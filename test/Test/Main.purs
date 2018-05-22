module Test.Main where

import Prelude

import Control.Monad.Gen as Gen
import Data.Argonaut.Core (Json, caseJson, caseJsonArray, caseJsonBoolean, caseJsonNull, caseJsonNumber, caseJsonObject, caseJsonString, fromArray, fromBoolean, fromNumber, fromObject, fromString, isArray, isBoolean, isNull, isNumber, isObject, isString, jsonNull, stringify, toArray, toBoolean, toNull, toNumber, toObject, toString)
import Data.Argonaut.Gen (genJson)
import Data.Argonaut.Parser (jsonParser)
import Data.Array as A
import Data.Either (isLeft, Either(..))
import Data.Maybe (Maybe(..), fromJust)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Console (log)
import Foreign.Object as Obj
import Partial.Unsafe (unsafePartial)
import Test.QuickCheck (class Testable, Result, quickCheck, quickCheck', (<?>))
import Test.QuickCheck.Gen (Gen)

foreign import thisIsNull :: Json
foreign import thisIsBoolean :: Json
foreign import thisIsNumber :: Json
foreign import thisIsString :: Json
foreign import thisIsArray :: Json
foreign import thisIsObject :: Json

isTest :: Effect Unit
isTest = do
  assert (isNull thisIsNull <?> "Error in null test")
  assert (isBoolean thisIsBoolean <?> "Error in boolean test")
  assert (isNumber thisIsNumber <?> "Error in number test")
  assert (isString thisIsString <?> "Error in string test")
  assert (isArray thisIsArray <?> "Error in array test")
  assert (isObject thisIsObject <?> "Error in object test")

foldTest :: Effect Unit
foldTest = do
  assert (foldFn thisIsNull == "null" <?> "Error in caseJson null")
  assert (foldFn thisIsBoolean == "boolean" <?> "Error in caseJson boolean")
  assert (foldFn thisIsNumber == "number" <?> "Error in caseJson number")
  assert (foldFn thisIsString == "string" <?> "Error in caseJson string")
  assert (foldFn thisIsArray == "array" <?> "Error in caseJson array")
  assert (foldFn thisIsObject == "object" <?> "Error in caseJson object")

foldFn :: Json -> String
foldFn = caseJson
         (const "null")
         (const "boolean")
         (const "number")
         (const "string")
         (const "array")
         (const "object")

cases :: Array Json
cases =
  [ thisIsNull
  , thisIsBoolean
  , thisIsNumber
  , thisIsString
  , thisIsArray
  , thisIsObject
  ]

foldXXX :: Effect Unit
foldXXX = do
  assert ((caseJsonNull "not null" (const "null") <$> cases) ==
          ["null", "not null", "not null", "not null", "not null", "not null"] <?>
          "Error in caseJsonNull")
  assert ((caseJsonBoolean "not boolean" (const "boolean") <$> cases) ==
          ["not boolean", "boolean", "not boolean", "not boolean", "not boolean", "not boolean"] <?>
          "Error in caseJsonBoolean")
  assert ((caseJsonNumber "not number" (const "number") <$> cases) ==
          ["not number", "not number", "number", "not number", "not number", "not number"] <?>
          "Error in caseJsonNumber")

  assert ((caseJsonString "not string" (const "string") <$> cases) ==
          ["not string", "not string", "not string", "string", "not string", "not string"] <?>
          "Error in caseJsonString")

  assert ((caseJsonArray "not array" (const "array") <$> cases) ==
          ["not array", "not array", "not array", "not array", "array", "not array"] <?>
          "Error in caseJsonArray")
  assert ((caseJsonObject "not object" (const "object") <$> cases) ==
          ["not object", "not object", "not object", "not object", "not object", "object"] <?>
          "Error in caseJsonObject")


fromTest :: Effect Unit
fromTest = do
  assert ((caseJsonNull false (const true) jsonNull) <?> "Error in fromNull")
  quickCheck (\bool -> caseJsonBoolean Nothing Just (fromBoolean bool) == Just bool <?> "Error in fromBoolean")
  quickCheck (\num -> caseJsonNumber Nothing Just (fromNumber num) == Just num <?> "Error in fromNumber")
  quickCheck (\str -> caseJsonString Nothing Just (fromString str) == Just str <?> "Error in fromString")
  quickCheck (\num ->
               let arr :: Array Json
                   arr = A.singleton (fromNumber num)
               in (caseJsonArray Nothing  Just (fromArray arr) == Just arr)
                  <?> "Error in fromArray")
  quickCheck (\(Tuple str num) ->
               let sm :: Obj.Object Json
                   sm = Obj.singleton str (fromNumber num)
               in (caseJsonObject Nothing Just (fromObject sm) == Just sm)
                  <?> "Error in fromObject")

toTest :: Effect Unit
toTest = do
  assert (assertion toNull thisIsNull "Error in toNull")
  assert (assertion toBoolean thisIsBoolean "Error in toBoolean")
  assert (assertion toNumber thisIsNumber "Error in toNumber")
  assert (assertion toString thisIsString "Error in toString")
  assert (assertion toArray thisIsArray "Error in toArray")
  assert (assertion toObject thisIsObject "Error in toObject")
  where
  assertion :: forall a. (Eq a) => (Json -> Maybe a) -> Json -> String -> Result
  assertion fn j msg =
    let forCases = A.catMaybes (fn <$> cases)
        exact = A.singleton $ unsafePartial fromJust $ fn j
    in forCases == exact <?> msg


parserTest :: Effect Unit
parserTest = do
  assert ((isLeft (jsonParser "\\\ffff")) <?> "Error in jsonParser")
  quickCheck' 10 roundtripTest
  where
  roundtripTest :: Gen Result
  roundtripTest = do
    json <- Gen.resize (const 5) genJson
    let parsed = jsonParser (stringify json)
    pure $ parsed == Right json <?> show (stringify <$> parsed) <> " /= " <> stringify json 

assert :: forall prop. Testable prop => prop -> Effect Unit
assert = quickCheck' 1

main :: Effect Unit
main = do
  log "isXxx tests"
  isTest
  log "caseJson tests"
  foldTest
  log "caseJsonXxx tests"
  foldXXX
  log "fromXxx tests"
  fromTest
  log "toXxx tests"
  toTest
  log "jsonParser tests"
  parserTest
