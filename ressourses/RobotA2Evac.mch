MACHINE 
	RobotA2Evac

SETS	
	Cote = {g, 
	d}; 
	Position = {h
	, b};
	EtatD = {l, T1, T2, T3}

VARIABLES	
	Deg, Dt, Ded, CoteDt, PosDt, Da

INVARIANT
	Deg : EtatD-{T2} & Ded : EtatD-{T1} & Dt : EtatD &
	CoteDt : Cote & PosDt : Position & Da : EtatD &
	((CoteDt=d & Dt /= l) => (Dt=T2 or (Dt=T3 & Ded=l))) &
	(PosDt=b => CoteDt=g)

INITIALISATION	
	Deg, Dt, Ded, Da := l, l, l, l 
	|| CoteDt := g 
	|| PosDt := b

OPERATIONS
	A_P = 
		SELECT 
			Da=l 
		THEN
			ANY p WHERE p : EtatD-{l} THEN Da := p END
		END;

	Chargt = 
		SELECT 
			Dt=l & Da/=l & CoteDt=g & PosDt=b 
		THEN 
			Dt := Da || Da := l
		END;

	EvacG =
		SELECT 
			Deg/=l 
		THEN 
			Deg := l 
		END;
	
	EvacD = 
		SELECT 
			Ded/=l 
		THEN 
			Ded := l 
		END;

	Montee =
		SELECT 
			PosDt=b & Dt/=l 
		THEN 
			PosDt := h 
		END;

	Descente =
		SELECT 
			PosDt=h & Dt=l & CoteDt=g 
		THEN 
			PosDt := b 
		END;

	RotationD =
		SELECT 
			PosDt=h & CoteDt=g & (Dt=T2 or (Dt=T3 & Ded=l & Deg/=l))
		THEN 
			CoteDt := d 
		END;

	RotationG =
		SELECT 
			PosDt=h & CoteDt=d & (Dt=l or (Dt=T3 & Deg=l))
		THEN 
			CoteDt := g 
		END;

	Dechargt =
		SELECT 
			PosDt=h & ((Deg=l & CoteDt=g & Dt : {T1, T3}) or (Ded=l & CoteDt=d & (Dt=T2 or (Dt=T3 & Deg/=l))))
		THEN
			IF 
				Deg=l & CoteDt=g 
			THEN 
				Deg := Dt 
			ELSE 
				Ded := Dt 
			END
			|| Dt := l 
		END
END


