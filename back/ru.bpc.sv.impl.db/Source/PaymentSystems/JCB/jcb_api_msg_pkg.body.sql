create or replace package body jcb_api_msg_pkg is

    subtype t_de_rec is jcb_de%rowtype;
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
            jcb_de;
        
        g_de.delete;
        
        for i in 1 .. l_de.count loop
            g_de(l_de(i).de_number) := l_de(i);
        end loop;
        
        l_de.delete;
    end;

    function format_de003 (
        i_de003_1         in jcb_api_type_pkg.t_de003
        , i_de003_2         in jcb_api_type_pkg.t_de003
        , i_de003_3         in jcb_api_type_pkg.t_de003
    ) return jcb_api_type_pkg.t_de003 is
    begin
        if i_de003_1 is not null then
            return i_de003_1 || nvl(i_de003_2, jcb_api_const_pkg.DEFAULT_DE003_2) || nvl(i_de003_3, jcb_api_const_pkg.DEFAULT_DE003_3);
        else
            return null;
        end if;
    end;     
    
    function format_de022 (   
        i_de022_1           in jcb_api_type_pkg.t_de022s
        , i_de022_2         in jcb_api_type_pkg.t_de022s
        , i_de022_3         in jcb_api_type_pkg.t_de022s
        , i_de022_4         in jcb_api_type_pkg.t_de022s
        , i_de022_5         in jcb_api_type_pkg.t_de022s
        , i_de022_6         in jcb_api_type_pkg.t_de022s
        , i_de022_7         in jcb_api_type_pkg.t_de022s
        , i_de022_8         in jcb_api_type_pkg.t_de022s
        , i_de022_9         in jcb_api_type_pkg.t_de022s
        , i_de022_10        in jcb_api_type_pkg.t_de022s
        , i_de022_11        in jcb_api_type_pkg.t_de022s
        , i_de022_12        in jcb_api_type_pkg.t_de022s
    ) return jcb_api_type_pkg.t_de022 is
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
            or i_de022_9 is not null
            or i_de022_10 is not null
            or i_de022_11 is not null
            or i_de022_12 is not null
        ) then
            return
            (   nvl(i_de022_1, '0') ||
                nvl(i_de022_2, '9') ||
                nvl(i_de022_3, '0') ||
                nvl(i_de022_4, 'Z') ||
                nvl(i_de022_5, 'Z') ||
                nvl(i_de022_6, 'Z') ||
                nvl(i_de022_7, '0') ||
                nvl(i_de022_8, 'Z') ||
                nvl(i_de022_9, '5') ||
                nvl(i_de022_10, '0') ||
                nvl(i_de022_11, '0') ||
                nvl(i_de022_12, '1')
            );
        else
            return null;
        end if;
    end;
    
    function format_de043 (   
        i_de043_1               in jcb_api_type_pkg.t_de043
        , i_de043_2             in jcb_api_type_pkg.t_de043
        , i_de043_3             in jcb_api_type_pkg.t_de043
        , i_de043_4             in jcb_api_type_pkg.t_de043
        , i_de043_5             in jcb_api_type_pkg.t_de043
        , i_de043_6             in jcb_api_type_pkg.t_de043
    ) return jcb_api_type_pkg.t_de043 is
        l_result                jcb_api_type_pkg.t_de043;
    begin
        if (   
            i_de043_1 is not null
            or i_de043_2 is not null
            or i_de043_3 is not null
            or i_de043_4 is not null
            or i_de043_5 is not null
            or i_de043_6 is not null
        ) then
        
            l_result :=           rpad(substr(i_de043_1, 1, 25), 25, ' ');             
            l_result := l_result || rpad(substr(i_de043_2, 1, 45), 45, ' ');
            l_result := l_result || rpad(substr(i_de043_3, 1, 13), 13, ' ');
            l_result := l_result || rpad(substr(i_de043_4, 1, 10), 10, ' ');
            l_result := l_result || rpad(nvl(substr(i_de043_5, 1, 3), ' '), 3, ' ');
            l_result := l_result || rpad(nvl(substr(i_de043_6, 1, 3), ' '), 3, ' ');
            
        end if;

        return l_result;
    end;

    function format_de030 (
        i_de030_1           in jcb_api_type_pkg.t_de030_1
        , i_de030_2         in jcb_api_type_pkg.t_de030_2
    ) return jcb_api_type_pkg.t_de030 is
    begin
        if i_de030_1 is not null or i_de030_2 is not null then
            return (
                jcb_utl_pkg.pad_number(nvl(i_de030_1, 0), 12, 12)
                || jcb_utl_pkg.pad_number(nvl(i_de030_2, 0), 12, 12)
            );
        else
            return null;
        end if;
    end;    

    procedure parse_de003 (
        i_de003            in jcb_api_type_pkg.t_de003
        , o_de003_1        out jcb_api_type_pkg.t_de003
        , o_de003_2        out jcb_api_type_pkg.t_de003
        , o_de003_3        out jcb_api_type_pkg.t_de003
    ) is
    begin
        if i_de003 is not null then
            o_de003_1 := substrb(i_de003, 1, 2);
            o_de003_2 := substrb(i_de003, 3, lengthb(jcb_api_const_pkg.DEFAULT_DE003_2));
            o_de003_3 := substrb(i_de003, 5, lengthb(jcb_api_const_pkg.DEFAULT_DE003_3));
        end if;
    end;
    
    procedure parse_de022 (
        i_de022             in jcb_api_type_pkg.t_de022
        , o_de022_1         out jcb_api_type_pkg.t_de022s
        , o_de022_2         out jcb_api_type_pkg.t_de022s
        , o_de022_3         out jcb_api_type_pkg.t_de022s
        , o_de022_4         out jcb_api_type_pkg.t_de022s
        , o_de022_5         out jcb_api_type_pkg.t_de022s
        , o_de022_6         out jcb_api_type_pkg.t_de022s
        , o_de022_7         out jcb_api_type_pkg.t_de022s
        , o_de022_8         out jcb_api_type_pkg.t_de022s
        , o_de022_9         out jcb_api_type_pkg.t_de022s
        , o_de022_10        out jcb_api_type_pkg.t_de022s
        , o_de022_11        out jcb_api_type_pkg.t_de022s
        , o_de022_12        out jcb_api_type_pkg.t_de022s
    ) is
    begin
        if i_de022 is not null then
            o_de022_1 := substrb(i_de022, 1, 1);
            o_de022_2 := substrb(i_de022, 2, 1);
            o_de022_3 := substrb(i_de022, 3, 1);
            o_de022_4 := substrb(i_de022, 4, 1);
            o_de022_5 := substrb(i_de022, 5, 1);
            o_de022_6 := substrb(i_de022, 6, 1);
            o_de022_7 := substrb(i_de022, 7, 1);
            o_de022_8 := substrb(i_de022, 8, 1);
            o_de022_9 := substrb(i_de022, 9, 1);
            o_de022_10 := substrb(i_de022, 10, 1);
            o_de022_11 := substrb(i_de022, 11, 1);
            o_de022_12 := substrb(i_de022, 12, 1);
        end if;
    end;
       
    procedure parse_de043 (
        i_de043             in jcb_api_type_pkg.t_de043
        , o_de043_1         out jcb_api_type_pkg.t_de043
        , o_de043_2         out jcb_api_type_pkg.t_de043
        , o_de043_3         out jcb_api_type_pkg.t_de043
        , o_de043_4         out jcb_api_type_pkg.t_de043
        , o_de043_5         out jcb_api_type_pkg.t_de043
        , o_de043_6         out jcb_api_type_pkg.t_de043
        
    ) is
        l_curr_pos           pls_integer := 1;
    begin
        if i_de043 is not null then
        
            o_de043_1  := trim(substr(i_de043, l_curr_pos,  25));
            l_curr_pos := l_curr_pos + 25;
            o_de043_2  := trim(substr(i_de043, l_curr_pos,  45));
            l_curr_pos := l_curr_pos + 45;
            o_de043_3  := trim(substr(i_de043, l_curr_pos,  13));
            l_curr_pos := l_curr_pos + 13;
            o_de043_4  := trim(substr(i_de043, l_curr_pos,  10));
            l_curr_pos := l_curr_pos + 10;
            o_de043_5  := trim(substr(i_de043, l_curr_pos,  3));
            l_curr_pos := l_curr_pos + 3;
            o_de043_6  := trim(substr(i_de043, l_curr_pos,  3));            
        end if;
        
    end;

    procedure parse_de030 (
        i_de030             in jcb_api_type_pkg.t_de030
        , o_de030_1         out jcb_api_type_pkg.t_de030_1
        , o_de030_2         out jcb_api_type_pkg.t_de030_2
    ) is
        l_curr_pos           pls_integer;
    begin
        if i_de030 is not null then
            l_curr_pos := 1;
            o_de030_1 := to_number(substrb(i_de030, l_curr_pos, 12));
            l_curr_pos := 13;
            o_de030_2 := to_number(substrb(i_de030, l_curr_pos, 12));
        end if;
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error         => 'JCB_ERROR_WRONG_VALUE'
                , i_env_param1  => 'DE030'
                , i_env_param2  => l_curr_pos
                , i_env_param3  => i_de030
            );
    end;

    function pack_message (
        i_pds_tab         in jcb_api_type_pkg.t_pds_tab
        , i_mti             in jcb_api_type_pkg.t_mti
        , i_de002           in jcb_api_type_pkg.t_de002 := null 
        , i_de003_1         in jcb_api_type_pkg.t_de003s := null 
        , i_de003_2         in jcb_api_type_pkg.t_de003s := null
        , i_de003_3         in jcb_api_type_pkg.t_de003s := null
        , i_de004           in jcb_api_type_pkg.t_de004 := null
        , i_de005           in jcb_api_type_pkg.t_de005 := null
        , i_de006           in jcb_api_type_pkg.t_de006 := null
        , i_de009           in jcb_api_type_pkg.t_de009 := null
        , i_de010           in jcb_api_type_pkg.t_de010 := null
        , i_de012           in jcb_api_type_pkg.t_de012 := null
        , i_de014           in jcb_api_type_pkg.t_de014 := null
        , i_de016           in jcb_api_type_pkg.t_de016 := null
        , i_de022           in jcb_api_type_pkg.t_de022 := null 
        , i_de022_1         in jcb_api_type_pkg.t_de022s := null
        , i_de022_2         in jcb_api_type_pkg.t_de022s := null
        , i_de022_3         in jcb_api_type_pkg.t_de022s := null
        , i_de022_4         in jcb_api_type_pkg.t_de022s := null
        , i_de022_5         in jcb_api_type_pkg.t_de022s := null
        , i_de022_6         in jcb_api_type_pkg.t_de022s := null
        , i_de022_7         in jcb_api_type_pkg.t_de022s := null
        , i_de022_8         in jcb_api_type_pkg.t_de022s := null
        , i_de022_9         in jcb_api_type_pkg.t_de022s := null
        , i_de022_10        in jcb_api_type_pkg.t_de022s := null
        , i_de022_11        in jcb_api_type_pkg.t_de022s := null
        , i_de022_12        in jcb_api_type_pkg.t_de022s := null
        , i_de023           in jcb_api_type_pkg.t_de023 := null
        , i_de024           in jcb_api_type_pkg.t_de024 := null
        , i_de025           in jcb_api_type_pkg.t_de025 := null
        , i_de026           in jcb_api_type_pkg.t_de026 := null
        , i_de030_1         in jcb_api_type_pkg.t_de030_1 := null
        , i_de030_2         in jcb_api_type_pkg.t_de030_2 := null
        , i_de031           in jcb_api_type_pkg.t_de031 := null
        , i_de032           in jcb_api_type_pkg.t_de032 := null
        , i_de033           in jcb_api_type_pkg.t_de033 := null
        , i_de037           in jcb_api_type_pkg.t_de037 := null
        , i_de038           in jcb_api_type_pkg.t_de038 := null
        , i_de040           in jcb_api_type_pkg.t_de040 := null
        , i_de041           in jcb_api_type_pkg.t_de041 := null
        , i_de042           in jcb_api_type_pkg.t_de042 := null
        , i_de043           in jcb_api_type_pkg.t_de043 := null 
        , i_de043_1         in jcb_api_type_pkg.t_de043 := null
        , i_de043_2         in jcb_api_type_pkg.t_de043 := null
        , i_de043_3         in jcb_api_type_pkg.t_de043 := null
        , i_de043_4         in jcb_api_type_pkg.t_de043 := null
        , i_de043_5         in jcb_api_type_pkg.t_de043 := null
        , i_de043_6         in jcb_api_type_pkg.t_de043 := null
        , i_de049           in jcb_api_type_pkg.t_de049 := null
        , i_de050           in jcb_api_type_pkg.t_de050 := null
        , i_de051           in jcb_api_type_pkg.t_de051 := null
        , i_de054           in jcb_api_type_pkg.t_de054 := null
        , i_de055           in jcb_api_type_pkg.t_de055 := null
        , i_de071           in jcb_api_type_pkg.t_de071 := null
        , i_de072           in jcb_api_type_pkg.t_de072 := null
        , i_de093           in jcb_api_type_pkg.t_de093 := null
        , i_de094           in jcb_api_type_pkg.t_de094 := null
        , i_de097           in jcb_api_type_pkg.t_de097 := null
        , i_de100           in jcb_api_type_pkg.t_de100 := null    
        , i_with_rdw        in com_api_type_pkg.t_boolean := null
    ) return blob is
        l_de048             jcb_api_type_pkg.t_de048;
        l_de062             jcb_api_type_pkg.t_de062;
        l_de123             jcb_api_type_pkg.t_de123;
        l_de124             jcb_api_type_pkg.t_de124;
        l_de125             jcb_api_type_pkg.t_de125;
        l_de126             jcb_api_type_pkg.t_de126;
        l_raw_data          blob;
        l_msg_body          blob;
        l_msg_length        blob;
        
        l_bitmask_word1     binary_integer := 0;
        l_bitmask_word2     binary_integer := 0;
        l_bitmask_word3     binary_integer := 0;
        l_bitmask_word4     binary_integer := 0;
        l_bitmask_word5     binary_integer := 0;
        l_bitmask_word6     binary_integer := 0;
        l_bitmask_word7     binary_integer := 0;
        l_bitmask_word8     binary_integer := 0;
        
        procedure set_bit (
            bit             in integer
        ) is
        begin
            case
                when bit between 1   and 16  then l_bitmask_word1 := jcb_utl_pkg.bitor(l_bitmask_word1, power(2, 16 - bit));
                when bit between 17  and 32  then l_bitmask_word2 := jcb_utl_pkg.bitor(l_bitmask_word2, power(2, 32 - bit));
                when bit between 33  and 48  then l_bitmask_word3 := jcb_utl_pkg.bitor(l_bitmask_word3, power(2, 48 - bit));
                when bit between 49  and 64  then l_bitmask_word4 := jcb_utl_pkg.bitor(l_bitmask_word4, power(2, 64 - bit));
                when bit between 65  and 80  then l_bitmask_word5 := jcb_utl_pkg.bitor(l_bitmask_word5, power(2, 80 - bit));
                when bit between 81  and 96  then l_bitmask_word6 := jcb_utl_pkg.bitor(l_bitmask_word6, power(2, 96 - bit));
                when bit between 97  and 112 then l_bitmask_word7 := jcb_utl_pkg.bitor(l_bitmask_word7, power(2, 112 - bit));
                when bit between 113 and 128 then l_bitmask_word8 := jcb_utl_pkg.bitor(l_bitmask_word8, power(2, 128 - bit));
                else null;
            end case;
        end;
        
        function pack_bitmask return blob is
        begin
            trc_log_pkg.debug (
                i_text          => 'l_bitmask_word1 = '  || l_bitmask_word1 
                                || ', l_bitmask_word2 = '|| l_bitmask_word2
                                || ', l_bitmask_word3 = '|| l_bitmask_word3
                                || ', l_bitmask_word4 = '|| l_bitmask_word4
                                || ', l_bitmask_word5 = '|| l_bitmask_word5
                                || ', l_bitmask_word6 = '|| l_bitmask_word6
                                || ', l_bitmask_word7 = '|| l_bitmask_word7
                                || ', l_bitmask_word8 = '|| l_bitmask_word8
            );

            trc_log_pkg.debug (
                i_text          =>  'bitmask = ' || 
                rawtohex(utl_raw.concat(
                    utl_raw.substr((utl_raw.cast_from_binary_integer(l_bitmask_word1)), -2)
                    , utl_raw.substr((utl_raw.cast_from_binary_integer(l_bitmask_word2)), -2)
                    , utl_raw.substr((utl_raw.cast_from_binary_integer(l_bitmask_word3)), -2)
                    , utl_raw.substr((utl_raw.cast_from_binary_integer(l_bitmask_word4)), -2)
                    , utl_raw.substr((utl_raw.cast_from_binary_integer(l_bitmask_word5)), -2)
                    , utl_raw.substr((utl_raw.cast_from_binary_integer(l_bitmask_word6)), -2)
                    , utl_raw.substr((utl_raw.cast_from_binary_integer(l_bitmask_word7)), -2)
                    , utl_raw.substr((utl_raw.cast_from_binary_integer(l_bitmask_word8)), -2)
                ))
            );
        
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
        
        procedure add_field (
            i_data              in varchar2
            , i_number          in binary_integer
        ) is 
            l_data              blob; 
        begin
            trc_log_pkg.debug (
                i_text          => 'add_field ' || i_number
            );
        
            if i_data is not null and g_de.exists(i_number) then
                if g_de(i_number).format = 'N' then
                    l_data := utl_raw.cast_to_raw (
                        jcb_utl_pkg.pad_number (
                            i_data          => i_data
                            , i_max_length  => g_de(i_number).max_length
                            , i_min_length  => g_de(i_number).min_length
                        )
                    );

                elsif g_de(i_number).format = 'B' then
                    l_data := hextoraw(i_data);-- utl_raw.cast_to_raw (i_data);   

                else 
                    l_data := utl_raw.cast_to_raw (
                        jcb_utl_pkg.pad_char (
                            i_data          => i_data
                            , i_max_length  => g_de(i_number).max_length
                            , i_min_length  => g_de(i_number).min_length
                        )
                    );
                end if;
                
                if g_de(i_number).prefix_length > 0 then

                    dbms_lob.append(l_msg_body, utl_raw.cast_to_raw(
                                                    jcb_utl_pkg.pad_number (
                                                        i_data          => utl_raw.length(l_data)
                                                        , i_max_length  => g_de(i_number).prefix_length
                                                        , i_min_length  => g_de(i_number).prefix_length
                                                    )
                    ));
                end if;
                
                set_bit(i_number);
                
                dbms_lob.append(l_msg_body, l_data);
            end if;
        end;
        
    begin
        trc_log_pkg.debug (
            i_text          => 'pack_message start, i_with_rdw = ' || i_with_rdw 
        );
        
        dbms_lob.createtemporary(l_raw_data, true);
        dbms_lob.createtemporary(l_msg_body, true);
        
        trc_log_pkg.debug (
            i_text          => 'l_raw_data init'
        );

        dbms_lob.append(l_raw_data, utl_raw.cast_to_raw(jcb_utl_pkg.pad_number(i_mti, 4, 4)));
        trc_log_pkg.debug (
            i_text          => 'l_raw_data append mti'
        );
         
        jcb_api_pds_pkg.format_pds (
              pds_tab   => i_pds_tab
            , de048     => l_de048
            , de062     => l_de062
            , de123     => l_de123
            , de124     => l_de124
            , de125     => l_de125
            , de126     => l_de126
        );
        trc_log_pkg.debug (
            i_text          => 'l_de048 = ' || l_de048
        );
        
        add_field(i_de002, 2);
        add_field(format_de003(i_de003_1, i_de003_2, i_de003_3), 3);
        add_field(i_de004, 4);
        add_field(i_de005, 5);
        add_field(i_de006, 6);
        add_field(i_de009, 9);
        add_field(i_de010, 10);
        add_field(to_char(i_de012, jcb_api_const_pkg.DE012_DATE_FORMAT), 12);
        add_field(to_char(i_de014, jcb_api_const_pkg.DE014_DATE_FORMAT), 14);
        add_field(to_char(i_de016, jcb_api_const_pkg.DE016_DATE_FORMAT), 16);
        
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
            , i_de022_12
        )), 22);
        
        add_field(i_de023, 23);
        add_field(i_de024, 24);
        add_field(i_de025, 25);
        add_field(i_de026, 26);
        add_field(format_de030(i_de030_1, i_de030_2), 30);
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
        add_field(i_de071, 71);
        add_field(i_de072, 72);
        add_field(i_de093, 93);
        add_field(i_de094, 94);
        add_field(i_de100, 100);
        add_field(l_de123, 123);
        add_field(l_de124, 124);
        add_field(l_de125, 125);
        add_field(l_de126, 126);
       
        set_bit(1); -- bitmask2 always present;
        dbms_lob.append(l_raw_data, pack_bitmask);
        trc_log_pkg.debug (
            i_text          => 'l_raw_data append bitmask'
        );

        dbms_lob.append(l_raw_data, l_msg_body);
        trc_log_pkg.debug (
            i_text          => 'l_raw_data append body'
        );
    
        -- if need to add rdw
        if nvl(i_with_rdw, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then 

            dbms_lob.createtemporary(l_msg_length, true);
            
            dbms_lob.append(l_msg_length, utl_raw.cast_from_binary_integer(utl_raw.length(l_raw_data)));
            
            dbms_lob.append(l_msg_length, l_raw_data);

            trc_log_pkg.debug (
                i_text          => 'length of message = '|| utl_raw.cast_to_varchar2(l_msg_length)
            );
            
            dbms_lob.freetemporary(l_msg_body); 
            dbms_lob.freetemporary(l_raw_data); 
            
            return l_msg_length;
        else
            dbms_lob.freetemporary(l_msg_body); 
            
            trc_log_pkg.debug (
                i_text          => 'pack_message end. Length l_raw_data = ' || dbms_lob.getlength(l_raw_data)
            );
            return l_raw_data;
            
        end if;
    
    end;

    procedure unpack_message (
        i_file              in blob
        , i_with_rdw        in com_api_type_pkg.t_boolean    default null
        , io_curr_pos       in out nocopy com_api_type_pkg.t_long_id
        , o_mti             out jcb_api_type_pkg.t_mti
        , o_de002           out jcb_api_type_pkg.t_de002  
        , o_de003_1         out jcb_api_type_pkg.t_de003s 
        , o_de003_2         out jcb_api_type_pkg.t_de003s
        , o_de003_3         out jcb_api_type_pkg.t_de003s
        , o_de004           out jcb_api_type_pkg.t_de004
        , o_de005           out jcb_api_type_pkg.t_de005
        , o_de006           out jcb_api_type_pkg.t_de006
        , o_de009           out jcb_api_type_pkg.t_de009
        , o_de010           out jcb_api_type_pkg.t_de010
        , o_de012           out jcb_api_type_pkg.t_de012
        , o_de014           out jcb_api_type_pkg.t_de014
        , o_de016           out jcb_api_type_pkg.t_de016
        , o_de022_1         out jcb_api_type_pkg.t_de022s
        , o_de022_2         out jcb_api_type_pkg.t_de022s
        , o_de022_3         out jcb_api_type_pkg.t_de022s
        , o_de022_4         out jcb_api_type_pkg.t_de022s
        , o_de022_5         out jcb_api_type_pkg.t_de022s
        , o_de022_6         out jcb_api_type_pkg.t_de022s
        , o_de022_7         out jcb_api_type_pkg.t_de022s
        , o_de022_8         out jcb_api_type_pkg.t_de022s
        , o_de022_9         out jcb_api_type_pkg.t_de022s
        , o_de022_10        out jcb_api_type_pkg.t_de022s
        , o_de022_11        out jcb_api_type_pkg.t_de022s
        , o_de022_12        out jcb_api_type_pkg.t_de022s
        , o_de023           out jcb_api_type_pkg.t_de023
        , o_de024           out jcb_api_type_pkg.t_de024
        , o_de025           out jcb_api_type_pkg.t_de025
        , o_de026           out jcb_api_type_pkg.t_de026
        , o_de030_1         out jcb_api_type_pkg.t_de030_1
        , o_de030_2         out jcb_api_type_pkg.t_de030_2
        , o_de031           out jcb_api_type_pkg.t_de031
        , o_de032           out jcb_api_type_pkg.t_de032
        , o_de033           out jcb_api_type_pkg.t_de033
        , o_de037           out jcb_api_type_pkg.t_de037
        , o_de038           out jcb_api_type_pkg.t_de038
        , o_de040           out jcb_api_type_pkg.t_de040
        , o_de041           out jcb_api_type_pkg.t_de041
        , o_de042           out jcb_api_type_pkg.t_de042
        , o_de043_1         out jcb_api_type_pkg.t_de043
        , o_de043_2         out jcb_api_type_pkg.t_de043
        , o_de043_3         out jcb_api_type_pkg.t_de043
        , o_de043_4         out jcb_api_type_pkg.t_de043
        , o_de043_5         out jcb_api_type_pkg.t_de043
        , o_de043_6         out jcb_api_type_pkg.t_de043
        , o_de048           out jcb_api_type_pkg.t_de048
        , o_de049           out jcb_api_type_pkg.t_de049
        , o_de050           out jcb_api_type_pkg.t_de050
        , o_de051           out jcb_api_type_pkg.t_de051
        , o_de054           out jcb_api_type_pkg.t_de054
        , o_de055           out jcb_api_type_pkg.t_de055
        , o_de062           out jcb_api_type_pkg.t_de062
        , o_de071           out jcb_api_type_pkg.t_de071
        , o_de072           out jcb_api_type_pkg.t_de072
        , o_de093           out jcb_api_type_pkg.t_de093
        , o_de094           out jcb_api_type_pkg.t_de094
        , o_de097           out jcb_api_type_pkg.t_de097
        , o_de100           out jcb_api_type_pkg.t_de100    
        , o_de123           out jcb_api_type_pkg.t_de123    
        , o_de124           out jcb_api_type_pkg.t_de124    
        , o_de125           out jcb_api_type_pkg.t_de125    
        , o_de126           out jcb_api_type_pkg.t_de126    
    ) is
        LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.unpack_message';
        l_de003             jcb_api_type_pkg.t_de003;
        l_de022             jcb_api_type_pkg.t_de022;
        l_de043             jcb_api_type_pkg.t_de_body;
        l_de030             jcb_api_type_pkg.t_de043;
        
        l_bitmask_word1     binary_integer := 0;
        l_bitmask_word2     binary_integer := 0;
        l_bitmask_word3     binary_integer := 0;
        l_bitmask_word4     binary_integer := 0;
        l_bitmask_word5     binary_integer := 0;
        l_bitmask_word6     binary_integer := 0;
        l_bitmask_word7     binary_integer := 0;
        l_bitmask_word8     binary_integer := 0;
        
        l_raw_data    raw(4096);
        l_msg_length  raw(8);

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
            l_raw_bitmask     raw(16);--com_api_type_pkg.t_raw_data;
        begin       
            l_raw_bitmask   := dbms_lob.substr(i_file, 16, io_curr_pos);
            io_curr_pos     := io_curr_pos + 16;
            trc_log_pkg.debug (
                i_text          => 'l_raw_bitmask = '  || rawtohex(l_raw_bitmask) 
            );     
               
            l_bitmask_word1 := utl_raw.cast_to_binary_integer(utl_raw.substr(l_raw_bitmask, 1, 2));
            l_bitmask_word2 := utl_raw.cast_to_binary_integer(utl_raw.substr(l_raw_bitmask, 3, 2));
            l_bitmask_word3 := utl_raw.cast_to_binary_integer(utl_raw.substr(l_raw_bitmask, 5, 2));
            l_bitmask_word4 := utl_raw.cast_to_binary_integer(utl_raw.substr(l_raw_bitmask, 7, 2));
            l_bitmask_word5 := utl_raw.cast_to_binary_integer(utl_raw.substr(l_raw_bitmask, 9, 2));
            l_bitmask_word6 := utl_raw.cast_to_binary_integer(utl_raw.substr(l_raw_bitmask, 11, 2));
            l_bitmask_word7 := utl_raw.cast_to_binary_integer(utl_raw.substr(l_raw_bitmask, 13, 2));
            l_bitmask_word8 := utl_raw.cast_to_binary_integer(utl_raw.substr(l_raw_bitmask, 15, 2));

            trc_log_pkg.debug (
                i_text          => 'l_bitmask_word1 = '  || l_bitmask_word1 
                                || ', l_bitmask_word2 = '|| l_bitmask_word2
                                || ', l_bitmask_word3 = '|| l_bitmask_word3
                                || ', l_bitmask_word4 = '|| l_bitmask_word4
                                || ', l_bitmask_word5 = '|| l_bitmask_word5
                                || ', l_bitmask_word6 = '|| l_bitmask_word6
                                || ', l_bitmask_word7 = '|| l_bitmask_word7
                                || ', l_bitmask_word8 = '|| l_bitmask_word8
            );
            
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
                        l_raw_data  := dbms_lob.substr(i_file, g_de(i_number).prefix_length, io_curr_pos);

                        if i_number in (100) then
                            trc_log_pkg.debug (
                                i_text          => 'length for Bit 100 = ' || utl_raw.cast_to_varchar2(l_raw_data)
                            );
                        end if;

                        l_de_length := to_number(utl_raw.cast_to_varchar2(l_raw_data));
                        
                    exception
                        when com_api_error_pkg.e_value_error then
                            if length(utl_raw.cast_to_varchar2(l_raw_data)) != 0
                                and utl_raw.cast_to_varchar2(l_raw_data) is not null
                            then
                                com_api_error_pkg.raise_error(
                                    i_error        => 'INCORRECT_CHARSET'
                                  , i_env_param1   => i_number
                                );
                            else
                                trc_log_pkg.debug (
                                    i_text          => 'l_de_length = [#1], io_curr_pos = [#2]'
                                    , i_env_param1  => utl_raw.cast_to_varchar2(l_raw_data)
                                    , i_env_param2  => io_curr_pos
                                );
                            
                                raise;
                            end if;
                    end;
                    io_curr_pos := io_curr_pos + g_de(i_number).prefix_length;
                    
                else
                    l_de_length := g_de(i_number).max_length;                    
                end if;
                
                -- read blob and inc l_cur_pos
                l_raw_data  := dbms_lob.substr(i_file, l_de_length, io_curr_pos);
                
                if g_de(i_number).format = 'B' then

                    o_data := utl_raw.cast_to_varchar2(l_raw_data);
                else
                    if g_de(i_number).format = 'N' then
                        o_data := jcb_utl_pkg.pad_number (
                            i_data          => utl_raw.cast_to_varchar2(l_raw_data)
                            , i_max_length  => g_de(i_number).max_length
                            , i_min_length  => g_de(i_number).min_length
                        );
                    else
                        o_data := jcb_utl_pkg.pad_char (
                            i_data          => utl_raw.cast_to_varchar2(l_raw_data)
                            , i_max_length  => g_de(i_number).max_length
                            , i_min_length  => g_de(i_number).min_length
                        );
                    end if;
                end if;

                io_curr_pos := io_curr_pos + l_de_length;

                trc_log_pkg.debug (
                    i_text          => 'Bit number = '  || i_number || ', o_data = [' || o_data || ']' 
                );     

            end if;
        exception
            when others then
                trc_log_pkg.debug(
                    i_text => LOG_PREFIX || '->get_field: i_number [' || i_number
                           || '], l_de_length [' || l_de_length
                           || '], l_curr_pos [' || io_curr_pos
                           || '], g_de(i_number).min_length [' || g_de(i_number).min_length
                           || '], g_de(i_number).max_length [' || g_de(i_number).max_length
                           || '], g_de(i_number).format [' || g_de(i_number).format
                           || '], g_de(i_number).prefix_length [' || g_de(i_number).prefix_length
                           || '], l_raw_data [' || utl_raw.cast_to_varchar2(l_raw_data) || ']'
                );
                raise;
        end;
        
        procedure get_field_number (
            o_data              out number
            , i_number          in binary_integer
            , i_mask_error      in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
        ) is 
            l_data              jcb_api_type_pkg.t_de_body;
        begin
            get_field(l_data, i_number);
            if l_data is not null and g_de.exists(i_number) then
                if g_de(i_number).format = 'N' then
                    begin
                        o_data := to_number(l_data);
                    exception
                        when com_api_error_pkg.e_invalid_number or com_api_error_pkg.e_value_error then
                            if i_mask_error = com_api_type_pkg.TRUE then
                                trc_log_pkg.warn (
                                    i_text          => 'JCB_ERROR_WRONG_VALUE'
                                    , i_env_param1  => 'DE'||lpad(i_number, 4, '0')
                                    , i_env_param2  => 1
                                    , i_env_param3  => l_data
                                );
                            else
                                com_api_error_pkg.raise_error(
                                    i_error         => 'JCB_ERROR_WRONG_VALUE'
                                    , i_env_param1  => 'DE'||lpad(i_number, 4, '0')
                                    , i_env_param2  => 1
                                    , i_env_param3  => l_data
                                );
                            end if;
                    end;
                end if;
            end if;
        end;
        
        procedure get_field_date (
            o_data              out date
          , i_fmt             in varchar2
          , i_number          in binary_integer
          , i_nulltrim        in     binary_integer   default null
        ) is 
            l_data              jcb_api_type_pkg.t_de_body;
        begin
            get_field(l_data, i_number);
            if l_data is not null and ltrim(l_data, '0') is not null
                and (   (i_nulltrim is not null
                            and ltrim(substr(l_data, 1, i_nulltrim), '0') is not null
                        )
                        or i_nulltrim is null
                    )
            then
                begin
                    o_data := to_date(l_data, i_fmt);
                exception
                    when others then 
                        com_api_error_pkg.raise_error(
                            i_error           => 'JCB_ERROR_WRONG_VALUE'
                            , i_env_param1    => 'DE'||lpad(i_number, 4, '0')
                            , i_env_param2    => 1
                            , i_env_param3    => l_data
                        );
                end;
            end if;
        end;
        
        procedure get_field_raw (
            o_data              out raw
            , i_number          in binary_integer
        ) is 
            l_data              jcb_api_type_pkg.t_de_body;
        begin
            get_field(l_data, i_number);
            if l_data is not null then
                o_data := utl_raw.cast_to_raw(l_data);
            end if;
        end;
        
    begin
        trc_log_pkg.debug (
            i_text          => 'start unpack message. io_curr_pos='||io_curr_pos || ', i_with_rdw = ' || i_with_rdw
        );
        
        if nvl(i_with_rdw, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then 

            l_msg_length:= dbms_lob.substr(i_file, 4, io_curr_pos);
            io_curr_pos := io_curr_pos + 4;

            trc_log_pkg.debug (
                i_text          => 'length of message = '|| utl_raw.cast_to_varchar2(l_msg_length) || '. io_curr_pos='||io_curr_pos
            );
            
        end if;
        
        l_raw_data  := dbms_lob.substr(i_file, 4, io_curr_pos);
        o_mti       := utl_raw.cast_to_varchar2(l_raw_data);
        io_curr_pos := io_curr_pos + 4;
        
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
        get_field_date(o_de012, jcb_api_const_pkg.DE012_DATE_FORMAT, 12, 6);
        get_field_date(o_de014, jcb_api_const_pkg.DE014_DATE_FORMAT, 14);
        o_de014 := last_day(o_de014);
        get_field_date(o_de016, jcb_api_const_pkg.DE016_DATE_FORMAT, 16);
        get_field(l_de022, 22);
        parse_de022 (
            i_de022         => l_de022
            , o_de022_1     => o_de022_1
            , o_de022_2     => o_de022_2
            , o_de022_3     => o_de022_3
            , o_de022_4     => o_de022_4
            , o_de022_5     => o_de022_5
            , o_de022_6     => o_de022_6
            , o_de022_7     => o_de022_7
            , o_de022_8     => o_de022_8
            , o_de022_9     => o_de022_9
            , o_de022_10    => o_de022_10
            , o_de022_11    => o_de022_11
            , o_de022_12    => o_de022_12
        );
        get_field_number(o_de023, 23, com_api_type_pkg.TRUE);
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
        get_field_number(o_de071, 71);
        get_field(o_de072, 72);
        get_field(o_de093, 93);
        get_field(o_de094, 94);
        get_field(o_de097, 97);
        get_field(o_de100, 100);
        get_field(o_de123, 123);
        get_field(o_de124, 124);
        get_field(o_de125, 125);
        get_field(o_de126, 126);
        
        --skip line break
        while utl_raw.cast_to_binary_integer(dbms_lob.substr(i_file, 1, io_curr_pos)) in (10, 13) loop
            io_curr_pos := io_curr_pos + 1;
        end loop;        
        
        trc_log_pkg.debug (
            i_text          => 'end unpack message'
        );
        
    end;
    
begin
    init_de_tab;
end;
/
