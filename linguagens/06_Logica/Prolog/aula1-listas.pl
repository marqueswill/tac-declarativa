suffix(Xs, Ys) :-
    append(_, Ys, Xs).

prefix(Xs, Ys) :-
    append(Ys, _, Xs).

sublist(Xs, Ys) :-
    suffix(Xs, Zs),
    prefix(Zs, Ys).

nrev([], []).
nrev([H|T0], L) :-
	nrev(T0, T),
	append(T, [H], L).

/** <examples>

?- sublist([a, b, c, d, e], [c, d]).
?- sublist([a, b, c, d, e], Ys).
?- sublist(Xs, Ys).

?- numlist(1, 1000, _L), time(nrev(_L, _)).

*/

pertence(X,[X|_]).
pertence(X,[_|T]) :- pertence(X,T).

prefixo([],_).
prefixo([X|Xs],[X|Ys]) :- prefixo(Xs,Ys).

sufixo(L,L).
sufixo(Xs,[Y|Ys]) :- sufixo(Xs,Ys).

concatena([],L,L).
concatena([H|T],L1,[H|L2]) :- concatena(T,L1,L2).

inverte([],[]).
inverte([H|T],L) :- inverte(T,T1), concatena(T1,[H],L).

%%%% Com acumulador %%%%

inv(Xs,Ys) :- inv(Xs,[],Ys).
inv([X|Xs],Ac,Ys) :- inv(Xs,[X|Ac],Ys).
inv([],Ys,Ys).

