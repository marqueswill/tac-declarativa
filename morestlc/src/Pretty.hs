-- | Small helpers for turning syntax back into text.
--
-- The real work is done by the BNFC generated pretty printer
-- ('PrintMoreSTLC.printTree'), which is derived from the very same
-- grammar as the parser -- so what you print here can be parsed again.
--
-- Nothing here needs to be changed by students.
module Pretty
  ( unIdent
  , ppTerm
  , ppType
  ) where

import Prelude
import AbsMoreSTLC
import PrintMoreSTLC (printTree)

unIdent :: Ident -> String
unIdent (Ident s) = s

ppTerm :: Term -> String
ppTerm = printTree

ppType :: Type -> String
ppType = printTree

