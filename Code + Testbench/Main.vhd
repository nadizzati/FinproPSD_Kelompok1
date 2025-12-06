library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity Main is
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
end Main;

architecture Behavioral of Main is
    -- State definitions
    type fsm_state is (
        STATE_IDLE, 
        STATE_OPEN_FILE,
        STATE_READ_DATA, 
        STATE_CAESAR_OP, 
        STATE_HILL_OP, 
        STATE_WRITE_TEMP, 
        STATE_WRITE_RESULT, 
        STATE_DONE, 
        STATE_ERROR
    );
    
    signal present_state : fsm_state := STATE_IDLE;
    
    -- Component declarations
    component caesarCipher 
        port (
            char_input       : in  std_logic_vector(7 downto 0);
            enc_dec_mode     : in  std_logic;
            shift_amount     : in  integer range 0 to 25;
            char_output      : out std_logic_vector(7 downto 0)
        );
    end component;

    component hillCipher 
        port (
            data_in  : in STD_LOGIC_VECTOR(7 downto 0);
            operation_mode   : in STD_LOGIC;
            data_out : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- Signals
    signal byte_input : std_logic_vector(7 downto 0);
    signal caesar_result, hill_result : std_logic_vector(7 downto 0);
    signal proc_mode : std_logic;
    signal completion_flag : std_logic := '0';
    signal error_flag : std_logic := '0';
    constant SHIFT_KEY : integer := 3;

begin
    -- Component instantiations
    caesar_unit : caesarCipher port map (
        char_input => byte_input,
        enc_dec_mode => proc_mode,
        shift_amount => SHIFT_KEY,
        char_output => caesar_result
    );

    hill_unit : hillCipher port map (
        data_in => byte_input,
        operation_mode => proc_mode,
        data_out => hill_result
    );

    -- Output assignments
    done_signal <= completion_flag;
    error_signal <= error_flag;
    
    -- Debug signal assignments
    debug_input <= byte_input;
    debug_caesar <= caesar_result;
    debug_hill <= hill_result;

    -- Main state machine
    fsm_process: process(clock_sig, reset_sig)
        file src_file  : text;
        file temp_file : text;
        file dest_file : text;
        
        variable txt_line_in : line;
        variable txt_line_out : line;
        variable read_char : character;
        variable file_opened : boolean := false;
    begin
        if reset_sig = '1' then
            present_state <= STATE_IDLE;
            completion_flag <= '0';
            error_flag <= '0';
            proc_mode <= '0';
            file_opened := false;
        elsif rising_edge(clock_sig) then
            case present_state is
                when STATE_IDLE =>
                    if start_sig = '1' then
                        proc_mode <= operation_mode;
                        present_state <= STATE_OPEN_FILE;
                        completion_flag <= '0';
                        error_flag <= '0';
                    end if;

                when STATE_OPEN_FILE =>
                    file_open(src_file, "input.txt", read_mode);
                    
                    if proc_mode = '0' then
                        file_open(temp_file, "phase1.txt", write_mode);
                        file_open(dest_file, "encryptOutput.txt", write_mode);
                    else
                        file_open(temp_file, "phase1.txt", write_mode);
                        file_open(dest_file, "decryptOutput.txt", write_mode);
                    end if;
                    
                    file_opened := true;
                    present_state <= STATE_READ_DATA;

                when STATE_READ_DATA =>
                    if not endfile(src_file) then
                        readline(src_file, txt_line_in);
                        read(txt_line_in, read_char);
                        byte_input <= std_logic_vector(to_unsigned(character'pos(read_char), 8));
                        
                        if proc_mode = '0' then
                            present_state <= STATE_CAESAR_OP;
                        else
                            present_state <= STATE_HILL_OP;
                        end if;
                    else
                        present_state <= STATE_DONE;
                    end if;

                when STATE_HILL_OP =>
                    if proc_mode = '1' then  -- Decryption: Hill 1
                        byte_input <= hill_result;
                        write(txt_line_out, character'val(to_integer(unsigned(hill_result))));
                        writeline(temp_file, txt_line_out);
                        present_state <= STATE_CAESAR_OP;
                    else  -- Encryption: Hill 2
                        byte_input <= hill_result;
                        write(txt_line_out, character'val(to_integer(unsigned(hill_result))));
                        writeline(dest_file, txt_line_out);
                        present_state <= STATE_WRITE_RESULT;
                    end if;
                
                when STATE_CAESAR_OP =>
                    if proc_mode = '1' then  -- Decryption: Caesar 2
                        byte_input <= caesar_result;
                        write(txt_line_out, character'val(to_integer(unsigned(caesar_result))));
                        writeline(dest_file, txt_line_out);
                        present_state <= STATE_WRITE_RESULT;
                    else  -- Encryption: Caesar 1
                        byte_input <= caesar_result;
                        write(txt_line_out, character'val(to_integer(unsigned(caesar_result))));
                        writeline(temp_file, txt_line_out);
                        present_state <= STATE_HILL_OP;
                    end if;

                when STATE_WRITE_RESULT =>
                    present_state <= STATE_READ_DATA;

                when STATE_DONE =>
                    if file_opened then
                        file_close(src_file);
                        file_close(temp_file);
                        file_close(dest_file);
                        file_opened := false;
                    end if;
                    
                    completion_flag <= '1';
                    present_state <= STATE_IDLE;

                when STATE_ERROR =>
                    error_flag <= '1';
                    present_state <= STATE_IDLE;

                when others =>
                    present_state <= STATE_ERROR;
            end case;
        end if;
    end process fsm_process;
end Behavioral;
