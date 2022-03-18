	/*
	Ce programme met en oeuvre l'algorithme Minmax (avec convention
	negamax) et l'illustre sur le jeu du TicTacToe (morpion 3x3)
	*/
	
:- ['tictactoe'].


	/****************************************************
  	ALGORITHME MINMAX avec convention NEGAMAX : negamax/5
  	*****************************************************/

	/*
	negamax(+J, +Etat, +P, +Pmax, [?Coup, ?Val])

	SPECIFICATIONS :

	retourne pour un joueur J donne, devant jouer dans
	une situation donnee Etat, de profondeur donnee P,
	le meilleur couple [Coup, Valeur] apres une analyse
	pouvant aller jusqu'a la profondeur Pmax.

	Il y a 3 cas a decrire (donc 3 clauses pour negamax/5)
	
	1/ la profondeur maximale est atteinte : on ne peut pas
	developper cet Etat ; 
	il n'y a donc pas de coup possible a jouer (Coup = rien)
	et l'evaluation de Etat est faite par l'heuristique.

	2/ la profondeur maximale n'est pas  atteinte mais J ne
	peut pas jouer ; au TicTacToe un joueur ne peut pas jouer
	quand le tableau est complet (totalement instancie) ;
	il n'y a pas de coup a jouer (Coup = rien)
	et l'evaluation de Etat est faite par l'heuristique.

	3/ la profondeur maxi n'est pas atteinte et J peut encore
	jouer. Il faut evaluer le sous-arbre complet issu de Etat ; 

	- on determine d'abord la liste de tous les couples
	[Coup_possible, Situation_suivante] via le predicat
	 successeurs/3 (deja fourni, voir plus bas).

	- cette liste est passee a un predicat intermediaire :
	loop_negamax/5, charge d'appliquer negamax sur chaque
	Situation_suivante ; loop_negamax/5 retourne une liste de
	couples [Coup_possible, Valeur]

	- parmi cette liste, on garde le meilleur couple, c-a-d celui
	qui a la plus petite valeur (cf. predicat meilleur/2);
	soit [C1,V1] ce couple optimal. Le predicat meilleur/2
	effectue cette selection.

	- finalement le couple retourne par negamax est [Coup, V2]
	avec : V2 is -V1 (cf. convention negamax vue en cours).

A FAIRE : ECRIRE ici les clauses de negamax/5
.....................................
	*/

negamax(J, Etat, Pmax, Pmax, [_, Val]) :-
	!,
	heuristique(J,Etat,Val),
	write("!!!!!!!!!!!!!!!!!!!!!\n").
/*negamax(J, Etat, _, _, [[], Val]) :-
	situation_terminale(J,Etat),
	heuristique(J,Etat,Val),
	!.
negamax(J, Etat, _, _, _) :-
	heuristique(J,Etat,Val),
	10000 is abs(Val),
	!.*/
negamax(J, Etat, _, _, [_, Val]) :-
	situation_terminale(J,Etat), !;
	alignement_gagnant(Etat, J), !;
	alignement_perdant(Etat, J), !;
	heuristique(J, Etat, Val).


negamax(J, Etat, P, Pmax, [Coup, Val]) :-
	successeurs(J, Etat, Succ),
	loop_negamax(J,P,Pmax,Succ, Res),
	meilleur(Res, [Coup, V1]),
	Val is -V1.

	%:- joueur_initial(J), situation_initiale(E), negamax(J,E,0,3,[C,V]).

	/*******************************************
	 DEVELOPPEMENT D'UNE SITUATION NON TERMINALE
	 successeurs/3 
	 *******************************************/

	 /*
   	 successeurs(+J,+Etat, ?Succ)

   	 retourne la liste des couples [Coup, Etat_Suivant]
 	 pour un joueur donne dans une situation donnee 
	 */

successeurs(J,Etat,Succ) :-
	findall([[L,C],Etat],
		    successeur(J,Etat,[L,C]),
		    Succ).

	/*************************************
         Boucle permettant d'appliquer negamax 
         a chaque situation suivante :
	*************************************/

	/*
	loop_negamax(+J,+P,+Pmax,+Successeurs,?Liste_Couples)
	retourne la liste des couples [Coup, Valeur_Situation_Suivante]
	a partir de la liste des couples [Coup, Situation_Suivante]
	*/

loop_negamax(_,_, _  ,[],                []).
loop_negamax(J,P,Pmax,[[Coup,Suiv]|Succ],[[Coup,Vsuiv]|Reste_Couples]) :-
	loop_negamax(J,P,Pmax,Succ,Reste_Couples),
	adversaire(J,A),
	Pnew is P+1,
	write(Suiv),
	write("\n\n"),
	negamax(A,Suiv,Pnew,Pmax, [_,Vsuiv]). % Cette ligne permet d'obtenir la valeur du coup suivant

	/*

A FAIRE : commenter chaque litteral de la 2eme clause de loop_negamax/5,
	en particulier la forme du terme [_,Vsuiv] dans le dernier
	litteral 
	*/

	/*********************************
	 Selection du couple qui a la plus
	 petite valeur V 
	 *********************************/

	/*
	meilleur(+Liste_de_Couples, ?Meilleur_Couple)

	SPECIFICATIONS :
	On suppose que chaque element de la liste est du type [C,V]
	- le meilleur dans une liste a un seul element est cet element
	- le meilleur dans une liste [X|L] avec L \= [], est obtenu en comparant
	  X et Y,le meilleur couple de L 
	  Entre X et Y on garde celui qui a la petite valeur de V.

A FAIRE : ECRIRE ici les clauses de meilleur/2
	*/

meilleur_coup([[C,V]], [C, V]) :- !.
meilleur_coup([[C,V] | Ls], [C1,V1]) :-
	meilleur_coup(Ls, [C2,V2]),
	(V < V2 ->
	 	C1 = C,
		V1 = V
	; 	C1 = C2,
		V1 = V2).

meilleur(Liste_de_Couples, Meilleur_Couple) :-
	meilleur_coup(Liste_de_Couples,Meilleur_Couple).

:-  meilleur([[[1,1],2],[[2,3],1],[[3,3],3]], [[2,3],1]).
:-  meilleur([[[1,1],-2],[[2,3],1],[[3,3],3]], [[1,1],-2]).

	/******************
  	PROGRAMME PRINCIPAL
  	*******************/

main(B,V, Pmax) :-
	joueur_initial(J),
	situation_initiale(M),
	%situation_test5(M),
	negamax(J, M, 0, Pmax, [B, V]).        


	/*
A FAIRE :
	Compl�ter puis tester le programme principal pour plusieurs valeurs de la profondeur maximale.
	Pmax = 1, 2, 3, 4 ...
	Commentez les r�sultats obtenus.
	*/

