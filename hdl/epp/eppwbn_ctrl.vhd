--|------------------------------------------------------------------------------
--| UNSL - Modular Oscilloscope
--|
--| File: eppwbn_wbn_side.vhd
--| Version: 0.20
--| Targeted device: Actel A3PE1500 
--|-----------------------------------------------------------------------------
--| Description:
--| 	EPP - Wishbone bridge. 
--|	  This module controls the negotiation (IEEE Std. 1284-2000).
--|   This can be easily modified to control other modes besides the EPP.
-------------------------------------------------------------------------------
--| File history:
--| 	0.01	| nov-2008 | First testing release
--|   0.20  | dic-2008 | Customs signals without tri-state
--|   0.21  | jan-2009 | Sinc reset
--------------------------------------------------------------------------------
--| Copyright � 2008, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity eppwbn_ctrl is
port(

	-- salida al puerto epp
  nStrobe: in std_logic;                  -- Nomenclatura IEEE Std. 1284-2000, 
                                          -- Negotiation/ECP/EPP (Compatibiliy) 
												                  -- HostClk/nWrite 
	Data: in std_logic_vector (7 downto 0); -- AD8..1/AD8..1 (Data1..Data8)
	nAck: out std_logic;                    -- PtrClk/PeriphClk/Intr
	-- Busy: out std_logic;                 -- PtrBusy/PeriphAck/nWait
	PError: out std_logic;                  -- AckData/nAckReverse
	Sel: out std_logic;                     -- XFlag (Select). Select no puede usarse
	nAutoFd: in std_logic;                  -- HostBusy/HostAck/nDStrb
	PeriphLogicH: out std_logic;            -- (Periph Logic High)
	nInit: in std_logic;                    -- nReverseRequest
	nFault: out std_logic;                  -- nDataAvail/nPeriphRequest
	nSelectIn: in std_logic;                -- 1284 Active/nAStrb
	-- HostLogicH: in std_logic;            -- (Host Logic High)
	-- i indica misma se�al de salida al puerto, aunque interna en el core y controlada por el bloque de control
	
	-- salida a la interface wishbone
	RST_I: in std_logic;  
	CLK_I: in std_logic;  

	-- se�ales internas
  rst_pp: out std_logic;  -- generador de reset desde la interfaz del puerto paralelo
	epp_mode: out std_logic_vector (1 downto 0) -- indicador de modo de comunicaci?n epp
      -- "00" deshabilitado
      -- "01" inicial (se?ales de usuario e interrupciones deshabilitadas)
      -- "10" sin definir
      -- "11" modo EPP normal
);
end entity eppwbn_ctrl;


architecture state_machines of eppwbn_ctrl is
	type StateType is (
          st_compatibility_idle,  -- Los estados corresponden a los especificados
          st_negotiation2,        --  por el est?ndar.
                                  -- Los n?meros de los estados negotiation corresponden 
                                  --  a las fases del est?ndar.
          st_initial_epp,
          st_epp_mode
					-- otros modos
          );
	signal next_state, present_state: StateType;
	signal ext_req_val: std_logic_vector (7 downto 0);									
begin
  
  ----------------------------------------------------------------------------------------
  -- generaci�n de se�al de reset para otros m�dulos y se�al de encendido hacia el host
  rst_pp <= not(nInit) and not(nSelectIn); -- (nInit = '0') and (nSelectIn = '0');
 
  PeriphLogicH <= '1';
  
  ----------------------------------------------------------------------------------------
  -- almacenamiento de Extensibility Request Value (as�ncrono)
  P_data_store: process(nStrobe, present_state, Data, RST_I, nInit, nSelectIn)
  begin
    if (RST_I = '1' or (nInit = '0' and nSelectIn = '0')) then
      ext_req_val <= (others => '0');
    elsif (present_state = st_negotiation2 and nStrobe'event and nStrobe = '0') then
      ext_req_val <= Data;
    end if;
  end process P_data_store;
  
  ----------------------------------------------------------------------------------------
  -- estado siguiente
  P_state_comb: process(present_state, next_state, RST_I, nSelectIn, nAutoFd, ext_req_val, nInit, nStrobe) begin
 
    if RST_I = '1' then
      next_state <= st_compatibility_idle;
    else
      case present_state is
        
        when st_compatibility_idle => 
          PError <= '0';
          nFault <= '1';
          Sel <= '1';
          nAck <= '1';
               
          epp_mode <= "00";
          
          -- verificaci�n de compatibilidad con 1284
          if (nAutoFd = '0' and  nSelectIn = '1') then
            next_state <= st_negotiation2;
          else
            next_state <= st_compatibility_idle;
          end if;
        
        when st_negotiation2 =>
          PError <= '1';
          nFault <= '1';
          Sel <= '1';
          nAck <= '0';
                 
          epp_mode <= "00"; 
          
          -- Reconocimiento del host 
          if (nStrobe = '1' and
              nAutoFd = '1') then
            
            -- Pedido de modo EPP
            if (ext_req_val = "01000000") then
              next_state <= st_initial_epp;
            
            -- Otros modos
            
            else 
              next_state <= st_compatibility_idle;
            end if;
          else
            next_state <= st_negotiation2;
          end if;
        
        when st_initial_epp =>
          Sel <= '1';
          PError <= '1';
          nFault <= '1';
          nAck <= '1';
        
          epp_mode <= "01";
          
          -- Finalizaci?n del modo EPP
          if nInit = '0' then
            next_state <= st_compatibility_idle;
          -- Comienzo del primer ciclo EPP
          elsif (nSelectIn = '0' or nAutoFd = '0') then
            next_state <= st_epp_mode;
          else
            next_state <= st_initial_epp;
          end if;
        
        when st_epp_mode =>
          Sel <= '0';     -- El bus debe asegurar que se puedan usar
          PError <= '0';  --  las se�ales definidas por el usuario en el m�dulo 
          nFault <= '0';  --  EPP.
          nAck <= '0';    
        
          epp_mode <= "11";
          
          -- Finalizaci?n del modo EPP
          
          next_state <= st_epp_mode;
                  -- Se sale de este estado en forma as�ncrona ya que esta acci�n
      end case;   --  no tiene handshake.
    end if;
    
  end process P_state_comb;
      

 
  ----------------------------------------------------------------------------------------
  -- estado actual
  P_state_clocked: process(CLK_I, nInit, nSelectIn) begin
    if (nInit = '0' and nSelectIn = '0') or RST_I = '1' then
      present_state <= st_compatibility_idle;
    elsif present_state = st_epp_mode and nInit = '0' then
      present_state <= st_compatibility_idle;
    elsif (CLK_I'event and CLK_I='1') then
      present_state <= next_state;
    end if;  
  end process P_state_clocked;
  
end architecture state_machines;