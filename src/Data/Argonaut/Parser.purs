module Data.Argonaut.Parser (customJsonParser, jsonParser) where

import Data.Argonaut.Core (Json)
import Data.Argonaut.Custom as Custom
import Data.Either (Either(..))
import Data.Function.Uncurried (Fn3, Fn6, runFn3, runFn6)
import Data.Maybe (Maybe, fromJust, isNothing)
import Partial.Unsafe (unsafePartial)

foreign import _customJsonParser :: forall number.
  Fn6
    (String -> Maybe (Custom.CustomNumber number))
    (forall a. Maybe a -> Boolean)
    (forall a. Maybe a -> a)
    (forall a. String -> Either String a)
    (forall a. Json -> Either a Json)
    String
    (Either String (Custom.Json (Custom.CustomNumber number)))
foreign import _jsonParser :: forall a. Fn3 (String -> a) (Json -> a) String a

-- | The first argument should return Nothing to fail, and it will cause the
-- | whole decoder to fail
customJsonParser :: forall number
   . (String -> Maybe (Custom.CustomNumber number))
  -> String
  -> Either String (Custom.Json (Custom.CustomNumber number))
customJsonParser mkNumber undecodedJson =
  runFn6 _customJsonParser mkNumber isNothing (unsafePartial fromJust) Left Right undecodedJson

-- | Parse a JSON string, constructing the `Json` value described by the string.
-- | To convert a string into a `Json` string, see `fromString`.
jsonParser :: String -> Either String Json
jsonParser j = runFn3 _jsonParser Left Right j
