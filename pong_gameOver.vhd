library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pongPack.ALL;

entity pong_gameOver is
    port (
        i_x                :       in      unsigned(pc_GAME_BITS-1 downto 0);
        i_y                :       in      unsigned(pc_GAME_BITS-1 downto 0);
        o_draw_gameOver    :       out     STD_LOGIC
    );
end pong_gameOver;

architecture RTL of pong_gameOver is
    signal r_x          :   integer range 0 to pc_GAME_WIDTH-1          :=0;
    signal r_y          :   integer range 0 to pc_GAME_HEIGHT-1         :=0;

    begin
        r_x <= to_integer(i_x);
        r_y <= to_integer(i_y);

        o_draw_gameOver <=  pf_draw_letter_G(r_x-9, r_y-7) when r_y >= 7 and r_y <= 13 and r_x >= 9 and r_x <= 13 else
                            pf_draw_letter_A(r_x-15, r_y-7) when r_y >= 7 and r_y <= 13 and r_x >= 15 and r_x <= 19 else
                            pf_draw_letter_M(r_x-21, r_y-7) when r_y >= 7 and r_y <= 13 and r_x >= 21 and r_x <= 25 else
                            pf_draw_letter_E(r_x-27, r_y-7) when r_y >= 7 and r_y <= 13 and r_x >= 27 and r_x <= 31 else

                            pf_draw_letter_O(r_x-9, r_y-16) when r_y >= 16 and r_y <= 22 and r_x >= 9 and r_x <= 13 else
                            pf_draw_letter_V(r_x-15, r_y-16) when r_y >= 16 and r_y <= 22 and r_x >= 15 and r_x <= 19 else
                            pf_draw_letter_E(r_x-21, r_y-16) when r_y >= 16 and r_y <= 22 and r_x >= 21 and r_x <= 25 else
                            pf_draw_letter_R(r_x-27, r_y-16) when r_y >= 16 and r_y <= 22 and r_x >= 27 and r_x <= 31 else
                            '0';

    end RTL;