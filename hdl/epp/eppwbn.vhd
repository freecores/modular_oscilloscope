-- eppwbn.vhd
-- Bloque completo

entity eppwbn is
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
	
	
architecture wbn16epp8 of eppwbn
	
  entity eppwbn_ctrl is
    port(
      nStrobe: in std_logic;                  -- Nomenclatura IEEE Std. 1284-2000, 
      Data: in std_logic_vector (7 downto 0); -- AD8..1/AD8..1 (Data1..Data8)
      nAck: out std_logic;                    -- PtrClk/PeriphClk/Intr
      PError: out std_logic;                  -- AckData/nAckReverse
      Sel: out std_logic;                     -- XFlag (Select). Select no puede usarse
      nAutoFd: in std_logic;                  -- HostBusy/HostAck/nDStrb
      PeriphLogicH: out std_logic;            -- (Periph Logic High)
      nInit: in std_logic;                    -- nReverseRequest
      nFault: out std_logic;                  -- nDataAvail/nPeriphRequest
      nSelectIn: in std_logic;                -- 1284 Active/nAStrb
      
      RST_I: in std_logic;  
      CLK_I: in std_logic;  

      rst_pp: out std_logic;  -- generador de reset desde la interfaz del puerto paralelo
      epp_mode: out std_logic_vector (1 downto 0) -- indicador de modo de comunicaci?n epp
    );
  end entity eppwbn_ctrl;
  
  entity eppwbn_epp_side is
    port(
      epp_mode: in std_logic_vector (1 downto 0);-- indicador de modo de comunicaci?n epp

      ctr_nAck:   in std_logic;                  -- PtrClk/PeriphClk/Intr
      ctr_PError: in std_logic;                  -- AckData/nAckReverse
      ctr_Sel:    in std_logic;                  -- XFlag (Select). Select no puede usarse
      ctr_nFault: in std_logic;                  -- nDataAvail/nPeriphRequest

      ctr_nAutoFd:    out std_logic;               -- HostBusy/HostAck/nDStrb
      ctr_nSelectIn:  out std_logic;               -- 1284 Active/nAStrb
      ctr_nStrobe:    out std_logic;               -- HostClk/nWrite
      
      wb_Busy:       in std_logic;              -- PtrBusy/PeriphAck/nWait
      wb_nAutoFd:    out std_logic;               -- HostBusy/HostAck/nDStrb
      wb_nSelectIn:  out std_logic;               -- 1284 Active/nAStrb
      wb_nStrobe:    out std_logic;               -- HostClk/nWrite

      nAck:   out std_logic;                  -- PtrClk/PeriphClk/Intr
      PError: out std_logic;                  -- AckData/nAckReverse
      Sel:    out std_logic;                  -- XFlag (Select). Select no puede usarse
      nFault: out std_logic;                  -- nDataAvail/nPeriphRequest
      
      Busy:      out std_logic;                 -- PtrBusy/PeriphAck/nWait
      nAutoFd:   in std_logic;                  -- HostBusy/HostAck/nDStrb
      nSelectIn: in std_logic;                  -- 1284 Active/nAStrb
      nStrobe:   in std_logic                  -- HostClk/nWrite
    );
  end entity eppwbn_epp_side;
  
  entity eppwbn_wbn_side is
    port(
      inStrobe: in std_logic; 										-- HostClk/nWrite 
      iData: inout std_logic_vector (7 downto 0); -- AD8..1/AD8..1 (Data1..Data8)
      iBusy: out std_logic; 											-- PtrBusy/PeriphAck/nWait
      inAutoFd: in std_logic; 										-- HostBusy/HostAck/nDStrb
      inSelectIn: in std_logic; 									-- 1284 Active/nAStrb
      
      RST_I: in std_logic;  
      CLK_I: in std_logic;  
      DAT_I: in std_logic_vector (7 downto 0);
      DAT_O: out std_logic_vector (7 downto 0);
      ADR_O: out std_logic_vector (7 downto 0);
      CYC_O: out std_logic;  
      STB_O: out std_logic;  
      ACK_I: in std_logic ;
      WE_O: out std_logic;
            
      rst_pp: in std_logic  -- reset desde la interfaz del puerto paralelo
  );
  
  
begin


