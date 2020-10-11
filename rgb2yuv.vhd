-- Rough RGB to YUV Conversion
-- Michael Moffitt 2015
-- mikejmoffitt.com
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rgb2yuv is
port (
	r: in std_logic_vector(9 downto 0);
	g: in std_logic_vector(9 downto 0);
	b: in std_logic_vector(9 downto 0);
	
	y: out std_logic_vector(9 downto 0);
	v: out std_logic_vector(9 downto 0); -- AKA Cb
	u: out std_logic_vector(9 downto 0); -- AKA Cr
	
	sw_en_n: in std_logic -- Active low
	
	);
	
end entity;

-- Solving for each component of the three channels:
-- =================================================

-- Yr: ("00" & r(7 downto 2)) + ("00000" & r(7 downto 5)) + ("000000" & r(7 downto 6)) -- 0.297 ~ 0.299
-- Yg: ('0' & g(7 downto 1)) + ("0000" & g(7 downto 4)) + ("000000" & g(7 downto 6)) -- 0.578 ~ 0.587
-- Yb: ("000" & b(7 downto 3)) -- 0.125 ~ 0.114

-- Pbr: - (("000" & r(7 downto 3)) + ("00000" & r(7 downto 5)) + ("0000000" & r(7))) -- 0.164 ~ 0.169
-- Pbg: - (("00" & g(7 downto 2)) + ("0000" & g(7 downto 4)) + ("00000" & g(7 downto 5))) -- 0.344 ~ 0.331
-- Pbb: ('0' & b(7 downto 1)) -- 0.5 ~ 0.5

-- Prr: ('0' & r(7 downto 1)) -- 0.5 ~ 0.5
-- Prg: - (("00" & g(7 downto 2)) + ("000" & g(7 downto 3)) + ("00000" & g(7 downto 5)) + ("000000" & g(7 downto 6))) -- 0.422 ~ 0.419
-- Prb: - (("0000" & b(7 downto 4)) + ("000000" & b(7 downto 6))) -- 0.078 ~ 0.081


architecture behavioral of rgb2yuv is
begin
	make_yuv: process(r, g, b, sw_en_n)
	begin
		if (sw_en_n = '0') then
			y <= ("00" & r(9 downto 2)) + ("00000" & r(9 downto 5)) + ("000000" & r(9 downto 6)) + ("0" & g(9 downto 1)) + ("0000" & g(9 downto 4)) + ("000000" & g(9 downto 6)) + ("000" & b(9 downto 3));
			u <= 512 + ("0" & r(9 downto 1)) - (("00" & g(9 downto 2)) + ("000" & g(9 downto 3)) + ("00000" & g(9 downto 5)) + ("000000" & g(9 downto 6)))- (("0000" & b(9 downto 4)) + ("000000" & b(9 downto 6)));
			v <= 512 + ("0" & b(9 downto 1))- (("00" & g(9 downto 2)) + ("0000" & g(9 downto 4)) + ("00000" & g(9 downto 5)))- (("000" & r(9 downto 3)) + ("00000" & r(9 downto 5)) + ("0000000" & r(9)));
		else
			u <= r;
			y <= g;
			v <= b;
		end if;
	end process;
end behavioral;
