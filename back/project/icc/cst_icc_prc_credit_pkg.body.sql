create or replace package body cst_icc_prc_credit_pkg as

/*
 * The process checks out all credit accounts and generates events EVNT5034 for those
 * whose overlimit balances are equal or more than their credit limits.
 */
procedure check_bad_credits(
    i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_event_type         in     com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name  := lower($$PLSQL_UNIT) || '.check_bad_credits ';
    BULK_LIMIT         constant com_api_type_pkg.t_count := 100;

    l_eff_date                  date;

    cursor cur_accounts is
        select a.id as account_id
             , a.split_hash
             , sum(case when b.balance_type  = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
                        then b.balance
                   end) as assigned_exceed
             , sum(case when b.balance_type != crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
                        then b.balance
                   end) as overlimit
          from prd_service_object o
          join prd_service        s   on  s.id         = o.service_id
          join acc_account        a   on  a.id         = o.object_id
                                      and a.split_hash = o.split_hash
          join acc_balance        b   on  b.account_id = a.id
         where o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
           and a.account_type    = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
           and a.status          = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE
           and a.inst_id         = i_inst_id
           and o.split_hash in (select v.split_hash from com_api_split_map_vw v)
           and l_eff_date between nvl(trunc(o.start_date), l_eff_date)
                              and nvl(o.end_date,          l_eff_date + 1)
           and b.balance_type in (crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
                                , crd_api_const_pkg.BALANCE_TYPE_OVERLIMIT)
        group by
              a.id
            , a.split_hash
        having sum(case when b.balance_type  = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
                        then b.balance
                   end)
               <=
               sum(case when b.balance_type != crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
                        then b.balance
                   end)
    ;

    type t_accounts_tab is table of cur_accounts%rowtype index by pls_integer;

    l_accounts_tab              t_accounts_tab;
    l_count                     com_api_type_pkg.t_count := 0;
begin
    prc_api_stat_pkg.log_start();

    l_eff_date := com_api_sttl_day_pkg.get_sysdate();

    open cur_accounts;

    loop
        fetch cur_accounts bulk collect into l_accounts_tab limit BULK_LIMIT;

        for i in 1 .. l_accounts_tab.count() loop
            if l_accounts_tab(i).assigned_exceed > 0 then
                evt_api_event_pkg.register_event(
                    i_event_type   => i_event_type
                  , i_eff_date     => l_eff_date
                  , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id    => l_accounts_tab(i).account_id
                  , i_inst_id      => i_inst_id
                  , i_split_hash   => l_accounts_tab(i).split_hash
                  , i_status       => null
                );
                l_count := l_count + 1;
            end if;
        end loop;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'l_accounts_tab.count [#1], l_count [#2]'
          , i_env_param1 => l_accounts_tab.count()
          , i_env_param2 => l_count
        );

        exit when cur_accounts%notfound;
    end loop;

    close cur_accounts;

    prc_api_stat_pkg.log_end(
        i_processed_total => l_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        if cur_accounts%isopen then
            close cur_accounts;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED: l_accounts_tab.count [#2], l_count [#3], sqlerrm: #1'
          , i_env_param1 => sqlerrm
          , i_env_param2 => l_accounts_tab.count()
          , i_env_param3 => l_count
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end check_bad_credits;

end;
/
