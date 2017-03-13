# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

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
