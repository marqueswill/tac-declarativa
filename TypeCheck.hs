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
-- ---------------------------------------------------------------------------
module TypeCheck
  ( Ctx
  , TypeError (..)
  , typeOf
  , typeCheck
  , expect
  , renderTypeError
  ) where

import Prelude
import AbsMoreSTLC
import Pretty (ppTerm, ppType, unIdent)
import Env (Env)
import qualified Env

-- | A typing context: names to types.
type Ctx = Env Type

data TypeError
  = UnboundVariable Ident
  | Mismatch Type Type Term
    -- ^ expected type, actual type, offending term
  | NotAFunction Type Term
  | NotAPair Type Term
  | NotAList Type Term
  | BranchMismatch Type Type Term
    -- ^ type of the first branch, type of the second branch, whole term
  | NotImplemented String
  deriving (Eq, Show)

-- | Type check a closed term.
typeCheck :: Term -> Either TypeError Type
typeCheck = typeOf Env.empty

-- | Check that @t@ has exactly the type @ty@ in context @ctx@.
--   Useful for the many rules with a fixed premise such as @t1 \in Nat@.

-- Função que verifica se o contexto passado é igual ao contexto que foi previamente definido
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

--   T_Var                            T_Abs
--   x \in Gamma  Gamma x = T1        Gamma, x:T2 |-- t1 \in T1
--   -------------------------        ------------------------------
--   Gamma |-- x \in T1               Gamma |-- \x:T2, t1 \in T2 -> T1
--   T_Var

typeOf ctx (TmVar x) =
  case Env.look x ctx of -- busca o tipo de do termo do ctx
    Just t  -> Right t  -- se ele foi bem tipado, eu apenas retorno o tipo encontrado
    Nothing -> Left (UnboundVariable x) -- se não foi definido, a varíavel não tem tipo 

typeOf ctx (TmAbs _x _ty t1)   = Left (NotImplemented "typeOf: TmAbs")


--   T_Nat            T_Succ                     T_Pred
--   ---------------  Gamma |-- t1 \in Nat       Gamma |-- t1 \in Nat
--   Gamma |-- n      -----------------------    -----------------------
--       \in Nat      Gamma |-- succ t1 \in Nat  Gamma |-- pred t1 \in Nat

-- T_Nat
typeOf _ (TmConst _) = Right TyNat -- nessa versão, toda constante é um natural

-- T_Succ
typeOf ctx (TmSucc t1) = do -- todo sucesso de uma constante é um natural
  expect ctx TyNat t1
  Right TyNat

-- T_Pred
typeOf ctx (TmPred t1) = do -- todo antecessor de uma constante é um natural
  expect ctx TyNat t1 -- o tipo de t1 deve ser um natural
  Right TyNat

-- --- your turn -------------------------------------------------------------

--   T_Mult
--   Gamma |-- t1 \in Nat
--   Gamma |-- t2 \in Nat
--   ------------------------
--   Gamma |-- t1 * t2 \in Nat
--
typeOf ctx (TmMult t1 t2)     = do
  expect ctx TyNat t1
  expect ctx TyNat t2
  Right TyNat -- Se ambos termos foram naturais, o resultado será natural tmb

--   T_If0
--   Gamma |-- t1 \in Nat
--   Gamma |-- t2 \in T0
--   Gamma |-- t3 \in T0
--   ----------------------------------
--   Gamma |-- if0 t1 then t2 else t3
--       \in T0
--
typeOf ctx t@(TmIf0 t1 t2 t3)  = do
  expect ctx TyNat t1 -- t1 deve ser Nat
  ty2 <- typeOf ctx t2
  ty3 <- typeOf ctx t3

  if (ty2 == ty3) -- t2 e t3 deve ter tipos iguais
    then Right ty2 
    else Left (BranchMismatch ty2 ty3 t)


--   T_App
--   Gamma |-- t1 \in T2 -> T1    Gamma |-- t2 \in T2
--   -------------------------------------------------
--   Gamma |-- t1 t2 \in T1
--
typeOf ctx t@(TmApp t1 t2) = do
  ty1 <- typeOf ctx t1
  ty2 <- typeOf ctx t2
  case ty1 of
    TyArrow ty3 ty4 -> 
      if ty3 == ty2      -- Se tipo do arg igual tipo do valor passado (arg no dominio)
        then Right (ty4) -- O tipo retornado é o tipo de retorno (tipo da imagem)
        else Left (Mismatch expected actual ty2)
    _ -> Left (NotAFunction ty1 t)



--   T_Pair                                   
--   Gamma |-- t1 \in T1                      
--   Gamma |-- t2 \in T2                         
--   ----------------------------             
--   Gamma |-- (t1, t2) \in T1 * T2           
--
typeOf ctx (TmPair t1 t2)     = do
  ty1 <- typeOf ctx t1
  ty2 <- typeOf ctx t2
  Right (TyProd ty1 ty2)

--   T_Fst                 T_Snd
--   Gamma |-- t0          Gamma |-- t0
--   \in T1 * T2           \in T1 * T2
--   ------------------    ------------------
--   Gamma |-- t0.fst      Gamma |-- t0.snd
--      \in T1                \in T2
typeOf ctx t@(TmFst t0) = do
  ty0 <- typeOf ctx t0
  case ty0 of 
    TyProd ty1 _ -> Right ty1
    _ ->  Left (NotAPair ty0 t)
typeOf ctx (TmSnd t0) = do
  ty0 <- typeOf ctx t0
  case ty0 of 
    TyProd _ ty2 -> Right ty2
    _ ->  Left (NotAPair ty0 t)



-- TODO
--   T_Let                                    
--   Gamma |-- t1 \in T1                     
--   Gamma, x:T1 |-- t2 \in T2                
--   ---------------------------------       
--   Gamma |-- let x = t1 in t2 \in T2
typeOf ctx (TmLet x t1 t2)  = do
  ty1 <- typeOf ctx t1
  ctx' <- ...


-- TODO
--   T_Fix
--   Gamma |-- t1 \in T1 -> T1
--   -------------------------
--   Gamma |-- fix t1 \in T1
--
typeOf ctx t@(TmFix t1) = do
  ty1 <- typeOf ctx t1
  case ty1 of
    TyArrow ty2 ty3 -> 
      if ty2 == ty3   
        then
        else Left (Mismatch expected actual ty2)
    _ -> NotAFunction ty1 t

--   T_Nil                                    
--   -------------------------------          
--   Gamma |-- nil T1 \in List T1             
--
typeOf ctx (TmNil ty) = Right TyList ty
  

--   T_Cons
--   Gamma |-- t1 \in T1
--   Gamma |-- t2 \in List T1
--   -----------------------------
--   Gamma |-- t1 :: t2 \in List T1
typeOf ctx (TmCons t1 t2)     = do
  ty1 <- typeOf t1 -- Descubro o tipo do elemento sendo concatenado
  expect ctx (TyList ty1) t2 -- A lista (t2) deve ser uma lista do tipo ty1
  Right (TyList ty1) -- se tudo bateu, só retorno o tipo da lista

--   T_Lcase
--   Gamma |-- t1 \in List T1    Gamma |-- t2 \in T2
--   Gamma, x1:T1, x2:List T1 |-- t3 \in T2
--   ------------------------------------------------------------
--   Gamma |-- case t1 of | nil => t2 | x1 :: x2 => t3 \in T2
--
--typeOf ctx t@TmLcase{}          = Left (NotImplemented ("typeOf: TmLcase in " ++ ppTerm t))




-- ---------------------------------------------------------------------------
-- Error messages
-- ---------------------------------------------------------------------------

renderTypeError :: TypeError -> String
renderTypeError err = case err of
  UnboundVariable x ->
    "unbound variable `" ++ unIdent x ++ "'"
  Mismatch expected actual t ->
    "type mismatch in `" ++ ppTerm t ++ "'\n" ++
    "    expected: " ++ ppType expected ++ "\n" ++
    "      actual: " ++ ppType actual
  NotAFunction ty t ->
    "`" ++ ppTerm t ++ "' has type " ++ ppType ty ++ ", which is not a function type"
  NotAPair ty t ->
    "`" ++ ppTerm t ++ "' has type " ++ ppType ty ++ ", which is not a product type"
  NotAList ty t ->
    "`" ++ ppTerm t ++ "' has type " ++ ppType ty ++ ", which is not a list type"
  BranchMismatch ty1 ty2 t ->
    "branches of `" ++ ppTerm t ++ "' disagree:\n" ++
    "    first branch : " ++ ppType ty1 ++ "\n" ++
    "    second branch: " ++ ppType ty2
  NotImplemented what ->
    "not implemented yet -- " ++ what
