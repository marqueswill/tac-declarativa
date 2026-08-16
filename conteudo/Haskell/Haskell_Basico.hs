square :: Int -> Int
square x = x * x


allEqual :: Int -> Int -> Int -> Bool
allEqual m n p =  (m == n) && (n == p)

casoTesteAllEqual_1 = allEqual 2 2 2 == True
casoTesteAllEqual_2 = allEqual 2 3 2 == False

resultadoCasosTesteAllEqual = foldl (&&) True [casoTesteAllEqual_1, casoTesteAllEqual_2]


maxi :: Int -> Int -> Int
maxi n m 
       | n >= m  = n
       | otherwise = m 
  
casoTesteMaxi_1 = maxi 2 3 == 3
casoTesteMaxi_2 = maxi 60 30 == 60
       
resultadoCasosTesteMaxi = foldl (&&) True [casoTesteMaxi_1, casoTesteMaxi_2]


fat ::  Int -> Int
fat  n
     | n == 0 = 1
     | n>0 = n * fat (n-1)

casoTesteFat_1 = fat 5 == 120
casoTesteFat_2 = fat 9 == 362880

resultadoCasosTesteFat = foldl (&&) True [casoTesteFat_1, casoTesteFat_2]


all4Equal :: Int -> Int -> Int -> Int -> Bool
--all4Equal a b c d  = (allEqual a b c) && (allEqual b c d)
all4Equal a b c d  = (allEqual a b c) && (c == d)
--all4Equal a b c d  =  (a == b) && (b == c) && (c == d)

casoTesteall4_1 = all4Equal 4 4 4 4 == True
casoTesteall4_2 = all4Equal 4 4 4 1 == False

resultadoCasosTesteAll4 = foldl (&&) True [casoTesteall4_1, casoTesteall4_2]


howManyEqual :: Int -> Int -> Int -> Int

howManyEqual a b c 
              | allEqual a b c = 3
              | (a == b) || (b == c) || (a == c) = 2
              | otherwise = 0

casoTesteHow_1 = howManyEqual 5 5 5 == 3
casoTesteHow_2 = howManyEqual 5 5 2 == 2

resultadoCasosTesteHow = foldl (&&) True [casoTesteHow_1, casoTesteHow_2]


sales :: Int -> Int 
sales n = n 


totalSales :: Int -> Int
totalSales 0 = sales 0
totalSales n
            | n > 0 = totalSales (n-1) +
                      sales n

casoTesteTSales_1 = totalSales 3 == 6
casoTesteTSales_2 = totalSales 10 == 55

resultadoCasosTesteTSales = foldl (&&) True [casoTesteTSales_1, casoTesteTSales_2]


maxSales :: Int -> Int
maxSales n
         | n == 0   = sales 0
         | n > 0    = maxi (maxSales (n-1))
                           (sales n)

casoTesteMaxSales_1 = maxSales 0 == 0
casoTesteMaxSales_2 = maxSales 5 == 5

resultadoCasosTesteMaxSales = foldl (&&) True [casoTesteMaxSales_1, casoTesteMaxSales_2]


maxSales' :: Int -> Int
maxSales' 0 = sales 0
maxSales' n = maxi (maxSales' (n-1)) (sales n)


totalSales' :: Int -> Int
totalSales' 0 = sales 0
totalSales' n = totalSales' (n-1) + sales n


myNot :: Bool -> Bool
myNot True = False
myNot False = True


myOr :: Bool -> Bool -> Bool
myOr True _ = True
myOr False x = x

casoTesteMyOr_1 = myOr True False == True
casoTesteMyOr_2 = myOr False False == False

resultadoCasosTesteMyOr = foldl (&&) True [casoTesteMyOr_1, casoTesteMyOr_2]


myAnd :: Bool -> Bool -> Bool
myAnd False x = False
myAnd True x = x


{-
Defina uma função que dado um valor
inteiro s e um número de semanas n retorna
quantas semanas de 0 a n tiveram venda
igual a s.
-}


funcao :: Int -> Int -> Int
funcao s 0 | sales 0 == s  = 1
           | otherwise = 0
funcao s n | n > 0 && sales(n) == s = 1 + funcao s (n-1)
           | n > 0  = funcao s (n-1)

casoTesteFsales_1 = funcao 7 3 == 0 
casoTesteFsales_2 = funcao 3 7 == 1

resultadoCasosTesteFsales = foldl (&&) True [casoTesteFsales_1, casoTesteFsales_2]


makeSpaces :: Int -> String
makeSpaces 0 = ""
makeSpaces n
          | n > 0 = " " ++ makeSpaces (n-1)
          
casoTesteMSpaces_1 = makeSpaces 3 == "   "
casoTesteMSpaces_2 = makeSpaces 2 == "  "

resultadoCasosTesteMSpaces = foldl (&&) True [casoTesteMSpaces_1, casoTesteMSpaces_2]


pushRight :: Int -> String -> String
pushRight n s = (makeSpaces n) ++ s

casoTestePush_1 = pushRight 3 "hello" == "   hello"
casoTestePush_2 = pushRight 2 "hello" == "  hello"
resultadoCasosTestePush = foldl (&&) True [casoTestePush_1, casoTestePush_2]          


averageSales :: Int -> Float
averageSales n = (fromIntegral (totalSales n)) / fromIntegral n


addPair :: (Int,Int) -> Int
addPair (x,y) = x+y


shift :: ((Int,Int),Int) -> (Int,(Int,Int))
shift ((x,y),z) = (x,(y,z))


type Name = String
type Age = Int
type Phone = Int
type Person = (Name, Age, Phone)


name :: Person -> Name
name (n,a,p) = n


sumSquares :: Int -> Int -> Int
sumSquares x y = sqX + sqY
	where 
	sqX = x * x
	sqY = y * y


sumSquares' :: Int -> Int -> Int
sumSquares' x y = sq x + sq y
	where sq z = z * z


sumSquares'' :: Int -> Int -> Int
sumSquares'' x y = let
	sqX = x * x
	sqY = y * y
	in sqX + sqY


oneRoot :: Float -> Float -> Float -> Float
oneRoot a b c = -b/(2.0*a)


twoRoots :: Float -> Float -> Float -> (Float, Float)
twoRoots a b c = (d-e, d+e)
	where
	d = -b/(2.0*a)
	e = sqrt(b^2-4.0*a*c)/(2.0*a)


roots :: Float -> Float -> Float -> String
roots a b c
	| b^2 == 4.0*a*c = show (oneRoot a b c)
	| b^2 > 4.0*a*c = show f ++ " " ++show s
	| otherwise = "no roots"
		where (f,s) = twoRoots a b c
