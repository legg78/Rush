create or replace package body mup_api_msg_pkg is

    subtype t_de_rec is mup_de%rowtype;
    type t_de_tab is table of t_de_rec index by binary_integer;
    
    g_de t_de_tab;
    
    procedure init_de_tab is
        l_de t_de_tab;
    begin
        select 
            de_number
            , name
            , upper(format)
            , min_length
            , max_length
            , prefix_length
            , subfield_count
        bulk collect into 
            l_de
        from 
            mup_de;
        
        g_de.delete;
        
        for i in 1 .. l_de.count loop
            g_de(l_de(i).de_number) := l_de(i);
        end loop;
        
        l_de.delete;
    end;

    function format_de003 (
        i_de003_1         in mup_api_type_pkg.t_de003
        , i_de003_2         in mup_api_type_pkg.t_de003
        , i_de003_3         in mup_api_type_pkg.t_de003
    ) return mup_api_type_pkg.t_de003 is
    begin
        if i_de003_1 is not null then
            return i_de003_1 || nvl(i_de003_2, mup_api_const_pkg.DEFAULT_DE003_2) || nvl(i_de003_3, mup_api_const_pkg.DEFAULT_DE003_3);
        else
            return null;
        end if;
    end;     
    
    function format_de022 (   
        i_de022_1           in mup_api_type_pkg.t_de022s
        , i_de022_2         in mup_api_type_pkg.t_de022s
        , i_de022_3         in mup_api_type_pkg.t_de022s
        , i_de022_4         in mup_api_type_pkg.t_de022s
        , i_de022_5         in mup_api_type_pkg.t_de022s
        , i_de022_6         in com_api_type_pkg.t_byte_char
        , i_de022_7         in mup_api_type_pkg.t_de022s
        , i_de022_8         in mup_api_type_pkg.t_de022s
        , i_de022_9         in mup_api_type_pkg.t_de022s
        , i_de022_10        in mup_api_type_pkg.t_de022s
        , i_de022_11        in mup_api_type_pkg.t_de022s
    ) return mup_api_type_pkg.t_de022 is
    begin
        if (   
            i_de022_1 is not null
            or i_de022_2 is not null
            or i_de022_3 is not null
            or i_de022_4 is not null
            or i_de022_5 is not null
            or i_de022_6 is not null
            or i_de022_7 is not null
            or i_de022_8 is not null
            or i_de022_9  is not null
            or i_de022_10 is not null
            or i_de022_11 is not null
        ) then
            return
            (   nvl(i_de022_1,  '0')  ||
                nvl(i_de022_2,  '9')  ||
                nvl(i_de022_3,  '9')  ||
                nvl(i_de022_4,  '9')  ||
                nvl(i_de022_5,  '9')  ||
                nvl(i_de022_6,  '00') ||
                nvl(i_de022_7,  '9')  ||
                nvl(i_de022_8,  '9')  ||
                nvl(i_de022_9,  '0')  ||
                nvl(i_de022_10, '0')  ||
                nvl(i_de022_11, '1')
            );
        else
            return null;
        end if;
    end;
    
    function format_de030 (
        i_de030_1           in mup_api_type_pkg.t_de030s
        , i_de030_2         in mup_api_type_pkg.t_de030s
    ) return mup_api_type_pkg.t_de030 is
    begin
        if i_de030_1 is not null or i_de030_2 is not null then
            return (
                mup_utl_pkg.pad_number(nvl(i_de030_1, 0), 12, 12)
                || mup_utl_pkg.pad_number(nvl(i_de030_2, 0), 12, 12)
            );
        else
            return null;
        end if;
    end;
    
    function format_de043 (   
        i_de043_1               in mup_api_type_pkg.t_de043
        , i_de043_2             in mup_api_type_pkg.t_de043
        , i_de043_3             in mup_api_type_pkg.t_de043
        , i_de043_4             in mup_api_type_pkg.t_de043
        , i_de043_5             in mup_api_type_pkg.t_de043
        , i_de043_6             in mup_api_type_pkg.t_de043
    ) return mup_api_type_pkg.t_de043 is
        result                  mup_api_type_pkg.t_de043;
        formatted_de043_3       mup_api_type_pkg.t_de043;
    begin
        if (   
            i_de043_1 is not null
            or i_de043_2 is not null
            or i_de043_3 is not null
            or i_de043_4 is not null
            or i_de043_5 is not null
            or i_de043_6 is not null
        ) then
        
            result := nvl(replace(substr(i_de043_1, 1, 22), '\','/'), ' ') || '\';
            result := result || replace(i_de043_2, '\', '/');

            formatted_de043_3 := '\' || replace(substr(i_de043_3, 1, 13),'\','/') || '\';

            result := substr(result, 1, 83 - length(formatted_de043_3));
            result := result || formatted_de043_3;
            result := result || rpad(nvl(replace(substr(i_de043_4, 1, 10), '\','/'), ' '), 10, ' ');
            result := result || rpad(nvl(substr(i_de043_5, 1, 3), ' '), 3, ' ');
            result := result || rpad(nvl(substr(i_de043_6, 1, 3), ' '), 3, ' ');
        end if;

        return result;
    end;

    procedure parse_de003 (
        i_de003            in mup_api_type_pkg.t_de003
        , o_de003_1        out mup_api_type_pkg.t_de003
        , o_de003_2        out mup_api_type_pkg.t_de003
        , o_de003_3        out mup_api_type_pkg.t_de003
    ) is
    begin
        if i_de003 is not null then
            o_de003_1 := substrb(i_de003, 1, 2);
            o_de003_2 := substrb(i_de003, 3, lengthb(mup_api_const_pkg.DEFAULT_DE003_2));
            o_de003_3 := substrb(i_de003, 5, lengthb(mup_api_const_pkg.DEFAULT_DE003_3));
        end if;
    end;
    
    procedure parse_de022 (
        i_de022             in mup_api_type_pkg.t_de022
        , o_de022_1         out mup_api_type_pkg.t_de022s
        , o_de022_2         out mup_api_type_pkg.t_de022s
        , o_de022_3         out mup_api_type_pkg.t_de022s
        , o_de022_4         out mup_api_type_pkg.t_de022s
        , o_de022_5         out mup_api_type_pkg.t_de022s
        , o_de022_6         out com_api_type_pkg.t_byte_char
        , o_de022_7         out mup_api_type_pkg.t_de022s
        , o_de022_8         out mup_api_type_pkg.t_de022s
        , o_de022_9         out mup_api_type_pkg.t_de022s
        , o_de022_10        out mup_api_type_pkg.t_de022s
        , o_de022_11        out mup_api_type_pkg.t_de022s
    ) is
    begin
        if i_de022 is not null then
            o_de022_1  := substrb(i_de022, 1,  1);
            o_de022_2  := substrb(i_de022, 2,  1);
            o_de022_3  := substrb(i_de022, 3,  1);
            o_de022_4  := substrb(i_de022, 4,  1);
            o_de022_5  := substrb(i_de022, 5,  1);
            o_de022_6  := substrb(i_de022, 6,  2);
            o_de022_7  := substrb(i_de022, 8,  1);
            o_de022_8  := substrb(i_de022, 9,  1);
            o_de022_9  := substrb(i_de022, 10, 1);
            o_de022_10 := substrb(i_de022, 11, 1);
            o_de022_11 := substrb(i_de022, 12, 1);
        end if;
    end;
    
    procedure parse_de030 (
        i_de030             in mup_api_type_pkg.t_de030
        , o_de030_1         out mup_api_type_pkg.t_de030s
        , o_de030_2         out mup_api_type_pkg.t_de030s
    ) is
        l_curr_pos           pls_integer;
    begin
        if i_de030 is not null then
            l_curr_pos := 1;
            o_de030_1 := to_number(substrb(i_de030, l_curr_pos, 12));
            l_curr_pos := 12;
            o_de030_2 := to_number(substrb(i_de030, l_curr_pos, 12));
        end if;
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error         => 'MUP_ERROR_WRONG_LENGTH'
                , i_env_param1  => 'DE030'
                , i_env_param2  => l_curr_pos
                , i_env_param3  => i_de030
            );
    end;
    
    procedure parse_de043 (
        i_de043             in mup_api_type_pkg.t_de043
        , o_de043_1         out mup_api_type_pkg.t_de043
        , o_de043_2         out mup_api_type_pkg.t_de043
        , o_de043_3         out mup_api_type_pkg.t_de043
        , o_de043_4         out mup_api_type_pkg.t_de043
        , o_de043_5         out mup_api_type_pkg.t_de043
        , o_de043_6         out mup_api_type_pkg.t_de043
        
    ) is
        l_curr_pos           pls_integer := 1;
        l_pos                pls_integer := 1;
    begin
        if i_de043 is not null then
            l_pos := instrb(i_de043, mup_api_const_pkg.DE043_FIELD_DELIMITER, l_curr_pos);
            if l_pos > 0 then
                o_de043_1 := substrb(i_de043, l_curr_pos, l_pos - l_curr_pos);
                l_curr_pos := l_pos + 1;
            else
                com_api_error_pkg.raise_error(
                    i_error         => 'MUP_SUBFIELD_DELIMITER_NOT_FOUND'
                    , i_env_param1  => 'DE043'
                    , i_env_param2  => l_curr_pos
                    , i_env_param3  => i_de043
                );
            end if;

            l_pos := instrb(i_de043, mup_api_const_pkg.DE043_FIELD_DELIMITER, l_curr_pos);
            if l_pos > 0 then
                o_de043_2 := substrb(i_de043, l_curr_pos, l_pos - l_curr_pos);
                l_curr_pos := l_pos + 1;
            else
                com_api_error_pkg.raise_error(
                    i_error         => 'MUP_SUBFIELD_DELIMITER_NOT_FOUND'
                    , i_env_param1  => 'DE043'
                    , i_env_param2  => l_curr_pos
                    , i_env_param3  => i_de043
                );
            end if;

            l_pos := instrb(i_de043, mup_api_const_pkg.DE043_FIELD_DELIMITER, l_curr_pos);
            if l_pos > 0 then
                o_de043_3 := substrb(i_de043, l_curr_pos, l_pos - l_curr_pos);
                l_curr_pos := l_pos + 1;
            else
                com_api_error_pkg.raise_error(
                    i_error         => 'MUP_SUBFIELD_DELIMITER_NOT_FOUND'
                    , i_env_param1  => 'DE043'
                    , i_env_param2  => l_curr_pos
                    , i_env_param3  => i_de043
                );
            end if;

            o_de043_4 := rtrim(substrb(i_de043, l_curr_pos, 10));
            o_de043_5 := rtrim(substrb(i_de043, l_curr_pos + 10, 3));
            o_de043_6 := rtrim(substrb(i_de043, l_curr_pos + 13, 3));
        end if;
    end;

    procedure pack_message (
        o_raw_data          out varchar2
        , i_pds_tab         in mup_api_type_pkg.t_pds_tab
        , i_mti             in mup_api_type_pkg.t_mti
        , i_de002           in mup_api_type_pkg.t_de002
        , i_de003_1         in mup_api_type_pkg.t_de003
        , i_de003_2         in mup_api_type_pkg.t_de003
        , i_de003_3         in mup_api_type_pkg.t_de003
        , i_de004           in mup_api_type_pkg.t_de004
        , i_de005           in mup_api_type_pkg.t_de005
        , i_de006           in mup_api_type_pkg.t_de006
        , i_de009           in mup_api_type_pkg.t_de009
        , i_de010           in mup_api_type_pkg.t_de010
        , i_de012           in mup_api_type_pkg.t_de012
        , i_de014           in mup_api_type_pkg.t_de014
        , i_de022           in mup_api_type_pkg.t_de022
        , i_de022_1         in mup_api_type_pkg.t_de022s
        , i_de022_2         in mup_api_type_pkg.t_de022s
        , i_de022_3         in mup_api_type_pkg.t_de022s
        , i_de022_4         in mup_api_type_pkg.t_de022s
        , i_de022_5         in mup_api_type_pkg.t_de022s
        , i_de022_6         in com_api_type_pkg.t_byte_char
        , i_de022_7         in mup_api_type_pkg.t_de022s
        , i_de022_8         in mup_api_type_pkg.t_de022s
        , i_de022_9         in mup_api_type_pkg.t_de022s
        , i_de022_10        in mup_api_type_pkg.t_de022s
        , i_de022_11        in mup_api_type_pkg.t_de022s
        , i_de023           in mup_api_type_pkg.t_de023
        , i_de024           in mup_api_type_pkg.t_de024
        , i_de025           in mup_api_type_pkg.t_de025
        , i_de026           in mup_api_type_pkg.t_de026
        , i_de030           in mup_api_type_pkg.t_de030
        , i_de030_1         in mup_api_type_pkg.t_de030s
        , i_de030_2         in mup_api_type_pkg.t_de030s
        , i_de031           in mup_api_type_pkg.t_de031
        , i_de032           in mup_api_type_pkg.t_de032
        , i_de033           in mup_api_type_pkg.t_de033
        , i_de037           in mup_api_type_pkg.t_de037
        , i_de038           in mup_api_type_pkg.t_de038
        , i_de040           in mup_api_type_pkg.t_de040
        , i_de041           in mup_api_type_pkg.t_de041
        , i_de042           in mup_api_type_pkg.t_de042
        , i_de043           in mup_api_type_pkg.t_de043
        , i_de043_1         in mup_api_type_pkg.t_de043
        , i_de043_2         in mup_api_type_pkg.t_de043
        , i_de043_3         in mup_api_type_pkg.t_de043
        , i_de043_4         in mup_api_type_pkg.t_de043
        , i_de043_5         in mup_api_type_pkg.t_de043
        , i_de043_6         in mup_api_type_pkg.t_de043
        , i_de049           in mup_api_type_pkg.t_de049
        , i_de050           in mup_api_type_pkg.t_de050
        , i_de051           in mup_api_type_pkg.t_de051
        , i_de054           in mup_api_type_pkg.t_de054
        , i_de055           in mup_api_type_pkg.t_de055
        , i_de063           in mup_api_type_pkg.t_de063
        , i_de071           in mup_api_type_pkg.t_de071
        , i_de072           in mup_api_type_pkg.t_de072
        , i_de073           in mup_api_type_pkg.t_de073
        , i_de093           in mup_api_type_pkg.t_de093
        , i_de094           in mup_api_type_pkg.t_de094
        , i_de095           in mup_api_type_pkg.t_de095
        , i_de100           in mup_api_type_pkg.t_de100
        , i_de123           in mup_api_type_pkg.t_de123 
        , i_de124           in mup_api_type_pkg.t_de124 
        , i_de125           in mup_api_type_pkg.t_de125 
        , i_charset         in com_api_type_pkg.t_oracle_name
    ) is
        l_de048             mup_api_type_pkg.t_de048;
        l_de062             mup_api_type_pkg.t_de062;
        l_de123             mup_api_type_pkg.t_de123;
        l_de124             mup_api_type_pkg.t_de124;
        l_de125             mup_api_type_pkg.t_de125;
        
        l_bitmask_word1     binary_integer := 0;
        l_bitmask_word2     binary_integer := 0;
        l_bitmask_word3     binary_integer := 0;
        l_bitmask_word4     binary_integer := 0;
        l_bitmask_word5     binary_integer := 0;
        l_bitmask_word6     binary_integer := 0;
        l_bitmask_word7     binary_integer := 0;
        l_bitmask_word8     binary_integer := 0;

        l_default_charset   com_api_type_pkg.t_oracle_name := mup_api_const_pkg.g_default_charset;
        l_charset           com_api_type_pkg.t_oracle_name := nvl(i_charset, l_default_charset);
        l_adjust_charset    boolean := l_charset != l_default_charset;
        
        procedure set_bit (
            bit             in integer
        ) is
        begin
            case
                when bit between 1   and 16  then l_bitmask_word1 := mup_utl_pkg.bitor(l_bitmask_word1, power(2, 16 - bit));
                when bit between 17  and 32  then l_bitmask_word2 := mup_utl_pkg.bitor(l_bitmask_word2, power(2, 32 - bit));
                when bit between 33  and 48  then l_bitmask_word3 := mup_utl_pkg.bitor(l_bitmask_word3, power(2, 48 - bit));
                when bit between 49  and 64  then l_bitmask_word4 := mup_utl_pkg.bitor(l_bitmask_word4, power(2, 64 - bit));
                when bit between 65  and 80  then l_bitmask_word5 := mup_utl_pkg.bitor(l_bitmask_word5, power(2, 80 - bit));
                when bit between 81  and 96  then l_bitmask_word6 := mup_utl_pkg.bitor(l_bitmask_word6, power(2, 96 - bit));
                when bit between 97  and 112 then l_bitmask_word7 := mup_utl_pkg.bitor(l_bitmask_word7, power(2, 112 - bit));
                when bit between 113 and 128 then l_bitmask_word8 := mup_utl_pkg.bitor(l_bitmask_word8, power(2, 128 - bit));
                else null;
            end case;
        end;
        
        function pack_bitmask return varchar2 is
        begin
            return
                utl_raw.concat(
                    utl_raw.substr((utl_raw.cast_from_binary_integer(l_bitmask_word1)), -2)
                    , utl_raw.substr((utl_raw.cast_from_binary_integer(l_bitmask_word2)), -2)
                    , utl_raw.substr((utl_raw.cast_from_binary_integer(l_bitmask_word3)), -2)
                    , utl_raw.substr((utl_raw.cast_from_binary_integer(l_bitmask_word4)), -2)
                    , utl_raw.substr((utl_raw.cast_from_binary_integer(l_bitmask_word5)), -2)
                    , utl_raw.substr((utl_raw.cast_from_binary_integer(l_bitmask_word6)), -2)
                    , utl_raw.substr((utl_raw.cast_from_binary_integer(l_bitmask_word7)), -2)
                    , utl_raw.substr((utl_raw.cast_from_binary_integer(l_bitmask_word8)), -2)
                );
        end;
        
        function convert_data (
            data            in varchar2
        ) return varchar2 is
        begin
            if l_adjust_charset then
                return convert(data, l_charset, l_default_charset);
            else
                return data;
            end if;
        end;
        
        procedure add_field (
            i_data              in varchar2
            , i_number          in binary_integer
        ) is 
            l_data              mup_api_type_pkg.t_de_body;
        begin
            if i_data is not null and g_de.exists(i_number) then
                if g_de(i_number).format = 'N' then
                    l_data := utl_raw.cast_to_raw (
                        convert_data (
                            mup_utl_pkg.pad_number (
                                i_data          => i_data
                                , i_max_length  => g_de(i_number).max_length
                                , i_min_length  => g_de(i_number).min_length
                            )
                        )
                    );

                elsif g_de(i_number).format = 'B' then
                    l_data := i_data;   
                    trc_log_pkg.debug(
                        i_text => 'i_number [' || i_number || '] l_data [' || l_data || '] ' 
                    );
                else 
                    l_data := utl_raw.cast_to_raw (
                        convert_data (
                            mup_utl_pkg.pad_char (
                                i_data          => i_data
                                , i_max_length  => g_de(i_number).max_length
                                , i_min_length  => g_de(i_number).min_length
                            )
                        )
                    );
                end if;
                
                if g_de(i_number).prefix_length > 0 then
                
                    l_data := utl_raw.cast_to_raw(
                        convert_data (
                            mup_utl_pkg.pad_number (
                                i_data          => utl_raw.length(l_data)
                                , i_max_length  => g_de(i_number).prefix_length
                                , i_min_length  => g_de(i_number).prefix_length
                            )
                        )
                    ) || l_data;

                end if;
                
                set_bit(i_number);
                
                o_raw_data := o_raw_data || l_data;
            end if;
        end;
        
    begin
        mup_api_pds_pkg.format_pds
        (   pds_tab     => i_pds_tab
            , de048     => l_de048
            , de062     => l_de062
            , de123     => l_de123
            , de124     => l_de124
            , de125     => l_de125
        );
        
        add_field(i_de002, 2);
        add_field(format_de003(i_de003_1, i_de003_2, i_de003_3), 3);
        add_field(i_de004, 4);
        add_field(i_de005, 5);
        add_field(i_de006, 6);
        add_field(i_de009, 9);
        add_field(i_de010, 10);
        add_field(to_char(i_de012, mup_api_const_pkg.DE012_DATE_FORMAT), 12);
        add_field(to_char(i_de014, mup_api_const_pkg.DE014_DATE_FORMAT), 14);
        
        add_field(nvl(i_de022, format_de022(
            i_de022_1 
            , i_de022_2 
            , i_de022_3 
            , i_de022_4 
            , i_de022_5 
            , i_de022_6 
            , i_de022_7
            , i_de022_8
            , i_de022_9
            , i_de022_10
            , i_de022_11
        )), 22);
        
        add_field(i_de023, 23);
        add_field(i_de024, 24);
        add_field(i_de025, 25);
        add_field(i_de026, 26);
        add_field(nvl(i_de030, format_de030(i_de030_1, i_de030_2)), 30);
        add_field(i_de031, 31);
        add_field(i_de032, 32);
        add_field(i_de033, 33);
        add_field(i_de037, 37);
        add_field(i_de038, 38);
        add_field(i_de040, 40);
        add_field(i_de041, 41);
        add_field(i_de042, 42);
        add_field(nvl(i_de043, format_de043(i_de043_1, i_de043_2, i_de043_3, i_de043_4, i_de043_5, i_de043_6)), 43);
        add_field(l_de048, 48);
        add_field(i_de049, 49);
        add_field(i_de050, 50);
        add_field(i_de051, 51);
        add_field(i_de054, 54);
        add_field(rawtohex(i_de055), 55);
        add_field(l_de062, 62);
        add_field(i_de063, 63);
        add_field(i_de071, 71);
        add_field(i_de072, 72);
        add_field(to_char(i_de073, mup_api_const_pkg.DE073_DATE_FORMAT), 73);
        add_field(i_de093, 93);
        add_field(i_de094, 94);
        add_field(i_de095, 95);
        add_field(i_de100, 100);
        add_field(l_de123, 123);
        add_field(l_de124, 124);
        add_field(l_de125, 125);
        
        set_bit(1); -- bitmask2 always present;
        o_raw_data := utl_raw.cast_to_raw(convert_data(mup_utl_pkg.pad_number(i_mti, 4, 4))) || pack_bitmask || o_raw_data;
    end;

    procedure unpack_message (
        i_raw_data          in varchar2
        , o_mti             out mup_api_type_pkg.t_mti
        , o_de002           out mup_api_type_pkg.t_de002
        , o_de003_1         out mup_api_type_pkg.t_de003
        , o_de003_2         out mup_api_type_pkg.t_de003
        , o_de003_3         out mup_api_type_pkg.t_de003
        , o_de004           out mup_api_type_pkg.t_de004
        , o_de005           out mup_api_type_pkg.t_de005
        , o_de006           out mup_api_type_pkg.t_de006
        , o_de009           out mup_api_type_pkg.t_de009
        , o_de010           out mup_api_type_pkg.t_de010
        , o_de012           out mup_api_type_pkg.t_de012
        , o_de014           out mup_api_type_pkg.t_de014
        , o_de022_1         out mup_api_type_pkg.t_de022s
        , o_de022_2         out mup_api_type_pkg.t_de022s
        , o_de022_3         out mup_api_type_pkg.t_de022s
        , o_de022_4         out mup_api_type_pkg.t_de022s
        , o_de022_5         out mup_api_type_pkg.t_de022s
        , o_de022_6         out com_api_type_pkg.t_byte_char
        , o_de022_7         out mup_api_type_pkg.t_de022s
        , o_de022_8         out mup_api_type_pkg.t_de022s
        , o_de022_9         out mup_api_type_pkg.t_de022s
        , o_de022_10        out mup_api_type_pkg.t_de022s
        , o_de022_11        out mup_api_type_pkg.t_de022s
        , o_de023           out mup_api_type_pkg.t_de023
        , o_de024           out mup_api_type_pkg.t_de024
        , o_de025           out mup_api_type_pkg.t_de025
        , o_de026           out mup_api_type_pkg.t_de026
        , o_de030_1         out mup_api_type_pkg.t_de030s
        , o_de030_2         out mup_api_type_pkg.t_de030s
        , o_de031           out mup_api_type_pkg.t_de031
        , o_de032           out mup_api_type_pkg.t_de032
        , o_de033           out mup_api_type_pkg.t_de033
        , o_de037           out mup_api_type_pkg.t_de037
        , o_de038           out mup_api_type_pkg.t_de038
        , o_de040           out mup_api_type_pkg.t_de040
        , o_de041           out mup_api_type_pkg.t_de041
        , o_de042           out mup_api_type_pkg.t_de042
        , o_de043_1         out mup_api_type_pkg.t_de043
        , o_de043_2         out mup_api_type_pkg.t_de043
        , o_de043_3         out mup_api_type_pkg.t_de043
        , o_de043_4         out mup_api_type_pkg.t_de043
        , o_de043_5         out mup_api_type_pkg.t_de043
        , o_de043_6         out mup_api_type_pkg.t_de043
        , o_de048           out mup_api_type_pkg.t_de048
        , o_de049           out mup_api_type_pkg.t_de049
        , o_de050           out mup_api_type_pkg.t_de050
        , o_de051           out mup_api_type_pkg.t_de051
        , o_de054           out mup_api_type_pkg.t_de054
        , o_de055           out mup_api_type_pkg.t_de055
        , o_de062           out mup_api_type_pkg.t_de062
        , o_de063           out mup_api_type_pkg.t_de063
        , o_de071           out mup_api_type_pkg.t_de071
        , o_de072           out mup_api_type_pkg.t_de072
        , o_de073           out mup_api_type_pkg.t_de073
        , o_de093           out mup_api_type_pkg.t_de093
        , o_de094           out mup_api_type_pkg.t_de094
        , o_de095           out mup_api_type_pkg.t_de095
        , o_de100           out mup_api_type_pkg.t_de100
        , o_de123           out mup_api_type_pkg.t_de123
        , o_de124           out mup_api_type_pkg.t_de124
        , o_de125           out mup_api_type_pkg.t_de125
        , i_charset         in com_api_type_pkg.t_oracle_name
    ) is
        LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.unpack_message';
        l_de003             mup_api_type_pkg.t_de003;
        l_de022             mup_api_type_pkg.t_de022;
        l_de030             mup_api_type_pkg.t_de030;
        l_de043             mup_api_type_pkg.t_de_body;
        
        l_raw_data          com_api_type_pkg.t_raw_data;
        
        l_bitmask_word1     binary_integer := 0;
        l_bitmask_word2     binary_integer := 0;
        l_bitmask_word3     binary_integer := 0;
        l_bitmask_word4     binary_integer := 0;
        l_bitmask_word5     binary_integer := 0;
        l_bitmask_word6     binary_integer := 0;
        l_bitmask_word7     binary_integer := 0;
        l_bitmask_word8     binary_integer := 0;
        
        l_curr_pos          pls_integer;
        
        l_default_charset   com_api_type_pkg.t_oracle_name := mup_api_const_pkg.g_default_charset;
        l_charset           com_api_type_pkg.t_oracle_name := nvl(i_charset, l_default_charset);
        l_adjust_charset    boolean := l_charset != l_default_charset;

        function bit_and (
            bit             in binary_integer
        ) return binary_integer is
        begin
            case 
                when bit between 1   and 16  then return bitand(l_bitmask_word1, power(2, 16 - bit));
                when bit between 17  and 32  then return bitand(l_bitmask_word2, power(2, 32 - bit));
                when bit between 33  and 48  then return bitand(l_bitmask_word3, power(2, 48 - bit));
                when bit between 49  and 64  then return bitand(l_bitmask_word4, power(2, 64 - bit));
                when bit between 65  and 80  then return bitand(l_bitmask_word5, power(2, 80 - bit));
                when bit between 81  and 96  then return bitand(l_bitmask_word6, power(2, 96 - bit));
                when bit between 97  and 112 then return bitand(l_bitmask_word7, power(2, 112 - bit));
                when bit between 113 and 128 then return bitand(l_bitmask_word8, power(2, 128 - bit));
                else return 0;
            end case;
        end;
        
        procedure unpack_bitmask is
            l_raw_bitmask     com_api_type_pkg.t_raw_data;
        begin
            l_raw_bitmask := utl_raw.cast_to_raw(utl_raw.cast_to_varchar2(hextoraw(substr(i_raw_data, 9, 32))));
            l_curr_pos := l_curr_pos + 32;
        
            l_bitmask_word1 := utl_raw.cast_to_binary_integer(utl_raw.substr(l_raw_bitmask, 1, 2));
            l_bitmask_word2 := utl_raw.cast_to_binary_integer(utl_raw.substr(l_raw_bitmask, 3, 2));
            l_bitmask_word3 := utl_raw.cast_to_binary_integer(utl_raw.substr(l_raw_bitmask, 5, 2));
            l_bitmask_word4 := utl_raw.cast_to_binary_integer(utl_raw.substr(l_raw_bitmask, 7, 2));
            l_bitmask_word5 := utl_raw.cast_to_binary_integer(utl_raw.substr(l_raw_bitmask, 9, 2));
            l_bitmask_word6 := utl_raw.cast_to_binary_integer(utl_raw.substr(l_raw_bitmask, 11, 2));
            l_bitmask_word7 := utl_raw.cast_to_binary_integer(utl_raw.substr(l_raw_bitmask, 13, 2));
            l_bitmask_word8 := utl_raw.cast_to_binary_integer(utl_raw.substr(l_raw_bitmask, 15, 2));
        end;
        
        function convert_data (
            data            in varchar2
        ) return varchar2 is
        begin
            if l_adjust_charset then
                return convert(data, l_default_charset, l_charset);
            else
                return data;
            end if; 
        end;
        
        procedure get_field (
            o_data              out varchar2
            , i_number          in binary_integer
        ) is 
            l_de_length        pls_integer;
        begin
            if bit_and(i_number) > 0 and g_de.exists(i_number) then
                if g_de(i_number).prefix_length > 0 then
                    begin
                        l_de_length := to_number(
                                           convert_data(
                                               utl_raw.cast_to_varchar2(
                                                   hextoraw(substr(l_raw_data, l_curr_pos, g_de(i_number).prefix_length * 2))
                                               )
                                           )
                                       ) * 2;                                                               
                    exception
                        when com_api_error_pkg.e_value_error then
                            if length(
                                   utl_raw.cast_to_varchar2(
                                       hextoraw(substr(l_raw_data, l_curr_pos, g_de(i_number).prefix_length * 2))
                                   )
                               ) = 0
                               and substr(l_raw_data, l_curr_pos, g_de(i_number).prefix_length * 2) is not null
                            then
                                app_api_error_pkg.raise_error(
                                    i_appl_data_id => i_number
                                  , i_error        => 'INCORRECT_CHARSET'
                                  , i_env_param1   => i_charset
                                );
                            else
                                raise;
                            end if;
                    end;
                    l_curr_pos := l_curr_pos + g_de(i_number).prefix_length * 2;
                else
                    l_de_length := g_de(i_number).max_length * 2;
                end if;
                
                if g_de(i_number).format = 'B' then
                    o_data := utl_raw.cast_to_varchar2(hextoraw(substr(l_raw_data, l_curr_pos, l_de_length)));
                else
                    if g_de(i_number).format = 'N' then
                        o_data := mup_utl_pkg.pad_number (
                            i_data          =>
                                convert_data (
                                    utl_raw.cast_to_varchar2 (
                                        hextoraw( substr(l_raw_data, l_curr_pos, l_de_length) )
                                    )
                                )
                            , i_max_length  => g_de(i_number).max_length
                            , i_min_length  => g_de(i_number).min_length
                        );
                    else
                        o_data := mup_utl_pkg.pad_char (
                            i_data          =>
                                convert_data (
                                    utl_raw.cast_to_varchar2 (
                                        hextoraw( substr(l_raw_data, l_curr_pos, l_de_length) )
                                    )
                                )
                            , i_max_length  => g_de(i_number).max_length
                            , i_min_length  => g_de(i_number).min_length
                        );
                    end if;
                end if;

                l_curr_pos := l_curr_pos + l_de_length;
            end if;
            /*trc_log_pkg.debug(
                i_text => '->get_field: i_number [' || i_number || '], o_data [' || o_data || '], l_curr_pos [' || l_curr_pos ||']'
            );*/            
        exception
            when others then
                trc_log_pkg.debug(
                    i_text => LOG_PREFIX || '->get_field: i_number [' || i_number
                           || '], l_de_length [' || l_de_length
                           || '], l_curr_pos [' || l_curr_pos
                           || '], g_de(i_number).min_length [' || g_de(i_number).min_length
                           || '], g_de(i_number).max_length [' || g_de(i_number).max_length
                           || '], g_de(i_number).format [' || g_de(i_number).format
                           || '], g_de(i_number).prefix_length [' || g_de(i_number).prefix_length
                           || '], l_raw_data [' || l_raw_data || ']'
                );
                raise;
        end;
        
        procedure get_field_number (
            o_data              out number
            , i_number          in binary_integer
            , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
        ) is 
            l_data              mup_api_type_pkg.t_de_body;
        begin
            get_field(l_data, i_number);
            if l_data is not null and g_de.exists(i_number) then
                if g_de(i_number).format = 'N' then
                    begin
                        o_data := to_number(l_data);
                    exception
                        when com_api_error_pkg.e_invalid_number or com_api_error_pkg.e_value_error then
                            if i_mask_error = get_true then
                                trc_log_pkg.warn (
                                    i_text          => 'MUP_ERROR_WRONG_VALUE'
                                    , i_env_param1  => 'DE'||lpad(i_number, 4, '0')
                                    , i_env_param2  => 1
                                    , i_env_param3  => l_data
                                );
                            else
                                com_api_error_pkg.raise_error(
                                    i_error         => 'MUP_ERROR_WRONG_VALUE'
                                    , i_env_param1  => 'DE'||lpad(i_number, 4, '0')
                                    , i_env_param2  => 1
                                    , i_env_param3  => l_data
                                );
                            end if;
                    end;
                end if;
            end if;
            /*trc_log_pkg.debug(
                i_text => '->get_field: i_number [' || i_number || '], o_data [' || o_data || ']'
            );  */          
            
        end;
        
        procedure get_field_date (
            o_data              out date
            , i_fmt             in varchar2
            , i_number          in binary_integer
        ) is 
            l_data              mup_api_type_pkg.t_de_body;
        begin
            get_field(l_data, i_number);
            if l_data is not null and ltrim(l_data, '0') is not null then
                begin
                    if i_fmt = mup_api_const_pkg.DE073_DATE_FORMAT and substr(l_data, 5, 2) = '00' then
                        o_data := to_date(substr(l_data, 1, 4)||'01', i_fmt);
                    else
                        o_data := to_date(l_data, i_fmt);
                    end if;
                exception
                    when others then 
                        com_api_error_pkg.raise_error(
                            i_error         => 'MUP_ERROR_WRONG_VALUE'
                            , i_env_param1    => 'DE'||lpad(i_number, 4, '0')
                            , i_env_param2    => 1
                            , i_env_param3    => l_data
                        );
                end;
            end if;
            /*trc_log_pkg.debug(
                i_text => '->get_field: i_number [' || i_number || '], o_data [' || o_data || ']'
            );      */      
        end;
        
        procedure get_field_raw (
            o_data              out raw
            , i_number          in binary_integer
        ) is 
            l_data              mup_api_type_pkg.t_de_body;
        begin
            get_field(l_data, i_number);
            if l_data is not null then
                o_data := utl_raw.cast_to_raw(l_data);
            end if;
            trc_log_pkg.debug(
                i_text => '->get_field: i_number [' || i_number || '], o_data [' || o_data || ']'
            );                        
        end;
        
    begin
        -- convert to varchar
        l_raw_data := i_raw_data;
        
        -- get mti
        l_curr_pos := 1;
        o_mti := convert_data(utl_raw.cast_to_varchar2(hextoraw(substr(l_raw_data, l_curr_pos, 8))));
        l_curr_pos := l_curr_pos + 8;
        
        -- unpack bit mask
        unpack_bitmask;
        
        -- get data elements
        get_field(o_de002, 2);
        get_field(l_de003, 3);
        parse_de003 (
            i_de003            => l_de003
            , o_de003_1        => o_de003_1
            , o_de003_2        => o_de003_2
            , o_de003_3        => o_de003_3
        );
        get_field_number(o_de004, 4);
        get_field_number(o_de005, 5);
        get_field_number(o_de006, 6);
        get_field(o_de009, 9);
        get_field(o_de010, 10);
        get_field_date(o_de012, mup_api_const_pkg.DE012_DATE_FORMAT, 12);
        get_field_date(o_de014, mup_api_const_pkg.DE014_DATE_FORMAT, 14);
        o_de014 := last_day(o_de014);
        get_field(l_de022, 22);
        parse_de022 (
            i_de022             => l_de022
            , o_de022_1         => o_de022_1
            , o_de022_2         => o_de022_2
            , o_de022_3         => o_de022_3
            , o_de022_4         => o_de022_4
            , o_de022_5         => o_de022_5
            , o_de022_6         => o_de022_6
            , o_de022_7         => o_de022_7
            , o_de022_8         => o_de022_8
            , o_de022_9         => o_de022_9
            , o_de022_10        => o_de022_10
            , o_de022_11        => o_de022_11
        );
        get_field_number(o_de023, 23, get_true);
        get_field(o_de024, 24);
        get_field(o_de025, 25);
        get_field(o_de026, 26);
        get_field(l_de030, 30);
        parse_de030 (
            i_de030             => l_de030
            , o_de030_1         => o_de030_1
            , o_de030_2         => o_de030_2
        );
        get_field(o_de031, 31);
        get_field(o_de032, 32);
        get_field(o_de033, 33);
        get_field(o_de037, 37);
        get_field(o_de038, 38);
        get_field(o_de040, 40);
        get_field(o_de041, 41);
        get_field(o_de042, 42);
        get_field(l_de043, 43);
        parse_de043 (
            i_de043             => l_de043
            , o_de043_1         => o_de043_1
            , o_de043_2         => o_de043_2
            , o_de043_3         => o_de043_3
            , o_de043_4         => o_de043_4
            , o_de043_5         => o_de043_5
            , o_de043_6         => o_de043_6
        );
        get_field(o_de048, 48);
        get_field(o_de049, 49);
        get_field(o_de050, 50);
        get_field(o_de051, 51);
        get_field(o_de054, 54);
        get_field_raw(o_de055, 55);
        get_field(o_de062, 62);
        get_field(o_de063, 63);
        get_field_number(o_de071, 71);
        get_field(o_de072, 72);
        get_field_date(o_de073, mup_api_const_pkg.DE073_DATE_FORMAT, 73);
        get_field(o_de093, 93);
        get_field(o_de094, 94);
        get_field(o_de095, 95);
        get_field(o_de100, 100);
        get_field(o_de123, 123);
        get_field(o_de124, 124);
        get_field(o_de125, 125);
    end;
    
begin
    init_de_tab;
end;
/
