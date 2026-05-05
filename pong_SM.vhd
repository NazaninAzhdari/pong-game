library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pongPack.ALL;

entity pong_SM is
    generic (
        g_VIDEO_WIDTH   :   integer :=8
    );
    port (
        i_clk           :   in      STD_LOGIC; --25
        i_reset         :   in      STD_LOGIC;
        i_start         :   in      STD_LOGIC;
        i_btn_up_P1     :   in      STD_LOGIC;
        i_btn_dwn_P1    :   in      STD_LOGIC;
        i_btn_up_P2     :   in      STD_LOGIC;
        i_btn_dwn_P2    :   in      STD_LOGIC;
        o_hs            :   out     STD_LOGIC;
        o_vs            :   out     STD_LOGIC;
        o_de            :   out     STD_LOGIC;
        o_blue          :   out     unsigned(g_VIDEO_WIDTH-1 downto 0);
        o_green         :   out     unsigned(g_VIDEO_WIDTH-1 downto 0);
        o_red           :   out     unsigned(g_VIDEO_WIDTH-1 downto 0)
    );
end pong_SM;

architecture RTL of pong_SM is
    --sync signals
    signal w_x        :    unsigned(pc_VGA_BITS-1 downto 0) :=(others=>'0');
    signal w_y        :    unsigned(pc_VGA_BITS-1 downto 0) :=(others=>'0');
    signal r_hs       :    STD_LOGIC                 :='0';
    signal r_vs       :    STD_LOGIC                 :='0'; 
    signal r_de       :    STD_LOGIC                 :='0';
    signal r_x        :    unsigned(pc_GAME_BITS-1 downto 0) :=(others=>'0');
    signal r_y        :    unsigned(pc_GAME_BITS-1 downto 0) :=(others=>'0');

    signal r_y_paddle1_top        :    unsigned(pc_GAME_BITS-1 downto 0) :=(others=>'0');
    signal r_y_paddle1_dwn        :    unsigned(pc_GAME_BITS-1 downto 0) :=(others=>'0');
    signal r_y_paddle2_top        :    unsigned(pc_GAME_BITS-1 downto 0) :=(others=>'0');
    signal r_y_paddle2_dwn        :    unsigned(pc_GAME_BITS-1 downto 0) :=(others=>'0');
    signal r_x_ball               :    unsigned(pc_GAME_BITS-1 downto 0) :=(others=>'0');
    signal r_y_ball               :    unsigned(pc_GAME_BITS-1 downto 0) :=(others=>'0');

    signal r_draw_paddle1 :  STD_LOGIC    :='0';
    signal r_draw_paddle2 :  STD_LOGIC    :='0';
    signal r_draw_border  :  STD_LOGIC    :='0';
    signal r_draw_ball    :  STD_LOGIC    :='0';
    signal r_draw         :  STD_LOGIC    :='0';

    signal r_blue         :  unsigned(g_VIDEO_WIDTH-1 downto 0)   :=(others=>'0');
    signal r_green        :  unsigned(g_VIDEO_WIDTH-1 downto 0)   :=(others=>'0');
    signal r_red          :  unsigned(g_VIDEO_WIDTH-1 downto 0)   :=(others=>'0');
	 
	 signal r_x_ball_int          	 :   integer range 0 to pc_GAME_WIDTH-1      :=0;
    signal r_y_ball_int          	 :   integer range 0 to pc_GAME_HEIGHT-1     :=0;
	 signal r_y_paddle1_top_int       :   integer;
    signal r_y_paddle1_dwn_int       :   integer;
	 signal r_y_paddle2_top_int       :   integer;
    signal r_y_paddle2_dwn_int       :   integer; 



    type pong_game is (IDLE, GAME_RUNNING, P1_WIN, P2_WIN, END_GAME);
    signal r_SM     :   pong_game       :=IDLE;

    signal r_score_p1 : integer   :=0;
    signal r_score_p2 : integer   :=0;

    signal r_reset        :   STD_LOGIC   :='0';
    signal r_start        :   STD_LOGIC   :='0';
    signal w_reset        :   STD_LOGIC   :='0';
    signal w_start        :   STD_LOGIC   :='0';

    begin
	 
		r_x_ball_int <= to_integer(r_x_ball);
		r_y_ball_int <= to_integer(r_y_ball);
		r_y_paddle1_top_int <= to_integer(r_y_paddle1_top);
		r_y_paddle1_dwn_int <= to_integer(r_y_paddle1_dwn);
		r_y_paddle2_top_int <= to_integer(r_y_paddle2_top);
		r_y_paddle2_dwn_int <= to_integer(r_y_paddle2_dwn);

        process(i_clk) is
            begin
                if rising_edge(i_clk) then
                    w_reset <= i_reset;
                    w_start <= i_start;

                    if i_reset = '0' and w_reset = '1' then --falling edge of the reset button will reset the game
                        r_reset  <= '1';
                        r_start  <= '0';
                        r_score_P1 <= 0;
                        r_score_P2 <= 0;
                        r_SM       <= IDLE;
                    else
                        r_reset <= '0';

                        case r_SM is
                            when IDLE =>
                                if i_start= '0' and w_start = '1' then  --falling edge of start button, start the game
                                    r_start <= '1';
                                    r_SM <= GAME_RUNNING;
                                end if;

                            when GAME_RUNNING =>
											if r_x_ball_int = pc_X_PADDLE_PLAYER1 then
												if r_y_ball_int <= r_y_paddle1_dwn_int and r_y_ball_int >= r_y_paddle1_top_int then
													r_score_p1 <= r_score_p1 + 1;
												else
													r_SM <= END_GAME;
													r_start <= '0';
												end if;
											
											elsif r_x_ball_int = pc_X_PADDLE_PLAYER2 then
												if r_y_ball_int <= r_y_paddle2_dwn_int and r_y_ball_int >= r_y_paddle2_top_int then
													r_score_p2 <= r_score_p2 + 1;
												else
													r_SM <= END_GAME;
													r_start <= '0';
												end if;
												
											else
												r_SM <= GAME_RUNNING;
											end if;
											
											
                                

                            when P1_WIN =>
                                r_score_p1 <= r_score_p1 + 1;
                                r_SM <= GAME_RUNNING;

                            when P2_WIN =>
                                r_score_p2 <= r_score_p2 + 1;
                                r_SM <= GAME_RUNNING;

                            when END_GAME =>
                                r_start <= '0';
                                r_SM <= IDLE;

                            when others =>
                                r_SM <= IDLE;
                            end case;
                        end if;
                    end if;
            end process;



        --synchronizing
        sync : entity work.HVsync
        port map (
            i_clk=> i_clk,  --25MHz
            i_reset=> r_reset,
            o_x=>w_x,
            o_y=>w_y,
            o_HS=>r_hs,
            o_VS=>r_vs,
            o_DE=>r_de
        );

        r_x <= w_x(pc_VGA_BITS-1 downto 4);
        r_y <= w_y(pc_VGA_BITS-1 downto 4);


        --paddle 1
        paddle1: entity work.pong_paddle
        generic map (
        g_X_LOCATION_PADDLE=> pc_X_PADDLE_PLAYER1
        )
        port map (
            i_clk=> i_clk,  --25
			i_start => r_start,
            i_x=> r_x,
            i_y=> r_y,
            i_btn_up=> i_btn_up_P1,
            i_btn_dwn=> i_btn_dwn_P1,
            o_y_paddle_top=> r_y_paddle1_top,
            o_y_paddle_dwn=> r_y_paddle1_dwn,
            o_draw_paddle=> r_draw_paddle1
        );


        --paddle 2
        paddle2: entity work.pong_paddle
        generic map (
        g_X_LOCATION_PADDLE=> pc_X_PADDLE_PLAYER2
        )
        port map (
            i_clk=> i_clk,  --25
			i_start => r_start,
            i_x=> r_x,
            i_y=> r_y,
            i_btn_up=> i_btn_up_P2,
            i_btn_dwn=> i_btn_dwn_P2,
            o_y_paddle_top=> r_y_paddle2_top,
            o_y_paddle_dwn=> r_y_paddle2_dwn,
            o_draw_paddle=> r_draw_paddle2
        );

        --border
        border: entity work.pong_border
        port map (
            i_x=> r_x,
            i_y => r_y,
            o_draw_border => r_draw_border
        );


        --ball
        ball: entity work.pong_ball
        port map (
            i_clk => i_clk, --25
			i_start => r_start,
            i_x => r_x,
            i_y => r_y,
            o_x_ball => r_x_ball,
            o_y_ball => r_y_ball,
            o_draw_ball => r_draw_ball
        );



        r_draw <= '1' when r_draw_paddle1='1' or r_draw_paddle2='1' or r_draw_border='1' or r_draw_ball ='1'  else '0';

            r_blue <=   (others=>'0') when r_draw_ball = '1' and r_de = '1' else  --ball yellow
                        (others=>'1') when r_draw_paddle1 = '1' and r_de = '1' else --paddle 1 becomes blue 
                        (others=>'0') when r_draw_paddle2 = '1' and r_de = '1' else --paddle 2 becomes red
                        (others=>'1') when r_draw_border = '1' and r_de = '1' else  --border white
                        (others=>'0');
            r_green <=  (others=>'1') when r_draw_ball = '1' and r_de = '1' else  --ball yellow
                        (others=>'0') when r_draw_paddle1 = '1' and r_de = '1' else --paddle 1 becomes blue
						(others=>'0') when r_draw_paddle2 = '1' and r_de = '1' else --paddle 2 becomes red
						(others=>'1') when r_draw_border = '1' and r_de = '1' else --border white
                "01100000" when r_draw= '0' and r_de = '1' else --background green-red
                (others=>'0');
            r_red <=  (others=>'1') when r_draw_ball = '1' and r_de = '1' else  --ball yellow
                    (others=>'0') when r_draw_paddle1 = '1' and r_de = '1' else --paddle 1 becomes blue
					(others=>'1') when r_draw_paddle2 = '1' and r_de = '1' else --paddle 2 becomes red
					(others=>'1') when r_draw_border = '1' and r_de = '1' else --border white
                "00001010" when r_draw= '0' and r_de = '1' else --background green-red
                (others=>'0');
					 
			o_hs <= r_hs;
			o_vs <= r_vs;
			o_de <= r_de;
			o_red <= r_red;
			o_blue <= r_blue;
			o_green <= r_green;
			

    end RTL;