library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Datamemory is
	port (
		address: in STD_LOGIC_VECTOR (31 downto 0);
		write_data: in STD_LOGIC_VECTOR (31 downto 0);
		MemWrite: in STD_LOGIC;
		clk: in STD_LOGIC;
		read_data: out STD_LOGIC_VECTOR (31 downto 0)
	);
end Datamemory;


architecture behavioral of Datamemory is	  

	type mem_array is array(0 to 31) of STD_LOGIC_VECTOR (31 downto 0);

	signal data_mem: mem_array := (
		X"00000000", -- initialize data memory
		X"00000000", -- mem 1
		X"00000000",
		X"00000033",
		 X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000", 
		X"00000000", -- mem 10 
		X"00000000", 
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",  
		X"00000000", -- mem 20
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000", 
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000",
		X"00000000", 
		X"00000000", -- mem 30
		X"00000000");

	begin

		mem_process: process(address, write_data,clk)
			begin
				if clk = '0' and clk'event then
					read_data <= data_mem(conv_integer(address(6 downto 2)));
					if (MemWrite = '1') then
						data_mem(conv_integer(address(6 downto 2))) <= write_data;
					end if;
				end if;
		end process mem_process;

end behavioral;