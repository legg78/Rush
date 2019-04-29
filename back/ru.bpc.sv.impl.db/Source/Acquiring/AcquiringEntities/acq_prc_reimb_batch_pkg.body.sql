create or replace package body acq_prc_reimb_batch_pkg as

function get_reimb_date(
    i_merchant_id       in      com_api_type_pkg.t_short_id
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_oper_date         in      date
  , i_posting_date      in      date
) return date is

    l_cycle_id          com_api_type_pkg.t_short_id;
    l_params            com_api_type_pkg.t_param_tab;
begin

    l_cycle_id :=
        prd_api_product_pkg.get_cycle_id (
            i_product_id      => prd_api_product_pkg.get_product_id(
                                     i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                   , i_object_id     => i_merchant_id
                                 )
          , i_entity_type     => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
          , i_object_id       => i_merchant_id
          , i_cycle_type      => 'CYTP0200'
          , i_params          => l_params
          , i_eff_date        => i_posting_date
        );

    return
        fcl_api_cycle_pkg.calc_next_date(
            i_cycle_id          => l_cycle_id
          , i_start_date        => i_posting_date
        );
end;

function get_cheque_number(
    i_batch_id          in      com_api_type_pkg.t_medium_id
  , i_reimb_date        in      date
) return com_api_type_pkg.t_name is
begin
    return to_char(i_batch_id);
end;

procedure process(
    i_inst_id           in      com_api_type_pkg.t_inst_id
) is
    l_batch_id              com_api_type_pkg.t_medium_id;
    l_cheque_number         com_api_type_pkg.t_name;
    l_reimb_date            date;
    l_eff_date              date;

    l_oper_id_tab           com_api_type_pkg.t_number_tab;
    l_batch_id_tab          com_api_type_pkg.t_number_tab;
    l_channel_id_tab        com_api_type_pkg.t_number_tab;
    l_oper_date_tab         com_api_type_pkg.t_date_tab;
    l_posting_date_tab      com_api_type_pkg.t_date_tab;
    l_sttl_day_tab          com_api_type_pkg.t_tiny_tab;
    l_reimb_date_tab        com_api_type_pkg.t_date_tab;
    l_merchant_id_tab       com_api_type_pkg.t_number_tab;
    l_account_id_tab        com_api_type_pkg.t_number_tab;
    l_card_number_tab       com_api_type_pkg.t_card_number_tab;
    l_auth_code_tab         com_api_type_pkg.t_name_tab;
    l_rrn_tab               com_api_type_pkg.t_rrn_tab;
    l_cheque_number_tab     com_api_type_pkg.t_name_tab;
    l_gross_amount_tab      com_api_type_pkg.t_number_tab;
    l_service_charge_tab    com_api_type_pkg.t_number_tab;
    l_tax_amount_tab        com_api_type_pkg.t_number_tab;
    l_net_amount_tab        com_api_type_pkg.t_number_tab;
    l_oper_count_tab        com_api_type_pkg.t_number_tab;
    l_inst_id_tab           com_api_type_pkg.t_inst_id_tab;
    l_split_hash_tab        com_api_type_pkg.t_tiny_tab;

    l_event_object_id       com_api_type_pkg.t_number_tab;

    l_record_count          pls_integer := 0;

    cursor cu_reimb_oper is
        select decode(grouping(d.object_id), 1, null, d.object_id) operation_id
             , c.channel_id
--             , min(null) pos_batch_id
             , min(trunc(g.oper_date)) oper_date
             , trunc(d.posting_date) posting_date
             , b.sttl_day
             , p2.merchant_id
             , b.account_id
             , sum(decode(f.amount_type, acq_api_const_pkg.REIMB_AMOUNT_TYPE_GROSS , e.amount, 0)) gross_amount
             , sum(decode(f.amount_type, acq_api_const_pkg.REIMB_AMOUNT_TYPE_CHARGE, e.amount, 0)) service_charge
             , sum(decode(f.amount_type, acq_api_const_pkg.REIMB_AMOUNT_TYPE_TAX   , e.amount, 0)) tax_amount
             , sum(decode(f.amount_type, acq_api_const_pkg.REIMB_AMOUNT_TYPE_NET   , e.amount, 0)) net_amount
             , count(distinct d.object_id) oper_count
             , a.inst_id
             , b.split_hash
             , iss_api_token_pkg.decode_card_number(i_card_number => h.card_number) as card_number
             , p.auth_code
             , g.originator_refnum
          from evt_event_object      a
             , acc_entry             b
             , acq_reimb_account     c
             , acc_macros            d
             , acc_macros            e
             , acq_reimb_macros_type f
             , opr_operation         g
             , opr_card              h
             , opr_participant       p
             , opr_participant       p2
         where decode(a.status, 'EVST0001', a.procedure_name, null) = 'ACQ_PRC_REIMB_BATCH_PKG.PROCESS'
           and (a.inst_id        = i_inst_id or i_inst_id is null)
           and a.eff_date       <= l_eff_date
           and a.object_id       = b.id
           and (
                a.split_hash      in (select split_hash from com_split_map where thread_number = get_thread_number)
                or
                get_thread_number = -1
               )
           and b.balance_impact  = com_api_type_pkg.CREDIT
           and b.account_id      = c.account_id
           and b.macros_id       = d.id
           and d.object_id       = e.object_id
           and d.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and e.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and e.macros_type_id  = f.macros_type_id
           and d.object_id       = g.id
           and g.id              = h.oper_id
           and p.oper_id         = g.id
           and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and p2.oper_id         = g.id
           and p2.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
         group by rollup(d.object_id)
                , c.channel_id
                , trunc(d.posting_date)
                , b.sttl_day
                , p2.merchant_id
                , b.account_id
                , a.inst_id
                , b.split_hash
                , h.card_number
                , p.auth_code
                , g.originator_refnum;

    cursor cu_entries_count is
        select count(1)
          from evt_event_object      a
             , acc_entry             b
             , acq_reimb_account     c
         where decode(a.status, 'EVST0001', a.procedure_name, null) = 'ACQ_PRC_REIMB_BATCH_PKG.PROCESS'
           and (a.inst_id        = i_inst_id or i_inst_id is null)
           and a.eff_date       <= l_eff_date
           and a.object_id       = b.id
           and (
                a.split_hash      in (select split_hash from com_split_map where thread_number = get_thread_number)
                or
                get_thread_number = -1
               )
           and b.balance_impact  = com_api_type_pkg.CREDIT
           and b.account_id      = c.account_id;

    cursor cu_events_to_delete is
        select a.id               event_object_id
          from evt_event_object a
         where decode(a.status, 'EVST0001', a.procedure_name, null) = 'ACQ_PRC_REIMB_BATCH_PKG.PROCESS'
           and (a.inst_id        = i_inst_id or i_inst_id is null)
           and a.eff_date       <= l_eff_date
           and (
                a.split_hash      in (select split_hash from com_split_map where thread_number = get_thread_number)
                or
                get_thread_number = -1
               );

begin

    l_eff_date := com_api_sttl_day_pkg.get_sysdate;

    prc_api_stat_pkg.log_start;

    open cu_entries_count;
    fetch cu_entries_count into l_record_count;
    close cu_entries_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count
    );

    l_batch_id := com_api_id_pkg.get_id(acq_reimb_batch_seq.nextval, com_api_sttl_day_pkg.get_sysdate);

    open cu_reimb_oper;
    loop
        fetch cu_reimb_oper bulk collect into
            l_oper_id_tab
          , l_channel_id_tab
          , l_oper_date_tab
          , l_posting_date_tab
          , l_sttl_day_tab
          , l_merchant_id_tab
          , l_account_id_tab
          , l_gross_amount_tab
          , l_service_charge_tab
          , l_tax_amount_tab
          , l_net_amount_tab
          , l_oper_count_tab
          , l_inst_id_tab
          , l_split_hash_tab
          , l_card_number_tab
          , l_auth_code_tab
          , l_rrn_tab
        limit 1000;

        for i in 1..l_oper_id_tab.count loop
            if l_reimb_date is null then
                l_reimb_date :=
                    get_reimb_date(
                        i_merchant_id       => l_merchant_id_tab(i)
                      , i_account_id        => l_account_id_tab(i)
                      , i_oper_date         => l_oper_date_tab(i)
                      , i_posting_date      => l_posting_date_tab(i)
                    );
            end if;

            if l_cheque_number is null then
                l_cheque_number :=
                    get_cheque_number(
                        i_batch_id          => l_batch_id
                      , i_reimb_date        => l_reimb_date
                    );
            end if;

            l_reimb_date_tab(i)     := l_reimb_date;
            l_cheque_number_tab(i)  := l_cheque_number;
            l_batch_id_tab(i)       := l_batch_id;
            l_record_count := l_record_count + 1;


            -- batch row - get next id and flush date for new calculation
            if l_oper_id_tab(i) is null then
                l_batch_id := com_api_id_pkg.get_id(acq_reimb_batch_seq.nextval, com_api_sttl_day_pkg.get_sysdate);
                l_reimb_date    := null;
                l_cheque_number := null;
            end if;

        end loop;

        forall i in 1..l_oper_id_tab.count
            insert
                when l_oper_id_tab(i) is null then
                    into acq_reimb_batch (
                        id
                      , channel_id
                      , oper_date
                      , posting_date
                      , sttl_day
                      , reimb_date
                      , merchant_id
                      , account_id
                      , cheque_number
                      , status
                      , gross_amount
                      , service_charge
                      , tax_amount
                      , net_amount
                      , oper_count
                      , inst_id
                      , split_hash
                      , session_file_id
                      , seqnum
                    ) values (
                        l_batch_id_tab(i)
                      , l_channel_id_tab(i)
                      , l_oper_date_tab(i)
                      , l_posting_date_tab(i)
                      , l_sttl_day_tab(i)
                      , l_reimb_date_tab(i)
                      , l_merchant_id_tab(i)
                      , l_account_id_tab(i)
                      , l_cheque_number_tab(i)
                      , acq_api_const_pkg.REIMB_BATCH_STATUS_AWATING
                      , l_gross_amount_tab(i)
                      , l_service_charge_tab(i)
                      , l_tax_amount_tab(i)
                      , l_net_amount_tab(i)
                      , l_oper_count_tab(i)
                      , l_inst_id_tab(i)
                      , l_split_hash_tab(i)
                      , null
                      , 1
                    )
                when l_oper_id_tab(i) is not null then
                    into acq_reimb_oper (
                        id
                      , batch_id
                      , channel_id
                      , oper_date
                      , posting_date
                      , sttl_day
                      , reimb_date
                      , merchant_id
                      , account_id
                      , card_number
                      , auth_code
                      , refnum
                      , gross_amount
                      , service_charge
                      , tax_amount
                      , net_amount
                      , inst_id
                      , split_hash
                    ) values (
                        l_oper_id_tab(i)
                      , l_batch_id_tab(i)
                      , l_channel_id_tab(i)
                      , l_oper_date_tab(i)
                      , l_posting_date_tab(i)
                      , l_sttl_day_tab(i)
                      , l_reimb_date_tab(i)
                      , l_merchant_id_tab(i)
                      , l_account_id_tab(i)
                      , iss_api_token_pkg.encode_card_number(i_card_number => l_card_number_tab(i))
                      , l_auth_code_tab(i)
                      , l_rrn_tab(i)
                      , l_gross_amount_tab(i)
                      , l_service_charge_tab(i)
                      , l_tax_amount_tab(i)
                      , l_net_amount_tab(i)
                      , l_inst_id_tab(i)
                      , l_split_hash_tab(i)
                    )
                   select 1 from dual;

        prc_api_stat_pkg.log_current (
            i_current_count       => l_record_count
          , i_excepted_count      => 0
        );

        exit when cu_reimb_oper%notfound;
    end loop;

    close cu_reimb_oper;

    open cu_events_to_delete;
    loop
        fetch cu_events_to_delete bulk collect into
            l_event_object_id
        limit 1000;

        forall i in 1..l_event_object_id.count
            delete from evt_event_object where id = l_event_object_id(i);

        exit when cu_events_to_delete%notfound;
    end loop;
    close cu_events_to_delete;

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        if cu_reimb_oper%isopen then
            close cu_reimb_oper;
        end if;

        if cu_events_to_delete%isopen then
            close cu_events_to_delete;
        end if;

        if cu_entries_count%isopen then
            close cu_entries_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;
end;

end;
/
