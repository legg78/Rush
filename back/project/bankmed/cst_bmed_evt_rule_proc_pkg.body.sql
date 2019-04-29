create or replace package body cst_bmed_evt_rule_proc_pkg as

procedure check_direct_debit_paid is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.check_direct_debit_paid: ';
    l_params                        com_api_type_pkg.t_param_tab;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_account_id                    com_api_type_pkg.t_medium_id;
    l_order_id                      com_api_type_pkg.t_long_id;
    l_sysdate                       date;
begin
    l_params      := evt_api_shared_data_pkg.g_params;
    l_sysdate     := com_api_sttl_day_pkg.get_sysdate;

    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_entity_type [#1], l_object_id [#2]'
      , i_env_param1 => l_entity_type
      , i_env_param2 => l_object_id
    );

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_account_id := l_object_id;
    else
        select max(account_id)
          into l_account_id
          from acc_account_object
         where entity_type = l_entity_type
           and object_id   = l_object_id;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'found by acc_account_object l_account_id [#1]'
          , i_env_param1 => l_account_id
        );
    end if;
    
    begin
        select o.id
          into l_order_id
          from (
                select o.id
                  from pmo_order o
                 where o.status       = pmo_api_const_pkg.PMO_STATUS_WAIT_CONFIRM
                   and o.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                   and o.object_id    = l_account_id
                   and o.amount       > 0
                 order by o.event_date desc
               ) o
         where rownum = 1;
    exception
        when no_data_found then
            l_order_id := null;
    end;
    
    if l_order_id is not null then
        for eo in (select a.id
                     from evt_event_object a
                        , pmo_order        o
                    where decode(a.status, 'EVST0001', a.procedure_name, null) = 'CST_BMED_PRC_OUTGOING_PKG.PROCESS_EXPORT_CBS'
                      and o.id              = l_order_id
                      and a.object_id       = o.id
                      and a.entity_type     = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
                      and a.eff_date       <= l_sysdate)
        loop
            evt_api_event_pkg.process_event_object(
                i_event_object_id       => eo.id
            );
        end loop;
        pmo_api_order_pkg.set_order_status(
            i_order_id              => l_order_id
          , i_status                => cst_bmed_api_const_pkg.PMO_STATUS_NOT_PAID
        );
    end if;

end check_direct_debit_paid;

end;
/
