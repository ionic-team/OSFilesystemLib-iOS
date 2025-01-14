import Foundation

extension URL {
    static func create(with path: String) -> URL {
        let url: URL

        if #available(iOS 16.0, *) {
            url = .init(filePath: path)
        } else {
            url = .init(fileURLWithPath: path)
        }

        return url
    }

    func urlWithAppendingPath(_ path: String) -> URL {
        if #available(iOS 16.0, *) {
            self.appending(path: path)
        } else {
            self.appendingPathComponent(path)
        }
    }
}
