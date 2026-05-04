library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity HVsync is
    generic (
        --herizontal porch
        H_ACTIVE    :   integer     :=640;
        H_FP        :   integer     :=16;
        H_SYNC      :   integer     :=96;
        H_BP        :   integer     :=48;
        H_TOTAL     :   integer     :=H_ACTIVE + H_FP + H_SYNC + H_BP;
        --vertical porch
        V_ACTIVE    :   integer     := 480;
        V_FP        :   integer     :=10;
        V_SYNC      :   integer     :=2;
        V_BP        :   integer     :=33;
        V_TOTAL     :   integer     :=V_ACTIVE + V_FP + V_SYNC + V_BP
    );
    port (
        i_clk       :   in      STD_LOGIC;  --25MHz
        i_reset     :   in      STD_LOGIC;
        o_x         :   out     integer;
        o_y         :   out     integer;
        o_HS        :   out     STD_LOGIC;
        o_VS        :   out     STD_LOGIC;
        o_DE        :   out     STD_LOGIC
    );
end HVsync;

architecture RTL of HVsync is
    signal  r_x     :   integer range 0 to H_TOTAL-1    :=0;
    signal  r_y     :   integer range 0 to V_ACTIVE-1   :=0;

    begin
        process(i_clk) is
            begin
                if i_reset = '1' then
                    r_x <= 0;
                    r_y <= 0;
                else
                    if rising_edge(i_clk) then
                        if r_y < V_TOTAL -1 then
                            if r_x < H_TOTAL-1 then
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

        o_x <= r_x;
        o_y <= r_y;
        o_HS <= '0' when r_x >= H_ACTIVE + H_FP and r_x < H_TOTAL - H_BP else '1';
        o_VS <= '0' when r_y >= V_ACTIVE + V_FP and r_y < V_TOTAL - V_BP else '1';
        o_DE <= '1' when r_x <= H_ACTIVE-1 and r_y <= V_ACTIVE-1 else '0';

    end RTL;