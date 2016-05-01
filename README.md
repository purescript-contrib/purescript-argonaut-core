# purescript-argonaut-core

[![Latest release](http://img.shields.io/bower/v/purescript-argonaut-core.svg)](https://github.com/purescript-contrib/purescript-argonaut-core/releases)
[![Build Status](https://travis-ci.org/purescript-contrib/purescript-argonaut-core.svg?branch=master)](https://travis-ci.org/purescript-contrib/purescript-argonaut-core)
[![Dependency Status](https://www.versioneye.com/user/projects/563a993c1d47d40019000870/badge.svg?style=flat)](https://www.versioneye.com/user/projects/563a993c1d47d40019000870)
[![Maintainer: slamdata](https://img.shields.io/badge/maintainer-slamdata-lightgrey.svg)](http://github.com/slamdata)

Core part of `purescript-argonaut` that contains basic types for `Json`, folds over them, tests, printer and parser.

## Installation

```shell
bower install purescript-argonaut-core
```

## Documentation

Module documentation is [published on Pursuit](http://pursuit.purescript.org/packages/purescript-argonaut-core).

## Tutorial

Some of Argonaut's functions might seem a bit arcane at first, so it can help
to understand the underlying design decisions which make it the way it is.

One approach for modelling JSON values would be to define an ADT, like this:

```purescript
data Json
  = JNull
  | JBoolean Boolean
  | JArray (Array Json)
  | JObject (StrMap Json)
  [...]
```

And indeed, some might even say this is the obvious approach.

Because Argonaut is written with the compilation target of JavaScript in mind,
it takes a slightly different approach, which is to reuse the existing data
types which JavaScript already provides. This way, the result of JavaScript's
`JSON.stringify` function is already a `Json` value, and no extra processing is
needed before you can start operating on it. This ought to help your program
both in terms of speed and memory churn.

Much of the design of Argonaut follows naturally from this design decision.

### Introducing Json values

(Or, where do `Json` values come from?)

Usually, a `Json` value will be introduced into your program via either the FFI
or via the construction functions in `Data.Argonaut.Core`. Here are some
examples:

```javascript
// In an FFI module.
exports.someNumber = 23.6;
exports.someBoolean = false;
exports.someObject = {people: [{name: "john"}, {name: "jane"}], 
```

```purescript
foreign import someNumber :: Json
foreign import someBoolean :: Json
foreign import someObject :: Json
```

Generally, if a JavaScript value could be returned from a call to
`JSON.stringify`, it's fine to import it from the FFI as `Json`. So, for
example, objects, booleans, numbers, strings, and arrays are all fine, but
functions are not.

The construction functions (that is, `fromX`, or `jsonX`) can be used as
follows:

```purescript
import Data.Tuple (Tuple(..))
import Data.StrMap as StrMap
import Data.Argonaut.Core as A

someNumber = A.fromNumber 23.6
someBoolean = A.fromBoolean false
someObject = A.fromObject (StrMap.fromFoldable [
                Tuple "people" (A.fromArray [
                  A.jsonSingletonObject "name" (A.fromString "john"),
                  A.jsonSingletonObject "name" (A.fromString "jane")
                ])
              ])
```

### Eliminating/matching on `Json` values

We can perform case analysis for `Json` values using the `foldJson` function.
This function is necessary because `Json` is not an algebraic data type. If
`Json` were an algebraic data type, we would not have as much need for this
function, because we could perform pattern matching with a `case ... of`
expression instead.

For example, imagine we had the following values defined in JavaScript and
imported via the FFI:

```javascript
exports.someNumber = 0.0;
exports.someArray = [0.0, {foo: 'bar'}, false];
exports.someObject = {foo: 1, bar: [2,2]};
```

Then we can match on them in PureScript using `foldJson`:

```purescript
foreign import someNumber :: Json
foreign import someArray :: Json
foreign import someObject :: Json

basicInfo :: Json -> String
basicInfo = foldJson
  (const "It was null")
  (\b -> "Got a boolean: " <>
            if b then "it was true!" else "It was false.")
  (\x -> "Got a number: " <> show x)
  (\s -> "Got a string, which was " <> Data.String.length s <>
           " characters long.")
  (\xs -> "Got an array, which had " <> Data.Array.length xs <>
           " items.")
  (\obj -> "Got an object, which had " <> Data.StrMap.size obj <>
           " items.")
```

```purescript
basicInfo someNumber -- => "Got a number: 0.0"
basicInfo someArray  -- => "Got an array, which had 3 items."
basicInfo someObject -- => "Got an object, which had 2 items."
```

All the other functions for matching on `Json` values can be expressed in terms
of `foldJson`, but a few others are provided for convenience. For example, the
`foldJsonX` functions can be used to match on a specific type. The first
argument acts as a default value, to be used if the `Json` value turned out not
to be that type. For example, we can write a function which tests whether a
JSON value is the string "lol" like this:

```purescript
isJsonLol = foldJsonString false (_ == "lol")
```

If the `Json` value is not a string, the default `false` is used. Otherwise,
we test whether the string is equal to "lol".

The `toX` functions also occupy a similar role. We could have written
`isJsonLol` like this, too:

```purescript
isJsonLol json =
  case toString json of
    Just str -> str == "lol"
    Nothing  -> false
```
