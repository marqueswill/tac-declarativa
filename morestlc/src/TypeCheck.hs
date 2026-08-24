-- ---------------------------------------------------------------------------

-- | Static semantics of MoreSTLC  --  *** STUDENT EXERCISE ***
--
-- Implement the typing relation
--
--     Gamma |-- t \in T
--
-- as the function 'typeOf'.  The rules are the ones of @has_type@ in
-- MoreStlc.v, restricted to the fragment of the language kept here (no sums,
-- no Unit, no records, no variants -- and no booleans, since MoreStlc.v has
-- none: @if0@ is the only conditional).
--
--   T_Var                            T_Abs
--   x \in Gamma  Gamma x = T1        Gamma, x:T2 |-- t1 \in T1
--   -------------------------        ------------------------------
--   Gamma |-- x \in T1               Gamma |-- \x:T2, t1 \in T2 -> T1
--
--   T_App
--   Gamma |-- t1 \in T2 -> T1    Gamma |-- t2 \in T2
--   -------------------------------------------------
--   Gamma |-- t1 t2 \in T1
--
--   T_Nat            T_Succ                     T_Pred
--   ---------------  Gamma |-- t1 \in Nat       Gamma |-- t1 \in Nat
--   Gamma |-- n      -----------------------    -----------------------
--       \in Nat      Gamma |-- succ t1 \in Nat  Gamma |-- pred t1 \in Nat
--
--   T_Mult                                   T_If0
--   Gamma |-- t1 \in Nat                     Gamma |-- t1 \in Nat
--   Gamma |-- t2 \in Nat                     Gamma |-- t2 \in T0
--   ------------------------                 Gamma |-- t3 \in T0
--   Gamma |-- t1 * t2 \in Nat                ----------------------------------
--                                            Gamma |-- if0 t1 then t2 else t3
--                                                \in T0
--
--   T_Pair                                   T_Fst                 T_Snd
--   Gamma |-- t1 \in T1                      Gamma |-- t0          Gamma |-- t0
--   Gamma |-- t2 \in T2                          \in T1 * T2           \in T1 * T2
--   ----------------------------             ------------------    ------------------
--   Gamma |-- (t1, t2) \in T1 * T2           Gamma |-- t0.fst      Gamma |-- t0.snd
--                                                \in T1                \in T2
--
--   T_Nil                                    T_Cons
--   -------------------------------          Gamma |-- t1 \in T1
--   Gamma |-- nil T1 \in List T1             Gamma |-- t2 \in List T1
--                                            -----------------------------
--                                            Gamma |-- t1 :: t2 \in List T1
--
--   T_Lcase
--   Gamma |-- t1 \in List T1    Gamma |-- t2 \in T2
--   Gamma, x1:T1, x2:List T1 |-- t3 \in T2
--   ------------------------------------------------------------
--   Gamma |-- case t1 of | nil => t2 | x1 :: x2 => t3 \in T2
--
--   T_Let                                    T_Fix
--   Gamma |-- t1 \in T1                      Gamma |-- t1 \in T1 -> T1
--   Gamma, x:T1 |-- t2 \in T2                -------------------------
--   ---------------------------------        Gamma |-- fix t1 \in T1
--   Gamma |-- let x = t1 in t2 \in T2
--
-- ---------------------------------------------------------------------------
module TypeCheck
  ( Ctx,
    TypeError (..),
    typeOf,
    typeCheck,
    expect,
    renderTypeError,
  )
where

import AbsMoreSTLC
import Env (Env)
import Env qualified
import Pretty (ppTerm, ppType, unIdent)
import Prelude

-- | A typing context: names to types.
type Ctx = Env Type

data TypeError
  = UnboundVariable Ident
  | -- | expected type, actual type, offending term
    Mismatch Type Type Term
  | NotAFunction Type Term
  | NotAPair Type Term
  | NotAList Type Term
  | -- | type of the first branch, type of the second branch, whole term
    BranchMismatch Type Type Term
  | NotImplemented String
  deriving (Eq, Show)

-- | Type check a closed term.
typeCheck :: Term -> Either TypeError Type
typeCheck = typeOf Env.empty

-- | Check that @t@ has exactly the type @ty@ in context @ctx@.
--   Useful for the many rules with a fixed premise such as @t1 \in Nat@.
expect :: Ctx -> Type -> Term -> Either TypeError ()
expect ctx ty t = do
  ty' <- typeOf ctx t
  if ty' == ty then Right () else Left (Mismatch ty ty' t)

-- ---------------------------------------------------------------------------
-- The typing relation
-- ---------------------------------------------------------------------------

-- | @typeOf ctx t@ returns the type of @t@ under @ctx@, or a 'TypeError'.
--
-- Three cases are filled in below as worked examples.  Replace every
-- @Left (NotImplemented ...)@ with the corresponding rule.
typeOf :: Ctx -> Term -> Either TypeError Type
-- --- worked examples -------------------------------------------------------

-- T_Var
typeOf ctx (TmVar x) =
  case Env.look x ctx of
    Just t -> Right t
    Nothing -> Left (UnboundVariable x)
-- T_Nat
typeOf _ (TmConst _) = Right TyNat
-- T_Succ
typeOf ctx (TmSucc t1) = do
  expect ctx TyNat t1
  Right TyNat

-- --- your turn -------------------------------------------------------------

typeOf _ctx (TmPred _t1) = Left (NotImplemented "typeOf: TmPred")
typeOf _ctx (TmMult _t1 _t2) = Left (NotImplemented "typeOf: TmMult")
typeOf _ctx (TmIf0 _t1 _t2 _t3) = Left (NotImplemented "typeOf: TmIf0")
typeOf _ctx (TmAbs _x _ty _t1) = Left (NotImplemented "typeOf: TmAbs")
typeOf _ctx (TmApp _t1 _t2) = Left (NotImplemented "typeOf: TmApp")
typeOf _ctx (TmLet _x _t1 _t2) = Left (NotImplemented "typeOf: TmLet")
typeOf _ctx (TmPair _t1 _t2) = Left (NotImplemented "typeOf: TmPair")
typeOf _ctx (TmFst _t0) = Left (NotImplemented "typeOf: TmFst")
typeOf _ctx (TmSnd _t0) = Left (NotImplemented "typeOf: TmSnd")
typeOf _ctx (TmNil _ty) = Left (NotImplemented "typeOf: TmNil")
typeOf _ctx (TmCons _t1 _t2) = Left (NotImplemented "typeOf: TmCons")
typeOf _ctx t@TmLcase {} = Left (NotImplemented ("typeOf: TmLcase in " ++ ppTerm t))
typeOf _ctx (TmFix _t1) = Left (NotImplemented "typeOf: TmFix")

-- ---------------------------------------------------------------------------
-- Error messages
-- ---------------------------------------------------------------------------

renderTypeError :: TypeError -> String
renderTypeError err = case err of
  UnboundVariable x ->
    "unbound variable `" ++ unIdent x ++ "'"
  Mismatch expected actual t ->
    "type mismatch in `"
      ++ ppTerm t
      ++ "'\n"
      ++ "    expected: "
      ++ ppType expected
      ++ "\n"
      ++ "      actual: "
      ++ ppType actual
  NotAFunction ty t ->
    "`" ++ ppTerm t ++ "' has type " ++ ppType ty ++ ", which is not a function type"
  NotAPair ty t ->
    "`" ++ ppTerm t ++ "' has type " ++ ppType ty ++ ", which is not a product type"
  NotAList ty t ->
    "`" ++ ppTerm t ++ "' has type " ++ ppType ty ++ ", which is not a list type"
  BranchMismatch ty1 ty2 t ->
    "branches of `"
      ++ ppTerm t
      ++ "' disagree:\n"
      ++ "    first branch : "
      ++ ppType ty1
      ++ "\n"
      ++ "    second branch: "
      ++ ppType ty2
  NotImplemented what ->
    "not implemented yet -- " ++ what
