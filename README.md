# purescript-argonaut-core

[![Latest release](http://img.shields.io/github/release/purescript-contrib/purescript-argonaut-core.svg)](https://github.com/purescript-contrib/purescript-argonaut-core/releases)
[![Build Status](https://travis-ci.org/purescript-contrib/purescript-argonaut-core.svg?branch=master)](https://travis-ci.org/purescript-contrib/purescript-argonaut-core)
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

One approach for modelling JSON values would be to define an algebraic data
type, like this:

```purescript
data Json
  = JNull
  | JString String
  | JNumber Number
  | JBoolean Boolean
  | JArray (Array Json)
  | JObject (StrMap Json)
```

And indeed, some might even say this is the obvious approach.

Because Argonaut is written with the compilation target of JavaScript in mind,
it takes a slightly different approach, which is to reuse the existing data
types which JavaScript already provides. This way, the result of JavaScript's
`JSON.parse` function is already a `Json` value, and no extra processing is
needed before you can start operating on it. This ought to help your program
both in terms of speed and memory churn.

Much of the design of Argonaut follows naturally from this design decision.

### Types

The most important type in this library is, of course, `Json`, which is the
type of JSON data in its native JavaScript representation.

As the (hypothetical) algebraic data type declaration above indicates, there
are six possibilities for a JSON value: it can be `null`, a string, a number, a
boolean, an array of JSON values, or an object mapping string keys to JSON
values.

For convenience, and to ensure that values have the appropriate underlying
data representations, Argonaut also declares types for each of these individual
possibilities, whose names correspond to the data constructor names above.

Therefore, `JString`, `JNumber`, and `JBoolean` are synonyms for the primitive
PureScript types `String`, `Number`, and `Boolean` respectively; `JArray` is a
synonym for `Array Json`; and `JObject` is a synonym for `StrMap Json`.
Argonaut defines a type `JNull` as the type of the `null` value in JavaScript.

### Introducing Json values

(Or, where do `Json` values come from?)

If your program is receiving JSON data as a string, you probably want the
`parseJson` function in `Data.Argonaut.Parser`, which is a very simple wrapper
around JavaScript's `JSON.parse`.

Otherwise, `Json` values can be introduced into your program via the FFI or via
the construction functions in `Data.Argonaut.Core`. Here are some examples:

```javascript
// In an FFI module.
exports.someNumber = 23.6;
exports.someBoolean = false;
exports.someObject = {people: [{name: "john"}, {name: "jane"}], common_interests: []};
```

```purescript
foreign import someNumber :: Json
foreign import someBoolean :: Json
foreign import someObject :: Json
```

Generally, if a JavaScript value could be returned from a call to `JSON.parse`,
it's fine to import it from the FFI as `Json`. So, for example, objects,
booleans, numbers, strings, and arrays are all fine, but functions are not.

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
                ]),
                Tuple "common_interests" A.jsonEmptyArray
              ])
```

### Eliminating/matching on `Json` values

We can perform case analysis for `Json` values using the `foldJson` function.
This function is necessary because `Json` is not an algebraic data type. If
`Json` were an algebraic data type, we would not have as much need for this
function, because we could perform pattern matching with a `case ... of`
expression instead.

The type of `foldJson` is:

```purescript
foldJson :: forall a.
            (JNull -> a) -> (JBoolean -> a) -> (JNumber -> a) ->
            (JString -> a) -> (JArray -> a) -> (JObject -> a) ->
            Json -> a
```

That is, `foldJson` takes six functions, which all must return values of some
particular type `a`, together with one `Json` value. `foldJson` itself also
returns a value of the same type `a`.

A use of `foldJson` is very similar to a `case ... of` expression, as it allows
you to handle each of the six possibilities for the `Json` value you passed in.
Thinking of it this way, each of the six function arguments is like one of the
case alternatives. Just like in a `case ... of` expression, the final value
that the whole expression evaluates to comes from evaluating exactly one of the
'alternatives' (functions) that you pass in. In fact, you can tell that this
is the case just by looking at the type signature of `foldJson`, because of a
property called *parametricity* (although a deeper explanation of parametricity
is outside the scope of this tutorial).

For example, imagine we had the following values defined in JavaScript and
imported via the FFI:

```javascript
exports.anotherNumber = 0.0;
exports.anotherArray = [0.0, {foo: 'bar'}, false];
exports.anotherObject = {foo: 1, bar: [2,2]};
```

Then we can match on them in PureScript using `foldJson`:

```purescript
foreign import anotherNumber :: Json
foreign import anotherArray :: Json
foreign import anotherObject :: Json

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
basicInfo anotherNumber -- => "Got a number: 0.0"
basicInfo anotherArray  -- => "Got an array, which had 3 items."
basicInfo anotherObject -- => "Got an object, which had 2 items."
```

`foldJson` is the fundamental function for pattern matching on `Json` values;
any kind of pattern matching you might want to do can be done with `foldJson`.

However, `foldJson` is not always comfortable to use, so Argonaut provides a
few other simpler versions for convenience. For example, the `foldJsonX`
functions can be used to match on a specific type. The first argument acts as a
default value, to be used if the `Json` value turned out not to be that type.
For example, we can write a function which tests whether a JSON value is the
string "lol" like this:

```purescript
foldJsonString :: forall a. a -> (JString -> a) -> Json -> a

isJsonLol = foldJsonString false (_ == "lol")
```

If the `Json` value is not a string, the default `false` is used. Otherwise,
we test whether the string is equal to "lol".

The `toX` functions also occupy a similar role: they attempt to convert `Json`
values into a specific type. If the json value you provide is of the right
type, you'll get a `Just` value. Otherwise, you'll get `Nothing`. For example,
we could have written `isJsonLol` like this, too:

```purescript
toString :: Json -> Maybe JString

isJsonLol json =
  case toString json of
    Just str -> str == "lol"
    Nothing  -> false
```
