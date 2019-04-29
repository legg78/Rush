create or replace package body mup_api_pds_pkg is

    subtype t_pds_rec is mup_pds%rowtype;
    type t_pds_tab is table of t_pds_rec index by binary_integer;
    
    g_pds t_pds_tab;
    
    procedure init_pds_tab is
        l_pds t_pds_tab;
    begin
        select 
            pds_number
            , name
            , upper(format)
            , min_length
            , max_length
            , subfield_count
        bulk collect into 
            l_pds
        from 
            mup_pds
        where max_length > 0;
        
        g_pds.delete;
        
        for i in 1 .. l_pds.count loop
            g_pds(l_pds(i).pds_number) := l_pds(i);
        end loop;
        
        l_pds.delete;
    end;
    
    function format_pds_tag (   
        i_pds_tag               in mup_api_type_pkg.t_pds_tag
    ) return mup_api_type_pkg.t_pds_tag_chr is
    begin
        return mup_utl_pkg.pad_number (
            i_data          => i_pds_tag
            , i_max_length  => mup_api_const_pkg.PDS_TAG_LEN
            , i_min_length  => mup_api_const_pkg.PDS_TAG_LEN
        );
    end;
    
    function format_pds_len (
        i_pds_len                 in mup_api_type_pkg.t_pds_len
    ) return mup_api_type_pkg.t_pds_len_chr is
    begin
        return mup_utl_pkg.pad_number (
            i_data          => i_pds_len
            , i_max_length  => mup_api_const_pkg.PDS_LENGTH_LEN
            , i_min_length  => mup_api_const_pkg.PDS_LENGTH_LEN
        );
    end;
    
    function format_pds_body (
        i_data                  in mup_api_type_pkg.t_pds_body
        , i_number              in binary_integer
    ) return mup_api_type_pkg.t_pds_body is
    begin
        if i_data is not null and g_pds.exists(i_number) then
            if g_pds(i_number).format = 'N' then
                return mup_utl_pkg.pad_number (
                    i_data          => i_data
                    , i_max_length  => g_pds(i_number).max_length
                    , i_min_length  => g_pds(i_number).min_length
                );

            elsif g_pds(i_number).format = 'B' then
                return i_data;   

            else 
                return mup_utl_pkg.pad_char (
                    i_data          => i_data
                    , i_max_length  => g_pds(i_number).max_length
                    , i_min_length  => g_pds(i_number).min_length
                );
            end if;
        else
            return null;
        end if;
    end;
    
    procedure extract_pds
    (   de048                   in mup_api_type_pkg.t_de048
        , de062                 in mup_api_type_pkg.t_de062
        , de123                 in mup_api_type_pkg.t_de123
        , de124                 in mup_api_type_pkg.t_de124
        , de125                 in mup_api_type_pkg.t_de125
        , pds_tab               in out nocopy mup_api_type_pkg.t_pds_tab
    ) is
        de_body                 mup_api_type_pkg.t_de048;
        de_length               integer;
        curr_pos                integer;
        pds_tag                 mup_api_type_pkg.t_pds_tag;
        pds_len                 mup_api_type_pkg.t_pds_len;
        pds_body                mup_api_type_pkg.t_pds_body;
        de_name                 varchar2(5);   
        curr_body               mup_api_type_pkg.t_pds_body;
    begin
        pds_tab.delete;

        for i in 1 .. 5 loop
            case 
                when i = 1 then begin de_body := de048; de_name := 'DE048'; end;
                when i = 2 then begin de_body := de062; de_name := 'DE062'; end;
                when i = 3 then begin de_body := de123; de_name := 'DE123'; end;
                when i = 4 then begin de_body := de124; de_name := 'DE124'; end;
                when i = 5 then begin de_body := de125; de_name := 'DE125'; end;
            end case;

            if de_body is null then 
                exit;
            else
                curr_pos := 1;
                de_length := length(de_body);

                loop
                    exit when curr_pos > de_length;

                    curr_body := substr(de_body, curr_pos, mup_api_const_pkg.PDS_TAG_LEN);
                    if length(curr_body) = mup_api_const_pkg.PDS_TAG_LEN then
                        begin
                            pds_tag := to_number(curr_body);
                        exception
                            when com_api_error_pkg.e_invalid_number or com_api_error_pkg.e_value_error then
                                com_api_error_pkg.raise_error(
                                    i_error         => 'PDS_ERROR_WRONG_TAG'
                                  , i_env_param1    => de_name
                                  , i_env_param2    => curr_pos
                                  , i_env_param3    => de_body
                                );
                        end;
                        curr_pos := curr_pos + mup_api_const_pkg.PDS_TAG_LEN;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'PDS_ERROR_WRONG_TAG'
                          , i_env_param1    => de_name
                          , i_env_param2    => curr_pos
                          , i_env_param3    => de_body
                        );
                    end if;

                    curr_body := substr(de_body, curr_pos, mup_api_const_pkg.PDS_LENGTH_LEN);
                    if length(curr_body) = mup_api_const_pkg.PDS_LENGTH_LEN then
                        begin
                            pds_len := to_number(curr_body);
                        exception
                            when com_api_error_pkg.e_invalid_number or com_api_error_pkg.e_value_error then
                                com_api_error_pkg.raise_error(
                                    i_error         => 'PDS_ERROR_WRONG_LENGTH'
                                  , i_env_param1    => de_name
                                  , i_env_param2    => curr_pos
                                  , i_env_param3    => de_body
                                );
                        
                        end;
                        curr_pos := curr_pos + mup_api_const_pkg.PDS_LENGTH_LEN;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'PDS_ERROR_WRONG_LENGTH'
                          , i_env_param1    => de_name
                          , i_env_param2    => curr_pos
                          , i_env_param3    => de_body
                        );
                    end if;

                    curr_body := substr(de_body, curr_pos, pds_len);
                    if length(curr_body) = pds_len then
                        pds_body := curr_body;
                        curr_pos := curr_pos + pds_len; 
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'PDS_ERROR_WRONG_BODY'
                          , i_env_param1    => de_name
                          , i_env_param2    => curr_pos
                          , i_env_param3    => pds_len
                          , i_env_param4    => de_body
                        );
                    end if;

                    pds_tab(pds_tag) := pds_body;
                end loop;
            end if;
        end loop;
    end;

    procedure format_pds
    (   pds_tab                 in mup_api_type_pkg.t_pds_tab
        , de048                 out mup_api_type_pkg.t_de048
        , de062                 out mup_api_type_pkg.t_de062
        , de123                 out mup_api_type_pkg.t_de123
        , de124                 out mup_api_type_pkg.t_de124
        , de125                 out mup_api_type_pkg.t_de125
    ) is
        i                       binary_integer;
        used_de                 integer := 0;
        de_body                 mup_api_type_pkg.t_de048;
        pds_str                 mup_api_type_pkg.t_de_body;
        pds_body                mup_api_type_pkg.t_pds_body;
    begin
        if pds_tab.count > 0 then
            i := pds_tab.first; 
            loop
                if pds_tab(i) is not null then
                    pds_body := format_pds_body (
                        i_data          => pds_tab(i)
                        , i_number        => i
                    );
                    
                    if pds_body is not null then
                        pds_str := (
                            format_pds_tag(i)
                            || format_pds_len(length(pds_body))
                            || pds_body
                        );

                        if nvl(length(de_body), 0) + length(pds_str) > mup_api_const_pkg.MAX_PDS_DE_LEN then

                            case
                                when used_de = 0 then de048 := de_body;
                                when used_de = 1 then de062 := de_body;
                                when used_de = 2 then de123 := de_body;
                                when used_de = 3 then de124 := de_body;
                                when used_de = 4 then
                                    com_api_error_pkg.raise_error(
                                        i_error         => 'PDS_ERROR_TOO_MANY'
                                    );

                            end case;

                            used_de := used_de + 1;
                            de_body := null;
                        end if;

                        de_body := de_body || pds_str;
                    end if;
                end if;

                i := pds_tab.next(i);
                exit when i is null;
            end loop;

            if de_body is not null then
                case
                    when used_de = 0 then de048 := de_body;
                    when used_de = 1 then de062 := de_body;
                    when used_de = 2 then de123 := de_body;
                    when used_de = 3 then de124 := de_body;
                    when used_de = 4 then de125 := de_body;
                end case;
            end if;
        end if;
    end;

    function get_pds_body (
        i_pds_tab               in mup_api_type_pkg.t_pds_tab
        , i_pds_tag             in mup_api_type_pkg.t_pds_tag
    ) return mup_api_type_pkg.t_pds_body is
    begin
        if i_pds_tab.exists(i_pds_tag) then
            return i_pds_tab(i_pds_tag);
        else
            return null;        
        end if;
    end;
    
    procedure set_pds_body (
        io_pds_tab              in out nocopy mup_api_type_pkg.t_pds_tab
        , i_pds_tag             in mup_api_type_pkg.t_pds_tag
        , i_pds_body            in mup_api_type_pkg.t_pds_body
    ) is
    begin
        if i_pds_body is null then
            io_pds_tab.delete(i_pds_tag);
        else
            io_pds_tab(i_pds_tag) := i_pds_body;
        end if;
    end;
    
    procedure read_pds (
        i_msg_id                in com_api_type_pkg.t_long_id
        , o_pds_tab             in out nocopy mup_api_type_pkg.t_pds_tab
    ) is
    
        l_pds_tab               mup_api_type_pkg.t_pds_row_tab;
    
    begin
        o_pds_tab.delete;

        select 
            msg_id
            , pds_number
            , pds_body
        bulk collect into
            l_pds_tab
        from
            mup_msg_pds
        where
            msg_id = i_msg_id;
        
        for i in 1 .. l_pds_tab.count loop
            o_pds_tab(l_pds_tab(i).pds_number) := l_pds_tab(i).pds_body;        
        end loop;    
    end;             

    procedure save_pds (
        i_msg_id                in com_api_type_pkg.t_long_id
        , i_pds_tab             in out nocopy mup_api_type_pkg.t_pds_tab
        , i_clear               in com_api_type_pkg.t_boolean
    ) is
        l_index_tab             com_api_type_pkg.t_integer_tab;
        i                       binary_integer;
    begin
        i := i_pds_tab.first;
        loop
            exit when i is null;

            l_index_tab(i) := i;
            
            i := i_pds_tab.next(i); 
        end loop;
        
        if i_clear = com_api_type_pkg.TRUE then
            delete from
                mup_msg_pds
            where
                msg_id = i_msg_id;
                
            forall i in indices of i_pds_tab
                insert into mup_msg_pds (
                    msg_id
                    , pds_number
                    , pds_body
                ) values (
                    i_msg_id
                    , l_index_tab(i)
                    , i_pds_tab(i)
                );
        
        else
            forall i in indices of i_pds_tab
                merge into
                    mup_msg_pds dst
                using (
                    select
                        l_index_tab(i) pds_number
                        , i_pds_tab(i) pds_body
                    from
                        dual
                ) src
                on (
                    dst.msg_id = i_msg_id
                    and dst.pds_number = src.pds_number
                )
                when matched then
                    update
                    set
                        dst.pds_body = src.pds_body
                when not matched then
                    insert (    
                        dst.msg_id
                        , dst.pds_number
                        , dst.pds_body
                    ) values (
                        i_msg_id
                        , src.pds_number
                        , src.pds_body
                    );
        end if;
    end;
    
    function format_p0025
    (   i_p0025_1               in mup_api_type_pkg.t_p0025_1
        , i_p0025_2             in mup_api_type_pkg.t_p0025_2
    ) return mup_api_type_pkg.t_pds_body is
    begin
        if i_p0025_1 is null then
            return null;
        else
            return (   
                i_p0025_1
                || to_char(i_p0025_2, mup_api_const_pkg.P0025_DATE_FORMAT)
            );
        end if;
    end;
    
    function format_p0268 (   
        i_p0268_1               in mup_api_type_pkg.t_p0268_1
        , i_p0268_2             in mup_api_type_pkg.t_p0268_2
    ) return mup_api_type_pkg.t_pds_body is
    begin
        if i_p0268_1 is null then
            return null;
        else
            return (
                mup_utl_pkg.pad_number(i_p0268_1, 12, 12)
                || mup_utl_pkg.pad_number(nvl(i_p0268_2, '0'), 3, 3)
            );
        end if;
    
    end;
    
    function format_p0149 (   
        i_p0149_1               in mup_api_type_pkg.t_p0149_1
        , i_p0149_2             in mup_api_type_pkg.t_p0149_2
    ) return mup_api_type_pkg.t_pds_body is
    begin
        if i_p0149_1 is null then
            return null;
        else
            return (
                mup_utl_pkg.pad_number(i_p0149_1, 3, 3)
                || mup_utl_pkg.pad_number(nvl(i_p0149_2, '0'), 3, 3)
            );
        end if;
    end;

    -- need only subfield 1
    function format_p2158 (   
        i_p2158_1               in mup_api_type_pkg.t_p2158_1
        , i_p2158_2             in mup_api_type_pkg.t_p2158_2
        , i_p2158_3             in mup_api_type_pkg.t_p2158_3
        , i_p2158_4             in mup_api_type_pkg.t_p2158_4
        , i_p2158_5             in mup_api_type_pkg.t_p2158_5
        , i_p2158_6             in mup_api_type_pkg.t_p2158_6
    ) return mup_api_type_pkg.t_pds_body is
    begin       
        if i_p2158_1 is null then
            return null;
        else
            return (
                mup_utl_pkg.pad_number(nvl(i_p2158_1, '1'), 4, 4)
                || nvl(to_char(i_p2158_2, mup_api_const_pkg.P2158_DATE_FORMAT), '') 
                || nvl(i_p2158_3, '')
                || nvl(i_p2158_4, '')
                || nvl(i_p2158_5, '')
                || nvl(i_p2158_6, '')
            );
        end if;
    end;
     
    function format_p2072 (   
        i_p2072_1               in mup_api_type_pkg.t_p2072_1
        , i_p2072_2             in mup_api_type_pkg.t_p2072_2
    ) return mup_api_type_pkg.t_pds_body is
    begin       
        if i_p2072_2 is null then
            return null;
        else
            return (
                nvl(i_p2072_1, 'CYR')
                || mup_utl_pkg.pad_char(nvl(i_p2072_2, ' '), 100, 100)
            );
        end if;
    end;

    function format_p2097(
        i_p2097_1               in  mup_api_type_pkg.t_p2097_1
      , i_p2097_2               in  mup_api_type_pkg.t_p2097_2
      , i_standard_version_id   in  com_api_type_pkg.t_tiny_id   := null
    ) return mup_api_type_pkg.t_pds_body
    is
    begin
        if i_p2097_2 is null then
            return null;
        end if;

        return nvl(i_p2097_1, 'UTF') || mup_utl_pkg.pad_char(nvl(i_p2097_2, ' '), 4, 203);
    end format_p2097;

    function format_p2175(
        i_p2175_1               in  mup_api_type_pkg.t_p2175_1
      , i_p2175_2               in  mup_api_type_pkg.t_p2175_2
      , i_standard_version_id   in  com_api_type_pkg.t_tiny_id   := null
    ) return mup_api_type_pkg.t_pds_body
    is
        l_p2175_1                   mup_api_type_pkg.t_p2175_1;
    begin

        if i_p2175_2 is null then
            return null;
        end if;

        if (i_p2175_1 = 'CYR' or i_p2175_1 is null) and i_standard_version_id >= mup_api_const_pkg.MUP_STANDARD_VERSION_ID_18Q4 then
            l_p2175_1 := 'UTF';
        else
            l_p2175_1 := nvl(i_p2175_1, 'CYR');
        end if;

        return l_p2175_1 || mup_utl_pkg.pad_char(nvl(i_p2175_2, ' '), 7, 258);
    end format_p2175;

    procedure parse_p0005 (
        i_p0005                  in mup_api_type_pkg.t_pds_body
        , o_reject_code_tab      out nocopy mup_api_type_pkg.t_reject_code_tab
    ) is
        l_reject_code           mup_api_type_pkg.t_reject_code_rec;
        l_length                integer;
        l_curr_pos              integer;
        l_curr_pos2             integer;
        l_curr_body             mup_api_type_pkg.t_pds_body;
        l_pds_tag               mup_api_type_pkg.t_pds_body;
    begin
        o_reject_code_tab.delete;

        l_curr_pos := 1;
        l_length := nvl(length(i_p0005), 0);
        l_pds_tag := 'P0005';

        loop
            exit when l_curr_pos > l_length;
            
            l_curr_pos2 := 1;
            l_reject_code := null;
            
            l_curr_body := substr(i_p0005, l_curr_pos, mup_api_const_pkg.P0005_PART_LENGTH);
            if length(l_curr_body) = mup_api_const_pkg.P0005_PART_LENGTH then
                begin
                    -- Data Element ID
                    l_reject_code.de_number := substr(l_curr_body, l_curr_pos2, 5);
                    l_curr_pos2 := l_curr_pos2 + 5;
                    
                    -- Error Severity Code
                    l_reject_code.severity_code := substr(l_curr_body, l_curr_pos2, 2);
                    l_curr_pos2 := l_curr_pos2 + 2;
                    
                    -- Error Message Code
                    l_reject_code.message_code := substr(l_curr_body, l_curr_pos2, 4);
                    l_curr_pos2 := l_curr_pos2 + 4;
                    
                    -- Subfield ID
                    l_reject_code.subfield_id :=  substr(l_curr_body, l_curr_pos2, 3);
                    l_curr_pos2 := l_curr_pos2 + 3;
                exception
                    when com_api_error_pkg.e_invalid_number then
                        com_api_error_pkg.raise_error(
                            i_error       => 'MUP_ERROR_WRONG_VALUE'
                          , i_env_param1  => l_pds_tag
                          , i_env_param2  => l_curr_pos2
                          , i_env_param3  => l_curr_body
                        );
                end;
                
                l_curr_pos := l_curr_pos + mup_api_const_pkg.P0005_PART_LENGTH;
            else
                com_api_error_pkg.raise_error(
                    i_error       => 'PDS_ERROR_WRONG_LENGTH'
                  , i_env_param1  => l_pds_tag
                  , i_env_param2  => l_curr_pos
                  , i_env_param3  => i_p0005
                );
            end if;
            
            o_reject_code_tab(o_reject_code_tab.count+1) := l_reject_code;
        end loop;
    end;
    
    procedure parse_p0025 (
        i_p0025                 in mup_api_type_pkg.t_pds_body
        , o_p0025_1             out mup_api_type_pkg.t_p0025_1
        , o_p0025_2             out mup_api_type_pkg.t_p0025_2
    ) is
        l_curr_pos               pls_integer;
    begin
        l_curr_pos := 1;
        o_p0025_1 := substr(i_p0025, l_curr_pos, 1);
        l_curr_pos := l_curr_pos + 1;
        o_p0025_2 := to_date(substr(i_p0025, l_curr_pos, 6), mup_api_const_pkg.P0025_DATE_FORMAT);
    exception
        when others then
            com_api_error_pkg.raise_error(
                i_error         => 'MUP_ERROR_WRONG_VALUE'
                , i_env_param1  => 'P0025'
                , i_env_param2  => l_curr_pos
                , i_env_param3  => i_p0025
           );
    end;
    
    procedure parse_p0105 (   
        i_p0105                 in mup_api_type_pkg.t_pds_body
        , o_file_type           out mup_api_type_pkg.t_pds_body
        , o_file_date           out date
        , o_cmid                out com_api_type_pkg.t_cmid
    ) is
        l_curr_pos              pls_integer;
    begin
        l_curr_pos := 1;
        o_file_type := substr(i_p0105, l_curr_pos, 3);
        l_curr_pos := l_curr_pos + 3;
        o_file_date := to_date(substr(i_p0105, l_curr_pos, 6), mup_api_const_pkg.P0105_DATE_FORMAT);
        l_curr_pos := l_curr_pos + 6;
        o_cmid := substr(i_p0105, 10, 11);
    exception
        when others then
            com_api_error_pkg.raise_error(
                 i_error         => 'MUP_ERROR_WRONG_VALUE'
                 , i_env_param1  => 'P0105'
                 , i_env_param2  => l_curr_pos
                 , i_env_param3  => i_p0105
             );
    end;

    procedure parse_p0146(
        i_pds_body              in  mup_api_type_pkg.t_pds_body
      , o_p0146                 out mup_api_type_pkg.t_p0146
      , o_p0146_net             out mup_api_type_pkg.t_p0146_net
    ) is
        l_pds_tag               com_api_type_pkg.t_name;
        l_pds_part_length       mup_api_type_pkg.t_pds_len;
        l_curr_pos              integer;
        l_p0146_tab             mup_api_type_pkg.t_pds_tab;
    begin
        trc_log_pkg.debug(
            i_text       => 'parse_p0146: i_pds_body [#1]'
          , i_env_param1 => i_pds_body
        );

        l_pds_tag         := 'P0146';
        l_pds_part_length := mup_api_const_pkg.P0146_PART_LENGTH;

        if mod(nvl(length(i_pds_body), 0), l_pds_part_length) != 0 then
            com_api_error_pkg.raise_error(
                i_error      => 'PDS_ERROR_WRONG_LENGTH'
              , i_env_param1 => l_pds_tag
              , i_env_param2 => nvl(length(i_pds_body), 0)
              , i_env_param3 => i_pds_body
            );
        end if;

        l_curr_pos  := 1;
        
        while l_curr_pos <= nvl(length(i_pds_body), 0) loop
            begin
                l_p0146_tab.delete();
                l_p0146_tab(1) := substr(i_pds_body, l_curr_pos, 2); -- Fee Type
                l_p0146_tab(2) := substr(i_pds_body, l_curr_pos + 2, 2); -- Fee Processing
                l_p0146_tab(3) := substr(i_pds_body, l_curr_pos + 4, 2); -- Fee Settlement
                l_p0146_tab(4) := substr(i_pds_body, l_curr_pos + 6, 2); -- Currency Code, Fee

                l_p0146_tab(5) := substr(i_pds_body, l_curr_pos + 9,  12); -- Amount, Fee
                l_p0146_tab(6) := substr(i_pds_body, l_curr_pos + 21,  3); -- Currency Code, Fee, Reconcilation
                l_p0146_tab(7) := substr(i_pds_body, l_curr_pos + 24, 12); -- Amount, Fee, Reconcilation

                trc_log_pkg.debug(
                    i_text => 'l_curr_pos [' || l_curr_pos || '], l_p0146_tab: ['
                           || l_p0146_tab(1) || '] [' || l_p0146_tab(2) || '] ['
                           || l_p0146_tab(3) || '] [' || l_p0146_tab(4) || '] ['
                           || l_p0146_tab(5) || '] [' || l_p0146_tab(6) || '] [' || l_p0146_tab(7) || ']'
                );
                
                if l_p0146_tab(1) = '00' and l_p0146_tab(3) = '01' then
                    o_p0146_net := nvl(o_p0146_net, 0)
                                 + to_number(l_p0146_tab(7)) *
                                   case l_p0146_tab(2)
                                       when mup_api_const_pkg.PROC_CODE_CREDIT_FEE then -1 -- credit to originator, debit to destination
                                       when mup_api_const_pkg.PROC_CODE_DEBIT_FEE  then  1 -- debit to originator, credit to destination
                                                                                   else  0
                                   end;
                    trc_log_pkg.debug(
                        i_text       => 'o_p0146_net: [#1]'
                      , i_env_param1 => o_p0146_net
                    );
                                   
                end if;
            exception
                when com_api_error_pkg.e_invalid_number then
                    com_api_error_pkg.raise_error(
                        i_error      => 'MUP_ERROR_WRONG_VALUE'
                      , i_env_param1 => l_pds_tag
                      , i_env_param2 => l_curr_pos -- actual only for subfield 5 and 7
                      , i_env_param3 => i_pds_body
                    );
            end;

            l_curr_pos := l_curr_pos + l_pds_part_length;
        end loop;
        
        trc_log_pkg.debug(
            i_text       => 'o_p0146_net: [#1]'
          , i_env_param1 => o_p0146_net
        );
        
    end parse_p0146;

    procedure parse_p0149 (
        i_p0149                 in mup_api_type_pkg.t_pds_body
        , o_p0149_1             out mup_api_type_pkg.t_p0149_1
        , o_p0149_2             out mup_api_type_pkg.t_p0149_1
    ) is
        l_curr_pos               pls_integer;
    begin
        l_curr_pos := 1;
        o_p0149_1 := to_number(substr(i_p0149, l_curr_pos, 3));
        l_curr_pos := l_curr_pos + 3;
        o_p0149_2 := to_number(substr(i_p0149, l_curr_pos, 3));
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error         => 'MUP_ERROR_WRONG_VALUE'
                , i_env_param1  => 'P0149'
                , i_env_param2  => l_curr_pos
                , i_env_param3  => i_p0149
            );
    end;
    
    procedure parse_p2158 (
        i_p2158                in mup_api_type_pkg.t_pds_body
        , o_p2158_1            out mup_api_type_pkg.t_p2158_1
        , o_p2158_2            out mup_api_type_pkg.t_p2158_2
        , o_p2158_3            out mup_api_type_pkg.t_p2158_3
        , o_p2158_4            out mup_api_type_pkg.t_p2158_4
        , o_p2158_5            out mup_api_type_pkg.t_p2158_5
        , o_p2158_6            out mup_api_type_pkg.t_p2158_6
    ) is
        l_curr_pos              pls_integer;
    begin  
        l_curr_pos := 1;
        o_p2158_1 := substr(i_p2158, l_curr_pos, 4);
        l_curr_pos := l_curr_pos + 4;
        o_p2158_2 := to_date(substr(i_p2158, l_curr_pos, 6), mup_api_const_pkg.P2158_DATE_FORMAT);
        l_curr_pos := l_curr_pos + 6;
        o_p2158_3 := substr(i_p2158, l_curr_pos, 2);
        l_curr_pos := l_curr_pos + 2;
        o_p2158_4 := substr(i_p2158, l_curr_pos, 1);
        l_curr_pos := l_curr_pos + 1;
        o_p2158_5 := substr(i_p2158, l_curr_pos, 3);
        l_curr_pos := l_curr_pos + 3;
        o_p2158_6 := substr(i_p2158, l_curr_pos, 2);
        l_curr_pos := l_curr_pos + 2;

    exception
        when others then
            com_api_error_pkg.raise_error(
                i_error         => 'MUP_ERROR_WRONG_VALUE'
                , i_env_param1  => 'P0158'
                , i_env_param2  => l_curr_pos
                , i_env_param3  => i_p2158
            );
    end;
    
    procedure parse_p2159 (
        i_p2159                in mup_api_type_pkg.t_pds_body
        , o_p2159_1            out mup_api_type_pkg.t_p2159_1
        , o_p2159_2            out mup_api_type_pkg.t_p2159_2
        , o_p2159_3            out mup_api_type_pkg.t_p2159_3
        , o_p2159_4            out mup_api_type_pkg.t_p2159_4
        , o_p2159_5            out mup_api_type_pkg.t_p2159_5
        , o_p2159_6            out mup_api_type_pkg.t_p2159_6
    ) is
        l_curr_pos              pls_integer;
    begin   
        if rtrim(i_p2159) is not null then
            l_curr_pos := 1;
            o_p2159_1 := substr(i_p2159, l_curr_pos, 11);
            l_curr_pos := l_curr_pos + 11;
            o_p2159_2 := substr(i_p2159, l_curr_pos, 1);
            l_curr_pos := l_curr_pos + 1;
            o_p2159_3 := substr(i_p2159, l_curr_pos, 10);
            l_curr_pos := l_curr_pos + 10;
            
            if rtrim(substr(i_p2159, l_curr_pos, 6), 0) is not null then
                o_p2159_4 := to_date(rtrim(substr(i_p2159, l_curr_pos, 6)), mup_api_const_pkg.P2159_DATE_FORMAT);
            end if;
            l_curr_pos := l_curr_pos + 6;
            
            o_p2159_5 := substr(i_p2159, l_curr_pos, 2);
            l_curr_pos := l_curr_pos + 2;

            if rtrim(substr(i_p2159, l_curr_pos, 6), 0) is not null then
                o_p2159_6 := to_date(rtrim(substr(i_p2159, l_curr_pos, 6)), mup_api_const_pkg.P2159_DATE_FORMAT);
            end if;
            l_curr_pos := l_curr_pos + 6;
            
        end if;
    exception
        when others then
            com_api_error_pkg.raise_error(
                i_error         => 'MUP_ERROR_WRONG_VALUE'
                , i_env_param1  => 'P2159'
                , i_env_param2  => l_curr_pos
                , i_env_param3  => i_p2159
            );
    end;
      
    procedure parse_p0268 (
        i_p0268                in mup_api_type_pkg.t_pds_body
        , o_p0268_1            out mup_api_type_pkg.t_p0268_1
        , o_p0268_2            out mup_api_type_pkg.t_p0268_2
    ) is
        l_curr_pos              pls_integer;
    begin
        l_curr_pos := 1;
        o_p0268_1 := to_number(trim(substr(i_p0268, l_curr_pos, 12)));
        l_curr_pos := l_curr_pos + 12;
        o_p0268_2 := to_number(trim(substr(i_p0268, l_curr_pos, 3)));
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error         => 'MUP_ERROR_WRONG_VALUE'
                , i_env_param1  => 'P0268'
                , i_env_param2  => l_curr_pos
                , i_env_param3  => i_p0268
            );
    end;
   
    procedure parse_p0370 (
        i_p0370                 in mup_api_type_pkg.t_pds_body
        , o_p0370_1             out mup_api_type_pkg.t_p0370_1
        , o_p0370_2             out mup_api_type_pkg.t_p0370_2
    ) is
        l_curr_pos               pls_integer;
    begin
        l_curr_pos := 1;
        o_p0370_1 := to_number(substr(i_p0370, l_curr_pos, 19));
        l_curr_pos := l_curr_pos + 19;
        o_p0370_2 := to_number(substr(i_p0370, l_curr_pos, 19));
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error         => 'MUP_ERROR_WRONG_VALUE'
                , i_env_param1  => 'P0370'
                , i_env_param2  => l_curr_pos
                , i_env_param3  => i_p0370
            );
    end;

    procedure parse_p0372 (
        i_p0372                 in mup_api_type_pkg.t_pds_body
        , o_p0372_1             out mup_api_type_pkg.t_p0372_1
        , o_p0372_2             out mup_api_type_pkg.t_p0372_2
    ) is
        l_curr_pos               pls_integer;
    begin
        l_curr_pos := 1;
        o_p0372_1 := to_number(substr(i_p0372, l_curr_pos, 4));
        l_curr_pos := l_curr_pos + 4;
        o_p0372_2 := to_number(substr(i_p0372, l_curr_pos, 3));
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error         => 'MUP_ERROR_WRONG_VALUE'
                , i_env_param1  => 'P0372'
                , i_env_param2  => l_curr_pos
                , i_env_param3  => i_p0372
            );
    end;

    procedure parse_p0380 (
        i_pds_body              in mup_api_type_pkg.t_pds_body
        , i_pds_name            in mup_api_type_pkg.t_pds_body
        , o_p0380_1             out mup_api_type_pkg.t_p0380_1
        , o_p0380_2             out mup_api_type_pkg.t_p0380_2
    ) is
        l_curr_pos               pls_integer;
    begin
        l_curr_pos := 1;
        o_p0380_1 := substr(i_pds_body, 1, 1);
        l_curr_pos := l_curr_pos + 1;
        o_p0380_2 := nvl(to_number(substr(i_pds_body, 2)), 0);
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error         => 'MUP_ERROR_WRONG_VALUE'
                , i_env_param1  => i_pds_name
                , i_env_param2  => l_curr_pos
                , i_env_param3  => i_pds_body
            );
    end;

    procedure parse_p2072 (
        i_p2072                 in mup_api_type_pkg.t_pds_body
        , o_p2072_1             out mup_api_type_pkg.t_p2072_1
        , o_p2072_2             out mup_api_type_pkg.t_p2072_2
    ) is
        l_curr_pos               pls_integer;
    begin
        l_curr_pos := 1;
        o_p2072_1  := substr(i_p2072, l_curr_pos, 3);
        l_curr_pos := l_curr_pos + 3;
        o_p2072_2  := utl_raw.cast_to_raw(substr(i_p2072, l_curr_pos));
    exception
        when others then
            com_api_error_pkg.raise_error(
                 i_error         => 'MUP_ERROR_WRONG_VALUE'
                 , i_env_param1  => 'P2072'
                 , i_env_param2  => l_curr_pos
                 , i_env_param3  => i_p2072
             );
    end;

    procedure parse_p2097(
        i_p2097                 in      mup_api_type_pkg.t_pds_body
      , o_p2097_1                  out  mup_api_type_pkg.t_p2097_1
      , o_p2097_2                  out  mup_api_type_pkg.t_p2097_2
      , i_standard_version_id   in      com_api_type_pkg.t_tiny_id  := null
    ) is
        l_curr_pos        pls_integer := 1;
    begin
        l_curr_pos := 1;
        o_p2097_1  := substr(i_p2097, l_curr_pos, 3);
        l_curr_pos := l_curr_pos + 3;
        o_p2097_2  := utl_raw.cast_to_raw(substr(i_p2097, l_curr_pos));
    exception
        when others then
            com_api_error_pkg.raise_error(
                 i_error       => 'MUP_ERROR_WRONG_VALUE'
               , i_env_param1  => 'P2097'
               , i_env_param2  => l_curr_pos
               , i_env_param3  => i_p2097
             );
    end;

    procedure parse_p2175(
        i_p2175                 in      mup_api_type_pkg.t_pds_body
      , o_p2175_1                  out  mup_api_type_pkg.t_p2175_1
      , o_p2175_2                  out  mup_api_type_pkg.t_p2175_2
      , i_standard_version_id   in      com_api_type_pkg.t_tiny_id  := null
    ) is
        l_curr_pos                   pls_integer;
    begin

        if i_p2175 is null then
            return;
        end if;

        if i_standard_version_id >= mup_api_const_pkg.MUP_STANDARD_VERSION_ID_18Q4 then
            o_p2175_1  := 'UTF';
        else
            o_p2175_1  := substr(i_p2175, 1, 3);
        end if;

        l_curr_pos := 4;

        o_p2175_2  := utl_raw.cast_to_raw(substr(i_p2175, l_curr_pos));
    exception
        when others then
            com_api_error_pkg.raise_error(
                 i_error       => 'MUP_ERROR_WRONG_VALUE'
               , i_env_param1  => 'P2175'
               , i_env_param2  => l_curr_pos
               , i_env_param3  => i_p2175
             );
    end;

    procedure parse_p2001 (
        i_p2001                 in      mup_api_type_pkg.t_pds_body
      , o_p2001_1                  out  mup_api_type_pkg.t_p2001_1
      , o_p2001_2                  out  mup_api_type_pkg.t_p2001_2
      , o_p2001_3                  out  mup_api_type_pkg.t_p2001_3
      , o_p2001_4                  out  mup_api_type_pkg.t_p2001_4
      , o_p2001_5                  out  mup_api_type_pkg.t_p2001_5
      , o_p2001_6                  out  mup_api_type_pkg.t_p2001_6
      , o_p2001_7                  out  mup_api_type_pkg.t_p2001_7
    ) is
        l_curr_pos              pls_integer;
    begin   
        if rtrim(i_p2001) is not null then
            l_curr_pos := 1;
            o_p2001_1 := substr(i_p2001, l_curr_pos, 1);
            l_curr_pos := l_curr_pos + 1;
            o_p2001_2 := substr(i_p2001, l_curr_pos, 19);
            l_curr_pos := l_curr_pos + 19;
            o_p2001_3 := substr(i_p2001, l_curr_pos, 4);
            l_curr_pos := l_curr_pos + 4;
            o_p2001_4 := substr(i_p2001, l_curr_pos, 2);
            l_curr_pos := l_curr_pos + 2;
            o_p2001_5 := to_number(substr(i_p2001, l_curr_pos, 11));
            l_curr_pos := l_curr_pos + 11;
            o_p2001_6 := to_number(substr(i_p2001, l_curr_pos, 2));
            l_curr_pos := l_curr_pos + 2;
            o_p2001_7 := substr(i_p2001, l_curr_pos, 29);
            l_curr_pos := l_curr_pos + 29;
        end if;
    exception
        when others then
            com_api_error_pkg.raise_error(
                i_error         => 'MUP_ERROR_WRONG_VALUE'
                , i_env_param1  => 'P2001'
                , i_env_param2  => l_curr_pos
                , i_env_param3  => i_p2001
            );
    end;
      
begin
    init_pds_tab;   
end;
/
