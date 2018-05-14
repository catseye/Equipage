module Main where

import System.Environment
import qualified Equipage
import qualified EquipageQ

main = do
    args <- getArgs
    case args of
        ["-Q", fileName] -> do
            c <- readFile fileName
            putStrLn $ show $ EquipageQ.interp c []
            return ()
        [fileName] -> do
            c <- readFile fileName
            putStrLn $ show $ Equipage.interp c []
            return ()
        _ -> do
            putStrLn "Usage: equipage [-Q] <equipage-program-text-filename>"
