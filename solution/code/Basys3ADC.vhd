library ieee;
use ieee.std_logic_1164.all;

entity Basys3ADC is
    port(
        clk : in std_logic;
        XA2_P : in std_logic;
        XA2_N : in std_logic;
        an : out std_logic_vector(3 downto 0);
        seg : out std_logic_vector(7 downto 0);
        led : out std_logic_vector(7 downto 0) :="00000000"
        );
 end Basys3ADC;
 
 architecture beh of Basys3ADC is
 
 component xadc_wiz_0
   port
   (
    daddr_in        : in  STD_LOGIC_VECTOR (6 downto 0);     -- Address bus for the dynamic reconfiguration port
    den_in          : in  STD_LOGIC;                         -- Enable Signal for the dynamic reconfiguration port
    di_in           : in  STD_LOGIC_VECTOR (15 downto 0);    -- Input data bus for the dynamic reconfiguration port
    dwe_in          : in  STD_LOGIC;                         -- Write Enable for the dynamic reconfiguration port
    do_out          : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
    drdy_out        : out  STD_LOGIC;                        -- Data ready signal for the dynamic reconfiguration port
    dclk_in         : in  STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port
    reset_in        : in  STD_LOGIC;                         -- Reset signal for the System Monitor control logic
    vauxp14         : in  STD_LOGIC;                         -- Auxiliary Channel 14
    vauxn14         : in  STD_LOGIC;
    busy_out        : out  STD_LOGIC;                        -- ADC Busy signal
    channel_out     : out  STD_LOGIC_VECTOR (4 downto 0);    -- Channel Selection Outputs
    eoc_out         : out  STD_LOGIC;                        -- End of Conversion Signal
    eos_out         : out  STD_LOGIC;                        -- End of Sequence Signal
    alarm_out       : out STD_LOGIC;                         -- OR'ed output of all the Alarms
    vp_in           : in  STD_LOGIC;                         -- Dedicated Analog Input Pair
    vn_in           : in  STD_LOGIC
);
end component;

component sseg_dec 
    Port (      ALU_VAL : in std_logic_vector(7 downto 0); 
					    SIGN : in std_logic;
						VALID : in std_logic;
                    CLK : in std_logic;
                DISP_EN : out std_logic_vector(3 downto 0);
               SEGMENTS : out std_logic_vector(7 downto 0));
end component;

component clk_div2
    Port (  clk : in std_logic;
           sclk : out std_logic);
end component;

component EightBitDataPassDelay
    Port ( FastIn       : in STD_LOGIC_VECTOR (7 downto 0);
           UpdateNow    : in STD_LOGIC;
           HeldSample   : out STD_LOGIC_VECTOR (7 downto 0));
end component;


component EightBitBarMeter
    Port (  BarDatIn  : in  STD_LOGIC_VECTOR (7 downto 0);
            BarDatOut : out STD_LOGIC_VECTOR (7 downto 0) := "00000000"   );
end component;


signal ADCintcon    : std_logic_vector (7 downto 0);
signal ADCslowintcon    : std_logic_vector(7 downto 0);
signal Waistintcon  : std_logic_vector(7 downto 0);
signal EnableInt    : std_logic:='1';
signal ReadyInt     : std_logic;
signal SlowClock    : std_logic;


begin

u1: clk_div2
    Port map(  
            clk => clk,
            sclk => SlowClock
           );


u2: xadc_wiz_0
   port map
   (
    daddr_in                => "0011110",      -- Address bus for the dynamic reconfiguration port
    den_in                  => EnableInt,                         -- Enable Signal for the dynamic reconfiguration port
    di_in                   => (others => '0'),     -- Input data bus for the dynamic reconfiguration port
    dwe_in                  => '0',                          -- Write Enable for the dynamic reconfiguration port
    do_out (15 downto 8)    => ADCintcon,    -- Output data bus for dynamic reconfiguration port
    do_out (7 downto 0)     => Waistintcon,
    drdy_out                => open,                -- Data ready signal for the dynamic reconfiguration port
    dclk_in                 => clk,                         -- Clock input for the dynamic reconfiguration port
    reset_in                => '0',                         -- Reset signal for the System Monitor control logic
    vauxp14                 => XA2_P, --ADC(0),                         -- Auxiliary Channel 14
    vauxn14                 => XA2_N, --ADC(1),
    busy_out                => open,                        -- ADC Busy signal
    channel_out             => open,    -- Channel Selection Outputs
    eoc_out                 => EnableInt,                        -- End of Conversion Signal
    eos_out                 => open,                        -- End of Sequence Signal
    alarm_out               => open,                         -- OR'ed output of all the Alarms
    vp_in                   => '0',                         -- Dedicated Analog Input Pair
    vn_in                   => '0'
);

u3: EightBitDataPassDelay
    Port map ( 
            FastIn      => ADCintcon (7 downto 0),      
            UpdateNow   => SlowClock,
            HeldSample  => ADCslowintcon
           );
           
U4: sseg_dec 
    Port map (  ALU_VAL  => ADCslowintcon (7 downto 0),
			     SIGN    => '0',
				 VALID   => '1',
                 CLK     => clk,
                 DISP_EN => an,
                 SEGMENTS=> seg
                 );

u5: EightBitBarMeter
    Port map (  BarDatIn  => ADCintcon (7 downto 0),
                BarDatOut => led ( 7 downto 0) 
             );
             
             
end beh;
