(>.>) :: (t -> u) -> (u -> v) -> (t -> v)
g >.> f = f . g


twice :: (t -> t) -> (t -> t)
twice f = f . f


iter :: Int -> (t -> t) -> (t -> t)
iter 0 f = id
iter n f = f >.> iter (n-1) f


addNum :: Int -> (Int -> Int)
addNum n = h
    where
    h m = n + m


addNum' :: Int -> (Int -> Int)
addNum' n = (\m -> n+m)


comp2 :: (t -> u) -> (u -> u -> v) -> (t -> t -> v)
comp2 f g = (\x y -> g (f x) (f y))


f :: t -> u -> v
f = undefined
g ::  u -> t -> v
g  = \ a b -> f b a 


multiply :: Int -> Int -> Int
multiply a b = a*b


doubleList :: [Int] -> [Int]
doubleList = map (multiply 2)


getEvens = filter ((==0).(`mod` 2))

books db per = map snd (filter ((==per).fst) db

