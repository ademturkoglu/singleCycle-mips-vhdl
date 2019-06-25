library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Instruction_Memory is
    Port ( 
		dir : in  STD_LOGIC_VECTOR (31 downto 0);
        instr : out  STD_LOGIC_VECTOR (31 downto 0)
		);
end Instruction_Memory;

architecture Behavioral of Instruction_Memory is
	type mem is array(0 to 67) of std_logic_vector(7 downto 0);
	constant code : mem:=(

		-- Load here your software.
		
		-- Registers loaded.
		x"20",x"04",x"00",x"04",
		x"20",x"05",x"00",x"05",
		x"20",x"06",x"00",x"06",
		x"20",x"07",x"00",x"07",
		
		-- Instructions
		x"8C",x"41",x"00",x"01",
		x"00",x"A4",x"18",x"22",
		x"00",x"E6",x"10",x"24",
		x"00",x"85",x"20",x"25",
		x"00",x"C7",x"28",x"20",
	--x"14",x"21",x"FF",x"FA",
		x"10",x"22",x"FF",x"FF",
		x"00",x"62",x"30",x"2A",
		
		x"10",x"21",x"00",x"02",
		x"00",x"00",x"00",x"00",
		x"00",x"00",x"00",x"00",
		x"AC",x"01",x"00",x"02",
		x"00",x"23",x"20",x"20",
		x"08",x"00",x"00",x"04"

	--others=> x"00"
	);

	begin

		process(dir)
		begin
			instr(31 downto 24)<=code(conv_integer(dir));
			instr(23 downto 16)<=code(conv_integer(dir)+1);
			instr(15 downto 8)<= code(conv_integer(dir)+2);
			instr(7 downto 0)<=code(conv_integer(dir)+3);
		end process;
		
end Behavioral;