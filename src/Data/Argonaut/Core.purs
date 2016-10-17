-- | This module defines a data type and various functions for creating and
-- | manipulating JSON values. The README contains additional documentation
-- | for this module.
module Data.Argonaut.Core
  ( Json(..)
  , JNull(..)
  , JBoolean(..)
  , JNumber(..)
  , JString(..)
  , JAssoc(..)
  , JArray(..)
  , JObject(..)
  , foldJson
  , foldJsonNull
  , foldJsonBoolean
  , foldJsonNumber
  , foldJsonString
  , foldJsonArray
  , foldJsonObject
  , isNull
  , isBoolean
  , isNumber
  , isString
  , isArray
  , isObject
  , fromNull
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
  , jsonFalse
  , jsonTrue
  , jsonZero
  , jsonEmptyArray
  , jsonSingletonArray
  , jsonEmptyObject
  , jsonSingletonObject
  , stringify
  ) where

import Prelude

import Data.Tuple (Tuple)
import Data.Maybe (Maybe(..))
import Data.Function.Uncurried (Fn5, runFn5, Fn7, runFn7)

import Data.StrMap as M

-- | A Boolean value inside some JSON data. Note that this type is exactly the
-- | same as the primitive `Boolean` type; this synonym acts only to help
-- | indicate intent.
type JBoolean = Boolean

-- | A Number value inside some JSON data. Note that this type is exactly the
-- | same as the primitive `Number` type; this synonym acts only to help
-- | indicate intent.
type JNumber = Number

-- | A String value inside some JSON data. Note that this type is exactly the
-- | same as the primitive `String` type; this synonym acts only to help
-- | indicate intent.
type JString = String

-- | A JSON array; an array containing `Json` values.
type JArray = Array Json

-- | A JSON object; a JavaScript object containing `Json` values.
type JObject = M.StrMap Json

type JAssoc = Tuple String Json

-- | The type of null values inside JSON data. There is exactly one value of
-- | this type: in JavaScript, it is written `null`. This module exports this
-- | value as `jsonNull`.
foreign import data JNull :: *

-- | The type of JSON data. The underlying representation is the same as what
-- | would be returned from JavaScript's `JSON.stringify` function; that is,
-- | ordinary JavaScript booleans, strings, arrays, objects, etc.
foreign import data Json :: *

-- | Case analysis for `Json` values. See the README for more information.
foldJson
  :: forall a
   . (JNull -> a)
  -> (JBoolean -> a)
  -> (JNumber -> a)
  -> (JString -> a)
  -> (JArray -> a)
  -> (JObject -> a)
  -> Json -> a
foldJson a b c d e f json = runFn7 _foldJson a b c d e f json

-- | A simpler version of `foldJson` which accepts a callback for when the
-- | `Json` argument was null, and a default value for all other cases.
foldJsonNull :: forall a. a -> (JNull -> a) -> Json -> a
foldJsonNull d f j = runFn7 _foldJson f (const d) (const d) (const d) (const d) (const d) j

-- | A simpler version of `foldJson` which accepts a callback for when the
-- | `Json` argument was a `Boolean`, and a default value for all other cases.
foldJsonBoolean :: forall a. a -> (JBoolean -> a) -> Json -> a
foldJsonBoolean d f j = runFn7 _foldJson (const d) f (const d) (const d) (const d) (const d) j

-- | A simpler version of `foldJson` which accepts a callback for when the
-- | `Json` argument was a `Number`, and a default value for all other cases.
foldJsonNumber :: forall a. a -> (JNumber -> a) -> Json -> a
foldJsonNumber d f j = runFn7 _foldJson (const d) (const d) f (const d) (const d) (const d) j

-- | A simpler version of `foldJson` which accepts a callback for when the
-- | `Json` argument was a `String`, and a default value for all other cases.
foldJsonString :: forall a. a -> (JString -> a) -> Json -> a
foldJsonString d f j = runFn7 _foldJson (const d) (const d) (const d) f (const d) (const d) j

-- | A simpler version of `foldJson` which accepts a callback for when the
-- | `Json` argument was a `JArray`, and a default value for all other cases.
foldJsonArray :: forall a. a -> (JArray -> a) -> Json -> a
foldJsonArray d f j = runFn7 _foldJson (const d) (const d) (const d) (const d) f (const d) j

-- | A simpler version of `foldJson` which accepts a callback for when the
-- | `Json` argument was a `JObject`, and a default value for all other cases.
foldJsonObject :: forall a. a -> (JObject -> a) -> Json -> a
foldJsonObject d f j = runFn7 _foldJson (const d) (const d) (const d) (const d) (const d) f j

verbJsonType :: forall a b. b -> (a -> b) -> (b -> (a -> b) -> Json -> b) -> Json -> b
verbJsonType def f fold = fold def f


-- Tests
isJsonType :: forall a. (Boolean -> (a -> Boolean) -> Json -> Boolean) ->
              Json -> Boolean
isJsonType = verbJsonType false (const true)

isNull :: Json -> Boolean
isNull = isJsonType foldJsonNull

isBoolean :: Json -> Boolean
isBoolean = isJsonType foldJsonBoolean

isNumber :: Json -> Boolean
isNumber = isJsonType foldJsonNumber

isString :: Json -> Boolean
isString = isJsonType foldJsonString

isArray :: Json -> Boolean
isArray = isJsonType foldJsonArray

isObject :: Json -> Boolean
isObject = isJsonType foldJsonObject

-- Decoding

toJsonType
  :: forall a
   . (Maybe a -> (a -> Maybe a) -> Json -> Maybe a)
  -> Json
  -> Maybe a
toJsonType = verbJsonType Nothing Just

toNull :: Json -> Maybe JNull
toNull = toJsonType foldJsonNull

toBoolean :: Json -> Maybe JBoolean
toBoolean = toJsonType foldJsonBoolean

toNumber :: Json -> Maybe JNumber
toNumber = toJsonType foldJsonNumber

toString :: Json -> Maybe JString
toString = toJsonType foldJsonString

toArray :: Json -> Maybe JArray
toArray = toJsonType foldJsonArray

toObject :: Json -> Maybe JObject
toObject = toJsonType foldJsonObject

-- Encoding

foreign import fromNull :: JNull -> Json
foreign import fromBoolean  :: JBoolean -> Json
foreign import fromNumber :: JNumber -> Json
foreign import fromString  :: JString -> Json
foreign import fromArray :: JArray -> Json
foreign import fromObject  :: JObject -> Json

-- Defaults

foreign import jsonNull :: Json

jsonTrue :: Json
jsonTrue = fromBoolean true

jsonFalse :: Json
jsonFalse = fromBoolean false

jsonZero :: Json
jsonZero = fromNumber 0.0

jsonEmptyString :: Json
jsonEmptyString = fromString ""

jsonEmptyArray :: Json
jsonEmptyArray = fromArray []

jsonEmptyObject :: Json
jsonEmptyObject = fromObject M.empty

jsonSingletonArray :: Json -> Json
jsonSingletonArray j = fromArray [j]

jsonSingletonObject :: String -> Json -> Json
jsonSingletonObject key val = fromObject $ M.singleton key val

-- Instances

instance eqJNull :: Eq JNull where
  eq _ _ = true

instance ordJNull :: Ord JNull where
  compare _ _ = EQ

instance showJNull :: Show JNull where
  show _ = "null"

instance eqJson :: Eq Json where
  eq j1 j2 = compare j1 j2 == EQ

instance ordJson :: Ord Json where
  compare a b = runFn5 _compare EQ GT LT a b

instance showJson :: Show Json where
  show = stringify

foreign import stringify :: Json -> String

foreign import _foldJson
  :: forall z
   . Fn7
      (JNull -> z)
      (JBoolean -> z)
      (JNumber -> z)
      (JString -> z)
      (JArray -> z)
      (JObject -> z)
      Json
      z

foreign import _compare :: Fn5 Ordering Ordering Ordering Json Json Ordering
