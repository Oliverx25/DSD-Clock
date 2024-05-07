component Bin2BCD is
  port (
      Binary: in std_logic_vector;
      BCD: out std_logic_vector(11 downto 0)
  );
end component;

architecture Behavioral of Bin2BCD is
  -- Variables de la función BCD
  variable Nibble_Unidades: std_logic_vector(3 downto 0) := (others => '0');
  variable Nibble_Decenas : std_logic_vector(3 downto 0) := (others => '0');
  variable Nibble_Centenas: std_logic_vector(3 downto 0) := (others => '0');
  variable Counter: integer := 0;
begin
  BCD := (others => '0');
  Counter := 0;
  -- Iteración de bits de Bin a BCD
  for Binary_Index in Binary'range loop
      BCD := BCD(10 downto 0) & Binary(Binary_Index);
      if Counter < Binary'length - 1 then
          -- Nibble de las unidades
          Nibble_Unidades := BCD(3 downto 0);
          if unsigned(Nibble_Unidades) > 4 then
              Nibble_Unidades := std_logic_vector(unsigned(Nibble_Unidades) + 3);
              BCD(3 downto 0) := Nibble_Unidades;
          end if;
          -- Nibble de las decenas
          Nibble_Decenas := BCD(7 downto 4);
          if unsigned(Nibble_Decenas) > 4 then
              Nibble_Decenas := std_logic_vector(unsigned(Nibble_Decenas) + 3);
              BCD(7 downto 4) := Nibble_Decenas;
          end if;
          -- Nibble de las centenas
          Nibble_Centenas := BCD(11 downto 8);
          if unsigned(Nibble_Centenas) > 4 then
              Nibble_Centenas := std_logic_vector(unsigned(Nibble_Centenas) + 3);
              BCD(11 downto 8) := Nibble_Centenas;
          end if;
          -- Aumento del contador
          Counter := Counter + 1;
      end if;
  end loop;
end Behavioral;