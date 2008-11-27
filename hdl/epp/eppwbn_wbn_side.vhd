
--------------------------------------------------------------------------------
-- UNSL
--
-- File: eppwbn_wbn_side.vhd
-- File history:
--	See cvs history in opencores
--
-- Description: 
-- 	EPP- Wishbone bridge. This module is in the wishbone side.
--
-- Targeted device: Actel A3PR1500 <Die> <Package>
-- Author: Facundo Aguilera
--
-- GPL
--------------------------------------------------------------------------------

-- comments in spanish

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity eppwbn_wbn_side is
port(

	-- salida al puerto epp
	inStrobe: in std_logic; 					-- Nomenclatura IEEE Std. 1284 ECP/EPP (Compatibiliy)
												-- HostClk/nWrite 
	iData: inout std_logic_vector (7 downto 0); -- AD8..1/AD8..1 (Data1..Data8)
	-- inAck: out std_logic; 							--  PtrClk/PeriphClk/Intr
	iBusy: out std_logic; 						--  PtrBusy/PeriphAck/nWait
	-- iPError: out std_logic; 						--  AckData/nAckReverse
	-- iSel: out std_logic; 							--  XFlag (Select)
	inAutoFd: in std_logic; 					--  HostBusy/HostAck/nDStrb
	-- iPeriphLogicH: out std_logic; 					--  (Periph Logic High)
	-- inInit: in std_logic; 							--  nReverseRequest
	-- inFault: out std_logic; 						--  nDataAvail/nPeriphRequest
	inSelectIn: in std_logic; 					--  1284 Active/nAStrb
	-- iHostLogicH: in std_logic; 						--  (Host Logic High)
	-- i indica misma se�al de salida al puerto, aunque interna en el core y controlada por el bloque de control
	
	--  salida a la interface wishbone
	RST_I: in std_logic;  
	CLK_I: in std_logic;  
	DAT_I: in std_logic_vector (7 downto 0);
	DAT_O: out std_logic_vector (7 downto 0);
	ADR_O: out std_logic_vector (7 downto 0);
	CYC_O: out std_logic;  
	STB_O: out std_logic;  
	ACK_I: in std_logic ;
	WE_O: out std_logic;
	
	
	rst_epp: in std_logic  -- reser de la interfaz EPP

	
	-- selecci�n de posici�n del byte
	
);
	
end eppwbn_wbn_side;

architecture con_registro of eppwbn_wbn_side is  -- El dato es registrado en el core.

	
	signal adr_ack,data_ack: std_logic;
	signal adr_reg,data_reg: std_logic_vector (7 downto 0); -- deben crearse dos registros de lectrura/escritura
	signal pre_STB_O: std_logic; -- se�al previa a STB_O

begin
	
	iBusy <= adr_ack or data_ack; -- nWait. Se utiliza para confirmaci�n de lectuira/escritura de datos/direcciones
	WE_O <= not(inStrobe); -- Ambas se�ales tienen la misma utilidad, habilitan escritura
		
		
	-- Data R/W
	data_strobing: process (inAutoFd, ACK_I, CLK_I, pre_STB_O, RST_I, rst_epp)
	begin
		if (rst_epp = '1') then  -- Reset de interfaz EPP
			data_reg <= "00000000";
			pre_STB_O <= '0';
			data_ack <= '0';
		elsif (CLK_I'event and CLK_I = '1') then
			if (RST_I = '1') then 	-- Reset de interfaz Wishbone
				data_reg <= "00000000";
				pre_STB_O <= '0';
				data_ack <= '0';
			else
				if (inAutoFd = '0') then -- Data strobe
					pre_STB_O <= '1';
					if (inStrobe = '0') then -- Escritura EPP
						data_reg <= iData;
					end if;
				end if;
				if (ACK_I = '1' and pre_STB_O = '1') then -- Dato escrito o le�do
					pre_STB_O <= '0';
					data_ack <= '1';
					if (inStrobe = '1') then -- Lectura EPP
						data_reg <= DAT_I;
					end if;
				end if;	
			end if;
		end if;
		if (inAutoFd = '1' and data_ack = '1') then -- iBusy solo se pondr� a cero una vez que haya respuesta desde la PC
			data_ack <= '0';
		end if;
	end process;
	STB_O <= pre_STB_O;
	CYC_O <= pre_STB_O;
	DAT_O <= data_reg;  -- se utiliza el mismo registro para salida de datos a wishbone, lectura y escritura de datos desde epp
	

	-- Adr R/W
	adr_ack <= not(inSelectIn); -- Autoconfirmaci�n de estado.
	adr_strobing: process (inSelectIn, RST_I, rst_epp)
	begin
		if (RST_I = '1' or rst_epp = '1') then
			adr_reg <= "00000000";
		elsif (inSelectIn'event and inSelectIn = '1') then -- Adr strobe
			if inStrobe = '0' then
				adr_reg <= iData;
			end if;
		end if;		
	end process;
	ADR_O <= adr_reg;
	
	
	-- Puerto bidireccional
	iData <= data_reg when (inStrobe = '1' and data_ack = '1') else 
			 adr_reg when (inStrobe = '1' and adr_ack = '1') else 
			 "ZZZZZZZZ";
	
	
	
end con_registro;