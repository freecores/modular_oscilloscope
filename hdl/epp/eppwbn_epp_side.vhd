--|------------------------------------------------------------------------------
--| UNSL - Modular Oscilloscope
--|
--| File: eppwbn_epp_side.vhd
--| Version: 0.01
--| Targeted device: Actel A3PE1500
--|------------------------------------------------------------------------------
--| Description:
--| 	EPP - Wishbone bridge.
--|  	EPP module output control (IEEE Std. 1284-2000).
-------------------------------------------------------------------------------
--| File history:
--| 	0.01	| nov-2008 | First release
--------------------------------------------------------------------------------
--| Copyright � 2008, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity eppwbn_epp_side is
port(

  -- Selecci�n de modo
  epp_mode: in std_logic_vector (1 downto 0);-- indicador de modo de comunicaci�n epp
    -- "00" deshabilitado
    -- "01" inicial (se�ales de usuario e interrupciones deshabilitadas)
    -- "10" sin definir
    -- "11" modo EPP normal

  -- CTRL signals
	ctr_nAck:   in std_logic;                  -- PtrClk/PeriphClk/Intr
	ctr_PError: in std_logic;                  -- AckData/nAckReverse
	ctr_Sel:    in std_logic;                  -- XFlag (Select). Select no puede usarse
	ctr_nFault: in std_logic;                  -- nDataAvail/nPeriphRequest

  ctr_nAutoFd:    out std_logic;               -- HostBusy/HostAck/nDStrb
	ctr_nSelectIn:  out std_logic;               -- 1284 Active/nAStrb
  ctr_nStrobe:    out std_logic;               -- HostClk/nWrite
  
	-- WB-side signals
	wb_Busy:       in std_logic;              -- PtrBusy/PeriphAck/nWait
  wb_nAutoFd:    out std_logic;               -- HostBusy/HostAck/nDStrb
	wb_nSelectIn:  out std_logic;               -- 1284 Active/nAStrb
	wb_nStrobe:    out std_logic;               -- HostClk/nWrite
    -- No est�n implementadas las se�ales personalizadas

  -- To EPP port
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

architecture multiplexor of eppwbn_epp_side is

begin

  -- Puentes
  --  Son incorporados en un m�dulo para facilitar modificaciones
  Busy <= wb_Busy;

  ctr_nAutoFd <= nAutoFd;
  ctr_nSelectIn <= nSelectIn;
  ctr_nStrobe <= nStrobe;

  -- Selecci�n de salidas desde el m�dulo EPP cuando epp_mode = "11"
  --  Como no est�n implementadas las se�ales personalizadas se escribe "0000"
  multiplexing: process (epp_mode ,ctr_nAck, ctr_PError, ctr_Sel, ctr_nFault,
  						nAutoFd, nSelectIn, nStrobe) begin
    case epp_mode is

      when "11" => 
        -- Hacia el host
        nAck <= '0'; -- No est�n implementadas las se�ales personalizadas
        PError <= '0';
        Sel <= '0';
        nFault <= '0'; 
        
        -- Hacia el m�dulo EPP
        wb_nAutoFd <= nAutoFd;
        wb_nSelectIn <= nSelectIn;
        wb_nStrobe <= nStrobe;
      
      when "01" => 
        -- Hacia el host
        nAck <= ctr_nAck;
        PError <= ctr_PError;
        Sel <= ctr_Sel;
        nFault <= ctr_nFault;
        
        -- Hacia el m�dulo EPP
        wb_nAutoFd <= nAutoFd;
        wb_nSelectIn <= nSelectIn;
        wb_nStrobe <= nStrobe;
        
      when others =>
        -- Hacia el host
        nAck <= ctr_nAck;
        PError <= ctr_PError;
        Sel <= ctr_Sel;
        nFault <= ctr_nFault;
        
        -- Hacia el m�dulo EPP
        wb_nAutoFd <= '1';
        wb_nSelectIn <= '1';
        wb_nStrobe <= '1';
    end case;
  end process;

end architecture multiplexor;




