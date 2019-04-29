create or replace package body acq_prc_import_pkg as
    cursor cur_fees is
        select x.customer_number
             , x.provider_number
             , x.terminal_number
             , x.account_number
             , x.inst_id
             , x.mod_name
             , x.mod_condition
             , x.service_id
             , x.purpose_id
             , x.purpose_number
             , x.fee
        from prc_session_file s
           , prc_file_attribute_vw a
           , prc_file_vw f
           , xmltable('/fee_records/fee_record'
                passing s.file_xml_contents
                columns customer_number     varchar2(15)    path 'customer_number'
                      , provider_number     varchar2(200)   path 'provider_number'
                      , terminal_number     varchar2(16)    path 'terminal_number'
                      , account_number      varchar2(32)    path 'account_number'
                      , inst_id             number(4)       path 'inst_id'
                      , mod_name            varchar2(200)   path 'mod_name'
                      , mod_condition       varchar2(2000)  path 'mod_condition'
                      , service_id          number(8)       path 'service_id'
                      , purpose_id          number(8)       path 'purpose_id'
                      , purpose_number      varchar2(200)   path 'purpose_number'
                      , fee                 xmltype         path 'fee'
           ) x
        where  s.session_id = get_session_id
           and s.file_attr_id = a.id
           and f.id = a.file_id
           and f.file_type = acq_api_const_pkg.FILE_TYPE_FEES;


    cursor cur_fee_count is
        select nvl(sum(fee_count), 0) fee_count
         from prc_session_file s
            , prc_file_attribute a
            , prc_file f
            , xmltable(
                '/fee_records'
                passing s.file_xml_contents
                columns
                      fee_count                        number        path 'fn:count(fee_record)'
              ) x
         where s.session_id = get_session_id
         and s.file_attr_id = a.id
           and f.id = a.file_id
           and f.file_type = acq_api_const_pkg.FILE_TYPE_FEES;

type t_fee_record_rec   is record (
    customer_number com_api_type_pkg.t_merchant_number
  , provider_number  com_api_type_pkg.t_name
  , terminal_number  com_api_type_pkg.t_terminal_number
  , account_number  com_api_type_pkg.t_account_number
  , inst_id         com_api_type_pkg.t_inst_id
  , mod_name        com_api_type_pkg.t_name
  , mod_condition   com_api_type_pkg.t_full_desc
  , service_id      com_api_type_pkg.t_short_id
  , purpose_id      com_api_type_pkg.t_short_id
  , purpose_number  com_api_type_pkg.t_name
  , fee             xmltype
);

type t_fee_record_tab   is varray(1000) of t_fee_record_rec;
     l_fee_record_tab   t_fee_record_tab;

type t_fee_rec  is record (
    command         com_api_type_pkg.t_dict_value
  , fee_id          com_api_type_pkg.t_short_id
  , fee_type        com_api_type_pkg.t_dict_value
  , fee_rate_calc   com_api_type_pkg.t_dict_value
  , fee_base_calc   com_api_type_pkg.t_dict_value
  , currency        com_api_type_pkg.t_curr_code
  , inst_id         com_api_type_pkg.t_inst_id
  , cycle_id        com_api_type_pkg.t_short_id
  , limit_id        com_api_type_pkg.t_long_id
  , start_date      date
  , end_date        date
  , tier            xmltype
);

procedure process_modifier(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_mod_name          in      com_api_type_pkg.t_name
  , i_mod_condition     in      com_api_type_pkg.t_full_desc
  , o_mod_id               out  com_api_type_pkg.t_tiny_id
) is
    l_scale_id                  com_api_type_pkg.t_tiny_id;
    l_seq_num                   com_api_type_pkg.t_seqnum;
begin
    if i_mod_name is null and i_mod_condition is null then
        return;
    end if;

    trc_log_pkg.debug(
        i_text          => 'process modifier [#1] [#2]'
      , i_env_param1    => i_mod_name
      , i_env_param2    => i_mod_condition
    );

    begin
        select m.id
             , s.id
          into o_mod_id
             , l_scale_id
          from rul_mod m
             , rul_mod_scale s
         where m.scale_id = s.id
           and s.scale_type = acq_api_const_pkg.REVENUE_SHARING_SCALE_TYPE
           and replace(m.condition, ' ') = replace(i_mod_condition, ' ')
           and m.scale_id  = s.id;

        trc_log_pkg.debug(
            i_text          => 'exsiting modifier was found: mod_id [#1], scale_id [#2]'
          , i_env_param1    => o_mod_id
          , i_env_param2    => l_scale_id
        );

    exception
        when too_many_rows then
            com_api_error_pkg.raise_error(
                i_error     => 'TOO_MANY_MODIFIERS_FOUND'
            );

        when no_data_found then
            if i_mod_name is null then
                com_api_error_pkg.raise_error(
                    i_error      => 'UNABLE_TO_CREATE_MODIFIER'
                );
            end if;

            select id
              into l_scale_id
              from rul_mod_scale
             where scale_type = acq_api_const_pkg.REVENUE_SHARING_SCALE_TYPE
               and rownum = 1;

            trc_log_pkg.debug(
                i_text          => 'no modifier found, going to create new one; scale_id [#1]'
              , i_env_param1    => l_scale_id
            );

            rul_api_mod_pkg.add_mod(
                o_id           => o_mod_id
              , o_seqnum       => l_seq_num
              , i_scale_id     => l_scale_id
              , i_condition    => i_mod_condition
              , i_priority     => null
              , i_lang         => com_ui_user_env_pkg.get_user_lang
              , i_name         => i_mod_name
              , i_description  => null
            );

            trc_log_pkg.debug(
                i_text          => 'modifier added [#1]'
              , i_env_param1    => o_mod_id
            );
    end;
end;

procedure register_fee(
    io_fee_rec      in out nocopy   t_fee_rec
  , i_inst_id       in              com_api_type_pkg.t_inst_id
) is
    l_seqnum        com_api_type_pkg.t_seqnum;
    l_fee_tier_id   com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text          => 'register_fee'
    );

    fcl_ui_fee_pkg.add_fee(
        i_fee_type          => io_fee_rec.fee_type
      , i_currency          => io_fee_rec.currency
      , i_fee_rate_calc     => io_fee_rec.fee_rate_calc
      , i_fee_base_calc     => io_fee_rec.fee_base_calc
      , i_limit_id          => io_fee_rec.limit_id
      , i_cycle_id          => io_fee_rec.cycle_id
      , i_inst_id           => i_inst_id
      , o_fee_id            => io_fee_rec.fee_id
      , o_seqnum            => l_seqnum
    );

    for tier in (
        select x.fixed_rate
             , x.percent_rate
             , x.min_value
             , x.max_value
             , x.length_type
             , x.sum_threshold
             , x.count_threshold
          from xmltable('/tier'
                    passing io_fee_rec.tier
                    columns fixed_rate      number(22,4)    path 'fixed_rate'
                          , percent_rate    number(22,4)    path 'percent_rate'
                          , min_value       number(22,4)    path 'min_value'
                          , max_value       number(22,4)    path 'max_value'
                          , length_type     varchar2(8)     path 'length_type'
                          , sum_threshold   number(22,4)    path 'sum_threshold'
                          , count_threshold number(22,4)    path 'count_threshold'
               ) x
    ) loop
        fcl_ui_fee_pkg.add_fee_tier(
                i_fee_id            => io_fee_rec.fee_id
              , i_fixed_rate        => tier.fixed_rate
              , i_percent_rate      => tier.percent_rate
              , i_min_value         => nvl(tier.min_value, 0)
              , i_max_value         => nvl(tier.max_value, 0)
              , i_length_type       => tier.length_type
              , i_sum_threshold     => nvl(tier.sum_threshold, 0)
              , i_count_threshold   => nvl(tier.count_threshold, 0)
              , o_fee_tier_id       => l_fee_tier_id
              , o_seqnum            => l_seqnum
        );
    end loop;

    trc_log_pkg.debug(
        i_text          => 'New fee added: fee_id [#1]'
      , i_env_param1    => io_fee_rec.fee_id
    );

end;

procedure register_fee_record(
    io_fee_record   in out nocopy   t_fee_record_rec
) is
cursor l_cur_fee is
    select  x.command
          , x.fee_id
          , x.fee_type
          , x.fee_rate_calc
          , x.fee_base_calc
          , x.currency
          , x.inst_id
          , x.cycle_id
          , x.limit_id
          , to_date(x.start_date, com_api_const_pkg.XML_DATETIME_FORMAT) start_date
          , to_date(x.end_date, com_api_const_pkg.XML_DATETIME_FORMAT) end_date
          , x.tier
       from xmltable ('/fee'
              passing io_fee_record.fee
              columns command         varchar2(8)   path 'command'
                    , fee_id          number        path 'fee_id'
                    , fee_type        varchar2(8)   path 'fee_type'
                    , fee_rate_calc   varchar2(8)   path 'fee_rate_calc'
                    , fee_base_calc   varchar2(8)   path 'fee_base_calc'
                    , currency        varchar2(3)   path 'currency'
                    , inst_id         number        path 'inst_id'
                    , cycle_id        number        path 'cycle_id'
                    , limit_id        number        path 'limit_id'
                    , start_date      varchar2(20)  path 'start_date'
                    , end_date        varchar2(20)  path 'end_date'
                    , tier            xmltype       path 'tier'
            ) x;

    l_customer_id       com_api_type_pkg.t_medium_id;
    l_terminal_id       com_api_type_pkg.t_short_id;
    l_provider_id       com_api_type_pkg.t_short_id;
    l_account_id        com_api_type_pkg.t_account_id;
    l_service_id        com_api_type_pkg.t_short_id;
    l_purpose_id        com_api_type_pkg.t_short_id;
    l_mod_id            com_api_type_pkg.t_tiny_id;
    l_fee_rec           t_fee_rec;
    l_revenue_sharing_id    com_api_type_pkg.t_medium_id;
    l_seqnum            com_api_type_pkg.t_seqnum;
begin
    trc_log_pkg.debug(
        i_text          => 'register_fee_record'
    );

    if io_fee_record.customer_number is not null then
        begin
            select c.id
                 , nvl(io_fee_record.inst_id, c.inst_id)
              into l_customer_id
                 , io_fee_record.inst_id
              from prd_customer c
             where c.customer_number = upper(io_fee_record.customer_number);

        exception
            when no_data_found then
                trc_log_pkg.error(
                    i_text          => 'Customer not found by number [#1]'
                  , i_env_param1    => io_fee_record.customer_number
                );
                com_api_error_pkg.raise_error(
                    i_error         => 'CUSTOMER_NOT_FOUND'
                  , i_env_param1    => io_fee_record.customer_number
                );

        end;
    end if;

    if io_fee_record.terminal_number is not null then
        begin
           select id
                , nvl(io_fee_record.inst_id, inst_id)
             into l_terminal_id
                , io_fee_record.inst_id
             from acq_terminal
            where terminal_number = io_fee_record.terminal_number;

        exception
            when no_data_found then
                trc_log_pkg.error(
                    i_text          => 'Terminal not found by number [#1]'
                  , i_env_param1    => io_fee_record.terminal_number
                );
                com_api_error_pkg.raise_error(
                    i_error         => 'TERMINAL_NOT_FOUND'
                );

            when too_many_rows then
                trc_log_pkg.error(
                    i_text          => 'More than one terminal have the same number [#1]'
                  , i_env_param1    => io_fee_record.terminal_number
                );
                raise;

        end;
    end if;

    if io_fee_record.provider_number is not null then
        begin
           select p.id
                , nvl(io_fee_record.inst_id, c.inst_id)
             into l_provider_id
                , io_fee_record.inst_id
             from pmo_provider p
                , prd_customer c
            where p.provider_number = io_fee_record.provider_number
              and c.ext_entity_type = pmo_api_const_pkg.ENTITY_TYPE_SERVICE_PROVIDER
              and c.ext_object_id = p.id;

        exception
           when no_data_found then
               trc_log_pkg.error(
                    i_text          => 'Provider not found by number [#1]'
                  , i_env_param1    => io_fee_record.provider_number
               );

               com_api_error_pkg.raise_error(
                    i_error         => 'PROVIDER_NOT_FOUND'
               );

           when too_many_rows then
               trc_log_pkg.error(
                   i_text          => 'More than one provider have the same number [#1]'
                 , i_env_param1    => io_fee_record.provider_number
               );
               raise;
        end;
    end if;

    if io_fee_record.account_number is not null then
        begin
           select id
                , nvl(io_fee_record.inst_id, inst_id)
             into l_account_id
                , io_fee_record.inst_id
             from acc_account
            where account_number = io_fee_record.account_number;

        exception
           when no_data_found then
              trc_log_pkg.error(
                    i_text          => 'Account not found by number [#1]'
                  , i_env_param1    => io_fee_record.account_number
              );
              com_api_error_pkg.raise_error(
                  i_error         => 'ACCOUNT_NOT_FOUND'
              );

        end;
    end if;

    if io_fee_record.purpose_number is not null then
        begin
            select id
              into l_purpose_id
              from pmo_purpose
             where purpose_number = io_fee_record.purpose_number;

        exception
            when no_data_found then
                trc_log_pkg.error(
                    i_text          => 'Purpose not found by number [#1]'
                  , i_env_param1    => io_fee_record.purpose_number
                );

                com_api_error_pkg.raise_error(
                    i_error         => 'PAYMENT_PURPOSE_NOT_EXISTS'
                  , i_env_param1    => io_fee_record.purpose_number
                );
        end;
    end if;

    process_modifier(
        i_inst_id       => io_fee_record.inst_id
      , i_mod_name      => io_fee_record.mod_name
      , i_mod_condition => io_fee_record.mod_condition
      , o_mod_id        => l_mod_id
    );

    open l_cur_fee;

    loop
        fetch l_cur_fee into l_fee_rec;
        exit when l_cur_fee%notfound;

        begin
            select id
              into l_revenue_sharing_id
              from acq_revenue_sharing
             where nvl(terminal_id, 0)  = nvl(l_terminal_id, 0)
               and nvl(customer_id, 0)  = nvl(l_customer_id, 0)
               and nvl(account_id, 0)   = nvl(l_account_id, 0)
               and nvl(provider_id, 0)  = nvl(l_provider_id, 0)
               and nvl(mod_id, 0)       = nvl(l_mod_id, 0)
               and nvl(service_id, 0)   = nvl(l_service_id, 0)
               and nvl(purpose_id, 0)   = nvl(l_purpose_id, 0)
               and fee_type = l_fee_rec.fee_type
               and inst_id = io_fee_record.inst_id;

            trc_log_pkg.debug(
                i_text          => 'acq_revenue_sharing found [#1]'
              , i_env_param1    => l_revenue_sharing_id
            );

        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text          => 'acq_revenue_sharing not found'
                );
                l_revenue_sharing_id    := null;
        end;

        trc_log_pkg.debug(
            i_text          => 'process revenue sharing fee: command [#1], revenue_sharing_id [#2], fee_type [#3]'
          , i_env_param1    => l_fee_rec.command
          , i_env_param2    => l_revenue_sharing_id
          , i_env_param3    => l_fee_rec.fee_type
        );

        if l_revenue_sharing_id is null then
            if l_fee_rec.command in (
                app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
              , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
            ) then
                trc_log_pkg.error(
                    i_text          => 'Fee not found: command [#1], fee_type [#2], customer [#3], provider [#4], terminal [#5], purpose [#6]'
                  , i_env_param1    => l_fee_rec.command
                  , i_env_param2    => l_fee_rec.fee_type
                  , i_env_param3    => io_fee_record.customer_number
                  , i_env_param4    => io_fee_record.provider_number
                  , i_env_param5    => io_fee_record.terminal_number
                  , i_env_param6    => io_fee_record.purpose_number
                );

                com_api_error_pkg.raise_error(
                    i_error => 'FEE_NOT_FOUND'
                );

            elsif l_fee_rec.command in (
                app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
              , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
              , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
            ) then
                if l_fee_rec.fee_id is null then
                    register_fee(
                        io_fee_rec      => l_fee_rec
                      , i_inst_id       => io_fee_record.inst_id
                    );

                end if;

                acq_ui_revenue_sharing_pkg.add_revenue_sharing(
                    o_revenue_sharing_id    => l_revenue_sharing_id
                  , o_seqnum                => l_seqnum
                  , i_terminal_id           => l_terminal_id
                  , i_customer_id           => l_customer_id
                  , i_account_id            => l_account_id
                  , i_provider_id           => l_provider_id
                  , i_mod_id                => l_mod_id
                  , i_service_id            => l_service_id
                  , i_purpose_id            => l_purpose_id
                  , i_fee_type              => l_fee_rec.fee_type
                  , i_fee_id                => l_fee_rec.fee_id
                  , i_inst_id               => io_fee_record.inst_id
                );

                trc_log_pkg.debug(
                    i_text          => 'Revenue sharing has been added [#1] for fee id [#2]'
                  , i_env_param1    => l_revenue_sharing_id
                  , i_env_param2    => l_fee_rec.fee_id
                );

            else
                null;

            end if;

        else
            select seqnum
              into l_seqnum
              from acq_revenue_sharing
             where id = l_revenue_sharing_id;

            if l_fee_rec.command =  app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
                trc_log_pkg.error(
                    i_text          => 'Fee aready exists: command [#1], fee_type [#2], customer [#3], provider [#4], terminal [#5], purpose [#6]'
                  , i_env_param1    => l_fee_rec.command
                  , i_env_param2    => l_fee_rec.fee_type
                  , i_env_param3    => io_fee_record.customer_number
                  , i_env_param4    => io_fee_record.provider_number
                  , i_env_param5    => io_fee_record.terminal_number
                  , i_env_param6    => io_fee_record.purpose_number
                );

                com_api_error_pkg.raise_error(
                    i_error         => 'FEE_TYPE_ALREADY_EXIST'
                  , i_env_param1    => l_fee_rec.fee_type
                );

            elsif l_fee_rec.command in (
                app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
              , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
            ) then
                if l_fee_rec.fee_id is null then
                    register_fee(
                        io_fee_rec      => l_fee_rec
                      , i_inst_id       => io_fee_record.inst_id
                    );

                end if;

                acq_ui_revenue_sharing_pkg.modify_revenue_sharing(
                    i_revenue_sharing_id    => l_revenue_sharing_id
                  , io_seqnum               => l_seqnum
                  , i_fee_type              => l_fee_rec.fee_type
                  , i_fee_id                => l_fee_rec.fee_id
                );

                trc_log_pkg.debug(
                    i_text          => 'Revenue sharing has been updated [#1] by fee id [#2]'
                  , i_env_param1    => l_revenue_sharing_id
                  , i_env_param2    => l_fee_rec.fee_id
                );

            elsif l_fee_rec.command in (
                app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
              , app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
            ) then
                acq_ui_revenue_sharing_pkg.remove_revenue_sharing(
                    i_revenue_sharing_id    => l_revenue_sharing_id
                  , i_seqnum                => l_seqnum
                );

                trc_log_pkg.debug(
                    i_text          => 'Revenue sharing has been removed [#1] for fee id [#2]'
                  , i_env_param1    => l_revenue_sharing_id
                  , i_env_param2    => l_fee_rec.fee_id
                );

            end if;

        end if;

    end loop;

    close l_cur_fee;

exception
    when others then
        if l_cur_fee%isopen then
            close l_cur_fee;

        end if;

        raise;

end register_fee_record;

procedure import_fees is
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;

begin
    savepoint read_fees_start;

    trc_log_pkg.debug(
        i_text          => 'Read fees'
    );

    prc_api_stat_pkg.log_start;

    open cur_fee_count;
    fetch cur_fee_count into l_estimated_count;
    close cur_fee_count;
    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );

    open cur_fees;

    loop
        fetch cur_fees bulk collect into l_fee_record_tab limit 1000;
        for i in 1 .. l_fee_record_tab.count loop
            savepoint parse_fee_start;
             begin
                register_fee_record(
                    io_fee_record   => l_fee_record_tab(i)
                );

                l_processed_count := l_processed_count + 1;

            exception
                when others then
                    rollback to savepoint parse_fee_start;
                    trc_log_pkg.error(
                        i_text          => 'Fee record with error: #1'
                      , i_env_param1    => i
                    );

                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        l_excepted_count := l_excepted_count + 1;

                    else
                        close   cur_fees;
                        raise;

                    end if;
            end;

            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => l_processed_count
                  , i_excepted_count    => l_excepted_count
                );
            end if;
        end loop;

        exit when cur_fees%notfound;

    end loop;

    close cur_fees;

    prc_api_stat_pkg.log_end (
        i_excepted_total     => l_excepted_count
        , i_processed_total  => l_processed_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to savepoint read_fees_start;

        if cur_fees%isopen then
            close cur_fees;

        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;

end import_fees;

end acq_prc_import_pkg;
/
