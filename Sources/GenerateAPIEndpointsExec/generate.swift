import Foundation

/// Optimally this should be an API call to fetch fresh data, but Discord doesn't yet
/// fully support OpenAPI, so we just use a manually-downloaded for now.
///
/// The file is the Discord API's (alpha) postman collection
/// (https://www.postman.com/discord-api) which is exported and then
/// converted to the OpenAPI format.

func makeCase(_ info: API.Path.Info) -> String {
    let summary = info.summary.toCamelCase()
    if summary.isEmpty {
        fatalError("Summary is empty: \(info)")
    }
    
    let pathParams = (info.parameters ?? []).filter({ $0.in == .path })
    if pathParams.isEmpty {
        return "case \(summary)"
    } else {
        let paths = pathParams.map { param -> String in
            let type = param.schema.type.swiftTypeString
            let paramName = param.name.toCamelCase()
            return "\(paramName): \(type)"
        }.joined(separator: ", ")
        return "case \(summary)(\(paths))"
    }
}

func makeIterativeCase(_ info: API.Path.Info) -> (name: String, params: [String]) {
    let summary = info.summary.toCamelCase()
    if summary.isEmpty {
        fatalError("Summary is empty: \(info)")
    }
    let pathParams = (info.parameters ?? []).filter({ $0.in == .path })
    if pathParams.isEmpty {
        return ("case .\(summary):", [])
    } else {
        let paths = pathParams.map { param -> String in
            let paramName = param.name.toCamelCase()
            return paramName
        }
        let pathsJoined = paths.joined(separator: ", ")
        return ("case let .\(summary)(\(pathsJoined)):", paths)
    }
}

func makeRawCaseName(_ info: API.Path.Info) -> String {
    let summary = info.summary.toCamelCase()
    if summary.isEmpty {
        fatalError("Summary is empty: \(info)")
    }
    return "case .\(summary):"
}

@_disfavoredOverload
func makeRawCaseName(_ info: API.Path.Info) -> (name: String, params: [String]) {
    let summary = info.summary.toCamelCase()
    if summary.isEmpty {
        fatalError("Summary is empty: \(info)")
    }
    let pathParams = (info.parameters ?? []).filter({ $0.in == .path })
    let paths = pathParams.map { param -> String in
        let paramName = param.name.toCamelCase()
        return paramName
    }
    return ("case .\(summary):", paths)
}

let decoded = API.decode()

let grouped = Dictionary(grouping: decoded.paths) {
    $0.info.tags[0]
}.sorted(by: { $0.key.priority > $1.key.priority })

let cases = grouped.map { tag, infos in
    (tag, infos.map(\.info).map(makeCase))
}.map { tag, infos in
    """
    // MARK: \(tag.rawValue)
    /// \(tag.link)
    
    \(infos.joined(separator: "\n"))
    """
}.joined(separator: "\n\n")

extension String {
    /// Indents 4 spaces.
    func indent() -> String {
        self.components(separatedBy: .newlines).map {
            "    \($0)"
        }.joined(separator: "\n")
    }
}

let urlPrefixString = """
var urlPrefix: String {
    "https://discord.com/api/v\\(DiscordGlobalConfiguration.apiVersion)/"
}
"""

let _url = grouped.flatMap(\.value).map { info in
    let (name, params) = makeIterativeCase(info.info)
    var split = info.path.split(whereSeparator: { ["{", "}"].contains($0) })
    var iterator = params.makeIterator()
    var last: String? = nil
    for (idx, value) in split.enumerated() {
        let camel = value.toCamelCase()
        let param = last ?? iterator.next()
        if param == camel {
            split[idx] = #"\(\#(camel))"#
            last = nil
        } else {
            last = param
        }
    }
    var suffix = split.joined()
    guard suffix.removeFirst() == "/" else {
        fatalError("'\(split.joined())' did not start with a slash '/'")
    }
    let paramsEncoded = params.map { param in
        #"let \#(param) = encoded(\#(param))"#
    }.joined(separator: "\n")
    let pramsWithNewLine = params.isEmpty ? "" : "\n" + paramsEncoded.indent()
    let ret = #"suffix = "\#(suffix)""#
    return name + pramsWithNewLine + "\n" + ret.indent()
}.joined(separator: "\n")

let urlString = """
public var url: String {
    func encoded(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? string
    }
    let suffix: String
    switch self {
\(_url.indent())
    }
    return urlPrefix + suffix
}
"""

let webhookTokenParam = "webhookToken"

let _urlDescription = grouped.flatMap(\.value).map { info in
    let (name, params) = makeIterativeCase(info.info)
    var split = info.path.split(whereSeparator: { ["{", "}"].contains($0) })
    var iterator = params.makeIterator()
    var last: String? = nil
    for (idx, value) in split.enumerated() {
        let camel = value.toCamelCase()
        let param = last ?? iterator.next()
        if param == camel {
            split[idx] = #"\(\#(camel))"#
            last = nil
        } else {
            last = param
        }
    }
    var suffix = split.joined()
    guard suffix.removeFirst() == "/" else {
        fatalError("'\(split.joined())' did not start with a slash '/'")
    }
    let paramsEncoded = params.map { param -> String in
        if param == webhookTokenParam {
            return #"let \#(param) = \#(param).urlPathEncoded().hash"#
        } else {
            return #"let \#(param) = \#(param).urlPathEncoded()"#
        }
    }.joined(separator: "\n")
    let pramsWithNewLine = params.isEmpty ? "" : "\n" + paramsEncoded.indent()
    let ret = #"suffix = "\#(suffix)""#
    return name + pramsWithNewLine + "\n" + ret.indent()
}.joined(separator: "\n")

let urlDescriptionString = """
public var urlDescription: String {
    let suffix: String
    switch self {
\(_urlDescription.indent())
    }
    return urlPrefix + suffix
}
"""

let _methods = grouped.flatMap(\.value).map {
    makeRawCaseName($0.info) + " return .\($0.method.rawValue)"
}.joined(separator: "\n")

let methodsString = """
public var httpMethod: HTTPMethod {
    switch self {
\(_methods.indent())
    }
}
"""

let _countsAgainstGlobalRateLimit = grouped.flatMap(\.value).map {
    makeRawCaseName($0.info) + " return \($0.info.tags.contains(where: \.countsAgainstGlobalRateLimit))"
}.joined(separator: "\n")

let countsAgainstGlobalRateLimitString = """
public var countsAgainstGlobalRateLimit: Bool {
    switch self {
\(_countsAgainstGlobalRateLimit.indent())
    }
}
"""

let _requiresAuthorizationHeader = grouped.flatMap(\.value).map { info -> String in
    let (name, params) = makeRawCaseName(info.info)
    let requires = params.contains(webhookTokenParam)
    return name + " return \(requires)"
}.joined(separator: "\n")

let requiresAuthorizationHeaderString = """
public var requiresAuthorizationHeader: Bool {
    switch self {
\(_requiresAuthorizationHeader.indent())
    }
}
"""

let _parameters = grouped.flatMap(\.value).map { info -> String in
    let (name, params) = makeIterativeCase(info.info)
    let ret = "return [\(params.joined(separator: ", "))]"
    return name + "\n" + ret.indent()
}.joined(separator: "\n")

let parametersString = """
public var parameters: [String] {
    switch self {
\(_parameters.indent())
    }
}
"""

var _id = grouped.flatMap(\.value).enumerated().map { idx, info in
    makeRawCaseName(info.info) + " return \(idx + 1)"
}.joined(separator: "\n")

let idString = """
public var id: Int {
    switch self {
\(_id.indent())
    }
}
"""

let result = """
// MARK: - DO NOT EDIT. Auto-generated endpoints using the GenerateAPIEndpoints command plugin.

import NIOHTTP1

public enum APIEndpoint: Endpoint {

\(cases.indent())

\(urlPrefixString.indent())

\(urlString.indent())

\(urlDescriptionString.indent())

\(methodsString.indent())

\(countsAgainstGlobalRateLimitString.indent())

\(requiresAuthorizationHeaderString.indent())

\(parametersString.indent())

\(idString.indent())
}
"""

@main
struct Main {
    static func main() async throws {
        let fm = FileManager.default
        let current = fm.currentDirectoryPath
        let path = current + "/Sources/DiscordHTTP/Endpoints/APIEndpoint.swift"
        let data = Data(result.utf8)
        let write = fm.createFile(atPath: path, contents: data)
        if !write {
            fatalError("Failed to create/write to file at \(path.debugDescription)")
        }
    }
}
