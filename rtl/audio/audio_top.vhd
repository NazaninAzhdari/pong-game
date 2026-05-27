library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity audio_top is
    port (
        --inputs
        i_clk           :   in      STD_LOGIC;
		i_clk25		    :	in 		STD_LOGIC;
        i_reset         :   in      STD_LOGIC;
        i_beep_En       :   in      STD_LOGIC;
        i_start_En      :   in      STD_LOGIC;
        i_gameOver_En   :   in      STD_LOGIC;
        --outputs
        o_MCLK          :   out     STD_LOGIC;
        o_LRCLK         :   out     STD_LOGIC;
        o_BCLK          :   out     STD_LOGIC;
        o_DATA          :   out     STD_LOGIC
    );
end audio_top;

architecture RTL of audio_top is
    signal w_LRCLK          : STD_LOGIC  :='0';
    --Sample Signals
	signal r_sample             : unsigned(23 downto 0)  :=(others=>'0');
    signal w_beep_sample        : unsigned(23 downto 0)  :=(others=>'0');
	signal w_start_sample       : unsigned(23 downto 0)  :=(others=>'0');
	signal w_gameOver_sample    : unsigned(23 downto 0)  :=(others=>'0');
	
    --signals for handling the start melody
	signal r_start_en       :   STD_LOGIC  :='0';
	signal w_start_en       :   STD_LOGIC  :='0';
	constant c_START_LENGTH :   integer  :=70000000; --2.8 Seconds
	signal r_start_counter  :   integer range 0 to c_START_LENGTH :=0;
	
	--signals for handling the game over melody
	signal r_gameOver_en        :  STD_LOGIC  :='0';
	signal w_gameOver_en        :  STD_LOGIC  :='0';
	constant c_gameOver_LENGTH  :   integer  :=30000000; --1.2 Seconds
	signal r_gameOver_counter   :   integer range 0 to c_GAMEOVER_LENGTH :=0;
	
    begin 
        process(i_clk25) is
            begin 
                if rising_edge(i_clk25) then
                    --Manage the enable signal for starting melody
                    r_start_en <= i_start_en;
                    if i_start_en = '1' and r_start_en = '0' then
                        w_start_en <= '1';
                    end if;
                    
                    if w_start_en = '1' then
                        if r_start_counter < c_START_LENGTH then
                            r_start_counter <= r_start_counter + 1;
                        else
                            r_start_counter <= 0;
                            w_start_en <= '0';
                        end if;
                    end if;
                    
                    --Manage the enable signal for Game Over melody
                    r_gameOver_en <= i_gameOver_en;
                    if i_gameOver_en = '1' and r_gameOver_en = '0' then
                        w_gameOver_en <= '1';
                    end if;
                    
                    if w_gameOver_en = '1' then
                        if r_gameOver_counter < c_GAMEOVER_LENGTH then
                            r_gameOver_counter <= r_gameOver_counter + 1;
                        else
                            r_gameOver_counter <= 0;
                            w_gameOver_en <= '0';
                        end if;
                    end if; 
                end if;
            end process;
			
    
        beep_generator: entity work.beep_gen
        generic map(
            g_SAMPLE_WIDTH => 24,
            g_HALF_PERIOD_BEEP => 24 --1KHz frequency
        )
        port map(
            i_clk => i_clk, --50MHZ
            i_en  => i_beep_en,
            i_LRCLK => w_LRCLK,
            o_sample => w_beep_sample
        );

        start_melody_generator: entity work.start_melody_gen
        generic map(
            g_SAMPLE_WIDTH => 24
        )
        port map(
            i_clk=> i_clk,
            i_en=> w_start_En,
            i_LRCLK => w_LRCLK,
            o_sample => w_start_sample
        );

        gameOver_melody_generator: entity work.gameOver_melody_gen
        generic map(
            g_SAMPLE_WIDTH => 24
        )
        port map(
            i_clk=> i_clk,
            i_en=> w_gameOver_en,
            i_LRCLK => w_LRCLK,
            o_sample => w_gameOver_sample
        );
		  
        i2s_transmitter: entity work.i2s_tx
        generic map(
            g_SAMPLE_WIDTH => 24,
            g_HALF_PERIOD_MCLK => 2,  --12.5MHz 
            g_HALF_PERIOD_BCLK => 8   --3.1MHz
        )
        port map(
            i_clk => i_clk,
            i_reset => i_reset,
            i_sample => r_sample,
            o_BCLK => o_BCLK,
            o_LRCLK => w_LRCLK,
            o_MCLK => o_MCLK,
            o_DATA => o_DATA
        );

        r_sample <= w_beep_sample when i_beep_en = '1' else
							w_start_sample when i_start_en = '1' else
							w_gameOver_sample when i_gameOver_en = '1' else
							(others=>'0');

        o_LRCLK <= w_LRCLK;

    end RTL;