t(a, t(b, nil, nil), t(c, t(d, nil, nil), t(e, nil, nil))).

in(X,t(X,_,_)).
in(X,t(_,L,_)) :- in(X,L).
in(X,t(_,_,R)) :- in(X,R).

t(7, t(3, nil, nil), t(15, t(9, nil, nil), t(20, nil, nil))).

add(X,nil,t(X,nil,nil)).
add(X,t(Root,L,R),t(Root,L1,R)) :- X @< Root, add(X,L,L1).
add(X,t(Root,L,R),t(Root,L,R1)) :- X @> Root, add(X,R,R1).

abb(L,T) :- abb(L,T,nil).
abb([],T,T).
abb([N|Ns],T,T0) :- add(N,T0,T1), abb(Ns,T,T1).