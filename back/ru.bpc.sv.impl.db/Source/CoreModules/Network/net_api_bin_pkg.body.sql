create or replace package body net_api_bin_pkg is

    type t_pan_prefix_tab is table of varchar2(5) index by binary_integer;
    type t_pan_range_tab is table of varchar2(24) index by binary_integer;
    
    procedure get_bin_info (
        i_card_number            in     com_api_type_pkg.t_card_number
      , i_oper_type              in     com_api_type_pkg.t_dict_value   default null
      , i_terminal_type          in     com_api_type_pkg.t_dict_value   default null
      , i_acq_inst_id            in     com_api_type_pkg.t_inst_id      default null
      , i_acq_network_id         in     com_api_type_pkg.t_inst_id      default null
      , i_msg_type               in     com_api_type_pkg.t_dict_value   default null
      , i_oper_reason            in     com_api_type_pkg.t_dict_value   default null
      , i_oper_currency          in     com_api_type_pkg.t_curr_code    default null
      , i_merchant_id            in     com_api_type_pkg.t_short_id     default null
      , i_terminal_id            in     com_api_type_pkg.t_short_id     default null           
      , o_iss_inst_id               out com_api_type_pkg.t_inst_id
      , o_iss_network_id            out com_api_type_pkg.t_tiny_id
      , o_iss_host_id               out com_api_type_pkg.t_tiny_id
      , o_card_type_id              out com_api_type_pkg.t_tiny_id
      , o_card_country              out com_api_type_pkg.t_curr_code
      , o_card_inst_id              out com_api_type_pkg.t_inst_id
      , o_card_network_id           out com_api_type_pkg.t_tiny_id
      , o_pan_length                out com_api_type_pkg.t_tiny_id
      , i_raise_error            in     com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
    ) is
    begin
        net_api_bin_pkg.get_bin_info (
            i_card_number         => i_card_number       
          , i_oper_type           => i_oper_type       
          , i_terminal_type       => i_terminal_type   
          , i_acq_inst_id         => i_acq_inst_id     
          , i_acq_network_id      => i_acq_network_id  
          , i_msg_type            => i_msg_type        
          , i_oper_reason         => i_oper_reason     
          , i_oper_currency       => i_oper_currency   
          , i_merchant_id         => i_merchant_id     
          , i_terminal_id         => i_terminal_id     
          , io_iss_inst_id        => o_iss_inst_id    
          , o_iss_network_id      => o_iss_network_id  
          , o_iss_host_id         => o_iss_host_id     
          , o_card_type_id        => o_card_type_id    
          , o_card_country        => o_card_country    
          , o_card_inst_id        => o_card_inst_id    
          , o_card_network_id     => o_card_network_id 
          , o_pan_length          => o_pan_length      
          , i_raise_error         => i_raise_error     
       );
    end;    
    
    procedure get_bin_info (
        i_card_number            in     com_api_type_pkg.t_card_number
      , i_oper_type              in     com_api_type_pkg.t_dict_value   default null
      , i_terminal_type          in     com_api_type_pkg.t_dict_value   default null
      , i_acq_inst_id            in     com_api_type_pkg.t_inst_id      default null
      , i_acq_network_id         in     com_api_type_pkg.t_inst_id      default null
      , i_msg_type               in     com_api_type_pkg.t_dict_value   default null
      , i_oper_reason            in     com_api_type_pkg.t_dict_value   default null
      , i_oper_currency          in     com_api_type_pkg.t_curr_code    default null
      , i_merchant_id            in     com_api_type_pkg.t_short_id     default null
      , i_terminal_id            in     com_api_type_pkg.t_short_id     default null           
      , io_iss_inst_id           in out com_api_type_pkg.t_inst_id
      , o_iss_network_id            out com_api_type_pkg.t_tiny_id
      , o_iss_host_id               out com_api_type_pkg.t_tiny_id
      , o_card_type_id              out com_api_type_pkg.t_tiny_id
      , o_card_country              out com_api_type_pkg.t_curr_code
      , o_card_inst_id              out com_api_type_pkg.t_inst_id
      , o_card_network_id           out com_api_type_pkg.t_tiny_id
      , o_pan_length                out com_api_type_pkg.t_tiny_id
      , i_raise_error            in     com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
    ) is
        LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_bin_info[1]: ';
        l_pan_prefix               com_api_type_pkg.t_card_number;
        l_pan_low                  com_api_type_pkg.t_card_number;
        l_pan_high                 com_api_type_pkg.t_card_number;
    begin
        l_pan_prefix := substr(i_card_number, 1, BIN_INDEX_LENGTH);

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'i_card_number [#1] (length [#2]), i_oper_type [#3], '
                         || 'i_terminal_type [#4], i_msg_type [#5], i_oper_reason [6]'
                         || '], i_acq_inst_id [' || i_acq_inst_id
                         || '], i_acq_network_id [' || i_acq_network_id
                         || '], i_oper_currency [' || i_oper_currency
                         || '], i_merchant_id [' || i_merchant_id
                         || '], i_terminal_id [' || i_terminal_id
                         || ']; l_pan_prefix [' || l_pan_prefix || ']'
          , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
          , i_env_param2 => length(i_card_number)
          , i_env_param3 => i_oper_type
          , i_env_param4 => i_terminal_type
          , i_env_param5 => i_msg_type
          , i_env_param6 => i_oper_reason
        );

        select *
          into io_iss_inst_id
             , o_iss_network_id
             , o_iss_host_id
             , o_card_type_id
             , o_card_country
             , o_card_inst_id
             , o_card_network_id
             , o_pan_length
             , l_pan_low
             , l_pan_high
          from (        
            select decode(b.iss_inst_id, vis_api_const_pkg.INSTITUTION_VISA_SMS, vis_api_const_pkg.INSTITUTION_VISA, b.iss_inst_id) as iss_inst_id
                 , b.iss_network_id
                 , m.id                  iss_host_id
                 , b.card_type_id
                 , b.country
                 , b.card_inst_id
                 , b.card_network_id
                 , b.pan_length
                 , b.pan_low
                 , b.pan_high
              from net_bin_range_index i
                 , net_bin_range b
                 , net_network n
                 , net_member m
             where i.pan_prefix     = l_pan_prefix
               and i_card_number between substr(i.pan_low, 1, length(i_card_number)) and substr(i.pan_high, 1, length(i_card_number)) 
               and i.pan_low        = b.pan_low
               and i.pan_high       = b.pan_high
               and b.iss_network_id = n.id
               and b.iss_network_id = m.network_id
               and b.iss_inst_id    = m.inst_id
               and length(trim(trailing '0' from i_card_number)) <= b.pan_length
          order by case
                       when io_iss_inst_id = vis_api_const_pkg.INSTITUTION_VISA_SMS and b.iss_inst_id = vis_api_const_pkg.INSTITUTION_VISA_SMS
                       then 1
                       when io_iss_inst_id = vis_api_const_pkg.INSTITUTION_VISA_SMS and b.iss_inst_id = vis_api_const_pkg.INSTITUTION_VISA
                       then 2
                       when b.iss_inst_id = io_iss_inst_id
                       then 3
                       else 4
                   end
                 , net_cst_bin_pkg.bin_table_scan_priority (
                       i_network_id  => n.id
                   )
                 , net_cst_bin_pkg.extra_scan_priority (
                       i_card_number   => i_card_number
                     , i_network_id  => n.id
                   )
                 , net_cst_bin_pkg.advances_scan_priority (
                       i_card_number   => i_card_number
                     , i_pan_low     => i.pan_low
                     , i_network_id  => n.id
                   )
                 , n.bin_table_scan_priority
                 , utl_match.jaro_winkler_similarity(i.pan_low, rpad(i_card_number, length(i.pan_low), '0')) desc
                 , b.priority
       ) where rownum = 1;

        trc_log_pkg.debug(
            i_text => 'io_iss_inst_id [' || io_iss_inst_id
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
                i_error      => 'TOO_SHORT_PAN_LENGTH_FOR_BIN_RANGE'
              , i_env_param1 => o_pan_length
              , i_env_param2 => iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH
              , i_env_param3 => l_pan_low
              , i_env_param4 => l_pan_high
              , i_env_param5 => o_iss_network_id
              , i_env_param6 => o_card_network_id
            );
        end if;

        net_api_bin_pkg.get_substitution_host (
            i_card_number             => i_card_number
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
          , i_iss_inst_id             => io_iss_inst_id
          , i_iss_network_id          => o_iss_network_id
          , i_iss_host_id             => o_iss_host_id
          , o_substitution_inst_id    => io_iss_inst_id    
          , o_substitution_network_id => o_iss_network_id   
          , o_substitution_host_id    => o_iss_host_id
          , i_card_country            => o_card_country
        );

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'END; '
                   || 'io_iss_inst_id [' || io_iss_inst_id
                   || '], o_iss_network_id [' || o_iss_network_id
                   || '], o_iss_host_id [' || o_iss_host_id || ']'
        );
    exception
        when no_data_found then
            if i_raise_error = com_api_const_pkg.TRUE then
                com_api_error_pkg.raise_error (
                    i_error        => 'BIN_NOT_FOUND_BY_CARD_NUMBER'
                  , i_env_param1   => iss_api_card_pkg.get_card_mask(i_card_number)
                  , i_env_param2   => substr(i_card_number, 1, 6)
                );
            else
                trc_log_pkg.debug(
                    i_text => LOG_PREFIX || 'END; exception BIN_NOT_FOUND_BY_CARD_NUMBER was masked'
                );
                -- io_iss_inst_id := null;
                o_iss_network_id  := null;
                o_iss_host_id     := null;
                o_card_type_id    := null;
                o_card_country    := null;
                o_card_inst_id    := null;
                o_card_network_id := null;
                o_pan_length      := null;
            end if;
    end;

    procedure get_bin_info (
        i_card_number         in     com_api_type_pkg.t_card_number
      , i_network_id          in     com_api_type_pkg.t_tiny_id
      , o_iss_inst_id            out com_api_type_pkg.t_inst_id
      , o_iss_host_id            out com_api_type_pkg.t_tiny_id
      , o_card_type_id           out com_api_type_pkg.t_tiny_id
      , o_card_country           out com_api_type_pkg.t_curr_code
      , o_card_inst_id           out com_api_type_pkg.t_inst_id
      , o_card_network_id        out com_api_type_pkg.t_tiny_id
      , o_pan_length             out com_api_type_pkg.t_tiny_id
      , i_raise_error         in     com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
    ) is
        LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_bin_info[2]: ';
        l_pan_prefix                com_api_type_pkg.t_card_number;
        l_pan_low                  com_api_type_pkg.t_card_number;
        l_pan_high                 com_api_type_pkg.t_card_number;
        l_sysdate               date;
    begin
        l_pan_prefix := substr(i_card_number, 1, BIN_INDEX_LENGTH);
        l_sysdate    := get_sysdate;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'i_card_number [#1] (length [#2])'
                         || '], i_network_id [' || i_network_id || ']'
          , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
          , i_env_param2 => length(i_card_number)
        );

        select *
          into o_iss_inst_id
             , o_iss_host_id
             , o_card_type_id
             , o_card_country
             , o_card_inst_id
             , o_card_network_id
             , o_pan_length
        from (        
            select decode(b.iss_inst_id, vis_api_const_pkg.INSTITUTION_VISA_SMS, vis_api_const_pkg.INSTITUTION_VISA, b.iss_inst_id) as iss_inst_id
                 , m.id                  iss_host_id
                 , b.card_type_id
                 , b.country
                 , b.card_inst_id
                 , b.card_network_id
                 , b.pan_length
             from net_bin_range_index i
                , net_bin_range b
                , net_network n
                , net_member m
            where i.pan_prefix = l_pan_prefix
              and i_card_number between substr(i.pan_low, 1, length(i_card_number)) and substr(i.pan_high, 1, length(i_card_number)) 
              and i.pan_low = b.pan_low
              and i.pan_high = b.pan_high
              and b.iss_network_id = i_network_id
              and b.iss_network_id = n.id
              and b.iss_network_id = m.network_id
              and b.iss_inst_id = m.inst_id
              and (b.activation_date is null or b.activation_date <= l_sysdate) 
              and length(trim(trailing '0' from i_card_number)) <= b.pan_length
         order by net_cst_bin_pkg.bin_table_scan_priority (
                      i_network_id  => n.id
                  )
                , net_cst_bin_pkg.extra_scan_priority (
                      i_card_number => i_card_number
                    , i_network_id  => n.id
                )
                , net_cst_bin_pkg.advances_scan_priority (
                      i_card_number   => i_card_number
                    , i_pan_low     => i.pan_low
                    , i_network_id  => n.id
                )
                , n.bin_table_scan_priority
                , utl_match.jaro_winkler_similarity(i.pan_low, rpad(i_card_number, length(i.pan_low), '0')) desc
                , b.priority
       ) where rownum = 1;

        if o_pan_length < iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH then
            com_api_error_pkg.raise_error(
                i_error      => 'TOO_SHORT_PAN_LENGTH_FOR_BIN_RANGE'
              , i_env_param1 => o_pan_length
              , i_env_param2 => iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH
              , i_env_param3 => l_pan_low
              , i_env_param4 => l_pan_high
              , i_env_param5 => i_network_id
              , i_env_param6 => o_card_network_id
            );
        end if;

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'END; '
                   || 'o_iss_inst_id [' || o_iss_inst_id
                   || '], o_iss_host_id [' || o_iss_host_id
                   || '], o_card_type_id [' || o_card_type_id
                   || '], o_card_country [' || o_card_country
                   || '], o_card_inst_id [' || o_card_inst_id
                   || '], o_card_network_id [' || o_card_network_id
                   || '], o_pan_length [' || o_pan_length || ']'
        );
    exception
        when no_data_found then
            if i_raise_error = com_api_const_pkg.TRUE then
                com_api_error_pkg.raise_error (
                    i_error        => 'BIN_NOT_FOUND_BY_CARD_NUMBER'
                  , i_env_param1   => iss_api_card_pkg.get_card_mask(i_card_number)
                  , i_env_param2   => substr(i_card_number, 1, 6)
                );
            else
                trc_log_pkg.debug(
                    i_text => LOG_PREFIX || 'END; exception BIN_NOT_FOUND_BY_CARD_NUMBER was masked'
                );
                o_iss_inst_id     := null;
                o_iss_host_id     := null;
                o_card_type_id    := null;
                o_card_country    := null;
                o_card_inst_id    := null;
                o_card_network_id := null;
                o_pan_length      := null;
            end if;
    end;

    procedure add_bin_range(
        i_pan_low                  in     com_api_type_pkg.t_card_number
        , i_pan_high               in     com_api_type_pkg.t_card_number        
        , i_country                in     com_api_type_pkg.t_curr_name
        , i_network_id             in     com_api_type_pkg.t_tiny_id
        , i_inst_id                in     com_api_type_pkg.t_inst_id
        , i_pan_length             in     com_api_type_pkg.t_tiny_id
        , i_network_card_type      in     com_api_type_pkg.t_dict_value
        , i_card_network_id        in     com_api_type_pkg.t_network_id   default null
        , i_card_inst_id           in     com_api_type_pkg.t_inst_id      default null
        , i_module_code            in     com_api_type_pkg.t_module_code  default null
        , i_priority               in     com_api_type_pkg.t_tiny_id      default 1
        , i_activation_date        in     date                            default null
        , i_card_type_id           in     com_api_type_pkg.t_tiny_id      default null
    ) is
        l_card_type_id                    com_api_type_pkg.t_tiny_id;
        l_pan_length                      com_api_type_pkg.t_tiny_id;
    begin
        l_pan_length := nvl(i_pan_length, length(i_pan_low));

        if l_pan_length < iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH then
            com_api_error_pkg.raise_error(
                i_error      => 'TOO_SHORT_PAN_LENGTH_FOR_BIN_RANGE'
              , i_env_param1 => i_pan_length
              , i_env_param2 => iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH
              , i_env_param3 => i_pan_low
              , i_env_param4 => i_pan_high
              , i_env_param5 => i_network_id
              , i_env_param6 => i_card_network_id
            );
        end if;

        l_card_type_id := i_card_type_id;

        if l_card_type_id is null then
            begin
                select card_type_id 
                  into l_card_type_id
                  from (select card_type_id
                          from net_card_type_map
                         where standard_id = net_api_network_pkg.get_offline_standard(i_network_id => i_network_id)
                           and i_network_card_type like network_card_type
                           and nvl(i_country, '%') like nvl(country, '%')
                         order by priority
                       )
                 where rownum = 1;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error(
                        i_error             => 'IMPOSSIBLE_DEFINE_CARD_TYPE'
                      , i_env_param1        => i_network_id
                      , i_env_param2        => i_network_card_type
                    );
            end;
        end if;
        
        insert into net_bin_range(
            pan_low
          , pan_high
          , priority
          , card_type_id
          , country
          , iss_network_id
          , iss_inst_id
          , pan_length
          , card_network_id
          , card_inst_id
          , module_code
          , activation_date
        ) values (
            i_pan_low
          , i_pan_high
          , i_priority
          , l_card_type_id
          , i_country
          , i_network_id
          , i_inst_id
          , l_pan_length
          , i_card_network_id
          , i_card_inst_id
          , i_module_code
          , i_activation_date
        );
    end;

    procedure rebuild_bin_index is

        l_pan_low_tab           t_pan_range_tab;
        l_pan_high_tab          t_pan_range_tab;
        l_pan_low_adj_tab       t_pan_range_tab;
        l_pan_high_adj_tab      t_pan_range_tab;

        l_pan_prefix_tab        t_pan_prefix_tab;
        l_pan_low_tab2          t_pan_range_tab;
        l_pan_high_tab2         t_pan_range_tab;
    
        k                       pls_integer;
    
        cursor cu_bin_range is
            select distinct
                 pan_low
                 , pan_high
                 , rpad(pan_low, BIN_INDEX_LENGTH, '0') pan_low_adj 
                 , rpad(pan_high, BIN_INDEX_LENGTH, '9') pan_high_adj 
            from net_bin_range; 
          
    begin
        delete net_bin_range_index; 

        open cu_bin_range;
    
        loop
            fetch cu_bin_range bulk collect into
                l_pan_low_tab
                , l_pan_high_tab
                , l_pan_low_adj_tab
                , l_pan_high_adj_tab
            limit 50;
         
            l_pan_prefix_tab.delete;
            l_pan_low_tab2.delete;
            l_pan_high_tab2.delete;
        
            k := 0;
            
            for i in 1..l_pan_low_tab.count loop
                for j in 0 .. to_number(l_pan_high_adj_tab(i)) - to_number(l_pan_low_adj_tab(i)) loop
                    k := k + 1;
                    l_pan_prefix_tab(k) := lpad(to_char(to_number(l_pan_low_adj_tab(i)) + j), BIN_INDEX_LENGTH, '0');
                    l_pan_low_tab2(k)   := l_pan_low_tab(i);
                    l_pan_high_tab2(k)  := l_pan_high_tab(i);
                end loop;
            end loop;
             
            begin
                forall k in 1..l_pan_prefix_tab.count save exceptions
                    insert into net_bin_range_index(
                        pan_prefix
                      , pan_low
                      , pan_high
                    ) values (
                        l_pan_prefix_tab(k)
                      , l_pan_low_tab2(k)
                      , l_pan_high_tab2(k)
                    );
            exception
                when others then
                    null; 
            end;    
        
            exit when cu_bin_range%notfound;
        end loop;
    
        close cu_bin_range;
    
    exception
        when others then
            if cu_bin_range%isopen then
                close cu_bin_range;
            end if;
        
            raise;
    end;
    
    procedure sync_local_bins is
    begin
        delete from
            net_bin_range
        where
            module_code = net_api_const_pkg.MODULE_CODE_NETWORKING;
    
        insert into net_bin_range (
            pan_low
            , pan_high
            , pan_length
            , priority
            , card_type_id
            , country
            , iss_network_id
            , iss_inst_id
            , card_network_id
            , card_inst_id
            , module_code
        ) select
            pan_low
            , pan_high
            , pan_length
            , priority
            , card_type_id
            , country
            , iss_network_id
            , iss_inst_id
            , card_network_id
            , card_inst_id
            , net_api_const_pkg.MODULE_CODE_NETWORKING
        from
            net_local_bin_range;
            
        rebuild_bin_index;            
    end;

    procedure get_substitution_host (
        i_card_number              in     com_api_type_pkg.t_card_number
        , i_oper_type              in     com_api_type_pkg.t_dict_value   default null
        , i_terminal_type          in     com_api_type_pkg.t_dict_value   default null
        , i_acq_inst_id            in     com_api_type_pkg.t_inst_id      default null
        , i_acq_network_id         in     com_api_type_pkg.t_inst_id      default null
        , i_msg_type               in     com_api_type_pkg.t_dict_value   default null
        , i_oper_reason            in     com_api_type_pkg.t_dict_value   default null
        , i_oper_currency          in     com_api_type_pkg.t_curr_code    default null
        , i_merchant_id            in     com_api_type_pkg.t_short_id     default null
        , i_terminal_id            in     com_api_type_pkg.t_short_id     default null   
        , i_card_inst_id           in     com_api_type_pkg.t_inst_id      default null
        , i_card_network_id        in     com_api_type_pkg.t_inst_id      default null
        , i_iss_inst_id            in     com_api_type_pkg.t_inst_id      default null
        , i_iss_network_id         in     com_api_type_pkg.t_tiny_id      default null
        , i_iss_host_id            in     com_api_type_pkg.t_tiny_id      default null
        , o_substitution_inst_id      out com_api_type_pkg.t_inst_id     
        , o_substitution_network_id   out com_api_type_pkg.t_inst_id    
        , o_substitution_host_id      out com_api_type_pkg.t_inst_id
        , i_card_country           in     com_api_type_pkg.t_country_code default null
    ) is
    begin
        select *
          into o_substitution_inst_id
             , o_substitution_network_id
             , o_substitution_host_id
          from (   
                select h.substitution_inst_id 
                     , h.substitution_network_id
                     , m.id substitution_host_id
                  from net_host_substitution h
                     , net_member m 
                 where h.substitution_network_id like to_char(m.network_id)
                   and h.substitution_inst_id like to_char(m.inst_id)
                   and i_card_number between h.pan_low and h.pan_high
                   and nvl(i_oper_type, '%') like h.oper_type  
                   and nvl(i_terminal_type, '%') like h.terminal_type
                   and nvl(to_char(i_acq_inst_id), '%') like h.acq_inst_id
                   and nvl(to_char(i_acq_network_id), '%') like h.acq_network_id
                   and nvl(to_char(i_card_inst_id), '%') like h.card_inst_id
                   and nvl(to_char(i_card_network_id), '%') like h.card_network_id           
                   and nvl(to_char(i_iss_inst_id), '%') like h.iss_inst_id
                   and nvl(to_char(i_iss_network_id), '%') like h.iss_network_id                   
                   and nvl(i_msg_type, '%') like h.msg_type 
                   and nvl(i_oper_reason, '%') like h.oper_reason 
                   and nvl(i_oper_currency, '%') like h.oper_currency
                   and nvl(i_card_country, '%') like h.card_country 
                   and (h.merchant_array_id = '%'
                        or 
                        exists (select 1 from com_array a, com_array_element e
                                 where a.id = h.merchant_array_id
                                   and a.id = e.array_id
                                   and e.element_value = to_char(i_merchant_id))
                       )
                   and (h.terminal_array_id = '%'
                        or 
                        exists (select 1 from com_array a, com_array_element e
                         where a.id = h.terminal_array_id
                           and a.id = e.array_id
                           and e.element_value = to_char(i_terminal_id))
                       )                        
              order by h.priority asc
          )
         where rownum = 1;

    exception     
        when no_data_found then
            o_substitution_inst_id := i_iss_inst_id;    
            o_substitution_network_id := i_iss_network_id;   
            o_substitution_host_id := i_iss_host_id;
    end;

    /*
     * It checks network BIN ranges' collection and raises an error if some check is failed.
     */
    procedure check_bin_range(
        i_bin_range_tab       in      net_api_type_pkg.t_net_bin_range_tab
    ) is
        l_index                       com_api_type_pkg.t_count := 1;
    begin
        -- Check collection with BIN ranges for too short PAN's length
        while l_index <= i_bin_range_tab.count()
          and i_bin_range_tab(l_index).pan_length >= iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH
        loop
            l_index := l_index + 1;
        end loop;
        
        if l_index <= i_bin_range_tab.count() then
            com_api_error_pkg.raise_error(
                i_error      => 'TOO_SHORT_PAN_LENGTH_FOR_BIN_RANGE'
              , i_env_param1 => i_bin_range_tab(l_index).pan_length
              , i_env_param2 => iss_api_const_pkg.MINIMAL_CARD_NUMBER_LENGTH
              , i_env_param3 => i_bin_range_tab(l_index).pan_low
              , i_env_param4 => i_bin_range_tab(l_index).pan_high
              , i_env_param5 => i_bin_range_tab(l_index).iss_network_id
              , i_env_param6 => i_bin_range_tab(l_index).card_network_id
            );
        end if;
    end check_bin_range;

    procedure cleanup_network_bins(
        i_network_id                in     com_api_type_pkg.t_tiny_id
    ) is
    begin
        delete 
          from net_bin_range
         where iss_network_id = i_network_id;
    end;

end net_api_bin_pkg;
/
