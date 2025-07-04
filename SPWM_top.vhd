library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPWM_top is
    port(
        i_clk         : in  std_logic;
        i_rst         : in  std_logic;
--        i_sw_freq     : in  std_logic_vector(6 downto 0); 
        o_pwm_a       : out std_logic; 
        o_pwm_b       : out std_logic; 
        o_pwm_c       : out std_logic;    
        o_sin_led     : out std_logic
    );
end SPWM_top;

architecture behavioral of SPWM_top is
    
    signal clk_out1_0                            : std_logic;
    signal locked_0                              : std_logic;
    signal sin_value_a, sin_value_b, sin_value_c : std_logic_vector(8 downto 0);
    signal clk_div_sig                           : std_logic;
    signal pll_reset                             : std_logic;
--    signal phase_a,phase_b,phase_c               : unsigned(8 downto 0);
    signal sin_index                             : std_logic_vector(8 downto 0);
    
    component SPWM_clk_divider
        port(
            i_clk     : in  std_logic;
            i_rst     : in  std_logic;
    --            i_sw_freq : in  std_logic_vector(6 downto 0);
            o_clk_div : out std_logic
        );
    end component;

    component SPWM_main
        port(
            i_clk      : in  std_logic;                    
            i_rst      : in  std_logic;  
            i_duty     : in  std_logic_vector(8 downto 0);                  
            o_pwm_out  : out std_logic;
            o_sin_led  : out std_logic                     
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
    
    component SPWM_index
        port(
            i_clk     : in  std_logic;   
            i_rst     : in  std_logic;   
            o_sin_value_a : out std_logic_vector(8 downto 0);
            o_sin_value_b : out std_logic_vector(8 downto 0);
            o_sin_value_c : out std_logic_vector(8 downto 0)
    );
    end component;

begin
    pll_reset <= not i_rst;

    divider: SPWM_clk_divider
        port map(
            i_clk      => clk_out1_0,
            i_rst      => i_rst, 
     --           i_sw_freq  => i_sw_freq,
            o_clk_div  => clk_div_sig
        );

    spwm_1: SPWM_main
        port map(
            i_clk      => clk_div_sig,
            i_rst      => i_rst,
            i_duty     => sin_value_a,
            o_pwm_out  => o_pwm_a,            
            o_sin_led  => o_sin_led 
        );
        
    spwm_2: SPWM_main
          port map(
            i_clk      => clk_div_sig,
            i_rst      => i_rst,
            i_duty     => sin_value_b,
            o_pwm_out  => o_pwm_b,            
            o_sin_led  => o_sin_led 
        );
        
    spwm_3: SPWM_main
           port map(
            i_clk      => clk_div_sig,
            i_rst      => i_rst,
            i_duty     => sin_value_c,
            o_pwm_out  => o_pwm_c,          
            o_sin_led  => o_sin_led 
        );

    SPWM_indexx: SPWM_index
          port map( 
            i_clk         => clk_div_sig,   
            i_rst         => i_rst,         
            o_sin_value_a => sin_value_a ,
            o_sin_value_b => sin_value_b,
            o_sin_value_c => sin_value_c
        );

    PLL:  design_1_wrapper
       port map(
            reset_0     => pll_reset,
            sys_clock   => i_clk,
            clk_out1_0  => clk_out1_0,
            locked_0    => locked_0
       );
       
end behavioral;
