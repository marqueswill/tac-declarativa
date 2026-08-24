-- | A tiny environment (association list) used as the typing context.
--
-- Nothing here needs to be changed by students.
module Env
  ( Env,
    empty,
    extend,
    look,
    toList,
  )
where

import AbsMoreSTLC (Ident)
import Prelude

-- | Bindings are consed on the front, so 'extend' implements shadowing
--   for free: the most recent binding for a name is the one 'look' finds.
newtype Env a = Env [(Ident, a)]

empty :: Env a
empty = Env []

extend :: Ident -> a -> Env a -> Env a
extend x a (Env xs) = Env ((x, a) : xs)

look :: Ident -> Env a -> Maybe a
look x (Env xs) = Prelude.lookup x xs

-- | Most recent binding first.
toList :: Env a -> [(Ident, a)]
toList (Env xs) = xs
