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
        o_hdmi_DATA_BUS :   out     unsigned(23 downto 0)
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
            o_red=>w_red
        );
    

        o_hdmi_clk<= r_clk25;
        o_hdmi_HS<= w_hs;
        o_hdmi_VS<= w_VS;
        o_hdmi_DE<= w_DE;
        o_hdmi_DATA_BUS<= w_red & w_green & w_blue;

    end RTL;