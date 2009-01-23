--|-----------------------------------------------------------------------------
--| UNSL - Modular Oscilloscope
--|
--| File: eppwbn_wbn_side.vhd
--| Version: 0.01
--| Targeted device: Actel A3PE1500 
--|-----------------------------------------------------------------------------
--| Description:
--|   EPP - Wishbone bridge. 
--|	  Instantiate all the other modules. The TOP file.
--------------------------------------------------------------------------------
--| File history:
--|   0.01  | dic-2008 | First release
--------------------------------------------------------------------------------
--| Copyright ® 2008, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.


-- Bloque completo

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.eppwbn_pgk.all;

entity eppwbn is
port(
	-- Externo
	nStrobe: in std_logic;											-- Nomenclatura IEEE Std. 1284 
																							-- HostClk/nWrite 
	Data: inout std_logic_vector (7 downto 0); 	-- AD8..1 (Data1..Data8)
	nAck: out std_logic; 												--  PtrClk/PeriphClk/Intr
	busy: out std_logic; 												--  PtrBusy/PeriphAck/nWait
	PError: out std_logic; 											--  AckData/nAckReverse
	Sel: out std_logic; 												--  XFlag (Select)
	nAutoFd: in std_logic; 											--  HostBusy/HostAck/nDStrb
	PeriphLogicH: out std_logic; 								--  (Periph Logic High)
	nInit: in std_logic; 												--  nReverseRequest
	nFault: out std_logic;											--  nDataAvail/nPeriphRequest
	nSelectIn: in std_logic;										--  1284 Active/nAStrb
					
	--  Interno
	RST_I: in std_logic;  
	CLK_I: in std_logic;  
	DAT_I: in std_logic_vector (7 downto 0);
	DAT_O: out std_logic_vector (7 downto 0);
	ADR_O: out std_logic_vector (7 downto 0);
	CYC_O: out std_logic;  
	STB_O: out std_logic;  
	ACK_I: in std_logic ;
	WE_O: out std_logic 
	);
end eppwbn;
	
	
architecture structural of eppwbn is
  ------------------------------------------------------------------------------
	-- Señales
	signal s_epp_mode: std_logic_vector (1 downto 0);
  signal s_rst_pp: std_logic;
  
  signal s_wb_Busy:       std_logic;
  signal s_wb_nAutoFd:    std_logic;
  signal s_wb_nSelectIn:  std_logic;
  signal s_wb_nStrobe:    std_logic;
  
  signal s_ctr_nAck:   std_logic;
  signal s_ctr_PError: std_logic;
  signal s_ctr_Sel:    std_logic;
  signal s_ctr_nFault: std_logic;

  signal s_ctr_nAutoFd:    std_logic;
  signal s_ctr_nSelectIn:  std_logic;
  signal s_ctr_nStrobe:    std_logic;

  
  
	
  
begin

	-- Conexión del módulo de control
	U1:  eppwbn_ctrl
		port map (
			nStrobe => s_ctr_nStrobe,
			Data => Data,
			nAck => s_ctr_nAck,
			PError => s_ctr_PError,
			Sel => s_ctr_Sel,
			nAutoFd => s_ctr_nAutoFd,
			PeriphLogicH => PeriphLogicH,
			nInit => nInit,
			nFault => s_ctr_nFault,
			nSelectIn => s_ctr_nSelectIn,
			
			RST_I => RST_I,
			CLK_I => CLK_I,
      
			rst_pp => s_rst_pp,
			epp_mode => s_epp_mode
	);

	-- Conexión de módulo multiplexor
	U2:  eppwbn_epp_side
		port map (
			epp_mode => s_epp_mode, 

			ctr_nAck => s_ctr_nAck,
			ctr_PError => s_ctr_PError,
			ctr_Sel => s_ctr_Sel,
			ctr_nFault => s_ctr_nFault,

			ctr_nAutoFd => s_ctr_nAutoFd,
			ctr_nSelectIn => s_ctr_nSelectIn,
			ctr_nStrobe=> s_ctr_nStrobe,
			
			wb_Busy => s_wb_Busy,
			wb_nAutoFd => s_wb_nAutoFd,
			wb_nSelectIn => s_wb_nSelectIn,
			wb_nStrobe => s_wb_nStrobe,

			nAck => nAck,
			PError => PError,
			Sel => Sel,
			nFault => nFault,
			
			Busy => Busy,
			nAutoFd => nAutoFd,
			nSelectIn => nSelectIn,
			nStrobe => nStrobe
	);

	-- Conexión del módulo de comunicación con interfaz wishbone
	U3:  eppwbn_wbn_side
		port map(
			inStrobe => s_wb_nStrobe,
			iData => Data,
			iBusy => s_wb_Busy,
			inAutoFd => s_wb_nAutoFd,
			inSelectIn => s_wb_nSelectIn,
			
			RST_I => RST_I,
			CLK_I => CLK_I,
			DAT_I => DAT_I,
			DAT_O => DAT_O,
			ADR_O => ADR_O,
			CYC_O => CYC_O,
			STB_O => STB_O,
			ACK_I => ACK_I,
			WE_O => WE_O,
						
			rst_pp => s_rst_pp
		);
end architecture;