--|-----------------------------------------------------------------------------
--| UNSL - Modular Oscilloscope
--|
--| File: eppwbn_wbn_side.vhd
--| Version: 0.10
--| Targeted device: Actel A3PE1500 
--|-----------------------------------------------------------------------------
--| Description:
--|   EPP - Wishbone bridge. 
--|	  Package for instantiate all the other modules.
--|  	It's only defined to reduce the code in other files.
--------------------------------------------------------------------------------
--| File history:
--|   0.01  | dic-2008 | First testing release
--------------------------------------------------------------------------------
--| Copyright Facundo Aguilera 2008
--| GPL


-- Bloque completo
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package eppwbn_pgk is	
	------------------------------------------------------------------------------
	-- Componentes  
  component eppwbn_ctrl is
    port(
      nStrobe: in std_logic;                 
 
      Data: in std_logic_vector (7 downto 0);
      nAck: out std_logic;                   
      PError: out std_logic;                 
      Sel: out std_logic;                    
      nAutoFd: in std_logic;                 
      PeriphLogicH: out std_logic;           
      nInit: in std_logic;                   
      nFault: out std_logic;                 
      nSelectIn: in std_logic;               
 
      RST_I: in std_logic;  
      CLK_I: in std_logic;  

      rst_pp: out std_logic; 
      epp_mode: out std_logic_vector (1 downto 0) 
 	  );
	end component eppwbn_ctrl;
  
  component eppwbn_epp_side is
		port(
			epp_mode: in std_logic_vector (1 downto 0);

			ctr_nAck, ctr_PError, ctr_Sel, ctr_nFault:   in std_logic;       
			
			ctr_nAutoFd, ctr_nSelectIn, ctr_nStrobe:    out std_logic;      
							
			wb_Busy:       in std_logic;             
			wb_nAutoFd:    out std_logic;            
			wb_nSelectIn:  out std_logic;            
			wb_nStrobe:    out std_logic; 

			nAck, PError, Sel, nFault:   out std_logic;    
			
			Busy:      out std_logic; 
			nAutoFd:   in std_logic;
			nSelectIn: in std_logic;
			nStrobe:   in std_logic 
		);
	end component eppwbn_epp_side;
  
	component eppwbn_wbn_side is
		port(
			inStrobe: in std_logic; 
			iData: inout std_logic_vector (7 downto 0);
			iBusy: out std_logic; 		
			inAutoFd: in std_logic; 	
			inSelectIn: in std_logic;
		 
			RST_I, CLK_I: in std_logic;  
			DAT_I: in std_logic_vector (7 downto 0);
			DAT_O: out std_logic_vector (7 downto 0);
			ADR_O: out std_logic_vector (7 downto 0);
			CYC_O, STB_O: out std_logic;  
			ACK_I: in std_logic ;
			WE_O: out std_logic;

			rst_pp: in std_logic 
		);		
	end component eppwbn_wbn_side;
	
	
	
end package eppwbn_pgk;
	
