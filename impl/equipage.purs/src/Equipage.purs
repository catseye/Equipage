module Equipage (interp, Elem) where

import Prelude (class Show, id, map, negate, otherwise, show, ($), (+), (-), (<), (<<<), (>), (>>>))
import Data.List (List, foldr, fromFoldable, reverse, (:))
import Data.String (toCharArray)

data Elem
  = Int Int
  | Fn (List Elem -> List Elem)

instance showElem :: Show Elem where
  show (Int i) = show i
  show (Fn _)  = "<fn>"

apply :: Partial => List Elem -> List Elem
apply (Fn f : s) = f s

compose :: Partial => List Elem -> List Elem
compose (Fn f1 : Fn f2 : s) = Fn (f1 <<< f2) : s

pop :: Partial => List Elem -> List Elem
pop (_ : s) = s

swap :: Partial => List Elem -> List Elem
swap (e1 : e2 : s) = e2 : e1 : s

add :: Partial => List Elem -> List Elem
add (Int a : Int b : s) = Int (a + b) : s

sub :: Partial =>  List Elem -> List Elem
sub (Int a : Int b : s) = Int (b - a) : s

sign :: Partial => List Elem -> List Elem
sign (Int a : s) = Int x : s
  where x | a > 0     =  1
          | a < 0     = -1
          | otherwise =  0

pick :: Partial => List Elem -> List Elem
pick (Int a : s) = x : s
  where x | a > 0     = pick' a s
          | a < 0     = pick' (0 - a) (reverse s)
          | otherwise = Int 0
        pick' 1 (s : _) = s
        pick' n (_ : t) = pick' (n - 1) t

push :: Elem -> List Elem -> List Elem
push = (:)

stringToCharList :: String -> List Char
stringToCharList = fromFoldable <<< toCharArray

interp :: Partial => String -> List Elem -> List Elem
interp = interp' <<< stringToCharList

interp' :: Partial => List Char -> List Elem -> List Elem
interp' t = foldr (>>>) id (map ic t)

ic :: Partial => Char -> List Elem -> List Elem
ic '!'  = apply
ic ';'  = push $ Fn apply
ic '.'  = push $ Fn compose
ic '$'  = push $ Fn pop
ic '\\' = push $ Fn swap
ic '+'  = push $ Fn add
ic '-'  = push $ Fn sub
ic '%'  = push $ Fn sign
ic '~'  = push $ Fn pick
ic '1'  = push $ Fn (push $ Int 1)
ic ' '  = id
ic '\t' = id
ic '\n' = id
ic '\r' = id