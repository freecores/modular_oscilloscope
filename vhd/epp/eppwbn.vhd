-- Bloque completo

architecture eppwbn is 

-- generic (
      -- data_size : <type> {:= <default_value>};
      -- <generic2_name> : <type> {:= <default_value>};
      -- <other generics>...    
-- );
port(
	-- Externo
	nStrobe: in std_logic; 						-- Nomenclatura IEEE Std. 1284 ECP/EPP (Compatibiliy)
												-- HostClk/nWrite 
	Data: inout std_logic_vector (7 downto 0); 	--AD8..1 (Data1..Data8)
	nAck: out std_logic; 						--  PtrClk/PeriphClk/Intr
	busy: out std_logic; 						--  PtrBusy/PeriphAck/nWait
	PError: out std_logic; 						--  AckData/nAckReverse
	Sel: out std_logic; 						--  XFlag (Select)
	nAutoFd: in std_logic; 						--  HostBusy/HostAck/nDStrb
	PeriphLogicH: out std_logic; 				--  (Periph Logic High)
	nInit: in std_logic; 						--  nReverseRequest
	nFault: out std_logic; 						--  nDataAvail/nPeriphRequest
	nSelectIn: in std_logic; 					--  1284 Active/nAStrb
	HostLogicH: in std_logic; 					--  (Host Logic High)
	
	--  Interno
	RST_I: in std_logic;  
	CLK_I: in std_logic;  
	DAT_I: in std_logic_vector (15 downto 0);
	ADR_I: in std_logic_vector (15 downto 0);
	DAT_O: out std_logic_vector (15 downto 0);
	ADR_O: out std_logic_vector (15 downto 0);
	CYC_I: in std_logic;  
	ACK_O: out std_logic;  
	WE_I: in std_logic;  
	);
end eppwbn;
	
	
