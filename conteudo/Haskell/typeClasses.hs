import Data.Char (chr, ord)

(>.>) :: (t -> u) -> (u -> v) -> (t -> v)
g >.> f = f . g

capitalize :: Char -> Char
capitalize ch = chr (ord ch + offset)
    where offset = ord 'A' - ord 'a'

length' :: [a] ->Int
length' [] = 0
length' (x:xs) = 1 + length xs

allEqual :: (Eq t) => t -> t -> t -> Bool
allEqual n m p = (n == m) && (m == p)

member :: (Eq t) => [t] -> t -> Bool
member [] b = False
member (a:as) b = (a==b) || member as b

class Visible t where
    toString :: t -> String
    size :: t -> Int

instance Visible Char where
    toString ch = [ch]
    size _ = 1

instance Visible Bool where
    toString True = "True"
    toString False = "False"
    size _ = 1

instance (Visible t) => Visible [t] where
    toString = map toString >.> concat
    size = map size >.> foldr (+) 0

rep 0 ch = []
rep n ch = ch : rep (n-1) ch

