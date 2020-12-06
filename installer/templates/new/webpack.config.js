const glob = require('glob');
const path = require('path');
const merge = require('webpack-merge');
const webpack = require('webpack');

const TARGET = process.env.npm_lifecycle_event;
const PATHS = {
  app: path.join(__dirname, 'assets/javascripts/application.js'),
  widgets: glob.sync('./widgets/**/*.js'),
  build: path.join(__dirname, 'priv/static'),
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
    extensions: ['.js', '.jsx', 'css', 'scss'],
    modules: [
      'node_modules',
      PATHS.gridster
    ],
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
    rules: [
      {
        test: /\.css$/,
        use: [
          'style-loader',
          'css-loader'
        ]
      },
      {
        test: /\.scss$/,
        use: [
          'style-loader',
          'css-loader',
          'sass-loader'
        ]
      },
      {
        test: /\.jsx?$/,
        use: [
          {
            loader: 'babel-loader',
            options: {
              cacheDirectory: true
            }
          }
        ]
      },
      {
        test: /\.(svg|png|jpe?g|gif)(\?\S*)?$/,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: 'images/[name].[ext]'
            }
          }
        ]
      },
      {
        test: /\.(eot|woff|woff2|ttf)(\?\S*)?$/,
        loader: 'file-loader',
        options: {
          outputPath: 'fonts'
        }
      },
      {
        test: require.resolve('jquery-knob'),
        use: 'imports-loader?require=>false,define=>false,this=>window'
      },
      {
        test: PATHS.d3,
        use: ['script-loader']
      },
      {
        test: require.resolve('rickshaw'),
        use: ['script-loader']
      }
    ]
  }
};

// Development Environment
if (TARGET === 'start' || !TARGET) {
  module.exports = merge(common, {
    devtool: 'eval-source-map',
    devServer: {
      contentBase: PATHS.build,
      headers: { 'Access-Control-Allow-Origin': '*' },
      historyApiFallback: true,
      hot: true,
      inline: true,
      progress: true,
      publicPath: '/assets/',

      // display only errors to reduce the amount of output
      stats: 'errors-only',

      // Binding address of webpack-dev-server
      // Read more: https://github.com/kittoframework/kitto/wiki/Customize-Asset-Watcher
      host: process.env.KITTO_ASSETS_HOST,
      port: process.env.KITTO_ASSETS_PORT
    },
    plugins: [new webpack.HotModuleReplacementPlugin()]
  });
}

// Production Environment
if (TARGET === 'build') {
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
        filename: '[path].gz[query]',
        algorithm: 'gzip',
        test: /\.js$|\.html$/,
        compressionOptions: {
          verbose: true
        }
      })
    ]
  });
}
