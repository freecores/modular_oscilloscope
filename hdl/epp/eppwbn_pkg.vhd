--|-----------------------------------------------------------------------------
--| UNSL - Modular Oscilloscope
--|
--| File: eppwbn_wbn_side.vhd
--| Version: 0.10
--| Targeted device: Actel A3PE1500 
--|-----------------------------------------------------------------------------
--| Description:
--|   EPP - Wishbone bridge. 
--|	  Package for instantiate all EPP-WBN modules.
--------------------------------------------------------------------------------
--| File history:
--|   0.01  | dic-2008 | First release
--|   0.10  | jan-2008 | Added testing memory
--------------------------------------------------------------------------------
--| Copyright ® 2008, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.


-- Bloque completo
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package eppwbn_pgk is	
	------------------------------------------------------------------------------
	-- Componentes  
  
  -- Bridge control
  component eppwbn_ctrl is
    port(
      nStrobe:      in std_logic;                 
 
      Data:         in std_logic_vector (7 downto 0);
      nAck:         out std_logic;                   
      PError:       out std_logic;                 
      Sel:          out std_logic;                    
      nAutoFd:      in std_logic;                 
      PeriphLogicH: out std_logic;           
      nInit:        in std_logic;                   
      nFault:       out std_logic;                 
      nSelectIn:    in std_logic;               
 
      RST_I:        in std_logic;  
      CLK_I:        in std_logic;  

      rst_pp:       out std_logic; 
      epp_mode:     out std_logic_vector (1 downto 0) 
 	  );
	end component eppwbn_ctrl;
  
  -- Comunication with EPP interface
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
  
	-- Comunication with WB interface
  component eppwbn_wbn_side is
		port(
			inStrobe:     in std_logic; 
			iData:        inout std_logic_vector (7 downto 0);
			iBusy:        out std_logic; 		
			inAutoFd:     in std_logic; 	
			inSelectIn:   in std_logic;
		 
			RST_I, CLK_I: in std_logic;  
			DAT_I:        in std_logic_vector (7 downto 0);
			DAT_O:        out std_logic_vector (7 downto 0);
			ADR_O:        out std_logic_vector (7 downto 0);
			CYC_O, STB_O: out std_logic;  
			ACK_I:        in std_logic ;
			WE_O:         out std_logic;

			rst_pp:       in std_logic 
		);		
	end component eppwbn_wbn_side;
	
	-- Testing memory
  component mem_8bit_reset is
    generic ( --USE_RESET   : boolean   := false;  -- use system reset

              --USE_CS      : boolean   := false;  -- use chip select signal

              DEFAULT_OUT : std_logic := '0';  -- Default output
              --OPTION      : integer   := 1;  -- 1: Registered read Address(suitable
                                          -- for Altera's FPGAs
                                          -- 0: non registered read address
              ADD_WIDTH   : integer   := 8;
              WIDTH       : integer   := 8);

    port (
      cs       : in  std_logic;           -- chip select
      clk      : in  std_logic;           -- write clock
      reset    : in  std_logic;           -- System Reset
      add      : in  std_logic_vector(add_width -1 downto 0);   --  Address
      Data_In  : in  std_logic_vector(WIDTH -1 downto 0);       -- input data
      Data_Out : out std_logic_vector(WIDTH -1 downto 0);       -- Output Data
      WR       : in  std_logic);          -- Read Write Enable
  end component mem_8bit_reset;
  
  component eppwbn is
    port(
      -- Externo
      nStrobe:  in std_logic;											-- Nomenclatura IEEE Std. 1284 
                                                  -- HostClk/nWrite 
      Data:     inout std_logic_vector (7 downto 0); 	-- AD8..1 (Data1..Data8)
      nAck:     out std_logic; 												--  PtrClk/PeriphClk/Intr
      busy:     out std_logic; 												--  PtrBusy/PeriphAck/nWait
      PError:   out std_logic; 											--  AckData/nAckReverse
      Sel:      out std_logic; 												--  XFlag (Select)
      nAutoFd:  in std_logic; 											--  HostBusy/HostAck/nDStrb
      PeriphLogicH: out std_logic; 								--  (Periph Logic High)
      nInit:    in std_logic; 												--  nReverseRequest
      nFault:   out std_logic;											--  nDataAvail/nPeriphRequest
      nSelectIn: in std_logic;										--  1284 Active/nAStrb
              
      --  Interno
      RST_I:  in std_logic;  
      CLK_I:  in std_logic;  
      DAT_I:  in std_logic_vector (7 downto 0);
      DAT_O:  out std_logic_vector (7 downto 0);
      ADR_O:  out std_logic_vector (7 downto 0);
      CYC_O:  out std_logic;  
      STB_O:  out std_logic;  
      ACK_I:  in std_logic ;
      WE_O:   out std_logic 
      );
  end component eppwbn;
  
	
end package eppwbn_pgk;
	
