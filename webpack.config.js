var webpack = require('webpack')

// Examples & Specs
var examples_and_specs = {
  cache: true,
  watch: true,

  entry: {
    'spec': ['mocha!./spec'],

    'commands_example': ['./examples/commands/app.js'],
    'storage_example': ['./examples/storage/app.js'],
  },

  output: {
    filename: '[name].js'
  },

  module: {
    loaders: [
      { test: /\.coffee$/, loader: 'coffee-loader' },
    ]
  },

  resolve: {
    root: __dirname,
    alias: {
      'commandz': 'lib/commandz.coffee'
    }
  },
}

// CommandZ
var commandz = {
  cache: true,

  entry: './lib/commandz.coffee',
  output: {
    filename: 'commandz.min.js',
    library: 'CommandZ',
    libraryTarget: 'umd',
  },

  module: {
    loaders: [
      { test: /\.coffee$/, loader: 'coffee-loader' },
    ]
  },

  plugins: [
    new webpack.optimize.UglifyJsPlugin({
      compressor: { warnings: false }
    })
  ],
}

// Export
module.exports = {
  build: [examples_and_specs],
  dist:  [commandz],
}
