import Foundation

struct URLFactory {
    static func create(with path: String) -> URL {
        let url: URL

        if #available(iOS 16.0, *) {
            url = .init(filePath: path)
        } else {
            url = .init(fileURLWithPath: path)
        }

        return url
    }
}
