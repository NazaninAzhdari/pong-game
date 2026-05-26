library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity beep_gen is
    generic (
        g_SAMPLE_WIDTH      :   integer     :=24;
        g_HALF_PERIOD_BEEP  :   integer     :=24 --1KHz frequency
    );
    port (
        i_clk       :   in      STD_LOGIC;
        i_en        :   in      STD_LOGIC;
        i_LRCLK     :   in      STD_LOGIC;
        o_sample    :   out     unsigned(g_sample_width-1 downto 0)
    );
end beep_gen;

architecture RTL of beep_gen is
    signal r_LRCLK        : std_logic := '0';
    signal r_beep_counter : integer range 0 to g_HALF_PERIOD_BEEP-1 := 0;
    signal r_level        : std_logic := '0';
    signal r_sample       : signed(g_SAMPLE_WIDTH-1 downto 0) := (others => '0');

    constant AMP_POS : signed(g_SAMPLE_WIDTH-1 downto 0) := to_signed( 4000000, g_SAMPLE_WIDTH);
    constant AMP_NEG : signed(g_SAMPLE_WIDTH-1 downto 0) := to_signed(-4000000, g_SAMPLE_WIDTH);

begin
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            r_LRCLK <= i_LRCLK;

            -- detect LRCLK rising edge
            if i_LRCLK = '1' and r_LRCLK = '0' then

                if i_en = '1' then

                    -- increment counter
                    if r_beep_counter < g_HALF_PERIOD_BEEP-1 then
                        r_beep_counter <= r_beep_counter + 1;
                    else
                        r_beep_counter <= 0;
                        r_level <= not r_level;
                    end if;

                    -- output amplitude
                    if r_level = '1' then
                        r_sample <= AMP_POS;
                    else
                        r_sample <= AMP_NEG;
                    end if;

                else
                    r_sample <= (others => '0');
                    r_beep_counter <= 0;
                end if;

            end if;
        end if;
    end process;

    o_sample <= unsigned(STD_LOGIC_VECTOR(r_sample));

end RTL;

