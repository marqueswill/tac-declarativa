-- ---------------------------------------------------------------------------

-- | Dynamic semantics of MoreSTLC  --  *** STUDENT EXERCISE ***
--
-- MoreStlc.v gives a SMALL step relation @t --> t'@.  Here you implement the
-- corresponding BIG STEP relation
--
--     t ==> v      ("t evaluates to the value v")
--
-- which is the reflexive transitive closure of @-->@ ending in a value, read
-- off rule by rule.  Evaluation is CALL BY VALUE, and values are represented
-- as terms again -- exactly the ones 'isValue' accepts -- because
-- MoreStlc.v defines evaluation by SUBSTITUTION, not by closures.
--
-- The rules, with the corresponding constructors of @step@ in MoreStlc.v:
--
--   ---------- v value                     (v_abs, v_nat, v_lnil, v_lcons,
--   v ==> v                                 v_pair)
--
--   t1 ==> \x:T2, t   t2 ==> v2   [x:=v2]t ==> v        (ST_AppAbs, ST_App1,
--   -------------------------------------------          ST_App2)
--   t1 t2 ==> v
--
--   t1 ==> n                    t1 ==> n
--   ---------------------       -------------------------  (ST_SuccNat,
--   succ t1 ==> n+1             pred t1 ==> n-1             ST_PredNat)
--                               (and pred 0 ==> 0)
--
--   t1 ==> n1    t2 ==> n2
--   ------------------------                              (ST_Mulconsts)
--   t1 * t2 ==> n1*n2
--
--   t1 ==> 0    t2 ==> v        t1 ==> n   n > 0    t3 ==> v
--   -------------------------   -----------------------------  (ST_If0Zero,
--   if0 t1 then t2 else t3      if0 t1 then t2 else t3           ST_If0Nonzero)
--       ==> v                       ==> v
--
--   t1 ==> v1    [x:=v1]t2 ==> v
--   -----------------------------                         (ST_LetValue)
--   let x = t1 in t2 ==> v
--
--   t1 ==> v1  t2 ==> v2        t0 ==> (v1, v2)     t0 ==> (v1, v2)
--   ----------------------      ----------------    ----------------
--   (t1,t2) ==> (v1,v2)         t0.fst ==> v1       t0.snd ==> v2
--
--   t1 ==> v1   t2 ==> v2       t1 ==> nil T   t2 ==> v
--   ----------------------      ----------------------------------------
--   t1 :: t2 ==> v1 :: v2       case t1 of | nil => t2 | x::y => t3 ==> v
--
--   t1 ==> vh :: vt    [x:=vh]([y:=vt]t3) ==> v
--   --------------------------------------------          (ST_LcaseCons)
--   case t1 of | nil => t2 | x::y => t3 ==> v
--
--   t1 ==> \xf:T1, t     [xf := fix (\xf:T1, t)] t ==> v
--   -----------------------------------------------------  (ST_FixAbs)
--   fix t1 ==> v
--
-- ---------------------------------------------------------------------------
module Eval
  ( RuntimeError (..),
    isValue,
    subst,
    eval,
    renderRuntimeError,
  )
where

import AbsMoreSTLC
import Pretty (ppTerm, unIdent)
import Prelude

data RuntimeError
  = -- | no evaluation rule applies (a well typed program never gets stuck)
    Stuck Term
  | FreeVariable Ident
  | NotImplemented String
  deriving (Eq, Show)

-- ---------------------------------------------------------------------------
-- Values
-- ---------------------------------------------------------------------------

-- | The values of MoreSTLC.  This one is given to you: it is @Inductive value@
--   of MoreStlc.v, and 'eval' must return exactly the terms that satisfy
--   it.
isValue :: Term -> Bool
isValue e = case e of
  TmAbs _ _ _ -> True -- v_abs: a lambda is a value, its body is NOT
  --        evaluated
  TmConst _ -> True -- v_nat
  TmNil _ -> True -- v_lnil
  TmCons v1 v2 -> isValue v1 && isValue v2 -- v_lcons
  TmPair v1 v2 -> isValue v1 && isValue v2 -- v_pair
  _ -> False

-- ---------------------------------------------------------------------------
-- Substitution
-- ---------------------------------------------------------------------------

-- | @subst x s t@ is @[x:=s]t@ of MoreStlc.v.
--
-- Because the language is call by value and programs are closed, @s@ is
-- always a closed value, so naive substitution cannot capture anything --
-- you do NOT need to rename bound variables.  You DO need to stop
-- substituting when a binder shadows @x@.
--
-- All the boring congruence cases are given.  The three cases that bind a
-- variable are left for you.
subst :: Ident -> Term -> Term -> Term
subst x s = go
  where
    go t = case t of
      -- the interesting case
      TmVar y -> if y == x then s else TmVar y
      -- \*** your turn: these three bind variables ***
      TmAbs _y _ty _t1 -> todo "subst: TmAbs (mind the shadowing when _y == x)"
      TmLet _y _t1 _t2 -> todo "subst: TmLet (_t1 is not in the scope of _y)"
      TmLcase {} -> todo "subst: TmLcase (x and y are bound in the last branch only)"
      -- congruence cases, nothing to do here
      TmApp t1 t2 -> TmApp (go t1) (go t2)
      TmIf0 t1 t2 t3 -> TmIf0 (go t1) (go t2) (go t3)
      TmSucc t1 -> TmSucc (go t1)
      TmPred t1 -> TmPred (go t1)
      TmMult t1 t2 -> TmMult (go t1) (go t2)
      TmFst t0 -> TmFst (go t0)
      TmSnd t0 -> TmSnd (go t0)
      TmFix t1 -> TmFix (go t1)
      TmPair t1 t2 -> TmPair (go t1) (go t2)
      TmCons t1 t2 -> TmCons (go t1) (go t2)
      TmConst n -> TmConst n
      TmNil ty -> TmNil ty

    todo :: String -> a
    todo what = error ("*** not implemented yet -- " ++ what ++ " (see src/Eval.hs)")

-- ---------------------------------------------------------------------------
-- The evaluation relation
-- ---------------------------------------------------------------------------

-- | @eval t@ evaluates the closed term @t@ to a value.
--
-- The value cases are filled in as worked examples.  Replace every
-- @Left (NotImplemented ...)@ below with the corresponding rule.
eval :: Term -> Either RuntimeError Term
-- --- worked examples: values evaluate to themselves -------------------------

eval (TmConst n) = Right (TmConst n)
eval t@(TmAbs {}) = Right t
eval (TmNil ty) = Right (TmNil ty)
-- a free variable in a closed program is a bug, not a value
eval (TmVar x) = Left (FreeVariable x)
-- --- your turn --------------------------------------------------------------

eval (TmApp _t1 _t2) = Left (NotImplemented "eval: TmApp")
eval (TmSucc _t1) = Left (NotImplemented "eval: TmSucc")
eval (TmPred _t1) = Left (NotImplemented "eval: TmPred")
eval (TmMult _t1 _t2) = Left (NotImplemented "eval: TmMult")
eval (TmIf0 _t1 _t2 _t3) = Left (NotImplemented "eval: TmIf0")
eval (TmLet _x _t1 _t2) = Left (NotImplemented "eval: TmLet")
eval (TmPair _t1 _t2) = Left (NotImplemented "eval: TmPair")
eval (TmFst _t0) = Left (NotImplemented "eval: TmFst")
eval (TmSnd _t0) = Left (NotImplemented "eval: TmSnd")
eval (TmCons _t1 _t2) = Left (NotImplemented "eval: TmCons")
eval (TmLcase {}) = Left (NotImplemented "eval: TmLcase")
eval (TmFix _t1) = Left (NotImplemented "eval: TmFix")

-- ---------------------------------------------------------------------------
-- Error messages
-- ---------------------------------------------------------------------------

renderRuntimeError :: RuntimeError -> String
renderRuntimeError err = case err of
  Stuck t -> "stuck term: `" ++ ppTerm t ++ "'"
  FreeVariable x -> "free variable at run time: `" ++ unIdent x ++ "'"
  NotImplemented w -> "not implemented yet -- " ++ w
