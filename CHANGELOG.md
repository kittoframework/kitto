# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased

## [0.2.0] - 2016-10-31

### Added

* data-resolution="1080" dashboard attribute (506c6d2)
* labelLength, valueLength props on list widget (566edb13)
* truncate JavaScript helper function
* GET /dashboards redirects to the default dashboard (07d8497f)
* GET / redirects to the default dashboard (99cdef2)

## [0.1.1] - 2016-10-22

### Added

* Installer creates a sample jobs dashboard to monitor jobs

### Changed

* Supervisors are supervised using Supervisor.Spec.supervisor/3

## [0.1.0] - 2016-10-21

### Added

* Kitto.StatsServer which keeps stats about job runs
* A DSL to declare jobs. See: https://github.com/kittoframework/kitto#jobs
* Kitto.Time declares functions to handle time conversions
* mix kitto.server in :dev env watches assets and rebuilds then

### Changed

* Job processes are named

### Removed

* Kitto.Job.every(options, fun)  api is removed

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
