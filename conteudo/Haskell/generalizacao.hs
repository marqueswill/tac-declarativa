doubleList xs = map times2 xs
       where times2 x = x*2


sqrList xs = map sqr xs
    where sqr x = x*x


snds :: [(t,u)] -> [u]
snds xs = map snd xs

sales :: Int -> Int
sales n = n

total :: (Int->Int)-> Int -> Int
total f 0 = f 0
total f n = total f (n-1) + f n

totalSales n = total sales n

sumSquares :: Int -> Int
sumSquares n = total sq n
    where sq x = x*x


maxi :: Int -> Int -> Int
maxi a b | a > b = a
         | otherwise = b


maxFun :: (Int -> Int) -> Int -> Int
maxFun f 0 = f 0
maxFun f n = maxi (maxFun f(n-1)) (f n)


zeroInRange :: (Int -> Int) -> Int -> Bool
zeroInRange f 0 = (f 0 == 0)
zeroInRange f n = zeroInRange f (n-1) || (f n == 0)


maxSales :: Int -> Int
maxSales n | n == 0 = sales 0
           | n > 0 = maxi(maxSales (n-1)) (sales n)

maxSales2 :: (Int -> Int) -> Int -> Int
maxSales2 f 0 = f 0
maxSales2 f n = maxi (maxSales2 f(n-1)) (f n)


isCrescent :: (Int -> Int) -> Int -> Bool
isCrescent f 0 = True
isCrescent f n | (n > 0) && ( f n > f (n-1)) = isCrescent f (n-1)
               | n < 0 = False


fold :: (t -> t -> t) -> [t] -> t
fold f [a] = a
fold f (a:as) = f a (fold f as)

{- foldr ja existe no Predude do Haskell entao 
   damos novo nome abaixo  -}
foldr':: (t -> u -> u) -> u -> [t] -> u
foldr' f s [] = s
foldr' f s (a:as) = f a (foldr' f s as)


sumList = fold (+)

subList = fold (-)


and :: [Bool] -> Bool
and xs = fold (&&) xs

concat :: [[t]] -> [t]
concat xs = fold (++) xs

maximum :: [Int] -> Int
maximum xs = fold maxi xs


concat' :: [[t]] -> [t]
concat' xs = foldr (++) [] xs

and' :: [Bool] -> Bool
and' bs = foldr (&&) True bs

{- foldl ja existe no Predude do Haskell entao 
   damos novo nome abaixo  -}
foldl':: (u -> t -> u) -> u -> [t] -> u
foldl' f s [] = s
foldl' f s (a:as) = (foldl' f (f s a) as)




filter' :: (t -> Bool) -> [t] -> [t]
filter' p [] = []
filter' p (a:as)
    | p a = a : filter' p as
    | otherwise = filter' p as

digits st = filter' isDigit st
    where isDigit x = x>='0' && x<='9'

letters st = filter' isLetter st
    where isLetter x = (x>='a' && x<='z') || (x>='A' && x<='Z')


filter'' p l = [a | a <- l, p a]

evens xs = filter' isEven xs
    where isEven n = (n `mod` 2 == 0)


sumSquare :: [Int] -> Int
sumSquare l = fold (+) (square  l)
    where square = map (^2)


positives :: [Int] -> [Int]
positives l = filter isPositive l
     where isPositive x = x > 0


zip2 :: [t] -> [u] -> [(t,u)]
zip2 (a:as) (b:bs) = (a,b):zip2 as bs
zip2 (a:as) [] = []
zip2 [] (b:bs) = []
zip2 [] [] = []


rev [] = []
rev (a:as) = rev as ++ [a]


rep 0 ch = []
rep n ch = ch : rep (n-1) ch


type Person = String
type Book = String
type Database = [(Person, Book)]

exampleBase = [("Alice", "Postman Pat"), 
               ("Anna", "All Alone"),
               ("Alice","Spot"), 
               ("Rory", "Postman Pat")]


books :: Database -> Person -> [Book]
books db per = map snd (filter isPer db)
    where isPer (p,b) = (p == per)


returnLoan :: Database -> Person -> Book -> Database
returnLoan db p b = filter notPB db
    where notPB pr = (pr /= (p,b))





