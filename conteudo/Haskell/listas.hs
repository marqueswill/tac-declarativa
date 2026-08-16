sumlist :: [Int] -> Int
sumlist [] = 0
sumlist (a:as) = a + sumlist as


double :: [Int] -> [Int]
double [] = []
double (b:bs) = (2*b) : double bs


member :: [Int] -> Int -> Bool
member [] _ = False
member (x:xs) n
    | n == x = True
    | otherwise = member xs n

member' :: [Int] -> Int -> Bool
member' [] _ = False
member' (x:xs) y = (x==y) || member' xs y

digits :: String -> String
digits [] = ""
digits (x:xs)
    | x>='0' && x<='9' = x : digits xs
    | otherwise = digits xs


sumPairs :: [(Int,Int)] -> [Int]
sumPairs [] = []
sumPairs ((x,y):as) = (x+y) : sumPairs as 
-- teste:  sumPairs [(1,2),(3,4),(5,6)] = [3,7,11]
-- sumPairs (a:as) =  (fst a) + (snd a) : sumPairs as 


firstDigit :: String -> Char
firstDigit st = case (digits st) of
    [] -> '\0'
    (a:as) -> a


zip2 :: [t] -> [u] -> [(t,u)]
zip2 (a:as) (b:bs) = (a,b):zip2 as bs
zip2 (a:as) [] = []
zip2 [] (b:bs) = []
zip2 [] [] = []


type Person = String
type Book = String
type Database = [(Person, Book)]

exampleBase = [("Alice", "Postman Pat"), 
               ("Anna", "All Alone"),
               ("Alice","Spot"), 
               ("Rory", "Postman Pat")]

books :: Database -> Person -> [Book]
books [] _ = []
books ((x,y):as) p 
     | x == p = y : books as p
     | otherwise = books as p 


borrowers :: Database -> Book -> [Person]
borrowers [] _ = []
borrowers ((p,l):pls) liv
    |liv==l = p:borrowers pls liv
    |otherwise = borrowers pls liv


borrowed :: Database -> Book -> Bool
borrowed db b = if borrowers db b == [] then False else True


numBorrowed :: Database -> Person -> Int
numBorrowed [] _ = 0
numBorrowed ((p,l):pls) per
    |per==p = 1 + numBorrowed pls per
    |otherwise = numBorrowed pls per


makeLoan  ::  Database -> Person -> Book -> Database
makeLoan db p b =  (p,b) : db

makeLoan2  ::  Database -> Person -> Book -> Database
-- cada pessoa so pode emprestar um livro no maximo uma vez
makeLoan2 [] p b = [(p,b)]
makeLoan2 ((p,l):dbs) pessoa livro 
    | (p,l) == (pessoa,livro) = dbs
    | otherwise = (p,l) : (makeLoan2 dbs pessoa livro)


returnLoan :: Database -> Person -> Book -> Database
returnLoan [] _ _ = []
returnLoan (db@(pe,bo):dbs) p b
    | pe==p && bo==b = dbs
    | otherwise = db : returnLoan dbs p b


isEven :: Int -> Bool
isEven n = mod n 2 == 0

doubleList :: [Int] -> [Int]
doubleList xs = [2*a|a <- xs]
doubleIfEven xs = [2*a|a <- xs, isEven a]


sumPairs2 :: [(Int,Int)] -> [Int]
sumPairs2 lp = [a+b|(a,b) <- lp]

digits2 :: String -> String
digits2 st = [ch | ch <- st, isDigit ch]
    where isDigit x = x>='0' && x<='9'

member2 :: [Int] -> Int -> Bool
member2 xs x = not $ null [y | y <- xs, y==x] 

books2 :: Database -> Person -> [Book]
books2 db p = [book | (person, book) <- db, person == p]

borrowers2 :: Database -> Book -> [Person]
borrowers2 db b = [person | (person, book) <- db, book==b]

borrowed2 :: Database -> Book -> Bool
borrowed2 db b = not $ null [book | (_, book) <- db, book==b]

returnLoan2 :: Database -> Person -> Book -> Database
returnLoan2 db p b = [e | e <- db, e /= (p,b)]


quickSort :: [Int] -> [Int]
quickSort [] = []
quickSort (x:xs) = quickSort [e | e <- xs, e <= x] ++ [x] ++ quickSort [e | e <- xs, e > x]
