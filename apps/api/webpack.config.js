const path = require('path');

module.exports = (env, argv) => {
  const isProduction =
    process.env.NODE_ENV === 'production' || argv.mode === 'production';

  return {
    entry: './src/main.ts',
    target: 'node',
    mode: isProduction ? 'production' : 'development',
    devtool: 'source-map',
    output: {
      path: path.resolve(__dirname, 'dist'),
      filename: 'main.js',
      clean: true,
    },
    resolve: {
      extensions: ['.ts', '.js'],
      alias: {
        '@': path.resolve(__dirname, 'src'),
      },
    },
    module: {
      rules: [
        {
          test: /\.ts$/,
          use: {
            loader: 'ts-loader',
            options: {
              configFile: path.resolve(__dirname, 'tsconfig.app.json'),
            },
          },
          exclude: /node_modules/,
        },
      ],
    },
    externals: {
      '@nestjs/microservices': 'commonjs @nestjs/microservices',
      '@nestjs/websockets': 'commonjs @nestjs/websockets',
      'class-transformer': 'commonjs class-transformer',
      'class-validator': 'commonjs class-validator',
      '@nestjs/websockets/socket-module':
        'commonjs @nestjs/websockets/socket-module',
      '@nestjs/microservices/microservices-module':
        'commonjs @nestjs/microservices/microservices-module',
    },
  };
};
