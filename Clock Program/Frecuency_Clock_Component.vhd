library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Declaración del componente
component frequency_divider is
    port (
        clk_in : in std_logic;  -- Reloj de entrada (50MHz)
        clk_out : out std_logic -- Reloj de salida (1Hz)
    );
end component frequency_divider;

-- Implementación del componente
architecture behavioral of frequency_divider is
    signal count : integer range 0 to 50000000 := 0; -- Contador para el divisor de frecuencia
begin
    process (clk_in)
    begin
        if rising_edge(clk_in) then
            if count = 50000000 then
                clk_out <= not clk_out; -- Cambia el estado del reloj de salida
                count <= 0; -- Reinicia el contador
            else
                count <= count + 1; -- Incrementa el contador
            end if;
        end if;
    end process;
end behavioral;