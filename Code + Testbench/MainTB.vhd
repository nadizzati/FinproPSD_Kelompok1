library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity MainTB is
end MainTB;

architecture Behavioral of MainTB is
    component Main
        Port (
            clock_sig       : in STD_LOGIC;
            reset_sig       : in STD_LOGIC;
            operation_mode  : in STD_LOGIC;
            start_sig       : in STD_LOGIC;
            done_signal     : out STD_LOGIC;
            error_signal    : out STD_LOGIC;
            debug_input     : out STD_LOGIC_VECTOR(7 downto 0);
            debug_caesar    : out STD_LOGIC_VECTOR(7 downto 0);
            debug_hill      : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    signal sys_clock       : STD_LOGIC := '0';
    signal sys_reset       : STD_LOGIC := '0';
    signal sys_mode        : STD_LOGIC := '1'; 
    signal sys_start       : STD_LOGIC := '0';
    signal sys_done        : STD_LOGIC := '0';
    signal sys_error       : STD_LOGIC := '0';

    signal mon_input       : STD_LOGIC_VECTOR(7 downto 0);
    signal mon_caesar      : STD_LOGIC_VECTOR(7 downto 0);
    signal mon_hill        : STD_LOGIC_VECTOR(7 downto 0);
    signal char_input      : character := ' ';
    signal char_caesar     : character := ' ';
    signal char_hill       : character := ' ';

    constant CLOCK_PERIOD : time := 10 ns;

begin
    dut: Main PORT MAP (
        clock_sig => sys_clock,
        reset_sig => sys_reset,
        operation_mode => sys_mode,
        start_sig => sys_start,
        done_signal => sys_done,
        error_signal => sys_error,
        debug_input => mon_input,
        debug_caesar => mon_hill, 
        debug_hill => mon_caesar 
    );
    
    char_input <= character'val(to_integer(unsigned(mon_input))) when (mon_input >= x"20" and mon_input <= x"7E") else ' ';
    char_caesar <= character'val(to_integer(unsigned(mon_caesar))) when (mon_caesar >= x"20" and mon_caesar <= x"7E") else ' ';
    char_hill <= character'val(to_integer(unsigned(mon_hill))) when (mon_hill >= x"20" and mon_hill <= x"7E") else ' ';

    clock_gen: process
    begin
        while now < 2000 ns loop
            sys_clock <= '0';
            wait for CLOCK_PERIOD/2;
            sys_clock <= '1';
            wait for CLOCK_PERIOD/2;
        end loop;
        wait;
    end process;

    test_proc: process
        procedure create_input(text_data : string) is
            file src_file : text open write_mode is "input.txt";
            variable output_line : line;
        begin
            for idx in text_data'range loop
                write(output_line, text_data(idx));
                writeline(src_file, output_line);
            end loop;
            file_close(src_file);
            report "Input written to file: " & text_data severity note;
        end procedure;

        procedure verify_output(encrypt_flag : boolean; expected_text : string) is
            file result_file : text;
            variable input_line : line;
            variable char_read : character;
            variable result_string : string(1 to expected_text'length);
            variable pos : integer := 1;
        begin
            if encrypt_flag then
                report "Reading Encrypted Output" severity note;
                file_open(result_file, "encryptOutput.txt", read_mode);
            else
                report "Reading Decrypted Output" severity note;
                file_open(result_file, "decryptOutput.txt", read_mode);
            end if;

            pos := 1;
            while not endfile(result_file) and pos <= expected_text'length loop
                readline(result_file, input_line);
                read(input_line, char_read);
                result_string(pos) := char_read;
                report "Output Char: " & char_read severity note;
                pos := pos + 1;
            end loop;

            file_close(result_file);

            if result_string /= expected_text then
                report "Got:       " & result_string severity note;
            else
                report "Output matches expected data" severity note;
            end if;
        end procedure;

    begin
        sys_reset <= '1';
        wait for CLOCK_PERIOD;
        sys_reset <= '0';

        report "ENCRYPTION TEST SCENARIO" severity note;
        create_input("hello");

        sys_mode <= '0';
        sys_start <= '1';
        wait for CLOCK_PERIOD;
        sys_start <= '0';

        wait until sys_done = '1';
        wait for CLOCK_PERIOD;

        verify_output(true, "yjsyh"); 

        sys_reset <= '1';
        wait for CLOCK_PERIOD;
        sys_reset <= '0';

        report "DECRYPTION TEST SCENARIO" severity note;
        create_input("yjssh");
        
        sys_mode <= '1';
        sys_start <= '1';
        wait for CLOCK_PERIOD;
        sys_start <= '0';

        wait until sys_done = '1';
        wait for CLOCK_PERIOD;

        verify_output(false, "hello");

        wait;
    end process;
end Behavioral;