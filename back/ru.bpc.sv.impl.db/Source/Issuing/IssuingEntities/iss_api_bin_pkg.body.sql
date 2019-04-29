create or replace package body iss_api_bin_pkg is

    procedure get_bin_info (
        i_card_number           in com_api_type_pkg.t_card_number
        , i_oper_type           in com_api_type_pkg.t_dict_value default null
        , i_terminal_type       in com_api_type_pkg.t_dict_value default null
        , i_acq_inst_id         in com_api_type_pkg.t_inst_id    default null
        , i_acq_network_id      in com_api_type_pkg.t_inst_id    default null
        , i_msg_type            in com_api_type_pkg.t_dict_value default null
        , i_oper_reason         in com_api_type_pkg.t_dict_value default null
        , i_oper_currency       in com_api_type_pkg.t_curr_code  default null
        , i_merchant_id         in com_api_type_pkg.t_short_id   default null
        , i_terminal_id         in com_api_type_pkg.t_short_id   default null   
        , o_iss_inst_id         out com_api_type_pkg.t_inst_id
        , o_iss_network_id      out com_api_type_pkg.t_tiny_id
        , o_iss_host_id         out com_api_type_pkg.t_tiny_id
        , o_card_type_id        out com_api_type_pkg.t_tiny_id
        , o_card_country        out com_api_type_pkg.t_curr_code
        , o_card_inst_id        out com_api_type_pkg.t_inst_id
        , o_card_network_id     out com_api_type_pkg.t_tiny_id
        , o_pan_length          out com_api_type_pkg.t_tiny_id
        , i_raise_error         in com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
    ) is
        LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_bin_info[1]: ';
        l_bin                      com_api_type_pkg.t_card_number;
    begin
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'i_card_number [#1] (length [#2]), i_oper_type [#3], '
                         || 'i_terminal_type [#4], i_msg_type [#5], i_oper_reason [#6]'
                         || '], i_acq_inst_id [' || i_acq_inst_id
                         || '], i_acq_network_id [' || i_acq_network_id
                         || '], i_oper_currency [' || i_oper_currency
                         || '], i_merchant_id [' || i_merchant_id
                         || '], i_terminal_id [' || i_terminal_id || ']'
          , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
          , i_env_param2 => length(i_card_number)
          , i_env_param3 => i_oper_type
          , i_env_param4 => i_terminal_type
          , i_env_param5 => i_msg_type
          , i_env_param6 => i_oper_reason
        );

        begin

            select t.inst_id         as iss_inst_id
                 , i.network_id      as iss_network_id
                 , m.id              as iss_host_id
                 , t.card_type_id
                 , t.country         as card_country
                 , t.inst_id         as card_inst_id
                 , b.network_id      as card_network_id
                 , b.pan_length
                 , b.bin
              into o_iss_inst_id
                 , o_iss_network_id
                 , o_iss_host_id
                 , o_card_type_id
                 , o_card_country
                 , o_card_inst_id
                 , o_card_network_id
                 , o_pan_length
                 , l_bin
              from (
                  select c.inst_id
                       , c.card_type_id
                       , c.country
                       , ci.bin_id
                    from iss_card_number cn
                       , iss_card c
                       , iss_card_instance ci
                   where reverse(cn.card_number) = reverse(i_card_number)
                     and c.id       = cn.card_id
                     and ci.card_id = c.id
                   order by ci.seq_number desc    
                ) t
                , ost_institution i
                , iss_bin b
                , net_member m
            where i.id            = t.inst_id
              and b.id            = t.bin_id
              and m.network_id(+) = i.network_id
              and m.inst_id(+)    = i.id
              and rownum          = 1;

        exception when no_data_found then

            select b.iss_inst_id
                 , i.network_id      iss_network_id
                 , m.id              iss_host_id
                 , b.card_type_id
                 , b.card_country
                 , b.card_inst_id
                 , b.card_network_id
                 , b.pan_length
                 , b.bin
              into o_iss_inst_id
                 , o_iss_network_id
                 , o_iss_host_id
                 , o_card_type_id
                 , o_card_country
                 , o_card_inst_id
                 , o_card_network_id
                 , o_pan_length
                 , l_bin
              from (
                  select inst_id               iss_inst_id
                       , card_type_id
                       , country               card_country
                       , inst_id               card_inst_id
                       , network_id            card_network_id
                       , pan_length
                       , bin
                    from iss_bin
                   where i_card_number like bin || '%'
                   order by length(bin) desc
                ) b
                , ost_institution i
                , net_member m
            where i.id            = b.card_inst_id
              and m.network_id(+) = i.network_id
              and m.inst_id(+)    = i.id
              and rownum          = 1;

        end;

        trc_log_pkg.debug(
            i_text => 'o_iss_inst_id [' || o_iss_inst_id
                   || '], o_iss_network_id [' || o_iss_network_id
                   || '], o_iss_host_id [' || o_iss_host_id
                   || '], o_card_type_id [' || o_card_type_id
                   || '], o_card_country [' || o_card_country
                   || '], o_card_inst_id [' || o_card_inst_id
                   || '], o_card_network_id [' || o_card_network_id
                   || '], o_pan_length [' || o_pan_length || ']'
        );

        if o_pan_length < iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH then
            com_api_error_pkg.raise_error(
                i_error      => 'TOO_SHORT_PAN_LENGTH_FOR_BIN'
              , i_env_param1 => o_pan_length
              , i_env_param2 => iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH
              , i_env_param3 => l_bin
            );
        end if;

        net_api_bin_pkg.get_substitution_host (
            i_card_number               => i_card_number
            , i_oper_type               => i_oper_type
            , i_terminal_type           => i_terminal_type
            , i_acq_inst_id             => i_acq_inst_id
            , i_acq_network_id          => i_acq_network_id
            , i_msg_type                => i_msg_type
            , i_oper_reason             => i_oper_reason
            , i_oper_currency           => i_oper_currency
            , i_merchant_id             => i_merchant_id
            , i_terminal_id             => i_terminal_id
            , i_card_inst_id            => o_card_inst_id
            , i_card_network_id         => o_card_network_id
            , i_iss_inst_id             => o_iss_inst_id
            , i_iss_network_id          => o_iss_network_id
            , i_iss_host_id             => o_iss_host_id
            , o_substitution_inst_id    => o_iss_inst_id
            , o_substitution_network_id => o_iss_network_id
            , o_substitution_host_id    => o_iss_host_id
        );

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'END; '
                   || 'o_iss_inst_id [' || o_iss_inst_id
                   || '], o_iss_network_id [' || o_iss_network_id
                   || '], o_iss_host_id [' || o_iss_host_id || ']'
        );
    exception
        when no_data_found then
            if i_raise_error = com_api_const_pkg.TRUE then
                com_api_error_pkg.raise_error (
                    i_error             => 'BIN_NOT_FOUND_BY_CARD_NUMBER'
                    , i_env_param1      => iss_api_card_pkg.get_card_mask(i_card_number)
                    , i_env_param2      => substr(i_card_number, 1, 6)
                );
            else
                trc_log_pkg.debug(
                    i_text => LOG_PREFIX || 'END; exception BIN_NOT_FOUND_BY_CARD_NUMBER was masked'
                );
                o_iss_inst_id := null;
                o_iss_network_id := null;
                o_iss_host_id := null;
                o_card_type_id := null;
                o_card_country := null;
                o_card_inst_id := null;
                o_card_network_id := null;
                o_pan_length := null;
            end if;
    end;

    procedure get_bin_info (
        i_card_number           in com_api_type_pkg.t_card_number
        , o_iss_inst_id         out com_api_type_pkg.t_inst_id
        , o_iss_network_id      out com_api_type_pkg.t_tiny_id
        , o_card_inst_id        out com_api_type_pkg.t_inst_id
        , o_card_network_id     out com_api_type_pkg.t_tiny_id
        , o_card_type           out com_api_type_pkg.t_tiny_id
        , o_card_country        out com_api_type_pkg.t_country_code
        , o_bin_currency        out com_api_type_pkg.t_curr_code
        , o_sttl_currency       out com_api_type_pkg.t_curr_code
        , i_raise_error         in com_api_type_pkg.t_boolean
    ) is
        LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_bin_info[2]: ';
    begin
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'i_card_number [#1] (length [#2])'
          , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
          , i_env_param2 => length(i_card_number)
        );

        begin
            select t.inst_id        as card_inst
                 , t.inst_id        as iss_inst
                 , b.network_id     as card_network
                 , inst.network_id  as iss_network
                 , t.card_type_id
                 , t.country        as card_country
                 , b.bin_currency
                 , b.sttl_currency
              into o_card_inst_id
                 , o_iss_inst_id
                 , o_card_network_id
                 , o_iss_network_id
                 , o_card_type
                 , o_card_country
                 , o_bin_currency
                 , o_sttl_currency
              from (
                  select c.inst_id
                       , c.card_type_id
                       , c.country
                       , ci.bin_id
                    from iss_card_number cn
                       , iss_card c
                       , iss_card_instance ci
                   where reverse(cn.card_number) = reverse(i_card_number)
                     and c.id       = cn.card_id
                     and ci.card_id = c.id
                   order by ci.seq_number desc    
                ) t
                , ost_institution inst
                , iss_bin b
             where inst.id = t.inst_id
               and b.id    = t.bin_id
               and rownum  = 1;

        exception when no_data_found then

            select bin.inst_id       as card_inst
                 , bin.inst_id       as iss_inst
                 , bin.network_id    as card_network
                 , inst.network_id   as iss_network
                 , bin.card_type_id
                 , bin.country       as card_country
                 , bin.bin_currency
                 , bin.sttl_currency
              into o_card_inst_id
                 , o_iss_inst_id
                 , o_card_network_id
                 , o_iss_network_id
                 , o_card_type
                 , o_card_country
                 , o_bin_currency
                 , o_sttl_currency
              from (
                  select b.inst_id
                       , b.network_id
                       , b.card_type_id
                       , b.country
                       , b.bin_currency
                       , b.sttl_currency
                    from iss_bin b
                   where i_card_number like b.bin || '%'
                   order by length(b.bin) desc    
                ) bin
                , ost_institution inst
             where bin.inst_id = inst.id
               and rownum      = 1;

        end;

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'END; '
                   || 'o_iss_inst_id [' || o_iss_inst_id
                   || '], o_iss_network_id [' || o_iss_network_id
                   || '], o_card_type [' || o_card_type
                   || '], o_card_country [' || o_card_country
                   || '], o_card_inst_id [' || o_card_inst_id
                   || '], o_card_network_id [' || o_card_network_id
                   || '], o_bin_currency [' || o_bin_currency
                   || '], o_sttl_currency [' || o_sttl_currency || ']'
        );
    exception
        when no_data_found then
            if i_raise_error = com_api_const_pkg.FALSE then
                trc_log_pkg.debug (
                    i_text          => 'Masked error when searching BIN for card [#1]'
                    , i_env_param1  => iss_api_card_pkg.get_card_mask(i_card_number)
                );
            else
                com_api_error_pkg.raise_error (
                    i_error         => 'BIN_NOT_FOUND_BY_CARD_NUMBER'
                    , i_env_param1  => iss_api_card_pkg.get_card_mask(i_card_number)
                    , i_env_param2  => substr(i_card_number, 1, 6)
                );
            end if;
    end;

    procedure get_bin_info (
        i_card_number           in com_api_type_pkg.t_card_number
        , o_card_inst_id        out com_api_type_pkg.t_inst_id
        , o_card_network_id     out com_api_type_pkg.t_tiny_id
        , o_card_type           out com_api_type_pkg.t_tiny_id
        , o_card_country        out com_api_type_pkg.t_curr_code
        , i_raise_error         in com_api_type_pkg.t_boolean
    ) is
        l_bin_currency          com_api_type_pkg.t_curr_code;
        l_sttl_currency         com_api_type_pkg.t_curr_code;
        l_iss_inst_id           com_api_type_pkg.t_inst_id;
        l_iss_network_id        com_api_type_pkg.t_tiny_id;
    begin
        get_bin_info (
            i_card_number        => i_card_number
            , o_card_inst_id     => o_card_inst_id
            , o_card_network_id  => o_card_network_id
            , o_iss_inst_id      => l_iss_inst_id
            , o_iss_network_id   => l_iss_network_id
            , o_card_type        => o_card_type
            , o_card_country     => o_card_country
            , o_bin_currency     => l_bin_currency
            , o_sttl_currency    => l_sttl_currency
            , i_raise_error      => i_raise_error
        );
    end;
    
    function get_bin (
        i_bin_id                in com_api_type_pkg.t_short_id
    ) return iss_api_type_pkg.t_bin_rec
    is
        l_result                iss_api_type_pkg.t_bin_rec;
    begin
        select id
             , seqnum
             , bin
             , inst_id
             , network_id
             , bin_currency
             , sttl_currency
             , pan_length
             , card_type_id
             , country
          into l_result
          from iss_bin
         where id = i_bin_id;

        if l_result.pan_length < iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH then
            com_api_error_pkg.raise_error(
                i_error      => 'TOO_SHORT_PAN_LENGTH_FOR_BIN'
              , i_env_param1 => l_result.pan_length
              , i_env_param2 => iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH
              , i_env_param3 => l_result.bin
            );
        end if;

        return l_result;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error             => 'BIN_NOT_FOUND_BY_ID'
                , i_env_param1      => i_bin_id
            );
    end;

    function get_bin(
        i_bin                   in com_api_type_pkg.t_bin
      , i_mask_error            in com_api_type_pkg.t_boolean        := com_api_type_pkg.FALSE
    ) return iss_api_type_pkg.t_bin_rec
    is
        l_result                iss_api_type_pkg.t_bin_rec;
    begin
        select id
             , seqnum
             , bin
             , inst_id
             , network_id
             , bin_currency
             , sttl_currency
             , pan_length
             , card_type_id
             , country
          into l_result
          from iss_bin
         where bin = i_bin;

        if l_result.pan_length < iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH then
            com_api_error_pkg.raise_error(
                i_error      => 'TOO_SHORT_PAN_LENGTH_FOR_BIN'
              , i_env_param1 => l_result.pan_length
              , i_env_param2 => iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH
              , i_env_param3 => l_result.bin
            );
        end if;

        return l_result;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'BIN_IS_NOT_FOUND'
              , i_env_param1 => i_bin
              , i_mask_error => i_mask_error
            );
    end;
    
    function get_bin (
        i_card_number        in com_api_type_pkg.t_card_number
      , i_inst_id            in    com_api_type_pkg.t_inst_id       := ost_api_const_pkg.DEFAULT_INST
    ) return iss_api_type_pkg.t_bin_rec
    is
        l_result                iss_api_type_pkg.t_bin_rec;
    begin

        begin

            select b.id
                 , b.seqnum
                 , b.bin
                 , t.inst_id
                 , b.network_id
                 , b.bin_currency
                 , b.sttl_currency
                 , b.pan_length
                 , t.card_type_id
                 , t.country
              into l_result
              from (
                  select c.inst_id
                       , c.card_type_id
                       , c.country
                       , ci.bin_id
                    from iss_card_number cn
                       , iss_card c
                       , iss_card_instance ci
                   where reverse(cn.card_number) = reverse(i_card_number)
                     and c.id       = cn.card_id
                     and ci.card_id = c.id
                   order by ci.seq_number desc    
              ) t
              , iss_bin b
             where b.id   = t.bin_id
               and (i_inst_id = ost_api_const_pkg.DEFAULT_INST or b.inst_id = i_inst_id)
               and rownum = 1;

        exception when no_data_found then

            select id
                 , seqnum
                 , bin
                 , inst_id
                 , network_id
                 , bin_currency
                 , sttl_currency
                 , pan_length
                 , card_type_id
                 , country
              into l_result
              from (
                  select id
                       , seqnum
                       , bin
                       , inst_id
                       , network_id
                       , bin_currency
                       , sttl_currency
                       , pan_length
                       , card_type_id
                       , country
                    from iss_bin
                   where i_card_number like bin || '%'
                     and (i_inst_id = ost_api_const_pkg.DEFAULT_INST or inst_id = i_inst_id)
                   order by length(bin) desc    
              ) b
             where rownum = 1;

        end;

        if l_result.pan_length < iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH then
            com_api_error_pkg.raise_error(
                i_error      => 'TOO_SHORT_PAN_LENGTH_FOR_BIN'
              , i_env_param1 => l_result.pan_length
              , i_env_param2 => iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH
              , i_env_param3 => l_result.bin
              , i_env_param4 => i_inst_id
            );
        end if;

        return l_result;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error             => 'BIN_NOT_FOUND_BY_CARD_NUMBER'
                , i_env_param1      => iss_api_card_pkg.get_card_mask(i_card_number)
                , i_env_param2      => substr(i_card_number, 1, 6)
            );
    end;

    function get_bin_number(
        i_bin_id                in com_api_type_pkg.t_short_id
    ) return com_api_type_pkg.t_bin
    is
        l_bin_rec               iss_api_type_pkg.t_bin_rec;
    begin
        l_bin_rec := get_bin(i_bin_id => i_bin_id);

        return l_bin_rec.bin;
    end get_bin_number;

    function is_bin_ok (
        i_card_number           in com_api_type_pkg.t_card_number
        , i_card_type_id        in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_boolean
    is
        l_bin_rec               iss_api_type_pkg.t_bin_rec;
        l_count                 com_api_type_pkg.t_tiny_id;
    begin
        l_bin_rec := get_bin (
            i_card_number  => i_card_number
        );

        select count(*)
          into l_count 
          from (select c.id
                     , c.parent_type_id
                     , ltrim(sys_connect_by_path(c.id, '\'), '\') || '\' ph 
                  from net_card_type c 
               connect by prior c.parent_type_id = c.id) t
             , iss_bin_vw b 
         where b.card_type_id = t.id
           and to_number(substr(t.ph, 1, instr(t.ph, '\') -1)) = i_card_type_id
           and b.id = l_bin_rec.id;

        if l_count > 0 then
            return com_api_const_pkg.TRUE;
        else
            return com_api_const_pkg.FALSE;
        end if;        
    end;
    
end;
/
