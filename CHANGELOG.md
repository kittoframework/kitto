# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased

## [0.0.5] - 2016-10-10

### Added

* Kitto.Job.new/1 to support streaming jobs without interval
* Job cache. The last broadcasted message of each job is cached and sent
  upon connecting to `GET /events`

### Changed

* Supervise Notifier connections cache
* Supervise job processes

## [0.0.4] - 2016-10-05

### Fixed

* Properly serve assets in development via Webpack
* Fix deprecation warning caused by :random.uniform

## [0.0.3] - 2016-09-25

### Added

* gzipped assets are served in production
* Webpack plugin to produce gzipped assets

## [0.0.2] - 2016-09-24

### Added

* Assets are served in production

### Fixed

* Cowboy/Plug are not started twice
