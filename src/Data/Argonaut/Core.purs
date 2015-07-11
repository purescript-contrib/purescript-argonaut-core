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
  ) where

import Prelude

import Data.Tuple (Tuple(..))
import Data.Maybe (Maybe(..))
import Data.Function

import qualified Data.StrMap as M

type JBoolean = Boolean
type JNumber = Number
type JString = String
type JAssoc = Tuple String Json
type JArray = Array Json
type JObject = M.StrMap Json

foreign import data JNull :: *
foreign import data Json :: *

foldJson :: forall a.
            (JNull -> a) -> (JBoolean -> a) -> (JNumber -> a) ->
            (JString -> a) -> (JArray -> a) -> (JObject -> a) ->
            Json -> a
foldJson a b c d e f json = runFn7 _foldJson a b c d e f json

foldJsonNull :: forall a. a -> (JNull -> a) -> Json -> a
foldJsonNull d f j = runFn7 _foldJson f (const d) (const d) (const d) (const d) (const d) j

foldJsonBoolean :: forall a. a -> (JBoolean -> a) -> Json -> a
foldJsonBoolean d f j = runFn7 _foldJson (const d) f (const d) (const d) (const d) (const d) j

foldJsonNumber :: forall a. a -> (JNumber -> a) -> Json -> a
foldJsonNumber d f j = runFn7 _foldJson (const d) (const d) f (const d) (const d) (const d) j

foldJsonString :: forall a. a -> (JString -> a) -> Json -> a
foldJsonString d f j = runFn7 _foldJson (const d) (const d) (const d) f (const d) (const d) j

foldJsonArray :: forall a. a -> (JArray -> a) -> Json -> a
foldJsonArray d f j = runFn7 _foldJson (const d) (const d) (const d) (const d) f (const d) j

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

toJsonType :: forall a b. (Maybe a -> (a -> Maybe a) -> Json -> Maybe a) ->
              Json -> Maybe a
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
  eq j1 j2 = (compare j1 j2) == EQ

instance ordJson :: Ord Json where
  compare a b = runFn5 _compare EQ GT LT a b

instance showJson :: Show Json where
  show = _stringify 

-- Foreigns

foreign import _stringify :: Json -> String
foreign import _foldJson :: forall z. Fn7 (JNull -> z) (JBoolean -> z)
                            (JNumber -> z) (JString -> z) (JArray -> z)
                            (JObject -> z) Json z
foreign import _compare :: Fn5 Ordering Ordering Ordering Json Json Ordering
