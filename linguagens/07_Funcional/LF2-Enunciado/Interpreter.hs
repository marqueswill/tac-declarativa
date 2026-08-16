module Interpreter where

import AbsLF
import Tests
import Prelude hiding (lookup)

{- TODO: Estude a definição do tipo Function no arquivo AbsLF.hs e complete as definicoes
    de "getParams" e "getExp" abaixo. Note "getName" já é fornecida.
-}
getName :: Function -> Ident
getName (Fun name _ _) = name

getParams :: Function -> [Ident]
getParams (Fun _ params _) = params

getExp :: Function -> Exp
getExp (Fun _ _ exp) = exp

--
{- TODO: *Não* altere a definição de "executeP" abaixo.
         *Entenda* a razão da mudança em relação à definição na LI2.
         Garanta que saiba explicar verbalmente isso.
-}

{-
O executP inicializa o contexto do programa mapeando cada função à sua definição e em seguida faz o eval do
expMain, que é a função principal do programa usando o contexto inicializado.

Na linguagem imperativa, uma função é definida por uma declaração (statement), já na funcional toda função é definida
por uma expressão. Isso significa que, no caso da LF1, não há necessidade de executar um statement para obter uma expressão ou
mais outras declarações, basta avaliar a expressão do main para que o eval avalie as subexpressões contidadas nele recursivamente.
-}

executeP :: Program -> Valor
executeP (Prog fs) =  eval initialContext (expMain fs)
    where
        initialContext = (updatecF [] fs)
        expMain (f:xs)
            | (getName f == (Ident "main")) =  getExp f
            | otherwise = expMain xs


eval :: RContext -> Exp -> Valor
eval context x = case x of
    ECon exp0 exp  -> ValorStr ( s (eval context exp0) ++  s (eval context exp) )
    EAdd exp0 exp  -> ValorInt ( i (eval context exp0)  +  i (eval context exp))
    ESub exp0 exp  -> ValorInt ( i (eval context exp0)  -  i (eval context exp))
    EMul exp0 exp  -> ValorInt ( i (eval context exp0)  *  i (eval context exp))
    EDiv exp0 exp  -> ValorInt ( i (eval context exp0) `div` i (eval context exp))
    EOr  exp0 exp  -> ValorBool ( b (eval context exp0)  || b (eval context exp))
    EAnd exp0 exp  -> ValorBool ( b (eval context exp0)  && b (eval context exp))
    ENot exp       -> ValorBool ( not (b (eval context exp)))
    EStr str       -> ValorStr str
    ETrue          -> ValorBool True
    EFalse         -> ValorBool False
    EInt n         -> ValorInt n
    EVar id        -> lookup context  id
{- TODO: remova "undefined" e implemente a avaliação do "EIf" abaixo. A primeira expressao ("exp") é a condição,
   "expT" é a expressão do "then" e "expE" é a expressão do "else". A semântica (comportamento)
   pretendido é o seguinte: compare o valor resultante da avaliação de "exp" com 0.
   se o valor for diferente de 0, retorna-se o resultado da avaliação da expressão expT;
   caso contrário, retorna-se o resultado da avaliação da expressão expE.
   @dica: estude a semântica do "SIf" na LI2 e saiba explicar a diferença -}
    EIf exp expT expE -> if (i (eval context exp) /= 0)
                            then eval context expT
                            else eval context expE

{- TODO: abaixo, troque "undefined" por chamadas das funcoes definidas no inicio do arquivo
    aplicadas ao argumento "funDef"  @dica: não altere o resto, mas saiba explicar o funcionamento -}
    ECall id lexp   -> eval (paramBindings ++ contextFunctions) (getExp funDef)
                          where (ValorFun funDef) = lookup context id
                                -- parametros da função chamada
                                parameters_ids =  getParams funDef

                                -- Avaliação das subexpressões presentes nos parâmetros da função
                                -- e associação do resultado destas com seus respesctivos ids
                                paramBindings = zip parameters_ids (map (eval context) lexp)

                                -- Contexto com apenas as definições das funções para otimizar e remover possíveis conflitos
                                contextFunctions = filter (\(i,v) -> case v of
                                                                         ValorFun _ -> True
                                                                         _ -> False
                                                           )
                                                          context



-- *** @dica: nao altere o todo o codigo abaixo a partir daqui

{-
data Valor = ValorInt Integer |
             ValorStr String
i (ValorInt vi) = vi
s (ValorStr vs) = vs
-}

data Valor = ValorInt {
               i :: Integer
             }
            |
             ValorFun {
               f :: Function
             }
            |
             ValorStr {
               s :: String
             }
            | ValorBool {
               b :: Bool
             }

instance Show Valor where
  show (ValorBool b) = show b
  show (ValorInt i) = show i
  show (ValorStr s) = s
  show (ValorFun f) = show f
--(\(Ident x) -> x) nf

type RContext = [(Ident,Valor)]

lookup :: RContext -> Ident -> Valor
lookup ((i,v):cs) s
   | i == s = v
   | otherwise = lookup cs s

update :: RContext -> Ident -> Valor -> RContext
update [] s v = [(s,v)]
update ((i,v):cs) s nv
  | i == s = (i,nv):cs
  | otherwise = (i,v) : update cs s nv


updatecF :: RContext -> [Function] -> RContext
updatecF c [] = c
updatecF c (f:fs) = updatecF (update c (getName f) (ValorFun f)) fs
