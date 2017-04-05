module Test.StrongCheck.Data.Argonaut where

import Prelude

import Control.Lazy (class Lazy, defer)
import Control.Monad.Gen (class MonadGen)
import Control.Monad.Gen as Gen
import Control.Monad.Rec.Class (class MonadRec)

import Data.Argonaut.Core as J
import Data.Array as A
import Data.Char as C
import Data.NonEmpty ((:|))
import Data.String as S
import Data.StrMap as SM

genJson :: forall m. MonadGen m => MonadRec m => Lazy (m J.Json) => m J.Json
genJson = Gen.sized genJson'
  where
  genJson' :: Int -> m J.Json
  genJson' size
    | size > 3 =
        genJson' 3
    | size > 0 =
        Gen.resize (_ - 1) (Gen.choose genJArray genJObject)
    | otherwise =
        Gen.oneOf $ pure J.jsonNull :| [ genJBoolean, genJNumber, genJString]

  genJArray :: m J.Json
  genJArray = J.fromArray <$> Gen.unfoldable (defer \_ -> genJson)

  genJObject :: m J.Json
  genJObject = A.foldM extendJObj J.jsonEmptyObject =<< Gen.unfoldable genString

  extendJObj :: J.Json -> String -> m J.Json
  extendJObj obj k = do
    v <- genJson
    pure $
      J.foldJsonObject
        (J.jsonSingletonObject k v)
        (J.fromObject <<< SM.insert k v)
        obj

  genJBoolean :: m J.Json
  genJBoolean = J.fromBoolean <$> Gen.chooseBool

  genJNumber :: m J.Json
  genJNumber = J.fromNumber <$> Gen.chooseFloat (-1000000.0) 1000000.0

  genJString :: m J.Json
  genJString = J.fromString <$> genString

  genString :: m String
  genString = S.fromCharArray <$> Gen.unfoldable genChar

  genChar :: m Char
  genChar = C.fromCharCode <$> Gen.chooseInt 0 65535
