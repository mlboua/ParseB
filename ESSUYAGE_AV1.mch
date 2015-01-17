MACHINE
	ESSUYAGE_AV1

CONSTANTS
	
	VIT1,
	VIT2,
	MAX_VITESSE

SETS
	S_DMD_COMMODO_USER = {1, 2, 3, 4, 5}; 
	
	S_DMD_COMMODO = {6, 7, 9, 9, 10}; 
	
	ETAT_COMMODO = {11, 12}; /* etat de la commande*/
	
	TYPE_VITESSE = {13, 14}; /* etat de la variation de vitesse du vehicule */
	
	ALIMENTATION = {15, 16, 17};
	/* etat de l'alimemtation (position de la clef) */
	
	ETAT_MOTEUR_ESS_AV = {19, 19, 20, 21, 22,23,24, 
		25, 26, 27, 28};
	
	CDP = {29, 30, 31};
	ETAT_CDP = {32,33};
	
	BOOLEAN = {34, 35};
	T_INT_AV = {36, 37, 38, 39, 
		40, 41}

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
	(depassement_temps_maintenance = 35 => alimentation = 17)	&
	
	(t_perte_acc_depasse = 35 => alimentation = 17)	&
	
	(alimentation = 17 => vitesse_vehicule = 0)	&

	(seuil_depasse_vit1 = 35 => seuil_depasse_vit2 = 35) &

        (seuil_depasse_vit2 = 34 => seuil_depasse_vit1 = 34) &

	((dmd_commodo = 6 or dmd_commodo = 7 or dmd_commodo = 10) => 
		(seuil_depasse_vit1 = 34 & seuil_depasse_vit2 = 34)) &
	(alimentation = 17 => etat_moteur_ess_av = 20 or etat_moteur_ess_av = 
		22 or etat_moteur_ess_av = 26) &
	
	(dmd_commodo = 9 & seuil_depasse_vit2 = 35 & seuil_depasse_vit1 = 35 => 
		t_int_av = 41) &
	
	(t_int_av = 41 => (vitesse_vehicule <= VIT2 & dmd_commodo = 9)) &

	((vitesse_vehicule < 10 & type_vitesse = 13 & t_int_av /= 41 &
		t_int_av /= 40) => t_int_av = 36) &
	((vitesse_vehicule >= 10 & vitesse_vehicule < 50 & type_vitesse = 13 & 
		t_int_av /= 41 & t_int_av /= 40) 
		=> t_int_av = 37) &
	((vitesse_vehicule >= 50 & vitesse_vehicule < 90 & type_vitesse = 13 & 
		t_int_av /= 41 & t_int_av /= 40) 
		=> t_int_av = 38) &
	((vitesse_vehicule >= 90 & type_vitesse = 13 & t_int_av /= 41 &
		t_int_av /= 40) => t_int_av = 39) &

	((vitesse_vehicule < 5 & type_vitesse = 14 & t_int_av /= 41 & 
		t_int_av /= 40) => t_int_av = 36) &
	((vitesse_vehicule >= 5 & vitesse_vehicule < 40 & type_vitesse = 14 & 
		t_int_av /= 41 & t_int_av /= 40) 
		=> t_int_av = 37) &
	((vitesse_vehicule >= 40 & vitesse_vehicule < 80 & type_vitesse = 14 & 
		t_int_av /= 41 & t_int_av /= 40) 
		=> t_int_av = 38) &
	((vitesse_vehicule >= 80 & type_vitesse = 14 & t_int_av /= 41 &
		t_int_av /= 40) => t_int_av = 39) &

	((t_int_av = 40 & alimentation = 15) => ((etat_cdp = 32 or
		presence_CDP = 34) & (dmd_commodo = 10 or etat_commodo = 11) &
		(etat_moteur_ess_av = 23 or etat_moteur_ess_av = 26 or 
		etat_moteur_ess_av = 27))) &
	((t_int_av = 40 & alimentation /= 15) => (etat_cdp = 32 or
		 presence_CDP = 34) & (dmd_commodo = 10 or etat_commodo = 11)) &

	(((etat_cdp = 32 & dmd_commodo = 10) or (etat_commodo = 11 & 
		(etat_cdp = 32 or presence_CDP = 34))) => t_int_av = 40)  &
	((etat_commodo = 11) => (seuil_depasse_vit2 = 34)) &

	((alimentation = 15 & etat_moteur_ess_av = 22) => dmd_commodo = 6)
	
INITIALISATION
	dmd_commodo_user := 1 	||

	dmd_commodo := 6		||
	etat_commodo := 12		||
	vitesse_vehicule := 0	||
	type_vitesse := 13		||
	alimentation := 17		||
	etat_moteur_ess_av := 20 ||
	
	cdp := 31				||
	etat_cdp := 33          ||
	t_int_av := 36			||

	depassement_temps_maintenance := 35			||

	seuil_depasse_vit1 := 34  ||
	
	seuil_depasse_vit2 := 34 ||		
	t_perte_acc_depasse := 35 ||
	
	presence_CDP := 35 
	
OPERATIONS

action_commodo_repos =
	PRE
		etat_commodo = 12	&
		/* le commodo doit etre 12*/ 
		dmd_commodo_user /= 1
		/* la demande de commande utilisateur ne doit pas etre au repos */
	THEN
		dmd_commodo_user := 1	||
		/* la demande de commande utilisateur est mise sur repos*/
		IF (alimentation = 17) 
		THEN
			IF depassement_temps_maintenance = 34
			THEN
				/* maintenance */
				IF(etat_moteur_ess_av = 22)
				THEN
					/* on remet les essuies-vitres en position arret-fixe */
					etat_moteur_ess_av := 20
				ELSE
					/* on met les essuies-vitres en position maintenance */
					etat_moteur_ess_av := 22 ||
					dmd_commodo := 6
				END
			END
		ELSE
			IF etat_moteur_ess_av = 22
			THEN
				etat_moteur_ess_av := 20
			ELSE
				dmd_commodo := 6		||
				etat_moteur_ess_av := 20
			END
		END ||
		IF(t_int_av=41 or t_int_av = 40)
		THEN
			IF(type_vitesse = 13)
			THEN
				IF (vitesse_vehicule < 10)
				THEN
					t_int_av := 36
				ELSE
					IF (vitesse_vehicule < 50)
					THEN
						t_int_av := 37
					ELSE
						IF (vitesse_vehicule < 90)
						THEN
							t_int_av := 38
						ELSE
							t_int_av := 39
						END 
					END 
				END
			ELSE
				IF (vitesse_vehicule < 5)
				THEN
					t_int_av := 36
				ELSE
				IF (vitesse_vehicule < 40)
				THEN
					t_int_av := 37
				ELSE
				IF (vitesse_vehicule < 80)
				THEN
					t_int_av := 38
				ELSE
					t_int_av := 39
				END END END
			END
		END
	END;
	
	action_commodo_pv =
	PRE
		etat_commodo = 12		&

		dmd_commodo_user /= 3
		
	THEN
		IF (alimentation = 17)
		THEN
			IF depassement_temps_maintenance = 34
			THEN
				
				IF(etat_moteur_ess_av = 22)
				THEN
					etat_moteur_ess_av := 20
				ELSE
					etat_moteur_ess_av := 22 ||
					dmd_commodo := 6
				END
			END
		ELSE
			IF etat_moteur_ess_av = 22
			THEN
				etat_moteur_ess_av := 20
			ELSE
				dmd_commodo := 9			||
				etat_moteur_ess_av := 19 ||
				seuil_depasse_vit1 := 34 ||
				IF(vitesse_vehicule > VIT2)
				THEN
					seuil_depasse_vit2 := 35
				ELSE
					seuil_depasse_vit2 := 34
				END
			END
		END ||
		dmd_commodo_user := 3 ||
		IF(t_int_av=41  or t_int_av = 40)
		THEN
			IF(type_vitesse = 13)
			THEN
				IF (vitesse_vehicule < 10)
				THEN
					t_int_av := 36
				ELSE
					IF (vitesse_vehicule < 50)
					THEN
						t_int_av := 37
					ELSE
						IF (vitesse_vehicule < 90)
						THEN
							t_int_av := 38
						ELSE
							t_int_av := 39
						END 
					END 
				END
			ELSE
				IF (vitesse_vehicule < 5)
				THEN
					t_int_av := 36
				ELSE
				IF (vitesse_vehicule < 40)
				THEN
					t_int_av := 37
				ELSE
				IF (vitesse_vehicule < 80)
				THEN
					t_int_av := 38
				ELSE
					t_int_av := 39
				END END END
			END
		END
	END;
	
	
	action_commodo_gv =
	PRE
		etat_commodo = 12 	&
		dmd_commodo_user /= 4
	THEN
		IF (alimentation = 17)
		THEN
			IF depassement_temps_maintenance = 34
			THEN
				IF(etat_moteur_ess_av = 22)
				THEN
					etat_moteur_ess_av := 20
				ELSE
					etat_moteur_ess_av := 22 ||
					dmd_commodo := 6
				END
			END
		ELSE
			IF etat_moteur_ess_av = 22
			THEN
				etat_moteur_ess_av := 20
			ELSE
				etat_moteur_ess_av := 19		||
				dmd_commodo := 9			||
				seuil_depasse_vit1 := 34 ||
				IF(vitesse_vehicule > VIT2)
				
				THEN
					seuil_depasse_vit2 := 35
				ELSE
					seuil_depasse_vit2 := 34
				END
			END
		END ||
		dmd_commodo_user := 4
		||
		IF(t_int_av=41  or t_int_av = 40)
		THEN
			IF(type_vitesse = 13)
			THEN
				IF (vitesse_vehicule < 10)
				THEN
					t_int_av := 36
				ELSE
					IF (vitesse_vehicule < 50)
					THEN
						t_int_av := 37
					ELSE
						IF (vitesse_vehicule < 90)
						THEN
							t_int_av := 38
						ELSE
							t_int_av := 39
						END 
					END 
				END
			ELSE
				IF (vitesse_vehicule < 5)
				THEN
					t_int_av := 36
				ELSE
				IF (vitesse_vehicule < 40)
				THEN
					t_int_av := 37
				ELSE
				IF (vitesse_vehicule < 80)
				THEN
					t_int_av := 38
				ELSE
					t_int_av := 39
				END END END
			END
		END
	END;
	
action_commodo_interm =
	PRE
		etat_commodo = 12 &
		dmd_commodo_user /= 2 
	THEN
		IF (alimentation = 17)
		THEN
			IF depassement_temps_maintenance = 34
			THEN
				IF(etat_moteur_ess_av = 22)
				THEN
					etat_moteur_ess_av := 20
				ELSE
					etat_moteur_ess_av := 22 ||
					dmd_commodo := 6
				END
			END
		ELSE
			IF etat_moteur_ess_av = 22
			THEN
				etat_moteur_ess_av := 20
			ELSE
				dmd_commodo := 7		||
				etat_moteur_ess_av := 23
			END
		END
		||
		dmd_commodo_user := 2 ||
		IF(t_int_av=41  or t_int_av = 40)
		THEN
			IF(type_vitesse = 13)
			THEN
				IF (vitesse_vehicule < 10)
				THEN
					t_int_av := 36
				ELSE
					IF (vitesse_vehicule < 50)
					THEN
						t_int_av := 37
					ELSE
						IF (vitesse_vehicule < 90)
						THEN
							t_int_av := 38
						ELSE
							t_int_av := 39
						END 
					END 
				END
			ELSE
				IF (vitesse_vehicule < 5)
				THEN
					t_int_av := 36
				ELSE
				IF (vitesse_vehicule < 40)
				THEN
					t_int_av := 37
				ELSE
				IF (vitesse_vehicule < 80)
				THEN
					t_int_av := 38
				ELSE
					t_int_av := 39
				END END END
			END
		END
	END;
	action_commodo_auto =
	PRE
		etat_commodo = 12	&
		dmd_commodo_user /= 5 &
		presence_CDP = 35
	THEN
		IF (alimentation  = 17)
		THEN
			IF depassement_temps_maintenance = 34
			THEN
				IF etat_moteur_ess_av = 22
				THEN
					etat_moteur_ess_av := 20
				ELSE
					etat_moteur_ess_av := 22 ||
					dmd_commodo := 6
				END
			END
		ELSE
			IF etat_moteur_ess_av = 22
			THEN
				etat_moteur_ess_av := 20
			ELSE
				dmd_commodo := 10			||
				IF etat_cdp = 33
				THEN
					etat_moteur_ess_av := 24
				ELSE
					etat_moteur_ess_av := 23
				END
			END
		END			||
		dmd_commodo_user := 5
		||
		IF(t_int_av=41 & etat_cdp = 33)
		THEN
			IF(type_vitesse = 13)
			THEN
				t_int_av := 36
			ELSE
				IF (vitesse_vehicule < 5)
				THEN
					t_int_av := 36
				ELSE
					t_int_av := 37
				END
			END
		ELSE
			IF etat_cdp /= 33
			THEN
				t_int_av := 40
			END
		END
	END;

action_lavage_deb =
	PRE
		alimentation = 15	&
		etat_commodo = 12
	THEN
		IF etat_moteur_ess_av/=26
		THEN
			IF etat_moteur_ess_av = 19 or etat_moteur_ess_av = 25
			THEN
				etat_moteur_ess_av := 28
			ELSE
				etat_moteur_ess_av := 27
			END
		END
	END;



action_lavage_fin =
	PRE
		alimentation = 15	&
		(etat_moteur_ess_av = 27 or etat_moteur_ess_av = 28)
	THEN
		IF etat_moteur_ess_av/=26
		THEN
			IF t_int_av /= 40
			THEN
				IF dmd_commodo=6
				THEN
					etat_moteur_ess_av := 20
				ELSE
					IF dmd_commodo=9
					THEN 
						IF((seuil_depasse_vit2 = 35) & 
							seuil_depasse_vit1 = 35)
						THEN etat_moteur_ess_av := 23
						ELSE etat_moteur_ess_av := 19
						END
					ELSE
						IF dmd_commodo=9
						THEN 
							IF((seuil_depasse_vit2 = 35) & 
								seuil_depasse_vit1 = 35)
							THEN etat_moteur_ess_av := 19
							ELSE etat_moteur_ess_av := 19
							END
						ELSE
							IF dmd_commodo=7
							THEN 
								etat_moteur_ess_av := 23
							ELSE
								etat_moteur_ess_av := 20
							END
						END
					END
				END
			ELSE
				etat_moteur_ess_av := 23
			END
		END
	END;

action_pvi_deb =
	PRE
		alimentation = 15	&
		etat_commodo = 12
	THEN
		IF etat_moteur_ess_av = 20 
		THEN
			etat_moteur_ess_av := 24
		END
	END;

action_pvi_fin = 
	PRE
		alimentation = 15	&
		etat_moteur_ess_av = 24 &
		dmd_commodo = 6 &
		etat_cdp = 33 &
		etat_commodo = 12
	THEN
		IF etat_moteur_ess_av/=26
		THEN
			IF dmd_commodo=6
			THEN
				etat_moteur_ess_av := 20
			ELSE
				IF dmd_commodo=9
				THEN 
					IF((seuil_depasse_vit2 = 35) & 
						seuil_depasse_vit1 = 35)
					THEN etat_moteur_ess_av := 23
					ELSE etat_moteur_ess_av := 19
					END
				ELSE
					IF dmd_commodo=9
					THEN 
						IF((seuil_depasse_vit2 = 35) & 
							seuil_depasse_vit1 = 35)
						THEN etat_moteur_ess_av := 19
						ELSE etat_moteur_ess_av := 19
						END
					ELSE
						IF dmd_commodo=7
						THEN 
							etat_moteur_ess_av := 23
						ELSE
							etat_moteur_ess_av := 20
						END
					END
				END
			END
		END
	END;
	


action_commodo_defaillance_deb =
	PRE
		etat_commodo = 12
	THEN
		etat_commodo := 11   	||
		IF(alimentation=15 & etat_cdp = 33 & 
			etat_moteur_ess_av /= 26 & presence_CDP=35)
		THEN
			etat_moteur_ess_av := 24
		ELSE
			IF  etat_cdp = 32 or presence_CDP = 34
			THEN
				IF  etat_moteur_ess_av /= 26
					& alimentation=15
				THEN
					etat_moteur_ess_av := 23
				END ||
				t_int_av := 40
			END
		END ||
		seuil_depasse_vit2 := 34 ||
		seuil_depasse_vit1 := 34
	END;

action_commodo_defaillance_fin =
	PRE
		etat_commodo = 11
	THEN
		etat_commodo := 12	||
		IF alimentation = 15 &  etat_moteur_ess_av/=26
		THEN
			IF dmd_commodo=6
			THEN
				etat_moteur_ess_av := 20
			ELSE
				IF dmd_commodo=9
				THEN 
					etat_moteur_ess_av := 19
				ELSE
					IF dmd_commodo=9
					THEN 
						etat_moteur_ess_av := 19
					ELSE
						IF dmd_commodo=7
						THEN 
							etat_moteur_ess_av := 23
						ELSE
							IF dmd_commodo = 10 & 
								etat_cdp = 32
							THEN
								etat_moteur_ess_av := 23
							ELSE
								etat_moteur_ess_av := 24
							END
						END
					END
				END
			END
		END ||
		IF((dmd_commodo=9 or dmd_commodo=9) & vitesse_vehicule > VIT2)
		THEN
			seuil_depasse_vit2 := 35
		ELSE
			seuil_depasse_vit2 := 34
		END
		||
		IF dmd_commodo = 9 & seuil_depasse_vit2 = 35 &
			seuil_depasse_vit1 = 35
		THEN
			t_int_av := 41
		ELSE
			IF (dmd_commodo = 10 & etat_cdp = 32)
			THEN
				t_int_av := 40
			ELSE
				IF(type_vitesse = 13)
				THEN
					IF (vitesse_vehicule < 10)
					THEN
						t_int_av := 36
					ELSE
						IF (vitesse_vehicule < 50)
						THEN
							t_int_av := 37
						ELSE
							IF (vitesse_vehicule < 90)
							THEN
								t_int_av := 38
							ELSE
								t_int_av := 39
							END 
						END 
					END
				ELSE
					IF (vitesse_vehicule < 5)
					THEN
						t_int_av := 36
					ELSE
					IF (vitesse_vehicule < 40)
					THEN
						t_int_av := 37
					ELSE
					IF (vitesse_vehicule < 80)
					THEN
						t_int_av := 38
					ELSE
						t_int_av := 39
					END END END
				END
			END
		END
	END;
	
	
action_cdp_defaillant_deb =
	PRE
		etat_cdp = 33 &
		presence_CDP = 35
	THEN
		etat_cdp := 32 ||
		IF (etat_commodo = 11 or dmd_commodo =10) 
		THEN
			IF etat_moteur_ess_av /=26 & alimentation = 15
			THEN
				etat_moteur_ess_av := 23 
			END ||
			t_int_av := 40 
		END
	END;

action_cdp_defaillant_fin =
	PRE
		etat_cdp = 32 &
		presence_CDP = 35
	THEN
		etat_cdp := 33 ||
		IF etat_commodo /= 11 & alimentation = 15 & 
			etat_moteur_ess_av/=26
		THEN
			IF dmd_commodo=6
			THEN
					etat_moteur_ess_av := 20
			ELSE
				IF dmd_commodo=9
				THEN 
					IF((seuil_depasse_vit2 = 35) & seuil_depasse_vit1 = 35)
					THEN etat_moteur_ess_av := 23
					ELSE etat_moteur_ess_av := 19
					END
				ELSE
					IF dmd_commodo=9
					THEN 
						IF((seuil_depasse_vit2 = 35) &
							seuil_depasse_vit1 = 35)
						THEN etat_moteur_ess_av := 19
						ELSE etat_moteur_ess_av := 19
						END
					ELSE
						IF dmd_commodo=7
						THEN 
							etat_moteur_ess_av := 23
						ELSE
							etat_moteur_ess_av := 24
						END
					END
				END
			END
		ELSE
			IF alimentation =15 & etat_moteur_ess_av /= 26
			THEN
				etat_moteur_ess_av := 24
			END
		END ||
		IF dmd_commodo = 9 & seuil_depasse_vit2 = 35 &
			seuil_depasse_vit1 = 35
		THEN
			t_int_av := 41
		ELSE
			IF(type_vitesse = 13)
			THEN
				IF (vitesse_vehicule < 10)
				THEN
					t_int_av := 36
				ELSE
					IF (vitesse_vehicule < 50)
					THEN
						t_int_av := 37
					ELSE
						IF (vitesse_vehicule < 90)
						THEN
							t_int_av := 38
						ELSE
							t_int_av := 39
						END 
					END 
				END
			ELSE
				IF (vitesse_vehicule < 5)
				THEN
					t_int_av := 36
				ELSE
				IF (vitesse_vehicule < 40)
				THEN
					t_int_av := 37
				ELSE
				IF (vitesse_vehicule < 80)
				THEN
					t_int_av := 38
				ELSE
					t_int_av := 39
				END END END
			END
		END
	END;
	
bloquer_le_moteur_ess_av =
	PRE
		etat_moteur_ess_av /= 26
	THEN
		etat_moteur_ess_av := 26
	END;

depasser_temps_maintenance = 
	PRE
		depassement_temps_maintenance = 34 		&
		alimentation = 17
	THEN
		depassement_temps_maintenance := 35
	END;
	
depasser_temps_perte_acc =
	PRE
		alimentation = 17		&
		t_perte_acc_depasse = 34
	THEN
		t_perte_acc_depasse := 35
	END;

alimentation_acc =
	PRE
		alimentation /= 15	&
		vitesse_vehicule = 0
	THEN
		IF (alimentation = 17 & t_perte_acc_depasse = 35)
		THEN
			IF etat_moteur_ess_av/=26 & 
				etat_moteur_ess_av /= 22
			THEN
				IF t_int_av = 40
				THEN
					IF dmd_commodo = 10
					THEN
						etat_moteur_ess_av := 20
					ELSE
						etat_moteur_ess_av := 23
					END
				ELSE
					IF etat_commodo=11
					THEN
						etat_moteur_ess_av := 24
					ELSE
						etat_moteur_ess_av := 20
					END
				END
			ELSE
				IF etat_moteur_ess_av = 22 & t_int_av = 40 &
						dmd_commodo /= 10
				THEN
					etat_moteur_ess_av := 23
				END
			END	||
			IF (t_int_av = 40 & dmd_commodo = 10) or 
				(t_int_av = 41)
			THEN
				t_int_av := 36
			END ||
			dmd_commodo := 6||
			seuil_depasse_vit1 := 34 ||
			seuil_depasse_vit2 := 34 
		ELSE
			IF etat_moteur_ess_av/=26 & etat_moteur_ess_av /= 
				22
			THEN
				IF t_int_av = 40
				THEN
					etat_moteur_ess_av := 23
				ELSE
					IF etat_commodo=11
					THEN
						etat_moteur_ess_av := 24
					ELSE
						IF dmd_commodo=6
						THEN
							etat_moteur_ess_av := 20
						ELSE
							IF dmd_commodo=9
							THEN 
							IF((seuil_depasse_vit2 = 35) & 
								seuil_depasse_vit1 =35 )
							THEN etat_moteur_ess_av := 23
							ELSE etat_moteur_ess_av := 19
							END
							ELSE
							IF dmd_commodo=9
							THEN 
							IF((seuil_depasse_vit2 = 35) & 
								seuil_depasse_vit1 = 35)
							THEN etat_moteur_ess_av := 19
							ELSE etat_moteur_ess_av := 19
							END
							ELSE
							IF dmd_commodo=7
							THEN etat_moteur_ess_av := 23
							ELSE etat_moteur_ess_av := 24
							END
							END
							END
						END
					END
				END
			ELSE
				IF etat_moteur_ess_av = 22 & t_int_av = 40 &
						dmd_commodo /= 10
				THEN
					etat_moteur_ess_av := 23
				END
			END
		END 	||
		alimentation := 15		||
		t_perte_acc_depasse := 34		||
		depassement_temps_maintenance := 34 
	END;			

alimentation_dem =
	PRE
		alimentation = 15	&
		vitesse_vehicule = 0
	THEN
		alimentation := 16		||
		depassement_temps_maintenance := 34 ||
		t_perte_acc_depasse := 34 ||
		IF etat_moteur_ess_av /= 26
		THEN
			etat_moteur_ess_av := 21
		END
	END;
	
alimentation_coupe =
	PRE
		alimentation = 15 &
		vitesse_vehicule = 0
	THEN
		alimentation := 17		||
		depassement_temps_maintenance := 34	||
		t_perte_acc_depasse := 34 ||
		IF etat_moteur_ess_av /= 26
		THEN
			etat_moteur_ess_av := 20
		END
	END;
	


action_CDP_pv =
	SELECT
		alimentation  = 15	&
		(dmd_commodo = 10 or etat_commodo = 11) &
		etat_cdp = 33 &
		presence_CDP = 35
	THEN
		cdp := 29			||
		IF(etat_moteur_ess_av /= 26)
		THEN
			etat_moteur_ess_av := 19
		END
	END;

action_CDP_gv =
	SELECT
		alimentation = 15	&
		(dmd_commodo = 10 or etat_commodo = 11) &
		etat_cdp = 33 &
		presence_CDP = 35
	THEN
		cdp := 30			||
		IF(etat_moteur_ess_av /= 26)
		THEN
			etat_moteur_ess_av := 25
		END
	END;

action_CDP_arret =
	SELECT
		alimentation = 15	&
		(dmd_commodo = 10 or etat_commodo = 11) &
		etat_cdp = 33 &
		presence_CDP = 35
	THEN
		IF(etat_moteur_ess_av /= 26)
		THEN
			etat_moteur_ess_av := 20
		END			||
		cdp := 31
	END;



deceleration(varvit) =
	PRE
		varvit : VITESSE		&
		alimentation = 15	&
		(varvit <= vitesse_vehicule) 
	THEN
		IF((dmd_commodo = 9  or dmd_commodo = 9) & seuil_depasse_vit2 = 35 & 
			(vitesse_vehicule - varvit < VIT1 or seuil_depasse_vit1 = 35))
		THEN
			seuil_depasse_vit1 := 35 ||
			IF(dmd_commodo = 9 & t_int_av /= 40)
			THEN
				IF(etat_moteur_ess_av/=26)
				THEN
					etat_moteur_ess_av := 23		
				END ||
				t_int_av := 41
			ELSE
				IF(dmd_commodo_user = 4 & t_int_av /= 40)
				THEN
					etat_moteur_ess_av := 19	||
					IF (vitesse_vehicule - varvit < 5)
					THEN
						t_int_av := 36
					ELSE
					IF (vitesse_vehicule - varvit < 40)
					THEN
						t_int_av := 37
					ELSE
					IF (vitesse_vehicule - varvit < 80)
					THEN
						t_int_av := 38
					ELSE
						t_int_av := 39
					END END	END
				END
			END
		ELSE
			IF t_int_av /= 40
			THEN
				IF ((vitesse_vehicule - varvit) < 5)
				THEN
					t_int_av := 36
				ELSE
				IF (vitesse_vehicule - varvit < 40)
				THEN
					t_int_av := 37
				ELSE
				IF (vitesse_vehicule - varvit < 80)
				THEN
					t_int_av := 38
				ELSE
					t_int_av := 39
				END END END
			END
		END ||
		vitesse_vehicule := vitesse_vehicule - varvit	||
		type_vitesse := 14
	END	

	
END

