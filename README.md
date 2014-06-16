 <h2>DESIGN:</h2><br/>
 ==========================================================<br/>
   (1).MIPS CORE Implemention. <br/>
   (2).With 5 stage pipeline. <br/>
   (3).Hazard detction unit.  <br/>
   (4).Forwarding unit. <br/>

 <h2>INCLUDE INST:</h2><br/>
 ==========================================================<br/>
 <h3>1. Arithmetic:</h3><br/> 
 	ADD,<br/>
 	ADDI,<br/>
 	SUB,<br/>
 	MULT,<br/>
 	DIV,<br/>
 	MFHI,<br/>
 	MFLO <br/>
2. Data transfer:LUI,LW,SW,LHU,SH,LBU,SB 
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
		
