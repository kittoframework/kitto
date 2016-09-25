const glob = require('glob');
const path = require('path');
const merge = require('webpack-merge');
const webpack = require('webpack');

const TARGET = process.env.npm_lifecycle_event;
const PATHS = {
  app: path.join(__dirname, 'assets/javascripts/application.js'),
  widgets: glob.sync('./widgets/**/*.js'),
  build: path.join(__dirname, 'public/assets'),
  gridster: path.join(__dirname, 'node_modules/gridster/dist'),
  d3: path.join(__dirname, 'node_modules/d3/d3.min.js'),
  rickshaw: path.join(__dirname, 'node_modules/rickshaw/rickshaw.js')
};

process.env.BABEL_ENV = TARGET;

const common = {
  entry: {
    application: PATHS.app,
    widgets: PATHS.widgets
  },
  resolve: {
    extensions: ['', '.js', '.jsx', 'css', 'scss'],
    modulesDirectories: ['node_modules', PATHS.gridster],
    alias: {
      d3: PATHS.d3
    }
  },
  output: {
    path: PATHS.build,
    publicPath: '/assets/',
    filename: '[name].js'
  },
  module: {
    loaders: [
      { test: /\.css$/, loaders: ['style', 'css'] },
      { test: /\.scss$/, loaders: ['style', 'css', 'sass'] },
      { test: /\.jsx?$/, loaders: ['babel?cacheDirectory'] },
      {
        test: /\.(eot|woff|woff2|ttf|svg|png|jpe?g|gif)(\?\S*)?$/,
        loader: 'url?limit=100000&name=[name].[ext]'
      },
      {
        test: require.resolve('jquery-knob'),
        loader: "imports?require=>false,define=>false,this=>window"
      },
      {
        test: PATHS.d3,
        loader: "script"
      },
      {
        test: require.resolve('rickshaw'),
        loader: "script"
      }
    ]
  }
};

if(TARGET === 'start' || !TARGET) {
  module.exports = merge(common, {
    devtool: 'eval-source-map',
    devServer: {
      contentBase: PATHS.build,

      historyApiFallback: true,
      hot: true,
      inline: true,
      progress: true,

      // display only errors to reduce the amount of output
      stats: 'errors-only',

      // parse host and port from env so this is easy
      // to customize
      host: process.env.HOST,
      port: process.env.PORT
    },
    plugins: [new webpack.HotModuleReplacementPlugin()]
  });
}

if(TARGET === 'build') {
  var CompressionPlugin = require("compression-webpack-plugin");

  module.exports = merge(common, {
    plugins: [
      new webpack.optimize.UglifyJsPlugin({
        compress: {
          warnings: false,
          keep_fnames: true
        },
        mangle: {
         keep_fnames: true
        }
      }),
      new CompressionPlugin({
        asset: '[path].gz[query]',
        algorithm: 'gzip',
        test: /\.js$|\.html$/,
        verbose: true
      })
    ]
  });
}
