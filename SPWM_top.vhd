library ieee;
use ieee.std_logic_1164.all;

entity SPWM_top is
    port(
        i_clk     : in  std_logic;
        i_rst     : in  std_logic;
        o_pwm_out : out std_logic
    );
end SPWM_top;

architecture behavioral of SPWM_top is

    component SPWM_clk_divider
        port(
            i_clk     : in  std_logic;
            i_rst     : in  std_logic;
            o_clk_div : out std_logic
        );
    end component;

    component SPWM_main
        port(
            i_clk     : in  std_logic;
            i_rst     : in  std_logic;
            o_pwm_out : out std_logic
        );
    end component;


    signal clk_div_sig : std_logic;

begin

    divider: SPWM_clk_divider
        port map(
            i_clk     => i_clk,
            i_rst     => i_rst,
            o_clk_div => clk_div_sig
        );

    spwm: SPWM_main
        port map(
            i_clk     => clk_div_sig,
            i_rst     => i_rst,
            o_pwm_out => o_pwm_out
        );

end behavioral;