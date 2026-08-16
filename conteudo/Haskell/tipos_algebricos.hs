import Data.Maybe (fromJust)
data Estacao = Inverno | Verao | Outono | Primavera

data Temp = Frio | Quente


clima :: Estacao -> Temp
clima Inverno = Frio
clima _ = Quente


type Name = String
type Age = Int

data People = Person Name Age

p1 = Person "Jose" 22
p2 = Person "Maria" 23

showPerson :: People -> String
showPerson (Person n a) = n ++ " -- " ++ show a

data Shape = Circle Float | Rectangle Float Float

isRound :: Shape -> Bool
isRound (Circle _) = True
isRound (Rectangle _ _) = False


area :: Shape -> Float
area (Circle r) = pi*r*r
area (Rectangle h w) = h * w

-- Tipos de dados recursivos
data Expr = Lit Int |
            Add Expr Expr |
            Sub Expr Expr

v1 = Lit 1   -- 1 
v2 = Add (Lit 1) (Lit 2)  -- 1 + 2
v3 = Sub v2 v1 -- (1+2) - 1
v4 = Sub (Add (Lit 1) (Lit 2)) (Lit 1) --  (1+2) - 1      

eval :: Expr -> Int
eval (Lit n) = n
eval (Add e1 e2) = eval e1 + eval e2
eval (Sub e1 e2) = eval e1 - eval e2

teste1 =  eval v1 == 1
teste2 =  eval v2 == 3
teste3 =  eval v3 == 2
teste4 =  eval v4 == 2
resultadoTeste = foldl (&&) True [teste1,teste2,teste3,teste4]

data Pairs t = Pair t t

data List t = Nil | Cons t (List t)
    deriving (Eq,Ord,Show)

data Tree t = NilT | Node t (Tree t) (Tree t)
    deriving (Eq,Ord,Show)

a1 = Node 1 NilT NilT
a2 = Node 2 a1 NilT
a3 = Node 3 (Node 4 a1 a1) a2
a4 = Node "hello" (NilT) (Node "world" NilT NilT)


showExpr :: Expr -> String
showExpr (Lit x) = show x
showExpr (Add x y) = "(" ++ showExpr x ++ "+" ++ showExpr y ++ ")"
showExpr (Sub x y) = "(" ++ showExpr x ++ "-" ++ showExpr y ++ ")"

teste1showExpr = showExpr v1 == "1"
teste2showExpr = showExpr v2 == "(1 + 2)"
teste3showExpr = showExpr v4 == "((1 + 2) - 1)"
resultadoTesteshoExpr = foldl (&&) True [teste1showExpr,teste2showExpr,teste3showExpr ]

mapTree :: (a -> b) -> Tree a -> Tree b
mapTree _ (NilT) = NilT
mapTree f (Node x lT rT) = Node (f x) (mapTree f lT) (mapTree f rT)

test1mapTree  = mapTree (+1) a1 == Node 2 NilT NilT
test2mapTree  = mapTree (*2) a2 == Node 4  (Node 2 NilT NilT)  NilT

depth :: Tree a -> Int
depth (NilT) = 0
depth (Node _ lT rT) = 1 + max (depth lT) (depth rT)

collapse :: Tree t -> [t]
collapse NilT = []
collapse (Node n left right) = (collapse left) ++ [ n ] ++ (collapse right)

saldo :: String -> [(String,Float)] -> Maybe Float
saldo _ [] = Nothing
saldo person ((p,s):pss)
    | person == p = Just s
    | otherwise = saldo person pss

f :: Float -> Float -> Float
f x y = x / y


f' :: Float -> Float -> Maybe Float
f' x y
    | y == 0 = Nothing
    | otherwise = Just $ x / y

fat :: Int -> Maybe Int
fat 0 = Just 1
fat n
    | n < 0 = Nothing
    | n > 0 = Just (n * (fromJust (fat (n-1))))
