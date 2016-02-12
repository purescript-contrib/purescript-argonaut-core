module Data.Argonaut.Printer (class Printer, printJson) where

import Prelude (show)
import Data.Argonaut.Core (Json())

class Printer a where
  printJson :: Json -> a

instance printerString :: Printer String where
  printJson = show
