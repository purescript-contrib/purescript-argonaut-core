-- | This module defines a data type and various functions for creating and
-- | manipulating JSON values. The README contains additional documentation
-- | for this module.
module Data.Argonaut.Core
  ( Json
  , caseJson
  , caseJsonNull
  , caseJsonBoolean
  , caseJsonNumber
  , caseJsonString
  , caseJsonArray
  , caseJsonObject
  , isNull
  , isBoolean
  , isNumber
  , isString
  , isArray
  , isObject
  , fromBoolean
  , fromNumber
  , fromString
  , fromArray
  , fromObject
  , toNull
  , toBoolean
  , toNumber
  , toString
  , toArray
  , toObject
  , jsonNull
  , jsonTrue
  , jsonFalse
  , jsonZero
  , jsonEmptyString
  , jsonEmptyArray
  , jsonSingletonArray
  , jsonEmptyObject
  , jsonSingletonObject
  , stringify
  , stringifyWithIndent
  ) where

import Prelude

import Data.Maybe (Maybe)
import Foreign.Object (Object)
import Data.Argonaut.Custom as Custom

-- | The type of JSON data. The underlying representation is the same as what
-- | would be returned from JavaScript's `JSON.parse` function; that is,
-- | ordinary JavaScript booleans, strings, arrays, objects, etc.
type Json = Custom.Json Number

-- | Case analysis for `Json` values. See the README for more information.
caseJson
  :: forall a
   . (Unit -> a)
  -> (Boolean -> a)
  -> (Number -> a)
  -> (String -> a)
  -> (Array Json -> a)
  -> (Object Json -> a)
  -> Json
  -> a
caseJson = Custom.caseJson

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was null, and a default value for all other cases.
caseJsonNull :: forall a. a -> (Unit -> a) -> Json -> a
caseJsonNull = Custom.caseJsonNull

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was a `Boolean`, and a default value for all other cases.
caseJsonBoolean :: forall a. a -> (Boolean -> a) -> Json -> a
caseJsonBoolean = Custom.caseJsonBoolean

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was a `Number`, and a default value for all other cases.
caseJsonNumber :: forall a. a -> (Number -> a) -> Json -> a
caseJsonNumber = Custom.caseJsonNumber

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was a `String`, and a default value for all other cases.
caseJsonString :: forall a. a -> (String -> a) -> Json -> a
caseJsonString = Custom.caseJsonString

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was a `Array Json`, and a default value for all other cases.
caseJsonArray :: forall a. a -> (Array Json -> a) -> Json -> a
caseJsonArray = Custom.caseJsonArray

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was an `Object`, and a default value for all other cases.
caseJsonObject :: forall a. a -> (Object Json -> a) -> Json -> a
caseJsonObject = Custom.caseJsonObject

-- Tests

-- | Check if the provided `Json` is the `null` value
isNull :: Json -> Boolean
isNull = Custom.isNull

-- | Check if the provided `Json` is a `Boolean`
isBoolean :: Json -> Boolean
isBoolean = Custom.isBoolean

-- | Check if the provided `Json` is a `Number`
isNumber :: Json -> Boolean
isNumber = Custom.isNumber

-- | Check if the provided `Json` is a `String`
isString :: Json -> Boolean
isString = Custom.isString

-- | Check if the provided `Json` is an `Array`
isArray :: Json -> Boolean
isArray = Custom.isArray

-- | Check if the provided `Json` is an `Object`
isObject :: Json -> Boolean
isObject = Custom.isObject

-- Decoding

-- | Convert `Json` to the `Unit` value if the `Json` is the null value
toNull :: Json -> Maybe Unit
toNull = Custom.toNull

-- | Convert `Json` to a `Boolean` value, if the `Json` is a boolean.
toBoolean :: Json -> Maybe Boolean
toBoolean = Custom.toBoolean

-- | Convert `Json` to a `Number` value, if the `Json` is a number.
toNumber :: Json -> Maybe Number
toNumber = Custom.toNumber

-- | Convert `Json` to a `String` value, if the `Json` is a string. To write a
-- | `Json` value to a JSON string, see `stringify`.
toString :: Json -> Maybe String
toString = Custom.toString

-- | Convert `Json` to an `Array` of `Json` values, if the `Json` is an array.
toArray :: Json -> Maybe (Array Json)
toArray = Custom.toArray

-- | Convert `Json` to an `Object` of `Json` values, if the `Json` is an object.
toObject :: Json -> Maybe (Object Json)
toObject = Custom.toObject

-- Encoding

-- | Construct `Json` from a `Boolean` value
fromBoolean :: Boolean -> Json
fromBoolean = Custom.fromBoolean

-- | Construct `Json` from a `Number` value
fromNumber :: Number -> Json
fromNumber = Custom.fromNumber

-- | Construct the `Json` representation of a `String` value.
-- | Note that this function only produces `Json` containing a single piece of `String`
-- | data (similar to `fromBoolean`, `fromNumber`, etc.).
-- | This function does NOT convert the `String` encoding of a JSON value to `Json` - For that
-- | purpose, you'll need to use `jsonParser`.
fromString :: String -> Json
fromString = Custom.fromString

-- | Construct `Json` from an array of `Json` values
fromArray :: Array Json -> Json
fromArray = Custom.fromArray

-- | Construct `Json` from an object with `Json` values
fromObject :: Object Json -> Json
fromObject = Custom.fromObject

-- Defaults

-- | The JSON null value represented as `Json`
jsonNull :: Json
jsonNull = Custom.jsonNull

-- | The true boolean value represented as `Json`
jsonTrue :: Json
jsonTrue = Custom.jsonTrue

-- | The false boolean value represented as `Json`
jsonFalse :: Json
jsonFalse = Custom.jsonFalse

-- | The number zero represented as `Json`
jsonZero :: Json
jsonZero = Custom.fromNumber 0.0

-- | An empty string represented as `Json`
jsonEmptyString :: Json
jsonEmptyString = Custom.jsonEmptyString

-- | An empty array represented as `Json`
jsonEmptyArray :: Json
jsonEmptyArray = Custom.jsonEmptyArray

-- | An empty object represented as `Json`
jsonEmptyObject :: Json
jsonEmptyObject = Custom.jsonEmptyObject

-- | Constructs a `Json` array value containing only the provided value
jsonSingletonArray :: Json -> Json
jsonSingletonArray = Custom.jsonSingletonArray

-- | Constructs a `Json` object value containing only the provided key and value
jsonSingletonObject :: String -> Json -> Json
jsonSingletonObject = Custom.jsonSingletonObject

-- | Converts a `Json` value to a JSON string. To retrieve a string from a `Json`
-- | string value, see `fromString`.
foreign import stringify :: Json -> String

-- | Converts a `Json` value to a JSON string.
-- | The first `Int` argument specifies the amount of white space characters to use as indentation.
-- | This number is capped at 10 (if it is greater, the value is just 10). Values less than 1 indicate that no space should be used.
foreign import stringifyWithIndent :: Int -> Json -> String
