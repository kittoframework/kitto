# Kitto

[![Build Status](https://travis-ci.org/kittoframework/kitto.svg?branch=master)](https://travis-ci.org/kittoframework/kitto)
[![Package Version](https://img.shields.io/hexpm/v/kitto.svg)](https://hex.pm/packages/kitto)
[![Coverage](https://s3.amazonaws.com/assets.coveralls.io/badges/coveralls_73.svg)](https://coveralls.io/github/kittoframework/kitto)

Kitto is a framework to help you create dashboards, written in Elixir / React.

It is heavily inspired by [shopify/dashing](http://dashing.io/).


![demo](http://i.imgur.com/c9SloLX.png)

## Demo

+ [Sample Dashboard](http://kitto.io/dashboards/sample)
+ [Elixir Dashboard](http://kitto.io/dashboards/elixir)

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

## Production

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

### Deployment

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

Copyright (c) 2016 Dimitris Zorbas, MIT Licence.
See [LICENSE.txt](https://github.com/kittoframework/kitto/blob/master/LICENSE.txt) for further details.
