# ion-ios-filesystem

A Swift library for iOS that provides access to the native file system. With this library, you can write and read files in different locations, manage directories, and more.

## Requirements

- iOS 14.0+
- Swift 5.0+
- Xcode 15.0+

## Installation

### CocoaPods

`ion-ios-filesystem` is available through [CocoaPods](https://cocoapods.org). Add this to your Podfile:

```ruby
pod 'IONFilesystemLib', '~> 1.1.2'
```

## Quick Start

This library is currently used by the File Plugin for OutSystems' [Cordova](https://github.com/ionic-team/cordova-outsystems-file) and [Capacitor](https://github.com/ionic-team/capacitor-filesystem) Plugins. Please check the library usage there for real use-case scenarios.

## Features

The library's features are divided in two protocols:

- `IONFILEDirectoryManager`
- `IONFILEFileManager`

The `IONFILEManager` implements both these protocols. To instantiate the library, you may do the following:

```swift
// declare the type alias if you need both file and directory operations; 
//  otherwise just use the specific protocol directly.
typealias FileManager = any IONFILEDirectoryManager & IONFILEFileManager

let fileManager: FileManager = IONFILEManager()
```

### `IONFILEDirectoryManager` 

The `IONFILEDirectoryManager` manages operations on directories:

- `createDirectory` - Creates a directory at the specified `URL`, with the option of also creating any missing intermediate directories, via `includeIntermediateDirectories` (`=false` to not create intermediate directories).
- `removeDirectory` - Deletes a directory at the specified `URL`, with the option of only removing the directory if it is empty, via `includeIntermediateDirectories` (`=true` to delete directory and children).
- `listDirectory` - Lists the children of a directory at the specified `URL` - returns a list of `URL`s for each of the files / sub-directories contained in the directory.

### `IONFILEFileManager`

The `IONFILEFileManager` contains most of the operations of the native library, for to manipulating files:

- `readEntireFile` - Reads the contents of a file at `URL` to memory.
- `readFileInChunks` - Reads the contents of a file in chunks. Especially useful for large files that may not fit in memory. See [this section](#reading-in-chunks-publisher) for more information
- `getFileURL` - get a native `URL` for a certain file, that may be located in a specific [Search Path](#file-search-paths).
- `deleteFile` - deletes a file at the specified `URL`
- `saveFile` - Write contents to a file - overwriting any existing content. You may indicate to create missing parent directories via `includeIntermediateDirectories` attribute.
- `appendData` - Append contents to the end of a file. You may indicate to create missing parent directories via `includeIntermediateDirectories` attribute.
- `getItemAttributes` - Get extra information on a specific file (or directory) at the specified `URL`. See [File Attributes model](#file-attributes-model) section for more information on what the information is.
- `renameItem` - Rename or move a file (or directory) at `fromURL` to `toURL`. Note that you cannot move to an existing directory.
- `copyItem` - Copy a file (or directory + all its contents) at `fromURL` to `toURL`. Note that you cannot copy to `toURL` if it's an existing directory.

#### File search Paths

In certain situations, you may want to manage files only in a specific location in the storage system. You can do that via the `IONFILEDirectoryType` enum. You call `getFileURL` with `IONFILESearchPath.directory` and the file sub-path inside that specific directory (`atPath`) and use the returned `URL` in the other library methods.

Here are the available directory types:

- `cache` - To store discardable files in a cache. Do not use for long-term storage.
- `document` - The directory for storing documents in the app.
- `library` - Store files in teh app's sandbox directory.
- `notSyncedLibrary` - Same as `library`, except it's not cloud-synced.
- `temporary` - The directory for storing temporary files. Do not use for long-term storage.

#### File encondings

You have options to specify how you want to read data. Using the `IONFILEEncoding` class, you can specify the data to be:
1. `byteBuffer` - A binary `Data` object. Useful for reading binary files, and media files (images, videos).
2. `encoding` - Textual data. Useful for reading text files. You specify the character encoding via `IONFILEStringEncoding`: `utf8` (default), `utf16` or `ascii`.

When writing, you use the `IONFILEEncodingValueMapper` object, which is similar to `IONFILEEncoding`, except for mapper you pass the data you want to write
1. `byteBuffer` - Expects `value: Data`.
2. `encoding` - Expects `value: String` + an encoding of type `IONFILEStringEncoding`.

#### Reading in Chunks Publisher

The `readFileInChunks` is the only method that can return multiple values.

You pass a `IONFILEEncoding`, just like in `readEntireFile`, but you can also specify a `chunkSize`, that dictates that size of chunks (in bytes) to read from the file at a time. Smaller chunks means more chunks returned in total; larger chunks mean less chunks returned, but also larger memory footprint.

There is no "perfect" value for `chunkSize`, ultimately it may lie with your use case for reading files. Overall, we recommend a value that is at least a few KB large (e.g. 8KB -> `chunkSize: 8192`), to make sure file reading isn't too slow, but also at most a couple MB (`chunkSize: 2097152`), to avoid running into issues with devices with lower memory.

To actually receive the chunks, you need to use the `IONFILEChunkPublisher` with the [Combine framework](https://developer.apple.com/documentation/combine). Here is an example usage:

```swift
import Combine
import Foundation
import IONFilesystemLib

// ... instantiate manager, url, encoding and chunkSize
do {
    try manager.readFileInChunks(atURL: url, withEncoding: encoding, andChunkSize: chunkSize)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                // handle file finished reading successfully here
            case .failure(let error):
                // handle file read errors here
            }
        }, receiveValue: { chunkRead in
            // handle each chunk read (`IONFILEEncodingValueMapper`) here
        })
} catch {
    // handle any other errors here...
}

```

#### File Attributes model

You can get several relevant attributes and metadata on a file (or directory) via the `IONFILEItemAttributeModel` class:

- `creationDateTimestamp` - UNIX Time stamp of file creation, in milliseconds
- `modificationDateTimestamp` - UNIX Time stamp of when file was modified last, in milliseconds
- `size` - Size of the file, in bytes
- `type` - Either `directory` or `file`

## Error Handling

The library returns specific error structures when there are errors in filesystem operations. These are:

```swift
enum IONFILEDirectoryManagerError: Error {
    case notEmpty
    case alreadyExists
}

public enum IONFILEFileManagerError: Error {
    case cantCreateURL(forPath: String)
    case cantDecodeData(usingEncoding: IONFILEStringEncoding)
    case directoryNotFound(atPath: String)
    case fileNotFound(atPath: String)
    case missingParentFolder
}

public enum IONFILEChunkPublisherError: Error {
    case cantEncodeData(usingEncoding: IONFILEStringEncoding)
    case notAbleToReadFile
}
```

## Contributing

1. Fork the repository ("Copy only `main` branch" should be unchecked).
2. Checkout development branch (`git switch development`).
3. Create your feature branch (`git checkout -b feature/amazing-feature`).
4. Commit your changes (`git commit -m 'Add amazing feature'`).
5. Push to the branch (`git push origin feature/amazing-feature`).
6. Open a Pull Request to `development` branch.

## License

`ion-ios-filesystem` is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Support

- Report issues on our [Issue Tracker](https://github.com/ionic-team/ion-ios-filesystem/issues)
