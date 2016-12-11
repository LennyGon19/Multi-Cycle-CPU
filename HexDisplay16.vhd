library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity HexDisplay16 is
port(
hex_input: in std_logic_vector(15 downto 0);
SEG0,SEG1,SEG2,SEG3 : out std_logic_vector (6 downto 0)
--SEG4,SEG5,SEG6,SEG7 
);
end HexDisplay16;

architecture arch of HexDisplay16 is

component dec_to_hex is 
port(hex_digit: in std_logic_vector(3 downto 0);
seg_output: out std_logic_vector(6 downto 0));
end component;

begin
--s7 : dec_to_hex port map(hex_input(31 downto 28), SEG7);
--s6 : dec_to_hex port map(hex_input(27 downto 24), SEG6);
--s5 : dec_to_hex port map(hex_input(23 downto 20), SEG5);
--s4 : dec_to_hex port map(hex_input(19 downto 16), SEG4);
s3 : dec_to_hex port map(hex_input(15 downto 12), SEG3);
s2 : dec_to_hex port map(hex_input(11 downto 8), SEG2);
s1 : dec_to_hex port map(hex_input(7 downto 4), SEG1);
s0 : dec_to_hex port map(hex_input(3 downto 0), SEG0);
end arch;