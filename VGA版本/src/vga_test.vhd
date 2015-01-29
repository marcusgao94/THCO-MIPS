library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga_test is
  PORT(
    clk :  IN   STD_LOGIC;  --50M
	 clk_sys : IN   STD_LOGIC; -- System: 12.5M
    rst   :  IN   STD_LOGIC;  --rst
	 
	 write_ena : IN STD_LOGIC;
	 write_char : IN STD_LOGIC_VECTOR(15 downto 0);
	 
	 
    h_sync    :  OUT  STD_LOGIC;  --horiztonal sync pulse
    v_sync    :  OUT  STD_LOGIC;  --vertical sync pulse
    
	 r, g, b : out STD_LOGIC_VECTOR(2 downto 0)
	 
	 
	); 
end vga_test;

architecture behave of vga_test is

  SIGNAL pix_clk : STD_LOGIC;
  SIGNAL dis_ena : STD_LOGIC;
  SIGNAL column : INTEGER;
  SIGNAL row : INTEGER;
  SIGNAL n_blank : STD_LOGIC;
  SIGNAL n_sync : STD_LOGIC; 
  
  SIGNAL column_minus : INTEGER;

  component fredivider_vga
  port(
    clkin:in STD_LOGIC;
    clkout:out STD_LOGIC
  );
  end component;
  
  COMPONENT vga_controller 
  GENERIC(
    h_pulse  :  INTEGER;   --horiztonal sync pulse width in pixels
    h_bp     :  INTEGER;   --horiztonal back porch width in pixels
    h_pixels :  INTEGER;  --horiztonal display width in pixels
    h_fp     :  INTEGER;   --horiztonal front porch width in pixels
    h_pol    :  STD_LOGIC;   --horizontal sync pulse polarity (1 = positive, 0 = negative)
    v_pulse  :  INTEGER;     --vertical sync pulse width in rows
    v_bp     :  INTEGER;    --vertical back porch width in rows
    v_pixels :  INTEGER;  --vertical display width in rows
    v_fp     :  INTEGER;     --vertical front porch width in rows
    v_pol    :  STD_LOGIC);  --vertical sync pulse polarity (1 = positive, 0 = negative)
  PORT(
    pixel_clk :  IN   STD_LOGIC;  --pixel clock at frequency of VGA mode being used
    reset_n   :  IN   STD_LOGIC;  --active low asycnchronous reset
    h_sync    :  OUT  STD_LOGIC;  --horiztonal sync pulse
    v_sync    :  OUT  STD_LOGIC;  --vertical sync pulse
    disp_ena  :  OUT  STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    column    :  OUT  INTEGER;    --horizontal pixel coordinate
    row       :  OUT  INTEGER;    --vertical pixel coordinate
    n_blank   :  OUT  STD_LOGIC;  --direct blacking output to DAC
    n_sync    :  OUT  STD_LOGIC); --sync-on-green output to DAC
  END component;
  
  component hw_image_generator 
		GENERIC(
			pixels_y :  INTEGER;   --row that first color will persist until
			pixels_x :  INTEGER);  --column that first color will persist until
		PORT(
			disp_ena :  IN   STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
			row      :  IN   INTEGER;    --row pixel coordinate
			column   :  IN   INTEGER;    --column pixel coordinate
			red      :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
			green    :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
			blue     :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
	END component;
	
  COMPONENT text_generator
  PORT(
    clkr      :  IN   STD_LOGIC;
	 clkw      :  IN   STD_LOGIC;
	 rst      :  IN   STD_LOGIC;
    disp_ena :  IN   STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    row      :  IN   INTEGER;    --row pixel coordinate
    column   :  IN   INTEGER;    --column pixel coordinate
	 write_ena:  IN   STD_LOGIC;
	 write_char: IN STD_LOGIC_VECTOR(15 downto 0);
    red      :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
    green    :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
    blue     :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
  END component;
	
begin

	 ufredivider:
    fredivider_vga port map(
      clkin=>clk,clkout=>pix_clk
    );
	 
	 uController:
	 vga_controller 
	 generic map (
	  h_pulse => 96,   --horiztonal sync pulse width in pixels
     h_bp => 48,   --horiztonal back porch width in pixels
     h_pixels=> 640,  --horiztonal display width in pixels
     h_fp=> 16,   --horiztonal front porch width in pixels
     h_pol=>'0',   --horizontal sync pulse polarity (1 = positive, 0 = negative)
     v_pulse =>2,     --vertical sync pulse width in rows
     v_bp =>33,    --vertical back porch width in rows
     v_pixels=>480,  --vertical display width in rows
     v_fp=>10,     --vertical front porch width in rows
     v_pol=>'0'  --vertical sync pulse polarity (1 = positive, 0 = negative)
	 )
	 port map(
		pixel_clk=>pix_clk, 
		reset_n=>rst, 
      h_sync=>h_sync, 
      v_sync=>v_sync, 
      disp_ena=>dis_ena, 
      column=>column, 
      row=>row, 
      n_blank=>n_blank, 
      n_sync=>n_sync
	 );
	 
--	 uImageGen:
--	 hw_image_generator 
--	 generic map (
--	  pixels_y =>200,   --row that first color will persist until
--     pixels_x =>200  --column that first color will persist until
--	 ) 
--	 port map (
--		--clk=>pix_clk, 
--	   disp_ena=>dis_ena, 
--		row=>row, 
--		column=>column, 
--		red=>r, 
--		green=>g, 
--		blue=>b
--	 );
	 
	 column_minus <= column - 1;
	 

	uTextGen:
	text_generator
	port map (
		clkr=>pix_clk,
		clkw=>clk_sys, 
		-- -Here Pay Attention !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		rst=>rst, 
		disp_ena=>dis_ena, 
		row=>row, 
		column=>column_minus, 
		write_ena=>write_ena,
		write_char=>write_char, 
		red=>r, 
		green=>g, 
		blue=>b
	);

end behave;

