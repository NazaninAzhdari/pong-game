library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pongPack.ALL;

entity pong_paddle is
    generic (
        g_X_LOCATION_PADDLE   :   integer     :=0  --top left of the paddle 
                                                 --set to X_PADDLE_PLAYER1 or X_PADDLE_PLAYER2
    );
    port (
        i_clk           :       in      STD_LOGIC; --50MHz clock
        i_x             :       in      unsigned(pc_GAME_BITS-1 downto 0);
        i_y             :       in      unsigned(pc_GAME_BITS-1 downto 0);
        i_btn_up        :       in      STD_LOGIC;
        i_btn_dwn       :       in      STD_LOGIC;
        o_y_paddle_top  :       out     unsigned(pc_GAME_BITS-1 downto 0);
        o_y_paddle_dwn  :       out     unsigned(pc_GAME_BITS-1 downto 0);
        o_draw_paddle   :       out     STD_LOGIC
    );
end pong_paddle;

architecture RTL of pong_paddle is
    signal r_x                  :   integer range 0 to pc_GAME_WIDTH-1                         :=0;
    signal r_y                  :   integer range 0 to pc_GAME_HEIGHT-1                        :=0;
    signal r_btn_DV             :   STD_LOGIC                                                  :='0';
    signal r_paddle_move_count  :   integer range 0 to pc_PADDLE_SPEED-1                       :=0;
    signal r_y_paddle_top       :   integer range 0 to (pc_GAME_HEIGHT - pc_PADDLE_HEIGHT -1)  :=11;
    signal r_y_paddle_dwn       :   integer range (pc_PADDLE_HEIGHT -1) to (pc_GAME_HEIGHT-1)  :=17; 


    begin
        r_btn_DV <= i_btn_up xor i_btn_dwn;
        r_x <= to_integer(i_x);
        r_y <= to_integer(i_y);

        process(i_clk) is
            begin
                if rising_edge(i_clk) then
						if r_btn_DV = '1' then
                    if r_paddle_move_count < pc_PADDLE_SPEED-1 then
                        r_paddle_move_count <= r_paddle_move_count + 1;
                    else
                        r_paddle_move_count <= 0;
							
							
						
                            
                                if i_btn_up = '1' and r_paddle_move_count = pc_PADDLE_SPEED -1 then 
											if r_y_paddle_top /=0 then
                                    r_y_paddle_top <= r_y_paddle_top + 1;
                                    r_y_paddle_dwn <= r_y_paddle_dwn -1;
											end if;
                                

                                elsif i_btn_dwn = '1' and r_paddle_move_count = pc_PADDLE_SPEED -1 then 
											if r_y_paddle_dwn /= pc_GAME_HEIGHT-1 then
                                    r_y_paddle_top <= r_y_paddle_top - 1;
                                    r_y_paddle_dwn <= r_y_paddle_dwn + 1;
												end if;
                                end if;
                        end if;    
                    end if;
                end if;
					 end process;
            
				
				process(i_clk) is
					begin
						if rising_edge(i_clk) then
							if (r_x < g_X_LOCATION_PADDLE + pc_PADDLE_WIDTH) 
                                        and (r_x >= g_X_LOCATION_PADDLE )
                                        and (r_y < r_y_paddle_dwn )
                                        and (r_y > r_y_paddle_top) then
													 
													 o_draw_paddle <= '1';
													 else
													 o_draw_paddle <= '0';
							end if;
						end if;
					end process;
					
            o_y_paddle_top <= to_unsigned(r_y_paddle_top, o_y_paddle_top'length);
            o_y_paddle_dwn <= to_unsigned(r_y_paddle_dwn, o_y_paddle_dwn'length);
 

    end RTL;