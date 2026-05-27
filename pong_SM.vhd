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
        i_clk           :   in      STD_LOGIC; --25MHz
        i_reset         :   in      STD_LOGIC;
        i_start         :   in      STD_LOGIC;
        i_btn_up_P1_L   :   in      STD_LOGIC;
        i_btn_dwn_P1_L  :   in      STD_LOGIC;
        i_btn_up_P2_L   :   in      STD_LOGIC;
        i_btn_dwn_P2_L  :   in      STD_LOGIC;
        o_hs            :   out     STD_LOGIC;
        o_vs            :   out     STD_LOGIC;
        o_de            :   out     STD_LOGIC;
        o_blue          :   out     unsigned(g_VIDEO_WIDTH-1 downto 0);
        o_green         :   out     unsigned(g_VIDEO_WIDTH-1 downto 0);
        o_red           :   out     unsigned(g_VIDEO_WIDTH-1 downto 0);
        o_score_P1      :   out     integer;
        o_score_P2      :   out     integer;
        o_beep_en       :   out     STD_LOGIC;
        o_start_en      :   out     STD_LOGIC;
        o_gameOver_en   :   out     STD_LOGIC
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

    --paddle and ball signals
    signal r_y_paddle1_top        :    unsigned(pc_GAME_BITS-1 downto 0) :=(others=>'0');
    signal r_y_paddle1_dwn        :    unsigned(pc_GAME_BITS-1 downto 0) :=(others=>'0');
    signal r_y_paddle2_top        :    unsigned(pc_GAME_BITS-1 downto 0) :=(others=>'0');
    signal r_y_paddle2_dwn        :    unsigned(pc_GAME_BITS-1 downto 0) :=(others=>'0');
    signal r_x_ball               :    unsigned(pc_GAME_BITS-1 downto 0) :=(others=>'0');
    signal r_y_ball               :    unsigned(pc_GAME_BITS-1 downto 0) :=(others=>'0');

    --drawing signals
    signal r_draw_paddle1         :  STD_LOGIC    :='0';
    signal r_draw_paddle2         :  STD_LOGIC    :='0';
    signal r_draw_ball            :  STD_LOGIC    :='0';
    signal r_draw_edge_border     :  STD_LOGIC    :='0';
    signal r_draw_middle_border   :  STD_LOGIC    :='0';
    signal r_draw_whole_border    :  STD_LOGIC    :='0';
    signal r_draw_start_txt       :  STD_LOGIC    :='0';
    signal r_draw_gameOver_txt    :  STD_LOGIC    :='0';
    signal r_draw_total_start     :  STD_LOGIC    :='0';
    signal r_draw_total_game      :  STD_LOGIC    :='0';
    signal r_draw_total_gameOver  :  STD_LOGIC    :='0';
    
    --determine which page to dry, start page, game page or game over page.
    signal r_draw_start_DV        :  STD_LOGIC    :='0';
    signal r_draw_game_DV         :  STD_LOGIC    :='0';
    signal r_draw_gameOver_DV     :  STD_LOGIC    :='0';

    --color data bus
    signal r_blue         :  unsigned(g_VIDEO_WIDTH-1 downto 0)   :=(others=>'0');
    signal r_green        :  unsigned(g_VIDEO_WIDTH-1 downto 0)   :=(others=>'0');
    signal r_red          :  unsigned(g_VIDEO_WIDTH-1 downto 0)   :=(others=>'0');
	 
    --signals for converting to integer
	signal r_x_ball_int          	 :   integer range 0 to pc_GAME_WIDTH-1      :=0;
    signal r_y_ball_int          	 :   integer range 0 to pc_GAME_HEIGHT-1     :=0;
	signal r_y_paddle1_top_int       :   integer;
    signal r_y_paddle1_dwn_int       :   integer;
	signal r_y_paddle2_top_int       :   integer;
    signal r_y_paddle2_dwn_int       :   integer; 

    --state machine
    type pong_game is (IDLE, GAME_START, COUNT, GAME_RUNNING, P1_WIN, P2_WIN, END_GAME);
    signal r_SM         :   pong_game       :=IDLE;

    --score signals
    signal r_score_p1        : integer range 0 to 9   :=0;
    signal r_score_p2        : integer range 0 to 9   :=0;
    signal r_start_counter   : integer range 0 to pc_START_LIMIT   :=0;

    --register the start and reset button to find the falling edge
    signal r_start          :   STD_LOGIC   :='0';
    signal w_reset          :   STD_LOGIC   :='0';
    signal w_start          :   STD_LOGIC   :='0';

    --beep
    signal r_beep_en        :   STD_LOGIC   :='0';
    signal r_beep_counter   :   integer range 0 to pc_BEEP_LENGTH   :=0;


    begin	 
        process(i_clk) is
            begin
                if rising_edge(i_clk) then
                    w_reset <= i_reset;
                    w_start <= i_start;

                    if i_reset = '0' and w_reset = '1' then --falling edge of the reset button will reset the game
                        r_start  <= '0';
                        r_score_P1 <= 0;
                        r_score_P2 <= 0;
                        r_SM       <= IDLE;
                    else
                        
                        case r_SM is
                            when IDLE =>
                                r_draw_start_DV <= '1';
                                r_draw_game_DV <= '0';
                                r_draw_gameOver_DV <= '0';

                                if i_start= '0' and w_start = '1' then  --falling edge of start button, go from sart page to game page
                                    r_SM <= GAME_START;
                                end if;
                            
                            when GAME_START =>
                                r_draw_start_DV <= '0';
                                r_draw_game_DV <= '1';
                                r_draw_gameOver_DV <= '0';

                                if i_start= '0' and w_start = '1' then         --falling edge of start button, start the game
                                    r_SM <= COUNT;
                                end if;
									
                            when COUNT =>
                                if r_start_counter < pc_START_LIMIT then      -- bull starts to move after some seconds
                                    r_start_counter <= r_start_counter + 1;
                                else
                                    r_start_counter <= 0;  
                                    r_SM <= GAME_RUNNING;
                                end if;
                                 

                            when GAME_RUNNING =>
								r_start <= '1';

                                if r_x_ball_int = pc_X_PADDLE_PLAYER1 then
                                    if r_y_ball_int <= r_y_paddle1_dwn_int and r_y_ball_int >= r_y_paddle1_top_int then
                                        r_SM <= GAME_RUNNING;
                                        r_beep_en <= '1';

                                    else
                                        r_SM <= P2_WIN;
                                    end if;
                                
                                elsif r_x_ball_int = pc_X_PADDLE_PLAYER2 then
                                    if r_y_ball_int <= r_y_paddle2_dwn_int and r_y_ball_int >= r_y_paddle2_top_int then
                                        r_SM <= GAME_RUNNING;
                                        r_beep_en <= '1';

                                    else
                                        r_SM <= P1_WIN;
                                    end if;
                                else
                                    r_SM <= GAME_RUNNING;
                                end if;
										  
								--beep for 20ms when colliding		  
                                if r_beep_en = '1' then
                                    if r_beep_counter < pc_BEEP_LENGTH then
                                            r_beep_counter <= r_beep_counter + 1;
                                    else
                                            r_beep_en <= '0';
                                            r_beep_counter <= 0;
                                    end if;
                                end if;

                            when P1_WIN =>
                                if r_score_P1 = pc_SCORE_LIMIT then
                                    r_score_P1 <= 0;
												r_score_P2 <= 0;
                                else
                                    r_score_P1 <= r_score_P1 + 1;
                                    r_SM <= END_GAME;
                                end if;

                            when P2_WIN =>
                                if r_score_P2 = pc_SCORE_LIMIT then
                                    r_score_P2 <= 0;
												r_score_P1 <= 0;
                                else
                                    r_score_P2 <= r_score_P2 + 1;
                                    r_SM <= END_GAME;
                                end if;

                            when END_GAME =>
                                r_start <= '0';

                                r_draw_start_DV <= '0';
                                r_draw_game_DV <= '0';
                                r_draw_gameOver_DV <= '1';

                                if i_start= '0' and w_start = '1' then  --falling edge of start button, go from game over page to game page
                                    r_SM <= GAME_START;
                                end if;

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
            i_reset=> '0',
            o_x=>w_x,
            o_y=>w_y,
            o_HS=>r_hs,
            o_VS=>r_vs,
            o_DE=>r_de
        );
        
        --dividing both signals by 16
        r_x <= w_x(pc_VGA_BITS-1 downto 4);
        r_y <= w_y(pc_VGA_BITS-1 downto 4);

        --paddle 1
        paddle1: entity work.pong_paddle
        generic map (
        g_X_LOCATION_PADDLE=> pc_X_PADDLE_PLAYER1
        )
        port map (
            i_clk=> i_clk,  --25MHz
			i_start => r_start,
            i_x=> r_x,
            i_y=> r_y,
            i_btn_up_L=> i_btn_up_P1_L,
            i_btn_dwn_L=> i_btn_dwn_P1_L,
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
            i_clk=> i_clk,  --25MHz
			i_start => r_start,
            i_x=> r_x,
            i_y=> r_y,
            i_btn_up_L=> i_btn_up_P2_L,
            i_btn_dwn_L=> i_btn_dwn_P2_L,
            o_y_paddle_top=> r_y_paddle2_top,
            o_y_paddle_dwn=> r_y_paddle2_dwn,
            o_draw_paddle=> r_draw_paddle2
        );

        --ball
        ball: entity work.pong_ball
        port map (
            i_clk => i_clk, --25MHz
			i_start => r_start,
            i_x => r_x,
            i_y => r_y,
            i_x_not_div => w_x,
            i_y_not_div => w_y,
            o_x_ball => r_x_ball,
            o_y_ball => r_y_ball,
            o_draw_ball => r_draw_ball
        );

        --drawing border for game
        border: entity work.pong_border
        port map (
            i_x=> r_x,
            i_y => r_y,
            o_draw_edge_border => r_draw_edge_border,
            o_draw_middle_border => r_draw_middle_border
        );

        --drawing start page
        start_page: entity work.pong_start
        port map (
            i_x=> r_x,
            i_y => r_y,
            o_draw_start_txt => r_draw_start_txt
        );

        --drawing game over page
        gameOver_page: entity work.pong_gameOver
        port map (
            i_x=> r_x,
            i_y => r_y,
            o_draw_gameOver_txt => r_draw_gameOver_txt
        );
        


        --converting unsigned signals to integer
        r_x_ball_int <= to_integer(r_x_ball);
		r_y_ball_int <= to_integer(r_y_ball);
		r_y_paddle1_top_int <= to_integer(r_y_paddle1_top);
		r_y_paddle1_dwn_int <= to_integer(r_y_paddle1_dwn);
		r_y_paddle2_top_int <= to_integer(r_y_paddle2_top);
		r_y_paddle2_dwn_int <= to_integer(r_y_paddle2_dwn);
        
        

        r_blue <=   (others=>'1') when r_draw_start_DV = '1'     and r_draw_total_start='1'     and r_de = '1' else  --draw start text in start page(white)
                    (others=>'1') when r_draw_start_DV = '1'     and r_draw_total_start='0'     and r_de = '1' else  --draw background of start page(green-blue)
                    
                    (others=>'0') when r_draw_game_DV = '1'      and r_draw_paddle1 ='1'       and r_de = '1' else  --paddle 1 in game page(yellow)
                    (others=>'0') when r_draw_game_DV = '1'      and r_draw_paddle2 ='1'       and r_de = '1' else  --paddle 2 in game page(red)
					(others=>'1') when r_draw_game_DV = '1'      and r_draw_ball ='1'          and r_de = '1' else  --draw ball in game page(blue)
						  
                    (others=>'1') when r_draw_game_DV = '1'      and r_draw_whole_border ='1'   and r_de = '1' else  --border in game page(white)
                    (others=>'0') when r_draw_game_DV = '1'      and r_draw_total_game= '0'     and r_de = '1' else  --background in game page(green-red)
                    (others=>'1') when r_draw_gameOver_DV = '1'  and r_draw_total_gameOver ='1' and r_de = '1' else  --draw game over text in end page(white)
                    (others=>'0') when r_draw_gameOver_DV = '1'  and r_draw_total_gameOver='0'  and r_de = '1' else  --draw background of start page(red)
                    (others=>'0');
        
        r_green <=  (others=>'1') when r_draw_start_DV = '1'     and r_draw_total_start='1'     and r_de = '1' else  --draw start text in start page(white)
                    (others=>'1') when r_draw_start_DV = '1'     and r_draw_total_start='0'     and r_de = '1' else  --draw background of start page(green-blue)
                    
                    (others=>'1') when r_draw_game_DV = '1'      and r_draw_paddle1 ='1'       and r_de = '1' else  --paddle 1 in game page(yellow)
                    (others=>'0') when r_draw_game_DV = '1'      and r_draw_paddle2 ='1'       and r_de = '1' else  --paddle 2 in game page(red)
					(others=>'0') when r_draw_game_DV = '1'      and r_draw_ball ='1'          and r_de = '1' else  --draw ball in game page(blue)
						  
                    (others=>'1') when r_draw_game_DV = '1'      and r_draw_whole_border ='1'   and r_de = '1' else  --border in game page(white)
                    "01100000"    when r_draw_game_DV = '1'      and r_draw_total_game= '0'     and r_de = '1' else  --background in game page(green-red)
                    (others=>'1') when r_draw_gameOver_DV = '1'  and r_draw_total_gameOver ='1' and r_de = '1' else  --draw game over text in end page(white)
                    (others=>'0') when r_draw_gameOver_DV = '1'  and r_draw_total_gameOver='0'  and r_de = '1' else  --draw background of start page(red)
                    (others=>'0');

        r_red <=    (others=>'1') when r_draw_start_DV = '1'     and r_draw_total_start='1'     and r_de = '1' else  --draw start text in start page(white)
                    (others=>'0') when r_draw_start_DV = '1'     and r_draw_total_start='0'     and r_de = '1' else  --draw background of start page(green-blue)
                    
                    (others=>'1') when r_draw_game_DV = '1'      and r_draw_paddle1 ='1'       and r_de = '1' else  --paddle 1 in game page(yellow)
                    (others=>'1') when r_draw_game_DV = '1'      and r_draw_paddle2 ='1'       and r_de = '1' else  --paddle 2 in game page(red)
					(others=>'0') when r_draw_game_DV = '1'      and r_draw_ball ='1'          and r_de = '1' else  --draw ball in game page(blue)
						  
                    (others=>'1') when r_draw_game_DV = '1'      and r_draw_whole_border ='1'   and r_de = '1' else  --border in game page(white)
                    "00001010"    when r_draw_game_DV = '1'      and r_draw_total_game= '0'     and r_de = '1' else  --background in game page(green-red)
                    (others=>'1') when r_draw_gameOver_DV = '1'  and r_draw_total_gameOver ='1' and r_de = '1' else  --draw game over text in end page(white)
                    (others=>'1') when r_draw_gameOver_DV = '1'  and r_draw_total_gameOver='0'  and r_de = '1' else  --draw background of start page(red)
                    (others=>'0');

     
        r_draw_total_start <= '1' when r_draw_edge_border = '1' or r_draw_start_txt = '1' else '0';
        r_draw_total_gameOver <= '1' when r_draw_edge_border = '1' or r_draw_gameOver_txt = '1' else '0';
        r_draw_whole_border <= '1' when r_draw_edge_border = '1' or r_draw_middle_border = '1' else '0';
        r_draw_total_game <= '1' when r_draw_paddle1='1' or r_draw_paddle2='1' or r_draw_whole_border='1' or r_draw_ball ='1'  else '0';

		
        --connecting signals to output signals
		o_hs <= r_hs;
		o_vs <= r_vs;
		o_de <= r_de;
		o_red <= r_red;
		o_blue <= r_blue;
		o_green <= r_green;
        o_score_P1 <= r_score_P1;
        o_score_P2 <= r_score_P2;
        o_beep_en <= r_beep_en;
        o_start_en <= r_draw_start_DV;
        o_gameOver_en <= r_draw_gameOver_DV;
			
    end RTL;