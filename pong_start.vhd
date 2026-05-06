library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pongPack.ALL;

entity pong_start is
    port (
        i_x             :       in      unsigned(pc_GAME_BITS-1 downto 0);
        i_y             :       in      unsigned(pc_GAME_BITS-1 downto 0);
        o_draw_start    :       out     STD_LOGIC
    );
end pong_start;

architecture RTL of pong_start is
    signal r_x          :   integer range 0 to pc_GAME_WIDTH-1          :=0;
    signal r_y          :   integer range 0 to pc_GAME_HEIGHT-1         :=0;

    begin
        r_x <= to_integer(i_x);
        r_y <= to_integer(i_y);

        o_draw_start <= draw_letter_S(r_x-5, r_y-12) when r_y >= 12 and r_y <= 18 and r_x >= 5 and r_x <= 9 else
                        draw_letter_T(r_x-11, r_y-12) when r_y >= 12 and r_y <= 18 and r_x >= 11 and r_x <= 15 else 
                        draw_letter_A(r_x-17, r_y-12) when r_y >= 12 and r_y <= 18 and r_x >= 17 and r_x <= 21 else 
                        draw_letter_R(r_x-23, r_y-12) when r_y >= 12 and r_y <= 18 and r_x >= 23 and r_x <= 27 else 
                        draw_letter_T(r_x-29, r_y-12) when r_y >= 12 and r_y <= 18 and r_x >= 29 and r_x <= 33 else 
                        '0';

    end RTL;