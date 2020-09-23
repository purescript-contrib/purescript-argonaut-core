# Changelog

Notable changes to this project are documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Breaking changes (😱!!!):

New features:

Bugfixes:

Other improvements:

## [v5.1.0](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v5.1.0) - 2020-09-09

* Adds `stringifyWithIndent` function to enable pretty-printing JSON.

## [v5.0.2](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v5.0.2) - 2020-03-05

Adds documentation comments to public functions (@thomashoneyman)

## [v5.0.1](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v5.0.1) - 2019-09-03

* Fix `purs bundle` issue caused by `objToString` and `objKeys` functions in the FFI file (@joneshf)
* Update tests for compatibility with PureScript 0.13 (@joneshf)

## [v5.0.0](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v5.0.0) - 2019-03-04

Updated dependencies

## [v4.0.1](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v4.0.1) - 2018-06-23

- Adds metadata including contributor guidelines
- Pushes latest release to Pursuit

## [v4.0.0](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v4.0.0) - 2018-05-25

Updates for 0.12

**Breaking changes:**

- Removed the J* aliases like JArray
- `foldJson`, `fold*` functions are now called `caseJson`, `case*`

## [v3.1.1](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v3.1.1) - 2018-01-24

- Reduced size in `genJson` to prevent excessively large structures being built up

## [v3.1.0](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v3.1.0) - 2017-04-08

- Added `JNull` value export

## [v3.0.0](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v3.0.0) - 2017-04-07

- Updated for PureScript 0.11

## [v2.0.1](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v2.0.1) - 2016-10-27

- Workaround for bug in DCE in `psc-bundle` #14 (@menelaos)

## [v2.0.0](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v2.0.0) - 2016-10-17

- Updated dependencies

## [v1.1.0](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v1.1.0) - 2016-08-09

- `stringify` is now exported explicitly, to be used to better express intent than the current `show` (@charleso)

## [v1.0.0](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v1.0.0) - 2016-06-06

Updates for 1.0 core libraries.

## [v0.2.3](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v0.2.3) - 2015-12-15

- Functionally equivalent to v0.2.2, this release improves the documentation for Pursuit

## [v0.2.2](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v0.2.2) - 2015-11-20

- Removed unused import

## [v0.2.1](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v0.2.1) - 2015-10-29


## [v0.2.0](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v0.2.0) - 2015-08-19

- Updated dependencies for PureScript 0.7.3 (@zudov)

## [v0.1.0](https://github.com/purescript-contrib/purescript-argonaut-core/releases/tag/v0.1.0) - 2015-07-11

- Initial release
