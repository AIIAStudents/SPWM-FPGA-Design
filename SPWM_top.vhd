library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPWM_top is
    port(
        i_clk     : in  std_logic;
        i_rst     : in  std_logic;
        i_sw      : in  std_logic_vector (3 downto 0);
        o_pwm_out : out std_logic
    );
end SPWM_top;

architecture behavioral of SPWM_top is
    
    signal clk_out1_0 : std_logic;
    signal locked_0   : std_logic;
    
    component SPWM_clk_divider
        port(
            i_clk     : in  std_logic;
            i_rst     : in  std_logic;
            i_sw      : in  std_logic_vector (3 downto 0);  
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
    
    component design_1_wrapper
        port(
            reset_0       : in  std_logic;  
            sys_clock     : in  std_logic;
            clk_out1_0    : out std_logic;
            locked_0      : out std_logic
        );
    end component;
    
    
    signal clk_div_sig : std_logic;
    signal pll_reset : std_logic;


begin
    pll_reset <= not i_rst;

    divider: SPWM_clk_divider
        port map(
            i_clk      => clk_out1_0,
            i_rst      => i_rst,
            i_sw       => i_sw,
            o_clk_div  => clk_div_sig
        );

    spwm: SPWM_main
        port map(
            i_clk     => clk_div_sig,
            i_rst     => i_rst,
            o_pwm_out => o_pwm_out
        );
        
    PLL:  design_1_wrapper
       port map(
            reset_0     => pll_reset,
            sys_clock   => i_clk,
            clk_out1_0  => clk_out1_0,
            locked_0    => locked_0
       );
       
end behavioral;
