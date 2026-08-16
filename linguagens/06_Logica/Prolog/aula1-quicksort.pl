quicksort([ ], [ ]). 
quicksort([H | T], SORTED) :- partition(H, T, L, R), 
    quicksort(L, SORTEDL), 
    quicksort(R, SORTEDR), 
    append(SORTEDL, [H | SORTEDR], SORTED). 

partition(_, [], [], []). 
partition(X, [H | T], [H | L], R) :- H @=< X, partition(X, T, L, R). 

partition(X, [H | T], L, [H | R]) :- H @> X, partition(X, T, L, R). 

append([], L, L). 
append([H | L1], L2, [H | L3]) :- append(L1, L2, L3). 
