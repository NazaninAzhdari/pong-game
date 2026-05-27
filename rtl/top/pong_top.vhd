library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pongPack.ALL;

entity pong_top is
    generic (
        g_VIDEO_WIDTH :   integer     :=8
    );
    port (
        i_clk           :   in      STD_LOGIC;  --50 MHz
        i_reset         :   in      STD_LOGIC;
		i_start	        :	in		STD_LOGIC;
        i_switch        :   in      unsigned(3 downto 0);

        --output to hdmi
        o_hdmi_clk      :   out     STD_LOGIC; --25MHz
        o_hdmi_HS       :   out     STD_LOGIC;
        o_hdmi_VS       :   out     STD_LOGIC;
        o_hdmi_DE       :   out     STD_LOGIC;
        o_hdmi_DATA_BUS :   out     unsigned(23 downto 0);

        --output to seven segment display
        o_7seg_P1       :   out     unsigned(6 downto 0);
        o_7seg_P2       :   out     unsigned(6 downto 0);
        o_7seg_G        :   out     STD_LOGIC;

        --output to audio interface
        o_XCLK          :   out     STD_LOGIC;
        o_BCLK          :   out     STD_LOGIC;
        o_LRCLK         :   out     STD_LOGIC;
        o_DAC_DATA      :   out     STD_LOGIC
    );
end pong_top;

architecture RTL of pong_top is
    --dividing frequency
    signal r_clk25    :    STD_LOGIC                :='0';

    --debouncing reset and start button
    signal r_reset    :    STD_LOGIC                :='0';
	signal r_start    :    STD_LOGIC                :='0';

    --HVsync signals
    signal w_hs           :    STD_LOGIC                 :='0';
    signal w_vs           :    STD_LOGIC                 :='0'; 
    signal w_de           :    STD_LOGIC                 :='0';

    --video bus signals
    signal w_blue         :  unsigned(g_VIDEO_WIDTH-1 downto 0)   :=(others=>'0');
    signal w_green        :  unsigned(g_VIDEO_WIDTH-1 downto 0)   :=(others=>'0');
    signal w_red          :  unsigned(g_VIDEO_WIDTH-1 downto 0)   :=(others=>'0');

    --score signals and disply the score on 7seg
    signal w_score_P1       :    integer                 :=0;
    signal w_score_P2       :    integer                 :=0;
    signal r_7seg_P1        :    unsigned(6 downto 0)    :=(others=>'0');
    signal r_7seg_P2        :    unsigned(6 downto 0)    :=(others=>'0');

    --audio interface
    signal w_beep_en        :       STD_LOGIC               :='0';
    signal w_start_en       :       STD_LOGIC               :='0';  
    signal w_gameOver_en    :       STD_LOGIC               :='0';

 
    begin
        -----------------------------
        --dividing clock frequency
        -----------------------------
        clk25: entity work.freq_divider
        generic map (
            g_HALF_PERIOD_OUT_FRQ => 1
        )
        port map (
            i_clk => i_clk,  --50
            o_clk => r_clk25 --25
        );

        --------------------------
        --debouncing reset button
        --------------------------
        debouncing_reset: entity work.debounce_filter 
        generic map (
            g_CLK_CYCLES => 500000
        )
        port map (
            i_clk => i_clk, --50
            i_bouncy => i_reset,
            o_debounced => r_reset
        );

        ----------------------------
		  --debouncing start button
        ----------------------------
        debouncing_start: entity work.debounce_filter 
        generic map (
            g_CLK_CYCLES => 500000
        )
        port map (
            i_clk => i_clk, --50
            i_bouncy => i_start,
            o_debounced => r_start
        );

        --------------------------
        --pong game state machine
        --------------------------
        pong_game : entity work.pong_SM
        generic map(
            g_VIDEO_WIDTH=> g_VIDEO_WIDTH
        )
        port map(
            i_clk=> r_clk25,
            i_reset=>r_reset,
            i_start=>r_start,
            i_btn_up_P1_L=>i_switch(0),
            i_btn_dwn_P1_L=>i_switch(1),
            i_btn_up_P2_L=>i_switch(2),
            i_btn_dwn_P2_L=>i_switch(3),
            o_hs=>w_hs,
            o_vs=>w_vs,
            o_de=>w_de,
            o_blue=>w_blue,
            o_green=>w_green,
            o_red=>w_red,
            o_score_P1 => w_score_P1,
            o_score_P2 => w_score_P2,
            o_beep_en => w_beep_en,
            o_start_en => w_start_en,
            o_gameOver_en => w_gameOver_en
        );

        ------------------
        --audio interface
        ------------------
        audio: entity work.audio_top
        port map(
            i_clk => i_clk,
			i_clk25 => r_clk25,
            i_reset => r_reset,
            i_beep_En => w_beep_en,
            i_start_en => w_start_en,
            i_gameOver_en => w_gameOver_en,
            o_MCLK => o_XCLK,
            o_LRCLK => o_LRCLK,
            o_BCLK => o_BCLK,
            o_DATA => o_DAC_DATA
        );

        ---------------------------------------------
        --display the player 1's score on first 7seg 
        ---------------------------------------------
        sevenSegment_display_P1: entity work.sevenSeg_display
        port map (
            i_clk => r_clk25,
            i_score => w_score_P1,
            o_7seg => r_7seg_P1
        );

        o_7seg_P1 <= not r_7seg_P1;

        ----------------------------------------------
        --display the player 2's score on second 7seg 
        ----------------------------------------------
        sevenSegment_display_P2: entity work.sevenSeg_display
        port map (
            i_clk => r_clk25,
            i_score => w_score_P2,
            o_7seg => r_7seg_P2
        );
        
        o_7seg_P2 <= not r_7seg_P2;

        -----------------------------------------------------------------------------
        --display a simple minus "-" between the score of players, on the middle 7seg
        --for example like this =>  0 - 0 
        -----------------------------------------------------------------------------
        o_7seg_G <= '0'; --Active low
    
        ------------------------------------
        --connecting hdmi interface signals
        ------------------------------------
        o_hdmi_clk<= r_clk25;
        o_hdmi_HS<= w_hs;
        o_hdmi_VS<= w_VS;
        o_hdmi_DE<= w_DE;
        o_hdmi_DATA_BUS<= w_red & w_green & w_blue;

    end RTL;