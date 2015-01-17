/**********************************************************************************************/
/*                                  GSM 11.11 - VERSION LONGUE                                */
/**********************************************************************************************/

MACHINE
	GSM  

SETS
	PERMISSION = {always,chv1,chv2,adm,never};
	VALUE = {true, false};
	FILES = {mf,df_gsm,ef_iccid,ef_lp,ef_imsi,ef_kc,ef_ad};
	ENABLED_STATUS = {enabled, disabled};
	BLOCKED_STATUS = {blocked, unblocked};
	CODE = {a1,a2,a3,a4};
	DATA = {d1,d2,d3,d4,d5}
	
CONSTANTS
	MAX_CHV,
	MAX_UNBLOCK,
	FILES_CHILDREN,
	PERMISSION_READ,
	PERMISSION_UPDATE,
	CODE_UNBLOCK

PROPERTIES
	
	MAX_UNBLOCK = 10 &
	CODE_UNBLOCK : CHV --> CODE &
	CODE_UNBLOCK = {(chv1|->a3),(chv2|->a4)} &
	FILES_CHILDREN : FILES <-> FILES &
	MAX_CHV = 3  &
	FILES_CHILDREN = {(mf|->df_gsm), (mf|->ef_iccid),(df_gsm|->ef_lp),(df_gsm|->ef_imsi),(df_gsm|->ef_kc),(df_gsm|->ef_ad)} &
	PERMISSION_READ : EF --> PERMISSION &
	PERMISSION_READ = {(ef_iccid|->always),(ef_lp|->always),(ef_imsi|->chv1),(ef_kc|-> chv1),(ef_ad|->always)} &
	PERMISSION_UPDATE : EF --> PERMISSION &
	PERMISSION_UPDATE = {(ef_iccid|->never),(ef_lp|->chv1),(ef_imsi|->adm),(ef_kc|-> chv1),(ef_ad|->adm)} 


DEFINITIONS
	COUNTER_CHV == 0..MAX_CHV;
	COUNTER_UNBLOCK == 0..MAX_UNBLOCK;
	MF == {mf};
	DF == {df_gsm};
	EF_TRANSPARENT == {ef_iccid,ef_lp,ef_imsi,ef_kc,ef_ad};
	EF == EF_TRANSPARENT;
	CHV == {chv1,chv2}

VARIABLES 
	current_file,
	current_directory,
	counter_chv,
	counter_unblock,
	code_chv,
	permission_session,
	enabled_chv1_status,
	blocked_chv_status,
	blocked_status,
	data

INVARIANT
	current_file <: EF &
	card(current_file) <= 1 &
	current_directory : DF \/ MF &
	counter_chv : CHV --> COUNTER_CHV &
	counter_unblock : CHV --> COUNTER_UNBLOCK &
	code_chv : CHV --> CODE &
	permission_session : PERMISSION --> VALUE & 
	enabled_chv1_status : ENABLED_STATUS &
	blocked_chv_status : CHV --> BLOCKED_STATUS &
	blocked_status : CHV --> BLOCKED_STATUS &
	data : EF --> DATA &
	((chv1|->0) : counter_chv) <=> ((chv1|->blocked) : blocked_chv_status) &
	((chv2|->0) : counter_chv) <=> ((chv2|->blocked) : blocked_chv_status) &
	((chv1|->0) : counter_unblock) <=> ((chv1|->blocked) : blocked_status) &
	((chv2|->0) : counter_unblock) <=> ((chv2|->blocked) : blocked_status) &
	(current_file = {} or (dom(FILES_CHILDREN |> current_file) = {current_directory}))
 
INITIALISATION
	current_file := {} ||
	current_directory := mf ||
	counter_chv := {(chv1|->MAX_CHV), (chv2|->MAX_CHV)} ||
	counter_unblock := {(chv1|->MAX_UNBLOCK), (chv2|->MAX_UNBLOCK)} ||
	code_chv := {(chv1|->a1),(chv2|->a2)} ||
	enabled_chv1_status := enabled ||
	blocked_chv_status := {(chv1|->unblocked), (chv2|->unblocked)} ||
	blocked_status := {(chv1|->unblocked), (chv2|->unblocked)} ||
	permission_session := {(always|->true),(chv1|->false),(chv2|->false),(adm|->false),(never|->false)} ||
	data := {(ef_iccid|->d1),(ef_lp|->d2),(ef_imsi|->d3),(ef_kc|-> d4),(ef_ad|->d5)} 

OPERATIONS

	STATUS = 
		BEGIN	
			skip
		END;  


	RESET =
		BEGIN
			current_file := {} ||
			current_directory := mf ||
			permission_session := {(always|->true),(chv1|->false), (chv2|->false), (adm|->false), (never|->false)} 
		END;


	sw <-- SELECT_FILE(ff) =  
		PRE
			ff : FILES 
		THEN 
			IF (((current_directory|->ff) /: FILES_CHILDREN) &
				(#(dp).(dp : FILES & ((dp|->current_directory) /: FILES_CHILDREN or (dp|->ff) /: FILES_CHILDREN))) &
				((ff|->current_directory) /: FILES_CHILDREN) &
				(ff /= mf) &
				(ff /= current_directory)) 
			THEN
				sw := 9404
			ELSE
				sw := 9001 ||
				IF (ff : DF \/ MF) 
				THEN
					current_directory := ff ||	
					current_file := {} 
				ELSE
					current_file := {ff} 
				END
			END
		END;
			

	sw,dd <-- READ_BINARY =  
		 PRE 
			current_file <: EF_TRANSPARENT 
		 THEN 
			IF (current_file = {})
			THEN
				sw := 9400 
			ELSE
				IF ((permission_session[PERMISSION_READ[current_file]] = {true}) or 
					(PERMISSION_READ[current_file]	= {chv1} & enabled_chv1_status = disabled))
				THEN
					sw := 9000 ||
					ANY ff WHERE (ff : current_file) 
					THEN
						dd := data(ff)
					END		
				ELSE
					sw := 9804 	
				END
			END 
		END;


	sw <-- UPDATE_BINARY(dd) =  
		 PRE 
			dd : DATA &
			current_file <: EF_TRANSPARENT  
		 THEN
			IF (current_file = {})
			THEN
				sw := 9400 
			ELSE
				IF ((permission_session[PERMISSION_UPDATE[current_file]] = {true}) or
				(PERMISSION_UPDATE[current_file] = {chv1} & enabled_chv1_status = disabled))	 
 				THEN
					sw := 9000 ||
					ANY ff WHERE ff : current_file 
					THEN
						data(ff) := dd
					END
				ELSE
					sw := 9804
				END
			END
		 END;  


	sw <-- CHANGE_CHV(cc, old_code_cc, new_code_cc) = 
		PRE
			cc : CHV  &
			old_code_cc : CODE &
			new_code_cc : CODE
		THEN 
			IF (blocked_chv_status(cc) = blocked)
			THEN			
				sw := 9840
			ELSE
				IF ((cc=chv1) & enabled_chv1_status = disabled)
				THEN			
					sw := 9808
				ELSE
					IF (code_chv(cc)= old_code_cc)
					THEN
						code_chv(cc) := new_code_cc ||
						counter_chv(cc) := MAX_CHV ||
						permission_session(cc) := true ||
						sw := 9000
					ELSE
						IF (counter_chv(cc) = 1)
						THEN 
							counter_chv(cc) := 0 ||
							blocked_chv_status(cc) := blocked ||
							permission_session(cc) := false ||
							sw := 9840 
						ELSE
							counter_chv(cc) := counter_chv(cc) - 1 ||
							sw := 9804
						END
					END	
				END
			END
		END;


	sw <-- VERIFY_CHV(cc, code_cc) =  
		 PRE 
			cc : CHV &
			code_cc : CODE
		 THEN 
			IF (blocked_chv_status(cc) = blocked)
			THEN			
				sw := 9840
			ELSE
				IF ((cc=chv1) & enabled_chv1_status = disabled)
				THEN			
					sw := 9808
				ELSE
					IF (code_chv(cc) = code_cc)
					THEN
						counter_chv(cc) := MAX_CHV ||
						permission_session(cc) := true ||
						sw := 9000
					ELSE
						IF (counter_chv(cc) = 1)
						THEN 
							counter_chv(cc) := 0 ||
							blocked_chv_status(cc) := blocked ||
							permission_session(cc) := false ||
							sw := 9840 
						ELSE
							counter_chv(cc) := counter_chv(cc) - 1 ||
							sw := 9804
						END
					END	
				END
			END
		END;		


	sw <-- UNBLOCK_CHV(cc, code_unblock_cc, new_code_cc) = 
		PRE
			cc : CHV  &
			code_unblock_cc : CODE &
			new_code_cc : CODE
		THEN 
			IF (blocked_status(cc) = blocked)
			THEN			
				sw := 9840
			ELSE
				IF (CODE_UNBLOCK(cc) = code_unblock_cc) 
				THEN
					code_chv(cc) := new_code_cc ||
					blocked_chv_status(cc) := unblocked ||
					counter_chv(cc) := MAX_CHV ||
					counter_unblock(cc) := MAX_UNBLOCK ||
					permission_session(cc) := true ||
					sw := 9000 ||
					IF (cc = chv1)
					THEN
						enabled_chv1_status := enabled
					END
				ELSE
					IF (counter_unblock(cc) = 1)
					THEN 
						counter_unblock(cc) := 0 ||
						blocked_status(cc) := blocked ||
						sw := 9840 
					ELSE
						counter_unblock(cc) := counter_unblock(cc) - 1 ||
						sw := 9804
					END
				END	
			END
		END;


	sw <-- ENABLE_CHV(code_cc) =  
		 PRE
			code_cc : CODE
		 THEN
			IF (blocked_chv_status(chv1) = blocked)
			THEN
				sw := 9840
			ELSE
				IF (enabled_chv1_status = enabled)
				THEN
					sw := 9808
				ELSE
					IF (code_chv(chv1) = code_cc)
					THEN
						counter_chv(chv1) := MAX_CHV ||
						enabled_chv1_status := enabled ||
						permission_session(chv1) := true ||
						sw := 9000
					ELSE
						IF (counter_chv(chv1) = 1)
						THEN 
							counter_chv(chv1) := 0 ||
							blocked_chv_status(chv1) := blocked ||
							permission_session(chv1) := false ||
							enabled_chv1_status := enabled ||
							sw := 9840 
						ELSE
							counter_chv(chv1) := counter_chv(chv1) - 1 ||
							sw := 9804
						END
					END
				END
			END	
		END;


	sw <-- DISABLE_CHV(code_cc) =  
		 PRE
			code_cc : CODE
		 THEN
			IF (blocked_chv_status(chv1) = blocked)
			THEN
				sw := 9840
			ELSE
				IF (enabled_chv1_status = disabled)
				THEN
					sw := 9808
				ELSE
					IF (code_cc = code_chv(chv1))
					THEN
						counter_chv(chv1) := MAX_CHV ||
						enabled_chv1_status := disabled ||
						permission_session(chv1) := true ||
						sw := 9000
					ELSE
						IF (counter_chv(chv1) = 1)
						THEN 
							counter_chv(chv1) := 0 ||
							blocked_chv_status(chv1) := blocked ||
							permission_session(chv1) := false ||
							enabled_chv1_status := enabled ||
							sw := 9840 
						ELSE
							counter_chv(chv1) := counter_chv(chv1) - 1 ||
							enabled_chv1_status := enabled ||
							sw := 9804
						END
					END
				END
			END	
		END

END
