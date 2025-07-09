library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPWM_clk_divider is
    port(
        i_clk     : in  std_logic;                    
        i_rst     : in  std_logic;
--        i_sw_freq : in  std_logic_vector(6 downto 0); 
        o_clk_div : out std_logic;
        o_clk_div_index : out std_logic                   
    );
end entity;

architecture behavioral of SPWM_clk_divider is
    signal divide : unsigned(25 downto 0) := (others=>'0');
begin
    process(i_clk, i_rst)
    begin
        if i_rst='0' then
            divide <= (others=>'0');
        elsif rising_edge(i_clk) then
            divide <= divide + 1;
        end if;
    end process;
--    o_clk_div <= std_logic(divide(3 + to_integer(unsigned(i_sw_freq))));
    o_clk_div       <= std_logic(divide(3));
    o_clk_div_index <= std_logic(divide(11));
end architecture; 