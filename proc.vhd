LIBRARY ieee; USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;

ENTITY proc IS
PORT ( 
DIN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
Resetn, Clock, Run : IN STD_LOGIC;
--reg_display : BUFFER STD_LOGIC_VECTOR(31 DOWNTO 0);
BusWires : BUFFER STD_LOGIC_VECTOR(15 DOWNTO 0);
Done : BUFFER STD_LOGIC;
UpCount : out std_logic_vector(1 downto 0)
);
END proc;

ARCHITECTURE Behavior OF proc IS
-- declare components
COMPONENT dec3to8 
PORT ( W : IN STD_LOGIC_VECTOR(2 DOWNTO 0); 
	   En : IN STD_LOGIC; 
		 Y : OUT STD_LOGIC_VECTOR(0 TO 7)); 
END COMPONENT; 
 
 
COMPONENT regn 
GENERIC (n : INTEGER := 16);
PORT ( 		R : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
	Rin, Clock : IN STD_LOGIC;
				Q : BUFFER STD_LOGIC_VECTOR(n-1 DOWNTO 0)
);
END COMPONENT; 

-- declare signals
TYPE State_type IS (T0, T1, T2, T3); 
SIGNAL Tstep_Q, Tstep_D: State_type;

SIGNAL R0, R1, R2, R3, R4, R5, R6, R7, A, G : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL IR : STD_LOGIC_VECTOR(1 to 9);
SIGNAL Rin, Rout : STD_LOGIC_VECTOR(0 TO 7);

SIGNAL HIGH, IRin, DINout, Ain, Gin, Gout : STD_LOGIC;
SIGNAL Xreg, Yreg : STD_LOGIC_VECTOR(0 to 7);  
SIGNAL I : std_LOGIC_VECTOR (2 downto 0);

SIGNAL alu_result : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL Sel : STD_LOGIC_VECTOR(1 to 10);

BEGIN
High <= '1';
I <= IR(1 TO 3); 
decX: dec3to8 PORT MAP (IR(4 TO 6), High, Xreg);
decY: dec3to8 PORT MAP (IR(7 TO 9), High, Yreg);

statetable: PROCESS (Tstep_Q, Run, Done)
BEGIN
CASE Tstep_Q IS

	WHEN T0 => 
		IF(Run = '0') THEN Tstep_D <= T0;
		ELSE 
			Tstep_D <=T1;
		END IF; 
	
	WHEN T1 =>
		IF (Done = '1') THEN Tstep_D <= T0;
			ELSE Tstep_D <= T2;
		END IF;
	
	WHEN T2 =>
		Tstep_D <= T3;
	
	WHEN T3 =>
		Tstep_D <= T0;

END CASE;
END PROCESS;

controlsignals: PROCESS (Tstep_Q, I, Xreg, Yreg)
BEGIN
-- specify initial values

DONE <= '0';
Ain <= '0';
Gin <= '0';
Gout <= '0';
IRin <= '0';
Rin <= "00000000";
Rout <= "00000000";
DINout <= '0';

 CASE Tstep_Q IS
	WHEN T0 =>
		IRin <= '1';
	WHEN T1 =>
		CASE I IS
			when "000" =>  -- mv
				Rout <= Yreg;
				Rin <= Xreg;
				DONE <= '1';
			when "001" =>  -- mvi
				DINout <= '1';
				Rin <= Xreg;
				DONE <= '1';
			when "010" =>  -- add
				Rout <= Xreg;
				Ain <= '1';
			when "011" =>  -- sub
				Rout <= Xreg;
				Ain <= '1';
			when "100" =>  -- and
				Rout <= Xreg;
				Ain <= '1';
			when "101" =>  -- or
				Rout <= Xreg;
				Ain <= '1';	
			when "110" =>  -- xor
				Rout <= Xreg;
				Ain <= '1';		
			when "111" =>  --not
				Rout <= Xreg;
				Ain <= '1';	
		END CASE;
	WHEN T2 => 
		CASE I IS
			when "010" =>  -- add
				Rout <= Yreg;
				Gin <= '1';
			when "011" =>  -- sub
				Rout <= Yreg;
				Gin <= '1';
			when "100" =>  -- and
				Rout <= Yreg;
				Gin <= '1';
			when "101" =>  -- or
				Rout <= Yreg;
				Gin <= '1';	
			when "110" =>  -- xor
				Rout <= Yreg;
				Gin <= '1';	
			when "111" =>  --not
				Rout <= Yreg;
				Gin <= '1';
			WHEN OTHERS => -- null
				Null;
		END CASE;
	WHEN T3 => 
		CASE I IS
			when "010" =>  -- add
				Gout <= '1';
				Rin <= Xreg;
				DONE <= '1';
			when "011" =>  -- sub
				Gout <= '1';
				Rin <= Xreg;
				DONE <= '1';
			when "100" =>  -- and
				Gout <= '1';
				Rin <= Xreg;
				DONE <= '1';
			when "101" =>  -- or
				Gout <= '1';
				Rin <= Xreg;
				DONE <= '1';	
			when "110" =>  -- xor
				Gout <= '1';
				Rin <= Xreg;
				DONE <= '1';
			when "111" =>
				Gout <= '1';
				Rin <= Xreg;
				DONE <= '1';
				
			WHEN OTHERS => -- null
				Null;
		END CASE;
  END CASE;
	if Tstep_Q = T0 then
		UpCount <= "00";
	elsif Tstep_Q = T1 then
		UpCount <= "01";
	elsif Tstep_Q = T2 then
		UpCount <= "10";
	elsif Tstep_Q = T3 then
		UpCount <= "11";
	else 
	null;
	end if;	
END PROCESS;

fsmflipflops: PROCESS (Clock, Resetn, Tstep_D) 
BEGIN 
   IF (Resetn = '0') THEN 
    Tstep_Q <= T0; 
   ELSIF (rising_edge(Clock)) THEN 
    Tstep_Q <= Tstep_D; 
 	else 
	null;
	
   END IF; 
END PROCESS;  


reg_0: regn PORT MAP (BusWires, Rin(0), Clock, R0);
reg_1: regn PORT MAP (BusWires, Rin(1), Clock, R1);
reg_2: regn PORT MAP (BusWires, Rin(2), Clock, R2);
reg_3: regn PORT MAP (BusWires, Rin(3), Clock, R3);
reg_4: regn PORT MAP (BusWires, Rin(4), Clock, R4);
reg_5: regn PORT MAP (BusWires, Rin(5), Clock, R5);
reg_6: regn PORT MAP (BusWires, Rin(6), Clock, R6);
reg_7: regn PORT MAP (BusWires, Rin(7), Clock, R7);
reg_A: regn PORT MAP (BusWires, Ain, Clock, A);


reg_IR: regn GENERIC MAP (n => 9) PORT MAP (DIN(15 DOWNTO 7), IRin, Clock, IR);

 --alu 
 alu: PROCESS (I, A, BusWires)  -- alu_op
 BEGIN 
  IF I = "010" THEN  -- add
   alu_result <= A + BusWires;  
  
  ELSIF I = "011" THEN -- sub
	 alu_result <= A - BusWires;
  
  ELSIF I = "100" THEN  -- and
	 alu_result <= A and BusWires;
  
  ELSIF I = "101" THEN  -- or 
	 alu_result <= A or BusWires;
	 
  ELSIF I = "110" THEN  -- xor 
	 alu_result <= A xor BusWires;
	elsif I = "111" THEN --not
	alu_result <= not A;
   ELSE
	null;
	
  END IF; 
 END PROCESS; 
reg_G: regn PORT MAP (alu_result, Gin, Clock, G);

Sel <= Rout & Gout & DINout; 
busmux: PROCESS (Sel, R0, R1, R2, R3, R4, R5, R6, R7, G, DIN) 
 BEGIN 
  IF Sel = "1000000000" THEN 
		BusWires <= R0; 
  	ELSIF Sel = "0100000000" THEN
		BusWires <= R1;
	ELSIF Sel = "0010000000" THEN
		BusWires <= R2;
	ELSIF Sel = "0001000000" THEN
		BusWires <= R3;
	ELSIF Sel = "0000100000" THEN
		BusWires <= R4;
	ELSIF Sel = "0000010000" THEN
		BusWires <= R5;
	ELSIF Sel = "0000001000" THEN
		BusWires <= R6;
	ELSIF Sel = "0000000100" THEN
		BusWires <= R7;
	ELSIF Sel = "0000000010" THEN
		BusWires <= G;
	ELSE
		BusWires <= DIN;
	END IF;

 END PROCESS;  

END Behavior;