-- ---------------------------------------------------------------------------

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
module Eval
  ( RuntimeError (..),
    isValue,
    subst,
    eval,
    renderRuntimeError,
  )
where

import AbsMoreSTLC
import AbsMoreSTLC (Term (TmCons, TmLet))
import Data.Either (Either (Left, Right))
import Pretty (ppTerm, unIdent)
import Text.XHtml (sub)
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
  TmCons v1 v2 -> isValue v1 && isValue v2 -- v_lcons -> calls recursively
  TmPair v1 v2 -> isValue v1 && isValue v2 -- v_pair -> calls recursively
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

-- Shadowing significa que uma variável de um escopo interno tem o mesmo nome
-- de outra em um contexto externo.
-- Basicamente isso aqui tá explicando que a substituição por ser "burra" e assumir
-- que sempre que uma variável for redefinida eu posso assumir que a substituição
-- para o valor antigo foi completa. Não tem branching

-- All the boring congruence cases are given. The three cases that bind a
-- variable are left for you.

-- Substitui o termo "s" por todas ocorrências de "x" dentro do termo "t"
subst :: Ident -> Term -> Term -> Term
subst x s = go
  where
    go t = case t of
      TmVar y ->
        if y == x
          then s
          else TmVar y
      -- \*** your turn: these three bind variables ***
      -- Casos com substituição de variáveis

      TmAbs y ty t1 ->
        -- \y : ty -> t1
        -- y  ==> arg
        -- ty ==> tipo de y
        -- t1 ==> corpo
        -- eu preciso substituir o s dentro de t1
        -- Se y == x, estou definindo outra função com mesmo nome
        -- todo "subst: TmAbs (mind the shadowing when _y == x)"
        if y == x -- Se eu encontro um novo termo com mesmo "id" que já estou substituindo
          then TmAbs y ty t1 -- eu paro a substituição
          else TmAbs y ty (go t1) -- senão se o simbolo nao foi redefinido, eu continuo substituindo ele
      TmLet y t1 t2 ->
        -- let y = t1 in t2
        -- todo "subst: TmLet (t1 is not in the scope of y)"
        if x /= y -- se o subst de um let encontrar outro let (redefinição/shadowing)
          then TmLet y (go t1) (go t2) -- substitui x em ambos
          else TmLet y t1' t2' -- substitui x em t1, pego o resultado e substituo ele em t2
          -- shadowing:
          -- let x = 10 in (let x = x + 1 in x * 2)
          -- 10 substitui apenas na redefinição, senão substitui em ambos
        where
          t1' = go t1
          t2' = subst y t1' t2
      TmLcase t1 t2 j k t3 ->
        -- todo "subst: TmLcase (x and y are bound in the last branch only)"
        -- x
        let t1' = go t1
            t2' = go t2
         in if (x == j || x == k) -- verificação de shadowing para a ultima branch
              then TmLcase t1' t2' j k t3
              else TmLcase t1' t2' j k (go t3)
      -- congruence cases, nothing to do here
      -- casos que só propaga/ continua a recursão
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
      -- Casos base
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
eval (TmVar x) = Left (FreeVariable x) -- a free variable in a closed program is a bug, not a value

-- --- your turn --------------------------------------------------------------

--   t1 ==> \x:T2, t   t2 ==> v2   [x:=v2]t ==> v
--   -------------------------------------------  (ST_AppAbs, ST_App1, ST_App2)
--   t1 t2 ==> v
eval (TmApp t1 t2) = do
  v1 <- eval t1
  v2 <- eval t2
  case v1 of
    TmAbs x _ body -> eval (subst x v2 body) -- substitui o v2 no corpo de v1
    _ -> Left (Stuck (TmApp t1 t2))

--   t1 ==> n
--   ---------------------       (ST_SuccNat)
--   succ t1 ==> n+1
eval (TmSucc t1) = do
  v1 <- eval t1
  case v1 of
    TmConst n -> Right (TmConst (n + 1))
    _ -> Left (Stuck (TmSucc t1))

--   t1 ==> n
--   -------------------------   (ST_PredNat)
--   pred t1 ==> n-1
--   (and pred 0 ==> 0)
eval (TmPred t1) = do
  v1 <- eval t1
  case v1 of
    TmConst 0 -> Right (TmConst 0) -- ATENÇÃO: Adicionado para respeitar a regra 'pred 0 ==> 0'
    TmConst n -> Right (TmConst (n - 1))
    _ -> Left (Stuck (TmPred t1))

--   t1 ==> n1    t2 ==> n2
--   ------------------------    (ST_Mulconsts)
--   t1 * t2 ==> n1*n2
eval (TmMult t1 t2) = do
  v1 <- eval t1
  v2 <- eval t2
  case v1 of
    TmConst n1 -> case v2 of
      TmConst n2 -> Right (TmConst (n1 * n2))
      _ -> Left (Stuck (TmMult v1 t2))
    _ -> Left (Stuck (TmMult t1 t2))

--   t1 ==> 0    t2 ==> v        t1 ==> n   n > 0    t3 ==> v
--   -------------------------   -----------------------------  (ST_If0Zero, ST_If0Nonzero)
--   if0 t1 then t2 else t3      if0 t1 then t2 else t3
--       ==> v                       ==> v
eval (TmIf0 t1 t2 t3) = do
  v1 <- eval t1
  case v1 of
    TmConst 0 -> eval t2
    TmConst n -> eval t3
    _ -> Left (Stuck (TmIf0 t1 t2 t3))

--   t1 ==> v1    [x:=v1]t2 ==> v
--   ----------------------------- (ST_LetValue)
--   let x = t1 in t2 ==> v
eval (TmLet x t1 t2) = do
  v1 <- eval t1
  eval (subst x v1 t2)

--   t1 ==> v1  t2 ==> v2
--   ----------------------      (v_pair)
--   (t1,t2) ==> (v1,v2)
eval (TmPair t1 t2) = do
  v1 <- eval t1
  v2 <- eval t2
  Right (TmPair v1 v2)

--   t0 ==> (v1, v2)
--   ----------------
--   t0.fst ==> v1
eval (TmFst t0) = do
  v0 <- eval t0
  case v0 of
    TmPair v1 _ -> Right v1
    _ -> Left (Stuck (TmFst t0))

--   t0 ==> (v1, v2)
--   ----------------
--   t0.snd ==> v2
eval (TmSnd t0) = do
  v0 <- eval t0
  case v0 of
    TmPair _ v2 -> Right v2
    _ -> Left (Stuck (TmSnd t0))

--   t1 ==> v1   t2 ==> v2
--   ----------------------
--   t1 :: t2 ==> v1 :: v2
eval (TmCons t1 t2) = do
  v1 <- eval t1
  v2 <- eval t2
  Right (TmCons v1 v2)

--   t1 ==> nil T   t2 ==> v
--   ----------------------------------------
--   case t1 of | nil => t2 | x::y => t3 ==> v
--
--   t1 ==> vh :: vt    [x:=vh]([y:=vt]t3) ==> v
--   -------------------------------------------- (ST_LcaseCons)
--   case t1 of | nil => t2 | x::y => t3 ==> v
eval (TmLcase t1 t2 x y t3) = do
  v1 <- eval t1
  case v1 of
    TmNil _ -> eval t2
    TmCons vh vt -> eval (subst x vh (subst y vt t3))
    _ -> Left (Stuck (TmLcase t1 t2 x y t3))

--   t1 ==> \xf:T1, t     [xf := fix (\xf:T1, t)] t ==> v
--   -----------------------------------------------------  (ST_FixAbs)
--   fix t1 ==> v
eval (TmFix t1) = do
  v1 <- eval t1
  case v1 of
    TmAbs xf ty t -> eval (subst xf (TmFix v1) t)
    _ -> Left (Stuck (TmFix t1))

-- ---------------------------------------------------------------------------
-- Error messages
-- ---------------------------------------------------------------------------

renderRuntimeError :: RuntimeError -> String
renderRuntimeError err = case err of
  Stuck t -> "stuck term: `" ++ ppTerm t ++ "'"
  FreeVariable x -> "free variable at run time: `" ++ unIdent x ++ "'"
  NotImplemented w -> "not implemented yet -- " ++ w
