library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MIPS is
    Port (
		clk : in  STD_LOGIC;
		reset : in std_logic;
		address : out  STD_LOGIC_VECTOR (31 downto 0)
         );
end MIPS;

architecture Behavioral of MIPS is

	COMPONENT PC
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		din : IN std_logic_vector(31 downto 0);          
		dout : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
	
	
	COMPONENT Instruction_Memory
	PORT(
		dir : IN std_logic_vector(31 downto 0);          
		instr : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT Alu_PCnext
	PORT(
		PC : IN std_logic_vector(31 downto 0);          
		PCnext : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT ControlUnit
	PORT(
		OpCode : IN std_logic_vector(5 downto 0);
		Funct : IN std_logic_vector(5 downto 0);          
		MemtoReg : OUT std_logic;
		MemWrite : OUT std_logic;
		Branch : OUT std_logic;
		AluSrc : OUT std_logic;
		RegDst : OUT std_logic;
		RegWrite : OUT std_logic;
		jump : OUT std_logic;
		AluCtrl : OUT std_logic_vector(2 downto 0)
		);
	END COMPONENT;
	
	component Datamemory
	port (
		address: in STD_LOGIC_VECTOR (31 downto 0);
		write_data: in STD_LOGIC_VECTOR (31 downto 0);
		MemWrite: in STD_LOGIC;
		clk: in STD_LOGIC;
		read_data: out STD_LOGIC_VECTOR (31 downto 0)
	);
	end component;
	
	COMPONENT Register_File
	PORT(
		clk : IN std_logic;
		we3 : IN std_logic;
		A1 : IN std_logic_vector(4 downto 0);
		A2 : IN std_logic_vector(4 downto 0);
		A3 : IN std_logic_vector(4 downto 0);
		WD3 : IN std_logic_vector(31 downto 0);          
		RD1 : OUT std_logic_vector(31 downto 0);
		RD2 : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT ALU
	PORT(
		a : IN std_logic_vector(31 downto 0);
		b : IN std_logic_vector(31 downto 0);
		func : IN std_logic_vector(2 downto 0);          
		zero : out std_logic;
		rslt : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT SignExtend
	PORT(
		din : IN std_logic_vector(15 downto 0);          
		dout : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT Mux_2to1_32b
	PORT(
		ctrl : IN std_logic;
		A : IN std_logic_vector(31 downto 0);
		B : IN std_logic_vector(31 downto 0);          
		O : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT SL2
	PORT(
		din : IN std_logic_vector(31 downto 0);          
		dout : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
	COMPONENT ALU_sum
	PORT(
		a : IN std_logic_vector(31 downto 0);
		b : IN std_logic_vector(31 downto 0);          
		sal : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	
	
	COMPONENT Mux_2to1_5bits
	PORT(
		ctrl : IN std_logic;
		a : IN std_logic_vector(4 downto 0);
		b : IN std_logic_vector(4 downto 0);          
		sal : OUT std_logic_vector(4 downto 0)
		);
	END COMPONENT;
	
	signal memtoreg,branch,alusrc,regdst,regwrite,jump,zero,memwrite : std_logic;
	signal aluctrl : std_logic_vector(2 downto 0);
	
	signal rst_pc : std_logic;
	signal pc_in,pc_out,instr: std_logic_vector(31 downto 0);
	
	alias code_op : std_logic_vector(5 downto 0) is instr(31 downto 26);
	alias funct : std_logic_vector(5 downto 0) is instr(5 downto 0);
	
	alias rs : std_logic_vector(4 downto 0) is instr(25 downto 21);
	alias rt : std_logic_vector(4 downto 0) is instr(20 downto 16);
	alias rd : std_logic_vector(4 downto 0) is instr(15 downto 11);
	alias shamt : std_logic_vector(4 downto 0) is instr(10 downto 6);
	alias inmd : std_logic_vector(15 downto 0) is instr(15 downto 0);
	alias addr : std_logic_vector(25 downto 0) is instr(25 downto 0);
	
	signal pc_out_next: std_logic_vector(31 downto 0);
	signal sal_rt_o_rd : std_logic_vector(4 downto 0);
	
	signal srca,srcb,rd2,alu_result,extsig_out,readdata : std_logic_vector(31 downto 0);
	signal shift_out,pc_branch,result_mem : std_logic_vector(31 downto 0);
	
	--signs for j

	signal addr32,addr32_corri,addr32_pc_next,pc_next_j : std_logic_vector(31 downto 0);
	signal pcsrc : std_logic;
	
	begin

		Inst_ControlUnit: ControlUnit PORT MAP(
			OpCode => code_op,
			Funct => funct,
			MemtoReg => memtoreg,
			MemWrite => memwrite,
			Branch => branch,
			AluSrc => alusrc,
			RegDst => regdst,
			RegWrite => regwrite,
			jump => jump,
			AluCtrl => aluctrl
		);
		

		Inst_PC: PC PORT MAP(
			clk => clk,
			reset => reset,
			din => pc_next_j,
			dout => pc_out
		);
		
		Inst_Instruction_Memory: Instruction_Memory PORT MAP(
			dir => pc_out,
			instr =>instr
		);
		
		Memory: Datamemory PORT MAP(
		address => alu_result,
		write_data => rd2 ,
		MemWrite => memwrite,
		clk => clk,
		read_data => readdata
		
		);
		
		
		ALU_sum_4: ALU_sum PORT MAP(
			a => pc_out,
			b => x"00000004",
			sal => pc_out_next
		);
		
		
		
		Inst_Mux_rt_o_rd: Mux_2to1_5bits PORT MAP(
			ctrl => regdst,
			a => rt,
			b => rd,
			sal => sal_rt_o_rd
		);
		
		
		
		Inst_Register_File: Register_File PORT MAP(
			clk => clk,
			we3 => regwrite,
			A1 => rs,
			A2 => rt,
			A3 => sal_rt_o_rd,
			RD1 => srca,
			RD2 => rd2,
			WD3 => result_mem
		);
		
		Inst_ALU: ALU PORT MAP(
			a => srca,
			b => srcb,
			func => aluctrl,
			zero=> zero,
			rslt => alu_result
		);
		
		
		Inst_SignExtend: SignExtend PORT MAP(
			din => inmd,
			dout => extsig_out
		);
		
		Inst_Mux_extSign_o_red2: Mux_2to1_32b PORT MAP(
			ctrl => alusrc,
			A => rd2,
			B => extsig_out,
			O => srcb
		);
		
		Inst_SL2: SL2 PORT MAP(
			din => extsig_out,
			dout => shift_out
		);
		
		
		ALU_sum_shift: ALU_sum PORT MAP(
			a => shift_out,
			b => pc_out_next,
			sal => pc_branch
		);
		
		pcsrc<=branch and zero;
		
		Inst2_Mux_2to1_32b: Mux_2to1_32b PORT MAP(
			ctrl => pcsrc,
			A => pc_out_next,
			B => pc_branch,
			O => pc_in
		);
		

		Inst3_Mux_2to1_32b: Mux_2to1_32b PORT MAP(
			ctrl => memtoreg,
			A => alu_result,
			B => readdata,
			O => result_mem
		);

		
		address<= alu_result;
		
		addr32_pc_next<= pc_out_next (31 downto 28) & addr &"00";
		
		Mux_instru_j: Mux_2to1_32b PORT MAP(
			ctrl => jump,
			A => pc_in,
			B => addr32_pc_next,
			O => pc_next_j
		);
		
end Behavioral;

