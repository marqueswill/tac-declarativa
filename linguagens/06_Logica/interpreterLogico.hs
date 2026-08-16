{-
parent Bob Alice
parent Bob Eve
parent Alice Charlie
father  x y <-  parent x y /\ male x
ancestor x y <- parent x y
ancestor x y <- parent x z /\ ancestor z y
male Bob
ancestor Bob w.
ancestor Bob Charlie.
ancestor k Charlie.
-}

import Prelude hiding (lookup)
import Debug.Trace


bob = FPObj (Obj "Bob")
charlie = FPObj (Obj "Charlie")
eve = FPObj (Obj "Eve")
alice = FPObj (Obj "Alice")
emma = FPObj (Obj "Emma")
--          [ F "parent" [charlie,emma]],
--          [ F "father" [x,y] , F "parent" [x,y] , F "male" [x] ],
--          [ F "male" [bob] ],
prog1 = [
         [ F "parent" [bob,eve]],
         [ F "parent" [eve, charlie]],
         [ F "parent" [bob,alice]],
         [ F "ancestor" [x,y] , F "parent" [x,y] ],
         [ F "ancestor" [x,y] , F "parent" [x,z], F "ancestor" [z,y] ]
        ]

q9 = F "ancestor" [w, charlie]
q1 = F "ancestor" [bob, w]
q2 = F "ancestor" [bob, charlie]
q3 = F "ancestor" [bob, eve]
q4 = F "ancestor" [eve,bob]
q5 = F "parent" [bob,alice]
q6 = F "parent" [bob,x]
q7 = F "parent" [bob,w]
q8 = F "parent" [bob,charlie]
q99 = F "ancestor" [eve,w]
q66 = F "parent" [w,x]
q55 = F "parent" [w, charlie]
x = FPVar (Var "x")
y = FPVar (Var "y")
z = FPVar (Var "z")
w = FPVar (Var "w")


-- Abstract syntax
type  PrologProgram =  [Rule]
type  Rule = [Fact]
data Fact = F Name [FactParam]
data FactParam = FPVar Variable | FPObj Object deriving (Eq)
data Variable = Var Name  deriving (Eq)
data Object = Obj Name    deriving (Eq)
type Name = String




-- semantics
type Binding = [(Variable, FactParam)]
type Bindings = [Binding]

followsPF :: PrologProgram -> Fact -> Bindings
--followsPF program fact | trace ("          @" ++ show fact) False = undefined
followsPF program fact =  concatMap (followsFR program fact) program

followsFR :: PrologProgram -> Fact -> [Fact] -> Bindings
followsFR program fact rule =
   let headBinding = unify fact (head rule) in
                       if (headBinding == [])
                         then []
                         else followsPBA program headBinding  (tail rule)

followsPBA :: PrologProgram -> Binding -> [Fact] -> Bindings
--followsPBA program binding (hBodyFact:rBodyFacts) | trace (fm(show (applyBindings binding (hBodyFact:rBodyFacts)))) False = undefined
followsPBA _ binding [] = [binding]
followsPBA program binding (hBodyFact:rBodyFacts) =
     let r = followsPF program (applyBinding binding hBodyFact) in
      case r of
        [] -> []
        (_:_) -> foldl (\ac b-> ac +++ (followsPBA program (b <+> binding) rBodyFacts))
                       r r


---------- auxiliary functions  ----------
------------------------------------------

-- standard unification
unify :: Fact -> Fact -> Binding
unify (F n1 params1) (F n2 params2)
   | (n1 == n2) && (length params1 == length params2) = unifyParams [] params1 params2
   | otherwise = []

unifyParams :: Binding -> [FactParam] -> [FactParam] -> Binding
unifyParams acc []        []       = acc
unifyParams acc (p1:rps1) (p2:rp2) = let rup12 = unifyParam (bindParam acc p1) (bindParam acc p2) in
                                          case rup12 of
                                            [] -> []
                                            (_:_)-> unifyParams (rup12 <+> acc) rps1 rp2

unifyParam :: FactParam -> FactParam -> Binding
unifyParam (FPObj (Obj n1)) obj@(FPObj (Obj n2))
   | n1 == n2 =  [((Var "_dummy"), obj)]
   | otherwise = []
unifyParam obj@(FPObj (Obj _)) (FPVar var@(Var _)) = [(var, obj)]
unifyParam (FPVar var@(Var _)) obj@(FPObj (Obj _)) = [(var, obj)]
unifyParam (FPVar var1@(Var _)) var2@(FPVar (Var _)) = [(var1, var2)]

applyBindings :: Binding -> [Fact] -> [Fact]
applyBindings b lfs = map (applyBinding b) lfs
applyBinding :: Binding -> Fact -> Fact
applyBinding binding (F name params) = F name (map (bindParam binding) params)

bindParam :: Binding -> FactParam -> FactParam
bindParam binding obj@(FPObj (Obj _)) = obj
bindParam binding var@(FPVar (Var name)) = case lookup binding name of
                                              Just varObj -> varObj
                                              Nothing -> var
-- bindings' union
(+++) :: Bindings -> Bindings -> Bindings
(+++) = (++)
--bs1 +++ [] = []
--bs1 +++ bs2 = bs1 ++ bs2

-- bindings' reconcilation, first parameter overrides second in commnon binding pairs
(<++>) :: Bindings -> Bindings -> Bindings
bindings1 <++> bindings2 = [ b1 <+> b2 | b1 <- bindings1, b2 <- bindings2]

(<+>) :: Binding -> Binding -> Binding
b1 <+> b2 = b1 ++ (filter (\(v,_) -> not (elem v (map fst b1))) b2)


lookup :: Binding -> Name -> Maybe FactParam
lookup [] _ = Nothing
lookup ((Var n, factParam):restBinding) name
  | n == name = Just factParam
  | otherwise = lookup restBinding name

lookupDeep :: Bindings -> Name -> [String]
lookupDeep bindings name = map (\binding -> lookupObjectBottom binding name) bindings
lookupObjectBottom :: Binding -> Name -> String
lookupObjectBottom binding name = case (lookup binding name) of
                                  Just factParam -> case factParam of
                                                     (FPVar (Var nv)) -> show (lookupObjectBottom binding nv)
                                                     (FPObj obj) -> show obj
                                  Nothing -> ""

fm :: String -> String
fm s =  "\n                 :-" ++ take (length (tail s) - 1)  (tail s)

instance Show Fact where
  show (F n fprms) = n ++ show fprms
instance Show Variable where
  show (Var n) = n

instance Show Object where
  show (Obj n) = n

instance Show FactParam where
  show (FPVar v) = show v
  show (FPObj o) = show o
