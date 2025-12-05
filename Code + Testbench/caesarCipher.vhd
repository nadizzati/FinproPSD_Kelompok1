library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity caesarCipher is
    port (
        char_input       : in  std_logic_vector(7 downto 0);
        enc_dec_mode     : in  std_logic;  -- '0' encrypt, '1' decrypt
        shift_amount     : in  integer range 0 to 25;
        char_output      : out std_logic_vector(7 downto 0)
    );
end entity caesarCipher;

architecture Behavioral of caesarCipher is
begin
    process(char_input, enc_dec_mode, shift_amount)
        variable ascii_value : integer range 0 to 255;
        variable shift_value : integer range -25 to 25;
    begin
        -- input -> integer
        ascii_value := to_integer(unsigned(char_input));
        
        -- determine shift direction based on mode
        if enc_dec_mode = '0' then  -- encrypt
            shift_value := shift_amount;
        else  -- decrypt
            shift_value := -shift_amount;
        end if;
        
        -- uppercase letters (A-Z)
        if (ascii_value >= 65 and ascii_value <= 90) then
            ascii_value := ((ascii_value - 65 + shift_value + 26) mod 26) + 65;
        
        -- lowercase letters (a-z)
        elsif (ascii_value >= 97 and ascii_value <= 122) then
            ascii_value := ((ascii_value - 97 + shift_value + 26) mod 26) + 97;
        end if;

        char_output <= std_logic_vector(to_unsigned(ascii_value, 8));
    end process;
end architecture Behavioral;