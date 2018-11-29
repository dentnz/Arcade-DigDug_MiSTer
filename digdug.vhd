library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity digdug is
port(
	clock_18       : in std_logic;
	reset          : in std_logic;
	video_r        : out std_logic_vector(2 downto 0);
	video_g        : out std_logic_vector(2 downto 0);
	video_b        : out std_logic_vector(1 downto 0);
	video_csync    : out std_logic;
	video_ce       : out std_logic;
	hblank         : out std_logic;
	vblank         : out std_logic;
	video_hs       : out std_logic;
	video_vs       : out std_logic;

	audio          : out std_logic_vector(9 downto 0);

	b_test         : in std_logic;
	b_svce         : in std_logic;
	coin           : in std_logic;
	start1         : in std_logic;
	left1          : in std_logic;
	right1         : in std_logic;
	fire1          : in std_logic;
	start2         : in std_logic;
	left2          : in std_logic;
	right2         : in std_logic;
	fire2          : in std_logic;

	dn_addr        : in  std_logic_vector(15 downto 0);
	dn_data        : in  std_logic_vector(7 downto 0);
	dn_wr          : in  std_logic
);
end digdug;

architecture struct of digdug is

 signal reset_n: std_logic;
 signal clock_18n : std_logic;

 signal hcnt : std_logic_vector(8 downto 0);
 signal vcnt : std_logic_vector(8 downto 0);
 signal ena_vidgen      : std_logic;
 signal ena_snd_machine : std_logic;
 signal cpu1_ena        : std_logic;
 signal cpu2_ena        : std_logic;
 signal cpu3_ena        : std_logic;

 signal cpu1_addr   : std_logic_vector(15 downto 0);
 signal cpu1_di     : std_logic_vector( 7 downto 0);
 signal cpu1_do     : std_logic_vector( 7 downto 0);
 signal cpu1_wr_n   : std_logic;
 signal cpu1_mreq_n : std_logic;
 signal cpu1_irq_n  : std_logic;
 signal cpu1_nmi_n  : std_logic;
 signal cpu1_m1_n   : std_logic;

 signal cpu2_addr   : std_logic_vector(15 downto 0);
 signal cpu2_di     : std_logic_vector( 7 downto 0);
 signal cpu2_do     : std_logic_vector( 7 downto 0);
 signal cpu2_wr_n   : std_logic;
 signal cpu2_mreq_n : std_logic;
 signal cpu2_irq_n : std_logic;
 signal cpu2_m1_n   : std_logic;
 
 signal cpu3_addr   : std_logic_vector(15 downto 0);
 signal cpu3_di     : std_logic_vector( 7 downto 0);
 signal cpu3_do     : std_logic_vector( 7 downto 0);
 signal cpu3_wr_n   : std_logic;
 signal cpu3_mreq_n : std_logic;
 signal cpu3_nmi_n  : std_logic;
 signal cpu3_m1_n   : std_logic;

 signal bgtile_addr : std_logic_vector(15 downto 0);
 signal sprite_addr : std_logic_vector(15 downto 0);

 signal cpu1_rom_do : std_logic_vector( 7 downto 0);
 signal cpu2_rom_do : std_logic_vector( 7 downto 0);
 signal cpu3_rom_do : std_logic_vector( 7 downto 0);
 
 signal bgram_do    : std_logic_vector( 7 downto 0);
 signal bgram_we    : std_logic;
 signal wram1_do    : std_logic_vector( 7 downto 0);
 signal wram1_we    : std_logic;
 signal wram2_do    : std_logic_vector( 7 downto 0);
 signal wram2_we    : std_logic;
 signal wram3_do    : std_logic_vector( 7 downto 0);
 signal wram3_we    : std_logic;
 signal port_we     : std_logic;

 signal slot       : std_logic_vector(2 downto 0) := (others => '0');
 signal mux_addr   : std_logic_vector(15 downto 0);
 signal mux_cpu_do : std_logic_vector( 7 downto 0);
 signal mux_cpu_we : std_logic;
 signal mux_cpu_mreq : std_logic;
 signal latch_we   : std_logic;
 signal io_we      : std_logic;

 signal cs06XX_control : std_logic_vector( 7 downto 0);
 signal cs06XX_do      : std_logic_vector( 7 downto 0);
 signal cs06XX_di      : std_logic_vector( 7 downto 0);

 signal cs51XX_data_cnt           : std_logic_vector( 1 downto 0) := "00";
 signal cs51XX_coin_mode_cnt      : std_logic_vector( 2 downto 0) := "000";
 signal cs51XX_switch_mode        : std_logic := '0';
 signal cs51XX_credit_mode        : std_logic := '1';
 signal cs51XX_do                 : std_logic_vector( 7 downto 0);
 signal cs51XX_switch_mode_do     : std_logic_vector( 7 downto 0);
 signal cs51XX_non_switch_mode_do : std_logic_vector( 7 downto 0);
 signal change_next               : std_logic;
 signal credit_bcd_0              : std_logic_vector( 3 downto 0);
 signal credit_bcd_1              : std_logic_vector( 3 downto 0);
 
 signal cs54XX_do         : std_logic_vector( 7 downto 0);
 
 signal cs54xx_ena      : std_logic;
 signal cs54xx_ena_div  : std_logic_vector(2 downto 0) := "000";
 signal cs5Xxx_rw       : std_logic;
 
 signal cs54xx_rom_addr : std_logic_vector(10 downto 0); 
 signal cs54xx_rom_do   : std_logic_vector( 7 downto 0); 
 
 signal cs54xx_irq_n      : std_logic := '1'; 
 signal cs54xx_irq_cnt    : std_logic_vector( 3 downto 0); 
 signal cs54xx_k_port_in  : std_logic_vector( 3 downto 0); 
 signal cs54xx_r0_port_in : std_logic_vector( 3 downto 0); 
 signal cs54xx_audio_1    : std_logic_vector( 3 downto 0); 
 signal cs54xx_audio_2    : std_logic_vector( 3 downto 0); 
 signal cs54xx_audio_3    : std_logic_vector( 3 downto 0); 

 signal cs05XX_ctrl       : std_logic_vector( 5 downto 0);
 
 signal dip_switch_a  : std_logic_vector (7 downto 0);
 signal dip_switch_b  : std_logic_vector (7 downto 0);
 signal dip_switch_do : std_logic_vector (1 downto 0);
 
 signal bgtile_num     : std_logic_vector( 7 downto 0);
 signal bgtile_num_r   : std_logic_vector( 7 downto 0);
 signal bgtile_color   : std_logic_vector( 7 downto 0);
 signal bgtile_color_r : std_logic_vector( 7 downto 0);
 signal bggraphx_addr  : std_logic_vector(11 downto 0);
 signal bggraphx_do    : std_logic_vector( 7 downto 0);
 signal bgpalette_addr : std_logic_vector( 7 downto 0);
 signal bgpalette_do   : std_logic_vector( 7 downto 0); 
 signal bgbits         : std_logic_vector( 3 downto 0);

 signal rgb_palette_addr : std_logic_vector( 4 downto 0);
 signal rgb_palette_do   : std_logic_vector( 7 downto 0); 
 
 signal sprite_num     : std_logic_vector(5 downto 0);
 signal sprite_state   : std_logic_vector(2 downto 0); 
 signal sprite_line    : std_logic_vector(7 downto 0);
 signal sptile_num     : std_logic_vector(7 downto 0);
 signal sptile_color   : std_logic_vector(7 downto 0);
 signal spdata         : std_logic_vector(3 downto 0);
 signal spvcnt         : std_logic_vector(4 downto 0);
 signal sphcnt         : std_logic_vector(4 downto 0);
 signal spram_wr_addr  : std_logic_vector(8 downto 0);
 signal spram_rd_addr  : std_logic_vector(8 downto 0);
 signal spram_we       : std_logic;
 signal spram_clr      : std_logic;
 signal spgraphx_addr  : std_logic_vector(12 downto 0);
 signal spgraphx_do    : std_logic_vector(7 downto 0);
 signal sppalette_addr : std_logic_vector(7 downto 0);
 signal sppalette_do   : std_logic_vector(7 downto 0); 
 signal spbits_wr      : std_logic_vector(3 downto 0);
 signal spbits_rd      : std_logic_vector(3 downto 0);
 signal spflip_V ,spflip_H  : std_logic;
 signal spflip_2V,spflip_2H : std_logic_vector(1 downto 0);
 signal spflip_3V,spflip_3H : std_logic_vector(2 downto 0);
 signal spflips             : std_logic_vector(12 downto 0);

 signal flip_h         : std_logic; 
 
 signal spram1_addr    : std_logic_vector(8 downto 0);
 signal spram1_di      : std_logic_vector(3 downto 0);
 signal spram1_do      : std_logic_vector(3 downto 0);
 signal spram1_we      : std_logic;
 signal spram2_addr    : std_logic_vector(8 downto 0);
 signal spram2_di      : std_logic_vector(3 downto 0);
 signal spram2_do      : std_logic_vector(3 downto 0);
 signal spram2_we      : std_logic;

-- @dentnz - This is galaga's starfield stuff, which isn't required but maybe we leave it in? ;)
 signal stars_hcnt      : std_logic_vector( 8 downto 0);
 signal stars_vcnt      : std_logic_vector( 8 downto 0);
 signal stars_offset    : std_logic_vector( 7 downto 0); 
 signal stars_set0_addr : std_logic_vector( 6 downto 0);
 signal stars_set0_data : std_logic_vector(15 downto 0);
 signal star_color_set0 : std_logic_vector( 5 downto 0);
 signal stars_set1_addr : std_logic_vector( 6 downto 0);
 signal stars_set1_data : std_logic_vector(15 downto 0);
 signal star_color_set1 : std_logic_vector( 5 downto 0);
 signal stars_set2_addr : std_logic_vector( 6 downto 0);
 signal stars_set2_data : std_logic_vector(15 downto 0);
 signal star_color_set2 : std_logic_vector( 5 downto 0);
 signal stars_set3_addr : std_logic_vector( 6 downto 0);
 signal stars_set3_data : std_logic_vector(15 downto 0);
 signal star_color_set3 : std_logic_vector( 5 downto 0);
 signal star_color      : std_logic_vector( 5 downto 0);
 
 signal irq1_clr_n  : std_logic;
 signal irq2_clr_n  : std_logic;
 signal nmion_n     : std_logic;
 signal reset_cpu_n : std_logic;

 signal snd_ram_0_we : std_logic;
 signal snd_ram_1_we : std_logic;
 signal snd_audio    : std_logic_vector(9 downto 0);

 signal coin_r   : std_logic;
 signal start1_r : std_logic;
 signal start2_r : std_logic;
 
 signal fire1_r   : std_logic;
 signal fire2_r   : std_logic;
 signal fire1_mem : std_logic;
 signal fire2_mem : std_logic;

 signal rom1_cs   : std_logic;
 signal rom2_cs   : std_logic;
 signal rom3_cs   : std_logic;
 signal roms_cs   : std_logic;
 signal romb_cs   : std_logic;
 signal romm_cs   : std_logic;

begin

clock_18n <= not clock_18;
reset_n   <= not reset;

dip_switch_a <= "11110111"; --  cab:7 / na:6 / test:5 / freeze:4 / demo sound:3 / na:2 / difficulty:1-0
dip_switch_b <= "10010111"; --lives:7-6/ bonus:5-3 / coinage:2-0
dip_switch_do <= 	dip_switch_a(to_integer(unsigned(mux_addr(3 downto 0)))) & 
									dip_switch_b(to_integer(unsigned(mux_addr(3 downto 0))));

audio <= ("00" & cs54xx_audio_1 &  "0000" ) + ("00" & cs54xx_audio_2 &  "0000" )+ ('0'&snd_audio(9 downto 1));

-- make access slots from 18MHz
-- 6MHz for pixel clock and sound machine
-- 3MHz for cpu, background and sprite machine

--       slots  |   0  |   1  |   2  |    3   |   4   |   5   |
-- wram  access | cpu1 | cpu2 | cpu3 | bgram  | spram | n.u.  | 
-- sound access | cpu1 | cpu2 | cpu3 | sndram | n.u.  | sndram| 

-- enable signals are one slot early

process (clock_18)
begin
 if rising_edge(clock_18) then
  ena_vidgen      <= '0';
	ena_snd_machine <= '0';
  cpu1_ena   <= '0';
  cpu2_ena   <= '0';
  cpu3_ena   <= '0';
  cs54xx_ena <= '0';
	
  if slot = "101" then
   slot <= (others => '0');
	cs54xx_ena_div <= cs54xx_ena_div +'1';
	else
		slot <= std_logic_vector(unsigned(slot) + 1);
  end if;   
	
	if slot = "101" or slot = "010" then ena_vidgen      <= '1';	end if;	
	if slot = "010" or slot = "100" then ena_snd_machine <= '1';	end if;	
	if slot = "101" then cpu1_ena <= '1';	end if;
	if slot = "000" then cpu2_ena <= '1';	end if;	
	if slot = "001" then cpu3_ena <= '1';	end if;
	
	if slot = "000" and cs54xx_ena_div = "000" then cs54xx_ena <= '1'; end if;
		
 end if;
end process;

video_ce <= '1' when slot = "011" or slot = "000" else '0';

--- SPRITES MACHINE ---
-----------------------
	
-- 0x8B80 - 0x8BFF : 64 sprites tile num, tile color
-- 0x9380 - 0x93FF : 64 sprites pos v, pos h lsb
-- 0x9B80 - 0x9BFF : 64 sprites 2xH, 2xV, flip H, flip V

-- @dentnz - DigDug only has 32 sprites. Mame sprite register map:
-- map(0x8800, 0x8bff).ram().share("digdug_objram");   /* work RAM + sprite registers */
-- map(0x9000, 0x93ff).ram().share("digdug_posram");   /* work RAM + sprite registers */
-- map(0x9800, 0x9bff).ram().share("digdug_flpram");   /* work RAM + sprite registers */

-- @dentnz - I guess this is mapping sprite number to memory address, but maybe only for active sprites? 
sprite_addr <= X"03"&'1' & sprite_num & sprite_state(0);
sprite_line <= wram2_do + vcnt(7 downto 0);

process (clock_18, slot)
begin
 if rising_edge(clock_18) then 
	if hcnt = std_logic_vector(to_unsigned(191,9)) then
		sprite_num   <= "000000";
		sprite_state <= "000";
		spram_rd_addr<= "111101111";
	end if;
	
	if slot = "100" and sprite_state = "000" then
		sptile_num   <= wram1_do;
		spdata       <= wram3_do(3 downto 0);
		spvcnt       <= sprite_line(4 downto 0);
		if  sprite_line(7 downto 4) = "1111" or 											-- size V x 1
		   (sprite_line(7 downto 5) = "111" and wram3_do(3)='1' )then -- size V x 2 -- fixed Dar : 04/11/2017
			sprite_state <= "001";
		else
			if sprite_num = "111111" then
				sprite_state <= "111";
			else
				sprite_num <= sprite_num + "000001";			
				sprite_state <= "000";
			end if;		
		end if;	
	end if;
	
	if slot = "100" and sprite_state = "001" then
		sptile_color  <= wram1_do;
		spram_wr_addr <= wram3_do(0) & wram2_do;
		sphcnt        <= "00000";
		sprite_state  <= "010";
	end if;

	if sprite_state = "010" then
		sphcnt <= sphcnt + "00001";
		sprite_state  <= "011";
	end if; 

	if sprite_state = "011" then
		sphcnt <= sphcnt + "00001";
		spram_wr_addr <= spram_wr_addr + "000000001";
		if 	(sphcnt = "01111" and spdata(2) = '0' ) or   -- size H x 1  -- fixed Dar : 04/11/2017
				(sphcnt = "11111" and spdata(2) = '1' ) then -- size H x 2  -- fixed Dar : 04/11/2017 
			if sprite_num = "111111" then
				sprite_state <= "111";
			else
				sprite_num <= sprite_num + "000001";			
				sprite_state <= "000";
			end if;		
		end if;
	end if; 
	
	if slot = "000" or slot = "011" then
		if vcnt(0) = '1' then
			spbits_rd <= spram2_do;
		else
			spbits_rd <= spram1_do;
		end if;
	end if;
	
	spram_clr <= '0';
	if slot = "001" or slot = "100" then
		spram_clr <= '1';
	end if;
	
	if slot = "010" or slot = "101" then
		spram_rd_addr <= spram_rd_addr + "000000001";
	end if;

 end if;
end process;

spram_we <= '1' when sprite_state = "011" and spbits_wr /= "1111" else '0';

spram1_addr <= spram_wr_addr when vcnt(0) = '1' else spram_rd_addr;
spram2_addr <= spram_wr_addr when vcnt(0) = '0' else spram_rd_addr;

spram1_di  <= spbits_wr when vcnt(0) = '1' else "1111";
spram2_di  <= spbits_wr when vcnt(0) = '0' else "1111";
 
spram1_we <= spram_we when vcnt(0) = '1' else spram_clr;
spram2_we <= spram_we when vcnt(0) = '0' else spram_clr; 

spflip_H <= spdata(0) xor flip_h; spflip_2H <= spflip_H & spflip_H;
spflip_V <= spdata(1); spflip_2V <= spflip_V & spflip_V;

with spdata(3 downto 2) select
spflips <= 	"0000000"                       & spflip_V & spflip_2H & spflip_V & spflip_2V when "00",
						"000000"  &            spflip_H & spflip_V & spflip_2H & spflip_V & spflip_2V when "01",
						"00000"   & spflip_V & '0'      & spflip_V & spflip_2H & spflip_V & spflip_2V when "10",
						"00000"   & spflip_V & spflip_H & spflip_V & spflip_2H & spflip_V & spflip_2V when others;

with spdata(3 downto 2) select
spgraphx_addr <=  (sptile_num(6 downto 0)                             & spvcnt(3) & sphcnt(3 downto 2) & spvcnt(2 downto 0) ) xor spflips when "00",
									(sptile_num(6 downto 1) & 						sphcnt(4)     & spvcnt(3) & sphcnt(3 downto 2) & spvcnt(2 downto 0) ) xor spflips when "01",
									(sptile_num(6 downto 2) & spvcnt(4) & sptile_num(0) & spvcnt(3) & sphcnt(3 downto 2) & spvcnt(2 downto 0) ) xor spflips when "10",
									(sptile_num(6 downto 2) & spvcnt(4) & sphcnt(4)     & spvcnt(3) & sphcnt(3 downto 2) & spvcnt(2 downto 0) ) xor spflips when others;

sppalette_addr <= sptile_color(5 downto 0) &
									spgraphx_do(to_integer(unsigned('1' & ((not sphcnt(1 downto 0)) xor spflip_2H )))) &
									spgraphx_do(to_integer(unsigned('0' & ((not sphcnt(1 downto 0)) xor spflip_2H )))); 

spbits_wr <= 	sppalette_do(3 downto 0);

--- BACKGROUND TILES MACHINE ---
-----------------------_--------
	
-- 0x8000-0x83FF : tile num
-- 0x8400-0x87FF : tile color

bgtile_addr <= 	"10000" & hcnt(1) & vcnt(7 downto 3) & hcnt(7 downto 3)                                when (hcnt(8)='1' and flip_h='0') else
								"10000" & hcnt(1) & hcnt(4) & hcnt(4) & hcnt(4) & hcnt(4) & hcnt(3) & vcnt(7 downto 3) when (hcnt(8)='0' and flip_h='0') else
								"10000" & hcnt(1) & not( vcnt(7 downto 3) & hcnt(7 downto 3))                          when (hcnt(8)='1' and flip_h='1') else
								"10000" & hcnt(1) & not( hcnt(4) & hcnt(4) & hcnt(4) & hcnt(4) & hcnt(3) & vcnt(7 downto 3));
								

-- Attention : slot et hcnt ne sont pas entierement synchronisés
-- slot  |0 |1 | 2 |3 |4 |5 | ...
-- hcnt  | 0 or 1  | 1 or 2 | ...

process (clock_18, slot)
begin
 if rising_edge(clock_18) then 
		if slot = "011" and hcnt(2 downto 1) = "00" then
			bgtile_num <= bgram_do;
		end if;
		if slot = "011" and hcnt(2 downto 1) = "01" then
			bgtile_color <= bgram_do;
		end if;
		if (slot = "000" or slot = "011") and hcnt(2 downto 0) = "111" then
			bgtile_num_r <= bgtile_num;
			bgtile_color_r <= bgtile_color;
		end if;
 end if;
end process;

bggraphx_addr <= 	'1' & bgtile_num_r(6 downto 0) & not hcnt(2) &     vcnt(2 downto 0) when flip_h='0' else
									'1' & bgtile_num_r(6 downto 0) &     hcnt(2) & not vcnt(2 downto 0);

bgpalette_addr <= bgtile_color_r(5 downto 0) &
									bggraphx_do(to_integer(unsigned('1' & (hcnt(1 downto 0)) xor (flip_h & flip_h)))) &
									bggraphx_do(to_integer(unsigned('0' & (hcnt(1 downto 0)) xor (flip_h & flip_h)))); 

bgbits <= bgpalette_do(3 downto 0);

--- STARS MACHINE --- 
---------------------

stars_data : entity work.stars
port map(
	clk       => clock_18n,
	addr_set0 => stars_set0_addr,
	data_set0 => stars_set0_data,
	addr_set1 => stars_set1_addr,
	data_set1 => stars_set1_data,
	addr_set2 => stars_set2_addr,
	data_set2 => stars_set2_data,
	addr_set3 => stars_set3_addr,
	data_set3 => stars_set3_data
);

stars_machine_0 : entity work.stars_machine
port  map(
	clk              => clock_18,
	ena_hcnt         => ena_vidgen,
	hcnt             => stars_hcnt,
	vcnt             => stars_vcnt,
	stars_set_addr_o => stars_set0_addr,
  stars_set_data   => stars_set0_data,
  offset_y         => stars_offset,
  star_color       => star_color_set0
);

stars_machine_1 : entity work.stars_machine
port  map(
	clk              => clock_18,
	ena_hcnt         => ena_vidgen,
	hcnt             => stars_hcnt,
	vcnt             => stars_vcnt,
	stars_set_addr_o => stars_set1_addr,
  stars_set_data   => stars_set1_data,
  offset_y         => stars_offset,
  star_color       => star_color_set1
);

stars_machine_2 : entity work.stars_machine
port  map(
	clk              => clock_18,
	ena_hcnt         => ena_vidgen,
	hcnt             => stars_hcnt,
	vcnt             => stars_vcnt,
	stars_set_addr_o => stars_set2_addr,
  stars_set_data   => stars_set2_data,
  offset_y         => stars_offset,
  star_color       => star_color_set2
);

stars_machine_3 : entity work.stars_machine
port  map(
	clk              => clock_18,
	ena_hcnt         => ena_vidgen,
	hcnt             => stars_hcnt,
	vcnt             => stars_vcnt,
	stars_set_addr_o => stars_set3_addr,
  stars_set_data   => stars_set3_data,
  offset_y         => stars_offset,
  star_color       => star_color_set3
);

process (clock_18)
	subtype speed is integer range -3 to 3;
	type speed_array is array(0 to 7) of speed; 
	variable speeds : speed_array := ( -1, -2, -3, 0, 3, 2, 1, 0 ); 
begin
 if rising_edge(clock_18) then 

	if ena_vidgen = '1' then
		if hcnt = std_logic_vector(to_unsigned(256+8,9)) then
			stars_hcnt <= "000000000";
			stars_vcnt <= stars_vcnt + "000000001";
			if vcnt = std_logic_vector(to_unsigned(128+6,9)) then
				stars_vcnt <= "000000000";
				stars_offset <= stars_offset + 
					std_logic_vector(to_signed(speeds(to_integer(unsigned(cs05XX_ctrl(2 downto 0)))),8));
			end if;
		else
			stars_hcnt <= stars_hcnt + "000000001";
		end if;	
	end if; 
	
	star_color <= "000000";
	if cs05XX_ctrl(5) = '1' then
		if cs05XX_ctrl(4 downto 3) = "00" then star_color <= star_color_set0 or star_color_set2; end if;
		if cs05XX_ctrl(4 downto 3) = "01" then star_color <= star_color_set1 or star_color_set2; end if;
		if cs05XX_ctrl(4 downto 3) = "10" then star_color <= star_color_set0 or star_color_set3; end if;
		if cs05XX_ctrl(4 downto 3) = "11" then star_color <= star_color_set1 or star_color_set3; end if;
	end if;

 end if;
end process; 
	
--- VIDEO MUX ---
-----------------

rgb_palette_addr <= ('0' & spbits_rd) when bgbits = "1111" else ('1' & bgbits);

process (clock_18, rgb_palette_addr)
begin
 if rising_edge(clock_18)then
  if rgb_palette_addr(3 downto 0) = "1111" then
		video_r <= star_color(1 downto 0) & "0";
		video_g <= star_color(3 downto 2) & "0";
		video_b <= star_color(5 downto 4);		
	else
		video_r <= rgb_palette_do(2 downto 0);
		video_g <= rgb_palette_do(5 downto 3);
		video_b <= rgb_palette_do(7 downto 6);	
	end if;
 end if;
end process;


--- SOUND MACHINE ---
---------------------

sound_machine : entity work.sound_machine
port map(
clock_18  => clock_18,
ena       => ena_snd_machine,
hcnt      => hcnt(5 downto 0),
cpu_addr  => mux_addr(3 downto 0), 
cpu_do    => mux_cpu_do(3 downto 0), 
ram_0_we  => snd_ram_0_we,
ram_1_we  => snd_ram_1_we,
audio     => snd_audio
);

--- CPUS -------------
----------------------

with slot select
mux_addr <= 	cpu1_addr   when "000",
							cpu2_addr   when "001",
							cpu3_addr   when "010",
							bgtile_addr when "011",
							sprite_addr when "100",
							X"5555"     when others;

with slot select
mux_cpu_do <= 	cpu1_do when "000",
								cpu2_do when "001",
								cpu3_do when "010",
								X"00"   when others;

mux_cpu_we <= 	(not cpu1_wr_n and cpu1_ena)or
								(not cpu2_wr_n and cpu2_ena)or
								(not cpu3_wr_n and cpu3_ena);

mux_cpu_mreq <= 	(not cpu1_mreq_n and cpu1_ena) or
									(not cpu2_mreq_n and cpu2_ena) or
									(not cpu3_mreq_n and cpu3_ena);
									
latch_we <= '1' when mux_cpu_we = '1' and mux_addr(15 downto 11) = "01101" else '0';
io_we    <= '1' when mux_cpu_we = '1' and mux_addr(15 downto 11) = "01110" else '0';
bgram_we <= '1' when mux_cpu_we = '1' and mux_addr(15 downto 11) = "10000" else '0';
wram1_we <= '1' when mux_cpu_we = '1' and mux_addr(15 downto 11) = "10001" else '0';
wram2_we <= '1' when mux_cpu_we = '1' and mux_addr(15 downto 11) = "10010" else '0';
wram3_we <= '1' when mux_cpu_we = '1' and mux_addr(15 downto 11) = "10011" else '0';
port_we  <= '1' when mux_cpu_we = '1' and mux_addr(15 downto 11) = "10100" else '0';

snd_ram_0_we <= '1' when mux_cpu_we = '1' and mux_addr(15 downto 11) = "01101"  and mux_addr(5 downto 4) = "00" else '0';
snd_ram_1_we <= '1' when mux_cpu_we = '1' and mux_addr(15 downto 11) = "01101"  and mux_addr(5 downto 4) = "01" else '0';

process (reset, clock_18n, io_we) 
	variable cs06XX_nmi_cnt : natural range 0 to 1000;
begin
 if reset='1' then
			irq1_clr_n  <= '0';
			irq2_clr_n  <= '0';
			nmion_n     <= '0';
			reset_cpu_n <= '0';
			cpu1_irq_n  <= '1';
			cpu2_irq_n  <= '1';
			cs51XX_coin_mode_cnt <= "000";
			cs51XX_data_cnt <= "00";
			cs51XX_switch_mode <= '0';
			cs51XX_credit_mode <= '1';
			cs05XX_ctrl <= "000000";
			flip_h <= '0';
			cs54xx_irq_n <= '1';
			cs54xx_irq_cnt <= X"0";
			
 else 
  if rising_edge(clock_18n) then 
		if latch_we ='1' and mux_addr(5 downto 4) = "10" then 
			if mux_addr(2 downto 0) = "000" then irq1_clr_n  <= mux_cpu_do(0); end if;
			if mux_addr(2 downto 0) = "001" then irq2_clr_n  <= mux_cpu_do(0); end if;
			if mux_addr(2 downto 0) = "010" then nmion_n     <= mux_cpu_do(0); end if;
			if mux_addr(2 downto 0) = "011" then reset_cpu_n <= mux_cpu_do(0); end if;
		end if;
		
		if port_we ='1' then 
			if mux_addr(2 downto 0) < "110" then cs05XX_ctrl(to_integer(unsigned(mux_addr(2 downto 0)))) <= mux_cpu_do(0); end if;
			if mux_addr(2 downto 0) = "111" then flip_h <= mux_cpu_do(0); end if;
		end if;

		if irq1_clr_n = '0' then 
		  cpu1_irq_n <= '1';
		elsif vcnt = std_logic_vector(to_unsigned(240,9)) then cpu1_irq_n <= '0';
 		end if;
		if irq2_clr_n = '0' then 
		  cpu2_irq_n <= '1';
		elsif vcnt = std_logic_vector(to_unsigned(240,9)) then cpu2_irq_n <= '0';
		end if;
		
		if cs54xx_irq_cnt = X"0" then 
		  cs54xx_irq_n <= '1';
		else 
			if cs54xx_ena = '1' then
				cs54xx_irq_cnt <= cs54xx_irq_cnt - '1';
			end if;
		end if;
		
		-- write to cs06XX
		if io_we = '1' then 
			-- write to data register (0x7000)
		  if mux_addr(8) = '0' then
				-- @dentnz cs54xx is used for sound effects... we could probably ignore this or create our cs53XX I/O
				-- write data to device#4 (cs54XX)
				if cs06XX_control(3 downto 0) = "1000" then
						-- write data for k and r#0 port and launch irq to advice cs50xx
						cs54xx_k_port_in <= mux_cpu_do(7 downto 4);
						cs54xx_r0_port_in <= mux_cpu_do(3 downto 0);
						cs54xx_irq_n <= '0';
						cs54xx_irq_cnt <= X"7";						
				end if;		  
				-- write data to device#1 (cs51XX)
				if cs06XX_control(3 downto 0) = "0001" then
					-- when not in coin mode
					if cs51XX_coin_mode_cnt = "000" then
						-- if data = 1 enter coin mode for next 4 write operations
						if mux_cpu_do(2 downto 0) = "001" then
							cs51XX_coin_mode_cnt <= "100";
						end if;
						-- if data = 2 enter credit mode
						if mux_cpu_do(2 downto 0) = "010" then
							cs51XX_switch_mode <= '0';
							cs51XX_credit_mode <= '1';
							cs51XX_data_cnt <= "00";
						end if;
						-- if data = 5 enter switch mode 
						if mux_cpu_do(2 downto 0) = "101" then
							cs51XX_switch_mode <= '1';
							cs51XX_credit_mode <= '0';
							cs51XX_data_cnt <= "00";
						end if;
					-- when in coin mode	
					else
						-- written coin/credit data are ignored atm 
						-- only count down to exit coin_mode (request 4 write operations)
						cs51XX_coin_mode_cnt <= cs51XX_coin_mode_cnt - "001";
					end if;	
				end if;
			end if;
			
			-- write to control register (0x7100) 
			if mux_addr(8) = '1' then
				cs06XX_control <= mux_cpu_do;
			  -- start/stop nmi timer
				if mux_cpu_do(3 downto 0) = "0000" then
					cs06XX_nmi_cnt := 0;
					cpu1_nmi_n <= '1';
				else
					cs06XX_nmi_cnt := 1;
				end if;
			end if;
		end if;	
		
		-- generate periodic nmi when timer is on
		if cs06XX_nmi_cnt >= 1 then
			if cpu1_ena = '1' then  -- to get 333ns tick
				-- 600 * 333ns = 200µs
				if cs06XX_nmi_cnt < 600 then  
					cs06XX_nmi_cnt := cs06XX_nmi_cnt + 1;
					cpu1_nmi_n <= '1';
				else
					cs06XX_nmi_cnt := 1;
					cpu1_nmi_n <= '0';
				end if;	
			end if;
		end if;
		
		-- manage cs06XX data read
		change_next <= '0';
		if mux_cpu_mreq = '1' and mux_cpu_we ='0' and mux_addr(15 downto 11) = "01110" then
			if mux_addr(8) = '0' then
				change_next <= '1';
			end if;
		end if ;
		-- cycle data_cnt at each read and clear firex_mem in switch mode
		if change_next = '1' then
			if cs06XX_control(3 downto 0) = "0001" then
				if cs51XX_data_cnt = "10" then cs51XX_data_cnt <= "00"; 
				else cs51XX_data_cnt <= cs51XX_data_cnt + "01"; end if;
				
				if cs51XX_data_cnt = "10" then 
					fire1_mem <= '0';
					fire2_mem <= '0';
				end if;
				
			end if;				
		end if;
		-- manage fire button rising edge detection
		fire1_r <= fire1;
		fire2_r <= fire2;
		if fire1_r ='0' and fire1 ='1' then fire1_mem <= '1'; end if;
		if fire2_r ='0' and fire2 ='1' then fire2_mem <= '1'; end if;
		
		-- manage credit count (bcd)
		--   increase at each coin up to 99
		coin_r <= coin;
		start1_r <= start1;
		start2_r <= start2;
		if coin = '1' and coin_r = '0' then 
			if credit_bcd_0 = "1001" then 
				if credit_bcd_1 /= "1001" then
					credit_bcd_1 <= credit_bcd_1 + "0001";
					credit_bcd_0 <= "0000";
				end if;
			else
				credit_bcd_0 <= credit_bcd_0 + "0001";
			end if; 
		end if;
		
	  --   decrease only when in credit mode
		if cs51XX_credit_mode = '1' then
			if (start1 = '1' and start1_r = '0') then
				if credit_bcd_0 = "0000" then 
					if credit_bcd_1 /= "0000" then
						credit_bcd_1 <= credit_bcd_1 - "0001";
						credit_bcd_0 <= "1001";
					end if;
				else
					credit_bcd_0 <= credit_bcd_0 - "0001";
				end if; 		
			end if;
			
			if (start2 = '1' and start2_r = '0') then
				if credit_bcd_0 = "0000" or credit_bcd_0 = "0001" then
 					if credit_bcd_1 /= "0000" then
						credit_bcd_1 <= credit_bcd_1 - "0001";
						if credit_bcd_0 = "0000" then 
							credit_bcd_0 <= "1000";
						else
							credit_bcd_0 <= "1001";
						end if;
					end if;
				else
					credit_bcd_0 <= credit_bcd_0 - "0010";					
				end if;
			end if;
		end if;
		
  end if;
 end if;
end process;

with cs51XX_data_cnt select
cs51XX_switch_mode_do <= 	not (left2 & '0' & right2 & '0' & left1 & '0' & right1 & '0' )       when "00",
									not (b_test & b_svce & '0' & coin & start2 & start1 & fire2_mem & fire1_mem) when "01",
									X"00" when others;	

with cs51XX_data_cnt select
cs51XX_non_switch_mode_do <= 	credit_bcd_1 & credit_bcd_0 when "00", -- credits (cpu spy this)
										not ("110" & fire1_mem & left1 & '0' & right1 & '0' ) when "01",
										not ("110" & fire2_mem & left2 & '0' & right2 & '0' ) when "10",
										X"00" when "11"; -- N.U.	

cs51XX_do <= cs51XX_switch_mode_do when cs51XX_switch_mode = '1' else cs51XX_non_switch_mode_do;

cs54XX_do <= X"FF"; -- no data from CS54XX

with cs06XX_control(3 downto 0) select
cs06XX_di <= cs51XX_do when "0001",
						 cs54XX_do when "1000",
						 X"00" when others;

cs06XX_do <= cs06XX_di when mux_addr(8)= '0' else cs06XX_control;

process (clock_18, nmion_n)
begin
 if nmion_n = '1' then
 elsif rising_edge(clock_18) and ena_vidgen = '1' then
		if hcnt = "100000000" then
			if vcnt = "001000000" or vcnt = "011000000" then cpu3_nmi_n <= '0'; end if;
			if vcnt = "001000001" or vcnt = "011000001" then cpu3_nmi_n <= '1'; end if;
		end if;
 end if;
end process;

-- @dentnz - what is this doing?
with cpu1_addr(15 downto 11) select
cpu1_di <= 	cpu1_rom_do when "00000",
						cpu1_rom_do when "00001",
						cpu1_rom_do when "00010",
						cpu1_rom_do when "00011",
						cpu1_rom_do when "00100",
						cpu1_rom_do when "00101",
						cpu1_rom_do when "00110",
 						cpu1_rom_do when "00111",
						"000000" & dip_switch_do when "01101",
						cs06XX_do   when "01110",
						bgram_do    when "10000",
						wram1_do    when "10001",
						wram2_do    when "10010",
						wram3_do    when "10011",
						X"00"       when others;

with cpu2_addr(15 downto 11) select
cpu2_di <= 	cpu2_rom_do when "00000",
						cpu2_rom_do when "00001",
						"000000" & dip_switch_do when "01101",
						cs06XX_do   when "01110",
						bgram_do    when "10000",
						wram1_do    when "10001",
						wram2_do    when "10010",
						wram3_do    when "10011",
						X"00"       when others;

with cpu3_addr(15 downto 11) select
cpu3_di <= 	cpu3_rom_do when "00000",
						cpu3_rom_do when "00001",
						"000000" & dip_switch_do when "01101",
						cs06XX_do   when "01110",
						bgram_do    when "10000",
						wram1_do    when "10001",
						wram2_do    when "10010",
						wram3_do    when "10011",
						X"00"       when others;

-- video address/sync generator
gen_video : entity work.gen_video
port map(
clk     => clock_18,
enable  => ena_vidgen,
hcnt    => hcnt,
vcnt    => vcnt,
hsync   => video_hs,
vsync   => video_vs,
csync   => video_csync,
hblank  => hblank,
vblank  => vblank
);

-- microprocessor Z80 - 1
cpu1 : entity work.T80se
generic map(Mode => 0, T2Write => 1, IOWait => 1)
port map(
  RESET_n => reset_n,
  CLK_n   => clock_18,
	CLKEN   => cpu1_ena,
  WAIT_n  => '1',
  INT_n   => cpu1_irq_n,
  NMI_n   => cpu1_nmi_n,
  BUSRQ_n => '1',
  M1_n    => cpu1_m1_n,
  MREQ_n  => cpu1_mreq_n,
  IORQ_n  => open,
  RD_n    => open,
  WR_n    => cpu1_wr_n,
  RFSH_n  => open,
  HALT_n  => open,
  BUSAK_n => open,
  A       => cpu1_addr,
  DI      => cpu1_di,
  DO      => cpu1_do
);

-- microprocessor Z80 - 2
cpu2 : entity work.T80se
generic map(Mode => 0, T2Write => 1, IOWait => 1)
port map(
--  RESET_n => reset_n,
  RESET_n => reset_cpu_n,
  CLK_n   => clock_18,
	CLKEN   => cpu2_ena,
  WAIT_n  => '1',
  INT_n   => cpu2_irq_n,
  NMI_n   => '1', --cpu_int_n,
  BUSRQ_n => '1',
  M1_n    => cpu2_m1_n,
  MREQ_n  => cpu2_mreq_n,
  IORQ_n  => open,
  RD_n    => open,
  WR_n    => cpu2_wr_n,
  RFSH_n  => open,
  HALT_n  => open,
  BUSAK_n => open,
  A       => cpu2_addr,
  DI      => cpu2_di,
  DO      => cpu2_do
);

-- microprocessor Z80 - 3
cpu3 : entity work.T80se
generic map(Mode => 0, T2Write => 1, IOWait => 1)
port map(
--  RESET_n => reset_n,
  RESET_n => reset_cpu_n,
  CLK_n   => clock_18,
	CLKEN   => cpu3_ena,
  WAIT_n  => '1',
  INT_n   => '1',
  NMI_n   => cpu3_nmi_n,
  BUSRQ_n => '1',
  M1_n    => cpu3_m1_n,
  MREQ_n  => cpu3_mreq_n,
  IORQ_n  => open,
  RD_n    => open,
  WR_n    => cpu3_wr_n,
  RFSH_n  => open,
  HALT_n  => open,
  BUSAK_n => open,
  A       => cpu3_addr,
  DI      => cpu3_di,
  DO      => cpu3_do
);

-- mb88 - cs54xx (28 pins IC, 1024 bytes rom)
mb88_54xx : entity work.mb88
port map(
 reset_n    => reset_cpu_n, --reset_n,
 clock      => clock_18,
 ena        => cs54xx_ena,

 r0_port_in  => cs54xx_r0_port_in, -- pin 12,13,15,16
 r1_port_in  => X"0",
 r2_port_in  => X"0",
 r3_port_in  => X"0",
 r0_port_out => open,
 r1_port_out => cs54xx_audio_3,   -- pin 17,18,19,20 (resistor divider )
 r2_port_out => open,
 r3_port_out => open,
 k_port_in   => cs54xx_k_port_in, -- pin 24,25,26,27
 ol_port_out => cs54xx_audio_1,   -- pin  4, 5, 6, 7 (resistor divider 150K/22K)
 oh_port_out => cs54xx_audio_2,   -- pin  8, 9,10,11 (resistor divider  47K/10K)
 p_port_out  => open,

 stby_n    => '0',
 tc_n      => '0',
 irq_n     => cs54xx_irq_n,
 sc_in_n   => '0',
 si_n      => '0',
 sc_out_n  => open,
 so_n      => open,
 to_n      => open,
 
 rom_addr  => cs54xx_rom_addr,
 rom_data  => cs54xx_rom_do
);

-- @dentnz - Load ROM into the DigDug Memory Map

-- cs54xx program ROM
-- @dentnz - we probably don't need to program this custom chip with code... Remove it later
-- @dentnz - need to work out what we do with romm_cs
cs54xx_prog : work.dpram generic map (10,8)
port map
(
	clock_a   => clock_18,
	wren_a    => dn_wr and romm_cs,
	address_a => dn_addr(9 downto 0),
	data_a    => dn_data,

	clock_b   => clock_18n,
	address_b => cs54xx_rom_addr(9 downto 0),
	q_b       => cs54xx_rom_do
);

-- @dentnz - this bit is mapping the rom sent across from MiSTer for the three Z80 CPUs

-- MAIN CPU:
-- Address          Dir Data     Name      Description
---------------- --- -------- --------- ------------------------
-- 0000xxxxxxxxxxxx R   xxxxxxxx ROM 0     program ROM    0x0000
-- 0001xxxxxxxxxxxx R   xxxxxxxx ROM 1     program ROM
-- 0010xxxxxxxxxxxx R   xxxxxxxx ROM 2     program ROM
-- 0011xxxxxxxxxxxx R   xxxxxxxx ROM 3     program ROM

-- SUB CPU:
-- Address          Dir Data     Name      Description
---------------- --- -------- --------- ------------------------
-- 0000xxxxxxxxxxxx R   xxxxxxxx ROM 4     program ROM    0x4000
-- 0001xxxxxxxxxxxx R   xxxxxxxx ROM 5     program ROM

-- SOUND CPU:
-- Address          Dir Data     Name      Description
---------------- --- -------- --------- ------------------------
-- 0000xxxxxxxxxxxx R   xxxxxxxx ROM 6     program ROM    0x6000
-- 0001xxxxxxxxxxxx R   xxxxxxxx ROM 7     program ROM (optional, not used) -- NOT USED IN MAME, so ignoring


rom1_cs <= '1' when dn_addr(15 downto 14) = "00"     else '0'; -- 0000 0000 0000 0000 = 0x0000  - 'maincpu'        - 16k
rom2_cs <= '1' when dn_addr(15 downto 12) = "0100"   else '0'; -- 0100 0000 0000 0000 = 0X4000  - 'sub'            - 8k 
rom3_cs <= '1' when dn_addr(15 downto 12) = "0110"   else '0'; -- 0110 0000 0000 0000 = 0x6000  - 'sub2'           - 4k

-- Graphics ROM -- Note that we have a clash here, romm_cs needs to be 8k for graphics, NOT cs54xx

roms_cs <= '1' when dn_addr(15 downto 12) = "0111"   else '0'; -- 0111 0000 0000 0000 = 0x7000  - 'gfx1'           - 2k
romb_cs <= '1' when dn_addr(15 downto 11) = "01111"  else '0'; -- 0111 1000 0000 0000 = 0x7800  - 'gfx2'           - 16k
romm_cs <= '1' when dn_addr(15 downto 11) = "10111"  else '0'; -- 1011 1000 0000 0000 = 0xb800  - 'gfx3' + 'gfx4'? - 8k

-- cpu1 program ROM
rom_cpu1 : work.dpram generic map (14,8)
port map
(
	clock_a   => clock_18,
	wren_a    => dn_wr and rom1_cs,
	address_a => dn_addr(13 downto 0),
	data_a    => dn_data,

	clock_b   => clock_18n,
	address_b => mux_addr(13 downto 0),
	q_b       => cpu1_rom_do
);

-- cpu2 program ROM
rom_cpu2 : work.dpram generic map (12,8)
port map
(
	clock_a   => clock_18,
	wren_a    => dn_wr and rom2_cs,
	address_a => dn_addr(11 downto 0),
	data_a    => dn_data,

	clock_b   => clock_18n,
	address_b => mux_addr(11 downto 0),
	q_b       => cpu2_rom_do
);

-- cpu3 program ROM
rom_cpu3 : work.dpram generic map (12,8)
port map
(
	clock_a   => clock_18,
	wren_a    => dn_wr and rom3_cs,
	address_a => dn_addr(11 downto 0),
	data_a    => dn_data,

	clock_b   => clock_18n,
	address_b => mux_addr(11 downto 0),
	q_b       => cpu3_rom_do
);

-- background graphics ROM
bg_graphics : work.dpram generic map (12,8)
port map
(
	clock_a   => clock_18,
	wren_a    => dn_wr and romb_cs,
	address_a => dn_addr(11 downto 0),
	data_a    => dn_data,

	clock_b   => clock_18n,
	address_b => bggraphx_addr(11 downto 0),
	q_b       => bggraphx_do
);

-- background palette ROM
bg_palette : entity work.bg_palette
port map(
 clk  => clock_18,
 addr => bgpalette_addr,
 data => bgpalette_do
);

-- background char RAM   0x8000-0x87FF
bgram : entity work.gen_ram
generic map( dWidth => 8, aWidth => 11)
port map(
 clk  => clock_18n,
 we   => bgram_we,
 addr => mux_addr(10 downto 0),
 d    => mux_cpu_do,
 q    => bgram_do
);
-- working/sprite register RAM1   0x8800-0x8BFF / 0x8C00-0x8FFF
wram1 : entity work.gen_ram
generic map( dWidth => 8, aWidth => 10)
port map(
 clk  => clock_18n,
 we   => wram1_we,
 addr => mux_addr(9 downto 0),
 d    => mux_cpu_do,
 q    => wram1_do
);
-- working/sprite register RAM2   0x9000-0x93FF / 0x9400-0x97FF
wram2 : entity work.gen_ram
generic map( dWidth => 8, aWidth => 10)
port map(
 clk  => clock_18n,
 we   => wram2_we,
 addr => mux_addr(9 downto 0),
 d    => mux_cpu_do,
 q    => wram2_do
);
-- working/sprite register RAM3   0x9800-0x9BFF / 0x9C00-0x9FFF
wram3 : entity work.gen_ram
generic map( dWidth => 8, aWidth => 10)
port map(
 clk  => clock_18n,
 we   => wram3_we,
 addr => mux_addr(9 downto 0),
 d    => mux_cpu_do,
 q    => wram3_do
);

-- sprite RAM1
spram1 : entity work.gen_ram
generic map( dWidth => 4, aWidth => 9)
port map(
 clk  => clock_18,
 we   => spram1_we,
 addr => spram1_addr,
 d    => spram1_di,
 q    => spram1_do
);

-- sprite RAM2
spram2 : entity work.gen_ram
generic map( dWidth => 4, aWidth => 9)
port map(
 clk  => clock_18,
 we   => spram2_we,
 addr => spram2_addr,
 d    => spram2_di,
 q    => spram2_do
);

-- sprite graphics ROM
sp_graphics : work.dpram generic map (13,8)
port map
(
	clock_a   => clock_18,
	wren_a    => dn_wr and roms_cs,
	address_a => dn_addr(12 downto 0),
	data_a    => dn_data,

	clock_b   => clock_18n,
	address_b => spgraphx_addr,
	q_b       => spgraphx_do
);

-- sprite palette ROM
sp_palette : entity work.sp_palette
port map(
 clk  => clock_18,
 addr => sppalette_addr,
 data => sppalette_do
);

-- RGB palette ROM
rgb_palette : entity work.rgb
port map(
 clk  => clock_18,
 addr => rgb_palette_addr,
 data => rgb_palette_do
);

end struct;