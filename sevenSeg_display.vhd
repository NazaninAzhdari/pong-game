library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sevenSeg_display is
    port (
        i_clk       :   in      STD_LOGIC; 
        i_score     :   in      integer;
        o_7seg      :   out     unsigned(6 downto 0)
    );
end sevenSeg_display;

architecture RTL of sevenSeg_display is
    begin
        process(i_clk) is
		  begin
            if rising_edge(i_clk) then
                case i_score is
                    when 0 => o_7seg <= "1111110";
                    when 1 => o_7seg <= "0110000";
                    when 2 => o_7seg <= "1101101";
                    when 3 => o_7seg <= "1111001";
                    when 4 => o_7seg <= "0110011";
                    when 5 => o_7seg <= "1011011";
                    when 6 => o_7seg <= "1011111";
                    when 7 => o_7seg <= "1110000";
                    when 8 => o_7seg <= "1111111";
                    when 9 => o_7seg <= "1111011";
                    when 10 => o_7seg <= "0000001"; --represents "-"
                    when others => o_7seg <= "0000000";
                    end case;
                end if;
            end process;

    end RTL;