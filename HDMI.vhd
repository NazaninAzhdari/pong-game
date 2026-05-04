library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity HDMI is
    generic (
        VIDEO_WIDTH :   integer     :=8;
    )
    port (
        i_clk       :   in      STD_LOGIC;
        i_HS        :   in      STD_LOGIC;
        i_VS        :   in      STD_LOGIC;
        i_DE        :   in      STD_LOGIC;
        i_blue_VB   :   in      unsigned(VIDEO_WIDTH-1 downto 0);
        i_green_VB  :   in      unsigned(VIDEO_WIDTH-1 downto 0);
        i_red_VB    :   in      unsigned(VIDEO_WIDTH-1 downto 0);

        --output to hdmi
        o_hdmi_clk      :   out     STD_LOGIC; --25MHz
        o_hdmi_HS       :   out     STD_LOGIC;
        o_hdmi_VS       :   out     STD_LOGIC;
        o_hdmi_DE       :   out     STD_LOGIC;
        o_hdmi_DATA_BUS :   out     unsigned(23 downto 0)
    );
end HDMI;

architecture RTL of HDMI is
    begin
        o_hdmi_clk <= i_clk;
        o_hdmi_HS <= i_HS;
        o_hdmi_VS <= i_VS;
        o_hdmi_DE <= i_DE;
        o_hdmi_DATA_BUS <= i_blue_VB + i_green_VB + i_red_VB;
    end RTL;