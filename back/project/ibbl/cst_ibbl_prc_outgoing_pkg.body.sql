create or replace package body cst_ibbl_prc_outgoing_pkg as

CRLF                 constant  com_api_type_pkg.t_name := chr(13)||chr(10);

procedure debit_cards_turnovers(
    i_inst_id  in     com_api_type_pkg.t_inst_id
)is
    l_estimate_count    com_api_type_pkg.t_long_id := 0;
    l_container_id      com_api_type_pkg.t_long_id :=  prc_api_session_pkg.get_container_id;
    l_eff_date          date := com_api_sttl_day_pkg.get_sysdate();

    l_event_tab         com_api_type_pkg.t_number_tab;
    l_message_id_tab    num_tab_tpt;

    l_start_date        date;
    l_end_date          date;
    i_date_type         com_api_type_pkg.t_dict_value;
    l_file_type         com_api_type_pkg.t_dict_value;
    l_file              clob;
    l_params            com_api_type_pkg.t_param_tab;
    l_session_file_id   com_api_type_pkg.t_long_id;
begin
    savepoint process_file;

    trc_log_pkg.debug('debit_cards_turnovers Start');

    prc_api_stat_pkg.log_start;

    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    select o.id as event_object_id
         , (select decode(count(1), 0, 0, v.id)
              from net_bin_range r
                 , net_card_type_feature f
             where rpad(v.dst_bin, r.pan_length, '0') between r.pan_low and r.pan_high
               and r.card_type_id = f.card_type_id
               and f.card_feature = net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT) as vss_message_id
      bulk collect into
           l_event_tab
         , l_message_id_tab
      from evt_event_object o
         , evt_event e
         , evt_subscriber s
         , vis_vss2 v
     where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_IBBL_PRC_OUTGOING_PKG.DEBIT_CARDS_TURNOVERS'
       and o.eff_date      <= l_eff_date
       and e.id             = o.event_id
       and e.event_type     = s.event_type
       and o.procedure_name = s.procedure_name
       and o.entity_type    = vis_api_const_pkg.ENTITY_TYPE_VSS_MESSAGE
       and o.object_id      = v.id
       and (v.inst_id       = i_inst_id or i_inst_id is null)
  order by v.id
 ;
    l_estimate_count := l_event_tab.count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimate_count
    );
    
    if nvl(l_estimate_count, 0) = 0 then
        trc_log_pkg.debug('debit_cards_turnovers: estimated_count = ['||l_estimate_count||'], file creatiom skipped') ;
    else
        select
            xmlelement("accounts", xmlattributes('http://sv.bpc.in/SVXP' as "xmlns"),
                xmlelement("file_type",    l_file_type),
                xmlelement("date_purpose", i_date_type),
                xmlelement("start_date",   to_char(l_start_date, 'yyyy-mm-dd')),
                xmlelement("end_date",     to_char(l_end_date, 'yyyy-mm-dd')),
                xmlelement("inst_id",      i_inst_id),
                xmlagg(xmlelement("account", xmlattributes(g.account_id as "id"),
                    xmlelement("account_number", g.account_number),
                    xmlelement("currency", min(currency)),
                    xmlelement("account_type", min(g.account_type)),
                    xmlelement("account_status", min(g.status)),
                    xmlelement("aval_balance", min(g.aval_balance))
                    ,xmlagg(
                        xmlelement(
                            "balance", xmlattributes(g.balance_id as "id"),
                        xmlelement("balance_type", g.balance_type),
                        xmlelement("turnover",
                            xmlelement("incoming_balance", g.incoming_balance),
                            xmlelement("debits_amount", g.debits_amount),
                            xmlelement("debits_count", g.debits_count),
                            xmlelement("credits_amount", g.credits_amount),
                            xmlelement("credits_count", g.credits_count),
                            xmlelement("outgoing_balance", g.outgoing_balance)
                        )
                      )
                   ) --*/
                )
              )
            ).getclobval()
         into l_file
        from (
            select null account_id
                 , v.sttl_currency as currency
                 , null account_type
                 , null status
                 , null account_number
                 , null balance_type
                 , null balance_id
                 , sum(v.debit_amount) as debits_amount
                 , sum(v.credit_amount) as credits_amount
                 , sum(v.trans_count) as debits_count
                 , sum(v.trans_count) as credits_count
                 , null incoming_balance
                 , null outgoing_balance
                 , null aval_balance
            from vis_vss2 v
            where v.id in (select column_value from table(cast(l_message_id_tab as num_tab_tpt)) where column_value != 0)
            group by v.sttl_currency
        ) g
        group by g.account_number;

        rul_api_param_pkg.set_param(
            i_name          => 'START_DATE'
          , i_value         => l_start_date
          , io_params       => l_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'END_DATE'
          , i_value         => l_end_date
          , io_params       => l_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'INST_ID'
          , i_value         => i_inst_id
          , io_params       => l_params
        );
        
        prc_api_file_pkg.open_file(
            o_sess_file_id => l_session_file_id
          , i_file_type    => l_file_type
          , i_file_purpose => prc_api_const_pkg.FILE_PURPOSE_OUT
          , io_params      => l_params
        );

        l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

        prc_api_file_pkg.put_file(
            i_sess_file_id  => l_session_file_id
          , i_clob_content  => l_file
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
        trc_log_pkg.debug('file saved, cnt = ' || l_estimate_count || ', length = ' || length(l_file));
    end if;

    evt_api_event_pkg.process_event_object(
        i_event_object_id_tab    => l_event_tab
    );

    prc_api_stat_pkg.log_end(
        i_processed_total  => l_estimate_count
      , i_excepted_total   => 0
      , i_rejected_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        rollback to process_file;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end debit_cards_turnovers;

function get_multiplier(
    i_curr_code                in            com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_money
result_cache relies_on (com_currency)
is
begin
    return
        case
            when i_curr_code is null
            then 1
            else power(10, com_api_currency_pkg.get_currency_exponent(i_curr_code => i_curr_code))
        end;
end get_multiplier;

procedure create_operations_from_vss_msg(
    i_inst_id                     in     com_api_type_pkg.t_inst_id
  , i_create_operation            in     com_api_type_pkg.t_boolean
  , i_visa_vss_amnt_type_array_id in     com_api_type_pkg.t_short_id
) is
    l_record_count     com_api_type_pkg.t_long_id;
    l_eff_date         date  := com_api_sttl_day_pkg.get_sysdate();
    l_session_file_id  com_api_type_pkg.t_long_id;
    l_oper_id          com_api_type_pkg.t_long_id;
    l_excepted_tab     num_tab_tpt := new num_tab_tpt();
    l_skipped_tab      num_tab_tpt := new num_tab_tpt();
    l_oper_reason      com_api_type_pkg.t_dict_value;
    l_rate             com_api_type_pkg.t_rate;
    l_net_commission   com_api_type_pkg.t_money;
begin
    savepoint process_file;

    trc_log_pkg.debug('create_operations_from_vss_msg Start');

    prc_api_stat_pkg.log_start;

    select cast(collect(cast(o.id as number)) as num_tab_tpt) skipped_evnt_obj_id_tab
      into l_skipped_tab
      from evt_event_object o
         , evt_event e
         , evt_subscriber s
         , vis_vss2 v
     where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_IBBL_PRC_OUTGOING_PKG.CREATE_OPERATIONS_FROM_VSS_MSG'
       and o.eff_date      <= l_eff_date
       and e.id             = o.event_id
       and e.event_type     = s.event_type
       and o.procedure_name = s.procedure_name
       and o.entity_type    = vis_api_const_pkg.ENTITY_TYPE_VSS_MESSAGE
       and o.object_id      = v.id
       and (v.inst_id       = i_inst_id or i_inst_id is null)
       and (NOT (nvl(v.bus_mode,' ') = '9'
             and
                nvl(v.amount_type,' ') in ( select substr(ae.element_value, -1)
                                              from com_array_element ae
                                             where ae.array_id = i_visa_vss_amnt_type_array_id)
           )
           );

    if nvl(l_skipped_tab.count, 0) > 0 then
           evt_api_event_pkg.change_event_object_status(
            i_event_object_id_tab => l_skipped_tab
          , i_event_object_status => evt_api_const_pkg.EVENT_STATUS_DO_NOT_PROCES
        );
    end if;
  
    for rec in (
        select cast(collect(cast(v.event_object_id as number)) as num_tab_tpt) event_object_id_tab
             , cast(collect(cast(v.vis_vss2_id as number)) as num_tab_tpt) vis_vss2_id_tab
             , v.inst_id
             , v.sttl_date
             , sum(v.trans_count) trans_count
             , v.src_bin
             , v.dst_bin
             , sum(v.net_amount) net_amount
             , v.sttl_currency
             , v.file_id
             , sum(case when amount_type = 'F' and (src_country  = '050'  or dst_country = '050') then net_amount else 0 end) as f9_dom
             , sum(case when amount_type = 'F' and (src_country != '050' and dst_country!= '050') then net_amount else 0 end) as f9_intl
             , sum(case when amount_type = 'C' and (src_country  = '050'  or dst_country = '050') then net_amount else 0 end) as c9_dom
             , sum(case when amount_type = 'C' and (src_country != '050' and dst_country!= '050') then net_amount else 0 end) as c9_intl
             , sum(case when amount_type = 'I' and (src_country != '050' and dst_country!= '050') then net_amount else 0 end) as i9_intl
             , row_number() over(order by v.src_bin
                                        , v.dst_bin
                                        , v.sttl_currency
                                        , v.file_id
                                        , v.inst_id
                                        , v.sttl_date
                                        , sign(v.net_amount)) rn
             , min(cnt) cnt
          from (select o.id as event_object_id
                     , v.id as vis_vss2_id
                     , v.amount_type
                     , v.sttl_currency
                     , v.file_id
                     , v.inst_id
                     , v.net_amount / cst_ibbl_prc_outgoing_pkg.get_multiplier(i_curr_code => v.sttl_currency) as net_amount
                     , v.src_bin
                     , v.dst_bin
                     , v.trans_count
                     , v.sttl_date
                     , (select nvl(min(b.country),' ') from net_bin_range b 
                         where rpad(v.dst_bin, b.pan_length, '0') between b.pan_low and b.pan_high
                       ) as src_country
                     , (select nvl(min(b.country),' ') from net_bin_range b 
                         where rpad(v.dst_bin, b.pan_length, '0') between b.pan_low and b.pan_high
                       ) as dst_country
                     , count(o.id) over() cnt
                  from evt_event_object o
                     , evt_event e
                     , evt_subscriber s
                     , vis_vss2 v
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_IBBL_PRC_OUTGOING_PKG.CREATE_OPERATIONS_FROM_VSS_MSG'
                   and o.eff_date      <= l_eff_date
                   and e.id             = o.event_id
                   and e.event_type     = s.event_type
                   and o.procedure_name = s.procedure_name
                   and o.entity_type    = vis_api_const_pkg.ENTITY_TYPE_VSS_MESSAGE
                   and o.object_id      = v.id
                   and (v.inst_id       = i_inst_id or i_inst_id is null)
                   and v.bus_mode       = '9'
                   and v.amount_type in ( select substr(ae.element_value, -1) 
                                            from com_array_element ae
                                           where ae.array_id      = i_visa_vss_amnt_type_array_id)
             ) v                 
      group by v.src_bin
             , v.dst_bin
             , v.sttl_currency
             , v.file_id
             , v.inst_id
             , v.sttl_date
             , sign(v.net_amount)
     ) loop
        if rec.rn = 1 then
            l_record_count := nvl(l_skipped_tab.count, 0) + rec.cnt;
            prc_api_stat_pkg.log_estimation(i_estimated_count => l_record_count  );
        end if;

        if nvl(rec.net_amount ,0) = 0 then
          
            l_excepted_tab := l_excepted_tab MULTISET UNION rec.event_object_id_tab; 
            for i in rec.event_object_id_tab.first.. rec.event_object_id_tab.last loop
                trc_log_pkg.debug('operation not created, because net_amount = 0, event_object_id = '||rec.event_object_id_tab(i));
            end loop;
            
        else

            begin
                if nvl(i_create_operation, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
                    
                    l_rate := com_api_rate_pkg.get_rate(
                        i_src_currency    => rec.sttl_currency
                      , i_dst_currency    => '050' -- BDT
                      , i_rate_type       => com_api_const_pkg.CUST_RATE_TYPE
                      , i_inst_id         => i_inst_id
                      , i_conversion_type => null
                      , i_eff_date        => rec.sttl_date
                      , i_mask_exception  => com_api_const_pkg.FALSE
                    );

   -- due to bank requirements, there are one formula for all bin ranges implemented
   -- NET commission =  F9(INTL)* BDT Conversion Rate + F9(DOM) - C9(INTL)*BDT Conversion Rate - C9(DOM) Р Р†Р вЂљРІР‚Сљ (13.04%*F9(DOM+INTL))
                
                   if rec.dst_bin in ('498773','402404') then
                    -- VISA Debit Card
                        l_net_commission := rec.f9_intl * l_rate + rec.f9_dom - rec.c9_intl*l_rate - rec.c9_dom -(.1304 * (rec.f9_dom + rec.f9_intl * l_rate));
                    elsif rec.dst_bin in ('498770', '498771', '498772') then
                    -- Comm_Khidmah Credit Card Trans
                        l_net_commission := rec.f9_intl * l_rate + rec.f9_dom - rec.c9_intl*l_rate - rec.c9_dom -(.1304 * (rec.f9_dom + rec.f9_intl * l_rate));
                    elsif rec.dst_bin in ('423363') then
                    -- Hajj Card Trans
                        l_net_commission := rec.f9_intl * l_rate + rec.f9_dom - rec.c9_intl*l_rate - rec.c9_dom -(.1304 * (rec.f9_dom + rec.f9_intl * l_rate));
                    elsif rec.dst_bin in ( '423363') then
                    -- Travel Card Trans
                        l_net_commission := rec.f9_intl * l_rate + rec.f9_dom - rec.c9_intl*l_rate - rec.c9_dom -(.1304 * (rec.f9_dom + rec.f9_intl * l_rate));
                    elsif rec.dst_bin = '468759' then
                    -- Payroll/Salary Card Trans
                        l_net_commission := rec.f9_intl * l_rate + rec.f9_dom - rec.c9_intl*l_rate - rec.c9_dom -(.1304 * (rec.f9_dom + rec.f9_intl * l_rate));
                    else
                        com_api_error_pkg.raise_error(
                            i_error        => 'BIN_IS_NOT_FOUND'
                          , i_env_param1   => rec.dst_bin
                          , i_entity_type  => vis_api_const_pkg.ENTITY_TYPE_VSS_MESSAGE
                          , i_object_id    => rec.vis_vss2_id_tab(1)
                        );
                    end if;

                    l_oper_id := opr_api_create_pkg.get_id(i_host_date => rec.sttl_date );

                    l_oper_reason := case sign(rec.net_amount)
                                     when -1 then opr_api_const_pkg.OPER_REASON_VSS_FEE_NEGATIVE
                                     else         opr_api_const_pkg.OPER_REASON_VSS_FEE_POSITIVE
                                     end;

                    insert into cst_ibbl_gl_routing_formular(
                        operation_id
                      , sttl_date
                      , src_bin
                      , dst_bin
                      , f9_intl
                      , f9_dom
                      , c9_intl
                      , c9_dom
                      , i9_intl
                      , bdt_conv_rate
                      , sttl_currency
                      , net_commission
                    ) values (
                        l_oper_id
                      , rec.sttl_date
                      , rec.src_bin
                      , rec.dst_bin
                      , rec.f9_intl
                      , rec.f9_dom
                      , rec.c9_intl
                      , rec.c9_dom
                      , rec.i9_intl
                      , l_rate --null --bdt_conv_rate
                      , rec.sttl_currency
                      , l_net_commission
                    );
                    
                    opr_api_create_pkg.create_operation(
                        io_oper_id                 => l_oper_id
                      , i_session_id               => get_session_id
                      , i_is_reversal              => com_api_const_pkg.FALSE
                      , i_oper_type                => opr_api_const_pkg.OPERATION_TYPE_INSTITUTION_FEE
                      , i_oper_reason              => l_oper_reason
                      , i_msg_type                 => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                      , i_status                   => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                      , i_sttl_type                => opr_api_const_pkg.SETTLEMENT_INTERNAL
                      , i_acq_inst_bin             => rec.src_bin
                      , i_forw_inst_bin            => rec.dst_bin
                      , i_oper_count               => rec.trans_count
                      , i_oper_amount              => abs(rec.net_amount)
                      , i_oper_currency            => rec.sttl_currency
                      , i_oper_date                => rec.sttl_date
                      , i_host_date                => rec.sttl_date
                      , i_sttl_currency            => rec.sttl_currency
                      , i_forced_processing        => com_api_const_pkg.FALSE
                      , i_incom_sess_file_id       => rec.file_id
                      , i_fee_amount               => l_net_commission
                      , i_fee_currency             => '050'
                      , i_sttl_date                => rec.sttl_date
                    );

                    opr_api_create_pkg.add_participant(
                        i_oper_id             => l_oper_id
                      , i_msg_type            => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                      , i_oper_type           => opr_api_const_pkg.OPERATION_TYPE_INSTITUTION_FEE
                      , i_oper_reason         => l_oper_reason
                      , i_participant_type    => com_api_const_pkg.PARTICIPANT_INSTITUTION
                      , i_host_date           => rec.sttl_date
                      , i_inst_id             => rec.inst_id
                      , i_card_inst_id        => rec.inst_id
                      , i_card_type_id        => null --rec.card_type_id
                      , i_account_amount      => abs(rec.net_amount)
                      , i_account_currency    => rec.sttl_currency
                      , i_without_checks      => com_api_const_pkg.TRUE
                      , i_oper_currency       => rec.sttl_currency
                      , i_mask_error          => com_api_const_pkg.FALSE
                      , i_is_reversal         => com_api_const_pkg.FALSE
                    );
                    
                    forall q in indices of rec.vis_vss2_id_tab
                        update vis_vss2 
                           set operation_id = l_oper_id 
                         where id           = rec.vis_vss2_id_tab(q);
                end if;
            
                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab    => rec.event_object_id_tab
                );
            exception
                when com_api_error_pkg.e_application_error then
                    if com_api_error_pkg.get_last_error = 'CURRENCY_RATE_NOT_FOUND' then
                        raise;
                    else
                       trc_log_pkg.debug(sqlerrm);
                    end if;
                       
                    l_excepted_tab := l_excepted_tab MULTISET UNION rec.event_object_id_tab;
            end;
        end if;
    end loop;

    if nvl(l_excepted_tab.count, 0) > 0 then
        evt_api_event_pkg.change_event_object_status(
            i_event_object_id_tab => l_excepted_tab
          , i_event_object_status => evt_api_const_pkg.EVENT_STATUS_DO_NOT_PROCES
        );
    end if;

    if l_record_count is null then
        prc_api_stat_pkg.log_estimation(
            i_estimated_count => 0
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total  => nvl(l_record_count, 0) - nvl(l_excepted_tab.count, 0) - nvl(l_skipped_tab.count, 0)
      , i_excepted_total   => nvl(l_excepted_tab.count, 0) + nvl(l_skipped_tab.count, 0)
      , i_rejected_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        rollback to process_file;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end create_operations_from_vss_msg;

end cst_ibbl_prc_outgoing_pkg;
/
