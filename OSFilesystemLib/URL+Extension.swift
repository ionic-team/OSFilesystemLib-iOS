import Foundation

extension URL {
    var urlPath: String {
        if #available(iOS 16.0, *) {
            path()
        } else {
            path
        }
    }

    func urlWithAppendingPath(_ path: String) -> URL {
        if #available(iOS 16.0, *) {
            appending(path: path)
        } else {
            appendingPathComponent(path)
        }
    }
}
