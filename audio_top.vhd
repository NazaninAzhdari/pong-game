library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity audio_top is
    port (
        i_clk       :   in      STD_LOGIC;
        i_reset_L   :   in      STD_LOGIC;

        o_MCLK      :   out      STD_LOGIC;
        o_LRCLK     :   out     STD_LOGIC;
        o_BCLK      :   out      STD_LOGIC;
        o_DATA      :   out     STD_LOGIC
    );
end audio_top;

architecture RTL of audio_top is
    signal w_LRCLK : STD_LOGIC  :='0';
    signal w_sample : unsigned(23 downto 0)  :=(others=>'0');

    begin
    
        beep_generator: entity work.beep_gen
        generic map(
            g_SAMPLE_WIDTH => 24,
            g_HALF_PERIOD_BEEP => 24 --1KHz frequency
        )
        port map(
            i_clk => i_clk, --50MHZ
            i_en  => -- i should make en enable signal that goes high when collision happens
            i_LRCLK => w_LRCLK,
            o_sample => w_sample
        );

        melody_gen : entity work.start_melody_gen
        generic map(
            g_SAMPLE_WIDTH => 24
        )
        port map(
            i_clk=> i_clk,
            i_en=> -- i should make en enable signal that goes high when we are in start frame
            i_LRCLK => w_LRCLK,
            o_sample => w_sample
        );


        i2s: entity work.i2s_transmitter
        generic map(
            g_SAMPLE_WIDTH => 24,
            g_HALF_PERIOD_MCLK => 2,  --12.5MHz 
            g_HALF_PERIOD_BCLK => 8  --3.1MHz
        )
        port map(
            i_clk => i_clk,
            i_reset => not i_reset_L,
            i_sample => w_sample,
            o_BCLK => o_BCLK,
            o_LRCLK => w_LRCLK,
            o_MCLK => o_MCLK,
            o_DATA => o_DATA
        );

        o_LRCLK <= w_LRCLK;

        

    end RTL;