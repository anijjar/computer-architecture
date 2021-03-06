-- Aman Nijjar

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY MUX_ARRAY IS
   GENERIC (
      num : INTEGER 16
   );
   PORT (
      data_in : IN STD_LOGIC_VECTOR ((2*num)-1 DOWNTO 0);
      s : IN STD_LOGIC;
      data_out : OUT STD_LOGIC_VECTOR(num-1 DOWNTO 0)
   );
END MUX_ARRAY;

ARCHITECTURE behavioural OF MUX_ARRAY IS
BEGIN
   gen: for i in (num-1) downto 0 generate
      ut : entity work.MUX2_1 PORT MAP(SEL => s, A => data_in(i*2), B => data_in((i*2)+1), C => data_out(i));
   end generate;
   
END behavioural;