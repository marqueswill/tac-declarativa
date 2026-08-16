%% Aula-1 de Prolog
%% Disciplina: Linguagens de programação
%% Unb

%%%%%%%% Fatos %%%%%%%%%%%%

pai(joão, pedro).
pai(joão, henrique).
pai(pedro, clara).
pai(pedro, clarissa).

mãe(maria, pedro).
mãe(maria, henrique).
mãe(luisa, clara).
mãe(luisa, clarissa).

homem(joão).
homem(pedro).
homem(henrique).

mulher(clara).
mulher(clarissa).
mulher(luisa).

%%%%%%%% Relacionamentos (Regras) %%%%%%%%%%%%

filho(X, Y) :- pai(Y, X), homem(X).
filho(X, Y) :- mãe(Y, X), homem(X).

filha(X, Y) :- pai(Y, X), mulher(X).
filha(X, Y) :- mãe(Y, X), mulher(X).

avô(X, Y) :- pai(X, Z), pai(Z, Y).
avô(X, Y) :- pai(X, Z), mãe(Z, Y).

avó(X, Y) :- mãe(X, Z), pai(Z, Y).
avó(X, Y) :- mãe(X, Z), mãe(Z, Y).

%%%%%%%% Alternativa %%%%%%%%%%%%

parente(X, Y) :- pai(X, Y).
parente(X, Y) :- mãe(X, Y).

filho(X, Y) :- parente(Y, X), homem(X).
filha(X, Y) :- parente(Y, X), mulher(X).

avô(X, Y) :- pai(X, Z), parente(Z, Y).
avó(X, Y) :- mãe(X, Z), parente(Z, Y).

/** <examples>
?- pai(joão, pedro).
?- mãe(maria, clara).
?- filho(pedro, X).
?- filha(clara, X).
?- avô(joão, X).
?- pai(X, pedro), X = gustavo.
*/