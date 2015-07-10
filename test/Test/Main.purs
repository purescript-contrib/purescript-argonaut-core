module Test.Main where

import Prelude

import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Console (log)
import Data.Maybe (Maybe(..))
import Data.Maybe.Unsafe (fromJust)
import Data.Either (isLeft, isRight, Either(..))
import Data.Tuple (Tuple(..))
import Data.Foldable (for_)
import qualified Data.Array as A
import qualified Data.StrMap as M

import Data.Argonaut.Core
import Data.Argonaut.Parser
import Data.Argonaut.Printer

import Test.StrongCheck (assert, (<?>), quickCheck, Result())

foreign import thisIsNull :: Json
foreign import thisIsBoolean :: Json
foreign import thisIsNumber :: Json
foreign import thisIsString :: Json
foreign import thisIsArray :: Json
foreign import thisIsObject :: Json
foreign import nil :: JNull

isTest :: Eff _ Unit
isTest = do
  assert (isNull thisIsNull <?> "Error in null test")
  assert (isBoolean thisIsBoolean <?> "Error in boolean test")
  assert (isNumber thisIsNumber <?> "Error in number test")
  assert (isString thisIsString <?> "Error in string test")
  assert (isArray thisIsArray <?> "Error in array test")
  assert (isObject thisIsObject <?> "Error in object test")

foldTest :: Eff _ Unit
foldTest = do
  assert (foldFn thisIsNull == "null" <?> "Error in foldJson null")
  assert (foldFn thisIsBoolean == "boolean" <?> "Error in foldJson boolean")
  assert (foldFn thisIsNumber == "number" <?> "Error in foldJson number")
  assert (foldFn thisIsString == "string" <?> "Error in foldJson string")
  assert (foldFn thisIsArray == "array" <?> "Error in foldJson array")
  assert (foldFn thisIsObject == "object" <?> "Error in foldJson object")


foldFn :: Json -> String
foldFn = foldJson
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

foldXXX :: Eff _ Unit
foldXXX = do
  assert ((foldJsonNull "not null" (const "null") <$> cases) ==
          ["null", "not null", "not null", "not null", "not null", "not null"] <?>
          "Error in foldJsonNull")
  assert ((foldJsonBoolean "not boolean" (const "boolean") <$> cases) ==
          ["not boolean", "boolean", "not boolean", "not boolean", "not boolean", "not boolean"] <?>
          "Error in foldJsonBoolean")
  assert ((foldJsonNumber "not number" (const "number") <$> cases) ==
          ["not number", "not number", "number", "not number", "not number", "not number"] <?>
          "Error in foldJsonNumber")

  assert ((foldJsonString "not string" (const "string") <$> cases) ==
          ["not string", "not string", "not string", "string", "not string", "not string"] <?>
          "Error in foldJsonString")

  assert ((foldJsonArray "not array" (const "array") <$> cases) ==
          ["not array", "not array", "not array", "not array", "array", "not array"] <?>
          "Error in foldJsonArray")
  assert ((foldJsonObject "not object" (const "object") <$> cases) ==
          ["not object", "not object", "not object", "not object", "not object", "object"] <?>
          "Error in foldJsonObject")


fromTest :: Eff _ Unit
fromTest = do
  assert ((foldJsonNull false (const true) (fromNull nil)) <?> "Error in fromNull")
  quickCheck (\bool -> foldJsonBoolean Nothing Just (fromBoolean bool) == Just bool <?> "Error in fromBoolean")
  quickCheck (\num -> foldJsonNumber Nothing Just (fromNumber num) == Just num <?> "Error in fromNumber")
  quickCheck (\str -> foldJsonString Nothing Just (fromString str) == Just str <?> "Error in fromString")
  quickCheck (\num ->
               let arr :: Array Json
                   arr = A.singleton (fromNumber num)
               in (foldJsonArray Nothing  Just (fromArray arr) == Just arr)
                  <?> "Error in fromArray")
  quickCheck (\(Tuple str num) ->
               let sm :: M.StrMap Json
                   sm = M.singleton str (fromNumber num)
               in (foldJsonObject Nothing Just (fromObject sm) == Just sm)
                  <?> "Error in fromObject")

toTest :: Eff _ Unit
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
        exact = A.singleton $ fromJust $ fn j
    in forCases == exact <?> msg


parserTest :: Eff _ Unit
parserTest = do
  assert ((isRight (jsonParser "{\"foo\": 1}")) <?> "Error in jsonParser")
  assert ((isLeft (jsonParser "\\\ffff")) <?> "Error in jsonParser")

printJsonTest :: Eff _ Unit
printJsonTest = do
  for_ cases (assert <<< assertion)
  where
  assertion :: Json -> Result
  assertion j = ((jsonParser (printJson j)) == Right j) <?> "Error in printJson"

main :: Eff _ Unit
main = do
  log "isXxx tests" 
  isTest
  log "foldJson tests"
  foldTest
  log "foldJsonXxx tests"
  foldXXX
  log "fromXxx tests"
  fromTest
  log "toXxx tests"
  toTest
  log "jsonParser tests"
  parserTest
  log "printJson tests" 
  printJsonTest
