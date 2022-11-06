import MultipartKit
import NIOCore
import NIOHTTP1
import Foundation

public protocol MultipartEncodable: Encodable {
    var files: [File]? { get }
}

struct MultipartEncodingContainer: Encodable {
    
    struct JSON: Encodable, MultipartPartConvertible {
        var buffer: ByteBuffer
        
        var multipart: MultipartPart? {
            MultipartPart(
                headers: ["Content-Type": "application/json"],
                body: buffer
            )
        }
        
        init? (multipart: MultipartPart) {
            self.buffer = multipart.body
        }
        
        init<E: Encodable>(from encodable: E) throws {
            let data = try DiscordGlobalConfiguration.encoder.encode(encodable)
            self.buffer = .init(data: data)
        }
        
        func encode(to encoder: Encoder) throws {
            var buffer = buffer
            if let data = buffer.readData(length: buffer.readableBytes) {
                var container = encoder.singleValueContainer()
                try container.encode(data)
            } else {
                throw EncodingError.invalidValue(buffer, .init(
                    codingPath: encoder.codingPath,
                    debugDescription: "Could not encode ByteBuffer"
                ))
            }
        }
    }
    
    static let boundary: String = {
        let random1 = (0..<4).map { _ in Int.random(in: 0..<10) }.map { "\($0)" }.joined()
        let random2 = (0..<4).map { _ in Int.random(in: 0..<10) }.map { "\($0)" }.joined()
        return random1 + "discordbm" + random2
    }()
    
    var payload_json: JSON
    var files: [File]
}

private let allocator = ByteBufferAllocator()

extension MultipartEncodable {
    func encodeMultipart() throws -> ByteBuffer? {
        guard let files = self.files else { return nil }
        var buffer = allocator.buffer(capacity: 1024)
        let data = MultipartEncodingContainer(
            payload_json: try .init(from: self),
            files: files
        )
        try DiscordGlobalConfiguration.multipartEncoder.encode(
            data,
            boundary: MultipartEncodingContainer.boundary,
            into: &buffer
        )
        return buffer
    }
}


public struct File: Sendable, Codable, MultipartPartConvertible, Equatable {
    /// Name of the file, including extension.
    public var filename: String
    
    /// The file's data.
    public var data: ByteBuffer
    
    /// The file extension, if it has one.
    public var `extension`: String? {
        let parts = self.filename.split(separator: ".")
        if parts.count > 1 {
            return parts.last.map(String.init)
        } else {
            return nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case data, filename
    }
    
    /// `Decodable` conformance.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: .data)
        var buffer = ByteBufferAllocator().buffer(capacity: 0)
        buffer.writeBytes(data)
        let filename = try container.decode(String.self, forKey: .filename)
        self.init(data: buffer, filename: filename)
    }
    
    /// `Encodable` conformance.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let data = self.data.getData(at: self.data.readerIndex, length: self.data.readableBytes)
        try container.encode(data, forKey: .data)
        try container.encode(self.filename, forKey: .filename)
    }
    
    /// Creates a new `File`.
    ///
    ///     let file = File(data: "hello", filename: "foo.txt")
    ///
    /// - parameters:
    ///     - data: The file's contents.
    ///     - filename: The name of the file, not including path.
    public init(data: String, filename: String) {
        let buffer = ByteBufferAllocator().buffer(string: data)
        self.init(data: buffer, filename: filename)
    }
    
    /// Creates a new `File`.
    ///
    ///     let file = File(data: "hello", filename: "foo.txt")
    ///
    /// - parameters:
    ///     - data: The file's contents.
    ///     - filename: The name of the file, not including path.
    public init(data: ByteBuffer, filename: String) {
        self.data = data
        self.filename = filename
    }
    
    public var multipart: MultipartPart? {
        var part = MultipartPart(headers: [:], body: .init(self.data.readableBytesView))
        if let ext = self.extension,
           let (type, subType) = Self.fileExtensionMediaTypeMapping[ext] {
            part.headers.add(name: "Content-Type", value: "\(type)/\(subType)")
        }
        part.headers.add(name: "Content-Disposition", value: #"form-data; filename="\#(self.filename)""#)
        return part
    }
    
    public init? (multipart: MultipartPart) {
        if let header = multipart.headers.first(name: "Content-Disposition") {
            let parts = header.split(separator: ";").compactMap {
                part -> (key: Substring, value: Substring)? in
                var part = part
                if part.first == " " {
                    part.removeFirst()
                }
                let split = part.split(separator: "=")
                guard split.count == 2 else { return nil }
                return (split[0], split[1])
            }
            let filename = parts.first(where: { ["filename", "filename*"].contains($0.key) })
            if let filename = filename {
                self.filename = String(filename.value)
            } else {
                return nil
            }
        } else {
            return nil
        }
        self.data = multipart.body
    }
    
    static let fileExtensionMediaTypeMapping: [String: (type: String, subType: String)] = [
        "ez": (type: "application", subType: "andrew-inset"),
        "anx": (type: "application", subType: "annodex"),
        "atom": (type: "application", subType: "atom+xml"),
        "atomcat": (type: "application", subType: "atomcat+xml"),
        "atomsrv": (type: "application", subType: "atomserv+xml"),
        "lin": (type: "application", subType: "bbolin"),
        "cu": (type: "application", subType: "cu-seeme"),
        "davmount": (type: "application", subType: "davmount+xml"),
        "dcm": (type: "application", subType: "dicom"),
        "tsp": (type: "application", subType: "dsptype"),
        "es": (type: "application", subType: "ecmascript"),
        "spl": (type: "application", subType: "futuresplash"),
        "hta": (type: "application", subType: "hta"),
        "jar": (type: "application", subType: "java-archive"),
        "ser": (type: "application", subType: "java-serialized-object"),
        "class": (type: "application", subType: "java-vm"),
        "js": (type: "application", subType: "javascript"),
        "mjs": (type: "application", subType: "javascript"),
        "json": (type: "application", subType: "json"),
        "m3g": (type: "application", subType: "m3g"),
        "hqx": (type: "application", subType: "mac-binhex40"),
        "cpt": (type: "application", subType: "mac-compactpro"),
        "nb": (type: "application", subType: "mathematica"),
        "nbp": (type: "application", subType: "mathematica"),
        "mbox": (type: "application", subType: "mbox"),
        "mdb": (type: "application", subType: "msaccess"),
        "doc": (type: "application", subType: "msword"),
        "dot": (type: "application", subType: "msword"),
        "mxf": (type: "application", subType: "mxf"),
        "bin": (type: "application", subType: "octet-stream"),
        "oda": (type: "application", subType: "oda"),
        "ogx": (type: "application", subType: "ogg"),
        "one": (type: "application", subType: "onenote"),
        "onetoc2": (type: "application", subType: "onenote"),
        "onetmp": (type: "application", subType: "onenote"),
        "onepkg": (type: "application", subType: "onenote"),
        "pdf": (type: "application", subType: "pdf"),
        "pgp": (type: "application", subType: "pgp-encrypted"),
        "key": (type: "application", subType: "pgp-keys"),
        "sig": (type: "application", subType: "pgp-signature"),
        "prf": (type: "application", subType: "pics-rules"),
        "ps": (type: "application", subType: "postscript"),
        "ai": (type: "application", subType: "postscript"),
        "eps": (type: "application", subType: "postscript"),
        "epsi": (type: "application", subType: "postscript"),
        "epsf": (type: "application", subType: "postscript"),
        "eps2": (type: "application", subType: "postscript"),
        "eps3": (type: "application", subType: "postscript"),
        "rar": (type: "application", subType: "rar"),
        "rdf": (type: "application", subType: "rdf+xml"),
        "rtf": (type: "application", subType: "rtf"),
        "stl": (type: "application", subType: "sla"),
        "smi": (type: "application", subType: "smil+xml"),
        "smil": (type: "application", subType: "smil+xml"),
        "xhtml": (type: "application", subType: "xhtml+xml"),
        "xht": (type: "application", subType: "xhtml+xml"),
        "xml": (type: "application", subType: "xml"),
        "xsd": (type: "application", subType: "xml"),
        "xsl": (type: "application", subType: "xslt+xml"),
        "xslt": (type: "application", subType: "xslt+xml"),
        "xspf": (type: "application", subType: "xspf+xml"),
        "zip": (type: "application", subType: "zip"),
        "apk": (type: "application", subType: "vnd.android.package-archive"),
        "cdy": (type: "application", subType: "vnd.cinderella"),
        "kml": (type: "application", subType: "vnd.google-earth.kml+xml"),
        "kmz": (type: "application", subType: "vnd.google-earth.kmz"),
        "xul": (type: "application", subType: "vnd.mozilla.xul+xml"),
        "xls": (type: "application", subType: "vnd.ms-excel"),
        "xlb": (type: "application", subType: "vnd.ms-excel"),
        "xlt": (type: "application", subType: "vnd.ms-excel"),
        "xlam": (type: "application", subType: "vnd.ms-excel.addin.macroEnabled.12"),
        "xlsb": (type: "application", subType: "vnd.ms-excel.sheet.binary.macroEnabled.12"),
        "xlsm": (type: "application", subType: "vnd.ms-excel.sheet.macroEnabled.12"),
        "xltm": (type: "application", subType: "vnd.ms-excel.template.macroEnabled.12"),
        "eot": (type: "application", subType: "vnd.ms-fontobject"),
        "thmx": (type: "application", subType: "vnd.ms-officetheme"),
        "cat": (type: "application", subType: "vnd.ms-pki.seccat"),
        "ppt": (type: "application", subType: "vnd.ms-powerpoint"),
        "pps": (type: "application", subType: "vnd.ms-powerpoint"),
        "ppam": (type: "application", subType: "vnd.ms-powerpoint.addin.macroEnabled.12"),
        "pptm": (type: "application", subType: "vnd.ms-powerpoint.presentation.macroEnabled.12"),
        "sldm": (type: "application", subType: "vnd.ms-powerpoint.slide.macroEnabled.12"),
        "ppsm": (type: "application", subType: "vnd.ms-powerpoint.slideshow.macroEnabled.12"),
        "potm": (type: "application", subType: "vnd.ms-powerpoint.template.macroEnabled.12"),
        "docm": (type: "application", subType: "vnd.ms-word.document.macroEnabled.12"),
        "dotm": (type: "application", subType: "vnd.ms-word.template.macroEnabled.12"),
        "odc": (type: "application", subType: "vnd.oasis.opendocument.chart"),
        "odb": (type: "application", subType: "vnd.oasis.opendocument.database"),
        "odf": (type: "application", subType: "vnd.oasis.opendocument.formula"),
        "odg": (type: "application", subType: "vnd.oasis.opendocument.graphics"),
        "otg": (type: "application", subType: "vnd.oasis.opendocument.graphics-template"),
        "odi": (type: "application", subType: "vnd.oasis.opendocument.image"),
        "odp": (type: "application", subType: "vnd.oasis.opendocument.presentation"),
        "otp": (type: "application", subType: "vnd.oasis.opendocument.presentation-template"),
        "ods": (type: "application", subType: "vnd.oasis.opendocument.spreadsheet"),
        "ots": (type: "application", subType: "vnd.oasis.opendocument.spreadsheet-template"),
        "odt": (type: "application", subType: "vnd.oasis.opendocument.text"),
        "odm": (type: "application", subType: "vnd.oasis.opendocument.text-master"),
        "ott": (type: "application", subType: "vnd.oasis.opendocument.text-template"),
        "oth": (type: "application", subType: "vnd.oasis.opendocument.text-web"),
        "pptx": (type: "application", subType: "vnd.openxmlformats-officedocument.presentationml.presentation"),
        "sldx": (type: "application", subType: "vnd.openxmlformats-officedocument.presentationml.slide"),
        "ppsx": (type: "application", subType: "vnd.openxmlformats-officedocument.presentationml.slideshow"),
        "potx": (type: "application", subType: "vnd.openxmlformats-officedocument.presentationml.template"),
        "xlsx": (type: "application", subType: "vnd.openxmlformats-officedocument.spreadsheetml.sheet"),
        "xltx": (type: "application", subType: "vnd.openxmlformats-officedocument.spreadsheetml.template"),
        "docx": (type: "application", subType: "vnd.openxmlformats-officedocument.wordprocessingml.document"),
        "dotx": (type: "application", subType: "vnd.openxmlformats-officedocument.wordprocessingml.template"),
        "cod": (type: "application", subType: "vnd.rim.cod"),
        "mmf": (type: "application", subType: "vnd.smaf"),
        "sdc": (type: "application", subType: "vnd.stardivision.calc"),
        "sds": (type: "application", subType: "vnd.stardivision.chart"),
        "sda": (type: "application", subType: "vnd.stardivision.draw"),
        "sdd": (type: "application", subType: "vnd.stardivision.impress"),
        "sdf": (type: "application", subType: "vnd.stardivision.math"),
        "sdw": (type: "application", subType: "vnd.stardivision.writer"),
        "sgl": (type: "application", subType: "vnd.stardivision.writer-global"),
        "sxc": (type: "application", subType: "vnd.sun.xml.calc"),
        "stc": (type: "application", subType: "vnd.sun.xml.calc.template"),
        "sxd": (type: "application", subType: "vnd.sun.xml.draw"),
        "std": (type: "application", subType: "vnd.sun.xml.draw.template"),
        "sxi": (type: "application", subType: "vnd.sun.xml.impress"),
        "sti": (type: "application", subType: "vnd.sun.xml.impress.template"),
        "sxm": (type: "application", subType: "vnd.sun.xml.math"),
        "sxw": (type: "application", subType: "vnd.sun.xml.writer"),
        "sxg": (type: "application", subType: "vnd.sun.xml.writer.global"),
        "stw": (type: "application", subType: "vnd.sun.xml.writer.template"),
        "sis": (type: "application", subType: "vnd.symbian.install"),
        "cap": (type: "application", subType: "vnd.tcpdump.pcap"),
        "pcap": (type: "application", subType: "vnd.tcpdump.pcap"),
        "vsd": (type: "application", subType: "vnd.visio"),
        "wbxml": (type: "application", subType: "vnd.wap.wbxml"),
        "wmlc": (type: "application", subType: "vnd.wap.wmlc"),
        "wmlsc": (type: "application", subType: "vnd.wap.wmlscriptc"),
        "wpd": (type: "application", subType: "vnd.wordperfect"),
        "wp5": (type: "application", subType: "vnd.wordperfect5.1"),
        "wasm": (type: "application", subType: "wasm"),
        "wk": (type: "application", subType: "x-123"),
        "7z": (type: "application", subType: "x-7z-compressed"),
        "abw": (type: "application", subType: "x-abiword"),
        "dmg": (type: "application", subType: "x-apple-diskimage"),
        "bcpio": (type: "application", subType: "x-bcpio"),
        "torrent": (type: "application", subType: "x-bittorrent"),
        "cab": (type: "application", subType: "x-cab"),
        "cbr": (type: "application", subType: "x-cbr"),
        "cbz": (type: "application", subType: "x-cbz"),
        "cdf": (type: "application", subType: "x-cdf"),
        "cda": (type: "application", subType: "x-cdf"),
        "vcd": (type: "application", subType: "x-cdlink"),
        "pgn": (type: "application", subType: "x-chess-pgn"),
        "mph": (type: "application", subType: "x-comsol"),
        "cpio": (type: "application", subType: "x-cpio"),
        "csh": (type: "application", subType: "x-csh"),
        "deb": (type: "application", subType: "x-debian-package"),
        "udeb": (type: "application", subType: "x-debian-package"),
        "dcr": (type: "application", subType: "x-director"),
        "dir": (type: "application", subType: "x-director"),
        "dxr": (type: "application", subType: "x-director"),
        "dms": (type: "application", subType: "x-dms"),
        "wad": (type: "application", subType: "x-doom"),
        "dvi": (type: "application", subType: "x-dvi"),
        "pfa": (type: "application", subType: "x-font"),
        "pfb": (type: "application", subType: "x-font"),
        "gsf": (type: "application", subType: "x-font"),
        "pcf": (type: "application", subType: "x-font"),
        "pcf.Z": (type: "application", subType: "x-font"),
        "woff": (type: "application", subType: "x-font-woff"),
        "mm": (type: "application", subType: "x-freemind"),
        "gan": (type: "application", subType: "x-ganttproject"),
        "gnumeric": (type: "application", subType: "x-gnumeric"),
        "sgf": (type: "application", subType: "x-go-sgf"),
        "gcf": (type: "application", subType: "x-graphing-calculator"),
        "gtar": (type: "application", subType: "x-gtar"),
        "tgz": (type: "application", subType: "x-gtar-compressed"),
        "taz": (type: "application", subType: "x-gtar-compressed"),
        "hdf": (type: "application", subType: "x-hdf"),
        "hwp": (type: "application", subType: "x-hwp"),
        "ica": (type: "application", subType: "x-ica"),
        "info": (type: "application", subType: "x-info"),
        "ins": (type: "application", subType: "x-internet-signup"),
        "isp": (type: "application", subType: "x-internet-signup"),
        "iii": (type: "application", subType: "x-iphone"),
        "iso": (type: "application", subType: "x-iso9660-image"),
        "jam": (type: "application", subType: "x-jam"),
        "jnlp": (type: "application", subType: "x-java-jnlp-file"),
        "jmz": (type: "application", subType: "x-jmol"),
        "chrt": (type: "application", subType: "x-kchart"),
        "kil": (type: "application", subType: "x-killustrator"),
        "skp": (type: "application", subType: "x-koan"),
        "skd": (type: "application", subType: "x-koan"),
        "skt": (type: "application", subType: "x-koan"),
        "skm": (type: "application", subType: "x-koan"),
        "kpr": (type: "application", subType: "x-kpresenter"),
        "kpt": (type: "application", subType: "x-kpresenter"),
        "ksp": (type: "application", subType: "x-kspread"),
        "kwd": (type: "application", subType: "x-kword"),
        "kwt": (type: "application", subType: "x-kword"),
        "latex": (type: "application", subType: "x-latex"),
        "lha": (type: "application", subType: "x-lha"),
        "lyx": (type: "application", subType: "x-lyx"),
        "lzh": (type: "application", subType: "x-lzh"),
        "lzx": (type: "application", subType: "x-lzx"),
        "frm": (type: "application", subType: "x-maker"),
        "maker": (type: "application", subType: "x-maker"),
        "frame": (type: "application", subType: "x-maker"),
        "fm": (type: "application", subType: "x-maker"),
        "fb": (type: "application", subType: "x-maker"),
        "book": (type: "application", subType: "x-maker"),
        "fbdoc": (type: "application", subType: "x-maker"),
        "md5": (type: "application", subType: "x-md5"),
        "mif": (type: "application", subType: "x-mif"),
        "m3u8": (type: "application", subType: "x-mpegURL"),
        "wmd": (type: "application", subType: "x-ms-wmd"),
        "wmz": (type: "application", subType: "x-ms-wmz"),
        "com": (type: "application", subType: "x-msdos-program"),
        "exe": (type: "application", subType: "x-msdos-program"),
        "bat": (type: "application", subType: "x-msdos-program"),
        "dll": (type: "application", subType: "x-msdos-program"),
        "msi": (type: "application", subType: "x-msi"),
        "nc": (type: "application", subType: "x-netcdf"),
        "pac": (type: "application", subType: "x-ns-proxy-autoconfig"),
        "dat": (type: "application", subType: "x-ns-proxy-autoconfig"),
        "nwc": (type: "application", subType: "x-nwc"),
        "o": (type: "application", subType: "x-object"),
        "oza": (type: "application", subType: "x-oz-application"),
        "p7r": (type: "application", subType: "x-pkcs7-certreqresp"),
        "crl": (type: "application", subType: "x-pkcs7-crl"),
        "pyc": (type: "application", subType: "x-python-code"),
        "pyo": (type: "application", subType: "x-python-code"),
        "qgs": (type: "application", subType: "x-qgis"),
        "shp": (type: "application", subType: "x-qgis"),
        "shx": (type: "application", subType: "x-qgis"),
        "qtl": (type: "application", subType: "x-quicktimeplayer"),
        "rdp": (type: "application", subType: "x-rdp"),
        "rpm": (type: "application", subType: "x-redhat-package-manager"),
        "rss": (type: "application", subType: "x-rss+xml"),
        "rb": (type: "application", subType: "x-ruby"),
        "sci": (type: "application", subType: "x-scilab"),
        "sce": (type: "application", subType: "x-scilab"),
        "xcos": (type: "application", subType: "x-scilab-xcos"),
        "sh": (type: "application", subType: "x-sh"),
        "sha1": (type: "application", subType: "x-sha1"),
        "shar": (type: "application", subType: "x-shar"),
        "swf": (type: "application", subType: "x-shockwave-flash"),
        "swfl": (type: "application", subType: "x-shockwave-flash"),
        "scr": (type: "application", subType: "x-silverlight"),
        "sql": (type: "application", subType: "x-sql"),
        "sit": (type: "application", subType: "x-stuffit"),
        "sitx": (type: "application", subType: "x-stuffit"),
        "sv4cpio": (type: "application", subType: "x-sv4cpio"),
        "sv4crc": (type: "application", subType: "x-sv4crc"),
        "tar": (type: "application", subType: "x-tar"),
        "tcl": (type: "application", subType: "x-tcl"),
        "gf": (type: "application", subType: "x-tex-gf"),
        "pk": (type: "application", subType: "x-tex-pk"),
        "texinfo": (type: "application", subType: "x-texinfo"),
        "texi": (type: "application", subType: "x-texinfo"),
        "~": (type: "application", subType: "x-trash"),
        "%": (type: "application", subType: "x-trash"),
        "bak": (type: "application", subType: "x-trash"),
        "old": (type: "application", subType: "x-trash"),
        "sik": (type: "application", subType: "x-trash"),
        "t": (type: "application", subType: "x-troff"),
        "tr": (type: "application", subType: "x-troff"),
        "roff": (type: "application", subType: "x-troff"),
        "man": (type: "application", subType: "x-troff-man"),
        "me": (type: "application", subType: "x-troff-me"),
        "ms": (type: "application", subType: "x-troff-ms"),
        "ustar": (type: "application", subType: "x-ustar"),
        "src": (type: "application", subType: "x-wais-source"),
        "wz": (type: "application", subType: "x-wingz"),
        "crt": (type: "application", subType: "x-x509-ca-cert"),
        "xcf": (type: "application", subType: "x-xcf"),
        "fig": (type: "application", subType: "x-xfig"),
        "xpi": (type: "application", subType: "x-xpinstall"),
        "amr": (type: "audio", subType: "amr"),
        "awb": (type: "audio", subType: "amr-wb"),
        "axa": (type: "audio", subType: "annodex"),
        "au": (type: "audio", subType: "basic"),
        "snd": (type: "audio", subType: "basic"),
        "csd": (type: "audio", subType: "csound"),
        "orc": (type: "audio", subType: "csound"),
        "sco": (type: "audio", subType: "csound"),
        "flac": (type: "audio", subType: "flac"),
        "mid": (type: "audio", subType: "midi"),
        "midi": (type: "audio", subType: "midi"),
        "kar": (type: "audio", subType: "midi"),
        "mpga": (type: "audio", subType: "mpeg"),
        "mpega": (type: "audio", subType: "mpeg"),
        "mp2": (type: "audio", subType: "mpeg"),
        "mp3": (type: "audio", subType: "mpeg"),
        "m4a": (type: "audio", subType: "mpeg"),
        "m3u": (type: "audio", subType: "mpegurl"),
        "oga": (type: "audio", subType: "ogg"),
        "ogg": (type: "audio", subType: "ogg"),
        "opus": (type: "audio", subType: "ogg"),
        "spx": (type: "audio", subType: "ogg"),
        "sid": (type: "audio", subType: "prs.sid"),
        "aif": (type: "audio", subType: "x-aiff"),
        "aiff": (type: "audio", subType: "x-aiff"),
        "aifc": (type: "audio", subType: "x-aiff"),
        "gsm": (type: "audio", subType: "x-gsm"),
        "wma": (type: "audio", subType: "x-ms-wma"),
        "wax": (type: "audio", subType: "x-ms-wax"),
        "ra": (type: "audio", subType: "x-pn-realaudio"),
        "rm": (type: "audio", subType: "x-pn-realaudio"),
        "ram": (type: "audio", subType: "x-pn-realaudio"),
        "pls": (type: "audio", subType: "x-scpls"),
        "sd2": (type: "audio", subType: "x-sd2"),
        "wav": (type: "audio", subType: "x-wav"),
        "alc": (type: "chemical", subType: "x-alchemy"),
        "cac": (type: "chemical", subType: "x-cache"),
        "cache": (type: "chemical", subType: "x-cache"),
        "csf": (type: "chemical", subType: "x-cache-csf"),
        "cbin": (type: "chemical", subType: "x-cactvs-binary"),
        "cascii": (type: "chemical", subType: "x-cactvs-binary"),
        "ctab": (type: "chemical", subType: "x-cactvs-binary"),
        "cdx": (type: "chemical", subType: "x-cdx"),
        "cer": (type: "chemical", subType: "x-cerius"),
        "c3d": (type: "chemical", subType: "x-chem3d"),
        "chm": (type: "chemical", subType: "x-chemdraw"),
        "cif": (type: "chemical", subType: "x-cif"),
        "cmdf": (type: "chemical", subType: "x-cmdf"),
        "cml": (type: "chemical", subType: "x-cml"),
        "cpa": (type: "chemical", subType: "x-compass"),
        "bsd": (type: "chemical", subType: "x-crossfire"),
        "csml": (type: "chemical", subType: "x-csml"),
        "csm": (type: "chemical", subType: "x-csml"),
        "ctx": (type: "chemical", subType: "x-ctx"),
        "cxf": (type: "chemical", subType: "x-cxf"),
        "cef": (type: "chemical", subType: "x-cxf"),
        "emb": (type: "chemical", subType: "x-embl-dl-nucleotide"),
        "embl": (type: "chemical", subType: "x-embl-dl-nucleotide"),
        "spc": (type: "chemical", subType: "x-galactic-spc"),
        "inp": (type: "chemical", subType: "x-gamess-input"),
        "gam": (type: "chemical", subType: "x-gamess-input"),
        "gamin": (type: "chemical", subType: "x-gamess-input"),
        "fch": (type: "chemical", subType: "x-gaussian-checkpoint"),
        "fchk": (type: "chemical", subType: "x-gaussian-checkpoint"),
        "cub": (type: "chemical", subType: "x-gaussian-cube"),
        "gau": (type: "chemical", subType: "x-gaussian-input"),
        "gjc": (type: "chemical", subType: "x-gaussian-input"),
        "gjf": (type: "chemical", subType: "x-gaussian-input"),
        "gal": (type: "chemical", subType: "x-gaussian-log"),
        "gcg": (type: "chemical", subType: "x-gcg8-sequence"),
        "gen": (type: "chemical", subType: "x-genbank"),
        "hin": (type: "chemical", subType: "x-hin"),
        "istr": (type: "chemical", subType: "x-isostar"),
        "ist": (type: "chemical", subType: "x-isostar"),
        "jdx": (type: "chemical", subType: "x-jcamp-dx"),
        "dx": (type: "chemical", subType: "x-jcamp-dx"),
        "kin": (type: "chemical", subType: "x-kinemage"),
        "mcm": (type: "chemical", subType: "x-macmolecule"),
        "mmd": (type: "chemical", subType: "x-macromodel-input"),
        "mmod": (type: "chemical", subType: "x-macromodel-input"),
        "mol": (type: "chemical", subType: "x-mdl-molfile"),
        "rd": (type: "chemical", subType: "x-mdl-rdfile"),
        "rxn": (type: "chemical", subType: "x-mdl-rxnfile"),
        "sd": (type: "chemical", subType: "x-mdl-sdfile"),
        "tgf": (type: "chemical", subType: "x-mdl-tgf"),
        "mcif": (type: "chemical", subType: "x-mmcif"),
        "mol2": (type: "chemical", subType: "x-mol2"),
        "b": (type: "chemical", subType: "x-molconn-Z"),
        "gpt": (type: "chemical", subType: "x-mopac-graph"),
        "mop": (type: "chemical", subType: "x-mopac-input"),
        "mopcrt": (type: "chemical", subType: "x-mopac-input"),
        "mpc": (type: "chemical", subType: "x-mopac-input"),
        "zmt": (type: "chemical", subType: "x-mopac-input"),
        "moo": (type: "chemical", subType: "x-mopac-out"),
        "mvb": (type: "chemical", subType: "x-mopac-vib"),
        "asn": (type: "chemical", subType: "x-ncbi-asn1"),
        "prt": (type: "chemical", subType: "x-ncbi-asn1-ascii"),
        "ent": (type: "chemical", subType: "x-ncbi-asn1-ascii"),
        "val": (type: "chemical", subType: "x-ncbi-asn1-binary"),
        "aso": (type: "chemical", subType: "x-ncbi-asn1-binary"),
        "pdb": (type: "chemical", subType: "x-pdb"),
        "ros": (type: "chemical", subType: "x-rosdal"),
        "sw": (type: "chemical", subType: "x-swissprot"),
        "vms": (type: "chemical", subType: "x-vamas-iso14976"),
        "vmd": (type: "chemical", subType: "x-vmd"),
        "xtel": (type: "chemical", subType: "x-xtel"),
        "xyz": (type: "chemical", subType: "x-xyz"),
        "gif": (type: "image", subType: "gif"),
        "ief": (type: "image", subType: "ief"),
        "jp2": (type: "image", subType: "jp2"),
        "jpg2": (type: "image", subType: "jp2"),
        "jpeg": (type: "image", subType: "jpeg"),
        "jpg": (type: "image", subType: "jpeg"),
        "jpe": (type: "image", subType: "jpeg"),
        "jpm": (type: "image", subType: "jpm"),
        "jpx": (type: "image", subType: "jpx"),
        "jpf": (type: "image", subType: "jpx"),
        "pcx": (type: "image", subType: "pcx"),
        "png": (type: "image", subType: "png"),
        "svg": (type: "image", subType: "svg+xml"),
        "svgz": (type: "image", subType: "svg+xml"),
        "tiff": (type: "image", subType: "tiff"),
        "tif": (type: "image", subType: "tiff"),
        "djvu": (type: "image", subType: "vnd.djvu"),
        "djv": (type: "image", subType: "vnd.djvu"),
        "ico": (type: "image", subType: "vnd.microsoft.icon"),
        "wbmp": (type: "image", subType: "vnd.wap.wbmp"),
        "cr2": (type: "image", subType: "x-canon-cr2"),
        "crw": (type: "image", subType: "x-canon-crw"),
        "ras": (type: "image", subType: "x-cmu-raster"),
        "cdr": (type: "image", subType: "x-coreldraw"),
        "pat": (type: "image", subType: "x-coreldrawpattern"),
        "cdt": (type: "image", subType: "x-coreldrawtemplate"),
        "erf": (type: "image", subType: "x-epson-erf"),
        "art": (type: "image", subType: "x-jg"),
        "jng": (type: "image", subType: "x-jng"),
        "bmp": (type: "image", subType: "x-ms-bmp"),
        "nef": (type: "image", subType: "x-nikon-nef"),
        "orf": (type: "image", subType: "x-olympus-orf"),
        "psd": (type: "image", subType: "x-photoshop"),
        "pnm": (type: "image", subType: "x-portable-anymap"),
        "pbm": (type: "image", subType: "x-portable-bitmap"),
        "pgm": (type: "image", subType: "x-portable-graymap"),
        "ppm": (type: "image", subType: "x-portable-pixmap"),
        "rgb": (type: "image", subType: "x-rgb"),
        "xbm": (type: "image", subType: "x-xbitmap"),
        "xpm": (type: "image", subType: "x-xpixmap"),
        "xwd": (type: "image", subType: "x-xwindowdump"),
        "eml": (type: "message", subType: "rfc822"),
        "igs": (type: "model", subType: "iges"),
        "iges": (type: "model", subType: "iges"),
        "msh": (type: "model", subType: "mesh"),
        "mesh": (type: "model", subType: "mesh"),
        "silo": (type: "model", subType: "mesh"),
        "wrl": (type: "model", subType: "vrml"),
        "vrml": (type: "model", subType: "vrml"),
        "x3dv": (type: "model", subType: "x3d+vrml"),
        "x3d": (type: "model", subType: "x3d+xml"),
        "x3db": (type: "model", subType: "x3d+binary"),
        "appcache": (type: "text", subType: "cache-manifest"),
        "ics": (type: "text", subType: "calendar"),
        "icz": (type: "text", subType: "calendar"),
        "css": (type: "text", subType: "css"),
        "csv": (type: "text", subType: "csv"),
        "323": (type: "text", subType: "h323"),
        "html": (type: "text", subType: "html"),
        "htm": (type: "text", subType: "html"),
        "shtml": (type: "text", subType: "html"),
        "uls": (type: "text", subType: "iuls"),
        "mml": (type: "text", subType: "mathml"),
        "asc": (type: "text", subType: "plain"),
        "txt": (type: "text", subType: "plain"),
        "text": (type: "text", subType: "plain"),
        "pot": (type: "text", subType: "plain"),
        "brf": (type: "text", subType: "plain"),
        "srt": (type: "text", subType: "plain"),
        "rtx": (type: "text", subType: "richtext"),
        "sct": (type: "text", subType: "scriptlet"),
        "wsc": (type: "text", subType: "scriptlet"),
        "tm": (type: "text", subType: "texmacs"),
        "tsv": (type: "text", subType: "tab-separated-values"),
        "ttl": (type: "text", subType: "turtle"),
        "jad": (type: "text", subType: "vnd.sun.j2me.app-descriptor"),
        "wml": (type: "text", subType: "vnd.wap.wml"),
        "wmls": (type: "text", subType: "vnd.wap.wmlscript"),
        "bib": (type: "text", subType: "x-bibtex"),
        "boo": (type: "text", subType: "x-boo"),
        "h++": (type: "text", subType: "x-c++hdr"),
        "hpp": (type: "text", subType: "x-c++hdr"),
        "hxx": (type: "text", subType: "x-c++hdr"),
        "hh": (type: "text", subType: "x-c++hdr"),
        "c++": (type: "text", subType: "x-c++src"),
        "cpp": (type: "text", subType: "x-c++src"),
        "cxx": (type: "text", subType: "x-c++src"),
        "cc": (type: "text", subType: "x-c++src"),
        "h": (type: "text", subType: "x-chdr"),
        "htc": (type: "text", subType: "x-component"),
        "c": (type: "text", subType: "x-csrc"),
        "d": (type: "text", subType: "x-dsrc"),
        "diff": (type: "text", subType: "x-diff"),
        "patch": (type: "text", subType: "x-diff"),
        "hs": (type: "text", subType: "x-haskell"),
        "java": (type: "text", subType: "x-java"),
        "ly": (type: "text", subType: "x-lilypond"),
        "lhs": (type: "text", subType: "x-literate-haskell"),
        "moc": (type: "text", subType: "x-moc"),
        "p": (type: "text", subType: "x-pascal"),
        "pas": (type: "text", subType: "x-pascal"),
        "gcd": (type: "text", subType: "x-pcs-gcd"),
        "pl": (type: "text", subType: "x-perl"),
        "pm": (type: "text", subType: "x-perl"),
        "py": (type: "text", subType: "x-python"),
        "scala": (type: "text", subType: "x-scala"),
        "etx": (type: "text", subType: "x-setext"),
        "sfv": (type: "text", subType: "x-sfv"),
        "tk": (type: "text", subType: "x-tcl"),
        "tex": (type: "text", subType: "x-tex"),
        "ltx": (type: "text", subType: "x-tex"),
        "sty": (type: "text", subType: "x-tex"),
        "cls": (type: "text", subType: "x-tex"),
        "vcs": (type: "text", subType: "x-vcalendar"),
        "vcf": (type: "text", subType: "x-vcard"),
        "3gp": (type: "video", subType: "3gpp"),
        "axv": (type: "video", subType: "annodex"),
        "dl": (type: "video", subType: "dl"),
        "dif": (type: "video", subType: "dv"),
        "dv": (type: "video", subType: "dv"),
        "fli": (type: "video", subType: "fli"),
        "gl": (type: "video", subType: "gl"),
        "mpeg": (type: "video", subType: "mpeg"),
        "mpg": (type: "video", subType: "mpeg"),
        "mpe": (type: "video", subType: "mpeg"),
        "ts": (type: "video", subType: "MP2T"),
        "mp4": (type: "video", subType: "mp4"),
        "qt": (type: "video", subType: "quicktime"),
        "mov": (type: "video", subType: "quicktime"),
        "ogv": (type: "video", subType: "ogg"),
        "webm": (type: "video", subType: "webm"),
        "mxu": (type: "video", subType: "vnd.mpegurl"),
        "flv": (type: "video", subType: "x-flv"),
        "lsf": (type: "video", subType: "x-la-asf"),
        "lsx": (type: "video", subType: "x-la-asf"),
        "mng": (type: "video", subType: "x-mng"),
        "asf": (type: "video", subType: "x-ms-asf"),
        "asx": (type: "video", subType: "x-ms-asf"),
        "wm": (type: "video", subType: "x-ms-wm"),
        "wmv": (type: "video", subType: "x-ms-wmv"),
        "wmx": (type: "video", subType: "x-ms-wmx"),
        "wvx": (type: "video", subType: "x-ms-wvx"),
        "avi": (type: "video", subType: "x-msvideo"),
        "movie": (type: "video", subType: "x-sgi-movie"),
        "mpv": (type: "video", subType: "x-matroska"),
        "mkv": (type: "video", subType: "x-matroska"),
        "ice": (type: "x-conference", subType: "x-cooltalk"),
        "sisx": (type: "x-epoc", subType: "x-sisx-app"),
        "vrm": (type: "x-world", subType: "x-vrml"),
    ]
}
