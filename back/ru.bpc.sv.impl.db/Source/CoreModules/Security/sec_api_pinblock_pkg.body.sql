create or replace package body sec_api_pinblock_pkg as

function hex2dec(
    i_hex       in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_money is
begin
    return to_number(i_hex, lpad('x', length(i_hex), 'x'));
end;

function dec2hex( 
    i_dec       in      com_api_type_pkg.t_money 
) return com_api_type_pkg.t_name is
begin
    return to_char(i_dec, rpad('fm', length(i_dec) + 2, 'x'));
end;

function decrypt_3des_ecb( 
    i_src       in      com_api_type_pkg.t_pin_block
  , i_key       in      com_api_type_pkg.t_key
) return com_api_type_pkg.t_pin_block is
    l_result    com_api_type_pkg.t_pin_block;
begin
    l_result := 
        rawtohex( 
            dbms_crypto.decrypt( 
                src => hextoraw(i_src)
              , typ => dbms_crypto.encrypt_3des_2key + dbms_crypto.chain_ecb + dbms_crypto.pad_none
              , key => hextoraw(i_key)
            )
        );
    return l_result;
end;

function encrypt_3des_ecb( 
    i_src       in      com_api_type_pkg.t_pin_block
  , i_key       in      com_api_type_pkg.t_key
) return com_api_type_pkg.t_pin_block is
    l_result    com_api_type_pkg.t_pin_block;
begin
    l_result := 
        rawtohex( 
            dbms_crypto.encrypt( 
                src => hextoraw(i_src)
              , typ => dbms_crypto.encrypt_3des_2key + dbms_crypto.chain_ecb + dbms_crypto.pad_none
              , key => hextoraw(i_key)
            )
        );
    return l_result;
end;

function hex_bit_xor( 
    i_operand_a     in      com_api_type_pkg.t_pin_block
  , i_operand_b     in      com_api_type_pkg.t_pin_block
) return varchar2 is
    l_operand_a     com_api_type_pkg.t_pin_block;
    l_operand_b     com_api_type_pkg.t_pin_block;
    l_length        com_api_type_pkg.t_count    := 0;
begin
    l_length    := greatest(nvl(length(i_operand_a), 0), nvl(length(i_operand_b), 0));
    l_operand_a := lpad(i_operand_a, l_length, '0');
    l_operand_b := lpad(i_operand_b, l_length, '0');

    return rawtohex(utl_raw.bit_xor(hextoraw(l_operand_a), hextoraw(l_operand_b)));

end;

function get_random_hex_str( 
    i_length        in      com_api_type_pkg.t_count 
) return varchar2 is
    l_count         com_api_type_pkg.t_count  := 1;
    l_result        com_api_type_pkg.t_lob_data;
begin
    if i_length > 32767 then
        trc_log_pkg.debug('String length too large, truncate');
        return null;
    end if;

    while l_count <= i_length loop
        l_result  := l_result || to_char(mod(abs(dbms_random.random), 16), 'fmx');
        l_count   := l_count + 1;
    end loop;
    
    return l_result;
end;

procedure get_pinblock (
    i_key                   in      com_api_type_pkg.t_key
  , i_card_number           in      com_api_type_pkg.t_card_number
  , i_pin                   in      com_api_type_pkg.t_pin_block
  , i_pinblock_format       in      com_api_type_pkg.t_dict_value
  , o_pin_length               out  com_api_type_pkg.t_tiny_id
  , o_pin_padded               out  com_api_type_pkg.t_pin_block
  , o_pinblock                 out  com_api_type_pkg.t_pin_block
  , o_pinblock_clear           out  com_api_type_pkg.t_pin_block
)is

begin
    case i_pinblock_format
        when prs_api_const_pkg.PIN_BLOCK_FORMAT_ANSI then
            o_pin_padded := rpad('0' || dec2hex(nvl(length(i_pin), 0)) || i_pin, 16, 'F');
      
            o_pinblock_clear := hex_bit_xor(o_pin_padded, '0000'|| substr(i_card_number, -13, 12));
      
            o_pinblock := 
                encrypt_3des_ecb( 
                    i_src   => o_pinblock_clear
                  , i_key   => i_key
                );
        when '03' then
            o_pinblock_clear := rpad(i_pin, 16, 'F');
            
            o_pinblock := 
                encrypt_3des_ecb( 
                    i_src   => o_pinblock_clear
                  , i_key   => i_key
                );
        when '05' then
            o_pinblock_clear := '1' || dec2hex(nvl(length(i_pin), 0)) || i_pin || upper(get_random_hex_str(16 - 2 - nvl(length(i_pin), 0)));
            
            o_pinblock := 
                encrypt_3des_ecb( 
                    i_src   => o_pinblock_clear
                  , i_key   => i_key
                );
        when '34' then
            o_pinblock_clear := rpad('2'|| dec2hex(nvl(length(i_pin), 0)) || i_pin, 16, 'F');
            
            o_pinblock := 
                encrypt_3des_ecb( 
                    i_src   => o_pinblock_clear
                  , i_key   => i_key
                );
        else
            com_api_error_pkg.raise_error(
                i_error      => 'UNKNOWN_PINBLOCK_FORMAT'
              , i_env_param1 => i_pinblock_format
            );
    end case;
end;

procedure get_pin (
    i_key                   in      com_api_type_pkg.t_key
  , i_card_number           in      com_api_type_pkg.t_card_number
  , i_pinblock_encrypted    in      com_api_type_pkg.t_pin_block
  , i_pinblock_format       in      com_api_type_pkg.t_dict_value
  , o_pin                      out  com_api_type_pkg.t_pin_block
  , o_pin_length               out  com_api_type_pkg.t_tiny_id
  , o_pin_padded               out  com_api_type_pkg.t_pin_block
  , o_pinblock_clear           out  com_api_type_pkg.t_pin_block
) is
begin

    case i_pinblock_format
        when prs_api_const_pkg.PIN_BLOCK_FORMAT_ANSI then
            o_pinblock_clear := 
                decrypt_3des_ecb( 
                    i_src   => i_pinblock_encrypted
                  , i_key   => i_key
                );
                
            o_pin_padded := hex_bit_xor(o_pinblock_clear, '0000'||substr(i_card_number, -13, 12));
            
            if substr(o_pin_padded, 1, 1) != '0' then
                trc_log_pkg.debug('Incorrect padded PIN: '|| o_pin_padded);
                return;
            end if;
            
            o_pin_length := hex2dec(substr(o_pin_padded, 2, 1));
            
            if replace(substr(o_pin_padded, 2 + o_pin_length + 1 ), 'F', '') is not null then
                trc_log_pkg.debug('Incorrect padded PIN: '|| o_pin_padded);
                return;
            end if;
            
            o_pin := substr(o_pin_padded, 3, o_pin_length);
            
        when '03' then
            o_pinblock_clear := 
                decrypt_3des_ecb( 
                    i_src   => i_pinblock_encrypted
                  , i_key   => i_key
                );
                
                o_pin := rtrim(o_pinblock_clear, 'F');
    
        when '05' then
            o_pinblock_clear := 
                decrypt_3des_ecb( 
                    i_src   => i_pinblock_encrypted
                  , i_key   => i_key
                );
                
            if substr(o_pinblock_clear, 1, 1) != '1' then
                trc_log_pkg.debug('Incorrect PIN block: '|| o_pinblock_clear );
                return;
            end if;
            
            o_pin_length := hex2dec(substr(o_pinblock_clear, 2, 1));
            o_pin := substr(o_pinblock_clear, 3, o_pin_length);
            
        when '34' then
            o_pinblock_clear := 
                decrypt_3des_ecb( 
                    i_src   => i_pinblock_encrypted
                  , i_key   => i_key
                );
                
            if substr(o_pinblock_clear, 1, 1) != '2' then
                trc_log_pkg.debug('Incorrect PIN block: '|| o_pinblock_clear);
                return;
            end if;
            
            o_pin_length := hex2dec(substr(o_pinblock_clear, 2, 1));
            
            if replace(substr(o_pinblock_clear, 2 + o_pin_length + 1), 'F', '') is not null then
                trc_log_pkg.debug('Incorrect PIN block padding: '|| o_pinblock_clear);
            end if;
            
            o_pin := 
                rtrim(
                    substr(
                        o_pinblock_clear
                      , 3
                      , hex2dec(substr(o_pinblock_clear, 2, 1))
                    )
                  , 'F'
                );
        else
            trc_log_pkg.debug('PIN block format not supported: '|| i_pinblock_format );
    end case;
  
end;

end;
/