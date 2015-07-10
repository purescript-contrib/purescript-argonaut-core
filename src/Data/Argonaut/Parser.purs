module Data.Argonaut.Parser (jsonParser) where

import Data.Argonaut.Core (Json())
import Data.Function (Fn3(), runFn3)
import Data.Either (Either(..))

foreign import _jsonParser :: forall a. Fn3 (String -> a) (Json -> a) String a

jsonParser :: String -> Either String Json
jsonParser j = runFn3 _jsonParser Left Right j
