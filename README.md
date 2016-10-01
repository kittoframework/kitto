# Kitto

[![Build Status](https://travis-ci.org/kittoframework/kitto.svg?branch=master)](https://travis-ci.org/kittoframework/kitto)
[![Package Version](https://img.shields.io/hexpm/v/kitto.svg)](https://hex.pm/packages/kitto)

Kitto is a framework to help you create dashboards, written in Elixir / React.
It is heavily inspired by [shopify/dashing](http://dashing.io/).

[Demo](http://kitto.io/dashboards/sample)

![demo](http://i.imgur.com/c9SloLX.png)

## Installation

Install the latest archive

```shell
mix archive.install https://github.com/kittoframework/archives/raw/master/kitto_new-0.0.3.ez
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

Start a kitto server

```shell
mix kitto.server
```

Have assets compiled

```shell
npm run start
```

Try the sample dashboard at: [http://localhost:4000/dashboards/sample](http://localhost:4000/dashboards/sample)

## Production

Compile assets for production

```shell
npm run build
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

### About the name

The [road to Erlang / Elixir](https://www.google.gr/maps/place/Erlanger+Rd,+London) starts with [Kitto](https://en.wikipedia.org/wiki/H._D._F._Kitto).

# LICENSE

Copyright (c) 2016 Dimitris Zorbas, MIT Licence.
See [LICENSE.txt](https://github.com/kittoframework/kitto/blob/master/LICENSE.txt) for further details.
