create or replace package body cst_gpb_pmo_prc_make_pkg as

EVENT_TYPE_ENCASH_OPER_RECALC   constant com_api_type_pkg.t_dict_value := 'EVNT5208';

type t_oper_agg_rec is record(
    oper_type                     com_api_type_pkg.t_dict_value
  , oper_currency                 com_api_type_pkg.t_curr_code
  , oper_amount                   com_api_type_pkg.t_money
  , oper_id_tab                   num_tab_tpt
);

type t_oper_agg_tab is table of t_oper_agg_rec index by binary_integer;

type t_terminal_rec is record(
    terminal_id                   com_api_type_pkg.t_short_id
  , split_hash                    com_api_type_pkg.t_tiny_id
  , inst_id                       com_api_type_pkg.t_inst_id
  , merchant_number               com_api_type_pkg.t_merchant_number
  , customer_id                   com_api_type_pkg.t_medium_id
);
type t_terminal_tab is table of t_terminal_rec index by binary_integer;

procedure get_terminal(
    i_terminal_type_tab   in      com_dict_tpt
  , i_inst_id             in      com_api_type_pkg.t_inst_id
  , o_terminal_tab           out  t_terminal_tab
) is
begin
    if i_terminal_type_tab.count > 0 then
        select t.id
             , t.split_hash
             , t.inst_id
             , m.merchant_number
             , c.customer_id
          bulk collect into
               o_terminal_tab
          from acq_terminal t
             , acq_merchant m
             , prd_contract c
         where m.id(+) = t.merchant_id
           and c.id    = t.contract_id
           and t.terminal_type in (select x.column_value from table(cast(i_terminal_type_tab as com_dict_tpt)) x)
           and (i_inst_id = t.inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST);
    else
        trc_log_pkg.debug(
            i_text => 'Terminal type list is empty. No terminal retreived.'
        );
    end if;
end get_terminal;

procedure get_operations_with_lag(
    i_oper_date     in     date
  , i_terminal_id   in     com_api_type_pkg.t_short_id
  , i_split_hash    in     com_api_type_pkg.t_tiny_id
  , o_oper_agg_tab     out t_oper_agg_tab
) as
    l_oper_date            date;
    l_oper_date_start      date;
begin
    -- Get date_beg as oper_date of previous A19-operation or use last EOD date instead
    begin
        select greatest(oper_date, i_oper_date)
             , oper_date_lag
          into l_oper_date
             , l_oper_date_start
          from (select o.oper_date
                     , lag(o.oper_date) over(order by o.oper_date) as oper_date_lag
                  from opr_operation   o
                     , opr_participant p
                 where o.id               = p.oper_id
                   and o.status          in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                          , opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES)
                   and o.part_key         = trunc(i_oper_date)
                   and p.part_key         = trunc(i_oper_date)
                   and p.split_hash       = i_split_hash
                   and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                   and o.oper_type        = opr_api_const_pkg.OPERATION_TYPE_ATM_SETTLEMENT
                   and o.oper_date       <= i_oper_date
                 order by o.oper_date desc
                        , o.id        desc
                )
         where rownum = 1;

    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text       => 'No operations of [#1] found before [#2]'
              , i_env_param1 => opr_api_const_pkg.OPERATION_TYPE_ATM_SETTLEMENT
              , i_env_param2 => i_oper_date
            );
    end;

    if l_oper_date_start is null then

        select min(o.oper_date)
          into l_oper_date_start
          from opr_operation   o
             , opr_participant p
         where o.id               = p.oper_id
           and o.status          in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                  , opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES)
           and o.part_key         = trunc(i_oper_date)
           and p.part_key         = trunc(i_oper_date)
           and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
           and o.oper_type       in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                  , opr_api_const_pkg.OPERATION_TYPE_CASHIN)
           and o.oper_date       <= i_oper_date;
    end if;

    -- Get oper_id_tab, oper_count and oper_amount grouped by oper_type, oper_currency for this period
    select o.oper_type
         , o.oper_currency
         , sum(o.oper_amount)                                 as oper_amount
         , cast(collect(cast(o.id as number)) as num_tab_tpt) as oper_id_tab
     bulk collect
     into o_oper_agg_tab
      from opr_operation   o
         , opr_participant p
      where o.id               = p.oper_id
        and o.status          in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                               , opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES)
        and o.part_key         = trunc(i_oper_date)
        and p.part_key         = trunc(i_oper_date)
        and (p.terminal_id     = i_terminal_id or i_terminal_id is null)
        and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
        and o.oper_type       in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                               , opr_api_const_pkg.OPERATION_TYPE_CASHIN)
        and o.oper_date       <= l_oper_date
        and o.oper_date        > l_oper_date_start
      group by o.oper_type
             , o.oper_currency;

end get_operations_with_lag;

procedure get_operations(
    i_event_date    in     date
  , i_terminal_id   in     com_api_type_pkg.t_short_id
  , i_split_hash    in     com_api_type_pkg.t_tiny_id
  , o_oper_agg_tab     out t_oper_agg_tab
) as
    l_date_beg             date;
begin
    -- Get date_beg as oper_date of previous A19-operation or use last EOD date instead
    select greatest(max(oper_date), trunc(i_event_date))
      into l_date_beg
      from opr_operation   o
         , opr_participant p
     where o.id               = p.oper_id
       and o.status          in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                              , opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES)
       and o.part_key         = trunc(i_event_date)
       and p.part_key         = trunc(i_event_date)
       and (p.terminal_id     = i_terminal_id or i_terminal_id is null)
       and p.split_hash       = i_split_hash
       and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
       and o.oper_type        = opr_api_const_pkg.OPERATION_TYPE_ATM_SETTLEMENT
       and o.oper_date  between trunc(i_event_date) and i_event_date;

    -- Get oper_id_tab, oper_count and oper_amount grouped by oper_type, oper_currency for this period
    select o.oper_type
         , o.oper_currency
         , sum(o.oper_amount)                                 as oper_amount
         , cast(collect(cast(o.id as number)) as num_tab_tpt) as oper_id_tab
     bulk collect
     into o_oper_agg_tab
      from opr_operation o
         , opr_participant p
      where o.id               = p.oper_id
        and o.status           = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
        and o.part_key         = trunc(i_event_date)
        and p.part_key         = trunc(i_event_date)
        and (p.terminal_id     = i_terminal_id or i_terminal_id is null)
        and p.split_hash       = i_split_hash
        and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
        and o.oper_type       in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                               , opr_api_const_pkg.OPERATION_TYPE_CASHIN)
        and o.oper_date  between l_date_beg and i_event_date
      group by o.oper_type
             , o.oper_currency;

end get_operations;

procedure process(
    i_inst_id           in  com_api_type_pkg.t_inst_id
  , i_purpose_id        in  com_api_type_pkg.t_short_id
  , i_is_eod            in  com_api_type_pkg.t_boolean
) is
    l_estimated_count       com_api_type_pkg.t_long_id          := 0;
    l_excepted_count        com_api_type_pkg.t_long_id          := 0;
    l_processed_count       com_api_type_pkg.t_long_id          := 0;

    l_eff_date              date                                := com_api_sttl_day_pkg.get_sysdate;
    l_oper_id               com_api_type_pkg.t_long_id;
    l_oper_id_tab           com_api_type_pkg.t_long_tab;
    l_oper_date_tab         com_api_type_pkg.t_date_tab;
    l_oper_count            com_api_type_pkg.t_count            := 0;
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_termial_id_tab        com_api_type_pkg.t_short_tab;
    l_oper_split_hash_tab   com_api_type_pkg.t_tiny_tab;

    l_template_id           com_api_type_pkg.t_long_id;
    l_payment_order_id      com_api_type_pkg.t_long_id;

    l_oper_status_tab       com_api_type_pkg.t_dict_tab;
    l_terminal_type_tab     com_dict_tpt                        := com_dict_tpt();
    l_oper_detail_tab       opr_api_type_pkg.t_oper_detail_tab;
    i_object_tab            opr_api_type_pkg.t_oper_detail_tab;
    l_terminal_tab          t_terminal_tab;
    l_oper_agg_tab          t_oper_agg_tab;
    l_event_object_id_tab   com_api_type_pkg.t_number_tab;
    l_customer_id_tab       com_api_type_pkg.t_medium_tab;

    l_event_processed_obj_id_tab   com_api_type_pkg.t_number_tab;
    -- Events subcribed to process with entity type OPERATION of specified institution
    -- incassation operations (A19) are suggested to be subsribed here

    cursor cu_event_objects is
        select te.id            as terminal_id
             , eo.object_id     as oper_id
             , op.status
             , op.oper_date
             , eo.id            as event_object_id
             , eo.split_hash    as oper_split_hash
             , co.customer_id
          from evt_event_object eo
             , opr_operation    op
             , opr_participant  pa
             , acq_terminal     te
             , prd_contract     co
         where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_GPB_PMO_PRC_MAKE_PKG.PROCESS'
           and eo.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and eo.inst_id          = i_inst_id
           and op.id               = eo.object_id
           and pa.oper_id          = op.id
           and co.id               = te.contract_id
           and pa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
           and op.oper_type        = opr_api_const_pkg.OPERATION_TYPE_ATM_SETTLEMENT
           and eo.event_type       = EVENT_TYPE_ENCASH_OPER_RECALC
           and te.id               = pa.terminal_id
         order by eo.eff_date;

    cursor cu_event_objects_A19_count is
        select count(1)
          from evt_event_object eo
             , opr_operation    op
             , opr_participant  pa
         where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_GPB_PMO_PRC_MAKE_PKG.PROCESS'
           and eo.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and eo.inst_id          = i_inst_id
           and op.id               = eo.object_id
           and pa.oper_id          = op.id
           and pa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
           and op.oper_type        = opr_api_const_pkg.OPERATION_TYPE_ATM_SETTLEMENT
           and eo.event_type       = opr_api_const_pkg.EVENT_PROCESSED_SUCCESSFULLY
         order by eo.eff_date;

    cursor cu_event_A19_objects is
        select e.id
             , e.object_id     as oper_id
             , o.status
             , o.oper_date
             , p.split_hash     as oper_split_hash
          from evt_event_object e
             , opr_operation    o
             , opr_participant  p
         where decode(e.status, 'EVST0001', e.procedure_name, null) = 'CST_GPB_PMO_PRC_MAKE_PKG.PROCESS'
           and e.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and e.inst_id          = i_inst_id
           and o.id               = e.object_id
           and p.oper_id          = o.id
           and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
           and o.oper_type        = opr_api_const_pkg.OPERATION_TYPE_ATM_SETTLEMENT
           and e.event_type       = opr_api_const_pkg.EVENT_PROCESSED_SUCCESSFULLY
         order by e.eff_date;

    procedure find_unlink_oper_in_order(
         i_oper_id       in      com_api_type_pkg.t_long_id
    ) is
    begin
        -- Find attached orders in opr_oper_detail
        l_oper_detail_tab :=
            opr_api_detail_pkg.get_oper_detail(
                i_oper_id  => i_oper_id
            );

        for k in 1 .. l_oper_detail_tab.count loop
            pmo_api_order_pkg.set_order_status(
                i_order_id => l_oper_detail_tab(k).object_id
              , i_status   => pmo_api_const_pkg.PMO_STATUS_CANCELED
            );
        end loop;

        -- Unlink ATM-operations in pmo_order_detail
        opr_api_detail_pkg.remove_oper_detail(
            i_oper_id      => i_oper_id
        );
    end find_unlink_oper_in_order;

begin
    trc_log_pkg.debug(i_text => 'starting cst_gpb_pmo_prc_make_pkg.process');

    prc_api_stat_pkg.log_start;

    if i_is_eod = com_api_const_pkg.TRUE then

        l_terminal_type_tab.extend;
        l_terminal_type_tab(l_terminal_type_tab.count) := acq_api_const_pkg.TERMINAL_TYPE_ATM;
        l_terminal_type_tab.extend;
        l_terminal_type_tab(l_terminal_type_tab.count) := acq_api_const_pkg.TERMINAL_TYPE_INFO_KIOSK;

        get_terminal(
            i_terminal_type_tab => l_terminal_type_tab
          , i_inst_id           => i_inst_id
          , o_terminal_tab      => l_terminal_tab
        );

        for i in 1 .. l_terminal_tab.count loop

            -- Check if any AMT operations are present since last A19/EOD. Use current date instead of event_date
            get_operations(
                i_event_date    => l_eff_date
              , i_terminal_id   => l_terminal_tab(i).terminal_id
              , i_split_hash    => l_terminal_tab(i).split_hash
              , o_oper_agg_tab  => l_oper_agg_tab
            );

            if l_oper_agg_tab.count > 0 then

                begin
                    -- Create and process operation A19
                    savepoint sp_create_operation;

                    l_oper_id          := com_api_id_pkg.get_id(opr_operation_seq.nextval, l_eff_date);
                    l_payment_order_id := com_api_id_pkg.get_id(pmo_order_seq.nextval,     l_eff_date);

                    opr_api_create_pkg.add_participant(
                        i_oper_id          => l_oper_id
                      , i_msg_type         => opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                      , i_oper_type        => opr_api_const_pkg.OPERATION_TYPE_ATM_SETTLEMENT
                      , i_participant_type => com_api_const_pkg.PARTICIPANT_ACQUIRER
                      , i_host_date        => l_eff_date
                      , i_terminal_id      => l_terminal_tab(i).terminal_id
                      , i_inst_id          => l_terminal_tab(i).inst_id
                      , i_merchant_number  => l_terminal_tab(i).merchant_number
                    );

                    select count(1)
                      into l_oper_count
                      from opr_participant
                     where oper_id = l_oper_id;

                    if l_oper_count > 0 then
                        opr_api_create_pkg.create_operation(
                            io_oper_id         => l_oper_id
                          , i_status           => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                          , i_sttl_type        => opr_api_const_pkg.SETTLEMENT_INTERNAL
                          , i_msg_type         => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                          , i_oper_type        => opr_api_const_pkg.OPERATION_TYPE_ATM_SETTLEMENT
                          , i_oper_reason      => null
                          , i_oper_amount      => null
                          , i_oper_currency    => null
                          , i_is_reversal      => com_api_const_pkg.FALSE
                          , i_oper_date        => l_eff_date
                          , i_host_date        => l_eff_date
                          , i_payment_order_id => l_payment_order_id
                        );

                        opr_api_process_pkg.process_operation(
                            i_operation_id     => l_oper_id
                        );

                    else
                        com_api_error_pkg.raise_error(
                            i_error            => 'PARTICIPANT_NOT_CREATED'
                          , i_env_param1       => l_oper_id
                          , i_entity_type      => pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
                          , i_object_id        => l_payment_order_id
                        );
                    end if;

                    l_processed_count := l_processed_count + 1;
                exception
                    when com_api_error_pkg.e_application_error then

                        l_excepted_count := l_excepted_count + 1;
                        rollback to sp_create_operation;
                end;
            end if;
        end loop;
    end if;

    -- First iteration
    open cu_event_objects_A19_count;
    fetch cu_event_objects_A19_count into l_estimated_count;
    close cu_event_objects_A19_count;

    if l_estimated_count > 0 then

        open cu_event_A19_objects;
        loop
            fetch cu_event_A19_objects
             bulk collect into
                l_event_object_id_tab
              , l_oper_id_tab
              , l_oper_status_tab
              , l_oper_date_tab
              , l_oper_split_hash_tab
            limit 1000;

            for i in 1 .. l_oper_id_tab.count loop

                if l_oper_status_tab(i) not in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                              , opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES) then

                    find_unlink_oper_in_order(i_oper_id => l_oper_id_tab(i));

                end if;

                -- Find and recreate orders of A19 operations following after current operation in event
                -- and find previous processed A19 operation

                get_operations_with_lag(
                    i_oper_date    => l_oper_date_tab(i)
                  , i_terminal_id  => null
                  , i_split_hash   => l_oper_split_hash_tab(i)
                  , o_oper_agg_tab => l_oper_agg_tab
                );

                for j in 1 .. l_oper_agg_tab.count loop

                    for n in 1 .. l_oper_agg_tab(j).oper_id_tab.count loop

                        find_unlink_oper_in_order(i_oper_id => l_oper_agg_tab(j).oper_id_tab(n));

                    end loop;

                    -- Event EVNT5208 is expected to be subscribed to this process and it should be considered in second iteration
                    evt_api_event_pkg.register_event(
                        i_event_type  => EVENT_TYPE_ENCASH_OPER_RECALC
                      , i_eff_date    => l_eff_date
                      , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id   => l_oper_id_tab(i)
                      , i_inst_id     => i_inst_id
                      , i_split_hash  => l_oper_split_hash_tab(i)
                      , i_param_tab   => l_param_tab
                      , i_status      => null
                    );

                end loop;

                l_event_processed_obj_id_tab(l_event_processed_obj_id_tab.count) := l_event_object_id_tab(i);
            end loop;

            l_processed_count := l_processed_count + 1;

            exit when cu_event_A19_objects%notfound;
        end loop;

        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_event_processed_obj_id_tab
        );

        close cu_event_A19_objects;

        -- Second iteration
        open cu_event_objects;
        loop
            fetch cu_event_objects
             bulk collect into
                l_termial_id_tab
              , l_oper_id_tab
              , l_oper_status_tab
              , l_oper_date_tab
              , l_event_object_id_tab
              , l_oper_split_hash_tab
              , l_customer_id_tab
            limit 1000;

            for i in 1 .. l_oper_id_tab.count loop
                savepoint order_start;

                begin
                    -- Check operation has status = processed, otherwise ignore it.
                    if l_oper_status_tab(i) <> opr_api_const_pkg.OPERATION_STATUS_PROCESSED then
                        continue;
                    end if;

                    select max(id)
                      into l_template_id
                      from pmo_order
                     where object_id = l_termial_id_tab(i)
                       and entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                       and purpose_id = i_purpose_id
                       and is_template = 1;

                    if l_template_id is null then
                        trc_log_pkg.debug(
                            i_text       => 'PMO template was not found for terminal[#1]'
                          , i_env_param1 => l_termial_id_tab(i)
                        );

                        continue;
                    end if;

                    -- Find out required period and get operations this period
                    get_operations_with_lag(
                        i_oper_date    => l_oper_date_tab(i)
                      , i_terminal_id  => l_termial_id_tab(i)
                      , i_split_hash   => l_oper_split_hash_tab(i)
                      , o_oper_agg_tab => l_oper_agg_tab
                    );

                    for n in 1 .. l_oper_agg_tab.count loop

                        if l_oper_agg_tab(n).oper_amount > 0 then
                            l_param_tab.delete;

                            -- Set oper_currency and oper_type in l_param_tab
                            l_param_tab('ORDER_AMOUNT') := l_oper_agg_tab(n).oper_amount;
                            l_param_tab('CURRENCY')     := l_oper_agg_tab(n).oper_currency;

                            l_payment_order_id          := com_api_id_pkg.get_id(pmo_order_seq.nextval, l_eff_date);

                            i_object_tab(i_object_tab.count + 1).entity_type := pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER;
                            i_object_tab(i_object_tab.count    ).object_id   := l_payment_order_id;

                            pmo_api_order_pkg.add_order_detail(
                                i_order_id    => l_payment_order_id
                              , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                              , i_object_id   => l_oper_id_tab(i)
                            );

                            -- Create order for each group
                            pmo_api_order_pkg.add_order_with_params(
                                io_payment_order_id     => l_payment_order_id
                              , i_entity_type           => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                              , i_object_id             => l_termial_id_tab(i)
                              , i_customer_id           => l_customer_id_tab(i)
                              , i_split_hash            => l_oper_split_hash_tab(i)
                              , i_purpose_id            => i_purpose_id
                              , i_template_id           => l_template_id
                              , i_oper_id_tab           => l_oper_id_tab
                              , i_eff_date              => l_eff_date
                              , i_order_status          => pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC
                              , i_inst_id               => i_inst_id
                              , i_attempt_count         => 0
                              , i_payment_order_number  => null
                              , i_expiration_date       => null
                              , i_register_event        => com_api_const_pkg.TRUE
                              , io_param_tab            => l_param_tab
                            );

                        end if;
                    end loop;

                    -- Attach created order to A19-operation in opr_oper_detail
                    opr_api_detail_pkg.set_oper_detail(
                        i_oper_id    => l_oper_id_tab(i)
                      , i_object_tab => i_object_tab
                      , i_date       => l_eff_date
                    );

                exception
                    when others then
                        rollback to savepoint order_start;

                        trc_log_pkg.debug(
                            i_text       => 'Operation [#1] was not processed'
                          , i_env_param1 => l_oper_id_tab(i)
                        );

                        if com_api_error_pkg.is_application_error(sqlcode) <> com_api_const_pkg.TRUE then
                            raise;
                        end if;
                end;

                l_event_processed_obj_id_tab(l_event_processed_obj_id_tab.count) := l_event_object_id_tab(i);
            end loop;

            evt_api_event_pkg.process_event_object (
                i_event_object_id_tab => l_event_processed_obj_id_tab
            );

            exit when cu_event_objects%notfound;
        end loop;

        close cu_event_objects;

    end if;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_processed_count + l_excepted_count
     );

    prc_api_stat_pkg.log_end(
        i_processed_total => l_processed_count
      , i_excepted_total  => l_excepted_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (i_text => 'END cst_gpb_pmo_prc_make_pkg.process' );

exception
    when others then
        prc_api_stat_pkg.log_end(
            i_processed_total   => l_processed_count
          , i_excepted_total    => l_excepted_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end process;

end;
/
