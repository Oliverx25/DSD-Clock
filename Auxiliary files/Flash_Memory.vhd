library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flash_memory is
  port (
    clk_flash : in std_logic;                     -- port map (clk_flash => clk)
    reset_flash : in std_logic;                   -- port map (reset_flash => reset)

    addr : in std_logic_vector(7 downto 0);       -- port map (addr => Signal defined on architecture)
    -- The address is a signal of 8 bits, that can be used to access 256 positions (2^8 = 256)
    -- we access the memory using the address, that with signal inside of the architecture

    -- In that port, maping to a signal that alocate the data that be write (8 bits)
    data_in : in std_logic_vector(7 downto 0);    -- port map (data_in => Hours or Minutes)
    -- Hours're a signal of 5 bits, we need convert to 8 bits -> 3 bits of 0 in the left -> 000HHHHH (32)
    -- the same case for Minutes of 6 bits -> 2 bits of 0 in the left -> 00MMMMMM (64)
    -- If we conver the signal to 8 bits, we need to convert the signal to 8 bits or use auxiliar signal to pass the data for the memory and can be compared with the data that we read

    write_en : in std_logic;                      -- port map (write_en => not(push_button))
    -- only write when the push_button is pressed (push_button = '0') because the push_button is active low

    read_en : in std_logic;                       -- port map (read_en => '1') -> Always read
    -- The port read_en is always '1' because the read is always enable

    -- That port can be used as a signal, since that not be used in the top level (physical port)
    data_out : out std_logic_vector(7 downto 0)   -- port map (data_out )
  );
end entity flash_memory;

architecture behavioral of flash_memory is
  type memory_array is array (255 downto 0) of std_logic_vector(7 downto 0);
  signal memory : memory_array;
begin
  process (clk, reset)
  begin
    if reset = '1' then
      memory <= (others => (others => '0'));
    elsif rising_edge(clk) then
      if write_en = '1' then
        memory(to_integer(unsigned(addr))) <= data_in;
      end if;
      if read_en = '1' then
        data_out <= memory(to_integer(unsigned(addr)));
      end if;
    end if;
  end process;
end architecture behavioral;