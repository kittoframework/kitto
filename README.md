# Kitto

Kitto is a framework to help you create dashboards, written in Elixir / React.
It is heavily inspired by [shopify/dashing](http://dashing.io/).

[Demo](http://kitto.io/dashboards/sample)

![demo](http://i.imgur.com/c9SloLX.png)

## Installation

Install the latest archive

```shell
mix archive.install https://github.com/kittoframework/archives/raw/master/kitto_new-0.0.1.ez
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

### About the name

The [road to Erlang / Elixir](https://www.google.gr/maps/place/Erlanger+Rd,+London) starts with [Kitto](https://en.wikipedia.org/wiki/H._D._F._Kitto).

# LICENSE

Copyright (c) 2016 Dimitris Zorbas, MIT Licence.
See [LICENSE.txt](https://github.com/kittoframework/kitto/blob/master/LICENSE.txt) for further details.
