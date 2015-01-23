MACHINE
	ESSUYAGE_AV

CONSTANTS
	
	VIT1,
	VIT2,
	MAX_VITESSE

SETS
	S_DMD_COMMODO_USER = {repos1, interm1, 1pv1, gv1, auto1}; repositorie
	
	S_DMD_COMMODO = {d_repos1, d_interm1, d_pv1, d_pv1, d_auto1}; 
	
	ETAT_COMMODO = {defaillant1, fonctionnel1}; /* etat de la commande*/
	
	TYPE_VITESSE = {ascendant1, descendant1}; /* etat de la variation de vitesse du vehicule */
	
	ALIMENTATION = {accessoire1, demarreur1, aucune1};
	/* etat de l'alimemtation (position de la clef) */
	
	ETAT_MOTEUR_ESS_AV = {mgv1, mgv1, arretFixeAv1, suspendu1, arretMaintenance1,mInter1,pv1cycle1, 
		gv3cycles1, protectionMoteur1, pv3cyclesLavage1, gv3cyclesLavage1};
	
	CDP = {pvCDP1, gvCDP1, arretCDP1};
	ETAT_CDP = {c_defaillant1,c_fonctionnel1};
	
	BOOLEAN = {false1, true1};
	T_INT_AV = {T_INT_AV_TRES_LENTE1, T_INT_AV_LENTE1, T_INT_AV_MOYENNE1, T_INT_AV_RAPIDE1, 
		T_INT_FIXE1, T_REDUC_PV_INT1}
	/* delais de temporisation de l'intermittence */
	
DEFINITIONS

	VITESSE == 0..MAX_VITESSE	
	
PROPERTIES

	VIT1 = 5		&
	VIT2 = 10		&
	MAX_VITESSE = 100	
	
VARIABLES
	dmd_commodo_user,
	dmd_commodo,
	etat_commodo,
	type_vitesse,
	vitesse_vehicule,
	alimentation,
	etat_moteur_ess_av,
	cdp,
	etat_cdp,
	t_int_av,
	depassement_temps_maintenance,
	seuil_depasse_vit2,
	seuil_depasse_vit1,
	t_perte_acc_depasse,
	presence_CDP

INVARIANT
	/* Typage des variables : */
	dmd_commodo_user : S_DMD_COMMODO_USER		&
	dmd_commodo : S_DMD_COMMODO			&
	etat_commodo : ETAT_COMMODO			&
	type_vitesse : TYPE_VITESSE			&
	vitesse_vehicule : VITESSE			&
	alimentation : ALIMENTATION			&
	etat_moteur_ess_av : ETAT_MOTEUR_ESS_AV		&
	cdp : CDP					&
	etat_cdp : ETAT_CDP                             &
	t_int_av : T_INT_AV				&
	depassement_temps_maintenance : BOOLEAN		&
	seuil_depasse_vit2 : BOOLEAN			&
	seuil_depasse_vit1 : BOOLEAN                    &
	t_perte_acc_depasse : BOOLEAN			&
	presence_CDP : BOOLEAN                          &
	(depassement_temps_maintenance = true1 => alimentation = aucune1)	&
	/* le temps de maintenance depasse implique qu'il n'y ait pas d'alimentation */
	(t_perte_acc_depasse = true1 => alimentation = aucune1)	&
	/*  Si t_perte_acc est depasse alors il n'y a pas d'alimentation */
	(alimentation = aucune1 => vitesse_vehicule = 0)	&
	/* Si l'alimentation est aucune alors la vitesse du vehicule doit etre nulle */
	(seuil_depasse_vit1 = true1 => seuil_depasse_vit2 = true1) &
	/* Si le seuil vit1 est dépassé alors le seuil de vit2 est dépassé */
        (seuil_depasse_vit2 = false1 => seuil_depasse_vit1 = false1) &
	/* Si le seuil vit2 n'est pas depasse alors le seuil vit1 ne l'est pas non plus */
	((dmd_commodo = d_repos1 or dmd_commodo = d_interm1 or dmd_commodo = d_auto1) => 
		(seuil_depasse_vit1 = false1 & seuil_depasse_vit2 = false1)) &
	(alimentation = aucune1 => etat_moteur_ess_av = arretFixeAv1 or etat_moteur_ess_av = 
		arretMaintenance1 or etat_moteur_ess_av = protectionMoteur1) &
	/* si une demande a été faite de repos, le moteur est soit en arretFixeAv1 
		soit en maintenance */
	(dmd_commodo = d_pv1 & seuil_depasse_vit2 = true1 & seuil_depasse_vit1 = true1 => 
		t_int_av = T_REDUC_PV_INT1) &
	/* Dans le cas où une demande petite vitesse a été demandée, que le seuil VIT2 a été 
		dépasse et que la vitesse est inférieure soit à VIT1 soit à VIT2 alors 
		la temportisation d'intertemittence est à T_REDUC_PV_INT1 */
	(t_int_av = T_REDUC_PV_INT1 => (vitesse_vehicule <= VIT2 & dmd_commodo = d_pv1)) &
	/* si l'intermittence est en réduction de petite vitesse à intermittence, alors 
		la vitesse du véhicule est inférieur à VIT2 et la demande du commodo est
		à petite vitesse */
	((vitesse_vehicule < 10 & type_vitesse = ascendant1 & t_int_av /= T_REDUC_PV_INT1 &
		t_int_av /= T_INT_FIXE1) => t_int_av = T_INT_AV_TRES_LENTE1) &
	((vitesse_vehicule >= 10 & vitesse_vehicule < 50 & type_vitesse = ascendant1 & 
		t_int_av /= T_REDUC_PV_INT1 & t_int_av /= T_INT_FIXE1) 
		=> t_int_av = T_INT_AV_LENTE1) &
	((vitesse_vehicule >= 50 & vitesse_vehicule < 90 & type_vitesse = ascendant1 & 
		t_int_av /= T_REDUC_PV_INT1 & t_int_av /= T_INT_FIXE1) 
		=> t_int_av = T_INT_AV_MOYENNE1) &
	((vitesse_vehicule >= 90 & type_vitesse = ascendant1 & t_int_av /= T_REDUC_PV_INT1 &
		t_int_av /= T_INT_FIXE1) => t_int_av = T_INT_AV_RAPIDE1) &
	/* temporisation de l'intermittence en fonction de la vitesse du véhicule en 
		vitesse ascendante */
	((vitesse_vehicule < 5 & type_vitesse = descendant1 & t_int_av /= T_REDUC_PV_INT1 & 
		t_int_av /= T_INT_FIXE1) => t_int_av = T_INT_AV_TRES_LENTE1) &
	((vitesse_vehicule >= 5 & vitesse_vehicule < 40 & type_vitesse = descendant1 & 
		t_int_av /= T_REDUC_PV_INT1 & t_int_av /= T_INT_FIXE1) 
		=> t_int_av = T_INT_AV_LENTE1) &
	((vitesse_vehicule >= 40 & vitesse_vehicule < 80 & type_vitesse = descendant1 & 
		t_int_av /= T_REDUC_PV_INT1 & t_int_av /= T_INT_FIXE1) 
		=> t_int_av = T_INT_AV_MOYENNE1) &
	((vitesse_vehicule >= 80 & type_vitesse = descendant1 & t_int_av /= T_REDUC_PV_INT1 &
		t_int_av /= T_INT_FIXE1) => t_int_av = T_INT_AV_RAPIDE1) &
	/* lorsque la temporisation est fixe, alors le moteur est en intermittence et soit 
		le capteur de pluie est défaillant, soit il n'est pas présent sur le véhicule */
	((t_int_av = T_INT_FIXE1 & alimentation = accessoire1) => ((etat_cdp = c_defaillant1 or
		presence_CDP = false1) & (dmd_commodo = d_auto1 or etat_commodo = defaillant1) &
		(etat_moteur_ess_av = mInter1 or etat_moteur_ess_av = protectionMoteur1 or 
		etat_moteur_ess_av = pv3cyclesLavage1))) &
	((t_int_av = T_INT_FIXE1 & alimentation /= accessoire1) => (etat_cdp = c_defaillant1 or
		 presence_CDP = false1) & (dmd_commodo = d_auto1 or etat_commodo = defaillant1)) &
	/*lorque le capteur de pluie est défaillant et qu'il y a une demande d'automatique 
		ou que le commodo est défaillant et que le capteur de pluie n'est pas present
		sur le véhicule, ou que le commodo est défaillant et que le capteur de pluie 
		est défaillant alors le moteur est en intermittence fixe */
	(((etat_cdp = c_defaillant1 & dmd_commodo = d_auto1) or (etat_commodo = defaillant1 & 
		(etat_cdp = c_defaillant1 or presence_CDP = false1))) => t_int_av = T_INT_FIXE1)  &
	((etat_commodo = defaillant1) => (seuil_depasse_vit2 = false1)) &
	/* Si on est en accessoire et en mode maintenance, alors la demande est mise à repos */
	((alimentation = accessoire1 & etat_moteur_ess_av = arretMaintenance1) => dmd_commodo = d_repos1)
	
INITIALISATION
	dmd_commodo_user := repos1 				||
	/* la demande commodo utilisateur est mis au repos */
	dmd_commodo := d_repos1					||
	/* la demande intermediaire de commande est mise au repos */
	etat_commodo := fonctionnel1				||
	vitesse_vehicule := 0					||
	/* A l'initialisation le vehicule est a l'arret */
	type_vitesse := ascendant1				||
	/* la variation de vitesse est mise a ascendant car la vitesse du vehicule est 0 */
	alimentation := aucune1					||
	etat_moteur_ess_av := arretFixeAv1			||
	/* le moteur d'essuie-glace est mis a arret fixe*/
	cdp := arretCDP1						||
	etat_cdp := c_fonctionnel1                               ||
	t_int_av := T_INT_AV_TRES_LENTE1				||
	/* la temporisation d'intermittence est mise a TRES_LENTE */ 
	depassement_temps_maintenance := true1			||
	/* permet de savoir si on a dépassé le temps limite de possibilité de mise en route
		de la maintenance */
	seuil_depasse_vit1 := false1 /* permet de savoir si VIT1 a été dépasse lorsqu'on est
		en pv ou gv */ ||
	seuil_depasse_vit2 := false1 ||	/*permet de savoir si VIT2 a été dépassé lorqu'on 
		est en pv ou gv */	
	t_perte_acc_depasse := true1 ||
	/* permet de savoir si on a dépassé le temps limite de sauvegarde de la demande 
		précédant la perte d'accesoire*/
	presence_CDP := true1 /* presence du capteur de pluie */ 

OPERATIONS

action_commodo_repos =
	PRE
		etat_commodo = fonctionnel1	&
		/* le commodo doit etre fonctionnel1*/ 
		dmd_commodo_user /= repos1
		/* la demande de commande utilisateur ne doit pas etre au repos */
	THEN
		dmd_commodo_user := repos1	||
		/* la demande de commande utilisateur est mise sur repos*/
		IF (alimentation = aucune1) 
		THEN
			IF depassement_temps_maintenance = false1
			THEN
				/* maintenance */
				IF(etat_moteur_ess_av = arretMaintenance1)
				THEN
					/* on remet les essuies-vitres en position arret-fixe */
					etat_moteur_ess_av := arretFixeAv1
				ELSE
					/* on met les essuies-vitres en position maintenance */
					etat_moteur_ess_av := arretMaintenance1 ||
					dmd_commodo := d_repos1
				END
			END
		ELSE
			IF etat_moteur_ess_av = arretMaintenance1
			THEN
				etat_moteur_ess_av := arretFixeAv1
			ELSE
				dmd_commodo := d_repos1		||
				etat_moteur_ess_av := arretFixeAv1
			END
		END ||
		IF(t_int_av=T_REDUC_PV_INT1 or t_int_av = T_INT_FIXE1)
		THEN
			IF(type_vitesse = ascendant1)
			THEN
				IF (vitesse_vehicule < 10)
				THEN
					t_int_av := T_INT_AV_TRES_LENTE1
				ELSE
					IF (vitesse_vehicule < 50)
					THEN
						t_int_av := T_INT_AV_LENTE1
					ELSE
						IF (vitesse_vehicule < 90)
						THEN
							t_int_av := T_INT_AV_MOYENNE1
						ELSE
							t_int_av := T_INT_AV_RAPIDE1
						END 
					END 
				END
			ELSE
				IF (vitesse_vehicule < 5)
				THEN
					t_int_av := T_INT_AV_TRES_LENTE1
				ELSE
				IF (vitesse_vehicule < 40)
				THEN
					t_int_av := T_INT_AV_LENTE1
				ELSE
				IF (vitesse_vehicule < 80)
				THEN
					t_int_av := T_INT_AV_MOYENNE1
				ELSE
					t_int_av := T_INT_AV_RAPIDE1
				END END END
			END
		END
	END;

action_commodo_pv =
	PRE
		etat_commodo = fonctionnel1		&
		/* le commodo doit etre fonctionnel1*/ 
		dmd_commodo_user /= 1pv1
		/* la demande de commande utilisateur ne doit pas etre sur petite vitesse*/
	THEN
		IF (alimentation = aucune1)
		THEN
			IF depassement_temps_maintenance = false1
			THEN
				/* maintenance */
				IF(etat_moteur_ess_av = arretMaintenance1)
				THEN
					/*on remet les essuies-vitres en position arret-fixe */
					etat_moteur_ess_av := arretFixeAv1
				ELSE
					/* on met les essuies-vitres en position maintenance */
					etat_moteur_ess_av := arretMaintenance1 ||
					dmd_commodo := d_repos1
				END
			END
		ELSE
			IF etat_moteur_ess_av = arretMaintenance1
			THEN
				etat_moteur_ess_av := arretFixeAv1
			ELSE
				dmd_commodo := d_pv1			||
				etat_moteur_ess_av := mgv1 ||
				seuil_depasse_vit1 := false1 ||
				IF(vitesse_vehicule > VIT2)
				/* gestion du dépassement des seuils */
				THEN
					seuil_depasse_vit2 := true1
				ELSE
					seuil_depasse_vit2 := false1
				END
			END
		END ||
		dmd_commodo_user := 1pv1
		/* la demande de commande utilisateur est mise sur petite vitesse */ ||
		IF(t_int_av=T_REDUC_PV_INT1  or t_int_av = T_INT_FIXE1)
		THEN
			IF(type_vitesse = ascendant1)
			THEN
				IF (vitesse_vehicule < 10)
				THEN
					t_int_av := T_INT_AV_TRES_LENTE1
				ELSE
					IF (vitesse_vehicule < 50)
					THEN
						t_int_av := T_INT_AV_LENTE1
					ELSE
						IF (vitesse_vehicule < 90)
						THEN
							t_int_av := T_INT_AV_MOYENNE1
						ELSE
							t_int_av := T_INT_AV_RAPIDE1
						END 
					END 
				END
			ELSE
				IF (vitesse_vehicule < 5)
				THEN
					t_int_av := T_INT_AV_TRES_LENTE1
				ELSE
				IF (vitesse_vehicule < 40)
				THEN
					t_int_av := T_INT_AV_LENTE1
				ELSE
				IF (vitesse_vehicule < 80)
				THEN
					t_int_av := T_INT_AV_MOYENNE1
				ELSE
					t_int_av := T_INT_AV_RAPIDE1
				END END END
			END
		END
	END;
	
action_commodo_gv =
	PRE
		etat_commodo = fonctionnel1 	&
		/* le commodo doit etre fonctionnel1*/ 
		dmd_commodo_user /= gv1
		/* la demande de commande utilisateur ne doit pas etre sur grande vitesse*/
	THEN
		IF (alimentation = aucune1)
		/* maintenance */
		THEN
			IF depassement_temps_maintenance = false1
			THEN
				IF(etat_moteur_ess_av = arretMaintenance1)
				THEN
					/*on remet les essuies-vitres en position arret-fixe */
					etat_moteur_ess_av := arretFixeAv1
				ELSE
					/* on met les essuies-vitres en position maintenance */
					etat_moteur_ess_av := arretMaintenance1 ||
					dmd_commodo := d_repos1
				END
			END
		ELSE
			IF etat_moteur_ess_av = arretMaintenance1
			THEN
				etat_moteur_ess_av := arretFixeAv1
			ELSE
				etat_moteur_ess_av := mgv1		||
				dmd_commodo := d_pv1			||
				seuil_depasse_vit1 := false1 ||
				IF(vitesse_vehicule > VIT2)
				/* gestion du dépassement des seuils */
				THEN
					seuil_depasse_vit2 := true1
				ELSE
					seuil_depasse_vit2 := false1
				END
			END
		END ||
		dmd_commodo_user := gv1
		||
		IF(t_int_av=T_REDUC_PV_INT1  or t_int_av = T_INT_FIXE1)
		THEN
			IF(type_vitesse = ascendant1)
			THEN
				IF (vitesse_vehicule < 10)
				THEN
					t_int_av := T_INT_AV_TRES_LENTE1
				ELSE
					IF (vitesse_vehicule < 50)
					THEN
						t_int_av := T_INT_AV_LENTE1
					ELSE
						IF (vitesse_vehicule < 90)
						THEN
							t_int_av := T_INT_AV_MOYENNE1
						ELSE
							t_int_av := T_INT_AV_RAPIDE1
						END 
					END 
				END
			ELSE
				IF (vitesse_vehicule < 5)
				THEN
					t_int_av := T_INT_AV_TRES_LENTE1
				ELSE
				IF (vitesse_vehicule < 40)
				THEN
					t_int_av := T_INT_AV_LENTE1
				ELSE
				IF (vitesse_vehicule < 80)
				THEN
					t_int_av := T_INT_AV_MOYENNE1
				ELSE
					t_int_av := T_INT_AV_RAPIDE1
				END END END
			END
		END
	END;
	
action_commodo_interm =
	PRE
		etat_commodo = fonctionnel1 &
		/* le commodo doit etre fonctionnel1*/ 
		dmd_commodo_user /= interm1 
	THEN
		/* la demande de commande utilisateur est mise sur intermittence*/
		IF (alimentation = aucune1)
		THEN
			IF depassement_temps_maintenance = false1
			THEN
				/* maintenance */
				IF(etat_moteur_ess_av = arretMaintenance1)
				THEN
					/*on remet les essuies-vitres en position arret-fixe */
					etat_moteur_ess_av := arretFixeAv1
				ELSE
					/* on met les essuies-vitres en position maintenance */
					etat_moteur_ess_av := arretMaintenance1 ||
					dmd_commodo := d_repos1
				END
			END
		ELSE
			IF etat_moteur_ess_av = arretMaintenance1
			THEN
				etat_moteur_ess_av := arretFixeAv1
			ELSE
				dmd_commodo := d_interm1		||
				etat_moteur_ess_av := mInter1
			END
		END
		||
		dmd_commodo_user := interm1 ||
		/* la demande de commande utilisateur est mise sur intermittence*/	
		IF(t_int_av=T_REDUC_PV_INT1  or t_int_av = T_INT_FIXE1)
		THEN
			IF(type_vitesse = ascendant1)
			THEN
				IF (vitesse_vehicule < 10)
				THEN
					t_int_av := T_INT_AV_TRES_LENTE1
				ELSE
					IF (vitesse_vehicule < 50)
					THEN
						t_int_av := T_INT_AV_LENTE1
					ELSE
						IF (vitesse_vehicule < 90)
						THEN
							t_int_av := T_INT_AV_MOYENNE1
						ELSE
							t_int_av := T_INT_AV_RAPIDE1
						END 
					END 
				END
			ELSE
				IF (vitesse_vehicule < 5)
				THEN
					t_int_av := T_INT_AV_TRES_LENTE1
				ELSE
				IF (vitesse_vehicule < 40)
				THEN
					t_int_av := T_INT_AV_LENTE1
				ELSE
				IF (vitesse_vehicule < 80)
				THEN
					t_int_av := T_INT_AV_MOYENNE1
				ELSE
					t_int_av := T_INT_AV_RAPIDE1
				END END END
			END
		END
	END;
	



action_commodo_auto =
	PRE
		etat_commodo = fonctionnel1	&
		/* le commodo doit etre fonctionnel1*/ 
		dmd_commodo_user /= auto1 &
		/* la demande de commande utilisateur ne doit pas etre sur automatique */
		presence_CDP = true1
		/* pour lancer cette commande, il faut que le capteur de pluie soit présent */
	THEN
		IF (alimentation  = aucune1)
		THEN
			IF depassement_temps_maintenance = false1
			THEN
				/* maintenance */
				IF etat_moteur_ess_av = arretMaintenance1
				THEN
					/* on remet les essuies-vitres en position arret-fixe */
					etat_moteur_ess_av := arretFixeAv1
				ELSE
					/* on met les essuies-vitres en position maintenance */
					etat_moteur_ess_av := arretMaintenance1 ||
					dmd_commodo := d_repos1
				END
			END
		ELSE
			IF etat_moteur_ess_av = arretMaintenance1
			THEN
				etat_moteur_ess_av := arretFixeAv1
			ELSE
				dmd_commodo := d_auto1			||
				IF etat_cdp = c_fonctionnel1
				THEN
					etat_moteur_ess_av := pv1cycle1
				ELSE
					etat_moteur_ess_av := mInter1
				END
			END
		END			||
		dmd_commodo_user := auto1
		||
		IF(t_int_av=T_REDUC_PV_INT1 & etat_cdp = c_fonctionnel1)
		THEN
			IF(type_vitesse = ascendant1)
			THEN
				t_int_av := T_INT_AV_TRES_LENTE1
			ELSE
				IF (vitesse_vehicule < 5)
				THEN
					t_int_av := T_INT_AV_TRES_LENTE1
				ELSE
					t_int_av := T_INT_AV_LENTE1
				END
			END
		ELSE
			IF etat_cdp /= c_fonctionnel1
			THEN
				t_int_av := T_INT_FIXE1
			END
		END
	END;

action_lavage_deb =
	PRE
		alimentation = accessoire1	&
		etat_commodo = fonctionnel1
		/* le commodo doit etre fonctionnel1*/ 
	THEN
		/* on lave à la vitesse du moteur sauf pour intermitence */
		IF etat_moteur_ess_av/=protectionMoteur1
		THEN
			IF etat_moteur_ess_av = mgv1 or etat_moteur_ess_av = gv3cycles1
			THEN
				etat_moteur_ess_av := gv3cyclesLavage1
			ELSE
				etat_moteur_ess_av := pv3cyclesLavage1
			END
		END
	END;

action_lavage_fin =
	PRE
		alimentation = accessoire1	&
		(etat_moteur_ess_av = pv3cyclesLavage1 or etat_moteur_ess_av = gv3cyclesLavage1)
	THEN
		IF etat_moteur_ess_av/=protectionMoteur1
		THEN
			IF t_int_av /= T_INT_FIXE1
			THEN
				IF dmd_commodo=d_repos1
				THEN
					etat_moteur_ess_av := arretFixeAv1
				ELSE
					IF dmd_commodo=d_pv1
					THEN 
						IF((seuil_depasse_vit2 = true1) & 
							seuil_depasse_vit1 = true1)
						THEN etat_moteur_ess_av := mInter1
						ELSE etat_moteur_ess_av := mgv1
						END
					ELSE
						IF dmd_commodo=d_pv1
						THEN 
							IF((seuil_depasse_vit2 = true1) & 
								seuil_depasse_vit1 = true1)
							THEN etat_moteur_ess_av := mgv1
							ELSE etat_moteur_ess_av := mgv1
							END
						ELSE
							IF dmd_commodo=d_interm1
							THEN 
								etat_moteur_ess_av := mInter1
							ELSE
								etat_moteur_ess_av := arretFixeAv1
							END
						END
					END
				END
			ELSE
				/*cas où on est en intermittence fixe*/
				etat_moteur_ess_av := mInter1
			END
		END
	END;

action_pvi_deb =
	PRE
		alimentation = accessoire1	&
		etat_commodo = fonctionnel1
		/* le commodo doit etre fonctionnel1 */ 
	THEN
		IF etat_moteur_ess_av = arretFixeAv1 
		THEN
			etat_moteur_ess_av := pv1cycle1
		END
	END;

action_pvi_fin = 
	PRE
		alimentation = accessoire1	&
		etat_moteur_ess_av = pv1cycle1 &
		dmd_commodo = d_repos1 &
		etat_cdp = c_fonctionnel1 &
		etat_commodo = fonctionnel1
	THEN
		IF etat_moteur_ess_av/=protectionMoteur1
		THEN
			IF dmd_commodo=d_repos1
			THEN
				etat_moteur_ess_av := arretFixeAv1
			ELSE
				IF dmd_commodo=d_pv1
				THEN 
					IF((seuil_depasse_vit2 = true1) & 
						seuil_depasse_vit1 = true1)
					THEN etat_moteur_ess_av := mInter1
					ELSE etat_moteur_ess_av := mgv1
					END
				ELSE
					IF dmd_commodo=d_pv1
					THEN 
						IF((seuil_depasse_vit2 = true1) & 
							seuil_depasse_vit1 = true1)
						THEN etat_moteur_ess_av := mgv1
						ELSE etat_moteur_ess_av := mgv1
						END
					ELSE
						IF dmd_commodo=d_interm1
						THEN 
							etat_moteur_ess_av := mInter1
						ELSE
							etat_moteur_ess_av := arretFixeAv1
						END
					END
				END
			END
		END
	END;
	


action_commodo_defaillance_deb =
	PRE
		etat_commodo = fonctionnel1
		/* le commodo doit etre fonctionnel1*/ 
	THEN
		etat_commodo := defaillant1   	||
		IF(alimentation=accessoire1 & etat_cdp = c_fonctionnel1 & 
			etat_moteur_ess_av /= protectionMoteur1 & presence_CDP=true1)
		THEN
			etat_moteur_ess_av := pv1cycle1
		ELSE
			IF  etat_cdp = c_defaillant1 or presence_CDP = false1
			THEN
				IF  etat_moteur_ess_av /= protectionMoteur1
					& alimentation=accessoire1
				THEN
					etat_moteur_ess_av := mInter1
				END ||
				t_int_av := T_INT_FIXE1
			END
		END ||
		/* les seuils ne sont plus dépassés */
		seuil_depasse_vit2 := false1 ||
		seuil_depasse_vit1 := false1
	END;

action_commodo_defaillance_fin =
	PRE
		etat_commodo = defaillant1
	THEN
		etat_commodo := fonctionnel1	||
		IF alimentation = accessoire1 &  etat_moteur_ess_av/=protectionMoteur1
		THEN
			/* revient à l'état d'avant la défaillance */
			IF dmd_commodo=d_repos1
			THEN
				etat_moteur_ess_av := arretFixeAv1
			ELSE
				IF dmd_commodo=d_pv1
				THEN 
					etat_moteur_ess_av := mgv1
				ELSE
					IF dmd_commodo=d_pv1
					THEN 
						etat_moteur_ess_av := mgv1
					ELSE
						IF dmd_commodo=d_interm1
						THEN 
							etat_moteur_ess_av := mInter1
						ELSE
							IF dmd_commodo = d_auto1 & 
								etat_cdp = c_defaillant1
							THEN
								etat_moteur_ess_av := mInter1
							ELSE
								etat_moteur_ess_av := pv1cycle1
							END
						END
					END
				END
			END
		END ||
		IF((dmd_commodo=d_pv1 or dmd_commodo=d_pv1) & vitesse_vehicule > VIT2)
		/* gestion du dépassement des seuils */
		THEN
			seuil_depasse_vit2 := true1
		ELSE
			seuil_depasse_vit2 := false1
		END
		||
		/* On doit pouvoir réduire cette partie : on devrait recalculer l'intermittence 
			que dans le cas où l'intermittence était à T_INT_FIXE1 */
		IF dmd_commodo = d_pv1 & seuil_depasse_vit2 = true1 &
			seuil_depasse_vit1 = true1
		THEN
			t_int_av := T_REDUC_PV_INT1
		ELSE
			IF (dmd_commodo = d_auto1 & etat_cdp = c_defaillant1)
			THEN
				t_int_av := T_INT_FIXE1
			ELSE
				IF(type_vitesse = ascendant1)
				THEN
					IF (vitesse_vehicule < 10)
					THEN
						t_int_av := T_INT_AV_TRES_LENTE1
					ELSE
						IF (vitesse_vehicule < 50)
						THEN
							t_int_av := T_INT_AV_LENTE1
						ELSE
							IF (vitesse_vehicule < 90)
							THEN
								t_int_av := T_INT_AV_MOYENNE1
							ELSE
								t_int_av := T_INT_AV_RAPIDE1
							END 
						END 
					END
				ELSE
					IF (vitesse_vehicule < 5)
					THEN
						t_int_av := T_INT_AV_TRES_LENTE1
					ELSE
					IF (vitesse_vehicule < 40)
					THEN
						t_int_av := T_INT_AV_LENTE1
					ELSE
					IF (vitesse_vehicule < 80)
					THEN
						t_int_av := T_INT_AV_MOYENNE1
					ELSE
						t_int_av := T_INT_AV_RAPIDE1
					END END END
				END
			END
		END
	END;		

action_cdp_defaillant_deb =
	PRE
		etat_cdp = c_fonctionnel1 &
		presence_CDP = true1
	THEN
		etat_cdp := c_defaillant1 ||
		IF (etat_commodo = defaillant1 or dmd_commodo =d_auto1) 
		THEN
			IF etat_moteur_ess_av /=protectionMoteur1 & alimentation = accessoire1
			THEN
				etat_moteur_ess_av := mInter1 
			END ||
			t_int_av := T_INT_FIXE1 
		END
	END;

action_cdp_defaillant_fin =
	PRE
		etat_cdp = c_defaillant1 &
		presence_CDP = true1
	THEN
		etat_cdp := c_fonctionnel1 ||
		IF etat_commodo /= defaillant1 & alimentation = accessoire1 & 
			etat_moteur_ess_av/=protectionMoteur1
		THEN
		/* retour à l'état d'avant la défaillance */
			IF dmd_commodo=d_repos1
			THEN
					etat_moteur_ess_av := arretFixeAv1
			ELSE
				IF dmd_commodo=d_pv1
				THEN 
					IF((seuil_depasse_vit2 = true1) & seuil_depasse_vit1 = true1)
					THEN etat_moteur_ess_av := mInter1
					ELSE etat_moteur_ess_av := mgv1
					END
				ELSE
					IF dmd_commodo=d_pv1
					THEN 
						IF((seuil_depasse_vit2 = true1) &
							seuil_depasse_vit1 = true1)
						THEN etat_moteur_ess_av := mgv1
						ELSE etat_moteur_ess_av := mgv1
						END
					ELSE
						IF dmd_commodo=d_interm1
						THEN 
							etat_moteur_ess_av := mInter1
						ELSE
							/* on est en automatique */
							etat_moteur_ess_av := pv1cycle1
						END
					END
				END
			END
		ELSE
			IF alimentation =accessoire1 & etat_moteur_ess_av /= protectionMoteur1
			THEN
				etat_moteur_ess_av := pv1cycle1
			END
		END ||
		/* calcul de la nouvelle intermittence */
		IF dmd_commodo = d_pv1 & seuil_depasse_vit2 = true1 &
			seuil_depasse_vit1 = true1
		THEN
			t_int_av := T_REDUC_PV_INT1
		ELSE
			IF(type_vitesse = ascendant1)
			THEN
				IF (vitesse_vehicule < 10)
				THEN
					t_int_av := T_INT_AV_TRES_LENTE1
				ELSE
					IF (vitesse_vehicule < 50)
					THEN
						t_int_av := T_INT_AV_LENTE1
					ELSE
						IF (vitesse_vehicule < 90)
						THEN
							t_int_av := T_INT_AV_MOYENNE1
						ELSE
							t_int_av := T_INT_AV_RAPIDE1
						END 
					END 
				END
			ELSE
				IF (vitesse_vehicule < 5)
				THEN
					t_int_av := T_INT_AV_TRES_LENTE1
				ELSE
				IF (vitesse_vehicule < 40)
				THEN
					t_int_av := T_INT_AV_LENTE1
				ELSE
				IF (vitesse_vehicule < 80)
				THEN
					t_int_av := T_INT_AV_MOYENNE1
				ELSE
					t_int_av := T_INT_AV_RAPIDE1
				END END END
			END
		END
	END;
	
bloquer_le_moteur_ess_av =
	/* le moteur se met en protection moteur : utilisé dans la maintenance */
	PRE
		etat_moteur_ess_av /= protectionMoteur1
	THEN
		etat_moteur_ess_av := protectionMoteur1
	END;

depasser_temps_maintenance = 
	PRE
		depassement_temps_maintenance = false1 		&
		alimentation = aucune1
	THEN
		depassement_temps_maintenance := true1
	END;
	
depasser_temps_perte_acc =
	PRE
		alimentation = aucune1		&
		t_perte_acc_depasse = false1
	THEN
		t_perte_acc_depasse := true1
	END;

alimentation_acc =
	PRE
		alimentation /= accessoire1	&
		vitesse_vehicule = 0
	THEN
		IF (alimentation = aucune1 & t_perte_acc_depasse = true1)
		THEN
			/* si T_PERTE_ACC est dépassée, on réinitialise tout */
			IF etat_moteur_ess_av/=protectionMoteur1 & 
				etat_moteur_ess_av /= arretMaintenance1
			THEN
				IF t_int_av = T_INT_FIXE1
				THEN
					IF dmd_commodo = d_auto1
					THEN
						etat_moteur_ess_av := arretFixeAv1
					ELSE
						etat_moteur_ess_av := mInter1
					END
				ELSE
					IF etat_commodo=defaillant1
					THEN
						etat_moteur_ess_av := pv1cycle1
					ELSE
						etat_moteur_ess_av := arretFixeAv1
					END
				END
			ELSE
				IF etat_moteur_ess_av = arretMaintenance1 & t_int_av = T_INT_FIXE1 &
						dmd_commodo /= d_auto1
				THEN
					etat_moteur_ess_av := mInter1
				END
			END	||
			IF (t_int_av = T_INT_FIXE1 & dmd_commodo = d_auto1) or 
				(t_int_av = T_REDUC_PV_INT1)
			THEN
				/* on a perdu le fait qu'on était en auto donc on sort de 
				l'intermittence Fixe et on remet l'intermittence à tres lente car 
				la vitesse est nulle*/
				t_int_av := T_INT_AV_TRES_LENTE1
			END ||
			dmd_commodo := d_repos1||
			seuil_depasse_vit1 := false1 ||
			seuil_depasse_vit2 := false1 
		ELSE
			/* si T_PERTE_ACC n'est pas dépassé, on reprend où on s'était arrêté */
			IF etat_moteur_ess_av/=protectionMoteur1 & etat_moteur_ess_av /= 
				arretMaintenance1
			THEN
				IF t_int_av = T_INT_FIXE1
				THEN
					etat_moteur_ess_av := mInter1
				ELSE
					IF etat_commodo=defaillant1
					THEN
						etat_moteur_ess_av := pv1cycle1
					ELSE
						IF dmd_commodo=d_repos1
						THEN
							etat_moteur_ess_av := arretFixeAv1
						ELSE
							IF dmd_commodo=d_pv1
							THEN 
							IF((seuil_depasse_vit2 = true1) & 
								seuil_depasse_vit1 =true1 )
							THEN etat_moteur_ess_av := mInter1
							ELSE etat_moteur_ess_av := mgv1
							END
							ELSE
							IF dmd_commodo=d_pv1
							THEN 
							IF((seuil_depasse_vit2 = true1) & 
								seuil_depasse_vit1 = true1)
							THEN etat_moteur_ess_av := mgv1
							ELSE etat_moteur_ess_av := mgv1
							END
							ELSE
							IF dmd_commodo=d_interm1
							THEN etat_moteur_ess_av := mInter1
							ELSE etat_moteur_ess_av := pv1cycle1
							END
							END
							END
						END
					END
				END
			ELSE
				IF etat_moteur_ess_av = arretMaintenance1 & t_int_av = T_INT_FIXE1 &
						dmd_commodo /= d_auto1
				THEN
					etat_moteur_ess_av := mInter1
				END
			END
		END 	||
		alimentation := accessoire1		||
		t_perte_acc_depasse := false1		||
		depassement_temps_maintenance := false1 
	END;			

alimentation_dem =
	PRE
		alimentation = accessoire1	&
		vitesse_vehicule = 0
	THEN
		alimentation := demarreur1		||
		depassement_temps_maintenance := false1 ||
		t_perte_acc_depasse := false1 ||
		IF etat_moteur_ess_av /= protectionMoteur1
		THEN
			etat_moteur_ess_av := suspendu1
		END
	END;
	
alimentation_coupe =
	PRE
		alimentation = accessoire1 &
		vitesse_vehicule = 0
	THEN
		alimentation := aucune1		||
		depassement_temps_maintenance := false1	||
		t_perte_acc_depasse := false1 ||
		IF etat_moteur_ess_av /= protectionMoteur1
		THEN
			etat_moteur_ess_av := arretFixeAv1
		END
	END;
	


action_CDP_pv =
	SELECT
		alimentation  = accessoire1	&
		(dmd_commodo = d_auto1 or etat_commodo = defaillant1) &
		etat_cdp = c_fonctionnel1 &
		presence_CDP = true1
	THEN
		cdp := pvCDP1			||
		IF(etat_moteur_ess_av /= protectionMoteur1)
		THEN
			etat_moteur_ess_av := mgv1
		END
	END;

action_CDP_gv =
	SELECT
		alimentation = accessoire1	&
		(dmd_commodo = d_auto1 or etat_commodo = defaillant1) &
		etat_cdp = c_fonctionnel1 &
		presence_CDP = true1
	THEN
		cdp := gvCDP1			||
		IF(etat_moteur_ess_av /= protectionMoteur1)
		THEN
			etat_moteur_ess_av := gv3cycles1
		END
	END;

action_CDP_arret =
	SELECT
		alimentation = accessoire1	&
		(dmd_commodo = d_auto1 or etat_commodo = defaillant1) &
		etat_cdp = c_fonctionnel1 &
		presence_CDP = true1
	THEN
		/* le capteur ne capte rien*/
		IF(etat_moteur_ess_av /= protectionMoteur1)
		THEN
			etat_moteur_ess_av := arretFixeAv1
		END			||
		cdp := arretCDP1
	END;



deceleration(varvit) =
	PRE
		varvit : VITESSE		&
		alimentation = accessoire1	&
		(varvit <= vitesse_vehicule) 
	THEN
		IF((dmd_commodo = d_pv1  or dmd_commodo = d_pv1) & seuil_depasse_vit2 = true1 & 
			(vitesse_vehicule - varvit < VIT1 or seuil_depasse_vit1 = true1))
		/* cas d'une décélaration après avoir franchi le seuil */
		THEN
			seuil_depasse_vit1 := true1 ||
			IF(dmd_commodo = d_pv1 & t_int_av /= T_INT_FIXE1)
			THEN
				IF(etat_moteur_ess_av/=protectionMoteur1)
				THEN
					etat_moteur_ess_av := mInter1		
				END ||
				t_int_av := T_REDUC_PV_INT1
			ELSE
				IF(dmd_commodo_user = gv1 & t_int_av /= T_INT_FIXE1)
				THEN
					etat_moteur_ess_av := mgv1	||
					IF (vitesse_vehicule - varvit < 5)
					THEN
						t_int_av := T_INT_AV_TRES_LENTE1
					ELSE
					IF (vitesse_vehicule - varvit < 40)
					THEN
						t_int_av := T_INT_AV_LENTE1
					ELSE
					IF (vitesse_vehicule - varvit < 80)
					THEN
						t_int_av := T_INT_AV_MOYENNE1
					ELSE
						t_int_av := T_INT_AV_RAPIDE1
					END END	END
				END
			END
		ELSE
			IF t_int_av /= T_INT_FIXE1
			THEN
				IF ((vitesse_vehicule - varvit) < 5)
				THEN
					t_int_av := T_INT_AV_TRES_LENTE1
				ELSE
				IF (vitesse_vehicule - varvit < 40)
				THEN
					t_int_av := T_INT_AV_LENTE1
				ELSE
				IF (vitesse_vehicule - varvit < 80)
				THEN
					t_int_av := T_INT_AV_MOYENNE1
				ELSE
					t_int_av := T_INT_AV_RAPIDE1
				END END END
			END
		END ||
		vitesse_vehicule := vitesse_vehicule - varvit	||
		type_vitesse := descendant1
	END;

acceleration(varvit) =
	PRE
		alimentation = accessoire1	&
		varvit : VITESSE			&
		varvit + vitesse_vehicule < MAX_VITESSE
	THEN
		IF ((dmd_commodo = d_pv1  or dmd_commodo = d_pv1) & 
			seuil_depasse_vit2 = false1 & vitesse_vehicule + varvit > VIT2  )
		/* on ne modifie ce seuil à la condition que le seuil n'ait pas 
			encore été modifié*/
		THEN
			seuil_depasse_vit2 := true1
		END		||
		IF (not(dmd_commodo = d_pv1 & etat_moteur_ess_av = mInter1 & 
			(vitesse_vehicule+varvit) <= VIT2)) & t_int_av /= T_INT_FIXE1
		THEN
			IF ((vitesse_vehicule+varvit) < 10)
			THEN
				t_int_av := T_INT_AV_TRES_LENTE1
			ELSE
			IF (vitesse_vehicule+varvit < 50)
			THEN
				t_int_av := T_INT_AV_LENTE1
			ELSE
			IF (vitesse_vehicule+varvit < 90)
			THEN
				t_int_av := T_INT_AV_MOYENNE1
			ELSE
				t_int_av := T_INT_AV_RAPIDE1
			END END END 
		END ||
		IF ((dmd_commodo = d_pv1) & (etat_moteur_ess_av = mInter1) & 
			(vitesse_vehicule+varvit) > VIT2)
		/* passage d'intermmitence à pv ou pv à gv en fonction de la vitesse du véhicule */
		THEN
			IF(etat_moteur_ess_av /= protectionMoteur1 & t_int_av /= T_INT_FIXE1)
			THEN
				etat_moteur_ess_av := mgv1 
			END ||
			seuil_depasse_vit1 := false1
		ELSE
			IF(dmd_commodo = d_pv1 & etat_moteur_ess_av =mgv1 & 
				(vitesse_vehicule+varvit) >VIT2)
			THEN
				IF(etat_moteur_ess_av /= protectionMoteur1 &
					t_int_av /= T_INT_FIXE1)
				THEN
					etat_moteur_ess_av := mgv1 
				END ||
				seuil_depasse_vit1 := false1
			END
		END ||
		vitesse_vehicule := vitesse_vehicule + varvit	||
		type_vitesse := ascendant1
	END;
	
vitesse(vit) =
	PRE
		alimentation = accessoire1	&
		vit : VITESSE			
	THEN
		IF ((dmd_commodo = d_pv1  or dmd_commodo = d_pv1) & seuil_depasse_vit2 = false1 &
			vit > VIT2  )
		/* on ne modifie ce seuil à la condition que le seuil n'ait pas encore été 
			modifié lors d'une accélération */
		THEN
			seuil_depasse_vit2 := true1
		END				||
		IF (vitesse_vehicule < vit)
		THEN
			type_vitesse := ascendant1 ||
			IF(dmd_commodo = d_pv1 & etat_moteur_ess_av = mInter1 & 
				vit > VIT2)
			/* passage d'intermmitence à pv ou pv à gv en fonction de la 
				vitesse du véhicule */
			THEN
				IF etat_moteur_ess_av /= protectionMoteur1 & t_int_av /= T_INT_FIXE1
				THEN
					etat_moteur_ess_av := mgv1
				END ||
				seuil_depasse_vit1 := false1
			ELSE
				IF(dmd_commodo = d_pv1 & etat_moteur_ess_av =mgv1 &
					vit > VIT2)
				THEN
					IF etat_moteur_ess_av /= protectionMoteur1 & 
						t_int_av /= T_INT_FIXE1
					THEN
						etat_moteur_ess_av := mgv1 
					END ||
					seuil_depasse_vit1 := false1
				END
			END
			||
			IF (not (dmd_commodo = d_pv1 & etat_moteur_ess_av = mInter1 &
				vit <= VIT2)) & t_int_av /= T_INT_FIXE1
			THEN
				IF (vit < 10)
				THEN
					t_int_av := T_INT_AV_TRES_LENTE1
				ELSE
					IF (vit < 50)
					THEN
						t_int_av := T_INT_AV_LENTE1
					ELSE
						IF (vit < 90)
						THEN
							t_int_av := T_INT_AV_MOYENNE1
						ELSE
							t_int_av := T_INT_AV_RAPIDE1
						END 
					END 
				END
			END
		ELSE
			type_vitesse := descendant1 ||
			IF((dmd_commodo = d_pv1  or dmd_commodo = d_pv1) & 
				seuil_depasse_vit2 = true1 & (vit < VIT1 or 
				seuil_depasse_vit1 = true1))
		        /* cas d'une descélaration après avoir franchi le seuil vit2*/
		        THEN
				seuil_depasse_vit1 := true1 ||
				IF(dmd_commodo = d_pv1 & t_int_av /= T_INT_FIXE1)
			        THEN
					IF(etat_moteur_ess_av /= protectionMoteur1)
					THEN
					       etat_moteur_ess_av := mInter1
					END ||
				       t_int_av := T_REDUC_PV_INT1
				ELSE
					IF t_int_av /= T_INT_FIXE1
					THEN
						IF dmd_commodo = d_pv1
						THEN
							etat_moteur_ess_av := mgv1 ||
							IF (vit < 5)
							/* Soustraction de vitesse a controler*/	
							THEN
								t_int_av := T_INT_AV_TRES_LENTE1
							ELSE
							IF (vit < 40)
							/* Soustraction de vitesse a controler*/
							THEN t_int_av := T_INT_AV_LENTE1
							ELSE
							IF (vit < 80)
							/* Soustraction de vitesse a controler*/
							THEN t_int_av := T_INT_AV_MOYENNE1
							ELSE t_int_av := T_INT_AV_RAPIDE1
							END
							END
							END
						END
					END
				END
			ELSE
				IF t_int_av /= T_INT_FIXE1
				THEN
					IF (vit < 5)
					/* Soustraction de vitesse a controler*/	
					THEN
						t_int_av := T_INT_AV_TRES_LENTE1
					ELSE
						IF (vit < 40)
						/* Soustraction de vitesse a controler*/
						THEN
							t_int_av := T_INT_AV_LENTE1
						ELSE
						IF (vit < 80)
						/* Soustraction de vitesse a controler*/
						THEN
							t_int_av := T_INT_AV_MOYENNE1
						ELSE
							t_int_av := T_INT_AV_RAPIDE1
						END
						END
					END
				END
			END
		END ||
		vitesse_vehicule := vit	
	END

END
