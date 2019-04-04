module Main where

import Data.Array (drop)
import Equipage (interp)
import Node.Process (PROCESS, argv)

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.List (List(Nil))
import Node.Encoding (Encoding(..))
import Node.FS (FS)
import Node.FS.Sync (readTextFile)
import Partial.Unsafe (unsafePartial)
import Prelude (Unit, bind, ($))

main :: forall e. Eff (console :: CONSOLE, exception :: EXCEPTION, fs :: FS, process :: PROCESS | e) Unit
main = do
  args <- argv
  let params = drop 2 args
  case params of
    [fileName] -> do
      c <- readTextFile UTF8 fileName
      logShow $ unsafePartial $ interp c Nil
    _ ->
      log "Usage: equipage <equipage-program-text-filename>"
