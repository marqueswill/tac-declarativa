module Optimizer where

import AbsLF
import Interpreter

optimizeProgram :: Program -> Program
optimizeProgram (Prog fs) = Prog (map optimizeFunction fs)

optimizeFunction :: Function -> Function
optimizeFunction (Fun tR id decls exp) = Fun tR id decls (optimizeExp exp)

optimizeExp :: Exp -> Exp
optimizeExp exp  = case exp of
                      EStr str -> EStr str
                      ETrue    -> ETrue
                      EFalse   -> EFalse
                      EInt n   -> EInt n
                      EVar id  -> EVar id
                      ENot exp -> 
                        let 
                            optExp  = optimizeExp  exp
                            optENot = ENot optExp 
                        in
                            if (isLiteral optExp)
                                then  valueToExp (eval [] optENot )
                                else  optENot

                      ECon exp0 exp -> optmizeBinExp ECon exp0 exp
                      EAdd exp0 exp -> optmizeBinExp EAdd exp0 exp
-- TODO: substitua "undefined" abaixo pela otimização correspondente ao tipo de expressão.
-- @dica: estude a implementação fornecida da otimização das expressões anteriores
                      ESub exp0 exp -> optmizeBinExp ESub exp0 exp
                      EMul exp0 exp -> optmizeBinExp EMul exp0 exp
                      EDiv exp0 exp -> optmizeBinExp EDiv exp0 exp
                      EOr  exp0 exp -> optmizeBinExp EOr exp0 exp
                      EAnd exp0 exp -> optmizeBinExp EAnd exp0 exp

-- TODO: saiba explicar o motivo da otimização abaixo
                      ECall id lexp   -> ECall id (map (\expr ->  optimizeExp expr) lexp)
-- TODO: crie um programa exemplo em que a otimização abaixo seja usada
                      EIf exp expT expE ->
                        let
                            optExp  = optimizeExp exp
                            optThen = optimizeExp expT
                            optElse = optimizeExp expE
                            optEIf  = EIf optExp optThen optElse
                        in
                            case optExp of
                                EInt vExpIf -> if (vExpIf == 0)
                                                    then optElse
                                                    else optThen
                                _              -> optEIf


isLiteral :: Exp -> Bool
isLiteral exp = case exp of
                        EStr  _        -> True
                        ETrue          -> True
                        EFalse         -> True
                        EInt  _        -> True
                        _              -> False

valueToExp :: Valor -> Exp
valueToExp (ValorInt i) = EInt i
valueToExp (ValorStr s) = EStr s
valueToExp (ValorBool True) = ETrue
valueToExp (ValorBool False) = EFalse

optmizeBinExp :: (Exp -> Exp -> Exp) -> Exp -> Exp -> Exp
optmizeBinExp expBinConst exp0 exp1 =
    let
        optExp0 = optimizeExp exp0
        optExp1 = optimizeExp exp1
        optBinExp = expBinConst optExp0 optExp1
    in
        if ((isLiteral optExp0) && (isLiteral optExp1))
            then valueToExp (eval [] optBinExp)
            else optBinExp
