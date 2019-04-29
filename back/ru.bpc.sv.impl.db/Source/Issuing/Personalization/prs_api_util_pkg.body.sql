create or replace package body prs_api_util_pkg is

    function is_byte_multiple (
        i_string                in com_api_type_pkg.t_lob_data
    ) return com_api_type_pkg.t_boolean is
    begin
        if mod(length(i_string), 2) = 1 then
            trc_log_pkg.debug (
                i_text         => 'String is not byte multiple'
            );
            return com_api_type_pkg.FALSE;
        end if;
        return com_api_type_pkg.TRUE;
    end;
    
    function pad_num (
        i_number                in com_api_type_pkg.t_tiny_id
        , i_length              in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_lob_data is
        l_result                com_api_type_pkg.t_lob_data;
    begin
        l_result := nvl( to_char( i_number ), '0' );
        l_result := lpad( l_result, i_length, '0' );
        return l_result;
    end;

    function hex2bin (
        i_hex_string            in com_api_type_pkg.t_lob_data
    ) return com_api_type_pkg.t_lob_data is
    begin
        return utl_raw.cast_to_varchar2(i_hex_string);
    end;
    
    function bin2hex (
        i_bin_string            in com_api_type_pkg.t_lob_data
    ) return com_api_type_pkg.t_lob_data is
    begin
        return utl_raw.cast_to_raw(i_bin_string);
    end;

    function bin2hex2 (
        i_bin_string            in com_api_type_pkg.t_text
    ) return com_api_type_pkg.t_lob_data is
        l_bin                   com_api_type_pkg.t_text;
        l_length                com_api_type_pkg.t_tiny_id;
        l_result                varchar2(12);
    begin
        l_length := length(i_bin_string);
        for i in 1..l_length loop
            l_bin := l_bin || substr(i_bin_string, i, 1);
            if i < l_length then
                l_bin := l_bin || ',';
            end if;
        end loop;
        execute immediate 'select trim(to_char(BIN_TO_NUM(' || l_bin || '), ''XXXXXXXXXXXX'')) from dual'
        into l_result;
        if mod(nvl(length(l_result), 0), 2) != 0 then
            l_result := '0' || l_result;
        end if;
        return l_result;
    end;

    function dec2hex (
        i_dec_number            in number
    ) return com_api_type_pkg.t_lob_data is
        l_result                com_api_type_pkg.t_lob_data;
    begin
        l_result := to_char(i_dec_number, rpad('FM', length(i_dec_number) + 2, 'X'));
        if length(l_result) = 1 then
            l_result := '0' || l_result;
        end if;
        return l_result;
    end;

    function hex2dec (
        i_hex_string            in com_api_type_pkg.t_lob_data
    ) return number is
    begin
        return to_number(i_hex_string, lpad('X', length(i_hex_string), 'X'));
    end;

    function ber_tlv_length (
        i_string                in com_api_type_pkg.t_lob_data
    ) return com_api_type_pkg.t_lob_data is
      l_length                  com_api_type_pkg.t_tiny_id;
      l_hex_len                 com_api_type_pkg.t_lob_data;
      l_result                  com_api_type_pkg.t_lob_data;
    begin
        if is_byte_multiple( i_string ) = com_api_type_pkg.FALSE then
            return null;
        end if;
        l_length := length(i_string) / 2;
        
        l_hex_len := rul_api_name_pkg.pad_byte_len (
            i_src  => dec2hex( l_length )
        );
        
        if l_length < 128 /* 0x80 */ then
            l_result := l_hex_len;
        elsif ( length(l_hex_len) / 2 ) >= 255 /* 0xff */ then
            -- length in more than 254 bytes is not supported
            return null;
        else
            l_result := rawtohex (
                utl_raw.bit_or (
                    hextoraw( '80' )
                    , hextoraw(dec2hex(length(l_hex_len) / 2))
                )
            ) || l_hex_len;
        end if;
        
        return l_result;
    end;
    
    function hex_shift_left_nocycle (
        i_hex_string            in com_api_type_pkg.t_lob_data
        , i_bits                in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_lob_data is
        l_result                com_api_type_pkg.t_lob_data;
        l_length                com_api_type_pkg.t_tiny_id;
        l_bit_left              number;
        l_bit_right             number;
    begin
        l_length := nvl(length(i_hex_string), 0);

        l_bit_left := trunc(hex2dec(i_hex_string)*power(2,i_bits));
        l_bit_right := hex2dec(lpad('0', nvl(length(dec2hex(l_bit_left)),0)-l_length, '0')||lpad('F', l_length, 'F'));
        
        l_result := dec2hex(trunc(hex2dec(i_hex_string)*power(2,i_bits)));
        l_result := dec2hex(bitand(l_bit_left, l_bit_right));
        l_result := substr(l_result, -l_length);
        
        return l_result;
    end;

    function convert_data (
        i_data                 in varchar2
        , i_charset            in com_api_type_pkg.t_oracle_name
    ) return varchar2 is
        l_default_charset        com_api_type_pkg.t_oracle_name := prs_api_const_pkg.g_default_charset;
        l_charset                com_api_type_pkg.t_oracle_name := nvl(i_charset, l_default_charset);
        l_adjust_charset         boolean := l_charset != l_default_charset;
    begin
        if l_adjust_charset then
            return convert(i_data, l_charset, l_default_charset);
        end if;
        return i_data;
    end;

end;
/
