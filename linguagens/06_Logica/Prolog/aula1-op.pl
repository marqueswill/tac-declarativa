fib(0,0).
fib(1,1).
fib(N,X) :- N > 1, N1 is N-1, fib(N1,A), N2 is N-2, fib(N2,B), X is A+B.

/** <examples>
?- time(fib(5, Fib)).
*/

%%%%%%% Alternativa %%%%%%%%%%%%

fib(0, 1) :-
    !.
fib(N, F) :-
    fib(1, N, 1, 1, F).

fib(N, N, _, F, F) :-
    !.
fib(N0, N, F0, F1, F) :-
    N1 is N0 + 1,
    F2 is F0 + F1,
    fib(N1, N, F1, F2, F).

%%%%%% Fatorial %%%%%%%%%%%%%%%%

dif(N,1,M) :- M is N-1, N > 0.
prod(F,N,P) :- P is N*F.
fat(0,1).
fat(N,F) :-  dif(N,1,M) , fat(M,P), prod(P,N,F).



