create or replace package body jcb_api_pds_pkg is

    subtype t_pds_rec is jcb_pds%rowtype;
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
            jcb_pds
        where -- only limited set of active pds will be used
            max_length > 0;
        
        g_pds.delete;
        
        for i in 1 .. l_pds.count loop
            g_pds(l_pds(i).pds_number) := l_pds(i);
        end loop;
        
        l_pds.delete;
    end;
    
    function format_pds_tag (   
        i_pds_tag               in jcb_api_type_pkg.t_pds_tag
    ) return jcb_api_type_pkg.t_pds_tag_chr is
    begin
        return jcb_utl_pkg.pad_number (
            i_data          => i_pds_tag
            , i_max_length  => jcb_api_const_pkg.PDS_TAG_LEN
            , i_min_length  => jcb_api_const_pkg.PDS_TAG_LEN
        );
    end;
    
    function format_pds_len (
        i_pds_len                 in jcb_api_type_pkg.t_pds_len
    ) return jcb_api_type_pkg.t_pds_len_chr is
    begin
        return jcb_utl_pkg.pad_number (
            i_data          => i_pds_len
            , i_max_length  => jcb_api_const_pkg.PDS_LENGTH_LEN
            , i_min_length  => jcb_api_const_pkg.PDS_LENGTH_LEN
        );
    end;
    
    function format_pds_body (
        i_data                  in jcb_api_type_pkg.t_pds_body
        , i_number              in binary_integer
    ) return jcb_api_type_pkg.t_pds_body is
    begin
        if i_data is not null and g_pds.exists(i_number) then
            if g_pds(i_number).format = 'N' then
                return jcb_utl_pkg.pad_number (
                    i_data          => i_data
                    , i_max_length  => g_pds(i_number).max_length
                    , i_min_length  => g_pds(i_number).min_length
                );

            elsif g_pds(i_number).format = 'B' then
                return i_data;   

            else 
                return jcb_utl_pkg.pad_char (
                    i_data          => i_data
                    , i_max_length  => g_pds(i_number).max_length
                    , i_min_length  => g_pds(i_number).min_length
                );
            end if;
        else
            return null;
        end if;
    end;
    
    procedure extract_pds (
       de048                    in jcb_api_type_pkg.t_de048
        , de062                 in jcb_api_type_pkg.t_de062
        , de123                 in jcb_api_type_pkg.t_de123
        , de124                 in jcb_api_type_pkg.t_de124
        , de125                 in jcb_api_type_pkg.t_de125
        , de126                 in jcb_api_type_pkg.t_de126
        , pds_tab               in out nocopy jcb_api_type_pkg.t_pds_tab
    ) is
        de_body                 jcb_api_type_pkg.t_de048;
        de_length               integer;
        curr_pos                integer;
        pds_tag                 jcb_api_type_pkg.t_pds_tag;
        pds_len                 jcb_api_type_pkg.t_pds_len;
        pds_body                jcb_api_type_pkg.t_pds_body;
        de_name                 varchar2(5);   
        curr_body               jcb_api_type_pkg.t_pds_body;
    begin
        pds_tab.delete;

        for i in 1 .. 6 loop
            case 
                when i = 1 then begin de_body := de048; de_name := 'DE048'; end;
                when i = 2 then begin de_body := de062; de_name := 'DE062'; end;
                when i = 3 then begin de_body := de123; de_name := 'DE123'; end;
                when i = 4 then begin de_body := de124; de_name := 'DE124'; end;
                when i = 5 then begin de_body := de125; de_name := 'DE125'; end;
                when i = 6 then begin de_body := de126; de_name := 'DE126'; end;
            end case;

            if de_body is null then 
                exit;
            else
                curr_pos := 1;
                de_length := length(de_body);

                loop
                    exit when curr_pos > de_length;

                    curr_body := substr(de_body, curr_pos, jcb_api_const_pkg.PDS_TAG_LEN);
                    if length(curr_body) = jcb_api_const_pkg.PDS_TAG_LEN then
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
                        curr_pos := curr_pos + jcb_api_const_pkg.PDS_TAG_LEN;
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'PDS_ERROR_WRONG_TAG'
                          , i_env_param1    => de_name
                          , i_env_param2    => curr_pos
                          , i_env_param3    => de_body
                        );
                    end if;

                    curr_body := substr(de_body, curr_pos, jcb_api_const_pkg.PDS_LENGTH_LEN);
                    if length(curr_body) = jcb_api_const_pkg.PDS_LENGTH_LEN then
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
                        curr_pos := curr_pos + jcb_api_const_pkg.PDS_LENGTH_LEN;
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
    (   pds_tab                 in jcb_api_type_pkg.t_pds_tab
        , de048                 out jcb_api_type_pkg.t_de048
        , de062                 out jcb_api_type_pkg.t_de062
        , de123                 out jcb_api_type_pkg.t_de123
        , de124                 out jcb_api_type_pkg.t_de124
        , de125                 out jcb_api_type_pkg.t_de125
        , de126                 out jcb_api_type_pkg.t_de126
    ) is
        i                       binary_integer;
        used_de                 integer := 0;
        de_body                 jcb_api_type_pkg.t_de048;
        pds_str                 jcb_api_type_pkg.t_de_body;
        pds_body                jcb_api_type_pkg.t_pds_body;
    begin
        trc_log_pkg.debug (
            i_text          => 'pds_tab.count = ' || pds_tab.count
        );
    
        if pds_tab.count > 0 then
            i := pds_tab.first; 
            loop
                if pds_tab(i) is not null then
                    pds_body := format_pds_body (
                        i_data          => pds_tab(i)
                        , i_number      => i
                    );
                    trc_log_pkg.debug (
                        i_text          => 'pds_body = ' || pds_body
                    );
                    
                    if pds_body is not null then
                        pds_str := (
                            format_pds_tag(i)
                            || format_pds_len(length(pds_body))
                            || pds_body
                        );
                        trc_log_pkg.debug (
                            i_text          => 'pds_str = ' || pds_str
                        );

                        if nvl(length(de_body), 0) + length(pds_str) > jcb_api_const_pkg.MAX_PDS_DE_LEN then

                            case
                                when used_de = 0 then de048 := de_body;
                                when used_de = 1 then de062 := de_body;
                                when used_de = 2 then de123 := de_body;
                                when used_de = 3 then de124 := de_body;
                                when used_de = 4 then de125 := de_body;
                                when used_de = 5 then de126 := de_body;
                                when used_de = 6 then
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

            trc_log_pkg.debug (
                i_text          => 'de_body = ' || de_body
            );
            if de_body is not null then
                case
                    when used_de = 0 then de048 := de_body;
                    when used_de = 1 then de062 := de_body;
                    when used_de = 2 then de123 := de_body;
                    when used_de = 3 then de124 := de_body;
                    when used_de = 4 then de125 := de_body;
                    when used_de = 5 then de126 := de_body;
                end case;
            end if;
            trc_log_pkg.debug (
                i_text          => 'de048 = ' || de048
            );
            
        end if;
    end;

    function get_pds_body (
        i_pds_tab               in jcb_api_type_pkg.t_pds_tab
        , i_pds_tag             in jcb_api_type_pkg.t_pds_tag
    ) return jcb_api_type_pkg.t_pds_body is
    begin
        if i_pds_tab.exists(i_pds_tag) then
            return i_pds_tab(i_pds_tag);
        else
            return null;        
        end if;
    end;
    
    procedure set_pds_body (
        io_pds_tab              in out nocopy jcb_api_type_pkg.t_pds_tab
        , i_pds_tag             in jcb_api_type_pkg.t_pds_tag
        , i_pds_body            in jcb_api_type_pkg.t_pds_body
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
        , o_pds_tab             in out nocopy jcb_api_type_pkg.t_pds_tab
    ) is
    
        l_pds_tab               jcb_api_type_pkg.t_pds_row_tab;
    
    begin
        o_pds_tab.delete;

        select 
            msg_id
            , pds_number
            , pds_body
        bulk collect into
            l_pds_tab
        from
            jcb_msg_pds
        where
            msg_id = i_msg_id;
        
        for i in 1 .. l_pds_tab.count loop
            o_pds_tab(l_pds_tab(i).pds_number) := l_pds_tab(i).pds_body;        
        end loop;    
    end;             

    procedure save_pds (
        i_msg_id                in com_api_type_pkg.t_long_id
        , i_pds_tab             in out nocopy jcb_api_type_pkg.t_pds_tab
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
                jcb_msg_pds
            where
                msg_id = i_msg_id;
                
            forall i in indices of i_pds_tab
                insert into jcb_msg_pds (
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
                    jcb_msg_pds dst
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
    
    procedure parse_p3901 (   
        i_p3901               in jcb_api_type_pkg.t_pds_body
        , o_p3901_1           out jcb_api_type_pkg.t_p3901_1
        , o_p3901_2           out jcb_api_type_pkg.t_p3901_2
        , o_p3901_3           out jcb_api_type_pkg.t_p3901_3
        , o_p3901_4           out jcb_api_type_pkg.t_p3901_4
    )is
        l_curr_pos            pls_integer;
    begin
    
        l_curr_pos := 1;
        o_p3901_1  := substr(i_p3901, l_curr_pos, 3);
        l_curr_pos := l_curr_pos + 3;
        o_p3901_2  := to_date(substr(i_p3901, l_curr_pos, 6), jcb_api_const_pkg.P3901_DATE_FORMAT);
        l_curr_pos := l_curr_pos + 6;
        o_p3901_3  := substr(i_p3901, l_curr_pos, 11);
        l_curr_pos := l_curr_pos + 11;
        o_p3901_4  := substr(i_p3901, l_curr_pos, 5);
        
    exception
        when others then
            com_api_error_pkg.raise_error(
                 i_error         => 'JCB_ERROR_WRONG_VALUE'
                 , i_env_param1  => 'P3901'
                 , i_env_param2  => l_curr_pos
                 , i_env_param3  => i_p3901
             );
    end;
    
    procedure parse_p3005 (   
        i_p3005               in jcb_api_type_pkg.t_pds_body
        , i_fin_rec_id        in com_api_type_pkg.t_long_id
        , o_p3005_tab         in out nocopy jcb_api_type_pkg.t_p3005_tab
    )is
        l_curr_pos            pls_integer := 1;
        l_p3005_rec           jcb_api_type_pkg.t_p3005_rec := null;
    begin
        o_p3005_tab.delete;
        
        loop
            exit when l_curr_pos > nvl(length(i_p3005), 0);
            
            l_p3005_rec.msg_id := i_fin_rec_id;

            l_p3005_rec.p3005_1 := substr(i_p3005, l_curr_pos, 5);
            l_curr_pos := l_curr_pos + 5;
            l_p3005_rec.p3005_2 := substr(i_p3005, l_curr_pos, 3);
            l_curr_pos := l_curr_pos + 3;
            l_p3005_rec.p3005_3 := substr(i_p3005, l_curr_pos, 4);
            l_curr_pos := l_curr_pos + 4;
            l_p3005_rec.p3005_4 := substr(i_p3005, l_curr_pos, 10);
            l_curr_pos := l_curr_pos + 10;
            l_p3005_rec.p3005_5 := substr(i_p3005, l_curr_pos, 8);
            l_curr_pos := l_curr_pos + 8;
            l_p3005_rec.p3005_6 := substr(i_p3005, l_curr_pos, 3);
            l_curr_pos := l_curr_pos + 3;
            l_p3005_rec.p3005_7 := substr(i_p3005, l_curr_pos, 8);
            l_curr_pos := l_curr_pos + 8;
            l_p3005_rec.p3005_8 := substr(i_p3005, l_curr_pos, 1);
            l_curr_pos := l_curr_pos + 1;
            l_p3005_rec.p3005_9 := substr(i_p3005, l_curr_pos, 3);
            l_curr_pos := l_curr_pos + 3;
            l_p3005_rec.p3005_10 := substr(i_p3005, l_curr_pos, 12);
            l_curr_pos := l_curr_pos + 12;
            
            o_p3005_tab(o_p3005_tab.count + 1) := l_p3005_rec;
            
        end loop;
        
    exception
        when others then
            com_api_error_pkg.raise_error(
                i_error         => 'JCB_ERROR_WRONG_VALUE'
                , i_env_param1  => 'P3005'
                , i_env_param2  => l_curr_pos
                , i_env_param3  => i_p3005
           );
    end;
    
    procedure parse_p3007 (
        i_p3007                 in jcb_api_type_pkg.t_pds_body
        , o_p3007_1             out jcb_api_type_pkg.t_p3007_1
        , o_p3007_2             out jcb_api_type_pkg.t_p3007_2
    ) is
        l_curr_pos               pls_integer;
    begin
        l_curr_pos := 1;
        o_p3007_1 := substr(i_p3007, l_curr_pos, 1);
        l_curr_pos := l_curr_pos + 1;

        if substr(i_p3007, l_curr_pos, 6) != '000000' then
            o_p3007_2 := to_date(substr(i_p3007, l_curr_pos, 6), jcb_api_const_pkg.P3007_DATE_FORMAT);
        end if;
    exception
        when others then
            com_api_error_pkg.raise_error(
                i_error         => 'JCB_ERROR_WRONG_VALUE'
                , i_env_param1  => 'P3007'
                , i_env_param2  => l_curr_pos
                , i_env_param3  => i_p3007
           );
    end;
    
    procedure parse_p3600 (
        i_p3600                 in jcb_api_type_pkg.t_pds_body
        , o_p3600_1             out jcb_api_type_pkg.t_p3600_1
        , o_p3600_2             out jcb_api_type_pkg.t_p3600_2
        , o_p3600_3             out jcb_api_type_pkg.t_p3600_3
    ) is
        l_curr_pos               pls_integer;
    begin

        l_curr_pos := 1;
        o_p3600_1 := substr(i_p3600, l_curr_pos, 8);
        l_curr_pos := l_curr_pos + 8;

        o_p3600_2 := substr(i_p3600, l_curr_pos, 2);
        l_curr_pos := l_curr_pos + 2;

        o_p3600_3 := substr(i_p3600, l_curr_pos, 3);        
    end;
    
    procedure save_p3005 (
        i_msg_id                in com_api_type_pkg.t_long_id
        , i_p3005_tab           in jcb_api_type_pkg.t_p3005_tab
    ) is
    begin
        delete from
            jcb_fin_p3005
        where
            msg_id = i_msg_id;
                
        forall i in indices of i_p3005_tab
            insert into jcb_fin_p3005 (
                msg_id
              , p3005_1
              , p3005_2
              , p3005_3
              , p3005_4
              , p3005_5
              , p3005_6
              , p3005_7
              , p3005_8
              , p3005_9
              , p3005_10
            ) values (
                i_msg_id
              , i_p3005_tab(i).p3005_1
              , i_p3005_tab(i).p3005_2
              , i_p3005_tab(i).p3005_3
              , i_p3005_tab(i).p3005_4
              , i_p3005_tab(i).p3005_5
              , i_p3005_tab(i).p3005_6
              , i_p3005_tab(i).p3005_7
              , i_p3005_tab(i).p3005_8
              , i_p3005_tab(i).p3005_9
              , i_p3005_tab(i).p3005_10
            );
    end;
    
    function format_p3007(
        i_p3007_1               in jcb_api_type_pkg.t_p3007_1
        , i_p3007_2             in jcb_api_type_pkg.t_p3007_2
    ) return jcb_api_type_pkg.t_pds_body is
    begin
        if i_p3007_1 is null then
            return null;
        else
            return (   
                i_p3007_1
                || to_char(i_p3007_2, jcb_api_const_pkg.P3007_DATE_FORMAT)
            );
        end if;
    end;  
    
begin
    init_pds_tab;   
end;
/
