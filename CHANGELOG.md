## [1.1.2](https://github.com/ionic-team/ion-ios-filesystem/compare/1.1.1...1.1.2) (2026-03-10)


### Bug Fixes

* use Xcode to 16.4 instead of 26 ([#15](https://github.com/ionic-team/ion-ios-filesystem/issues/15)) ([c6f5049](https://github.com/ionic-team/ion-ios-filesystem/commit/c6f5049f8fff919282675c61786f9eb2e34690d1))

## [1.1.1](https://github.com/ionic-team/ion-ios-filesystem/compare/1.1.0...1.1.1) (2026-02-13)


### Bug Fixes

* Inconsistent error codes when missing file ([#14](https://github.com/ionic-team/ion-ios-filesystem/issues/14)) ([75d2681](https://github.com/ionic-team/ion-ios-filesystem/commit/75d26811672e6f0cc86dc2ff1a17c25a58a105fb))

## 1.1.0

### Features

- Feature: Alternative `readFile` and `readFileInChunks` methods with optional `length` and `offset` parameters.

## 1.0.1

### Fixes

- Do not add trailing slash to files.

## 1.0.0

### Features
- Add read operations, namely `readEntireFile(atURL:withEncoding:)`, `readFileInChunks(atURL:withEncoding:andChunkSize:)`, `listDirectory(atURL:)`, `getItemAttributes(atPath:)` and `getFileURL(atPath: withSearchPath:)`.
- Add write operations, namely `saveFile(atURL:withEncodingAndData:includeIntermediateDirectories:)` and `appendData(_:atURL:includeIntermediateDirectories:)`.
- Add directory operations, namely `createDirectory(atURL:includeIntermediateDirectories:)` and `removeDirectory(atURL:includeIntermediateDirectories:)`.
- Add file management operations, namely `deleteFile(atURL:)`, `renameItem(fromURL:toURL:)` and `copyItem(fromURL:toURL:)`.

### Chores
- Add dependency management contract file for CocoaPods and Swift Package Manager.
- Add GitHub Actions workflows.
- Create Repository
