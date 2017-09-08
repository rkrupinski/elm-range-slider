const { resolve } = require('path');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: resolve(__dirname, 'src', 'app.js'),

  output: {
    path: resolve(__dirname, 'build'),
    filename: '[name].js',
    publicPath: '/',
  },

  resolve: {
    extensions: [
      '.js',
      '.elm',
    ],
    modules: [
      resolve(__dirname, 'src'),
      resolve(__dirname, 'elm'),
      'node_modules',
    ],
  },

  module: {
    loaders: [
      {
        test: /\.elm$/,
        exclude: [
          /elm-stuff/,
          /node_modules/,
          /Stylesheets\.elm$/,
        ],
        use: [
          'elm-hot-loader',
          'elm-webpack-loader',
        ],
      },
      {
        test: /Stylesheets\.elm$/,
        use: [
          'style-loader',
          'css-loader',
          'elm-css-webpack-loader',
        ],
      },
    ],
  },

  devServer: {
    contentBase: resolve(__dirname, 'build'),
    hot: true,
    open: true,
    inline: true,
    publicPath: '/',
  },

  plugins: [
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NamedModulesPlugin(),
    new HtmlWebpackPlugin({
      title: 'elm-range-slider demo',
    }),
  ],

  devtool: 'cheap-module-eval-source-map',
};
