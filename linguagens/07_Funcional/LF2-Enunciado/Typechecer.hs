module Typechecer where

import AbsLF
import Prelude hiding (lookup)
import PrintLF

data R a = OK a | Erro String
         deriving (Eq, Ord, Show, Read)

isError e = case e of
    OK _ -> False
    Erro _ -> True


type TContext = [(Ident,Type)]


test1 = Prog [Fun Tint (Ident "main") [] (ECall (Ident "fat") [EInt 5]),Fun Tint (Ident "fat") [Dec Tint (Ident "n")] (EIf (EVar (Ident "n")) (EMul (EVar (Ident "n")) (ECall (Ident "fat") [ESub (EVar (Ident "n")) (EInt 1)])) (EInt 1))]
test2 = Prog [Fun Tint (Ident "main") [] (ECall (Ident "fat") [EAdd (EInt 5) (EInt 1)]),Fun Tint (Ident "fat") [Dec Tint (Ident "n")] (EIf (EVar (Ident "n")) (EMul (EVar (Ident "n")) (ECall (Ident "fat") [ESub (EVar (Ident "n")) (EInt 1)])) (EInt 1))]

checkProgram :: Program  -> [R TContext]
checkProgram (Prog fs) = let nCtx = bindFunctions [] fs in
                          case nCtx of
                             OK ctx -> map (checkFunction ctx) fs
                             Erro msg -> [Erro msg]

{- TODO: na definição de "checkFunction" abaixo,substitua "undefined"
         pelo argumento relevante -}
checkFunction ::  TContext -> Function -> R TContext
checkFunction tc (Fun tR _ decls exp) = checkType (parameterTypeBindings ++ functionTypes) exp tR
                                        where parameterTypeBindings = map (\(Dec tp id) -> (id,tp)) decls
                                              functionTypes = filter (\(i,t) -> case t of
                                                                                 TFun _  _ -> True
                                                                                 _ -> False
                                                                      ) tc

{- "checkType" é uma função que dado, um contexto de tipos, uma expressão, e um tipo,
   verifica se essa expressão tem esse tipo ou retorna um erro se a expressão-
   for mal tipada -}
checkType :: TContext -> Exp -> Type -> R TContext
checkType tc exp tp = let r = inferType tc exp in
                          case r of
                             OK tipo -> if (tipo == tp )
                                           then OK tc
                                           else Erro ("@typechecker: a expressao "++ printTree exp ++ " tem tipo " ++
                                                     printTree tipo ++ " mas o tipo esperado eh "
                                                     ++ printTree tp)
                             Erro msg -> Erro msg


{- "inferType" é uma função que dado um contexto de tipos e uma expressão, retorna
   o tipo dessa expressão ou um erro se a expressão for mal tipada -}

inferType :: TContext -> Exp -> R Type
inferType tc x  =  case x of
    ECon exp0 exp  -> checkBinExp tc exp0 exp TStr
    EAdd exp0 exp  -> checkBinExp tc exp0 exp Tint
    ESub exp0 exp  -> checkBinExp tc exp0 exp Tint
    EMul exp0 exp  -> checkBinExp tc exp0 exp Tint
    EDiv exp0 exp  -> checkBinExp tc exp0 exp Tint
    EOr  exp0 exp  -> checkBinExp tc exp0 exp Tbool
    EAnd exp0 exp  -> checkBinExp tc exp0 exp Tbool
    ENot exp       -> let r = checkType tc exp Tbool in
                         case r of
                             OK _ -> OK Tbool
                             Erro msg -> Erro msg
    EStr str       -> OK TStr
    ETrue          -> OK Tbool
    EFalse         -> OK Tbool
    EInt n         -> OK Tint
    EVar id        -> lookup tc id
{- TODO: implemente a checagem de tipo para o "EIf" abaixo:
   "exp" deve ser inteiro (Tint), e os tipos de "expT" e "expE" devem ser iguais.
   @dica: estude a estrutura da checagem de tipo do "SIf" na LI2Tipada.
-}
    eIf@(EIf exp expT expE) ->
        case inferType tc exp of
            OK Tint ->
                case inferType tc expT of
                    OK t1 ->
                        case inferType tc expE of
                            OK t2 ->
                                if t1 == t2
                                then OK t1
                                else Erro "Tipo corpo expressão são diferentes"
                            Erro msg -> Erro (msg ++ " Erro na expressão: " ++ printTree expE)
                    Erro msg -> Erro (msg ++ " Erro na expressão: " ++ printTree expT)
            OK _ -> Erro ("Tipo da expressão if deve ser inteiro: " ++ printTree exp)
            Erro msg -> Erro (msg ++ " Erro na expressão: " ++ printTree exp)



-- TODO: sobre "ECall" abaixo, a lógica permanece a mesma em relação a LI2Tipada ? Por que?
-- Porque a forma das funções seguem o mesmo padrão de abstração: uma função recebe uma lista de parâmetros e executa o seu corpo
-- usando esses argumentos. Também é verificado se todos parâmetros exigidos foram passados.
-- Logo, em ambas versões é necessário checar o tipo dos parâmetros e comparar com o tipo dos argumentos passados para função

    ECall id lexp -> let r = lookup tc id in
                    case r of
                        OK (TFun tR pTypes) ->
                            if (length pTypes == length lexp)
                            then
                                if (isThereError tksArgs /= [])
                                then Erro " @typechecker: chamada de funcao invalida"
                                else OK tR
                            else Erro " @typechecker: tamanhos diferentes de lista de argumentos e parametros"

                            where   tksArgs = zipWith (checkType tc) lexp pTypes
                                    isThereError l = filter (==False)
                                                            (map (\e->(let r2 = e in
                                                                        case r2 of
                                                                            OK _ -> True
                                                                            Erro _ -> False))
                                                                l)
                        Erro msg -> Erro msg


{- *** @dica: nao altere o codigo abaixo até o final do arquivo***
              mas saiba explicar o que ele faz
-}

checkBinExp :: TContext -> Exp -> Exp -> Type -> R Type
checkBinExp tc exp1 exp2 tp = let r = checkType tc exp1 tp in
                                       case r of
                                          OK _ -> let r2 = checkType tc exp2 tp in
                                                     case r2 of
                                                         OK _ -> OK tp
                                                         Erro msg -> Erro msg
                                          Erro msg -> Erro msg


lookup :: TContext -> Ident -> R Type
lookup [] id = Erro ("@typechecker: " ++ printTree id ++ " nao esta no contexto. ")
lookup ((id,value):cs) key
   | id == key = OK value
   | otherwise = lookup cs key


bindType :: TContext -> Ident -> Type -> R TContext
bindType [] id tp = OK [(id,tp)]
bindType ((id,tp):idTps) idN tpN
  | id == idN = Erro ("@typechecker: identificador" ++ printTree id ++ " nao pode ter mais de um tipo")
  | otherwise = let r = (bindType idTps idN tpN) in
                  case r of
                    OK restOK -> OK ((id,tp) : restOK)
                    Erro msg -> Erro msg

getFunctionType :: Function -> Type
getFunctionType (Fun tipoRetorno _ decls _) = TFun tipoRetorno (map (\(Dec tp _ )-> tp) decls)

bindFunctions :: TContext -> [Function] -> R TContext
bindFunctions tc [] = OK tc
bindFunctions tc (f@(Fun _ nomeF _ _):fs) = let r = bindType tc nomeF (getFunctionType f) in
                                                   case r of
                                                     OK tcNew -> bindFunctions tcNew fs
                                                     Erro msg -> Erro msg
