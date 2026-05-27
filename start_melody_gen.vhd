library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity start_melody_gen is
    generic (
        g_SAMPLE_WIDTH      :   integer     :=24
    );
    port (
        i_clk       :   in      STD_LOGIC;
        i_en        :   in      STD_LOGIC;
        i_LRCLK     :   in      STD_LOGIC;
        o_sample    :   out     unsigned(g_sample_width-1 downto 0)
    );
end start_melody_gen;

architecture RTL of start_melody_gen is
    signal r_LRCLK        : std_logic := '0';
    signal r_freq_counter : integer  := 0;
    signal r_level        : std_logic := '0';
    signal r_sample       : signed(g_SAMPLE_WIDTH-1 downto 0) := (others => '0');

    signal tone_indx : integer range 0 to 5  :=0;
    type tone is array ( 0 to 5) of integer;
    constant half_period_tone : tone :=(
        0 => 40,
        1 => 30,
        2 => 24,
        3 => 20,
        4 => 16,
		5 => 16
    );
    constant c_DURATION_LIMIT  :  integer   :=24000;
    signal r_duration_counter : integer range 0 to c_DURATION_LIMIT := 0;

    constant AMP_POS : signed(g_SAMPLE_WIDTH-1 downto 0) := to_signed( 4000000, g_SAMPLE_WIDTH);
    constant AMP_NEG : signed(g_SAMPLE_WIDTH-1 downto 0) := to_signed(-4000000, g_SAMPLE_WIDTH);

    begin
        process(i_clk) is
            begin
                if rising_edge(i_clk) then
                    r_LRCLK <= i_LRCLK;

                    if i_LRCLK = '1' and r_LRCLK = '0' then --rising-edge of LRCLK
                        if i_en = '1' then

                            if r_freq_counter < half_period_tone(tone_indx)-1 then
                                r_freq_counter <= r_freq_counter + 1;
                            else
                                r_freq_counter <= 0;
                                r_level <= not r_level;
                            end if;


                            if r_duration_counter < c_DURATION_LIMIT then
                                r_duration_counter <= r_duration_counter + 1;
                            else
                                r_duration_counter <= 0;
                                
                                if tone_indx = 5 then
                                    tone_indx <= 0;
                                else
                                    tone_indx <= tone_indx + 1;
                                end if;
                            end if;


                            if r_level = '1' then
                                r_sample <= AMP_POS;
                            else
                                r_sample <= AMP_NEG;
                            end if;
                        else
									r_sample <= (others=>'0');
									r_freq_counter <= 0;
									r_duration_counter <= 0;
									tone_indx <= 0;
									r_level <='0';
                        end if;
                    end if;
                end if;

            end process;

            o_sample <= unsigned(STD_LOGIC_VECTOR(r_sample));
    end RTL;
