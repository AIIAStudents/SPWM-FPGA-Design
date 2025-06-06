library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity SPWM_clk_divider is
    port(
        i_clk     : in  std_logic;
        i_rst     : in  std_logic;
        i_sw      : in  std_logic_vector(3 downto 0);  
        o_clk_div : out std_logic
    );
end SPWM_clk_divider;

architecture behavioral of SPWM_clk_divider is
    signal divide : std_logic_vector (25 downto 0) := (others => '0');
begin
    process(i_clk, i_rst)
    begin
        if i_rst = '0' then
            divide <= (others => '0');
        elsif rising_edge(i_clk) then
            divide <= divide + '1';
        end if;
    end process;

    o_clk_div <= divide(3 + (to_integer(unsigned(i_sw)))); 
end behavioral;
