
public struct OSFilesystemLib {
    /// Constructor method.
    public init() {
        // Empty constructor
        // This is required for the library's callers.
    }
    
    public func ping(_ input: String) -> String {
        return "PONG_" + input
    }
}
