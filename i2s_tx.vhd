library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2s_tx is
    port (
        i_clk         :       in      STD_LOGIC;            --FPGA Clock = 50 MHz 
        i_sample      :       in      unsigned(23 downto 0);
        o_XCLK        :       out     STD_LOGIC;            --Required Master Clock for running the DAC= 12.5 MHz
        o_LRCLK       :       out     STD_LOGIC;            --The LRCLK = Sample rate = 48 KHz => The LRCLK is high for right Channel and its low for left channel
        o_BCLK        :       out     STD_LOGIC;            --Bit CLK = Sample Rate * number of bits per channel * channels = 3.1 MHz = 48KHz * 32 * 2
        o_DATA        :       out     STD_LOGIC
    );
end i2s_tx;

architecture RTL of i2s_tx is
    --XCLK 
    constant    c_HALF_PERIOD_XCLK  :   integer     :=2;    --Number of Clock cycles required for half period of the Master Clock(12.5MHz).
                                                            --System Clock / (Master CLK * 2)
    signal      r_XCLK              :   STD_LOGIC   :='0';

    --Bit CLK
    constant    c_HALF_PERIOD_BCLK  :   integer     :=8;    --System Clock / (Master CLK * 2)
    signal      r_BCLK              :   STD_LOGIC   :='0';

    --LR clock
    signal      r_LRCLK             :   STD_LOGIC   :='1';
    signal      r_shift             :   unsigned(31 downto 0)   :=(others=>'0');
    signal      r_bit_counter       :   integer range 0 to 31   :=31;

    begin

        ------------------------------------
        --Generating 12.5 MHz Master Clock
        ------------------------------------
        generating_master_clock_12MHz : entity work.freq_divider
        generic map(
            g_HALF_PERIOD_OUT_FREQ => c_HALF_PERIOD_XCLK
        )
        port map (
            i_clk => i_clk,  --50 MHz 
            o_clk => r_XCLK  --12.5 MHz
        );

        -------------------------------------------------------------------------------------------
        --Generating 3.1 MHz Bit Clock
        --Bit Clock = sample rate(48KHz) * number of bits per channel(32) * number of channels(2)
        -------------------------------------------------------------------------------------------
        generating_bit_clock_3MHz : entity work.freq_divider
        generic map(
            g_HALF_PERIOD_OUT_FREQ=> c_HALF_PERIOD_BCLK
        )
        port map (
            i_clk => i_clk,  --50 MHz
            o_clk => r_BCLK  --3.1 MHz
        );

        process(r_BCLK) is
            begin
                if rising_edge(r_BCLK) then
                    o_DATA <= r_shift(31);                  --send the MSB
                    r_shift <= r_shift(30 downto 0) & '0';  --shift by one

                    if r_bit_counter < 31 then
                        r_bit_counter <= r_bit_counter + 1;
                    else
                        r_shift <= i_sample & "00000000";  --24 bits of real data + 8 bits padding
                        r_bit_counter <= 0;
                        r_LRCLK <= not r_LRCLK;           --generating the LRCLK, toggles every 32 bits transfered
                    end if;
                end if;

            end process;

        o_XCLK <= r_XCLK;
        o_BCLK <= r_BCLK;
        o_LRCLK <= r_LRCLK;
        
    end RTL;