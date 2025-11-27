module Data.Argonaut.Custom
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
  , jsonEmptyString
  , jsonEmptyArray
  , jsonSingletonArray
  , jsonEmptyObject
  , jsonSingletonObject
  , stringify
  , stringifyWithIndent
  , CustomNumber
  , customNumberContent
  , mkCustomNumber
  ) where

import Prelude

import Data.Function.Uncurried (Fn2, Fn6, Fn7, mkFn2, runFn6, runFn7)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Foreign.Object (Object)
import Foreign.Object as Obj

foreign import data CustomNumber :: Type -> Type

instance Eq a => Eq (CustomNumber a) where
  eq cna cnb = customNumberContent cna `eq` customNumberContent cnb

instance Ord a => Ord (CustomNumber a) where
  compare cna cnb = customNumberContent cna `compare` customNumberContent cnb

instance Show a => Show (CustomNumber a) where
  show a = "CustomNumber " <> show (customNumberContent a)

foreign import customNumberContent :: forall number. CustomNumber number -> number
foreign import mkCustomNumber :: forall number. number -> CustomNumber number

-- | The type of JSON data. The underlying representation is the same as what
-- | would be returned from JavaScript's `JSON.parse` function, but numeric
-- | literals are parsed using the function given to customJsonParser.
-- | See the `Core` module for a simpler version with IEEE 754 Numbers.
foreign import data Json :: Type -> Type

instance Ord a => Eq (Json a) where
  eq j1 j2 = compare j1 j2 == EQ

instance Ord a => Ord (Json a) where
  compare a b = runFn6 _compare EQ GT LT a b (mkFn2 compare)

-- | The type of null values inside JSON data. There is exactly one value of
-- | this type: in JavaScript, it is written `null`. This module exports this
-- | value as `jsonNull`.
foreign import data JNull :: Type

instance eqJNull :: Eq JNull where
  eq _ _ = true

instance ordJNull :: Ord JNull where
  compare _ _ = EQ

-- | Case analysis for `Json` values.
caseJson
  :: forall a number
   . (Unit -> a)
  -> (Boolean -> a)
  -> (number -> a)
  -> (String -> a)
  -> (Array (Json number) -> a)
  -> (Object (Json number) -> a)
  -> Json number
  -> a
caseJson a b c d e f json = runFn7 _caseJson a b c d e f json

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was null, and a default value for all other cases.
caseJsonNull :: forall a number. a -> (Unit -> a) -> Json number -> a
caseJsonNull d f j = runFn7 _caseJson f (const d) (const d) (const d) (const d) (const d) j

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was a `Boolean`, and a default value for all other cases.
caseJsonBoolean :: forall a number. a -> (Boolean -> a) -> Json number -> a
caseJsonBoolean d f j = runFn7 _caseJson (const d) f (const d) (const d) (const d) (const d) j

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was a `number`, and a default value for all other cases.
caseJsonNumber :: forall a number. a -> (number -> a) -> Json number -> a
caseJsonNumber d f j = runFn7 _caseJson (const d) (const d) f (const d) (const d) (const d) j

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was a `String`, and a default value for all other cases.
caseJsonString :: forall a number. a -> (String -> a) -> Json number -> a
caseJsonString d f j = runFn7 _caseJson (const d) (const d) (const d) f (const d) (const d) j

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was a `Array Json`, and a default value for all other cases.
caseJsonArray :: forall a number. a -> (Array (Json number) -> a) -> Json number -> a
caseJsonArray d f j = runFn7 _caseJson (const d) (const d) (const d) (const d) f (const d) j

-- | A simpler version of `caseJson` which accepts a callback for when the
-- | `Json` argument was an `Object`, and a default value for all other cases.
caseJsonObject :: forall a number. a -> (Object (Json number) -> a) -> Json number -> a
caseJsonObject d f j = runFn7 _caseJson (const d) (const d) (const d) (const d) (const d) f j

verbJsonType :: forall a b number. b -> (a -> b) -> (b -> (a -> b) -> Json number -> b) -> Json number -> b
verbJsonType def f g = g def f

-- Tests

isJsonType :: forall a number. (Boolean -> (a -> Boolean) -> Json number -> Boolean) -> Json number -> Boolean
isJsonType = verbJsonType false (const true)

-- | Check if the provided `Json` is the `null` value
isNull :: forall number. Json number -> Boolean
isNull = isJsonType caseJsonNull

-- | Check if the provided `Json` is a `Boolean`
isBoolean :: forall number. Json number -> Boolean
isBoolean = isJsonType caseJsonBoolean

-- | Check if the provided `Json` is a `Number`
isNumber :: forall number. Json number -> Boolean
isNumber = isJsonType caseJsonNumber

-- | Check if the provided `Json` is a `String`
isString :: forall number. Json number -> Boolean
isString = isJsonType caseJsonString

-- | Check if the provided `Json` is an `Array`
isArray :: forall number. Json number -> Boolean
isArray = isJsonType caseJsonArray

-- | Check if the provided `Json` is an `Object`
isObject :: forall number. Json number -> Boolean
isObject = isJsonType caseJsonObject

-- Decoding

toJsonType
  :: forall a number
   . (Maybe a -> (a -> Maybe a) -> Json number -> Maybe a)
  -> Json number
  -> Maybe a
toJsonType = verbJsonType Nothing Just

-- | Convert `Json` to the `Unit` value if the `Json` is the null value
toNull :: forall number. Json number -> Maybe Unit
toNull = toJsonType caseJsonNull

-- | Convert `Json` to a `Boolean` value, if the `Json` is a boolean.
toBoolean :: forall number. Json number -> Maybe Boolean
toBoolean = toJsonType caseJsonBoolean

-- | Convert `Json` to a `Number` value, if the `Json` is a number.
toNumber :: forall number. Json number -> Maybe number
toNumber = toJsonType caseJsonNumber

-- | Convert `Json` to a `String` value, if the `Json` is a string. To write a
-- | `Json` value to a JSON string, see `stringify`.
toString :: forall number. Json number -> Maybe String
toString = toJsonType caseJsonString

-- | Convert `Json` to an `Array` of `Json` values, if the `Json` is an array.
toArray :: forall number. Json number -> Maybe (Array (Json number))
toArray = toJsonType caseJsonArray

-- | Convert `Json` to an `Object` of `Json` values, if the `Json` is an object.
toObject :: forall number. Json number -> Maybe (Object (Json number))
toObject = toJsonType caseJsonObject

-- Encoding

-- | Construct `Json` from a `Boolean` value
foreign import fromBoolean :: forall number. Boolean -> Json number

-- | Construct `Json` from a `Number` value
foreign import fromNumber :: forall number. number -> Json number

-- | Construct the `Json` representation of a `String` value. Note that
-- | this function only produces `Json` containing a single piece of
-- | `String` data (similar to `fromBoolean`, `fromNumber`, etc.). This
-- | function does NOT convert the `String` encoding of a JSON value to
-- | `Json` - For that purpose, you'll need to use `jsonParser`.
foreign import fromString :: forall number. String -> Json number

-- | Construct `Json` from an array of `Json` values
foreign import fromArray :: forall number. Array (Json number) -> Json number

-- | Construct `Json` from an object with `Json` values
foreign import fromObject :: forall number. Object (Json number) -> Json number

-- Defaults

-- | The JSON null value represented as `Json`
foreign import jsonNull :: forall number. Json number

-- | The true boolean value represented as `Json`
jsonTrue :: forall number. Json number
jsonTrue = fromBoolean true

-- | The false boolean value represented as `Json`
jsonFalse :: forall number. Json number
jsonFalse = fromBoolean false

-- | An empty string represented as `Json`
jsonEmptyString :: forall number. Json number
jsonEmptyString = fromString ""

-- | An empty array represented as `Json`
jsonEmptyArray :: forall number. Json number
jsonEmptyArray = fromArray []

-- | An empty object represented as `Json`
jsonEmptyObject :: forall number. Json number
jsonEmptyObject = fromObject Obj.empty

-- | Constructs a `Json` array value containing only the provided value
jsonSingletonArray :: forall number. Json number -> Json number
jsonSingletonArray j = fromArray [ j ]

-- | Constructs a `Json` object value containing only the provided key and value
jsonSingletonObject :: forall number. String -> Json number -> Json number
jsonSingletonObject key val = fromObject (Obj.singleton key val)

-- | Converts a `Json` value to a JSON string. To retrieve a string from
-- | a `Json` string value, see `fromString`.
stringify :: forall number
   . (CustomNumber number -> String)
  -> Json (CustomNumber number)
  -> Either String String
stringify = _stringify Left Right

foreign import _stringify :: forall number
   . (forall a b. a -> Either a b)
  -> (forall a b. b -> Either a b)
  -> (CustomNumber number -> String)
  -> Json (CustomNumber number)
  -> Either String String

-- | Converts a `Json` value to a JSON string.
-- | The first argument encodes the custom numeral type. It must return valid JSON.
-- | The second `Int` argument specifies the amount of white space characters to use as indentation.
-- | This number is capped at 10 (if it is greater, the value is just 10). Values less than 1 indicate that no space should be used.
stringifyWithIndent :: forall number
   . (CustomNumber number -> String)
  -> Int
  -> Json (CustomNumber number)
  -> Either String String
stringifyWithIndent = _stringifyWithIndent Left Right

foreign import _stringifyWithIndent :: forall number
   . (forall a b. a -> Either a b)
  -> (forall a b. b -> Either a b)
  -> (CustomNumber number -> String)
  -> Int
  -> Json (CustomNumber number)
  -> Either String String

foreign import _caseJson
  :: forall z number
   . Fn7
       (Unit -> z)
       (Boolean -> z)
       (number -> z)
       (String -> z)
       (Array (Json number) -> z)
       (Object (Json number) -> z)
       (Json number)
       z

foreign import _compare
  :: forall number
   . Fn6 Ordering Ordering Ordering
       (Json number)
       (Json number)
       (Fn2 number number Ordering)
                               Ordering
