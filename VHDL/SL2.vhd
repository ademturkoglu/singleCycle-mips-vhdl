library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SL2 is
    Port ( 
		din : in  STD_LOGIC_VECTOR (31 downto 0);
        dout : out  STD_LOGIC_VECTOR (31 downto 0)
		);
end SL2;

architecture Behavioral of SL2 is

	begin
		dout<=din(29 downto 0)&"00"; --Multiply with 4

end Behavioral;

