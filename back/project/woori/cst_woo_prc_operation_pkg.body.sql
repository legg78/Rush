create or replace package body cst_woo_prc_operation_pkg as
/*********************************************************
*  Processes for specific pre/post-processing operations <br />
*  Created by  A. Alalykin (alalykin@bpcbt.com) at 11.04.2017 <br />
*  Module: CST_WOO_PRC_OPERATION_PKG <br />
*  @headcom
**********************************************************/

/*
 * If current system date is in the problem range (see (2)) then the procedure postpones
 * processing of operations by changing their status <Awaiting closure invoice>, these
 * operations should satisfy the following conditions:
 * 1) have active credit service;
 * 2) operation dates are in the range since prev_date(CYTP1006)+1 till next_date(CYTP1001).
 * Operations are unblocked for normal processing after date next_date(CYTP1001)+1 by
 * procedure unblock_credit_operations.
 * @param i_invoicing_lag - lag of ending CYTP1001 (Invoicing period)
                            compared to CYTP1006 (Forced interest charge period)
 */
procedure freeze_credit_operations(
    i_invoicing_lag    in     com_api_type_pkg.t_tiny_id
) is
    LOG_PREFIX                constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.freeze_credit_operations';
    BULK_LIMIT                constant pls_integer := 100;

    cursor l_cursor_operations(
        i_eff_date    in    date
    )
    is
    select opr.id               as oper_id
         , opr.oper_date        as oper_date
         , case
                when opr.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT then
                     (select amount
                        from opr_additional_amount
                       where amount_type = com_api_const_pkg.AMOUNT_PURPOSE_MACROS
                         and oper_id = opr.id)
                else opr.oper_amount
           end                  as oper_amount                  
         , case
                when opr.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT then
                     (select currency
                        from opr_additional_amount
                       where amount_type = com_api_const_pkg.AMOUNT_PURPOSE_MACROS
                         and oper_id = opr.id)
                else opr.oper_currency
           end                  as oper_currency
         , act.id               as account_id
         , ptp.inst_id
         , ptp.split_hash
         , min(so.start_date)   as crd_service_start_date
         , count(*) over ()     as total_count
      from opr_operation       opr
      join opr_participant     ptp    on ptp.oper_id              = opr.id
                                     and ptp.participant_type     = com_api_const_pkg.PARTICIPANT_ISSUER
      join opr_card            opc    on opc.oper_id              = ptp.oper_id
                                     and opc.participant_type     = ptp.participant_type
                                     and opc.split_hash           = ptp.split_hash
      join iss_card_vw         crd    on crd.card_number          = opc.card_number
                                     and crd.split_hash           = opc.split_hash
                                     and reverse(crd.card_number) = reverse(opc.card_number) -- support indexes
      join acc_account_object  ao     on ao.object_id             = crd.id
                                     and ao.entity_type           = iss_api_const_pkg.ENTITY_TYPE_CARD
                                     and ao.split_hash            = crd.split_hash
      join acc_account         act    on act.id                   = ao.account_id
                                     and act.split_hash           = ao.split_hash
      join prd_service_object  so     on so.object_id             = act.id
                                     and so.entity_type           = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                     and so.split_hash            = ao.split_hash
                                     and i_eff_date         between so.start_date
                                                                and nvl(so.end_date, to_date('01.01.3999', 'dd.mm.yyyy'))
      join prd_service         srv    on srv.id                   = so.service_id
                                     and srv.service_type_id      = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
                                     and srv.status               = prd_api_const_pkg.SERVICE_STATUS_ACTIVE
     where decode(opr.status, 'OPST0100', 'OPST0100', null) = 'OPST0100'
       and opr.oper_type not in ( opr_api_const_pkg.OPERATION_TYPE_CARD_STATUS   --'OPTP0171'
                                , cst_woo_const_pkg.OPERATION_PAYMENT_DD         --'OPTP7030' Payment from CBS
                                , cst_woo_const_pkg.OPERATION_PAYMENT            --'OPTP0028' Payment transaction
                                , opr_api_const_pkg.OPERATION_TYPE_REFUND        --'OPTP0020'
                                )
       and (    opr.msg_type  in (opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION)
            and opr.sttl_type in (opr_api_const_pkg.SETTLEMENT_USONUS)
             or
                opr.msg_type  in (opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT)
            and opr.sttl_type in (opr_api_const_pkg.SETTLEMENT_USONTHEM, opr_api_const_pkg.SETTLEMENT_INTERNAL
                , opr_api_const_pkg.SETTLEMENT_USONUS))
       and ptp.split_hash in (select split_hash from com_api_split_map_vw)
     group by
           opr.id
         , opr.original_id
         , opr.oper_date
         , opr.sttl_type
         , opr.oper_amount
         , opr.oper_currency
         , opr.msg_type
         , act.id
         , ptp.inst_id
         , ptp.split_hash
     order by
           act.id
    ;

    type t_cursor_operation_tab is table of l_cursor_operations%rowtype index by pls_integer;

    l_operation_tab                    t_cursor_operation_tab;
    l_eff_date                         date;
    l_crd_service_start_date           date;
    l_invoicing_next_date              date; -- date for cycle Invoicing period (CYTP1001)
    l_forced_intrst_chrg_prev_date     date; -- date for cycle Forced interest charge period (CYTP1006)
    l_param_name                       com_api_type_pkg.t_full_desc;
    l_estimated_count                  com_api_type_pkg.t_number_tab;
    l_excepted_count                   com_api_type_pkg.t_count := 0;
    l_processed_count                  com_api_type_pkg.t_count := 0;
    l_index                            com_api_type_pkg.t_count := 0;
    l_oper_ids                         com_api_type_pkg.t_long_tab;
    l_oper_amounts                     com_api_type_pkg.t_money_tab;
    l_oper_currencies                  com_api_type_pkg.t_curr_code_tab;
    l_accounts                         com_api_type_pkg.t_medium_tab;
    l_iss_inst_ids                     com_api_type_pkg.t_inst_id_tab;
    l_iss_split_hashes                 com_api_type_pkg.t_tiny_tab;
    l_unblock_dates                    com_api_type_pkg.t_date_tab;
    l_current_account_id               com_api_type_pkg.t_account_id;

    procedure get_credit_cycles_dates(
        i_account_id                   in     com_api_type_pkg.t_account_id
      , i_split_hash                   in     com_api_type_pkg.t_tiny_id
      , i_eff_date                     in     date
      , i_crd_service_start_date       in     date
      , i_invoicing_lag                in     com_api_type_pkg.t_tiny_id
      , o_forced_intrst_chrg_prev_date    out date
      , o_invoicing_next_date             out date
    ) is
        LOG_PREFIX                   constant com_api_type_pkg.t_name :=
            lower($$PLSQL_UNIT) || '.freeze_credit_operations->get_credit_cycles_dates()';
        l_invoicing_prev_date                 date;
        l_forced_intrst_chrg_next_date        date;
    begin
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ' << i_account_id [#1][#2], i_eff_date [#3], i_crd_service_start_date [#4]'
          , i_env_param1 => i_account_id
          , i_env_param2 => i_split_hash
          , i_env_param3 => to_char(i_eff_date,               com_api_const_pkg.LOG_DATE_FORMAT)
          , i_env_param4 => to_char(i_crd_service_start_date, com_api_const_pkg.LOG_DATE_FORMAT)
        );

        fcl_api_cycle_pkg.get_cycle_date(
            i_cycle_type   => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE -- CYTP1001
          , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => i_account_id
          , i_split_hash   => i_split_hash
          , i_add_counter  => com_api_const_pkg.FALSE
          , o_prev_date    => l_invoicing_prev_date
          , o_next_date    => o_invoicing_next_date
        );
        trc_log_pkg.debug(
            i_text       => 'l_invoicing_prev_date [#1], o_invoicing_next_date [#2]'
          , i_env_param1 => to_char(l_invoicing_prev_date, com_api_const_pkg.LOG_DATE_FORMAT)
          , i_env_param2 => to_char(o_invoicing_next_date, com_api_const_pkg.LOG_DATE_FORMAT)
        );

        fcl_api_cycle_pkg.get_cycle_date(
            i_cycle_type   => crd_api_const_pkg.FORCE_INT_CHARGE_CYCLE_TYPE -- CYTP1006
          , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => i_account_id
          , i_split_hash   => i_split_hash
          , i_add_counter  => com_api_const_pkg.FALSE
          , o_prev_date    => o_forced_intrst_chrg_prev_date
          , o_next_date    => l_forced_intrst_chrg_next_date
        );
        trc_log_pkg.debug(
            i_text       => 'o_forced_intrst_chrg_prev_date [#1], l_forced_intrst_chrg_next_date [#2]'
          , i_env_param1 => to_char(o_forced_intrst_chrg_prev_date, com_api_const_pkg.LOG_DATE_FORMAT)
          , i_env_param2 => to_char(l_forced_intrst_chrg_next_date, com_api_const_pkg.LOG_DATE_FORMAT)
        );

        -- If credit service has been just started, and CYTP1001/1006 cycles haven't been switched yet
        -- then process parameter <i_invoicing_lag> is used to determine if <i_eff_date> is in the problem
        -- period and operations by this account should be frozen.
        -- Example 1.
        -- Credit service is added on 02.05.2017, <i_invoicing_lag> = 5,
        -- invoicing period (CYTP1001) is set on 5th day of a month,
        -- forced interest charge period (CYTP1006) is set on last day of a month,
        -- the process is launched at 02.05.2017:
        -- CYTP1001: 02.05.2017-05.05.2017
        -- CYTP1006: 02.05.2017-31.05.2017
        -- The problem period will be defined as (02.05.2017; 05.05.2017],
        -- all operations from this interval will be frozen.
        -- Example 2.
        -- In previous conditions for cycles and <i_invoicing_lag> credit service is added on 10.05.2017,
        -- the process is launched at 10.05.2017:
        -- CYTP1001: 10.05.2017-05.06.2017
        -- CYTP1006: 10.05.2017-31.05.2017.
        -- Since the condition for <i_invoicing_lag> will be failed,
        -- so problem period will be defined as (10.05.2017; 05.05.2017];
        -- it is a negative time interval, no one operation will be inside of it.

        if      l_invoicing_prev_date = o_forced_intrst_chrg_prev_date
            and trunc(l_invoicing_prev_date) = trunc(i_crd_service_start_date)

        then
            if o_invoicing_next_date - i_eff_date >= i_invoicing_lag then
                trc_log_pkg.debug(
                    i_text       => '(1) between credit service creation [#1] and next invoicing date [#2]'
                                 || ' is more than [#3] days, RESTRICT freezing'
                  , i_env_param1 => to_char(i_crd_service_start_date, com_api_const_pkg.LOG_DATE_FORMAT)
                  , i_env_param2 => to_char(o_invoicing_next_date,    com_api_const_pkg.LOG_DATE_FORMAT)
                  , i_env_param3 => i_invoicing_lag
                );
                o_invoicing_next_date := add_months(o_invoicing_next_date, -1);
            end if;

        -- Otherwise, checking the following necessary condition is required:
        -- current invoicing period is nearly its ending,
        -- cycle Forced interest charge period (CYTP1006) has been already switched,
        -- cycle Invoicing period (CYTP1001) hasn't switched yet
        elsif l_invoicing_prev_date >= o_forced_intrst_chrg_prev_date then
            trc_log_pkg.debug(
                i_text       => '(2) RESTRICT freezing because prev_date(#1) >= prev_date(#2)'
              , i_env_param1 => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE -- CYTP1001
              , i_env_param2 => crd_api_const_pkg.FORCE_INT_CHARGE_CYCLE_TYPE -- CYTP1006
            );
            o_forced_intrst_chrg_prev_date := add_months(o_forced_intrst_chrg_prev_date, 1);
        end if;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ' >> the freezing period is [#1; #2]'
          , i_env_param1 => to_char(o_forced_intrst_chrg_prev_date, com_api_const_pkg.LOG_DATE_FORMAT)
          , i_env_param2 => to_char(o_invoicing_next_date, com_api_const_pkg.LOG_DATE_FORMAT)
        );
    end get_credit_cycles_dates;

    function get_oper_marked_event_id(
        i_inst_id            in            com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_tiny_id
    result_cache relies_on (evt_event)
    is
        l_event_id                         com_api_type_pkg.t_tiny_id;
    begin
        select min(e.id) keep (dense_rank first order by e.inst_id) -- default institution has lower priority
          into l_event_id
          from evt_event e
         where e.event_type = cst_woo_const_pkg.EVENT_TYPE_OPER_MARKED_AWAITED
          and (e.inst_id = i_inst_id
               or
               e.inst_id = ost_api_const_pkg.DEFAULT_INST);

        return l_event_id;
    end;

    procedure put_hold_macros(
        i_oper_id            in            com_api_type_pkg.t_long_id
      , i_account_id         in            com_api_type_pkg.t_account_id
      , i_amount             in            com_api_type_pkg.t_money
      , i_currency           in            com_api_type_pkg.t_curr_code
    ) is
        l_macros_id                        com_api_type_pkg.t_long_id;
        l_bunch_id                         com_api_type_pkg.t_long_id;
        l_accounts                         acc_api_type_pkg.t_account_by_name_tab;
        l_amounts                          com_api_type_pkg.t_amount_by_name_tab;
        l_dates                            com_api_type_pkg.t_date_by_name_tab;
        l_oper_params                      com_api_type_pkg.t_param_tab;
    begin
        rul_api_param_pkg.set_account(
            i_name            => com_api_const_pkg.ACCOUNT_PURPOSE_MACROS
          , i_account_rec     => acc_api_account_pkg.get_account(
                                     i_account_id  => i_account_id
                                   , i_mask_error  => com_api_const_pkg.TRUE
                                 )
          , io_account_tab    => l_accounts
        );

        rul_api_param_pkg.set_amount(
            i_name            => com_api_const_pkg.AMOUNT_PURPOSE_MACROS
          , i_amount          => i_amount
          , i_currency        => i_currency
          , i_conversion_rate => null
          , io_amount_tab     => l_amounts
        );

        acc_api_entry_pkg.put_macros(
            o_macros_id       => l_macros_id
          , o_bunch_id        => l_bunch_id
          , i_entity_type     => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id       => i_oper_id
          , i_macros_type_id  => cst_woo_const_pkg.MACROS_TYPE_ID_HOLD_AMOUNT
          , i_account_tab     => l_accounts
          , i_amount_tab      => l_amounts
          , i_date_tab        => l_dates       -- use sysdate for posting_date
          , i_account_name    => com_api_const_pkg.ACCOUNT_PURPOSE_MACROS
          , i_amount_name     => com_api_const_pkg.AMOUNT_PURPOSE_MACROS
          , i_amount_purpose  => com_api_const_pkg.AMOUNT_PURPOSE_MACROS
          , i_param_tab       => l_oper_params -- unnecessary because it is used for modifiers only
        );
    end put_hold_macros;

    procedure freeze_operations(
        io_oper_id_tab       in out nocopy com_api_type_pkg.t_long_tab
      , io_oper_amount_tab   in out nocopy com_api_type_pkg.t_money_tab
      , io_oper_currency_tab in out nocopy com_api_type_pkg.t_curr_code_tab
      , io_account_tab       in out nocopy com_api_type_pkg.t_medium_tab
      , io_inst_id_tab       in out nocopy com_api_type_pkg.t_inst_id_tab
      , io_split_hash_tab    in out nocopy com_api_type_pkg.t_tiny_tab
      , io_unblock_date_tab  in out nocopy com_api_type_pkg.t_date_tab
      , io_excepted_count    in out nocopy com_api_type_pkg.t_count
    ) is
        l_evt_object_id_tab                com_api_type_pkg.t_long_tab;
        l_session_id                       com_api_type_pkg.t_long_id;
        l_event_id_tab                     com_api_type_pkg.t_tiny_tab;
    begin
        savepoint new_bulk_of_operations;

        forall i in 1 .. io_oper_id_tab.count()
            update opr_operation
               set status = cst_woo_const_pkg.OPER_STATUS_AWAITING_CLS_INVCE
             where id = io_oper_id_tab(i);

        for i in 1 .. io_oper_id_tab.count() loop
            -- Put macros for hold operation amount on account's hold balance
            put_hold_macros(
                i_oper_id     => io_oper_id_tab(i)
              , i_account_id  => io_account_tab(i)
              , i_amount      => io_oper_amount_tab(i)
              , i_currency    => io_oper_currency_tab(i)
            );
            -- Generate events for the process of operations unblocking
            l_evt_object_id_tab(i) := com_api_id_pkg.get_id(
                                          i_seq   => evt_event_object_seq.nextval
                                        , i_date  => io_unblock_date_tab(i)
                                      );
            l_event_id_tab(i)      := get_oper_marked_event_id(
                                          i_inst_id => io_inst_id_tab(i)
                                      );
        end loop;

        l_session_id := prc_api_session_pkg.get_session_id();

        begin
            forall i in 1 .. l_evt_object_id_tab.count() save exceptions
                insert into evt_event_object(
                    id
                  , event_id
                  , procedure_name
                  , entity_type
                  , object_id
                  , eff_date
                  , event_timestamp
                  , inst_id
                  , split_hash
                  , status
                  , session_id
                )
                values(
                    l_evt_object_id_tab(i)
                  , l_event_id_tab(i)
                  , cst_woo_const_pkg.PROC_NAME_UNBLOCK_OPERATIONS
                  , opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  , io_oper_id_tab(i)
                  , io_unblock_date_tab(i)
                  , systimestamp
                  , io_inst_id_tab(i)
                  , io_split_hash_tab(i)
                  , evt_api_const_pkg.EVENT_STATUS_READY
                  , l_session_id
                );
        exception
            when com_api_error_pkg.e_dml_errors then
                -- Log errors for analysis and rollback an entire bulk of operations
                -- to be sure that there are no updated operations without events
                for i in 1 .. sql%bulk_exceptions.count() loop
                    trc_log_pkg.error(
                        i_text       => 'CST_WOO_ERROR_ON_INSERTING_EVENT_OBJECT'
                      , i_env_param1 => sqlerrm(-sql%bulk_exceptions(i).error_code)
                      , i_env_param2 => l_evt_object_id_tab(i)
                      , i_env_param3 => l_event_id_tab(i)
                      , i_env_param4 => io_oper_id_tab(i)
                      , i_env_param5 => io_inst_id_tab(i)
                      , i_env_param6 => io_split_hash_tab(i)
                    );
                end loop;

                io_excepted_count := io_excepted_count + sql%bulk_exceptions.count();

                rollback to savepoint new_bulk_of_operations;

                trc_log_pkg.debug(
                    i_text       => LOG_PREFIX || '->change_operations >> '
                                               || 'SKIP bulk of [#1] operations due to exceptions'
                  , i_env_param1 => sql%bulk_exceptions.count()
                );
        end;

        io_oper_id_tab.delete();
        io_inst_id_tab.delete();
        io_split_hash_tab.delete();
        io_oper_amount_tab.delete();
        io_oper_currency_tab.delete();
        io_account_tab.delete();
        io_unblock_date_tab.delete();
    end freeze_operations;

begin
    prc_api_stat_pkg.log_start();

    l_eff_date := com_api_sttl_day_pkg.get_sysdate();

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << l_eff_date (system date) [#1]'
      , i_env_param1 => to_char(l_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
    );

    if nvl(i_invoicing_lag, 0) <= 0 then
        -- Critical parameter <i_invoicing_lag> should be positive
        select min(param_name || ' ' || label)
          into l_param_name
          from prc_ui_parameter_vw
         where param_name = 'I_INVOICING_LAG'
           and lang       = get_user_lang();

        com_api_error_pkg.raise_fatal_error(
            i_error      => 'INVALID_PARAMETER_VALUE'
          , i_env_param1 => l_param_name
          , i_env_param2 => i_invoicing_lag
        );
    end if;

    open l_cursor_operations(i_eff_date => l_eff_date);

    loop
        fetch l_cursor_operations
        bulk collect into l_operation_tab
        limit BULK_LIMIT;

        if l_processed_count = 0 then
            l_processed_count :=
                case
                    when l_operation_tab.exists(1)
                    then nvl(l_operation_tab(1).total_count, 0)
                    else 0
                end;
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || ': estimated count of operations for potential FREEZING is [#1]'
              , i_env_param1 => l_processed_count
            );
            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_processed_count
            );
            l_processed_count := 0;
        end if;

        trc_log_pkg.debug(
            i_text       => 'l_operation_tab.count() = ' || l_operation_tab.count()
        );

        for i in 1 .. l_operation_tab.count() loop
            -- Check dates of cycles CYTP1001/CYTP1006 for every account once because cursor is ordered by account
            if l_current_account_id is null or l_current_account_id != l_operation_tab(i).account_id then
                get_credit_cycles_dates(
                    i_account_id                   => l_operation_tab(i).account_id
                  , i_split_hash                   => l_operation_tab(i).split_hash
                  , i_eff_date                     => l_eff_date
                  , i_crd_service_start_date       => l_operation_tab(i).crd_service_start_date
                  , i_invoicing_lag                => i_invoicing_lag
                  , o_forced_intrst_chrg_prev_date => l_forced_intrst_chrg_prev_date
                  , o_invoicing_next_date          => l_invoicing_next_date
                );
                l_current_account_id := l_operation_tab(i).account_id;
            end if;

            trc_log_pkg.debug(
                i_text       => 'Checking operation [#1], oper_date [#2]'
              , i_env_param1 => l_operation_tab(i).oper_id
              , i_env_param2 => to_char(l_operation_tab(i).oper_date, com_api_const_pkg.LOG_DATE_FORMAT)
            );
            if      l_operation_tab(i).oper_date >= l_forced_intrst_chrg_prev_date + 1
                and l_operation_tab(i).oper_date <= l_invoicing_next_date
            then
                l_index                     := l_oper_ids.count() + 1;
                l_oper_ids(l_index)         := l_operation_tab(i).oper_id;
                l_oper_amounts(l_index)     := l_operation_tab(i).oper_amount;
                l_oper_currencies(l_index)  := l_operation_tab(i).oper_currency;
                l_accounts(l_index)         := l_operation_tab(i).account_id;
                l_iss_inst_ids(l_index)     := l_operation_tab(i).inst_id;
                l_iss_split_hashes(l_index) := l_operation_tab(i).split_hash;
                -- Prepare <i_eff_date> value for unblocking events (on freezing operations)
                l_unblock_dates(l_index)    := trunc(l_invoicing_next_date) + 1;
            end if;
        end loop;

        l_processed_count := l_processed_count + l_oper_ids.count();

        -- Delay processing of all operations from the problem range
        -- by changing their status to <Awaiting> and scheduling subsequent unblocking via events
        if l_oper_ids.count() >= BULK_LIMIT or l_cursor_operations%notfound then
            freeze_operations(
                io_oper_id_tab        => l_oper_ids
              , io_oper_amount_tab    => l_oper_amounts
              , io_oper_currency_tab  => l_oper_currencies
              , io_account_tab        => l_accounts
              , io_inst_id_tab        => l_iss_inst_ids
              , io_split_hash_tab     => l_iss_split_hashes
              , io_unblock_date_tab   => l_unblock_dates
              , io_excepted_count     => l_excepted_count
            );
        end if;

        prc_api_stat_pkg.log_current(
            i_excepted_count    => l_excepted_count
          , i_current_count     => l_processed_count
        );

        exit when l_cursor_operations%notfound;
    end loop; -- cursor

    close l_cursor_operations;

    trc_log_pkg.debug(
        i_text             => LOG_PREFIX || ' >> processed operations (total/failed): #1/#2'
      , i_env_param1       => l_processed_count
      , i_env_param2       => l_excepted_count
    );
    -- Since estimated count of operations for freezing is unknown until end of the process, rewrite this count
    prc_api_stat_pkg.log_estimation(
        i_estimated_count  => l_processed_count
    );
    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback;

        if l_cursor_operations%isopen then
            close l_cursor_operations;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end freeze_credit_operations;

/*
 * The procedure unblocks operations that were previously postponed by procedure freeze_credit_operations
 * based on events in evt_event_object (where current system date is equal to events' eff_date).
 */
procedure unblock_credit_operations
is
    cursor cur_events_for_operations(
        i_eff_date    in    date
    ) is
    select eo.id
         , opr.id
         , count(distinct opr.id) over () as estimated_count
      from      evt_event_object  eo
      left join opr_operation     opr   on opr.id     = eo.object_id
                                       and opr.status = cst_woo_const_pkg.OPER_STATUS_AWAITING_CLS_INVCE
     where eo.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and eo.eff_date    <= i_eff_date
       and decode(eo.status, 'EVST0001', eo.procedure_name, null) = cst_woo_const_pkg.PROC_NAME_UNBLOCK_OPERATIONS
       and eo.split_hash in (select split_hash from com_api_split_map_vw)
    ;

    LOG_PREFIX                constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.unblock_credit_operations';
    BULK_LIMIT                constant pls_integer := 100;
    l_sysdate                          date;
    l_estimated_count                  com_api_type_pkg.t_number_tab;
    l_processed_count                  com_api_type_pkg.t_count := 0;
    l_event_object_ids                 com_api_type_pkg.t_number_tab;
    l_src_oper_ids                     num_tab_tpt := num_tab_tpt();
    l_oper_ids                         num_tab_tpt := num_tab_tpt();
begin
    prc_api_stat_pkg.log_start();

    l_sysdate := com_api_sttl_day_pkg.get_sysdate();

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << l_sysdate [#1]'
      , i_env_param1 => to_char(l_sysdate, com_api_const_pkg.LOG_DATE_FORMAT)
    );

    open cur_events_for_operations(i_eff_date => l_sysdate);

    loop
        fetch cur_events_for_operations bulk collect
         into l_event_object_ids
            , l_src_oper_ids
            , l_estimated_count
        limit BULK_LIMIT;

        if l_processed_count = 0 then
            l_estimated_count(1) := case
                                        when l_estimated_count.exists(1)
                                        then nvl(l_estimated_count(1), 0)
                                        else 0
                                    end;
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || ': estimated count of operations for UNBLOCKING is [#1]'
              , i_env_param1 => l_estimated_count(1)
            );
            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count(1)
            );
        end if;

        -- There may be some records in EVT_EVENT_OBJECT for a single operation, some operations
        -- may have unsuitable status, so that l_src_oper_ids may be a sparsed collection.
        -- For process statistics it is necessary to make this collection a dense one.
        select column_value
          bulk collect into l_oper_ids
          from table(cast(l_src_oper_ids as num_tab_tpt))
         group by
               column_value;

        forall i in 1 .. l_oper_ids.count()
            update opr_operation
               set status = opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
             where id     = l_oper_ids(i)
               and status = cst_woo_const_pkg.OPER_STATUS_AWAITING_CLS_INVCE; -- re-check

        for i in 1 .. l_oper_ids.count() loop
            acc_api_entry_pkg.cancel_processing(
                i_entity_type    => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id      => l_oper_ids(i)
              , i_macros_status  => acc_api_const_pkg.MACROS_STATUS_HOLDED
              , i_macros_type    => cst_woo_const_pkg.MACROS_TYPE_ID_HOLD_AMOUNT
            );
        end loop;

        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab  => l_event_object_ids
        );

        l_processed_count := l_processed_count + l_oper_ids.count();

        prc_api_stat_pkg.log_current(
            i_excepted_count    => 0
          , i_current_count     => l_processed_count
        );

        exit when cur_events_for_operations%notfound;
    end loop;

    close cur_events_for_operations;

    trc_log_pkg.debug(
        i_text             => LOG_PREFIX || ' >> operations were processed: #1'
      , i_env_param1       => l_processed_count
    );
    prc_api_stat_pkg.log_end(
        i_excepted_total   => 0
      , i_processed_total  => l_processed_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback;

        if cur_events_for_operations%isopen then
            close cur_events_for_operations;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end unblock_credit_operations;

end;
/
