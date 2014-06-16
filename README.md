DESIGN: (1).MIPS CORE Implemention. (2).With 5 stage pipeline. (3).Hazard detction unit  (4).Forwarding unit

INCLUDE INST:
    1. Arithmetic: ADD,ADDI,SUB,MULT,DIV,MFHI,MFLO 
	2. Data transfer:
		LUI, 
		LW, 
		SW, 
		LHU, 
		SH, 
		LBU, 
		SB 
	3. Logic: 
		AND,
		OR, 
		ORI, 
		SRL, 
		SRLV
	4. Jump & Compare: 
		BEQ
		BGT,
		BNEZ,
		BGEZ,
		LUI 
		jump, 
		jal, 
		jr 
	5. ETC:
		SLT,
		multiple load store: up to 21 addr in one inst
		
