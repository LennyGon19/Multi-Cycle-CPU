LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

ENTITY counter is
port
(
	Clk : in std_logic ;
	Clear	: in std_logic ;
	Q : out std_logic_vector (4 downto 0)
);
end counter;

architecture arch of counter is
	signal count : std_logic_vector(4 downto 0);
begin
	process(clk, clear)
	begin
			if clear = '0' then
				count <= "00000";
			elsif (rising_edge(clk)) then
				count <= count + 1;
			end if;
	end process;
	Q <= count;
end arch;
