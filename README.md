# Kitto

[![Build Status](https://travis-ci.org/kittoframework/kitto.svg?branch=master)](https://travis-ci.org/kittoframework/kitto)
[![Package Version](https://img.shields.io/hexpm/v/kitto.svg)](https://hex.pm/packages/kitto)
[![Coverage](https://s3.amazonaws.com/assets.coveralls.io/badges/coveralls_73.svg)](https://coveralls.io/github/kittoframework/kitto)

Kitto is a framework to help you create dashboards, written in [Elixir][elixir] / [React][react].

It is heavily inspired by [shopify/dashing](http://dashing.io/).


![demo](http://i.imgur.com/c9SloLX.png)

## Demo

+ [Sample Dashboard](http://kitto.io/dashboards/sample)
+ [Elixir Dashboard](http://kitto.io/dashboards/elixir)
+ [Jobs Dashboard](http://kitto.io/dashboards/jobs)

The source for the demo dashboards can be found at: [kittoframework/demo](https://github.com/kittoframework/demo).

To start creating your own, follow the steps below.

## Installation

Install the latest archive

```shell
mix archive.install https://github.com/kittoframework/archives/raw/master/kitto_new-0.0.5.ez
```

## Create a dashboard

```shell
mix kitto.new <project_name>
```

## Development

Install dependencies

```shell
mix deps.get && npm install
```

Start a kitto server (also watches for assets changes)

```shell
mix kitto.server
```

Try the sample dashboard at: [http://localhost:4000/dashboards/sample](http://localhost:4000/dashboards/sample)

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

* `data-widget` Selects the widget to be used. See: Widgets
* `data-source` Selects the data source to populate the widget. See: Jobs

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

## Widgets

Widgets live in `widgets/` are compiled using
[Webpack](https://webpack.github.io/) and are automatically loaded in the dashboards.
Assets are rebuilt upon change in development, but have to be compiled
for production. See `webpack.config.js` for built options.

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

### Contributing
#### Run the Tests

```shell
mix test
```

### About the name

The [road to Erlang / Elixir](https://www.google.gr/maps/place/Erlanger+Rd,+London) starts with [Kitto](https://en.wikipedia.org/wiki/H._D._F._Kitto).

# LICENSE

Copyright (c) 2016 Dimitris Zorbas, MIT License.
See [LICENSE.txt](https://github.com/kittoframework/kitto/blob/master/LICENSE.txt) for further details.

[elixir]: http://elixir-lang.org
[react]: https://facebook.github.io/react/
[webpack]: https://webpack.github.io/
[gridster]: http://dsmorse.github.io/gridster.js/
