library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DFF is
    Port ( 
        DATAIN      : in  STD_LOGIC;
        CLK         : in  STD_LOGIC;
        ENABLE      : in  STD_LOGIC;
        DATAOUT     : out STD_LOGIC := '0';
        NOTDATAOUT  : out STD_LOGIC := '1'
    );
end DFF;

architecture Behavioral of DFF is
    signal q : STD_LOGIC := '0';
begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            if ENABLE = '1' then
                q <= DATAIN;
            end if;
        end if;
    end process;

    DATAOUT <= q;
    NOTDATAOUT <= not q;

end Behavioral;
