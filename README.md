![kitto-logo](http://i.imgur.com/GE38c22.png)

---------------------------------------------

[![Build Status](https://travis-ci.org/kittoframework/kitto.svg?branch=master)](https://travis-ci.org/kittoframework/kitto)
[![Package Version](https://img.shields.io/hexpm/v/kitto.svg)](https://hex.pm/packages/kitto)
[![Coverage](https://coveralls.io/repos/github/kittoframework/kitto/badge.svg?branch=master)](https://coveralls.io/github/kittoframework/kitto)
[![Inline docs](http://inch-ci.org/github/kittoframework/kitto.svg)](http://inch-ci.org/github/kittoframework/kitto)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/kittoframework/kitto.svg)](https://beta.hexfaktor.org/github/kittoframework/kitto)
[![Chat on Gitter](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/kittoframework/Lobby)

Kitto is a framework to help you create dashboards, written in [Elixir][elixir] / [React][react].

## Demo

![demo](http://i.imgur.com/YgZibXU.png)

+ [Sample Dashboard](https://kitto.io/dashboards/sample)
+ [Elixir Dashboard](https://kitto.io/dashboards/elixir)
+ [Jobs Dashboard](https://kitto.io/dashboards/jobs)
+ [1080 Dashboard](https://kitto.io/dashboards/sample1080) (optimized for 1080 screens)

The source for the demo dashboards can be found at: [kittoframework/demo](https://github.com/kittoframework/demo).

To start creating your own, read [below](https://github.com/kittoframework/kitto#create-a-dashboard).

## Features

* Jobs are supervised processes running concurrently
* Widgets are coded in the popular [React][react] library
* Uses a modern asset tool-chain, [Webpack][webpack]
* Allows streaming SSE to numerous clients concurrently with low
  memory/CPU footprint
* Easy to deploy using the provided Docker images, or Heroku
* Can serve assets in production
* Keeps stats about defined jobs and comes with a dashboard to monitor them
* Can apply exponential back-offs to failing jobs
* [Reloads][code-reloading] code upon change in development

## Installation

Install the latest archive

```shell
mix archive.install https://github.com/kittoframework/archives/raw/master/kitto_new-0.4.0.ez
```

## Requirements

* `Elixir`: 1.3
* `Erlang/OTP`: 19

### Assets

* `Node`: 4.3.1
* `npm`: 1.4

It may may anadvertedly work in versions other than the above, but it won't have been
thoroughly tested (see [.travis.yml][.travis.yml] for the defined build matrix).

You may also use the official [Docker image](https://github.com/kittoframework/kitto#using-docker).

Please open an issue to request support for a specific platform.

## Create a dashboard

```shell
mix kitto.new <project_name>
```

## Development

Install dependencies

```shell
mix deps.get && npm install
```

Start a Kitto server (also watches for assets changes)

```shell
mix kitto.server
```

Try the sample dashboard at: [http://localhost:4000/dashboards/sample](http://localhost:4000/dashboards/sample)

For configuration options and troubleshooting be sure to consult the
[wiki][wiki].

## The dashboard grid

Kitto is capable of serving multiple dashboards. Each one of them is
served from a path of the following form `/dashboards/<dashboard_name>`.

A dashboard consists of a [Gridster](http://dsmorse.github.io/gridster.js/) grid containing [React](https://facebook.github.io/react/) widgets.

You will find a sample dashboard under `dashboards/sample`.

The snippet below will place a simple `Text` widget in the dashboard.

```html
<li data-row="1" data-col="1" data-sizex="2" data-sizey="1">
  <div class="widget-welcome"
       data-widget="Text"
       data-source="text"
       data-title="Hello"
       data-text="This is your shiny new dashboard."
       data-moreinfo="Protip: You can drag the widgets around!"></div>
</li>
```

The most important data attributes here are

* `data-widget` Selects the widget to be used. See: [Widgets](https://github.com/kittoframework/kitto#widgets)
* `data-source` Selects the data source to populate the widget. See: [Jobs](https://github.com/kittoframework/kitto#jobs)

The other data attributes are options to be passed as props to the React widget.

## Jobs

By creating a new dashboard using `mix kitto.new <project_name>` you get
a few sample jobs in the directory `jobs/`.

A job file is structured as follows:

```elixir
# File jobs/random.ex
use Kitto.Job.DSL

job :random, every: :second do
  broadcast! :random, %{value: :rand.uniform * 100 |> Float.round}
end
```

The above will spawn a supervised process which will emit a [server-sent
event](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events) with the name `random` every second.

Jobs can also run commands on the server. Data broadcast using commands is in
the form `{exit_code: integer, stdout: String.t}`. For example the following
job will broadcast a `kitto_last_commit` event with the results of the `curl`
statement:

```elixir
job :kitto_last_commit,
    every: {5, :minutes},
    command: "curl https://api.github.com/repos/kittoframework/kitto/commits\?page\=1\&per_page\=1"
```

## Hooks

If, instead of polling for new data from a data source, you want to act on data
as it changes, hooks are a useful feature for implementing webhooks to feed data
to your dashboards.

Hooks are stored in the `hooks/` directory and are structured as follows:

```elixir
# File hooks/github.exs
use Kitto.Hooks.DSL

hook :github do
  {:ok, body, _} = read_body conn
  commits = GitHub.parse_commits_from_hook(body)
  broadcast! :github_commits, %{commits: commits}
end
```

The hook generates a route using the atom in the `hook/2` method. The hook above
will listen at `/hooks/github` on any HTTP method.

## Widgets

Widgets live in `widgets/` are compiled using
[Webpack](https://webpack.github.io/) and are automatically loaded in the dashboards.
Assets are rebuilt upon change in development, but have to be compiled
for production. See `webpack.config.js` for build options.

Example widget (`widgets/text/text.js`)

```javascript
import React from 'react';
import Widget from '../../assets/javascripts/widget';

import './text.scss';

Widget.mount(class Text extends Widget {
  render() {
    return (
      <div className={this.props.className}>
        <h1 className="title">{this.props.title}</h1>
        <h3>{this.state.text || this.props.text}</h3>
        <p className="more-info">{this.props.moreinfo}</p>
      </div>
    );
  }
});
```

Each widget is updated with data from one source specified using the
`data-source` attribute.

## Deployment

Compile the project

```shell
MIX_ENV=prod mix compile
```

Compile assets for production

```shell
npm run build
```

Start the server

```shell
MIX_ENV=prod mix kitto.server
```

#### Using Docker

By scaffolding a new dashboard with:

```shell
mix kitto.new
```

you also get a `Dockerfile`.

Build an image including your code, ready to be deployed.

```shell
docker build . -t my-awesome-dashboard
```

Spawn a container of the image

```shell
docker run -i -p 127.0.0.1:4000:4000 -t my-awesome-dashboard
```
#### Heroku

Please read the detailed [instructions][wiki-heroku] in the wiki.

### Upgrading

Please read the [upgrading guide][upgrading-guide] in the wiki.

### Contributing
#### Run the Tests

```shell
mix test
```

### Support

Have a question?

* See [elixirforum/kitto](https://elixirforum.com/t/kitto-a-framework-for-interactive-dashboards)
* Open an [issue](https://github.com/kittoframework/kitto/issues/new)
* Ask in [gitter.im/kittoframework](https://gitter.im/kittoframework/Lobby)

### Inspiration

It is heavily inspired by [shopify/dashing](http://dashing.io/). :heart:

### About the name

The [road to Erlang / Elixir](https://www.google.gr/maps/place/Erlanger+Rd,+London) starts with [Kitto](https://en.wikipedia.org/wiki/H._D._F._Kitto).

# LICENSE

Copyright (c) 2016 Dimitris Zorbas, MIT License.
See [LICENSE.txt](https://github.com/kittoframework/kitto/blob/master/LICENSE.txt) for further details.

[elixir]: http://elixir-lang.org
[react]: https://facebook.github.io/react/
[webpack]: https://webpack.github.io/
[gridster]: http://dsmorse.github.io/gridster.js/
[wiki]: https://github.com/kittoframework/kitto/wiki
[wiki-heroku]: https://github.com/kittoframework/kitto/wiki/Deploying-to-Heroku
[code-reloading]: https://github.com/kittoframework/kitto/wiki/Code-Reloading
[upgrading-guide]: https://github.com/kittoframework/kitto/wiki/Upgrading-Guide
[.travis.yml]: https://github.com/kittoframework/kitto/blob/master/.travis.yml
