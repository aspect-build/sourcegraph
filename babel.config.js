// @ts-check
const path = require('path')

const semver = require('semver')
const logger = require('signale')

// TODO(bazel): drop when non-bazel removed.
const IS_BAZEL = !!process.env.BAZEL_BINDIR

/** @type {import('@babel/core').ConfigFunction} */
module.exports = api => {
  const isTest = api.env('test')
  api.cache.forever()

  if (process.env.BAZEL_TEST || (IS_BAZEL && isTest)) {
    throw new Error("Don't use babel.config.js for tests under Bazel, use babel.config.jest.js instead")
  }

  /**
   * Whether to instrument files with istanbul for code coverage.
   * This is needed for e2e test coverage.
   */
  const instrument = Boolean(process.env.COVERAGE_INSTRUMENT && JSON.parse(process.env.COVERAGE_INSTRUMENT))
  if (instrument) {
    logger.info('Instrumenting code for coverage tracking')
  }

  return {
    presets: [
      // Can't put this in plugins because it needs to run as the last plugin.
      ...(instrument ? [{ plugins: [['babel-plugin-istanbul', { cwd: path.resolve(__dirname) }]] }] : []),
      [
        '@babel/preset-env',
        {
          // Node (used for testing) doesn't support modules, so compile to CommonJS for testing.
          modules: process.env.BABEL_MODULE ?? (isTest ? 'commonjs' : false),
          bugfixes: true,
          useBuiltIns: 'entry',
          include: [
            // Polyfill URL because Chrome and Firefox are not spec-compliant
            // Hostnames of URIs with custom schemes (e.g. git) are not parsed out
            'web.url',
            // URLSearchParams.prototype.keys() is not iterable in Firefox
            'web.url-search-params',
            // Commonly needed by extensions (used by vscode-jsonrpc)
            'web.immediate',
            // Always define Symbol.observable before libraries are loaded, ensuring interopability between different libraries.
            'esnext.symbol.observable',
          ],
          // See https://github.com/zloirock/core-js#babelpreset-env
          corejs: semver.minVersion(require('./package.json').dependencies['core-js']),
        },
      ],
      '@babel/preset-typescript',
      [
        '@babel/preset-react',
        {
          runtime: 'automatic',
        },
      ],
    ],
    plugins: [
      ['@babel/plugin-transform-typescript', { isTSX: true }],
      'babel-plugin-lodash',
      [
        'webpack-chunkname',
        {
          /**
           * Autogenerate `webpackChunkName` for dynamic imports.
           *
           * import('./pages/Home') -> import(/* webpackChunkName: 'sg_pages_Home' *\/'./pages/Home')
           */
          getChunkName: (/** @type string */ importPath) => {
            const chunkName = importPath
              .replace(/[./]+/g, '_') // replace "." and "/" with "_".
              .replace(/(^_+)/g, '') // remove all leading "_".

            return `sg_${chunkName}`
          },
        },
      ],
    ],
  }
}
