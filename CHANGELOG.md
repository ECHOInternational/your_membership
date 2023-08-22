# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [2.0.0] - 2023-08-22
### Added
- Allow httparty v0.21.x
### Breaking
- Drop support for Ruby < 2.3

## [1.1.6] - 2021-02-17
### Added
- Allow httparty v0.18.x

## [1.1.5] - 2018-03-21
### Added
- Allow httparty v0.16.x

## [1.1.4] - 2017-08-18
### Fixed
- HTTParty monkey patch now handles nils properly.

## [1.1.3] - 2017-03-13
### Fixed
- Allow YourMembership::Sa::Members.profile_create to pass along
  a hashed password when one is present.

## [1.1.2] - 2017-02-16
### Added
- Allow httparty v0.14.x

## [1.1.1] - 2016-03-23
### Fixed
- Crash in `Profile#parse_custom_field_responses` when there are no
  CustomFieldResponses present.
