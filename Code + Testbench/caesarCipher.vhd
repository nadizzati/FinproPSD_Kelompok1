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
        variable shifted_value : integer;
        variable normalized : integer;
        variable shift_value : integer;
    begin
        -- input -> integer
        ascii_value := to_integer(unsigned(char_input));
        
        -- shift direction based on mode
        if enc_dec_mode = '0' then  -- encrypt
            shift_value := shift_amount;
        else  -- decrypt
            shift_value := -shift_amount;
        end if;
        
        -- uppercase letters (A-Z)
        if (ascii_value >= 65 and ascii_value <= 90) then
            normalized := ascii_value - 65;
            shifted_value := normalized + shift_value;
            
            -- modulo for negative numbers
            while shifted_value < 0 loop
                shifted_value := shifted_value + 26;
            end loop;
            
            shifted_value := shifted_value mod 26;
            ascii_value := shifted_value + 65;
        
        -- lowercase letters (a-z)
        elsif (ascii_value >= 97 and ascii_value <= 122) then
            normalized := ascii_value - 97;
            shifted_value := normalized + shift_value;
            
            -- modulo for negative numbers
            while shifted_value < 0 loop
                shifted_value := shifted_value + 26;
            end loop;
            
            shifted_value := shifted_value mod 26;
            ascii_value := shifted_value + 97;
        end if;
        
        -- konversi ke std_logic_vector
        char_output <= std_logic_vector(to_unsigned(ascii_value, 8));
    end process;
end architecture Behavioral;