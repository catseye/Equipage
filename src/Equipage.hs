module Equipage where

data Elem = Int Integer
          | Fn ([Elem] -> [Elem])

instance Show Elem where
    show (Int i) = show i
    show (Fn _)  = "<fn>"

apply (Fn f:s) = f s
compose (Fn f1:Fn f2:s) = ((Fn (f1 . f2)):s)

pop (e:s) = s
swap (e1:e2:s) = (e2:e1:s)

add ((Int a):(Int b):s) = ((Int (a + b)):s)
sub ((Int a):(Int b):s) = ((Int (b - a)):s)

sign (Int a:s) = (Int (if a > 0 then 1 else if a < 0 then -1 else 0):s)
pick (Int a:s) = ((if a > 0 then pick' a s else if a < 0 then pick' (0-a) (reverse s) else (Int 0)):s)
pick' 1 (s:t) = s
pick' n (s:t) = pick' (n-1) t

push e s = (e:s)

interp :: String -> [Elem] -> [Elem]
interp t = foldr (flip (.)) id (map (ic) t)

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
