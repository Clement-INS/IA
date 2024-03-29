%*******************************************************************************
%                                    AETOILE
%*******************************************************************************

/*
Rappels sur l'algorithme
 
- structures de donnees principales = 2 ensembles : P (etat pendants) et Q (etats clos)
- P est dedouble en 2 arbres binaires de recherche equilibres (AVL) : Pf et Pu
 
   Pf est l'ensemble des etats pendants (pending states), ordonnes selon
   f croissante (h croissante en cas d'egalite de f). Il permet de trouver
   rapidement le prochain etat a developper (celui qui a f(U) minimum).
   
   Pu est le meme ensemble mais ordonne lexicographiquement (selon la donnee de
   l'etat). Il permet de retrouver facilement n'importe quel etat pendant

   On gere les 2 ensembles de fa�on synchronisee : chaque fois qu'on modifie
   (ajout ou retrait d'un etat dans Pf) on fait la meme chose dans Pu.

   Q est l'ensemble des etats deja developpes. Comme Pu, il permet de retrouver
   facilement un etat par la donnee de sa situation.
   Q est modelise par un seul arbre binaire de recherche equilibre.

Predicat principal de l'algorithme :

   aetoile(Pf,Pu,Q)

   - reussit si Pf est vide ou bien contient un etat minimum terminal
   - sinon on prend un etat minimum U, on genere chaque successeur S et les valeurs g(S) et h(S)
	 et pour chacun
		si S appartient a Q, on l'oublie
		si S appartient a Pu (etat deja rencontre), on compare
			g(S)+h(S) avec la valeur deja calculee pour f(S)
			si g(S)+h(S) < f(S) on reclasse S dans Pf avec les nouvelles valeurs
				g et f 
			sinon on ne touche pas a Pf
		si S est entierement nouveau on l'insere dans Pf et dans Pu
	- appelle recursivement etoile avec les nouvelles valeurs NewPF, NewPs, NewQs

*/

%*******************************************************************************

:- ['avl.pl'].       % predicats pour gerer des arbres bin. de recherche   
:- ['taquin.pl'].    % predicats definissant le systeme a etudier

%*******************************************************************************
main :-
 	% initialisations S0, F0, H0, G0
 
 	initial_state5(S0),
 	G0 is 0,
 	heuristique(S0,H0),
 	F0 is G0 + H0,
 
 	% initialisations Pf, Pu et Q 
 
 	empty(Q),
 	empty(Pu0),
 	empty(Pf0),
 	insert([[F0,H0,G0],S0], Pf0, Pf),
 	insert([S0, [F0,H0,G0], nil, nil], Pu0, Pu),	
 
 	% lancement de Aetoile
 
 	aetoile(Pf,Pu,Q).

%*******************************************************************************
%

%*******************
%	AETOILE Program
%*******************

aetoile(nil, nil, _) :- write(" PAS de SOLUTION : L’ETAT FINAL N’EST PAS ATTEIGNABLE !"), !.
 
aetoile(Pf, Pu, Q) :- 
 	final_state(Final),
	suppress_min([[F,H,G],Final],Pf,_),
	suppress([Final,[F,H,G], Pere, A], Pu, _),
	insert([Final,[F,H,G], Pere, A],Q,Q1),
 	affiche_solution(Final, Q1, L),
	reverse(L, Solution, []),
	write(Solution),
	length(Solution,X),
	write("\n"),
	write(X),
	!.
 	
aetoile(Pf, Pu, Q) :-
	suppress_min([[F,H,G],U], Pf, Pfa),
	suppress([U,[F,H,G], Pere, A], Pu, Pua),
	expand(U, G, L),
	loop_successors(L, Pua, Pfa, Q, Pu1, Pf1),
	insert([U,[F,H,G],Pere, A], Q, Q1),
	aetoile(Pf1, Pu1, Q1).

%**************************************************
%	EXPAND : find all U's successors and their cost
%***************************************************

expand(U, G0, L) :-
	findall([Apres,[F,H,G], U, A],
	(rule(A,Count,U,Apres),
	heuristique2(Apres,H),
	G is G0 + Count,
	F is G + H), L).

:-initial_state(E), expand(E,0,[[[[a, b, c], [vide, h, d], [g, f, e]], [2, 1, 1], [[a, b, c], [g, h, d], [vide, f,e]], up], [[[a, b, c], [g, h, d], [f, vide, e]], [4, 3, 1], [[a, b, c], [g, h,d], [vide,f,e]], right]] ).

%*********************************************************
%	LOOP_SUCCESSORS : deal with each successor in the avls
%*********************************************************

loop_successors([], Pu, Pf, _, Pu, Pf).

loop_successors([[U, _, _, _] | Ss], Pu, Pf, Q, Pu2, Pf2) :-
	belongs([U, _, _, _], Q),!,
	loop_successors(Ss, Pu, Pf, Q, Pu2, Pf2).

loop_successors([[U,[F,H,G], Pere, A] | Ss] , Pu, Pf, Q, Pu3, Pf3) :-
	belongs([U,[F0,H0,G0],Pere1, A1],Pu),
	(F < F0 ->
		suppress([[F0,H0,G0],U],Pf,Pf1),
		suppress([U,[F0,H0,G0],Pere1, A1],Pu,Pu1),
		insert([[F,H,G], U], Pf1, Pf2),
		insert([U,[F,H,G], Pere, A], Pu1, Pu2),
		loop_successors(Ss, Pu2, Pf2, Q, Pu3, Pf3)
	;	loop_successors(Ss, Pu, Pf, Q, Pu3, Pf3)
	),
	!.

loop_successors([[U,[F,H,G],Pere, A] | Ss], Pu, Pf, Q, Pu3, Pf3) :-
	insert([U,[F,H,G],Pere, A], Pu, Pu2),
	insert([[F,H,G], U], Pf, Pf2),
	loop_successors(Ss, Pu2, Pf2, Q, Pu3, Pf3).

%*********************************************************************************************
%	AFFICHE SOLUTION : return the solution with the states and action that have been done in L
%*********************************************************************************************

affiche_solution(nil, _, []).

affiche_solution(U, Q, [[U,A] | L]) :-
	belongs([U, [F,H,G], Pere, A], Q),
	suppress([U, [F,H,G], Pere, A], Q, Q1),
	affiche_solution(Pere, Q1, L).

%********************************************************************************************
%	REVERSE: reverse a list, used to get the solution from the list given by affiche_solution
%********************************************************************************************

reverse([],L,L).

reverse([H|T],L,Acc) :- reverse(T,L,[H|Acc]).


%************************************************************
%	TESTS: test expand and loop_successors on different cases
%************************************************************

tests() :-
	% initialisations S0, F0, H0, G0

	initial_state(S0),
	G0 is 0,
	heuristique2(S0,H0),
	F0 is G0 + H0,

	% initialisations Pf, Pu et Q 

	empty(Q),
	empty(Pu0),
	empty(Pf0),
	insert([[F0,H0,G0],S0], Pf0, Pf),
	insert([S0, [F0,H0,G0], nil, nil], Pu0, Pu),
	suppress_min([[F0,H0,G0],S0], Pf, Pf1),
	suppress([S0, [F0,H0,G0], nil, nil], Pu, Pu1),
	aetoile(Pf1,Pu1,Q).
	/*

	expand(S0,G0,L),

	% Basic Test
	% loop_successors(L, Pu, Pf, Q, Pu1, Pf1),
	% put_flat(Pu1),
	% write("\n\n"),
	% put_flat(Pf1).

	%Test S in Q
	%insert([[[a,b,c],[g,h,d],[f,vide,e]],[4,3,1],[[a,b,c],[g,h,x],[vide,f,e]],right],Q,Q1),
	%loop_successors(L, Pu, Pf, Q1, Pu1, Pf1),
	%put_flat(Pu1),
	%write("\n\n"),
	%put_flat(Pf1).

	% Test with S in Pu wiht F0 > F
	%insert([[[a,b,c],[g,h,d],[f,vide,e]],[5,2,1],[[a,b,c],[g,h,d],[vide,f,e]],left],Pu,Pu2),
	%insert([[5,2,1],[[a,b,c],[g,h,d],[f,vide,e]]],Pf,Pf2),
	%loop_successors(L, Pu2, Pf2, Q, Pu1, Pf1),
	%put_flat(Pu1),
	%write("\n\n"),
	%put_flat(Pf1).

	% Test with S in Pu wiht F0 < F
	 insert([[[a,b,c],[g,h,d],[f,vide,e]],[3,2,1],[[a,b,c],[g,h,d],[vide,f,e]],left],Pu,Pu2),
	 insert([[3,2,1],[[a,b,c],[g,h,d],[f,vide,e]]],Pf,Pf2),
	 loop_successors(L, Pu2, Pf2, Q, Pu1, Pf1),
	 put_flat(Pu1),
	 write("\n\n"),
	 put_flat(Pf1).
	*/
