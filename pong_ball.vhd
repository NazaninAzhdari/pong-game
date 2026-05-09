library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pongPack.ALL;

entity pong_ball is
    port (
        i_clk       :       in      STD_LOGIC; --25
        i_start     :       in      STD_LOGIC;
        i_x         :       in      unsigned(pc_GAME_BITS-1 downto 0);
        i_y         :       in      unsigned(pc_GAME_BITS-1 downto 0);
        i_x_not_div :       in      unsigned(pc_VGA_BITS-1 downto 0);
        i_y_not_div :       in      unsigned(pc_VGA_BITS-1 downto 0);
        o_x_ball    :       out     unsigned(pc_GAME_BITS-1 downto 0);   --center of the ball
        o_y_ball    :       out     unsigned(pc_GAME_BITS-1 downto 0);   --center of the ball
        o_draw_ball :       out     STD_LOGIC
    );
end pong_ball;

architecture RTL of pong_ball is
    signal r_x          :   integer range 0 to pc_GAME_WIDTH-1      :=0;
    signal r_y          :   integer range 0 to pc_GAME_HEIGHT-1     :=0;

    signal r_x_not_div  :   integer range 0 to pc_H_TOTAL-1      :=0;
    signal r_y_not_div :   integer range 0 to pc_V_TOTAL-1      :=0;

    signal r_x_ball     :   integer range 0 to pc_GAME_WIDTH -1     :=pc_X_BALL_START; --center of the ball
    signal r_y_ball     :   integer range 0 to pc_GAME_HEIGHT -1    :=pc_Y_BALL_START; --center of the ball

    signal r_x_ball_nxt :   integer range 0 to pc_GAME_WIDTH -1     :=r_x_ball+1; --center of the ball
    signal r_y_ball_nxt :   integer range 0 to pc_GAME_HEIGHT -1    :=r_y_ball+1; --center of the ball

    signal r_move_count :   integer range 0 to pc_BALL_SPEED        :=0;

    begin
        r_x <= to_integer(i_x);
        r_y <= to_integer(i_y);

        r_x_not_div <= to_integer(i_x_not_div);
        r_y_not_div <= to_integer(i_y_not_div);

        process(i_clk) is
            begin
                if rising_edge(i_clk) then
                    if i_start = '0' then
                        r_x_ball <= pc_X_BALL_START;
                        r_y_ball <= pc_Y_BALL_START;
                        r_x_ball_nxt <= r_x_ball + 1;
                        r_y_ball_nxt <= r_y_ball + 1;
                        r_move_count <= 0;
                    else
                        if r_move_count < pc_BALL_SPEED then
                            r_move_count <= r_move_count + 1;
                        else
                            r_move_count <= 0;

                            if r_x_ball < r_x_ball_nxt then
                                if r_x_ball_nxt /= pc_X_PADDLE_PLAYER2 then
                                    r_x_ball <= r_x_ball_nxt;
                                    r_x_ball_nxt <= r_x_ball_nxt +1;
                                elsif r_x_ball_nxt = pc_X_PADDLE_PLAYER2 then
                                    r_x_ball <= r_x_ball_nxt;
                                    r_x_ball_nxt <= r_x_ball_nxt -1;
                                end if;
                            elsif r_x_ball > r_x_ball_nxt then
                                if r_x_ball_nxt /= pc_X_PADDLE_PLAYER1 then
                                    r_x_ball <= r_x_ball_nxt;
                                    r_x_ball_nxt <= r_x_ball_nxt -1;
                                elsif r_x_ball_nxt = pc_X_PADDLE_PLAYER1 then
                                    r_x_ball <= r_x_ball_nxt;
                                    r_x_ball_nxt <= r_x_ball_nxt +1;
                                end if;
                            end if;

                            if r_y_ball < r_y_ball_nxt then
                                if r_y_ball_nxt /= pc_Y_BUTTOM_BORDER-1 then
                                    r_y_ball <= r_y_ball_nxt;
                                    r_y_ball_nxt <= r_y_ball_nxt +1;
                                elsif r_y_ball_nxt = pc_Y_BUTTOM_BORDER-1 then
                                    r_y_ball <= r_y_ball_nxt;
                                    r_y_ball_nxt <= r_y_ball_nxt -1;
                                end if;
                            elsif r_y_ball > r_y_ball_nxt then
                                if r_y_ball_nxt /= pc_Y_TOP_BORDER+1 then
                                    r_y_ball <= r_y_ball_nxt;
                                    r_y_ball_nxt <= r_y_ball_nxt -1;
                                elsif r_y_ball_nxt = pc_Y_TOP_BORDER+1 then
                                    r_y_ball <= r_y_ball_nxt;
                                    r_y_ball_nxt <= r_y_ball_nxt +1;
                                end if;
                            end if;
                        end if;
                    end if;
                end if;
            end process;

            o_x_ball <= to_unsigned(r_x_ball, o_x_ball'length);
            o_y_ball <= to_unsigned(r_y_ball, o_y_ball'length);

            process(i_clk) is
                begin
                    if rising_edge(i_clk) then
                        if (r_x = r_x_ball ) and (r_y = r_y_ball ) then
                            o_draw_ball <= pf_draw_ball(r_x, r_y, r_x_not_div, r_y_not_div);
                        else
                            o_draw_ball <= '0';
                        end if;
                    end if;
                end process;

    end RTL;