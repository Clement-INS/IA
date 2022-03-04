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

% main :-
% 	% initialisations S0, F0, H0, G0
% 
% 	initial_state(S0),
% 	G0 is 0,
% 	heuristique2(S0,H0),
% 	F0 is G0 + H0,
% 
% 	% initialisations Pf, Pu et Q 
% 
% 	empty(Q),
% 	empty(Pu0),
% 	empty(Pf0),
% 	insert([[F0,H0,G0],S0], Pf0, Pf),
% 	insert([S0, [F0,H0,G0], nil, nil], Pu0, Pu),
	
% 
% 	% lancement de Aetoile
% 
% 	% aetoile(Pf,Pu,Q).

%*******************************************************************************
% 
 aetoile(nil, nil, _) :- write(" PAS de SOLUTION : L’ETAT FINAL N’EST PAS ATTEIGNABLE !").
% 
% aetoile(Pf,Pu,Q) :- 
% 	final_state(F),
% 	suppress_min(F,Pf,_),
% 	affiche_solution().
% 	
% aetoile(Pf, Pu, Qs) :-
% 	suppress_min([[F,H,G],U],Pf,Pfa),
% 	suppress([U,[F,H,G],Pere, A],Pu,Pua),
% 	expand(U,Action,[F1,H1,G1], Apres, G),
%

expand(U, G0, L) :-
	findall([Apres,[F,H,G], U, A],
	(rule(A,Count,U,Apres),
	heuristique2(Apres,H),
	G is G0 + Count,
	F is G + H), L).


loop_successors([], Pu, Pf, _, _, Pu, Pf) :-
	put_flat(Pu),
	write("!!!!!\n").

% loop_successors(S | Ss, Pu, Pf, Q, F0, Pu2, Pf2) :-
% 	belongs(S,Q),
% 	loop_successors(Ss, Pu, Pf, Q, F0, Pu3, Pf3).
% 
% loop_successors([U,[F,H,G],Pere, A] | Ss , Pu, Pf, Q, F0, Pu2, Pf2) :-
% 	belongs([U,[_,_,_],_, _],Pu),
% 	(F < F0 ->
% 		suppress([U,[_,_,_],_,_],Pu,Pu1),
% 		suppress([[_,_,_],U],Pf,Pf1),
% 		insert([U,[F,H,G],Pere, A], Pu1, Pu2),
% 		insert([[F,H,G], U], Pf1, Pf2)
% 	),
% 	loop_successors(Ss, Pu2, Pf2, Q, F0, Pu3, Pf3).

loop_successors([[U,[F,H,G],Pere, A] | Ss], Pu, Pf, Q, F0, Pu3, Pf3) :-
	insert([U,[F,H,G],Pere, A], Pu, Pu2),
	insert([[F,H,G], U], Pf, Pf2),
	loop_successors(Ss, Pu2, Pf2, Q, F0, Pu3, Pf3).




affiche_solution() :- write("Solution existante").

test_loop_successors() :-
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

	expand(S0,G0,L),
	% write(L),
	loop_successors(L, Pu, Pf, Q, F0, Pu1, Pf1),
	put_flat(Pu1).
	% % write("\n\n"),
	% put_flat(Pu2).
	% put_flat(Pf2).
	
