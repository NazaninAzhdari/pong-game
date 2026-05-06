library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pongPack.ALL;

entity pong_border is
    port (
        i_x                     :       in      unsigned(pc_GAME_BITS-1 downto 0);
        i_y                     :       in      unsigned(pc_GAME_BITS-1 downto 0);
        o_draw_edge_border      :       out     STD_LOGIC;
        o_draw_middle_border    :       out     STD_LOGIC
    );
end pong_border;

architecture RTL of pong_border is
    signal r_x          :   integer range 0 to pc_GAME_WIDTH-1          :=0;
    signal r_y          :   integer range 0 to pc_GAME_HEIGHT-1         :=0;

    begin
        r_x <= to_integer(i_x);
        r_y <= to_integer(i_y);

        o_draw_edge_border <= '1' when  (r_x = pc_X_LEFT_BORDER and r_y >= pc_Y_TOP_BORDER and r_y <= pc_Y_BUTTOM_BORDER)
                                or (r_x = pc_X_RIGHT_BORDER and r_y >= pc_Y_TOP_BORDER and r_y <= pc_Y_BUTTOM_BORDER)
                                or (r_y = pc_Y_TOP_BORDER  and r_x >= pc_X_LEFT_BORDER and r_x <= pc_X_RIGHT_BORDER)
                                or (r_y = pc_Y_BUTTOM_BORDER and r_x >= pc_X_LEFT_BORDER and r_x <= pc_X_RIGHT_BORDER)
                                else '0';

        o_draw_middle_border <= '1' when (r_x = pc_X_MIDDLE_BORDER and r_y >= pc_Y_TOP_BORDER and r_y <= pc_Y_BUTTOM_BORDER and i_y(1) = '1') 
                                else '0';

    end RTL;