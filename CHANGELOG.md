# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased

## [0.7.0] - 2017-10-18

### Added

* `Kitto.Notifier.broadcast!/2` supports railroading.

Example:

```elixir
job :ci_status, every: :minute do
  # All the combinations below will do the expected thing and infer which
  parameter is the topic and which is the message

  CI.status(:awesome_project) |> broadcast!
  CI.status(:awesome_project) |> broadcast!(:projects)
  CI.status(:awesome_project) |> broadcast!(:projects)
  broadcast!(:projects, CI.status(:awesome_project))
end
```

### Fixed

* `mix.kitto new <name>` check for valid name in OTP 20
* Font loading in development, due to webpack-dev-server not setting CORS headers

## [0.6.0] - 2017-04-18

### Added

* Add {edge, dev, app} kitto.new options (see: https://github.com/kittoframework/kitto/blob/v0.6.0/installer/lib/kitto_new.ex#L83)

## [0.6.0-rc0] - 2017-04-11

### Added

* Sample distillery config and asset compilation plugin
* Sample `config/dev.exs` and `config/prod.exs`

### Changed

* `Kitto.root` returns `Application.app_dir` when `:root` is set to `:otp_app`
* For newly scaffolded apps, assets are built in `priv/static`
* Static assets are served from `priv/static` of application
* Assets are forwarder to webpack live builder only when `:watch_assets?` is set to true
* Elixir CodeReloader is disabled when `:reload_code?` is set to false

## [0.5.2] - 2017-03-30

### Fixed

* Prevent DoS due to Atom creation for event topic subscription (5323717)
* Prevent XSS in 404 page (63570c0)
* Prevent directory traversal for dashboard templates (#103)

## [0.5.1] - 2017-02-21

### Fixed

* Added missing package.json to mix.exs

## [0.5.0] - 2017-02-19

### Changed

* The core Kitto JavaScript library is now packaged (#39, #72)
  Read: [upgrading-guide](https://github.com/kittoframework/kitto/wiki/Upgrading-Guide#050)

### Fixed

* Typo in jobs generated dashboard setting invalid invalid source for 
"average time took" widget

* Compilation warnings for Elixir v1.4

## [0.4.0] - 2017-01-12

### Added

* Exponential back-off support for failing jobs (b20064a)

* Widget generator task

  ```shell
  mix kitto.gen.widget weather
  # Generates:
  #   * widgets/weather/weather.js
  #   * widgets/weather/weather.scss
  ```

* Job generator task

  ```shell
  mix kitto.gen.job weather
  # Generates: jobs/weather.exs
  ```

* Dashboard generator task

  ```shell
  mix kitto.gen.dashboard weather
  # Generates: dashboards/weather.html.eex
  ```

### Changed

* Warning and danger widget colors are swapped in new generated dashboards

## [0.3.2] - 2016-12-22

### Fixed

* Heroku static asset serving bug (see: #77)
* Kitto server not starting when asset watcher bin is missing

## [0.3.1] - 2016-12-20

### Fixed

* Code Reloader failure in macOS, see (#65)

## [0.3.0] - 2016-12-08

### Added

* `:command` option to job DSL

Example:

```elixir
job :kitto_last_commit,
    every: {5, :minutes},
    command: "curl https://api.github.com/repos/kittoframework/kitto/commits\?page\=1\&per_page\=1"
```

Broadcasts JSON in the form `{ "exit_code": "an integer", "stdout": "a string" }`

* Gist installer gist task
(see: https://github.com/kittoframework/kitto/wiki/Widget-and-Job-Directory#install-widgetsjob-from-a-gist)
* Code reloading in development (see: https://github.com/kittoframework/kitto/wiki/Code-Reloading)
* Job Syntax Validation. When a job contains syntax errors, it is not loaded.
* SSE Events filtering (a7777618)
* [installer] Heroku deployment files (see: https://github.com/kittoframework/kitto/wiki/Deploying-to-Heroku)
* Widget data JSON API (6b8b476c)
* Remote dashboard reloading command (62bd4f90)

### Changed

* Calls to `broadcast/1` inside a job are rewritten to `Kitto.Notifier.broadcast/2`
* Installer checks for app name validity
* The graph type of the graph widget is now configurable (9eeaf5ff)

## [0.2.3] - 2016-11-15

### Added

* Kitto :assets_host and :assets_port config settings for the dev asset server
  binding address
* Kitto :ip config setting the server binding ip
* Authentication to POST /widgets/:id, (#11)

### Changed

* Scaffolded version of d3 is 3.5.17 gcc, python no longer required for
  `npm install` (acbda885)

## [0.2.2] - 2016-11-11

### Changed

* Fonts are no longer bundled in js but are served independently

### Fixed

* Font assets are now served in development
* Added missing favicon

## [0.2.1] - 2016-11-06

### Changed

* Job error output contains job definition and error locations
* Generated job files have .exs file extension

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
