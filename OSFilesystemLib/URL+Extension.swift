import Foundation

extension URL {
    var urlPath: String {
        if #available(iOS 16.0, *) {
            path()
        } else {
            path
        }
    }
}
