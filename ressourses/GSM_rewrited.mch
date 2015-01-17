/**********************************************************************************************/
/*                                  GSM 11.11 - VERSION LONGUE                                */
/**********************************************************************************************/

MACHINE
	GSM  

SETS
	PERMISSION = {always,chv1,chv2,adm,never};
	VALUE = {ltg_true, ltg_false};
	FILES = {NOFILES, mf,df_gsm,ef_iccid,ef_lp,ef_imsi,ef_kc,ef_ad};
	ENABLED_STATUS = {enabled, disabled};
	BLOCKED_STATUS = {blocked, unblocked};
	CODE = {a1,a2,a3,a4};
	DATA = {NO_DATA,d1,d2,d3,d4,d5};
	STATUS_WORDS = {SW_9000,SW_9001,SW_9400,SW_9404,SW_9804,SW_9808,SW_9840}
	
CONSTANTS
	MAX_CHV,
	MAX_UNBLOCK

PROPERTIES
	MAX_UNBLOCK = 10 &
	MAX_CHV = 3

VARIABLES 
	PARENT_FILES,
	PERMISSION_READ,
	PERMISSION_UPDATE,
	CODE_UNBLOCK,

	current_file,
	current_directory,
	counter_chv,
	counter_unblock,
	code_chv,
	permission_session,
	enabled_chv1_status,
	blocked_chv_status,
	blocked_status,
	data,
	sw, dd_out

INVARIANT
	CODE_UNBLOCK : {chv1,chv2} --> CODE &
	CODE_UNBLOCK(chv1)=a3 & CODE_UNBLOCK(chv2)=a4 &
	PARENT_FILES : FILES --> FILES &
	PARENT_FILES(df_gsm)=mf & PARENT_FILES(ef_iccid)=mf & PARENT_FILES(ef_lp)=df_gsm & PARENT_FILES(ef_imsi)=df_gsm & PARENT_FILES(ef_kc)=df_gsm & PARENT_FILES(ef_ad)=df_gsm &
	PERMISSION_READ : {ef_iccid,ef_lp,ef_imsi,ef_kc,ef_ad} --> PERMISSION &
	PERMISSION_READ(ef_iccid)=always & PERMISSION_READ(ef_lp)=always & PERMISSION_READ(ef_imsi)=chv1 & PERMISSION_READ(ef_kc)=chv1 & PERMISSION_READ(ef_ad)=always &
	PERMISSION_UPDATE : {ef_iccid,ef_lp,ef_imsi,ef_kc,ef_ad} --> PERMISSION &
	PERMISSION_UPDATE(ef_iccid)=never & PERMISSION_UPDATE(ef_lp)=chv1 & PERMISSION_UPDATE(ef_imsi)=adm & PERMISSION_UPDATE(ef_kc)=chv1 & PERMISSION_UPDATE(ef_ad)=adm &

	current_file : FILES-{mf,df_gsm} &
	current_directory : FILES-{NOFILES,ef_iccid,ef_lp,ef_imsi,ef_kc,ef_ad} &
	counter_chv : {chv1,chv2} --> 0..MAX_CHV &
	counter_unblock : {chv1,chv2} --> 0..MAX_UNBLOCK &
	code_chv : {chv1,chv2} --> CODE &
	permission_session : PERMISSION --> VALUE & 
	enabled_chv1_status : ENABLED_STATUS &
	blocked_chv_status : {chv1,chv2} --> BLOCKED_STATUS &
	blocked_status : {chv1,chv2} --> BLOCKED_STATUS &
	data : {ef_iccid,ef_lp,ef_imsi,ef_kc,ef_ad} --> DATA &
	(counter_chv(chv1)=0) <=> (blocked_chv_status(chv1)=blocked) &
	(counter_chv(chv2)=0) <=> (blocked_chv_status(chv2)=blocked) &
	(counter_unblock(chv1)=0) <=> (blocked_chv_status(chv1)=blocked) &
	(counter_unblock(chv2)=0) <=> (blocked_chv_status(chv2)=blocked) &
	(current_file = NOFILES or (PARENT_FILES(current_file) = current_directory)) &
	sw : STATUS_WORDS & dd_out : DATA
 
INITIALISATION
	current_file := NOFILES ||
	current_directory := mf ||
	counter_chv(chv1):=MAX_CHV || counter_chv(chv2):=MAX_CHV ||
	counter_unblock(chv1):=MAX_UNBLOCK || counter_unblock(chv2):=MAX_UNBLOCK ||
	code_chv(chv1):=a1 || code_chv(chv2):=a2 ||
	enabled_chv1_status := enabled ||
	blocked_chv_status(chv1):=unblocked || blocked_chv_status(chv2):=unblocked ||
	blocked_status(chv1):=unblocked || blocked_status(chv2):=unblocked ||
	permission_session(always):=ltg_true || permission_session(chv1):=ltg_false || permission_session(chv2):=ltg_false || permission_session(adm):=ltg_false || permission_session(never):=ltg_false ||
	data(ef_iccid):=d1 || data(ef_lp):=d2 || data(ef_imsi):=d3 || data(ef_kc):=d4 || data(ef_ad):=d5 ||
	sw := SW_9000 || dd_out := NO_DATA

OPERATIONS

	STATUS = 
		BEGIN	
			skip
		END;  


	RESET =
		SELECT 
			(permission_session(always) = ltg_true or permission_session(always) = ltg_false)
		THEN
			current_file := NOFILES ||
			current_directory := mf ||
			permission_session(always):=ltg_true || permission_session(chv1):=ltg_false || permission_session(chv2):=ltg_false || permission_session(adm):=ltg_false || permission_session(never):=ltg_false
		END;


	SELECT_FILE =  
		ANY
			ff
		WHERE
			ff : {NOFILES, mf,df_gsm,ef_iccid,ef_lp,ef_imsi,ef_kc,ef_ad}
		THEN 
			IF ((ff=mf) or (ff=df_gsm)) THEN
				IF ((PARENT_FILES(ff) = current_directory) or (PARENT_FILES(current_directory) = ff) or (ff = mf))
				THEN
					sw := SW_9000 ||
					current_directory := ff ||	
					current_file := NOFILES
				ELSE
					sw := SW_9404
				END
			ELSE 
				IF (PARENT_FILES(ff) = current_directory) 
				THEN
					sw := SW_9000 ||
					current_file := ff
				ELSE
					sw := SW_9404
				END
			END
		END;
			

	READ_BINARY =  
		SELECT
			current_file : {ef_iccid,ef_lp,ef_imsi,ef_kc,ef_ad}
		THEN 
			IF (current_file = NOFILES)
			THEN
				sw := SW_9400 
			ELSE
				IF ((permission_session(PERMISSION_READ(current_file)) = ltg_true) or 
					(PERMISSION_READ(current_file)	= chv1 & enabled_chv1_status = disabled))
				THEN
					sw := SW_9000 ||
					dd_out := data(current_file)
				ELSE
					sw := SW_9804 	
				END
			END 
		END;


	UPDATE_BINARY =  
		ANY
			dd
		WHERE
			dd : {NO_DATA,d1,d2,d3,d4,d5} &
			current_file : {ef_iccid,ef_lp,ef_imsi,ef_kc,ef_ad}  
		THEN
			IF (current_file = NOFILES)
			THEN
				sw := SW_9400 
			ELSE
				IF ((permission_session(PERMISSION_UPDATE(current_file)) = ltg_true) or
					(PERMISSION_UPDATE(current_file) = chv1 & enabled_chv1_status = disabled))	 
 				THEN
					sw := SW_9000 ||
					data(current_file) := dd
				ELSE
					sw := SW_9804
				END
			END
		 END;  


	CHANGE_CHV = 
		ANY
			cc, old_code_cc, new_code_cc
		WHERE
			cc : {chv1,chv2}  &
			old_code_cc : {a1,a2,a3,a4} &
			new_code_cc : {a1,a2,a3,a4}
		THEN 
			IF (blocked_chv_status(cc) = blocked)
			THEN			
				sw := SW_9840
			ELSE
				IF ((cc=chv1) & enabled_chv1_status = disabled)
				THEN			
					sw := SW_9808
				ELSE
					IF (code_chv(cc)= old_code_cc)
					THEN
						code_chv(cc) := new_code_cc ||
						counter_chv(cc) := MAX_CHV ||
						permission_session(cc) := ltg_true ||
						sw := SW_9000
					ELSE
						IF (counter_chv(cc) = 1)
						THEN 
							counter_chv(cc) := 0 ||
							blocked_chv_status(cc) := blocked ||
							permission_session(cc) := ltg_false ||
							sw := SW_9840 
						ELSE
							counter_chv(cc) := counter_chv(cc) - 1 ||
							sw := SW_9804
						END
					END	
				END
			END
		END;


	VERIFY_CHV =  
		ANY
			cc, code_cc
		WHERE
			cc : {chv1,chv2} &
			code_cc : {a1,a2,a3,a4}
		THEN 
			IF (blocked_chv_status(cc) = blocked)
			THEN			
				sw := SW_9840
			ELSE
				IF ((cc=chv1) & enabled_chv1_status = disabled)
				THEN			
					sw := SW_9808
				ELSE
					IF (code_chv(cc) = code_cc)
					THEN
						counter_chv(cc) := MAX_CHV ||
						permission_session(cc) := ltg_true ||
						sw := SW_9000
					ELSE
						IF (counter_chv(cc) = 1)
						THEN 
							counter_chv(cc) := 0 ||
							blocked_chv_status(cc) := blocked ||
							permission_session(cc) := ltg_false ||
							sw := SW_9840 
						ELSE
							counter_chv(cc) := counter_chv(cc) - 1 ||
							sw := SW_9804
						END
					END	
				END
			END
		END;		


	UNBLOCK_CHV = 
		ANY
			cc, code_unblock_cc, new_code_cc
		WHERE
			cc : {chv1,chv2}  &
			code_unblock_cc : {a1,a2,a3,a4} &
			new_code_cc : {a1,a2,a3,a4}
		THEN 
			IF (blocked_status(cc) = blocked)
			THEN			
				sw := SW_9840
			ELSE
				IF (CODE_UNBLOCK(cc) = code_unblock_cc) 
				THEN
					code_chv(cc) := new_code_cc ||
					blocked_chv_status(cc) := unblocked ||
					counter_chv(cc) := MAX_CHV ||
					counter_unblock(cc) := MAX_UNBLOCK ||
					permission_session(cc) := ltg_true ||
					sw := SW_9000 ||
					IF (cc = chv1)
					THEN
						enabled_chv1_status := enabled
					END
				ELSE
					IF (counter_unblock(cc) = 1)
					THEN 
						counter_unblock(cc) := 0 ||
						blocked_status(cc) := blocked ||
						sw := SW_9840 
					ELSE
						counter_unblock(cc) := counter_unblock(cc) - 1 ||
						sw := SW_9804
					END
				END	
			END
		END;


	ENABLE_CHV =  
		ANY
			code_cc
		WHERE
			code_cc : {a1,a2,a3,a4}
		THEN
			IF (blocked_chv_status(chv1) = blocked)
			THEN
				sw := SW_9840
			ELSE
				IF (enabled_chv1_status = enabled)
				THEN
					sw := SW_9808
				ELSE
					IF (code_chv(chv1) = code_cc)
					THEN
						counter_chv(chv1) := MAX_CHV ||
						enabled_chv1_status := enabled ||
						permission_session(chv1) := ltg_true ||
						sw := SW_9000
					ELSE
						IF (counter_chv(chv1) = 1)
						THEN 
							counter_chv(chv1) := 0 ||
							blocked_chv_status(chv1) := blocked ||
							permission_session(chv1) := ltg_false ||
							enabled_chv1_status := enabled ||
							sw := SW_9840 
						ELSE
							counter_chv(chv1) := counter_chv(chv1) - 1 ||
							sw := SW_9804
						END
					END
				END
			END	
		END;


	DISABLE_CHV =  
		ANY
			code_cc
		WHERE
			code_cc : {a1,a2,a3,a4}
		THEN
			IF (blocked_chv_status(chv1) = blocked)
			THEN
				sw := SW_9840
			ELSE
				IF (enabled_chv1_status = disabled)
				THEN
					sw := SW_9808
				ELSE
					IF (code_cc = code_chv(chv1))
					THEN
						counter_chv(chv1) := MAX_CHV ||
						enabled_chv1_status := disabled ||
						permission_session(chv1) := ltg_true ||
						sw := SW_9000
					ELSE
						IF (counter_chv(chv1) = 1)
						THEN 
							counter_chv(chv1) := 0 ||
							blocked_chv_status(chv1) := blocked ||
							permission_session(chv1) := ltg_false ||
							enabled_chv1_status := enabled ||
							sw := SW_9840 
						ELSE
							counter_chv(chv1) := counter_chv(chv1) - 1 ||
							enabled_chv1_status := enabled ||
							sw := SW_9804
						END
					END
				END
			END	
		END

END
