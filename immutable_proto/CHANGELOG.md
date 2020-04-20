# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


<!-- Template:
## [NEW](https://github.com/JonasWanke/immutable_proto/compare/vOLD...vNEW) - 2019-xx-xx
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
-->

## [Unreleased](https://github.com/JonasWanke/immutable_proto/compare/v0.1.0...dev)

## [0.1.0](https://github.com/JonasWanke/immutable_proto/compare/v0.0.5...v0.1.0) - 2020-04-20
### ⚠ BREAKING CHANGES
- **generator:** use Dart's `List` instead of `KtList`

## 0.0.5+1 - 2019-10-06
### Fixed
- **generator:** reduce false positives when detecting nested messages/enums

## [0.0.5](https://github.com/JonasWanke/immutable_proto/compare/v0.0.4...v0.0.5) - 2019-10-06
### Changed
- **generator:** make enum values required

### Fixed
- **generator:** reduce false positives when detecting nested enums

## [0.0.4](https://github.com/JonasWanke/immutable_proto/compare/v0.0.3...v0.0.4) - 2019-10-04
### Changed
- **generator:** prefer null to empty values in `fromProto`

### Fixed
- **generator:** reduce false positives when detecting nested messages
- **generator:** generate correct mappers for fields of type message

## [0.0.3](https://github.com/JonasWanke/immutable_proto/compare/v0.0.2...v0.0.3) - 2019-10-03
### Fixed
- update dependencies

## [0.0.2](https://github.com/JonasWanke/immutable_proto/compare/v0.0.1...v0.0.2) - 2019-10-02
### Added
- **generator:** support references to non-nested messages

## 0.0.1 - 2019-10-02
Initial release.
