library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pongPack.ALL;

entity pong_top is
    generic (
        g_VIDEO_WIDTH :   integer     :=8;
    );
    port (
        i_clk       :   in      STD_LOGIC;  --50
        i_reset     :   in      STD_LOGIC;
        i_switch    :   in      unsigned(3 downto 0);

        --output to hdmi
        o_hdmi_clk      :   out     STD_LOGIC; --25MHz
        o_hdmi_HS       :   out     STD_LOGIC;
        o_hdmi_VS       :   out     STD_LOGIC;
        o_hdmi_DE       :   out     STD_LOGIC;
        o_hdmi_DATA_BUS :   out     unsigned(23 downto 0)
    );
end pong_top;

architecture RTL of pong_top is
    signal r_clk25    :    STD_LOGIC                :='0';
    signal r_switch   :    unsigned(3 downto 0)     :=(others=>'0');
    signal r_reset    :    STD_LOGIC                :='0';

    signal w_x        :    unsigned(pc_VGA_BITS-1 downto 0) :=(others=>'0');
    signal w_y        :    unsigned(pc_VGA_BITS-1 downto 0) :=(others=>'0');
    signal r_hs       :    STD_LOGIC                 :='0';
    signal r_vs       :    STD_LOGIC                 :='0'; 
    signal r_de       :    STD_LOGIC                 :='0';
    
    signal r_x        :    unsigned(pc_GAME_BITS-1 downto 0) :=(others=>'0');
    signal r_y        :    unsigned(pc_GAME_BITS-1 downto 0) :=(others=>'0');

    signal r_draw_paddle1 :  STD_LOGIC    :='0';
    signal r_draw_paddle2 :  STD_LOGIC    :='0';
    signal r_draw_border  :  STD_LOGIC    :='0';
    signal r_draw         :  STD_LOGIC    :='0';

    signal r_blue         :  unsigned(g_VIDEO_WIDTH downto 0)   :=(others=>'0');
    signal r_green        :  unsigned(g_VIDEO_WIDTH downto 0)   :=(others=>'0');
    signal r_red          :  unsigned(g_VIDEO_WIDTH downto 0)   :=(others=>'0');

    begin
        --dividing clock frequency
        clk25: entity work.freq_divider
        generic map (
            g_CLK_CYCLES => 1
        )
        port map (
            i_clk => i_clk,  --50
            o_clk => r_clk25 --25
        );



        --debouncing switches
        debouncing0: entity debounce_filter 
        generic map (
            g_CLK_CYCLES => 500000
        )
        port map (
            i_clk => i_clk, --50
            i_bouncy => i_switch(0),
            o_debounced => r_switch(0),
        );

        debouncing1: entity debounce_filter 
        generic map (
            g_CLK_CYCLES => 500000
        )
        port map (
            i_clk => i_clk, --50
            i_bouncy => i_switch(1),
            o_debounced => r_switch(1),
        );

        debouncing2: entity debounce_filter 
        generic map (
            g_CLK_CYCLES => 500000
        )
        port map (
            i_clk => i_clk, --50
            i_bouncy => i_switch(2),
            o_debounced => r_switch(2),
        );

        debouncing3: entity debounce_filter 
        generic map (
            g_CLK_CYCLES => 500000
        )
        port map (
            i_clk => i_clk, --50
            i_bouncy => i_switch(3),
            o_debounced => r_switch(3),
        );



        --debouncing reset button
        debouncing_reset: entity debounce_filter 
        generic map (
            g_CLK_CYCLES => 500000
        )
        port map (
            i_clk => i_clk, --50
            i_bouncy => i_reset,
            o_debounced => r_reset,
        );



        --synchronizing
        sync : entity work.HVsync
        port map (
            i_clk=> r_clk25,  --25MHz
            i_reset=> r_reset,
            o_x=>w_x,
            o_y=>w_y,
            o_HS=>r_hs,
            o_VS=>r_vs,
            o_DE=>r_de
        );

        r_x <= w_x(VGA_BITS-1 downto 5);
        r_y <= w_y(VGA_BITS-1 downto 5);


        --paddle 1
        paddle1: entity work.pong_paddle
        generic map (
        g_X_LOCATION_PADDLE=> pc_X_PADDLE_PLAYER1,
        )
        port map (
            i_clk=> i_clk,  --50
            i_x=> w_x,
            i_y=> w_y,
            i_btn_up=> r_switch(0)
            i_btn_dwn=> r_switch(1)
            o_y_paddle_top=> open,
            o_y_paddle_dwn=> open,
            o_draw_paddle=> r_draw_paddle1
        );


        --paddle 2
        paddle2: entity work.pong_paddle
        generic map (
        g_X_LOCATION_PADDLE=> pc_X_PADDLE_PLAYER2,
        )
        port map (
            i_clk=> i_clk,  --50
            i_x=> w_x,
            i_y=> w_y,
            i_btn_up=> r_switch(2)
            i_btn_dwn=> r_switch(3)
            o_y_paddle_top=> open,
            o_y_paddle_dwn=> open,
            o_draw_paddle=> r_draw_paddle2
        );

        --border
        border: entity work.pong_border
        port map (
            i_x=> w_x,
            i_y => w_y,
            o_draw_border => r_draw_border
        );


        r_draw <= '1' when r_draw_paddle1 = '1' or r_draw_paddle2 = '1' or r_draw_border = '1' else '0';

    r_bule <= (others=>'1') when r_de = '1' else (others=>'0');
    r_green <= (others=>'1') when r_de = '1' else (others=>'0');
    r_red <= (others=>'1') when r_draw = '1' and r_de = '1' else (others=>'0');

    o_hdmi_clk<= r_clk25;
    o_hdmi_HS<= r_hs;
    o_hdmi_VS<= r_VS,
    o_hdmi_DE<= r_DE,
    o_hdmi_DATA_BUS<= r_blue & r_green & r_red;

    end RTL;