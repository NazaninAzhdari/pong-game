library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pongPack.ALL;

entity HVsync is
    port (
        i_clk       :   in      STD_LOGIC;  --25MHz
        i_reset     :   in      STD_LOGIC;
        o_x         :   out     unsigned(pc_VGA_BITS-1 downto 0);
        o_y         :   out     unsigned(pc_VGA_BITS-1 downto 0);
        o_HS        :   out     STD_LOGIC;
        o_VS        :   out     STD_LOGIC;
        o_DE        :   out     STD_LOGIC
    );
end HVsync;

architecture RTL of HVsync is
    signal  r_x     :   integer range 0 to pc_H_TOTAL-1    :=0;
    signal  r_y     :   integer range 0 to pc_V_ACTIVE-1   :=0;

    begin
        process(i_clk, i_reset) is
            begin
                if i_reset = '1' then
                    r_x <= 0;
                    r_y <= 0;
                else
                    if rising_edge(i_clk) then
                        if r_y < pc_V_TOTAL -1 then
                            if r_x < pc_H_TOTAL-1 then
                                r_x <= r_x + 1;
                            else
                                r_x <= 0;
                                r_y <= r_y + 1;
                            end if;
                        else
                            r_y <= 0;
                        end if;
                    end if;
                end if;
            end process;

        o_x <= to_unsigned(r_x, o_x'length);
        o_y <= to_unsigned(r_y, o_y'length);
        o_HS <= '0' when r_x >= pc_H_ACTIVE + pc_H_FP and r_x < pc_H_TOTAL - pc_H_BP else '1';
        o_VS <= '0' when r_y >= pc_V_ACTIVE + pc_V_FP and r_y < pc_V_TOTAL - pc_V_BP else '1';
        o_DE <= '1' when r_x <= pc_H_ACTIVE-1 and r_y <= pc_V_ACTIVE-1 else '0';

    end RTL;