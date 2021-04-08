
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY WRITE_BACK_CONTROLLER IS
   GENERIC (N : INTEGER := 16);
   PORT (
      rst : IN STD_LOGIC;
      clk : in std_logic;
      in_m1 : IN STD_LOGIC;
      in_opcode : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
      in_dr2 : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
	  in_reg_wb : IN STD_LOGIC;
	  in_ar : in std_logic_vector(16 downto 0);
      in_ra : in std_logic_vector(2 downto 0);
      in_usr_flag : IN STD_LOGIC;
	  in_ra_data : in std_logic_vector(16 downto 0); -- for the output instruction
      in_ram_mem : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      out_cpu : out std_logic_vector(15 downto 0);
	  out_ar : out std_logic_vector(16 downto 0);
      out_ra : out std_logic_vector(2 downto 0);
      out_ra_wen : out std_logic;
      dip_switches : IN STD_LOGIC_VECTOR(15 DOWNTO 0)
   );        
END WRITE_BACK_CONTROLLER;

ARCHITECTURE level_2 OF WRITE_BACK_CONTROLLER IS
   SIGNAL last_loadimm : STD_LOGIC_VECTOR(N DOWNTO 0) := (OTHERS => '0');
BEGIN
   Controller : PROCESS (rst, clk, in_reg_wb, in_ar, in_ra, in_opcode, last_loadimm, in_dr2)
        variable writeback : integer := 0;
   BEGIN
      IF (rst = '1') THEN
         out_cpu <= X"0000";
         out_ra <= "000";
         out_ar <= (OTHERS => '0');
         out_ra_wen <= '0';
      else
         IF (in_usr_flag = '1' and in_opcode = "0100000") THEN -- output instruction
            out_cpu <= in_ra_data(15 DOWNTO 0);
            out_ar <= (OTHERS => '0');
            out_ra <= "000";
            out_ra_wen <= '0';
         END IF;
         IF (in_reg_wb = '1') THEN -- to registers
            out_cpu <= X"0000";
            IF (in_opcode = "0010010") THEN --loadimm 
               IF (last_loadimm /= '0' & X"0000") THEN
                  IF (in_m1 = '1') THEN
                     if(in_dr2 = "11"&X"F0") then
                        out_ar <= '0'&dip_switches(15 DOWNTO 8) & last_loadimm(7 DOWNTO 0);
                        last_loadimm <= '0'&dip_switches(15 DOWNTO 8) & last_loadimm(7 DOWNTO 0);
                     else
                         out_ar <= '0'& in_dr2(7 DOWNTO 0) & last_loadimm(7 DOWNTO 0);
                         last_loadimm <= '0'& in_dr2(7 DOWNTO 0) & last_loadimm(7 DOWNTO 0);
                     end if;
                  ELSE
                      if(in_dr2 = "11"&X"F0") then
                        out_ar <='0'& last_loadimm(15 DOWNTO 8) & dip_switches(7 DOWNTO 8);
                        last_loadimm <= '0'&last_loadimm(15 DOWNTO 8) & dip_switches(7 DOWNTO 0);
                      else
                        out_ar <= '0' & last_loadimm(15 DOWNTO 8) & in_dr2(7 DOWNTO 0);
                        last_loadimm <= '0' & last_loadimm(15 DOWNTO 8) & in_dr2(7 DOWNTO 0);
                      end if;
                  END IF;
               ELSE
                   IF (in_m1 = '1') THEN
                        if(in_dr2 = "11"&X"F0") then
                           out_ar <= '0'&dip_switches(15 DOWNTO 8) & X"00";
                           last_loadimm <= '0'&dip_switches(15 DOWNTO 8) & X"00";
                        else
                            out_ar <= '0'& in_dr2(7 DOWNTO 0) & X"00";
                            last_loadimm <= '0'& in_dr2(7 DOWNTO 0) & X"00";
                        end if;
                     ELSE
                         if(in_dr2 = "11"&X"F0") then
                           out_ar <='0'& X"00" & dip_switches(7 DOWNTO 0);
                           last_loadimm <= '0'& X"00" & dip_switches(7 DOWNTO 0);
                         else
                           out_ar <= '0' & X"00" & in_dr2(7 DOWNTO 0);
                           last_loadimm <= '0' & X"00" & in_dr2(7 DOWNTO 0);
                         end if;
                     END IF;
               END IF;
               out_ra <= "111";
            ELSIF (in_opcode = "0010011") THEN -- MOV
               out_ar <= last_loadimm;
               out_ra <= in_ra; --ra = rdest
            ELSIF (in_opcode = "0010000") THEN -- Load
               out_ar <= '0' & in_ram_mem;
               out_ra <= in_ra; --ra = rdest
            ELSE
               out_ar <= in_ar;
               out_ra <= in_ra;
            END IF;
            out_ra_wen <= '1';
            writeback := 1;
         --END IF;
         else
           if(writeback = 1) then
               out_ra_wen <= '0';
               writeback := 0;
           end if;
         end if;
      END IF;
   END PROCESS Controller;
END level_2;