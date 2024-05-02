-- Practica 2 DSD - Reloj
-- Autores: Olvera Olvera Oliver Jesus
-- Fecha: 2024-04-21
-- Versión: 1.0

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
            -- inputs Switches
            -- Suplir por un switch, 0 -> Config-Alarm, 1 -> Config-Hour
            Change_Enable : in STD_LOGIC;                           -- Habilita el cambio de hora
            Alarm_Enable  : in STD_LOGIC;                           -- Habilita configuración de alarma
            -- ================================
            -- inputs Push Buttons
            Alarm_Save    : in STD_LOGIC;                           -- Guardar alarma
            Modify_Minute : in STD_LOGIC_VECTOR(5 downto 0);        -- 2^6 > 60 (minutos)
            Modify_Hour   : in STD_LOGIC_VECTOR(4 downto 0);        -- 2^5 > 24 (horas)

            -- outputs Segments
            Segments_Hour  : out STD_LOGIC_VECTOR(13 downto 0);     -- 7 segmentos para las horas
            Segments_Minute: out STD_LOGIC_VECTOR(13 downto 0);     -- 7 segmentos para los minutos
            Segments_Second: out STD_LOGIC_VECTOR(13 downto 0);     -- 7 segmentos para los segundos
            -- outputs LEDs
            LED_Second        : out STD_LOGIC                       -- LED para indicar segundos
            LED_Alarm_Sequence: out STD_LOGIC_VECTOR(3 downto 0)    -- Secuencia de LEDs para indicar alarma
        );
    end Clock;

    -- ========================================================================
    --                       Declaración de la arquitectura
    -- ========================================================================
    architecture Main of Clock is
    -- Señales a utilizar
    begin
        
    end Main;