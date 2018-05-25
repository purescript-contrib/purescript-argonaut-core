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
  ) where

import Prelude

import Data.Function.Uncurried (Fn5, runFn5, Fn7, runFn7)
import Data.Maybe (Maybe(..))
import Foreign.Object (Object)
import Foreign.Object as Obj

-- | The type of JSON data. The underlying representation is the same as what
-- | would be returned from JavaScript's `JSON.parse` function; that is,
-- | ordinary JavaScript booleans, strings, arrays, objects, etc.
foreign import data Json :: Type

instance eqJson :: Eq Json where
  eq j1 j2 = compare j1 j2 == EQ

instance ordJson :: Ord Json where
  compare a b = runFn5 _compare EQ GT LT a b

-- | The type of null values inside JSON data. There is exactly one value of
-- | this type: in JavaScript, it is written `null`. This module exports this
-- | value as `jsonNull`.
foreign import data JNull :: Type

instance eqJNull :: Eq JNull where
  eq _ _ = true

instance ordJNull :: Ord JNull where
  compare _ _ = EQ

-- | Case analysis for `Json` values. See the README for more information.
caseJson
  :: forall a
   . (Unit -> a)
  -> (Boolean -> a)
  -> (Number -> a)
  -> (String -> a)
  -> (Array Json -> a)
  -> (Object Json -> a)
  -> Json -> a
caseJson a b c d e f json = runFn7 _caseJson a b c d e f json

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was null, and a default value for all other cases.
caseJsonNull :: forall a. a -> (Unit -> a) -> Json -> a
caseJsonNull d f j = runFn7 _caseJson f (const d) (const d) (const d) (const d) (const d) j

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was a `Boolean`, and a default value for all other cases.
caseJsonBoolean :: forall a. a -> (Boolean -> a) -> Json -> a
caseJsonBoolean d f j = runFn7 _caseJson (const d) f (const d) (const d) (const d) (const d) j

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was a `Number`, and a default value for all other cases.
caseJsonNumber :: forall a. a -> (Number -> a) -> Json -> a
caseJsonNumber d f j = runFn7 _caseJson (const d) (const d) f (const d) (const d) (const d) j

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was a `String`, and a default value for all other cases.
caseJsonString :: forall a. a -> (String -> a) -> Json -> a
caseJsonString d f j = runFn7 _caseJson (const d) (const d) (const d) f (const d) (const d) j

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was a `Array Json`, and a default value for all other cases.
caseJsonArray :: forall a. a -> (Array Json -> a) -> Json -> a
caseJsonArray d f j = runFn7 _caseJson (const d) (const d) (const d) (const d) f (const d) j

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was an `Object`, and a default value for all other cases.
caseJsonObject :: forall a. a -> (Object Json -> a) -> Json -> a
caseJsonObject d f j = runFn7 _caseJson (const d) (const d) (const d) (const d) (const d) f j

verbJsonType :: forall a b. b -> (a -> b) -> (b -> (a -> b) -> Json -> b) -> Json -> b
verbJsonType def f g = g def f

-- Tests
isJsonType :: forall a. (Boolean -> (a -> Boolean) -> Json -> Boolean) -> Json -> Boolean
isJsonType = verbJsonType false (const true)

isNull :: Json -> Boolean
isNull = isJsonType caseJsonNull

isBoolean :: Json -> Boolean
isBoolean = isJsonType caseJsonBoolean

isNumber :: Json -> Boolean
isNumber = isJsonType caseJsonNumber

isString :: Json -> Boolean
isString = isJsonType caseJsonString

isArray :: Json -> Boolean
isArray = isJsonType caseJsonArray

isObject :: Json -> Boolean
isObject = isJsonType caseJsonObject

-- Decoding

toJsonType
  :: forall a
   . (Maybe a -> (a -> Maybe a) -> Json -> Maybe a)
  -> Json
  -> Maybe a
toJsonType = verbJsonType Nothing Just

toNull :: Json -> Maybe Unit
toNull = toJsonType caseJsonNull

toBoolean :: Json -> Maybe Boolean
toBoolean = toJsonType caseJsonBoolean

toNumber :: Json -> Maybe Number
toNumber = toJsonType caseJsonNumber

toString :: Json -> Maybe String
toString = toJsonType caseJsonString

toArray :: Json -> Maybe (Array Json)
toArray = toJsonType caseJsonArray

toObject :: Json -> Maybe (Object Json)
toObject = toJsonType caseJsonObject

-- Encoding

foreign import fromBoolean :: Boolean -> Json
foreign import fromNumber :: Number -> Json
foreign import fromString :: String -> Json
foreign import fromArray :: Array Json -> Json
foreign import fromObject :: Object Json -> Json

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
jsonEmptyObject = fromObject Obj.empty

jsonSingletonArray :: Json -> Json
jsonSingletonArray j = fromArray [j]

jsonSingletonObject :: String -> Json -> Json
jsonSingletonObject key val = fromObject (Obj.singleton key val)

foreign import stringify :: Json -> String

foreign import _caseJson
  :: forall z
   . Fn7
      (Unit -> z)
      (Boolean -> z)
      (Number -> z)
      (String -> z)
      (Array Json -> z)
      (Object Json -> z)
      Json
      z

foreign import _compare :: Fn5 Ordering Ordering Ordering Json Json Ordering
