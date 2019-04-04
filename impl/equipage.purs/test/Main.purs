module Test.Main where

import Prelude (Unit, discard, show, ($), (==))
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Test.Assert (ASSERT, assert)
import Equipage (interp)
import Partial.Unsafe (unsafePartial)
import Data.List (List(Nil))

type Spec = { src :: String, out :: String }

one :: Spec
one = { src: "1!", out: "(1 : Nil)"}

apply :: Spec
apply = { src: "1!1!", out: "(1 : 1 : Nil)"}

apply' :: Spec
apply' = { src: "1;!", out:  "(1 : Nil)"}

add :: Spec
add = { src: "1!1!+!", out: "(2 : Nil)"}

nop :: Spec
nop = { src: "1!  1!1!+! \
             \ 1!1!+!1!+!" , out: "(3 : 2 : 1 : Nil)"}

swapPop :: Spec
swapPop = { src: "1!  1!1!+!  1!1!+!1!+!   \\!$!", out: "(3 : 1 : Nil)"}

sub :: Spec
sub = { src: "1!  1!1!+!  1!1!+!1!+!   +!+!  1!-!", out: "(5 : Nil)"}

sign :: Spec
sign = {src: "1!1!+!1!+!   %!", out : "(1 : Nil)"}

sign' :: Spec
sign' = {src: "1!1!-!1!-!   %!", out: "(-1 : Nil)"}

sign'' :: Spec
sign'' = {src: "1!1!-!       %!", out: "(0 : Nil)"}

pick :: Spec
pick = {src: "1!  1!1!+!  1!1!+!1!+!    1!              ~!", out: "(3 : 3 : 2 : 1 : Nil)"}

pick' :: Spec
pick' = {src: "1!  1!1!+!  1!1!+!1!+!    1!1!+!          ~!", out: "(2 : 3 : 2 : 1 : Nil)"}

pick'' :: Spec
pick'' = {src: "1!  1!1!+!  1!1!+!1!+!    1!1!-!1!-!      ~!", out: "(1 : 3 : 2 : 1 : Nil)"}

pick''' :: Spec
pick''' = {src: "1!  1!1!+!  1!1!+!1!+!    1!1!-!1!-!1!-!  ~!", out: "(2 : 3 : 2 : 1 : Nil)"}

pick'''' :: Spec
pick'''' = {src: "1!  1!1!+!  1!1!+!1!+!    1!1!-!          ~!", out: "(0 : 3 : 2 : 1 : Nil)"}

compose :: Spec
compose = {src: "1!  1!1!+!  1!1!+!1!+!    \\$.!    !", out: "(3 : 1 : Nil)"}

call :: Spec
call = {src: "11+.!.!\
            \ 1!1!-!1!-!~!;!\
            \ 1!1!-!1!-!~!;!\
            \ 1!1!-!1!-!~!;!", out: "(2 : 2 : 2 : <fn> : Nil)"}

call' :: Spec
call' = {src: "1~+.!.!\
             \ 1!\
             \ 1!1!-!1!-!~!;!\
             \ 1!1!-!1!-!~!;!\
             \ 1!1!-!1!-!~!;!", out: "(8 : <fn> : Nil)"}

main :: forall e. Eff (console :: CONSOLE, assert :: ASSERT | e) Unit
main = do
  test one
  test apply
  test apply'
  test add
  test nop
  test swapPop
  test sub
  test sign
  test sign'
  test sign''
  test pick
  test pick'
  test pick''
  test pick'''
  test pick''''
  test compose
  test call
  test call'
  where test s = assert $ show (unsafePartial $ interp s.src Nil) == s.out
  