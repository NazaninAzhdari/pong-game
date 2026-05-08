library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2s_tx is
    port (
        i_clk         :       in      STD_LOGIC;            --50 MHz 
        i_sample      :       in      unsigned(23 downto 0);
        o_XCLK        :       out     STD_LOGIC;            --12.5 MHz
        o_LRCLK       :       out     STD_LOGIC;            --48 KHz
        o_BCLK        :       out     STD_LOGIC;            --3.1 MHz = 48KHz * 2 * 32
        o_DATA        :       out     STD_LOGIC
    );
end i2s_tx;

architecture RTL of i2s_tx is
    --XCLK 
    constant    CLK_CYCLES_XCLK     :   integer     :=3;
    signal      r_XCLK              :   STD_LOGIC   :='0';

    --Bit CLK
    constant    CLC_CYCLES_BCLK     :   integer     :=9;
    signal      r_BCLK              :   STD_LOGIC   :='0';

    --LR clock
    signal      r_LRCLK             :   STD_LOGIC   :='1';

    signal      r_shift             :   unsigned(31 downto 0)   :=(others=>'0');
    signal      r_bit_counter       :   integer range 0 to 31   :=0;

    begin

        generating_master_clock_12MHz : entity work.freq_divider
        generic map(
            g_CLK_CYCLES => CLK_CYCLES_XCLK
        )
        port map (
            i_clk => i_clk,  --50 MHz 
            o_clk => r_XCLK  --12.5 MHz
        );

        generating_bit_clock_3MHz : entity work.freq_divider
        generic map(
            g_CLK_CYCLES => CLK_CYCLES_BCLK
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
                        r_shift <= i_sample & "00000000"  --24 bits of real data + 8 bits padding
                        r_bit_counter <= 0;
                        r_LRCLK <= not r_LRCLK;           --generating the LRCLK, toggles every 32 bits transfered
                    end if;
                end if;

            end process;

        o_XCLK <= r_XCLK;
        o_BCLK <= r_BCLK;
        o_LRCLK <= r_LRCLK;
        
    end RTL;