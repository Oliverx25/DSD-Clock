-- Practica 2 DSD - Reloj
-- Autores: Olvera Olvera Oliver Jesus
-- Fecha: 2024-04-21
-- Versión: 1.5

  -- ========================================================================
  --              Declaración de la librería y paquetes a utilizar
  -- ========================================================================

  library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;

  -- ========================================================================
  --                         Declaración de la entidad
  -- ========================================================================
  entity Clock is
    Port (
      -- input Clock
      clk           : in STD_LOGIC;                           -- Clock
      -- inputs Switches
      Enable        : in STD_LOGIC;                           -- Enable to change the time
      Modify_Minute : in STD_LOGIC_VECTOR(5 downto 0);        -- 2^6 > 60 (minuts)
      Modify_Hour   : in STD_LOGIC_VECTOR(4 downto 0);        -- 2^5 > 24 (hours)
      -- inputs Push Buttons
      Alarm_Save    : in STD_LOGIC;                           -- Save the alarm (Select confirmation)
      reset         : in STD_LOGIC;                           -- Reset
      -- input Memory FLASH
      Data_Queary   : in STD_LOGIC_VECTOR(7 downto 0);        -- Data from the memory FLASH

      -- outputs Segments
      Segments_Hour  : out STD_LOGIC_VECTOR(13 downto 0);     -- 7 display segments for the hours
      Segments_Minute: out STD_LOGIC_VECTOR(13 downto 0);     -- 7 display segments for the minutes
      Segments_Second: out STD_LOGIC_VECTOR(13 downto 0);     -- 7 display segments for the seconds
      -- outputs LEDs
      LED_Second        : out STD_LOGIC;                      -- LED to indicate the seconds
      LED_Alarm_Sequence: out STD_LOGIC_VECTOR(3 downto 0)    -- Sequence of the alarm
      -- outputs Memory FLASH
      Chip_Enable       : out STD_LOGIC;                      -- Chip Enable
      Output_Enable     : out STD_LOGIC;                      -- Output Enable
      Address_Memory    : out STD_LOGIC_VECTOR(1 downto 0);   -- Address of the memory FLASH
    );
  end Clock;

  -- ========================================================================
  --                       Declaración de la arquitectura
  -- ========================================================================
  architecture Main of Clock is
    -- Signals and variables
      -- Clock
    signal Counter_Second   : STD_LOGIC_VECTOR(5 downto 0) := "000000";         -- Counter for the seconds
    signal Counter_Minute   : STD_LOGIC_VECTOR(5 downto 0) := "000000";         -- Counter for the minutes
    signal Counter_Hour     : STD_LOGIC_VECTOR(4 downto 0) := "00000";          -- Counter for the hours
      -- 7-segment display (BCD)
    signal Hours_BCD        : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');  -- BCD for the hours
    signal Minutes_BCD      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');  -- BCD for the minutes
    signal Seconds_BCD      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');  -- BCD for the seconds
      -- Alarm
    signal Alarm_Minute     : STD_LOGIC_VECTOR(5 downto 0) := "000000";         -- Alarm for the minutes
    signal Alarm_Hour       : STD_LOGIC_VECTOR(4 downto 0) := "00000";          -- Alarm for the hours
      -- Clock of 1 Hz
    signal Pulse_1Hz        : STD_LOGIC := '0';                                 -- Pulse for 1 Hz
    signal LED_Pulse        : STD_LOGIC := '0';                                 -- LED to indicate the pulse
    signal Counter_Clock    : natural := 0;                                     -- Counter for the clock
    constant Clk_frequency  : natural := 49999999;                              -- 50 MHz -> 0 to 49,999,999
      -- Create the states for the alarm sequence
    type Alarm_Sequence_States is (Alarm_0, Alarm_1);
    signal Alarm_State : Alarm_Sequence_States := Alarm_0;

    --  Constants for the 7-segment display
    constant cero:   STD_LOGIC_VECTOR(6 downto 0) := "1000000"; -- 0
    constant uno:    STD_LOGIC_VECTOR(6 downto 0) := "1111001"; -- 1
    constant dos:    STD_LOGIC_VECTOR(6 downto 0) := "0100100"; -- 2
    constant tres:   STD_LOGIC_VECTOR(6 downto 0) := "0110000"; -- 3
    constant cuatro: STD_LOGIC_VECTOR(6 downto 0) := "0011001"; -- 4
    constant cinco:  STD_LOGIC_VECTOR(6 downto 0) := "0010010"; -- 5
    constant seis:   STD_LOGIC_VECTOR(6 downto 0) := "0000010"; -- 6
    constant siete:  STD_LOGIC_VECTOR(6 downto 0) := "1111000"; -- 7
    constant ocho:   STD_LOGIC_VECTOR(6 downto 0) := "0000000"; -- 8
    constant nueve:  STD_LOGIC_VECTOR(6 downto 0) := "0011000"; -- 9
    constant N_D:    STD_LOGIC_VECTOR(6 downto 0) := "0000110"; -- Error (E)

    -- Function to convert a number to 7-segment display
    function map_nibble_to_segment(nibble: std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
      case nibble is
        when "0000" => return   cero;
        when "0001" => return    uno;
        when "0010" => return    dos;
        when "0011" => return   tres;
        when "0100" => return cuatro;
        when "0101" => return  cinco;
        when "0110" => return   seis;
        when "0111" => return  siete;
        when "1000" => return   ocho;
        when "1001" => return  nueve;
        when others => return    N_D;
      end case;
    end function map_nibble_to_segment;

    -- Function for convert binary to decimal
    function Bin2BCD(Binary: std_logic_vector) return std_logic_vector is
    -- Variables for the function
    variable BCD_Return: std_logic_vector(7 downto 0) := (others => '0');
    variable Nibble_Unidades: std_logic_vector(3 downto 0) := (others => '0');
    variable Nibble_Decenas : std_logic_vector(3 downto 0) := (others => '0');
    variable Counter: integer := 0;
    begin
      BCD_Return := (others => '0');
      Counter := 0;
      -- Iteration for each bit in the binary number
      for Binary_Index in Binary'range loop
        BCD_Return := BCD_Return(6 downto 0) & Binary(Binary_Index);
        if Counter < Binary'length - 1 then
          -- Nibble of units
          Nibble_Unidades := BCD_Return(3 downto 0);
          if unsigned(Nibble_Unidades) > 4 then
            Nibble_Unidades := std_logic_vector(unsigned(Nibble_Unidades) + 3);
            BCD_Return(3 downto 0) := Nibble_Unidades;
          end if;
          -- Nibble of tens
          Nibble_Decenas := BCD_Return(7 downto 4);
          if unsigned(Nibble_Decenas) > 4 then
            Nibble_Decenas := std_logic_vector(unsigned(Nibble_Decenas) + 3);
            BCD_Return(7 downto 4) := Nibble_Decenas;
          end if;
          -- Increase the counter
          Counter := Counter + 1;
        end if;
      end loop;
      return BCD_Return;
    end function Bin2BCD;

  begin
    -- Process to change the frecuency of the clock for 50,000,000 Hz to 1 Hz (1 second)
    Clock_Second : process(clk, reset)
    begin
      -- Push button are by default '1' (active low)
      if reset = '0' then
        Counter_Clock <= 0;
        Pulse_1Hz <= '0';
      elsif rising_edge(clk) then
        if Counter_Clock < Clk_frequency then
          Counter_Clock <= Counter_Clock + 1;
          Pulse_1Hz <= '0';
        else
          Counter_Clock <= 0;
          Pulse_1Hz <= '1';
        end if;
      end if;
    end process Clock_Second;

    -- process for the LED to indicate seconds
    Clock_LED : process(clk, reset)
    begin
      -- Push button are by default '1' (active low)
      if reset = '0' then
        LED_Pulse <= '0';
      elsif rising_edge(clk) then
        if Counter_Clock < 9999999 then
          LED_Pulse <= '1';
        else
          LED_Pulse <= '0';
        end if;
      end if;
    end process Clock_LED;

    -- Counters for the clock (hours, minutes, seconds)
    Clock_24_Hours : process(clk, reset, Enable, Pulse_1Hz)
    begin
      -- Push button are by default '1' (active low)
      if reset = '0' then
        -- Reset the counters
        Counter_Second <= (others => '0');
        Counter_Minute <= (others => '0');
        Counter_Hour   <= (others => '0');
      elsif Enable = '1' then
        -- If the Enable is active (1), the clock is stopped and the time is modified
        Counter_Second <= (others => '0');
        Counter_Hour <= Modify_Hour;
        Counter_Minute <= Modify_Minute;
      elsif rising_edge(clk) then
        -- Check the clock if any counter is greater than 59 or 23
        if unsigned(Counter_Hour) > 23 then
          Counter_Hour <= (others => '0');
        end if;
        if unsigned(Counter_Minute) > 59 then
          Counter_Minute <= (others => '0');
        end if;
        -- LED to indicate the seconds (1 Hz)
        LED_Second <= LED_Pulse;
        -- If the Enable is inactive (0), the clock is running
        if Pulse_1Hz = '1' then
          -- Seconds
          if unsigned(Counter_Second) > 58 then
            Counter_Second <= (others => '0');
            -- Minutes
            if unsigned(Counter_Minute) > 58 then
              Counter_Minute <= (others => '0');
              -- Hours
              if unsigned(Counter_Hour) > 22 then
                Counter_Hour <= (others => '0');
              else
                -- Increase the hour
                Counter_Hour <= std_logic_vector(unsigned(Counter_Hour) + 1);
              end if;
            else
              -- Increase the minute
              Counter_Minute <= std_logic_vector(unsigned(Counter_Minute) + 1);
            end if;
          else
            -- Increase the second
            Counter_Second <= std_logic_vector(unsigned(Counter_Second) + 1);
          end if;
        end if;
        -- end "if" Pulse_1Hz or code block for the clock
      end if;
      -- Assign the values to the 7-segment display
      Hours_BCD <= Bin2BCD(Counter_Hour);
      Segments_Hour(13 downto 7)  <= map_nibble_to_segment(Hours_BCD(7 downto 4));
      Segments_Hour(6 downto 0)   <= map_nibble_to_segment(Hours_BCD(3 downto 0));
      Minutes_BCD <= Bin2BCD(Counter_Minute);
      Segments_Minute(13 downto 7) <= map_nibble_to_segment(Minutes_BCD(7 downto 4));
      Segments_Minute(6 downto 0)  <= map_nibble_to_segment(Minutes_BCD(3 downto 0));
      Seconds_BCD <= Bin2BCD(Counter_Second);
      Segments_Second(13 downto 7) <= map_nibble_to_segment(Seconds_BCD(7 downto 4));
      Segments_Second(6 downto 0)  <= map_nibble_to_segment(Seconds_BCD(3 downto 0));
    end process Clock_24_Hours;

    -- Process to set the alarm and the sequence of the alarm
    Alarm : process(clk, reset)
    begin
      -- Set the alarm by FLASH memory
      if Alarm_Save = '0' and Enable = '0' then -- Push button are by default '1' (active low)
      -- Signals that we need are: Alarm_Minute and Alarm_Hour, on that signals we write the values of the memory FLASH, that values are input's by ports (This ports arent declared right now, but we need to declare it on the top of the code).
      -- The values are pre-saved on the memory FLASH, so we only need to read the values of the memory FLASH and assign it to the signals Alarm_Minute and Alarm_Hour.
        -- To do that, we need to use the following ports of the memory FLASH: Chip Enable (CE -> set on 0), Output Enable (OE -> set on 0), Address (A, 21 to 0), Data Input/Output (DQ, 7 to 0).
        -- We dont use the following ports: Write Enable (WE), Reset (RST); because we only need to read the values of the memory FLASH. Maybe we need to use the port RST, but we dont know yet.
      -- Manage of the address of the memory FLASH will be done with the sentence case, since we need 2 addresses, one for the Alarm_Minute and the other for the Alarm_Hour. That addresses are: 0x000000 and 0x000001. That can be done with only one port address (0 and 1), and concatenate it with the address of the memory FLASH (0x000000). -> A(21 to 0) = 0x000000 + 0 = 0x000000 and 0x000000 + 1 = 0x000001.
      -- Chip Enable (CE) and Output Enable (OE) are set on 0, because we need to read the values of the memory FLASH.
      -- Data Input/Output (DQ) are the values that we need to read, so we need to assign it to the signals Alarm_Minute and Alarm_Hour. That port are the only one that will be declarade by input, the other are output.
    -- We only access to set the alarm when the Enable is inactive (0), because we need to set the alarm when the clock is running. and the signal are rewrited only when the Alarm_Save is active (0). That in case we have many alarms, we only need to save the last alarm or the alarm that we need to set usign the sitwitches (Modify_Minute and Modify_Hour) to select the address of the memory FLASH for each alarm.

        Alarm_Minute <= Modify_Minute;
        -- Check the alarm minute if is greater than 59
        if unsigned(Modify_Minute) > 59 then
          Alarm_Minute <= "000000";
        end if;
        Alarm_Hour <= Modify_Hour;
        -- Check the alarm hour if is greater than 23
        if unsigned(Modify_Hour) > 23 then
          Alarm_Hour <= "00000";
        end if;

      -- Code block for the alarm sequence
      elsif rising_edge(clk) then
        if Pulse_1Hz = '1' then
          -- Check the alarm
          case Alarm_State is
            when Alarm_0 =>
              -- Continue pass to the next state for one minute
              if Counter_Hour = Alarm_Hour and Counter_Minute = Alarm_Minute then
                LED_Alarm_Sequence <= "1001";
                Alarm_State <= Alarm_1;
              else
                LED_Alarm_Sequence <= "0000";
              end if;
            -- Sequence of the alarm
            when Alarm_1 =>
              LED_Alarm_Sequence <= "0110";
              Alarm_State <= Alarm_0;
            -- Default state
            when others =>
              Alarm_State <= Alarm_0;
          end case;
        end if;
      end if;
    end process Alarm;
  end Main;