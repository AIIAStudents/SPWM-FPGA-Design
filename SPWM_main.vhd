library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPWM_main is
    port(
        i_clk        : in  std_logic;
        i_rst        : in  std_logic;
        i_duty       : in  std_logic_vector(7 downto 0);
        o_pwm_out    : out std_logic;
        o_sin_led    : out std_logic
    );
end entity;

architecture rtl of SPWM_main is

    type STATE_TYPE is (STATE_HIGH, STATE_LOW);
    signal STATE : STATE_TYPE := STATE_LOW;
    signal cnt_high   : integer ;
    signal cnt_low    : integer ;

begin

    fsm: process(i_clk, i_rst)
    begin
        if i_rst = '0' then
            state   <= STATE_LOW;
        elsif rising_edge(i_clk) then
            if state = STATE_HIGH then
				if 	cnt_high >= to_integer(unsigned(i_duty)) - 1 then
					state   <= STATE_LOW;
				else
					state   <= STATE_HIGH;
				end if;
			elsif state = STATE_LOW then
				if cnt_low > (255 - to_integer(unsigned(i_duty))) - 1 then
					state   <= STATE_HIGH;
				else
					state   <= STATE_LOW;
				end if;
			end if;
        end if;
    end process;
	


    counter_high: process(i_clk, i_rst)
    begin
        if i_rst = '0' then
            cnt_high <= 0;
        elsif rising_edge(i_clk) then
            if state = STATE_HIGH then
                if cnt_high <to_integer(unsigned(i_duty)) - 1then
                    cnt_high <= cnt_high + 1;
                else
                    cnt_high <= 0;
                end if;
            else
                cnt_high <= 0;
            end if;
        end if;
    end process;

    counter_low: process(i_clk, i_rst)
    begin
        if i_rst = '0' then
            cnt_low <= 0;
        elsif rising_edge(i_clk) then
            if state = STATE_LOW then
                if cnt_low <= (255 - to_integer(unsigned(i_duty)))- 1 then
                    cnt_low <= cnt_low + 1;
                else
                    cnt_low <= 0;
                end if;
            else
                cnt_low <= 0;
            end if;
        end if;
    end process;
    
	outt: process(state)
    begin
            if state = STATE_HIGH then
					o_pwm_out <= '1';
			elsif state = STATE_LOW then
					o_pwm_out <= '0';
			end if; 

	end process;
       

end architecture;
