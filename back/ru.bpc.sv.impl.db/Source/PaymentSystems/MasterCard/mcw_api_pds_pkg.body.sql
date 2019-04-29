create or replace package body mcw_api_pds_pkg is

    subtype t_pds_rec is mcw_pds%rowtype;
    type t_pds_tab is table of t_pds_rec index by binary_integer;

    g_pds    t_pds_tab;

    procedure init_pds_tab
    is
        l_pds     t_pds_tab;
    begin
        select pds_number
             , name
             , upper(format)
             , min_length
             , max_length
             , subfield_count
          bulk collect into
               l_pds
          from mcw_pds
         where pds_number <= mcw_api_const_pkg.MAX_PDS_NUMBER -- only limited set of active pds will be used
           and max_length > 0;

        g_pds.delete;

        for i in 1 .. l_pds.count loop
            g_pds(l_pds(i).pds_number) := l_pds(i);
        end loop;

        l_pds.delete;
    end;

    function format_pds_tag(
        i_pds_tag               in mcw_api_type_pkg.t_pds_tag
    ) return mcw_api_type_pkg.t_pds_tag_chr is
    begin
        return
            mcw_utl_pkg.pad_number(
                i_data        => i_pds_tag
              , i_max_length  => mcw_api_const_pkg.PDS_TAG_LEN
              , i_min_length  => mcw_api_const_pkg.PDS_TAG_LEN
            );
    end;

    function format_pds_len (
        i_pds_len               in mcw_api_type_pkg.t_pds_len
    ) return mcw_api_type_pkg.t_pds_len_chr is
    begin
        return mcw_utl_pkg.pad_number(
                   i_data        => i_pds_len
                 , i_max_length  => mcw_api_const_pkg.PDS_LENGTH_LEN
                 , i_min_length  => mcw_api_const_pkg.PDS_LENGTH_LEN
               );
    end;

    function format_pds_body (
        i_data                  in     mcw_api_type_pkg.t_pds_body
      , i_number                in     binary_integer
    ) return mcw_api_type_pkg.t_pds_body
    is
        l_pds_body                     mcw_api_type_pkg.t_pds_body;
    begin
        if i_data is not null and g_pds.exists(i_number) then
            l_pds_body :=
                case g_pds(i_number).format
                    when 'N' then
                        mcw_utl_pkg.pad_number(
                            i_data        => i_data
                          , i_max_length  => g_pds(i_number).max_length
                          , i_min_length  => g_pds(i_number).min_length
                        )
                    when 'B' then
                        i_data
                    else
                        mcw_utl_pkg.pad_char(
                            i_data        => i_data
                          , i_max_length  => g_pds(i_number).max_length
                          , i_min_length  => g_pds(i_number).min_length
                        )
                end;
        else
            trc_log_pkg.warn(
                i_text       => 'MCW_ATTEMPT_TO_USE_INACTIVE_PDS'
              , i_env_param1 => i_number
              , i_env_param2 => i_data
            );
        end if;

        return l_pds_body;
    end;

    procedure extract_pds(
        de048                   in            mcw_api_type_pkg.t_de048
      , de062                   in            mcw_api_type_pkg.t_de062
      , de123                   in            mcw_api_type_pkg.t_de123
      , de124                   in            mcw_api_type_pkg.t_de124
      , de125                   in            mcw_api_type_pkg.t_de125
      , pds_tab                 in out nocopy mcw_api_type_pkg.t_pds_tab
    ) is
        de_body                 mcw_api_type_pkg.t_de048;
        de_length               integer;
        curr_pos                integer;
        pds_tag                 mcw_api_type_pkg.t_pds_tag;
        pds_len                 mcw_api_type_pkg.t_pds_len;
        pds_body                mcw_api_type_pkg.t_pds_body;
        de_name                 varchar2(5);
        curr_body               mcw_api_type_pkg.t_pds_body;
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

                    curr_body := substr(de_body, curr_pos, mcw_api_const_pkg.PDS_TAG_LEN);
                    if length(curr_body) = mcw_api_const_pkg.PDS_TAG_LEN then
                        begin
                            pds_tag := to_number(curr_body);
                        exception
                            when com_api_error_pkg.e_invalid_number or com_api_error_pkg.e_value_error then
                                com_api_error_pkg.raise_error(
                                    i_error       => 'PDS_ERROR_WRONG_TAG'
                                  , i_env_param1    => de_name
                                  , i_env_param2    => curr_pos
                                  , i_env_param3    => de_body
                                );
                        end;
                        curr_pos := curr_pos + mcw_api_const_pkg.PDS_TAG_LEN;
                    else
                        com_api_error_pkg.raise_error(
                            i_error       => 'PDS_ERROR_WRONG_TAG'
                          , i_env_param1    => de_name
                          , i_env_param2    => curr_pos
                          , i_env_param3    => de_body
                        );
                    end if;

                    curr_body := substr(de_body, curr_pos, mcw_api_const_pkg.PDS_LENGTH_LEN);
                    if length(curr_body) = mcw_api_const_pkg.PDS_LENGTH_LEN then
                        begin
                            pds_len := to_number(curr_body);
                        exception
                            when com_api_error_pkg.e_invalid_number or com_api_error_pkg.e_value_error then
                                com_api_error_pkg.raise_error(
                                    i_error       => 'PDS_ERROR_WRONG_LENGTH'
                                  , i_env_param1    => de_name
                                  , i_env_param2    => curr_pos
                                  , i_env_param3    => de_body
                                );

                        end;
                        curr_pos := curr_pos + mcw_api_const_pkg.PDS_LENGTH_LEN;
                    else
                        com_api_error_pkg.raise_error(
                            i_error       => 'PDS_ERROR_WRONG_LENGTH'
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
                            i_error       => 'PDS_ERROR_WRONG_BODY'
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

    procedure format_pds(
        i_pds_tab               in     mcw_api_type_pkg.t_pds_tab
      , o_de048                    out mcw_api_type_pkg.t_de048
      , o_de062                    out mcw_api_type_pkg.t_de062
      , o_de123                    out mcw_api_type_pkg.t_de123
      , o_de124                    out mcw_api_type_pkg.t_de124
      , o_de125                    out mcw_api_type_pkg.t_de125
    ) is
        LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.format_pds';
        i                       binary_integer;
        used_de                 integer := 0;
        de_body                 mcw_api_type_pkg.t_de048;
        pds_str                 mcw_api_type_pkg.t_de_body;
        pds_body                mcw_api_type_pkg.t_pds_body;
    begin
        if i_pds_tab.count > 0 then
            i := i_pds_tab.first;
            loop
                if i_pds_tab(i) is not null then
                    pds_body := format_pds_body(
                                    i_data    => i_pds_tab(i)
                                  , i_number  => i
                                );

                    if pds_body is not null then
                        pds_str := format_pds_tag(i)
                                || format_pds_len(length(pds_body))
                                || pds_body;

                        if nvl(length(de_body), 0) + length(pds_str) > mcw_api_const_pkg.MAX_PDS_DE_LEN then
                            case
                                when used_de = 0 then o_de048 := de_body;
                                when used_de = 1 then o_de062 := de_body;
                                when used_de = 2 then o_de123 := de_body;
                                when used_de = 3 then o_de124 := de_body;
                                when used_de = 4 then
                                    com_api_error_pkg.raise_error(
                                        i_error       => 'PDS_ERROR_TOO_MANY'
                                    );
                            end case;

                            used_de := used_de + 1;
                            de_body := null;
                        end if;

                        de_body := de_body || pds_str;
                    end if;
                end if;

                i := i_pds_tab.next(i);
                exit when i is null;
            end loop;

            if de_body is not null then
                case
                    when used_de = 0 then o_de048 := de_body;
                    when used_de = 1 then o_de062 := de_body;
                    when used_de = 2 then o_de123 := de_body;
                    when used_de = 3 then o_de124 := de_body;
                    when used_de = 4 then o_de125 := de_body;
                end case;
            end if;
        end if;

        --trc_log_pkg.debug(
        --    i_text       => LOG_PREFIX || ' >> de048 [#1], de062 [#2], de123 [#3], de124 [#4], de125 [#5]'
        --  , i_env_param1 => o_de048
        --  , i_env_param2 => o_de062
        --  , i_env_param3 => o_de123
        --  , i_env_param4 => o_de124
        --  , i_env_param5 => o_de125
        --);
    end format_pds;

    function get_pds_body (
        i_pds_tab               in mcw_api_type_pkg.t_pds_tab
        , i_pds_tag             in mcw_api_type_pkg.t_pds_tag
    ) return mcw_api_type_pkg.t_pds_body is
    begin
        if i_pds_tab.exists(i_pds_tag) then
            return i_pds_tab(i_pds_tag);
        else
            return null;
        end if;
    end;

    procedure set_pds_body (
        io_pds_tab            in out nocopy mcw_api_type_pkg.t_pds_tab
      , i_pds_tag             in            mcw_api_type_pkg.t_pds_tag
      , i_pds_body            in            mcw_api_type_pkg.t_pds_body
    ) is
    begin
        if i_pds_body is null then
            io_pds_tab.delete(i_pds_tag);
        else
            io_pds_tab(i_pds_tag) := i_pds_body;
        end if;
    end;

    procedure read_pds (
        i_msg_id                in            com_api_type_pkg.t_long_id
      , o_pds_tab               in out nocopy mcw_api_type_pkg.t_pds_tab
    ) is
        l_pds_tab               mcw_api_type_pkg.t_pds_row_tab;
    begin
        o_pds_tab.delete;

        select msg_id
             , pds_number
             , pds_body
          bulk collect into
               l_pds_tab
          from mcw_msg_pds
         where msg_id = i_msg_id;

        for i in 1 .. l_pds_tab.count loop
            o_pds_tab(l_pds_tab(i).pds_number) := l_pds_tab(i).pds_body;
        end loop;
    end;

    procedure save_pds(
        i_msg_id                in            com_api_type_pkg.t_long_id
      , i_pds_tab               in out nocopy mcw_api_type_pkg.t_pds_tab
      , i_clear                 in            com_api_type_pkg.t_boolean
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
                mcw_msg_pds
            where
                msg_id = i_msg_id;

            forall i in indices of i_pds_tab
                insert into mcw_msg_pds (
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
                    mcw_msg_pds dst
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

    function format_p0004 (
        i_p0004_1               in mcw_api_type_pkg.t_p0004_1
        , i_p0004_2             in mcw_api_type_pkg.t_p0004_2
    ) return mcw_api_type_pkg.t_pds_body is
    begin
        if i_p0004_1 is null then
            return null;
        else
            return i_p0004_1 || i_p0004_2;
        end if;
    end;

    function format_p0025 (
        i_p0025_1               in mcw_api_type_pkg.t_p0025_1
        , i_p0025_2             in mcw_api_type_pkg.t_p0025_2
    ) return mcw_api_type_pkg.t_pds_body is
    begin
        if i_p0025_1 is null then
            return null;
        else
            return i_p0025_1
                || to_char(i_p0025_2, mcw_api_const_pkg.P0025_DATE_FORMAT);
        end if;
    end;

    function format_p0268 (
        i_p0268_1               in mcw_api_type_pkg.t_p0268_1
        , i_p0268_2             in mcw_api_type_pkg.t_p0268_2
    ) return mcw_api_type_pkg.t_pds_body is
    begin
        if i_p0268_1 is null then
            return null;
        else
            return mcw_utl_pkg.pad_number(i_p0268_1, 12, 12)
                || mcw_utl_pkg.pad_number(nvl(i_p0268_2, '0'), 3, 3);
        end if;

    end;

    function format_p0149 (
        i_p0149_1               in mcw_api_type_pkg.t_p0149_1
        , i_p0149_2             in mcw_api_type_pkg.t_p0149_2
    ) return mcw_api_type_pkg.t_pds_body is
    begin
        if i_p0149_1 is null then
            return null;
        else
            return mcw_utl_pkg.pad_number(i_p0149_1, 3, 3)
                || mcw_utl_pkg.pad_number(nvl(i_p0149_2, '0'), 3, 3);
        end if;
    end;

    function format_p0158 (
        i_p0158_1               in mcw_api_type_pkg.t_p0158_1
      , i_p0158_2               in mcw_api_type_pkg.t_p0158_2
      , i_p0158_3               in mcw_api_type_pkg.t_p0158_3
      , i_p0158_4               in mcw_api_type_pkg.t_p0158_4
      , i_p0158_5               in mcw_api_type_pkg.t_p0158_5
      , i_p0158_6               in mcw_api_type_pkg.t_p0158_6
      , i_p0158_7               in mcw_api_type_pkg.t_p0158_7
      , i_p0158_8               in mcw_api_type_pkg.t_p0158_8
      , i_p0158_9               in mcw_api_type_pkg.t_p0158_9
      , i_p0158_10              in mcw_api_type_pkg.t_p0158_10
      , i_p0158_11              in mcw_api_type_pkg.t_p0158_11
      , i_p0158_12              in mcw_api_type_pkg.t_p0158_12
      , i_p0158_13              in mcw_api_type_pkg.t_p0158_13
      , i_p0158_14              in mcw_api_type_pkg.t_p0158_14
    ) return mcw_api_type_pkg.t_pds_body
    is
    begin
        if i_p0158_4 is null then
            return null;
        else
            return mcw_utl_pkg.pad_char(nvl(i_p0158_1, ' '), 3, 3)
                || mcw_utl_pkg.pad_char(nvl(i_p0158_2, ' '), 1, 1)
                || mcw_utl_pkg.pad_char(nvl(i_p0158_3, ' '), 6, 6)
                || mcw_utl_pkg.pad_number(i_p0158_4, 2, 2);
        end if;
    end;

    function format_p0181(
        i_host_id               in     com_api_type_pkg.t_tiny_id
      , i_installment_data_1    in     com_api_type_pkg.t_param_value
      , i_installment_data_2    in     com_api_type_pkg.t_param_value
    ) return com_api_type_pkg.t_name
    is
        l_subfield                     com_api_type_pkg.t_cmid;
        l_result                       com_api_type_pkg.t_name;
        l_char                         com_api_type_pkg.t_name;
    begin
        l_subfield := substr(i_installment_data_1, 1, 2); --Type of installment - sf_1
        l_result   := l_subfield;

        l_subfield := substr(i_installment_data_2, 1, 2); --Number of installments - sf_2
        l_result   := l_result || l_subfield;

        l_char := '0';

        l_subfield := lpad(nvl(trim(substr(i_installment_data_2, 3, 5)), l_char), 5, l_char); --Interest Rate - sf_3
        l_result   := l_result || l_subfield;

        l_subfield := lpad(nvl(trim(substr(i_installment_data_2, 25, 12)), l_char), 12, l_char); --First Installment Amount - sf_4
        l_result   := l_result || l_subfield;

        l_subfield := lpad(nvl(trim(substr(i_installment_data_2, 37, 12)), l_char), 12, l_char); --Subsequent Installment Amount - sf_5
        l_result   := l_result || l_subfield;

        l_subfield := lpad(nvl(trim(substr(i_installment_data_2, 20, 5)), l_char), 5, l_char); --Annual Percentage Rate - sf_6
        l_result   := l_result || l_subfield;

        l_subfield := lpad(nvl(trim(substr(i_installment_data_2, 8, 12)), l_char), 12, l_char); --Installment Fee - sf_7
        l_result   := l_result || l_subfield;

        return l_result;

    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error       => 'MCW_ERROR_WRONG_VALUE'
              , i_env_param1  => 'P0181'
              , i_env_param2  => l_subfield
            );
    end format_p0181;

    function format_p0200 (
        i_p0200_1               in mcw_api_type_pkg.t_p0200_1
      , i_p0200_2               in mcw_api_type_pkg.t_p0200_2
    ) return mcw_api_type_pkg.t_pds_body
    is
    begin
        if i_p0200_1 is null then
            return null;
        else
            return mcw_utl_pkg.pad_char(to_char(i_p0200_1, 'YYMMDD'), 6, 6)
                || mcw_utl_pkg.pad_number(nvl(i_p0200_2, ' '), 2, 2);
        end if;
    end;

    function format_p0208 (
        i_p0208_1               in mcw_api_type_pkg.t_p0208_1
      , i_p0208_2               in mcw_api_type_pkg.t_p0208_2
    ) return mcw_api_type_pkg.t_pds_body
    is
    begin
        if i_p0208_1 is null then
            return null;
        else
            return mcw_utl_pkg.pad_number(nvl(i_p0208_1, '0'), 11, 11)
                || mcw_utl_pkg.pad_char(nvl(i_p0208_2, ' '), 15, 15);
        end if;
    end;

    function format_p0210 (
        i_p0210_1               in mcw_api_type_pkg.t_p0210_1
      , i_p0210_2               in mcw_api_type_pkg.t_p0210_2
    ) return mcw_api_type_pkg.t_pds_body
    is
    begin
        if i_p0210_1 is null then
            return null;
        else
            return mcw_utl_pkg.pad_char(nvl(i_p0210_1, '0'), 2, 2)
                || mcw_utl_pkg.pad_char(nvl(i_p0210_2, '0'), 2, 2);
        end if;
    end;

    procedure parse_p0001 (
        i_p0001                in mcw_api_type_pkg.t_pds_body
        , o_p0001_1            out mcw_api_type_pkg.t_p0001_1
        , o_p0001_2            out mcw_api_type_pkg.t_p0001_2
    )  is
        l_curr_pos              pls_integer;
    begin
        l_curr_pos := 1;
        o_p0001_1 := trim(substr(i_p0001, l_curr_pos, 2));
        l_curr_pos := l_curr_pos + 2;
        o_p0001_2 := trim(substr(i_p0001, l_curr_pos, 19));
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error       => 'MCW_ERROR_WRONG_VALUE'
              , i_env_param1  => 'P0001'
              , i_env_param2  => l_curr_pos
              , i_env_param3  => i_p0001
            );
    end;

    procedure parse_p0004 (
        i_p0004                in mcw_api_type_pkg.t_pds_body
        , o_p0004_1            out mcw_api_type_pkg.t_p0004_1
        , o_p0004_2            out mcw_api_type_pkg.t_p0004_2
    )  is
        l_curr_pos              pls_integer;
    begin
        l_curr_pos := 1;
        o_p0004_1 := trim(substr(i_p0004, l_curr_pos, 2));
        l_curr_pos := l_curr_pos + 2;
        o_p0004_2 := trim(substr(i_p0004, l_curr_pos, 34));
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error       => 'MCW_ERROR_WRONG_VALUE'
              , i_env_param1  => 'P0004'
              , i_env_param2  => l_curr_pos
              , i_env_param3  => i_p0004
            );
    end;

    procedure parse_p0005 (
        i_p0005                  in mcw_api_type_pkg.t_pds_body
        , o_reject_code_tab      out nocopy mcw_api_type_pkg.t_reject_code_tab
    ) is
        l_reject_code           mcw_api_type_pkg.t_reject_code_rec;
        l_length                integer;
        l_curr_pos              integer;
        l_curr_pos2             integer;
        l_curr_body             mcw_api_type_pkg.t_pds_body;
        l_pds_tag               mcw_api_type_pkg.t_pds_body;
    begin
        o_reject_code_tab.delete;

        l_curr_pos := 1;
        l_length := nvl(length(i_p0005), 0);
        l_pds_tag := 'P0005';

        loop
            exit when l_curr_pos > l_length;

            l_curr_pos2 := 1;
            l_reject_code := null;

            l_curr_body := substr(i_p0005, l_curr_pos, mcw_api_const_pkg.P0005_PART_LENGTH);
            if length(l_curr_body) = mcw_api_const_pkg.P0005_PART_LENGTH then
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
                            i_error       => 'MCW_ERROR_WRONG_VALUE'
                        , i_env_param1  => l_pds_tag
                        , i_env_param2  => l_curr_pos2
                        , i_env_param3  => l_curr_body
                        );
                end;

                l_curr_pos := l_curr_pos + mcw_api_const_pkg.P0005_PART_LENGTH;
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
        i_p0025                 in mcw_api_type_pkg.t_pds_body
        , o_p0025_1             out mcw_api_type_pkg.t_p0025_1
        , o_p0025_2             out mcw_api_type_pkg.t_p0025_2
    ) is
        l_curr_pos               pls_integer;
    begin
        l_curr_pos := 1;
        o_p0025_1 := substr(i_p0025, l_curr_pos, 1);
        l_curr_pos := l_curr_pos + 1;
        o_p0025_2 := to_date(substr(i_p0025, l_curr_pos, 6), mcw_api_const_pkg.P0025_DATE_FORMAT);
    exception
        when others then
            com_api_error_pkg.raise_error(
                i_error       => 'MCW_ERROR_WRONG_VALUE'
              , i_env_param1  => 'P0025'
              , i_env_param2  => l_curr_pos
              , i_env_param3  => i_p0025
           );
    end;

    procedure parse_p0105 (
        i_p0105                 in mcw_api_type_pkg.t_pds_body
        , o_file_type           out mcw_api_type_pkg.t_pds_body
        , o_file_date           out date
        , o_cmid                out com_api_type_pkg.t_cmid
    ) is
        l_curr_pos              pls_integer;
    begin
        l_curr_pos := 1;
        o_file_type := substr(i_p0105, l_curr_pos, 3);
        l_curr_pos := l_curr_pos + 3;
        o_file_date := to_date(substr(i_p0105, l_curr_pos, 6), mcw_api_const_pkg.P0105_DATE_FORMAT);
        l_curr_pos := l_curr_pos + 6;
        o_cmid := substr(i_p0105, 10, 11);
    exception
        when others then
            com_api_error_pkg.raise_error(
                 i_error       => 'MCW_ERROR_WRONG_VALUE'
               , i_env_param1  => 'P0105'
               , i_env_param2  => l_curr_pos
               , i_env_param3  => i_p0105
             );
    end;

    procedure parse_p0146(
        i_pds_body              in  mcw_api_type_pkg.t_pds_body
      , o_p0146                 out mcw_api_type_pkg.t_p0146
      , o_p0146_net             out mcw_api_type_pkg.t_p0146_net
      , i_is_p0147              in  com_api_type_pkg.t_boolean
    ) is
        l_pds_tag               com_api_type_pkg.t_name;
        l_pds_part_length       mcw_api_type_pkg.t_pds_len;
        l_curr_pos              integer;
        l_p0146_tab             mcw_api_type_pkg.t_pds_tab;
    begin
        trc_log_pkg.debug(
            i_text       => 'parse_p0146: i_pds_body [#1], i_is_p0147 [#2]'
          , i_env_param1 => i_pds_body
          , i_env_param2 => i_is_p0147
        );

        case
            when i_is_p0147 = com_api_type_pkg.TRUE then
                l_pds_tag         := 'P0147';
                l_pds_part_length := mcw_api_const_pkg.P0147_PART_LENGTH;
            else
                l_pds_tag         := 'P0146';
                l_pds_part_length := mcw_api_const_pkg.P0146_PART_LENGTH;
        end case;

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
                l_p0146_tab(4) := substr(i_pds_body, l_curr_pos + 6, 3); -- Currency Code, Fee
                case
                    when i_is_p0147 = com_api_type_pkg.TRUE then
                         -- Amount, Fee
                        l_p0146_tab(5) := substr(
                                              i_pds_body
                                            , l_curr_pos + 9 + com_api_currency_pkg.get_currency_exponent(i_curr_code => l_p0146_tab(4))
                                            , 12
                                          );
                         -- Currency Code, Fee, Reconcilation
                        l_p0146_tab(6) := substr(i_pds_body, l_curr_pos + 27,  3);
                        -- Amount, Fee, Reconcilation
                        l_p0146_tab(7) := substr(
                                              i_pds_body
                                            , l_curr_pos + 30 + com_api_currency_pkg.get_currency_exponent(i_curr_code => l_p0146_tab(6))
                                            , 12
                                          );
                    else
                        l_p0146_tab(5) := substr(i_pds_body, l_curr_pos + 9,  12); -- Amount, Fee
                        l_p0146_tab(6) := substr(i_pds_body, l_curr_pos + 21,  3); -- Currency Code, Fee, Reconcilation
                        l_p0146_tab(7) := substr(i_pds_body, l_curr_pos + 24, 12); -- Amount, Fee, Reconcilation
                end case;

                --trc_log_pkg.debug(
                --    i_text => 'l_curr_pos [' || l_curr_pos || '], l_p0146_tab: ['
                --           || l_p0146_tab(1) || '] [' || l_p0146_tab(2) || '] ['
                --           || l_p0146_tab(3) || '] [' || l_p0146_tab(4) || '] ['
                --           || l_p0146_tab(5) || '] [' || l_p0146_tab(6) || '] [' || l_p0146_tab(7) || ']'
                --);

                if l_p0146_tab(1) = '00' and l_p0146_tab(3) = '01' then
                    o_p0146_net := nvl(o_p0146_net, 0)
                                 + to_number(l_p0146_tab(7)) *
                                   case l_p0146_tab(2)
                                       when mcw_api_const_pkg.PROC_CODE_CREDIT_FEE then -1 -- credit to originator, debit to destination
                                       when mcw_api_const_pkg.PROC_CODE_DEBIT_FEE  then  1 -- debit to originator, credit to destination
                                                                                   else  0
                                   end;
                end if;
            exception
                when com_api_error_pkg.e_invalid_number then
                    com_api_error_pkg.raise_error(
                        i_error      => 'MCW_ERROR_WRONG_VALUE'
                      , i_env_param1 => l_pds_tag
                      , i_env_param2 => l_curr_pos -- actual only for subfield 5 and 7
                      , i_env_param3 => i_pds_body
                    );
            end;

            if i_is_p0147 = com_api_type_pkg.TRUE then
                for i in 1 .. l_p0146_tab.count() loop
                    o_p0146 := o_p0146 || l_p0146_tab(i);
                end loop;
            end if;

            l_curr_pos := l_curr_pos + l_pds_part_length;
        end loop;
    end parse_p0146;

    procedure parse_p0149 (
        i_p0149                 in mcw_api_type_pkg.t_pds_body
        , o_p0149_1             out mcw_api_type_pkg.t_p0149_1
        , o_p0149_2             out mcw_api_type_pkg.t_p0149_1
    ) is
        l_curr_pos               pls_integer;
    begin
        l_curr_pos := 1;
        o_p0149_1 := substr(i_p0149, l_curr_pos, 3);
        l_curr_pos := l_curr_pos + 3;
        o_p0149_2 := substr(i_p0149, l_curr_pos, 3);
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error       => 'MCW_ERROR_WRONG_VALUE'
              , i_env_param1  => 'P0149'
              , i_env_param2  => l_curr_pos
              , i_env_param3  => i_p0149
            );
    end;

    procedure parse_p0158 (
        i_p0158                in mcw_api_type_pkg.t_pds_body
        , o_p0158_1            out mcw_api_type_pkg.t_p0158_1
        , o_p0158_2            out mcw_api_type_pkg.t_p0158_2
        , o_p0158_3            out mcw_api_type_pkg.t_p0158_3
        , o_p0158_4            out mcw_api_type_pkg.t_p0158_4
        , o_p0158_5            out mcw_api_type_pkg.t_p0158_5
        , o_p0158_6            out mcw_api_type_pkg.t_p0158_6
        , o_p0158_7            out mcw_api_type_pkg.t_p0158_7
        , o_p0158_8            out mcw_api_type_pkg.t_p0158_8
        , o_p0158_9            out mcw_api_type_pkg.t_p0158_9
        , o_p0158_10           out mcw_api_type_pkg.t_p0158_10
        , o_p0158_11           out mcw_api_type_pkg.t_p0158_11
        , o_p0158_12           out mcw_api_type_pkg.t_p0158_12
        , o_p0158_13           out mcw_api_type_pkg.t_p0158_13
        , o_p0158_14           out mcw_api_type_pkg.t_p0158_14
    ) is
        l_curr_pos              pls_integer;
    begin
        l_curr_pos := 1;
        o_p0158_1 := substr(i_p0158, l_curr_pos, 3);
        l_curr_pos := l_curr_pos + 3;
        o_p0158_2 := substr(i_p0158, l_curr_pos, 1);
        l_curr_pos := l_curr_pos + 1;
        o_p0158_3 := substr(i_p0158, l_curr_pos, 6);
        l_curr_pos := l_curr_pos + 6;
        o_p0158_4 := substr(i_p0158, l_curr_pos, 2);
        l_curr_pos := l_curr_pos + 2;
        o_p0158_5 := to_date(substr(i_p0158, l_curr_pos, 6), mcw_api_const_pkg.P0158_DATE_FORMAT);
        l_curr_pos := l_curr_pos + 6;
        o_p0158_6 := to_number(substr(i_p0158, l_curr_pos, 2));
        l_curr_pos := l_curr_pos + 2;
        o_p0158_7 := substr(i_p0158, l_curr_pos, 1);
        l_curr_pos := l_curr_pos + 1;
        o_p0158_8 := substr(i_p0158, l_curr_pos, 3);
        l_curr_pos := l_curr_pos + 3;
        o_p0158_9 := substr(i_p0158, l_curr_pos, 1);
        l_curr_pos := l_curr_pos + 1;
        o_p0158_10 := substr(i_p0158, l_curr_pos, 1);
        l_curr_pos := l_curr_pos + 1;
        o_p0158_11 := substr(i_p0158, l_curr_pos, 1);
        l_curr_pos := l_curr_pos + 1;
        o_p0158_12 := substr(i_p0158, l_curr_pos, 1);
        l_curr_pos := l_curr_pos + 1;
        o_p0158_13 := substr(i_p0158, l_curr_pos, 1);
        l_curr_pos := l_curr_pos + 1;
        o_p0158_14 := substr(i_p0158, l_curr_pos, 1);
    exception
        when others then
            com_api_error_pkg.raise_error(
                i_error       => 'MCW_ERROR_WRONG_VALUE'
              , i_env_param1  => 'P0158'
              , i_env_param2  => l_curr_pos
              , i_env_param3  => i_p0158
            );
    end;

    procedure parse_p0159 (
        i_p0159                in mcw_api_type_pkg.t_pds_body
        , o_p0159_1            out mcw_api_type_pkg.t_p0159_1
        , o_p0159_2            out mcw_api_type_pkg.t_p0159_2
        , o_p0159_3            out mcw_api_type_pkg.t_p0159_3
        , o_p0159_4            out mcw_api_type_pkg.t_p0159_4
        , o_p0159_5            out mcw_api_type_pkg.t_p0159_5
        , o_p0159_6            out mcw_api_type_pkg.t_p0159_6
        , o_p0159_7            out mcw_api_type_pkg.t_p0159_7
        , o_p0159_8            out mcw_api_type_pkg.t_p0159_8
        , o_p0159_9            out mcw_api_type_pkg.t_p0159_9
    ) is
        l_curr_pos              pls_integer;
    begin
        if rtrim(i_p0159) is not null then
            l_curr_pos := 1;
            o_p0159_1 := substr(i_p0159, l_curr_pos, 11);
            l_curr_pos := l_curr_pos + 11;
            o_p0159_2 := substr(i_p0159, l_curr_pos, 28);
            l_curr_pos := l_curr_pos + 28;
            o_p0159_3 := to_number(rtrim(substr(i_p0159, l_curr_pos, 1)));
            l_curr_pos := l_curr_pos + 1;
            o_p0159_4 := substr(i_p0159, l_curr_pos, 10);
            l_curr_pos := l_curr_pos + 10;
            o_p0159_5 := substr(i_p0159, l_curr_pos, 1);
            l_curr_pos := l_curr_pos + 1;

            if rtrim(substr(i_p0159, l_curr_pos, 6), 0) is not null then
                o_p0159_6 := to_date(rtrim(substr(i_p0159, l_curr_pos, 6)), mcw_api_const_pkg.P0159_DATE_FORMAT);
            end if;
            l_curr_pos := l_curr_pos + 6;

            o_p0159_7 := to_number(rtrim(substr(i_p0159, l_curr_pos, 2)));
            l_curr_pos := l_curr_pos + 2;

            if rtrim(substr(i_p0159, l_curr_pos, 6), 0) is not null then
                o_p0159_8 := to_date(rtrim(substr(i_p0159, l_curr_pos, 6)), mcw_api_const_pkg.P0159_DATE_FORMAT);
            end if;
            l_curr_pos := l_curr_pos + 6;

            o_p0159_9 := to_number(rtrim(substr(i_p0159, l_curr_pos, 2)));
        end if;
    exception
        when others then
            com_api_error_pkg.raise_error(
                i_error       => 'MCW_ERROR_WRONG_VALUE'
              , i_env_param1  => 'P0159'
              , i_env_param2  => l_curr_pos
              , i_env_param3  => i_p0159
            );
    end;

    procedure parse_p0164(
        i_p0164                 in     mcw_api_type_pkg.t_pds_body
      , i_de050                 in     mcw_api_type_pkg.t_de050
      , o_cur_rate_tab             out mcw_api_type_pkg.t_cur_rate_tab
    ) is
        l_cur_rate_rec          mcw_api_type_pkg.t_cur_rate_rec;
        l_length                integer;
        l_curr_pos              integer;
        l_curr_pos2             integer;
        l_curr_body             mcw_api_type_pkg.t_pds_body;
        l_pds_tag               mcw_api_type_pkg.t_pds_body;
    begin
        l_curr_pos := 1;
        l_length   := nvl(length(i_p0164), 0);
        l_pds_tag  := 'P0164';

        loop
            exit when l_curr_pos > l_length;

            l_curr_pos2 := 1;
            l_cur_rate_rec := null;

            l_curr_body := substr(i_p0164, l_curr_pos, mcw_api_const_pkg.P0164_PART_LENGTH);
            if length(l_curr_body) = mcw_api_const_pkg.P0164_PART_LENGTH then
                begin
                    -- Currency Code
                    l_cur_rate_rec.p0164_1 := substr(l_curr_body, l_curr_pos2, 3);
                    l_curr_pos2 := l_curr_pos2 + 3;

                    -- Currency Conversion Rate
                    l_cur_rate_rec.p0164_2 := to_number(substr(l_curr_body, l_curr_pos2+1, 10))
                                              / (10 ** to_number(substr(l_curr_body, l_curr_pos2, 1)));
                    l_curr_pos2 := l_curr_pos2 + 11;

                    -- Currency Conversion Type
                    l_cur_rate_rec.p0164_3 := substr(l_curr_body, l_curr_pos2, 1);
                    l_curr_pos2 := l_curr_pos2 + 1;
                    -- Business Date
                    l_cur_rate_rec.p0164_4 := to_date(substr(l_curr_body, l_curr_pos2, 6), mcw_api_const_pkg.P0164_4_DATE_FORMAT);
                    l_curr_pos2 := l_curr_pos2 + 6;
                    -- Delivery Cycle
                    l_cur_rate_rec.p0164_5 := to_number(substr(l_curr_body, l_curr_pos2, 2));
                    l_curr_pos2 := l_curr_pos2 + 2;

                    l_cur_rate_rec.de050 := i_de050;
                exception
                    when com_api_error_pkg.e_invalid_number then
                        com_api_error_pkg.raise_error(
                            i_error       => 'MCW_ERROR_WRONG_VALUE'
                          , i_env_param1  => l_pds_tag
                          , i_env_param2  => l_curr_pos2
                          , i_env_param3  => l_curr_body
                        );
                end;

                l_curr_pos := l_curr_pos + mcw_api_const_pkg.P0164_PART_LENGTH;
            else
                com_api_error_pkg.raise_error(
                    i_error       => 'PDS_ERROR_WRONG_LENGTH'
                  , i_env_param1  => l_pds_tag
                  , i_env_param2  => l_curr_pos
                  , i_env_param3  => i_p0164
                );
            end if;

            o_cur_rate_tab(o_cur_rate_tab.count+1) := l_cur_rate_rec;
        end loop;
    end;

    procedure parse_p0200 (
        i_p0200                in mcw_api_type_pkg.t_pds_body
        , o_p0200_1            out mcw_api_type_pkg.t_p0200_1
        , o_p0200_2            out mcw_api_type_pkg.t_p0200_2
    ) is
        l_curr_pos              pls_integer;
    begin
        l_curr_pos := 1;
        o_p0200_1 := to_date(trim(substr(i_p0200, l_curr_pos, 6)),'YYMMDD');
        l_curr_pos := l_curr_pos + 6;
        o_p0200_2 := trim(substr(i_p0200, l_curr_pos, 2));
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error       => 'MCW_ERROR_WRONG_VALUE'
              , i_env_param1  => 'P0200'
              , i_env_param2  => l_curr_pos
              , i_env_param3  => i_p0200
            );
    end;

    procedure parse_p0208 (
        i_p0208                in mcw_api_type_pkg.t_pds_body
        , o_p0208_1            out mcw_api_type_pkg.t_p0208_1
        , o_p0208_2            out mcw_api_type_pkg.t_p0208_2
    )  is
        l_curr_pos              pls_integer;
    begin
        l_curr_pos := 1;
        o_p0208_1 :=trim(substr(i_p0208, l_curr_pos, 11));
        l_curr_pos := l_curr_pos + 11;
        o_p0208_2 := trim(substr(i_p0208, l_curr_pos, 15));
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error       => 'MCW_ERROR_WRONG_VALUE'
              , i_env_param1  => 'P0208'
              , i_env_param2  => l_curr_pos
              , i_env_param3  => i_p0208
            );
    end;

    procedure parse_p0210 (
        i_p0210                in mcw_api_type_pkg.t_pds_body
        , o_p0210_1            out mcw_api_type_pkg.t_p0210_1
        , o_p0210_2            out mcw_api_type_pkg.t_p0210_2
    )  is
        l_curr_pos              pls_integer;
    begin
        l_curr_pos := 1;
        o_p0210_1 :=trim(substr(i_p0210, l_curr_pos, 2));
        l_curr_pos := l_curr_pos + 2;
        o_p0210_2 := trim(substr(i_p0210, l_curr_pos, 2));
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error       => 'MCW_ERROR_WRONG_VALUE'
              , i_env_param1  => 'P0210'
              , i_env_param2  => l_curr_pos
              , i_env_param3  => i_p0210
            );
    end;

    procedure parse_p0268 (
        i_p0268                in mcw_api_type_pkg.t_pds_body
        , o_p0268_1            out mcw_api_type_pkg.t_p0268_1
        , o_p0268_2            out mcw_api_type_pkg.t_p0268_2
    ) is
        l_curr_pos              pls_integer;
    begin
        l_curr_pos := 1;
        o_p0268_1 := to_number(trim(substr(i_p0268, l_curr_pos, 12)));
        l_curr_pos := l_curr_pos + 12;
        o_p0268_2 := trim(substr(i_p0268, l_curr_pos, 3));
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error       => 'MCW_ERROR_WRONG_VALUE'
              , i_env_param1  => 'P0268'
              , i_env_param2  => l_curr_pos
              , i_env_param3  => i_p0268
            );
    end;

    procedure parse_p0370 (
        i_p0370                 in mcw_api_type_pkg.t_pds_body
        , o_p0370_1             out mcw_api_type_pkg.t_p0370_1
        , o_p0370_2             out mcw_api_type_pkg.t_p0370_2
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
                i_error       => 'MCW_ERROR_WRONG_VALUE'
              , i_env_param1  => 'P0370'
              , i_env_param2  => l_curr_pos
              , i_env_param3  => i_p0370
            );
    end;

    procedure parse_p0372 (
        i_p0372                 in mcw_api_type_pkg.t_pds_body
        , o_p0372_1             out mcw_api_type_pkg.t_p0372_1
        , o_p0372_2             out mcw_api_type_pkg.t_p0372_2
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
                i_error       => 'MCW_ERROR_WRONG_VALUE'
              , i_env_param1  => 'P0372'
              , i_env_param2  => l_curr_pos
              , i_env_param3  => i_p0372
            );
    end;

    procedure parse_p0380 (
        i_pds_body              in     mcw_api_type_pkg.t_pds_body
        , i_pds_name            in     mcw_api_type_pkg.t_pds_body
        , o_p0380_1                out mcw_api_type_pkg.t_p0380_1
        , o_p0380_2                out mcw_api_type_pkg.t_p0380_2
    ) is
        l_curr_pos                     pls_integer;
    begin
        l_curr_pos := 1;
        o_p0380_1 := substr(i_pds_body, 1, 1);
        l_curr_pos := l_curr_pos + 1;
        o_p0380_2 := nvl(to_number(substr(i_pds_body, 2)), 0);
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error       => 'MCW_ERROR_WRONG_VALUE'
              , i_env_param1  => i_pds_name
              , i_env_param2  => l_curr_pos
              , i_env_param3  => i_pds_body
            );
    end;

    procedure parse_p0399 (
        i_pds_body           in     mcw_api_type_pkg.t_pds_body
      , i_pds_name           in     mcw_api_type_pkg.t_pds_body
      , o_p0399_1               out mcw_api_type_pkg.t_p0399_1
      , o_p0399_2               out mcw_api_type_pkg.t_p0399_2
    ) is
        l_curr_pos                     pls_integer;
    begin
        l_curr_pos := 1;
        o_p0399_1  := substr(i_pds_body, 1, 1);
        l_curr_pos := l_curr_pos + 1;
        o_p0399_2  := nvl(to_number(substr(i_pds_body, 2)), 0);
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error       => 'MCW_ERROR_WRONG_VALUE'
              , i_env_param1  => i_pds_name
              , i_env_param2  => l_curr_pos
              , i_env_param3  => i_pds_body
            );
    end;

    procedure parse_p0501 (
        i_p0501                in     mcw_api_type_pkg.t_pds_body
        , o_p0501_1               out mcw_api_type_pkg.t_p0501_1
        , o_p0501_2               out mcw_api_type_pkg.t_p0501_2
        , o_p0501_3               out mcw_api_type_pkg.t_p0501_3
        , o_p0501_4               out mcw_api_type_pkg.t_p0501_4
    ) is
        l_curr_pos                    pls_integer;
    begin
        l_curr_pos := 1;
        o_p0501_1 := to_number(substr(i_p0501, l_curr_pos, 2));
        l_curr_pos := l_curr_pos + 2;
        o_p0501_2 := to_number(substr(i_p0501, l_curr_pos, 3));
        l_curr_pos := l_curr_pos + 3;
        o_p0501_3 := to_number(substr(i_p0501, l_curr_pos, 3));
        l_curr_pos := l_curr_pos + 3;
        o_p0501_4 := to_number(substr(i_p0501, l_curr_pos, 8));
    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error       => 'MCW_ERROR_WRONG_VALUE'
              , i_env_param1  => 'P0501'
              , i_env_param2  => l_curr_pos
              , i_env_param3  => i_p0501
            );
    end;

    procedure parse_p0715(
        i_p0715              in     mcw_api_type_pkg.t_pds_body
      , o_p0715                 out mcw_api_type_pkg.t_p0715
    ) is
    begin
        o_p0715 := i_p0715;
        -- additional parsing can be added here, if need
    end;

    procedure parse_p0181(
        i_p0181                 in      com_api_type_pkg.t_name
      , o_installment_data_1       out  com_api_type_pkg.t_param_value
      , o_installment_data_2       out  com_api_type_pkg.t_param_value
    ) is
        l_installment_data_1            com_api_type_pkg.t_param_value := substr(i_p0181, 1, 2);
        l_installment_data_2            com_api_type_pkg.t_param_value := substr(i_p0181, 3);
        l_sf_2                          com_api_type_pkg.t_name;
        l_sf_3                          com_api_type_pkg.t_name;
        l_sf_4                          com_api_type_pkg.t_name;
        l_sf_5                          com_api_type_pkg.t_name;
        l_sf_6                          com_api_type_pkg.t_name;
        l_sf_7                          com_api_type_pkg.t_name;
        l_sf_8                          com_api_type_pkg.t_name;
        l_sf_9                          com_api_type_pkg.t_name;
        l_sf_10                         com_api_type_pkg.t_name;
        l_char                          com_api_type_pkg.t_name := '0';
        l_space                         com_api_type_pkg.t_name := ' ';
    begin
        if l_installment_data_1 is not null then
            l_sf_2 := substr(l_installment_data_2, 1, 2);   -- Number of Installments
            l_sf_3 := lpad(nvl(ltrim(substr(l_installment_data_2, 3, 5), l_char), l_space), 5, l_space);        -- Interest Rate
            l_sf_4 := lpad(nvl(ltrim(substr(l_installment_data_2, 8, 12), l_char), l_space), 12, l_space);      -- First Installment Amount
            l_sf_5 := lpad(nvl(ltrim(substr(l_installment_data_2, 20, 12), l_char), l_space), 12, l_space);     -- Subsequent Installment Amount
            l_sf_6 := lpad(nvl(ltrim(substr(l_installment_data_2, 32, 5), l_char), l_space), 5, l_space);       -- Annual Percentage Rate
            l_sf_7 := lpad(nvl(ltrim(substr(l_installment_data_2, 37, 12), l_char), l_space), 12, l_space);     -- Installment Fee
            l_sf_8 := lpad(nvl(ltrim(substr(l_installment_data_2, 49, 5), l_char), l_space), 5, l_space);       -- Comission Rate
            l_sf_9 := lpad(nvl(ltrim(substr(l_installment_data_2, 54, 1), l_char), l_space), 1, l_space);       -- Commission Sign
            l_sf_10 := lpad(nvl(ltrim(substr(l_installment_data_2, 55, 12), l_char), l_space), 12, l_space);    -- Commission Amount

           l_installment_data_2 := 
                l_sf_2 ||
                l_sf_3 ||
                l_sf_7 ||
                l_sf_6 ||
                l_sf_4 ||
                l_sf_5 ||
                l_sf_8 ||
                l_sf_9 ||
                l_sf_10;

            o_installment_data_1 := l_installment_data_1;
            o_installment_data_2 := l_installment_data_2;
        end if;

    exception
        when com_api_error_pkg.e_invalid_number then
            com_api_error_pkg.raise_error(
                i_error       => 'MCW_ERROR_WRONG_VALUE'
              , i_env_param1  => 'P0181'
              , i_env_param2  => l_installment_data_1
              , i_env_param3  => l_installment_data_2
            );
    end parse_p0181;

begin
    init_pds_tab();
end;
/
