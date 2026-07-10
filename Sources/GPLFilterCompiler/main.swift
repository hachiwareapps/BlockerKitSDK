import BlockerKit
import CryptoKit
import Darwin
import Foundation
import WebKit

@main
struct GPLFilterCompiler {
    fileprivate static let defaultMaxRulesPerChunk = 3000

    static func main() async {
        do {
            try await run(arguments: Array(CommandLine.arguments.dropFirst()))
        } catch {
            writeError(error.localizedDescription)
            exit(1)
        }
    }

    private static func run(arguments: [String]) async throws {
        guard !arguments.isEmpty, arguments.first != "--help", arguments.first != "-h" else {
            printHelp()
            return
        }

        let options = try Options(arguments)
        let manifestURL = try options.fileURL(for: "--source-manifest")
        let outputDirectoryURL = try options.directoryURL(for: "--output-dir")
        let reportDirectoryURL = try options.directoryURL(for: "--report-dir")
        let checkoutRootURL = options.optionalDirectoryURL(for: "--checkout-dir")
            ?? FileManager.default.temporaryDirectory.appendingPathComponent(
                "BlockerKitGPLFilterCompiler-\(UUID().uuidString)",
                isDirectory: true
            )
        let shouldRemoveCheckoutRoot = options.optionalDirectoryURL(for: "--checkout-dir") == nil
        let prettyPrintedJSON = options.contains("--pretty")

        defer {
            if shouldRemoveCheckoutRoot {
                try? FileManager.default.removeItem(at: checkoutRootURL)
            }
        }

        let manifest = try SourceManifest.load(from: manifestURL)
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: outputDirectoryURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: reportDirectoryURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: checkoutRootURL, withIntermediateDirectories: true)

        var outputs: [GeneratedOutput] = []
        let outputRegistry = OutputRegistry()
        for source in manifest.sources {
            let checkoutURL = try checkout(source, into: checkoutRootURL)
            for directory in source.includedDirectories {
                let directoryOutputs = try await convertDirectory(
                    directory,
                    source: source,
                    checkoutURL: checkoutURL,
                    outputDirectoryURL: outputDirectoryURL,
                    reportDirectoryURL: reportDirectoryURL,
                    prettyPrintedJSON: prettyPrintedJSON,
                    outputRegistry: outputRegistry
                )
                outputs.append(contentsOf: directoryOutputs)
            }
        }

        try writeChecksums(for: outputs, outputDirectoryURL: outputDirectoryURL)
        try writeSummary(
            outputs: outputs,
            manifestURL: manifestURL,
            reportDirectoryURL: reportDirectoryURL
        )
        print("Generated \(outputs.count) Content Rule List JSON file(s).")
        print("Wrote checksums.sha256")
    }

    private static func checkout(_ source: FilterSource, into rootURL: URL) throws -> URL {
        let checkoutURL = rootURL.appendingPathComponent(source.checkoutDirectoryName, isDirectory: true)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: checkoutURL.path) {
            try fileManager.removeItem(at: checkoutURL)
        }
        try fileManager.createDirectory(at: checkoutURL, withIntermediateDirectories: true)

        try runProcess("git", ["init"], currentDirectoryURL: checkoutURL)
        try runProcess("git", ["remote", "add", "origin", source.upstreamURL], currentDirectoryURL: checkoutURL)
        try runProcess("git", ["fetch", "--depth", "1", "origin", source.commit], currentDirectoryURL: checkoutURL)
        try runProcess("git", ["checkout", "--detach", "FETCH_HEAD"], currentDirectoryURL: checkoutURL)

        let resolvedCommit = try runProcess(
            "git",
            ["rev-parse", "HEAD"],
            currentDirectoryURL: checkoutURL
        ).trimmingCharacters(in: .whitespacesAndNewlines)
        guard resolvedCommit.hasPrefix(source.commit) || source.commit.hasPrefix(resolvedCommit) else {
            throw ToolError(
                "Fetched commit \(resolvedCommit) does not match manifest commit \(source.commit) for \(source.upstreamURL)."
            )
        }

        return checkoutURL
    }

    private static func convertDirectory(
        _ directory: IncludedDirectory,
        source: FilterSource,
        checkoutURL: URL,
        outputDirectoryURL: URL,
        reportDirectoryURL: URL,
        prettyPrintedJSON: Bool,
        outputRegistry: OutputRegistry
    ) async throws -> [GeneratedOutput] {
        let directoryURL = try resolvedDirectoryURL(
            checkoutURL: checkoutURL,
            relativePath: directory.path
        )
        let outputPrefix = try directory.resolvedOutputPrefix(source: source)
        let maxRulesPerChunk = try directory.resolvedMaxRulesPerChunk(source: source)

        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            throw ToolError("Included directory does not exist: \(directory.path)")
        }

        let filterFileURLs = try fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: [.isRegularFileKey]
        )
        .filter { $0.pathExtension == "txt" }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
        guard !filterFileURLs.isEmpty else {
            throw ToolError("Included directory contains no .txt filter files: \(directory.path)")
        }

        let compiler = BlockerKitCompiler(
            options: BlockerKitCompiler.Options(
                includeNativeCosmeticRules: true,
                includeUserScriptRuntime: false,
                includeURLSchemeHandlerRules: false,
                prettyPrintedJSON: prettyPrintedJSON,
                contentRuleListMaxRuleCountPerChunk: maxRulesPerChunk
            )
        )

        var outputs: [GeneratedOutput] = []
        for filterFileURL in filterFileURLs {
            let sourceName = filterFileURL.deletingPathExtension().lastPathComponent
            try outputRegistry.reserve(
                identifier: "\(outputPrefix)_\(sourceName)",
                source: "\(source.upstreamURL):\(directory.path)/\(filterFileURL.lastPathComponent)"
            )
            let filterText = try String(contentsOf: filterFileURL, encoding: .utf8)
            let bundle = try await compiler.compile(filterText, progress: nil)
            let validation = try await validatedContentRuleListJSONChunks(
                bundle.contentRuleListJSONChunks,
                outputPrefix: outputPrefix,
                sourceFileURL: filterFileURL
            )
            let outputFiles = try writeContentRuleListJSONChunks(
                validation.chunks,
                sourceFileURL: filterFileURL,
                outputDirectoryURL: outputDirectoryURL,
                outputPrefix: outputPrefix
            )

            try writeReport(
                bundle.compilationReport,
                source: source,
                includedDirectory: directory.path,
                sourceFileURL: filterFileURL,
                outputFiles: outputFiles,
                validation: validation,
                reportDirectoryURL: reportDirectoryURL,
                outputPrefix: outputPrefix
            )

            outputs.append(contentsOf: outputFiles.map { outputFile in
                GeneratedOutput(
                    fileName: outputFile.fileName,
                    url: outputFile.url,
                    sourceRepository: source.upstreamURL,
                    sourceCommit: source.commit,
                    includedDirectory: directory.path,
                    sourceFileName: filterFileURL.lastPathComponent
                )
            })

            print(
                "Converted \(directory.path)/\(filterFileURL.lastPathComponent): "
                    + "\(bundle.statistics.generatedContentRuleCount) native rule(s), "
                    + "\(validation.chunks.count) WebKit-ready chunk(s), "
                    + "\(bundle.statistics.unsupportedRuleCount) unsupported rule(s), "
                    + "\(validation.droppedRules.count) WebKit-dropped rule(s)"
            )
        }

        return outputs
    }

    private static func resolvedDirectoryURL(checkoutURL: URL, relativePath: String) throws -> URL {
        guard !relativePath.hasPrefix("/") else {
            throw ToolError("Included directory must be relative to the checkout: \(relativePath)")
        }

        let root = checkoutURL.standardizedFileURL
        let directoryURL = checkoutURL
            .appendingPathComponent(relativePath, isDirectory: true)
            .standardizedFileURL
        guard directoryURL.path == root.path || directoryURL.path.hasPrefix(root.path + "/") else {
            throw ToolError("Included directory escapes the checkout: \(relativePath)")
        }
        return directoryURL
    }

    private static func writeContentRuleListJSONChunks(
        _ chunks: [String],
        sourceFileURL: URL,
        outputDirectoryURL: URL,
        outputPrefix: String
    ) throws -> [OutputFile] {
        let sourceName = sourceFileURL.deletingPathExtension().lastPathComponent

        return try chunks.enumerated().map { index, chunk in
            let identifier = contentRuleListJSONIdentifier(
                outputPrefix: outputPrefix,
                sourceName: sourceName,
                chunkIndex: index,
                chunkCount: chunks.count
            )
            let outputFileName = "ContentRuleList-\(identifier)"
            let outputFileURL = outputDirectoryURL.appendingPathComponent(outputFileName, isDirectory: false)
            try chunk.write(to: outputFileURL, atomically: true, encoding: .utf8)
            return OutputFile(fileName: outputFileName, url: outputFileURL)
        }
    }

    @MainActor
    private static func validatedContentRuleListJSONChunks(
        _ chunks: [String],
        outputPrefix: String,
        sourceFileURL: URL
    ) async throws -> ChunkValidationResult {
        guard !chunks.isEmpty else {
            return ChunkValidationResult(chunks: [], droppedRules: [])
        }

        let validationStoreURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            "BlockerKitGPLFilterCompilerValidation-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(at: validationStoreURL, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: validationStoreURL)
        }

        guard let store = WKContentRuleListStore(url: validationStoreURL) else {
            throw ToolError("Failed to create WKContentRuleListStore at \(validationStoreURL.path).")
        }

        let sourceName = sourceFileURL.deletingPathExtension().lastPathComponent
        let identifierBase = "\(outputPrefix)_\(sourceName)"
        var result = ChunkValidationResult(chunks: [], droppedRules: [])

        for (index, chunk) in chunks.enumerated() {
            let partial = try await validContentRuleListJSONChunks(
                from: chunk,
                identifier: "\(identifierBase)-validation-\(index)",
                store: store
            )
            result.chunks.append(contentsOf: partial.chunks)
            result.droppedRules.append(contentsOf: partial.droppedRules)
        }

        return result
    }

    @MainActor
    private static func validContentRuleListJSONChunks(
        from source: String,
        identifier: String,
        store: WKContentRuleListStore
    ) async throws -> ChunkValidationResult {
        let rules = try contentRules(in: source)
        guard !rules.isEmpty else {
            return ChunkValidationResult(chunks: [], droppedRules: [])
        }

        do {
            let bundle = try contentRuleListBundle(from: source)
            guard try await store.compileBlockerKitContentRuleList(identifier: identifier, from: bundle) != nil else {
                throw ToolError("WKContentRuleListStore returned no rule list for \(identifier).")
            }
            return ChunkValidationResult(chunks: [source], droppedRules: [])
        } catch {
            guard rules.count > 1 else {
                let droppedRuleJSON = try jsonString(from: rules[0])
                return ChunkValidationResult(
                    chunks: [],
                    droppedRules: [
                        DroppedContentRule(
                            identifier: identifier,
                            errorDescription: error.localizedDescription,
                            contentRuleJSON: droppedRuleJSON
                        )
                    ]
                )
            }

            let middleIndex = rules.count / 2
            let leftJSON = try contentRuleListJSON(from: Array(rules[..<middleIndex]))
            let rightJSON = try contentRuleListJSON(from: Array(rules[middleIndex...]))
            let left = try await validContentRuleListJSONChunks(
                from: leftJSON,
                identifier: "\(identifier)-0",
                store: store
            )
            let right = try await validContentRuleListJSONChunks(
                from: rightJSON,
                identifier: "\(identifier)-1",
                store: store
            )
            return ChunkValidationResult(
                chunks: left.chunks + right.chunks,
                droppedRules: left.droppedRules + right.droppedRules
            )
        }
    }

    private static func contentRuleListJSONIdentifier(
        outputPrefix: String,
        sourceName: String,
        chunkIndex: Int,
        chunkCount: Int
    ) -> String {
        if chunkCount == 1 {
            return "\(outputPrefix)_\(sourceName).json"
        }

        let chunkNumber = String(format: "%03d", chunkIndex + 1)
        return "\(outputPrefix)_\(sourceName)_chunk_\(chunkNumber).json"
    }

    private static func writeReport(
        _ report: FilterCompilationReport,
        source: FilterSource,
        includedDirectory: String,
        sourceFileURL: URL,
        outputFiles: [OutputFile],
        validation: ChunkValidationResult,
        reportDirectoryURL: URL,
        outputPrefix: String
    ) throws {
        let sourceName = sourceFileURL.deletingPathExtension().lastPathComponent
        let reportFileURL = reportDirectoryURL.appendingPathComponent(
            "\(outputPrefix)_\(sourceName).json",
            isDirectory: false
        )
        let reportEnvelope = ReportEnvelope(
            sourceRepository: source.upstreamURL,
            sourceCommit: source.commit,
            includedDirectory: includedDirectory,
            sourceFileName: sourceFileURL.lastPathComponent,
            outputFileNames: outputFiles.map(\.fileName),
            webKitValidationDroppedRuleCount: validation.droppedRules.count,
            webKitDroppedRules: validation.droppedRules,
            report: report
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(reportEnvelope)
        try data.write(to: reportFileURL, options: .atomic)
    }

    private static func writeChecksums(
        for outputs: [GeneratedOutput],
        outputDirectoryURL: URL
    ) throws {
        let checksumFileURL = outputDirectoryURL.appendingPathComponent("checksums.sha256", isDirectory: false)
        let lines = try outputs
            .sorted { $0.fileName < $1.fileName }
            .map { output -> String in
                let digest = try sha256HexDigest(for: output.url)
                return "\(digest)  \(output.fileName)"
            }
        try (lines.joined(separator: "\n") + "\n").write(
            to: checksumFileURL,
            atomically: true,
            encoding: .utf8
        )
    }

    private static func writeSummary(
        outputs: [GeneratedOutput],
        manifestURL: URL,
        reportDirectoryURL: URL
    ) throws {
        let summary = ConversionSummary(
            manifestPath: manifestURL.path,
            generatedAt: ISO8601DateFormatter().string(from: Date()),
            outputs: try outputs.sorted { $0.fileName < $1.fileName }.map { output in
                OutputSummary(
                    fileName: output.fileName,
                    sha256: try sha256HexDigest(for: output.url),
                    sourceRepository: output.sourceRepository,
                    sourceCommit: output.sourceCommit,
                    includedDirectory: output.includedDirectory,
                    sourceFileName: output.sourceFileName
                )
            }
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(summary)
        try data.write(
            to: reportDirectoryURL.appendingPathComponent("conversion-summary.json", isDirectory: false),
            options: .atomic
        )
    }

    private static func sha256HexDigest(for fileURL: URL) throws -> String {
        let digest = SHA256.hash(data: try Data(contentsOf: fileURL))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func contentRuleListBundle(from source: String) throws -> WKWebViewFilterBundle {
        let ruleCount = try contentRules(in: source).count
        return WKWebViewFilterBundle(
            contentRuleListJSON: source,
            contentRuleListJSONChunks: [source],
            userScripts: [],
            runtimeConfig: RuntimeConfig(),
            diagnostics: [],
            statistics: FilterCompilationStatistics(
                totalLines: 0,
                skippedLines: 0,
                parsedRules: ruleCount,
                nativeRuleCount: ruleCount,
                userScriptRuleCount: 0,
                approximateRuleCount: 0,
                unsupportedRuleCount: 0,
                generatedContentRuleCount: ruleCount,
                generatedContentRuleListChunkCount: 1,
                generatedUserScriptCount: 0
            )
        )
    }

    private static func contentRules(in source: String) throws -> [Any] {
        let data = Data(source.utf8)
        let object = try JSONSerialization.jsonObject(with: data)
        guard let rules = object as? [Any] else {
            throw ToolError("Content Rule List JSON must be an array.")
        }
        return rules
    }

    private static func contentRuleListJSON(from rules: [Any]) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: rules)
        return String(decoding: data, as: UTF8.self)
    }

    private static func jsonString(from object: Any) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
        return String(decoding: data, as: UTF8.self)
    }

    @discardableResult
    private static func runProcess(
        _ executable: String,
        _ arguments: [String],
        currentDirectoryURL: URL
    ) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [executable] + arguments
        process.currentDirectoryURL = currentDirectoryURL

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        let output = String(decoding: outputData, as: UTF8.self)
        guard process.terminationStatus == 0 else {
            throw ToolError("Command failed: \(executable) \(arguments.joined(separator: " "))\n\(output)")
        }
        return output
    }

    private static func printHelp() {
        print(
            """
            Usage:
              swift run gpl-filter-compiler \\
                --source-manifest filter-sources.json \\
                --output-dir outputs/filter-assets \\
                --report-dir outputs/reports

            Options:
              --source-manifest PATH  JSON manifest with upstreamURL, commit, includedDirectories, outputPrefix, and maxRulesPerChunk.
              --output-dir PATH       Directory for ContentRuleList-*.json and checksums.sha256.
              --report-dir PATH       Directory for conversion reports.
              --checkout-dir PATH     Optional reusable checkout directory. Defaults to a temporary directory.
              --pretty                Pretty-print generated Content Rule List JSON.
            """
        )
    }

    private static func writeError(_ message: String) {
        FileHandle.standardError.write(Data(("Error: \(message)\n").utf8))
    }
}

private struct Options {
    private var values: [String: String] = [:]
    private var flags: Set<String> = []

    init(_ arguments: [String]) throws {
        var iterator = arguments.makeIterator()
        while let argument = iterator.next() {
            guard argument.hasPrefix("--") else {
                throw ToolError("Unexpected argument: \(argument)")
            }

            if argument == "--pretty" {
                flags.insert(argument)
                continue
            }

            guard let value = iterator.next() else {
                throw ToolError("Missing value for \(argument).")
            }
            values[argument] = value
        }
    }

    func contains(_ flag: String) -> Bool {
        flags.contains(flag)
    }

    func value(for key: String) throws -> String {
        guard let value = values[key], !value.isEmpty else {
            throw ToolError("Missing required option: \(key)")
        }
        return value
    }

    func fileURL(for key: String) throws -> URL {
        URL(fileURLWithPath: try value(for: key), isDirectory: false)
    }

    func directoryURL(for key: String) throws -> URL {
        URL(fileURLWithPath: try value(for: key), isDirectory: true)
    }

    func optionalDirectoryURL(for key: String) -> URL? {
        values[key].map { URL(fileURLWithPath: $0, isDirectory: true) }
    }
}

private struct SourceManifest: Decodable {
    var sources: [FilterSource]

    static func load(from url: URL) throws -> SourceManifest {
        let manifest = try JSONDecoder().decode(SourceManifest.self, from: try Data(contentsOf: url))
        guard !manifest.sources.isEmpty else {
            throw ToolError("Manifest must contain at least one source.")
        }
        return manifest
    }
}

private struct FilterSource: Decodable {
    var name: String?
    var upstreamURL: String
    var commit: String
    var includedDirectories: [IncludedDirectory]
    var outputPrefix: String?
    var maxRulesPerChunk: Int?

    var checkoutDirectoryName: String {
        sanitizeFileName(name ?? URL(string: upstreamURL)?.lastPathComponent ?? upstreamURL)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SourceCodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        upstreamURL = try container.decodeFirstString(forKeys: [.upstreamURL, .upstreamUrl])
        commit = try container.decodeFirstString(forKeys: [.commit, .commitHash])
        includedDirectories = try container.decodeIfPresent(
            [IncludedDirectory].self,
            forKey: .includedDirectories
        ) ?? container.decodeIfPresent([IncludedDirectory].self, forKey: .directories) ?? []
        outputPrefix = try container.decodeIfPresent(String.self, forKey: .outputPrefix)
        maxRulesPerChunk = try container.decodeIfPresent(Int.self, forKey: .maxRulesPerChunk)

        guard !includedDirectories.isEmpty else {
            throw ToolError("Source \(upstreamURL) must include at least one directory.")
        }
        guard (7...64).contains(commit.count), commit.allSatisfy({ $0.isHexDigit }) else {
            throw ToolError("Source \(upstreamURL) must specify a 7 to 64 character hexadecimal commit hash.")
        }
    }
}

private enum SourceCodingKeys: String, CodingKey {
    case name
    case upstreamURL
    case upstreamUrl
    case commit
    case commitHash
    case includedDirectories
    case directories
    case outputPrefix
    case maxRulesPerChunk
}

private struct IncludedDirectory: Decodable {
    var path: String
    var outputPrefix: String?
    var maxRulesPerChunk: Int?

    init(from decoder: Decoder) throws {
        if let path = try? decoder.singleValueContainer().decode(String.self) {
            self.path = path
            self.outputPrefix = nil
            self.maxRulesPerChunk = nil
            return
        }

        let container = try decoder.container(keyedBy: DirectoryCodingKeys.self)
        path = try container.decode(String.self, forKey: .path)
        outputPrefix = try container.decodeIfPresent(String.self, forKey: .outputPrefix)
        maxRulesPerChunk = try container.decodeIfPresent(Int.self, forKey: .maxRulesPerChunk)
    }

    func resolvedOutputPrefix(source: FilterSource) throws -> String {
        guard let value = outputPrefix ?? source.outputPrefix, !value.isEmpty else {
            throw ToolError("Missing outputPrefix for included directory \(path).")
        }
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_."))
        guard value.unicodeScalars.allSatisfy(allowed.contains) else {
            throw ToolError("outputPrefix contains unsupported characters: \(value)")
        }
        return value
    }

    func resolvedMaxRulesPerChunk(source: FilterSource) throws -> Int {
        let value = maxRulesPerChunk ?? source.maxRulesPerChunk ?? GPLFilterCompiler.defaultMaxRulesPerChunk
        guard value > 0 else {
            throw ToolError("maxRulesPerChunk must be greater than zero for \(path).")
        }
        return value
    }
}

private enum DirectoryCodingKeys: String, CodingKey {
    case path
    case outputPrefix
    case maxRulesPerChunk
}

private extension KeyedDecodingContainer where Key == SourceCodingKeys {
    func decodeFirstString(forKeys keys: [SourceCodingKeys]) throws -> String {
        for key in keys {
            if let value = try decodeIfPresent(String.self, forKey: key), !value.isEmpty {
                return value
            }
        }

        let keyNames = keys.map(\.rawValue).joined(separator: " or ")
        throw ToolError("Missing required manifest field: \(keyNames)")
    }
}

private struct OutputFile {
    var fileName: String
    var url: URL
}

private final class OutputRegistry {
    private var sourcesByIdentifier: [String: String] = [:]

    func reserve(identifier: String, source: String) throws {
        if let existingSource = sourcesByIdentifier[identifier] {
            throw ToolError(
                "Output identifier \(identifier) is produced by both \(existingSource) and \(source)."
            )
        }
        sourcesByIdentifier[identifier] = source
    }
}

private struct GeneratedOutput {
    var fileName: String
    var url: URL
    var sourceRepository: String
    var sourceCommit: String
    var includedDirectory: String
    var sourceFileName: String
}

private struct ChunkValidationResult {
    var chunks: [String]
    var droppedRules: [DroppedContentRule]
}

private struct DroppedContentRule: Encodable {
    var identifier: String
    var errorDescription: String
    var contentRuleJSON: String
}

private struct ReportEnvelope: Encodable {
    var sourceRepository: String
    var sourceCommit: String
    var includedDirectory: String
    var sourceFileName: String
    var outputFileNames: [String]
    var webKitValidationDroppedRuleCount: Int
    var webKitDroppedRules: [DroppedContentRule]
    var report: FilterCompilationReport
}

private struct ConversionSummary: Encodable {
    var manifestPath: String
    var generatedAt: String
    var outputs: [OutputSummary]
}

private struct OutputSummary: Encodable {
    var fileName: String
    var sha256: String
    var sourceRepository: String
    var sourceCommit: String
    var includedDirectory: String
    var sourceFileName: String
}

private struct ToolError: LocalizedError {
    private let message: String

    init(_ message: String) {
        self.message = message
    }

    var errorDescription: String? {
        message
    }
}

private func sanitizeFileName(_ value: String) -> String {
    let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_."))
    let sanitized = value.unicodeScalars
        .map { allowed.contains($0) ? String($0) : "-" }
        .joined()
        .trimmingCharacters(in: CharacterSet(charactersIn: "-."))
    return sanitized.isEmpty ? "source" : sanitized
}
