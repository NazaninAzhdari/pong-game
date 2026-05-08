library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity beep_gen is
    generic (
        g_CLK_CYCLES   :  integer   :=26          --determines the frequency of the tone, approximately 1KHz
    );
    port (
        i_rlclk     :   in  STD_LOGIC;              --sample rate or LR clock, 48 KHz
        i_en        :   in  STD_LOGIC;
        o_sample    :   out unsigned(23 downto 0)   --24 bit resolution
    );
end beep_gen;

architecture RTL of beep_gen is
    signal r_counter    :   integer range 0 to g_CLK_CYCLES -1   :=0;
    signal r_wave       :   STD_LOGIC       :='0';
    begin

        process(i_rlclk) is
            begin
                if rising_edge(i_rlclk) then
                    --start beep
                    if i_en = '1' then
                        --generating samples
                        if r_counter < g_CLK_CYCLES -1 then
                            r_counter <= r_counter + 1;
                        else
                            r_counter <= 0;
                            r_wave <= not r_wave;
                        end if;
                    else
                        r_counter <= 0;
                        r_wave <= '0';
                    end if;
                end if;
            end process;

        o_sample <= (others=>r_wave);   --2 possible sample xFFFFFF or x000000
                                        --if g_clk_CYCLES = 24 then ,first 24 samples of x000000 will be sent, then 24 samples of xFFFFFF will be sent
                                        --this 48 samples together generates a tone.
                                        --                                           __________________________________________
                                        --tone _____________________________________|
                                        --the fequency of clock is 48KHz, meaning that we have 48000 rising_edge in one sec. in each rising edge we are sending a sample
                                        --so in total, in one second we send 48000 samples.
                                        --24 first samples are x000000, the second 24 samples are xFFFFFF, total of 48 sample, a tone
                                        --in 48000 rising edge in one sec, we can send 1000 tone.
                                        --so the frequency of our tone is 1KHz.
                                        
    end RTL;