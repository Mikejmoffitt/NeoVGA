-- pixel.vhd
-- NeoVGA Rev 2
-- 2015 Michael Moffitt
-------------------------
-- Takes in the 17 bits of Neo-Geo pixel bus data, and returns 10 RGB bits.
-- This is where /SHAD and /DAK are processed.
--
-- As the Neo-Geo image data has 5 bits per channel, I am expanding it to 10
-- by concatenating the group of 5 bits with itself.
-- /DAK acts somewhat like a 6th bit, the true LSB. It is shared between all
-- channels, and is the 16th bit of a 15 bit palette entry on the Neo-Geo.
-- When /DAK goes high, it slightly darkens the color. The effect is very
-- subtle and can't really be properly captured with something so simple as
-- dividing the color value, so I have it configured to simply remove the
-- repeated five bits.
--
-- When /SHAD is high, the image is darkened. This is accomplished by shifting
-- each color to the right by one, dividing it in two.

library ieee;
use ieee.std_logic_1164.all;

entity pixel is 
port (
	neo_clk: in std_logic;
	neo_pixel_bus_in: in std_logic_vector(16 downto 0);
	red_out: out std_logic_vector(9 downto 0);
	green_out: out std_logic_vector(9 downto 0);
	blue_out: out std_logic_vector(9 downto 0)
);
end pixel;

architecture behavioral of pixel is

constant RED_POS: integer := 16;
constant GREEN_POS: integer := 11;
constant BLUE_POS: integer := 6;
constant DEPTH_BITS: integer := 5;
constant RED_END: integer := RED_POS - DEPTH_BITS + 1;
constant GREEN_END: integer := GREEN_POS - DEPTH_BITS + 1;
constant BLUE_END: integer := BLUE_POS - DEPTH_BITS + 1;

constant SHAD_POS: integer := 0;
constant DAK_POS: integer := 1;

begin
	shad_proc: process(neo_clk, neo_pixel_bus_in)
	begin
		if (rising_edge(neo_clk)) then
			if (neo_pixel_bus_in(SHAD_POS) = '0') then -- SHAD is strong darkening
				if (neo_pixel_bus_in(DAK_POS) = '0') then -- DAK is very weak darkening
					red_out <= neo_pixel_bus_in(RED_POS downto RED_END) & neo_pixel_bus_in(RED_POS downto RED_END);
					green_out <= neo_pixel_bus_in(GREEN_POS downto GREEN_END) & neo_pixel_bus_in(GREEN_POS downto GREEN_END);
					blue_out <= neo_pixel_bus_in(BLUE_POS downto BLUE_END) & neo_pixel_bus_in(BLUE_POS downto BLUE_END);
				else
					red_out <= neo_pixel_bus_in(RED_POS downto RED_END) & "00000";
					green_out <= neo_pixel_bus_in(GREEN_POS downto GREEN_END) & "00000";
					blue_out <= neo_pixel_bus_in(BLUE_POS downto BLUE_END) & "00000";
				end if;
			else
				if (neo_pixel_bus_in(DAK_POS) = '0') then
					red_out <= '0' & neo_pixel_bus_in(RED_POS downto RED_END) & neo_pixel_bus_in(RED_POS downto RED_END + 1);
					green_out <= '0' & neo_pixel_bus_in(GREEN_POS downto GREEN_END) & neo_pixel_bus_in(GREEN_POS downto GREEN_END + 1);
					blue_out <= '0' & neo_pixel_bus_in(BLUE_POS downto BLUE_END) & neo_pixel_bus_in(BLUE_POS downto BLUE_END + 1);
				else
					red_out <= '0' & neo_pixel_bus_in(RED_POS downto RED_END) & "0000";
					green_out <= '0' & neo_pixel_bus_in(GREEN_POS downto GREEN_END) & "0000";
					blue_out <= '0' & neo_pixel_bus_in(BLUE_POS downto BLUE_END) & "0000";
				end if;
			end if;
		end if;
	end process;
end behavioral;
