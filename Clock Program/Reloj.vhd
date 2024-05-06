-- Programa reloj 
-- Elaborado por: Mejía Avianeda Avril Paola
-- Versión: 0

-- *:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧
-- 		Declaración de bibliotecas y paquetes
-- *:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧
	library IEEE;
	use IEEE.std_logic_1164.all;

-- *:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧
-- 		Declaración de la entidad
-- *:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧
	entity Reloj is
		port(
		-- Entradas
			clk : in std_logic;												-- Reloj de la tarjeta
			clr, set : in std_logic;										-- Selectores para set y reset
			new_hh, new_mm : in std_logic;									-- Ajuste de hora (módulo 24) y minutos (módulo 60)
		-- Salidas
			HEX0 : out std_logic_vector(6 downto 0);                   		-- Display HEX0 de 0x a 2x horas
			HEX1 : out std_logic_vector(6 downto 0);                		-- Display HEX1 de x0 a x9 horas
            HEX2 : out std_logic_vector(6 downto 0);		        		-- Display HEX2 de 0x a 5x minutos
            HEX3 : out std_logic_vector(6 downto 0);		        		-- Display HEX3 de x0 a x9 minutos
            HEX4 : out std_logic_vector(6 downto 0);		        		-- Display HEX4 de 0x a 5x segundos
            HEX5 : out std_logic_vector(6 downto 0);		        		-- Display HEX5 de x0 a x9 segundos
			LEDG8 : out std_logic											-- LED verde que enciende cada segundo
		);
	end entity;
	
-- *:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧
-- 		Declaración de la arquitectura
-- *:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧*:･ﾟ✧
	architecture Main of Reloj is
	-- Variables auxiliares internas
		signal clk_h0, clk_h1, clk_m0, clk_m1, clk_s0, clk_s1 : std_logic := '0';			-- Divisor de frecuencia para los contadores BCD
		signal clk_a1, clk_a2 : std_logic := '0';																					-- Divisor de frecuencia para los ajustes de hora y minutos
		signal new_set : std_logic;																											-- Para sincronizar el ajuste de horario
		constant max_freq : integer := 50_000_000;											-- Frecuencia del reloj de la tarjeta
		constant med_freq : integer := max_freq/2;											-- El nombre lo dice
		signal counter : integer range 0 to max_freq;										-- Para incrementar o decrementar en 1 cada pulso de reloj
	
	-- Asignación de segmentos para display
		constant cero:		std_logic_vector(6 downto 0) := "1000000";		-- Constante para 0 en display
		constant uno:		std_logic_vector(6 downto 0) := "1111001";		-- Constante para 1 en display
		constant dos:		std_logic_vector(6 downto 0) := "0100100";		-- Constante para 2 en display
		constant tres:		std_logic_vector(6 downto 0) := "0110000";		-- Constante para 3 en display
		constant cuatro:	std_logic_vector(6 downto 0) := "0011001";		-- Constante para 4 en display
		constant cinco:	std_logic_vector(6 downto 0) := "0010010";		    -- Constante para 5 en display
		constant seis:		std_logic_vector(6 downto 0) := "0000010";		-- Constante para 6 en display
		constant siete:		std_logic_vector(6 downto 0) := "0111000";		-- Constante para 7 en display
		constant ocho:		std_logic_vector(6 downto 0) := "0000000";		-- Constante para 8 en display
		constant nueve:	std_logic_vector(6 downto 0) := "0011000";		    -- Constante para 9 en display
		constant N_D:		std_logic_vector(6 downto 0) := "0111111";		-- Constante para - en display
	-- Función para constantes
		function display(num : integer) return std_logic_vector is
			variable hex : std_logic_vector(6 downto 0);
			begin
				case num is
					when 0 => hex := cero;
					when 1 => hex := uno;
					when 2 => hex := dos;
					when 3 => hex := tres;
					when 4 => hex := cuatro;
					when 5 => hex := cinco;
					when 6 => hex := seis;
					when 7 => hex := siete;
					when 8 => hex := ocho;
					when 9 => hex := nueve;
					when others => hex := N_D;
				end case;
			return hex;
		end function;
		
	-- Declaración de los procesos
		begin												-- Main de la arquitectura
		
		process (clk)										-- Para bajar la frecuencia a segundos (frecuencia de 1 Hz)
			begin
			if (rising_edge(clk)) then						-- Detecta cuando clk cambie de 0 a 1
				if (counter < max_freq) then
					counter <= counter + 1;
				else
					counter <= 1;
				end if;
				if (counter <= med_freq) then
					clk_h0 <= '0';
				else
					clk_h0 <= '1';
				end if;
			end if;
		end process;
		
		process (clk_h0, clr, set, new_hh, new_mm)			-- Implementación del reloj
		-- Variables auxiliares internas
			variable hh_0 : integer range 0 to 3;			-- Se le va a pasar a HEX0
			variable hh_1 : integer range 0 to 10;			-- Se le va a pasar a HEX1
			variable mm_0 : integer range 0 to 6;			-- Se le va a pasar a HEX2
			variable mm_1 : integer range 0 to 10;			-- Se le va a pasar a HEX3
			variable ss_0 : integer range 0 to 6;			-- Se le va a pasar a HEX4
			variable ss_1 : integer range 0 to 10;			-- Se le va a pasar a HEX5
		-- Señal asíncrona de reset
			begin
			if (clr = '1') then								-- Reset
				hh_0 := 0;
				hh_1 := 0;
				mm_0 := 0;
				mm_1 := 0;
				ss_0 := 0;
				ss_1 := 0;
			else											-- Contador para el segundero
				if (rising_edge(clk)) then					-- Detecta cuando clk cambie de 0 a 1
					ss_1 := ss_1 + 1;						-- Aumenta cada segundo
					clk_s1 <= '0';																		
					if (ss_1 = 10) then						-- Para cuando llegue a los 09 segundos, pase a 10
						ss_1 := 0;
						clk_s1 <= '1';
					end if;
				end if;
				if (rising_edge(clk)) then					-- Detecta cuando clk cambie de 0 a 1
					ss_0 := ss_0 + 1;
					clk_s0 <= '0';
					if (ss_0 = 10) then
						ss_0 := 0;
						clk_s0 <= '1';
					end if;
				end if;
			-- Señal de ajuste de minutos
				if (rising_edge(clk)) then					-- Detecta cuando clk cambie de 0 a 1
					new_set <= set;							-- Sincroniza los segundos
				end if;
				clk_a1 <= (clk_s0 and not new_set) or (new_mm and new_set);
				if (rising_edge(clk)) then					-- Detecta cuando clk cambie de 0 a 1
				-- Contador para el minutero
					mm_1 := mm_1 + 1;						-- Aumenta cada minuto
					clk_m1 <= '0';
					if (mm_1 = 10) then						-- Para cuando llegue a los 09 minutos, pase a 10
						mm_1 := 0;
						clk_m1 <= '1';
					end if;
				end if;
				if (rising_edge(clk)) then					-- Detecta cuando clk cambie de 0 a 1
					mm_0 := mm_0 + 1;
					clk_m0 <= '0';
					if (mm_0 = 6) then
						mm_0 := 0;
						clk_m0 <= '1';
					end if;
				end if;
			-- Señal de ajuste de minutos
				clk_a2 <= (clk_m0 and not new_set) or (new_hh and new_set);
				if (rising_edge(clk)) then					-- Detecta cuando clk cambie de 0 a 1
				-- Contador para las horas
					hh_1 := hh_1 + 1;
					clk_h1 <= '0';
					if (hh_1 = 10) then
						hh_1 := 0;
						clk_h1 <= '1';
					end if;
				end if;
				if (rising_edge(clk)) then					-- Detecta cuando clk cambie de 0 a 1
					hh_0 := hh_0 + 1;
				end if;
				if (hh_0 = 2 and hh_1 = 4) then
					hh_1 := 0;
					hh_0 := 0;
				end if;
			end if;
			HEX0 <= display(hh_0);
			HEX1 <= display(hh_1);
			HEX2 <= display(mm_0);
			HEX3 <= display(mm_1);
			HEX4 <= display(ss_0);
			HEX5 <= display(ss_1);
		end process;
	end architecture;
