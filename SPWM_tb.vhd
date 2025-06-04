library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPWM_top_tb is
end SPWM_top_tb;

architecture test of SPWM_top_tb is

    -- DUT Port Signals
    signal i_clk     : std_logic := '0';
    signal i_rst     : std_logic := '1';
    signal o_pwm_out : std_logic;

    -- Clock Period
    constant CLK_PERIOD : time := 20 ns; 

    -- DUT Component
    component SPWM_top
        port(
            i_clk     : in  std_logic;
            i_rst     : in  std_logic;
            o_pwm_out : out std_logic
        );
    end component;

begin


    uut: SPWM_top
        port map(
            i_clk     => i_clk,
            i_rst     => i_rst,
            o_pwm_out => o_pwm_out
        );


    clk_process : process
    begin
        while true loop
            i_clk <= '0';
            wait for CLK_PERIOD / 2;
            i_clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;


    rst_process : process
    begin
        i_rst <= '0';
        wait for 100 ns;
        i_rst <= '1'; 
        wait;
    end process;


end test;
