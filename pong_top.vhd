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
        i_clk       :   in      STD_LOGIC;  --50
        i_reset     :   in      STD_LOGIC;
		i_start	    :	in		STD_LOGIC;
        i_switch    :   in      unsigned(3 downto 0);

        --output to hdmi
        o_hdmi_clk      :   out     STD_LOGIC; --25MHz
        o_hdmi_HS       :   out     STD_LOGIC;
        o_hdmi_VS       :   out     STD_LOGIC;
        o_hdmi_DE       :   out     STD_LOGIC;
        o_hdmi_DATA_BUS :   out     unsigned(23 downto 0);

        --output to seven segment
        o_7seg_P1       :   out     unsigned(6 downto 0);
        o_7seg_P2       :   out     unsigned(6 downto 0);
        o_7seg_sign     :   out     unsigned(6 downto 0);

        --output to audio interface
        o_XCLK          :   out     STD_LOGIC;
        o_BCLK          :   out     STD_LOGIC;
        o_LRCLK         :   out     STD_LOGIC;
        o_DAC_DATA      :   out     STD_LOGIC
    );
end pong_top;

architecture RTL of pong_top is
    signal r_clk25    :    STD_LOGIC                :='0';
    signal r_switch   :    unsigned(3 downto 0)     :=(others=>'0');
    signal r_reset    :    STD_LOGIC                :='0';
	signal r_start    :    STD_LOGIC                :='0';

    signal w_hs       :    STD_LOGIC                 :='0';
    signal w_vs       :    STD_LOGIC                 :='0'; 
    signal w_de       :    STD_LOGIC                 :='0';

    signal w_blue         :  unsigned(g_VIDEO_WIDTH-1 downto 0)   :=(others=>'0');
    signal w_green        :  unsigned(g_VIDEO_WIDTH-1 downto 0)   :=(others=>'0');
    signal w_red          :  unsigned(g_VIDEO_WIDTH-1 downto 0)   :=(others=>'0');

    signal w_score_P1       :    integer                 :=0;
    signal w_score_P2       :    integer                 :=0;
    signal r_7seg_P1        :    unsigned(6 downto 0)    :=(others=>'0');
    signal r_7seg_P2        :    unsigned(6 downto 0)    :=(others=>'0');
    signal r_7seg_sign      :    unsigned(6 downto 0)    :=(others=>'0');

    signal w_beep_en        :       STD_LOGIC               :='0';
    signal w_sample         :       unsigned(23 downto 0)   :=(others=>'0');
    signal w_XCLK           :       STD_LOGIC               :='0';
    signal w_BCLK           :       STD_LOGIC               :='0';
    signal w_LRCLK          :       STD_LOGIC               :='0';
    signal w_DATA           :       STD_LOGIC               :='0';
	 
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
        debouncing0: entity work.debounce_filter 
        generic map (
            g_CLK_CYCLES => 1
        )
        port map (
            i_clk => i_clk, --50
            i_bouncy => i_switch(0),
            o_debounced => r_switch(0)
        );

        debouncing1: entity work.debounce_filter 
        generic map (
            g_CLK_CYCLES => 1
        )
        port map (
            i_clk => i_clk, --50
            i_bouncy => i_switch(1),
            o_debounced => r_switch(1)
        );

        debouncing2: entity work.debounce_filter 
        generic map (
            g_CLK_CYCLES => 1
        )
        port map (
            i_clk => i_clk, --50
            i_bouncy => i_switch(2),
            o_debounced => r_switch(2)
        );

        debouncing3: entity work.debounce_filter 
        generic map (
            g_CLK_CYCLES => 1
        )
        port map (
            i_clk => i_clk, --50
            i_bouncy => i_switch(3),
            o_debounced => r_switch(3)
        );



        --debouncing reset button
        debouncing_reset: entity work.debounce_filter 
        generic map (
            g_CLK_CYCLES => 500000
        )
        port map (
            i_clk => i_clk, --50
            i_bouncy => i_reset,
            o_debounced => r_reset
        );

		  --debouncing start button
        debouncing_start: entity work.debounce_filter 
        generic map (
            g_CLK_CYCLES => 500000
        )
        port map (
            i_clk => i_clk, --50
            i_bouncy => i_start,
            o_debounced => r_start
        );

        --pong game
        pong_game : entity work.pong_SM
        generic map(
            g_VIDEO_WIDTH=> g_VIDEO_WIDTH
        )
        port map(
            i_clk=> r_clk25,
            i_reset=>r_reset,
            i_start=>r_start,
            i_btn_up_P1_L=>r_switch(0),
            i_btn_dwn_P1_L=>r_switch(1),
            i_btn_up_P2_L=>r_switch(2),
            i_btn_dwn_P2_L=>r_switch(3),
            o_hs=>w_hs,
            o_vs=>w_vs,
            o_de=>w_de,
            o_blue=>w_blue,
            o_green=>w_green,
            o_red=>w_red,
            o_score_P1 => w_score_P1,
            o_score_P2 => w_score_P2,
            o_beep_en => w_beep_en
        );

        --generating simple beep sound
        beep_genarating: entity work.beep_gen
        generic map (
            g_CLK_CYCLES => 26
        )
        port map (
            i_rlclk => w_LRCLK,
            i_en => w_beep_en,
            o_sample => w_sample
        );

        --i2s synchronizing
        i2s_transmitter: entity work.i2s_tx
        port map (
            i_clk => i_clk, --50 MHz
            i_sample => w_sample,
            o_XCLK => w_XCLK,
            o_BCLK => w_BCLK,
            o_LRCLK => w_LRCLK,
            o_DATA => w_DATA
        );
        
        sevenSegment_display_P1: entity work.sevenSeg_display
        port map (
            i_clk => r_clk25,
            i_score => w_score_P1,
            o_7seg => r_7seg_P1
        );

        sevenSegment_display_P2: entity work.sevenSeg_display
        port map (
            i_clk => r_clk25,
            i_score => w_score_P2,
            o_7seg => r_7seg_P2
        );

        sevenSegment_display_sign: entity work.sevenSeg_display
        port map (
            i_clk => r_clk25,
            i_score => 10,  --represent "-"
            o_7seg => r_7seg_sign
        );
    

        o_hdmi_clk<= r_clk25;
        o_hdmi_HS<= w_hs;
        o_hdmi_VS<= w_VS;
        o_hdmi_DE<= w_DE;
        o_hdmi_DATA_BUS<= w_red & w_green & w_blue;

        o_7seg_P1 <= not r_7seg_P1;
        o_7seg_P2 <= not r_7seg_P2;
        o_7seg_sign <= not r_7seg_sign;

        o_XCLK <= w_XCLK;
        o_BCLK <= w_BCLK;
        o_LRCLK <= w_LRCLK;
        o_DAC_DATA <= w_DATA;


    end RTL;