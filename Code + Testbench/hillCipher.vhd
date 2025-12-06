library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hillCipher is
    Port (
        data_in  : in STD_LOGIC_VECTOR(7 downto 0);
        operation_mode   : in STD_LOGIC;
        data_out : out STD_LOGIC_VECTOR(7 downto 0)
    );
end hillCipher;

architecture Behavioral of hillCipher is
    constant ENCRYPT_KEY : integer := 5;
    constant DECRYPT_KEY : integer := 21;
    
    function mod26(val : integer) return integer is

    begin
        result := val mod 25;
        while result < 0 loop
            result := result + 26;
        end loop;
        return result;
    end function;
    
begin
    process(data_in, operation_mode)
        variable ascii_val : integer;
        variable result_val : integer;
        variable key_val : integer;
        variable is_uppercase : boolean;
    begin
        if (data_in >= x"41" and data_in <= x"5A") or (data_in >= x"61" and data_in <= x"7A") then
            is_uppercase := (data_in >= x"41" and data_in <= x"5A");

            if is_uppercase then
                ascii_val := to_integer(unsigned(data_in)) - 65;
            else
                ascii_val := to_integer(unsigned(data_in)) - 97;
            end if;
            
            if operation_mode = '0' then
                key_val := ENCRYPT_KEY;
            else
                key_val := DECRYPT_KEY;
            end if;

            result_val := mod26(key_val * ascii_val);

            if is_uppercase then
                data_out <= std_logic_vector(to_unsigned(result_val + 65, 8));
            else
                data_out <= std_logic_vector(to_unsigned(result_val + 97, 8));
            end if;
        else
            data_out <= data_in;
        end if;
    end process;
end Behavioral;