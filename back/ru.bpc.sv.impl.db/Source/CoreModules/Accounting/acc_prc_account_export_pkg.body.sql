create or replace package body acc_prc_account_export_pkg is
/*********************************************************
 *  process for accounts export to XML file <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 25.05.2012 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate:                      $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: ACC_PRC_ACCOUNT_EXPORT_PKG  <br />
 *  @headcom
 **********************************************************/

CRLF                           constant  com_api_type_pkg.t_name := chr(13)||chr(10);

type t_entry_rec is record (
    event_object_id            com_api_type_pkg.t_long_id
  , transaction_id             com_api_type_pkg.t_long_id
  , transaction_type           com_api_type_pkg.t_dict_value
  , posting_date               date
  , amount_purpose             com_api_type_pkg.t_dict_value
  , conversion_rate            com_api_type_pkg.t_rate
  , rate_type                  com_api_type_pkg.t_dict_value
  , balance_impact             com_api_type_pkg.t_boolean
  , entry_id                   com_api_type_pkg.t_long_id
  , sttl_date                  date
  , posting_order              com_api_type_pkg.t_short_id
  , sttl_day                   com_api_type_pkg.t_short_id
  , account_id                 com_api_type_pkg.t_medium_id
  , amount_value               com_api_type_pkg.t_money
  , entry_currency             com_api_type_pkg.t_dict_value
  , inst_id                    com_api_type_pkg.t_inst_id
  , is_settled                 com_api_type_pkg.t_boolean
  , entry_status               com_api_type_pkg.t_dict_value
  , balance_type               com_api_type_pkg.t_dict_value
);

type t_entry_list_tab          is table of t_entry_rec index by pls_integer;
type t_entry_tab               is table of t_entry_rec index by varchar2(40);
type t_entry_by_oper_tab       is table of t_entry_tab index by varchar2(40);

g_entry_by_oper_tab            t_entry_by_oper_tab;
g_event_object_id_tab          num_tab_tpt          := num_tab_tpt();

g_inst_flag_tab                com_api_type_pkg.t_boolean_tab;

procedure remain_active_inst_param(
    io_inst_flag_tab   in out nocopy com_api_type_pkg.t_boolean_tab
) is
    l_inst_id             com_api_type_pkg.t_inst_id;
begin
    if io_inst_flag_tab.count > 0 then
        l_inst_id := io_inst_flag_tab.first;
        while l_inst_id is not null
        loop
            if nvl(io_inst_flag_tab(l_inst_id), com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                io_inst_flag_tab.delete(l_inst_id);
            end if;
            l_inst_id := io_inst_flag_tab.next(l_inst_id);
        end loop;
    end if;
end remain_active_inst_param;

function check_inst_id(i_inst_id  in com_api_type_pkg.t_inst_id)
return com_api_type_pkg.t_boolean
is
begin
    return case
               when g_inst_flag_tab.exists(i_inst_id)
                and g_inst_flag_tab(i_inst_id) = com_api_const_pkg.TRUE
               then com_api_const_pkg.TRUE
               else com_api_const_pkg.FALSE
            end;
end check_inst_id;

procedure process(
    i_inst_id      in  com_api_type_pkg.t_inst_id
) is
    l_sysdate          date := com_api_sttl_day_pkg.get_sysdate;
    l_sess_file_id     com_api_type_pkg.t_long_id;
    l_file             clob;
    l_estimated_count  pls_integer := 0;
    l_processed_count  pls_integer := 0;
    l_balance_id_tab   num_tab_tpt;
    l_event_tab        com_api_type_pkg.t_number_tab;
    l_params           com_api_type_pkg.t_param_tab;

    cursor cu_event_objects(i_current_inst_id in    com_api_type_pkg.t_inst_id) is
        select b.id as balance_id
             , o.id as event_object_id
          from evt_event_object o
             , evt_event e
             , evt_subscriber s
             , acc_balance b
             , acc_account a
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ACC_PRC_ACCOUNT_EXPORT_PKG.PROCESS'
           and o.eff_date      <= l_sysdate
           and e.id             = o.event_id
           and e.event_type     = s.event_type
           and o.procedure_name = s.procedure_name
           and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_BALANCE
           and o.object_id      = b.id
           and (b.inst_id       = i_current_inst_id)
           and b.account_id     = a.id
           and b.balance_type   = acc_api_const_pkg.BALANCE_TYPE_LEDGER
           and a.account_type   in (select element_value from com_array_element el where el.array_id = 14)
      order by b.id;

    cursor main_xml_cur(i_current_inst_id in     com_api_type_pkg.t_inst_id) is
             select xmlelement("accounts", xmlattributes('http://sv.bpc.in/SVXP' as "xmlns")
                  , xmlelement("file_id",   to_char(l_sess_file_id,'TM9') )
                  , xmlelement("file_type", 'FLTPACCT' )
                  , xmlelement("file_date", to_char(l_sysdate, 'yyyy-mm-dd') )
                  , xmlelement("date_purpose", 'DTPR0001' )
                  , xmlelement("inst_id",      i_current_inst_id)
                  ,     xmlagg(                    
                            xmlelement("account"
                            ,  xmlattributes(to_char(a.id, 'TM9') as "id")
                            ,  xmlelement("account_number", nvl(b.balance_number, a.account_number))
                            ,  xmlelement("currency",       a.currency      )
                            ,  xmlelement("account_type",   a.account_type  )
                            ,  xmlelement("account_status", a.status        )
                            ,  xmlelement("customer"
                                 , xmlattributes(to_char(c.id, 'TM9') as "id")
                                 , xmlelement("customer_number", c.customer_number)
                               )
                            ,  xmlelement("balance"
                                 , xmlattributes(to_char(b.id, 'TM9') as "id")
                                 , xmlelement("balance_type",       b.balance_type)
                                 , (select xmlelement("balance_open_date",  b.open_date) from dual where b.open_date is not null)
                                 , (select xmlelement("balance_close_date", b.close_date) from dual where b.close_date is not null)
                               )
                            )
                        )
                    ).getclobval() as acc_data
              from acc_account a
                 , prd_customer c
                 , acc_balance b
             where b.id           in (select column_value from table(cast(l_balance_id_tab as num_tab_tpt)))
               and a.customer_id  = c.id
               and b.account_id   = a.id
               and b.balance_type = 'BLTP0001' 
               and a.account_type in (select element_value from com_array_element e where e.array_id = 14);

    procedure save_file is
    begin
        l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

        prc_api_file_pkg.put_file(
            i_sess_file_id  => l_sess_file_id
          , i_clob_content  => l_file
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_sess_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count  => l_balance_id_tab.count 
        );
                    
        trc_log_pkg.debug('file saved, cnt='||l_balance_id_tab.count||', length='||length(l_file));

        prc_api_stat_pkg.log_current (
            i_current_count     => l_balance_id_tab.count
            , i_excepted_count  => 0
        );
    end;
begin
    trc_log_pkg.debug('Start documents export: sysdate=['||l_sysdate||
                      '] thread_number=['||get_thread_number||'] inst=['||i_inst_id||']');

    prc_api_stat_pkg.log_start;

    savepoint sp_accounts_export;
    
    select count(1)
      into l_estimated_count
      from evt_event_object o
         , evt_event e
         , evt_subscriber s
         , acc_balance b
         , acc_account a
     where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ACC_PRC_ACCOUNT_EXPORT_PKG.PROCESS'
       and o.eff_date      <= l_sysdate
       and e.id             = o.event_id
       and e.event_type     = s.event_type
       and o.procedure_name = s.procedure_name
       and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_BALANCE
       and o.object_id      = b.id
       and (a.inst_id = i_inst_id
         or i_inst_id = ost_api_const_pkg.DEFAULT_INST
         or i_inst_id is null)
       and b.account_id     = a.id
       and b.balance_type   = acc_api_const_pkg.BALANCE_TYPE_LEDGER
       and a.account_type   in (select el.element_value 
                                  from com_array_element el 
                                 where el.array_id = 14);

    trc_log_pkg.debug(
        i_text =>'Estimate count = [' || l_estimated_count || '], inst_id = [' || i_inst_id || ']'
    );

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );

    for inst in (
        select i.id 
          from ost_institution i
         where (i.id = i_inst_id
             or i_inst_id = ost_api_const_pkg.DEFAULT_INST 
             or i_inst_id is null)
           and i.id != ost_api_const_pkg.UNIDENTIFIED_INST
    ) loop
           
        open cu_event_objects(i_current_inst_id => inst.id);

        fetch cu_event_objects bulk collect into
              l_balance_id_tab
            , l_event_tab;

        trc_log_pkg.debug(
            i_text =>'process institution ' || inst.id || ', l_balance_id_tab.count = [' || l_balance_id_tab.count || ']'
        );
        l_processed_count := l_processed_count + l_balance_id_tab.count;

        --generate xml
        if l_balance_id_tab.count > 0 then

            rul_api_param_pkg.set_param (
                i_name       => 'INST_ID'
                , i_value    => inst.id
                , io_params  => l_params
            );

            prc_api_file_pkg.open_file(
                o_sess_file_id => l_sess_file_id
              , io_params      => l_params
            );

            open  main_xml_cur(inst.id);
            fetch main_xml_cur into l_file;
            close main_xml_cur;

            save_file;

            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab    => l_event_tab
            );

        end if;

        close cu_event_objects;
    end loop;
    
    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_estimated_count - l_processed_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('finish');
exception
    when others then
        rollback to sp_accounts_export;
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_sess_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_sess_file_id
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
end;

procedure process_unload_turnover(
    i_inst_id       in     com_api_type_pkg.t_inst_id
  , i_mode          in     com_api_type_pkg.t_dict_value
  , i_date_type     in     com_api_type_pkg.t_dict_value
  , i_start_date    in     date                                 default null
  , i_end_date      in     date                                 default null
  , i_shift_from    in     com_api_type_pkg.t_tiny_id           default 0
  , i_shift_to      in     com_api_type_pkg.t_tiny_id           default 0
  , i_balance_type  in     com_api_type_pkg.t_dict_value        default null
  , i_unload_limits in     com_api_type_pkg.t_boolean           default com_api_type_pkg.FALSE
  , i_array_account_type_id in     com_api_type_pkg.t_medium_id      default null
) is
    l_estimate_count       simple_integer := 0;
    l_session_file_id      com_api_type_pkg.t_long_id;
    l_file                 clob;
    l_start_date           date;
    l_end_date             date;
    l_sysdate              date;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_container_id         com_api_type_pkg.t_long_id :=  prc_api_session_pkg.get_container_id;
    l_unload_limits        com_api_type_pkg.t_boolean;

    l_event_tab            com_api_type_pkg.t_number_tab;
    l_entry_id_tab         num_tab_tpt;    
    l_params               com_api_type_pkg.t_param_tab;  
begin
    savepoint process_;

    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    l_sysdate    := com_api_sttl_day_pkg.get_sysdate;
    l_start_date := trunc(coalesce(i_start_date, l_sysdate), 'DD');
    l_end_date   := nvl(trunc(i_end_date, 'DD'), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    l_start_date := l_start_date + nvl(i_shift_from, 0);
    l_end_date   := l_end_date + nvl(i_shift_to, 0);

    l_unload_limits := nvl(i_unload_limits, com_api_type_pkg.FALSE);

    trc_log_pkg.debug(
        i_text => 'process_unload_turnover, container_id=#1, inst=#2, mode=#3, date_type=#4, date_from=#5, date_to=#6'
      , i_env_param1 => l_container_id
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_mode
      , i_env_param4 => i_date_type
      , i_env_param5 => to_char(l_start_date, 'dd.mm.yyyy hh24:mi:ss')
      , i_env_param6 => to_char(l_end_date, 'dd.mm.yyyy hh24:mi:ss')
    );
    trc_log_pkg.debug(
        i_text => 'process_unload_turnover, shift_from=#1, shift_to=#2, balance_type=#3, file_type=#4, l_unload_limits=#5'
      , i_env_param1 => i_shift_from
      , i_env_param2 => i_shift_to
      , i_env_param3 => i_balance_type
      , i_env_param4 => l_file_type
      , i_env_param5 => l_unload_limits
    );

    trc_log_pkg.info(
        i_text => 'process_unload_turnover, i_array_account_type_id=[#1]'
      , i_env_param1 => i_array_account_type_id
    );

    prc_api_stat_pkg.log_start;

    if i_mode in ('EXMDFULL', 'EXMDOPBL') then
        select
            xmlelement("accounts", xmlattributes('http://sv.bpc.in/SVXP' as "xmlns"),
                xmlelement("file_type",    l_file_type),
                xmlelement("date_purpose", i_date_type),
                xmlelement("start_date",   to_char(l_start_date, 'yyyy-mm-dd')),
                xmlelement("end_date",     to_char(l_end_date, 'yyyy-mm-dd')),
                xmlelement("inst_id",      i_inst_id),
                xmlagg(xmlelement("account", xmlattributes(g.account_id as "id"),
                    xmlelement("account_number", min(g.account_number)),
                    xmlelement("currency", min(g.currency)),
                    xmlelement("account_type", min(g.account_type)),
                    xmlelement("account_status", min(g.status)),
                    xmlelement("aval_balance", min(g.aval_balance)),
                    xmlagg(xmlelement("balance", xmlattributes(g.balance_id as "id"),
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
                    ) --limits
                  , case when l_unload_limits = com_api_type_pkg.TRUE then
                             acc_prc_account_export_pkg.generate_limit_xml(
                                 i_account_id => g.account_id
                             )
                         else null
                    end
                  , (select xmlagg(
                                xmlelement("flexible_field"
                                  , xmlelement("field_name", ff.name)
                                  , xmlelement("field_value"
                                      , case ff.data_type
                                            when com_api_const_pkg.DATA_TYPE_NUMBER then
                                                to_char(
                                                    to_number(
                                                        fd.field_value
                                                      , nvl(ff.data_format, com_api_const_pkg.NUMBER_FORMAT)
                                                    )
                                                  , com_api_const_pkg.XML_NUMBER_FORMAT
                                                )
                                            when com_api_const_pkg.DATA_TYPE_DATE   then
                                                to_char(
                                                    to_date(
                                                        fd.field_value
                                                      , nvl(ff.data_format, com_api_const_pkg.DATE_FORMAT)
                                                    )
                                                  , com_api_const_pkg.XML_DATE_FORMAT
                                                )
                                            else
                                                fd.field_value
                                        end
                                    )
                                )
                            )
                       from com_flexible_field ff
                          , com_flexible_data  fd
                      where ff.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                        and fd.field_id    = ff.id
                        and fd.object_id   = g.account_id
                    ) -- account flexible fields
                ))
            ).getclobval()
          , count(1)
        into l_file
           , l_estimate_count
        from (
            select
                f.account_id
              , a.currency
              , a.account_type
              , a.status
              , a.account_number
              , b.balance_type
              , f.balance_id
              , f.debits_amount
              , f.credits_amount
              , f.debits_count
              , f.credits_count
              , nvl(f.incoming_balance, 0) as incoming_balance
              , nvl(f.outgoing_balance, 0) as outgoing_balance
              , acc_api_balance_pkg.get_aval_balance_amount_only(f.account_id, l_sysdate, com_api_const_pkg.DATE_PURPOSE_PROCESSING, 1) aval_balance
            from (
                select
                    aa.id as account_id
                  , ab.id as balance_id
                  , nvl(sum(case j.balance_impact when -1 then j.amount end),0)  debits_amount
                  , nvl(sum(case j.balance_impact when 1 then j.amount end), 0) credits_amount
                  , count(case j.balance_impact when -1 then 1 else null end) debits_count
                  , count(case j.balance_impact when 1 then 1 else null end) credits_count
                  , min(j.balance - j.balance_impact * j.amount) keep ( dense_rank first order by j.posting_order asc ) as incoming_balance
                  , min(j.balance) keep ( dense_rank first order by j.posting_order desc ) as outgoing_balance
                from
                    acc_balance ab
                  , acc_account aa
                  , (select
                         ab.id as balance_id
                       , ae.balance
                       , ae.balance_impact
                       , ae.amount
                       , ae.posting_order
                     from
                         acc_entry ae
                       , acc_balance  ab
                     where (
                         (i_date_type = com_api_const_pkg.DATE_PURPOSE_PROCESSING
                         and ae.posting_date between l_start_date and l_end_date
                         )
                        or
                         (i_date_type = com_api_const_pkg.DATE_PURPOSE_BANK
                         and ae.sttl_date between l_start_date and l_end_date
                         ))
                     and
                         ae.account_id = ab.account_id
                     and (ae.status <> 'ENTRCNCL' or ae.status is null)
                     and
                         ab.balance_type = ae.balance_type
                     and
                        (i_mode = 'EXMDFULL' or
                            (i_mode = 'EXMDOPBL'
                                and
                                    (
                                      (i_date_type = com_api_const_pkg.DATE_PURPOSE_PROCESSING
                                       and
                                       ab.open_date >= l_start_date
                                       and
                                       nvl(ab.close_date, l_end_date) <= l_end_date
                                      )
                                      or
                                      (i_date_type = com_api_const_pkg.DATE_PURPOSE_BANK
                                       and
                                       ab.open_sttl_date >= l_start_date
                                       and
                                       nvl(ab.close_sttl_date, l_end_date) <= l_end_date
                                      )
                                    )
                            )
                        )
                    ) j
                where
                    aa.id = ab.account_id
                and
                    j.balance_id(+) = ab.id
                and
                    (i_array_account_type_id is null or aa.account_type in (select element_value from com_array_element where array_id = i_array_account_type_id))
                and
                    ab.split_hash in (select split_hash from com_api_split_map_vw)
                and
                    (aa.inst_id = i_inst_id or nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST) = ost_api_const_pkg.DEFAULT_INST)
                and
                    (i_mode = 'EXMDFULL' or
                        (i_mode = 'EXMDOPBL'
                            and
                                (
                                  (i_date_type = com_api_const_pkg.DATE_PURPOSE_PROCESSING
                                   and
                                   ab.open_date >= l_start_date
                                   and
                                   nvl(ab.close_date, l_end_date) <= l_end_date
                                  )
                                  or
                                  (i_date_type = com_api_const_pkg.DATE_PURPOSE_BANK
                                   and
                                   ab.open_sttl_date >= l_start_date
                                   and
                                   nvl(ab.close_sttl_date, l_end_date) <= l_end_date
                                  )
                                )
                        )
                    )
                and (
                        (
                            i_balance_type is not null
                            and (i_balance_type = '%' or ab.balance_type = i_balance_type)
                        )
                        or
                        (
                            i_balance_type is null
                            and ab.balance_type in (select element_value from com_array_element where array_id = 12)
                        )
                    )
                group by
                    aa.id, ab.id
            ) f
              , acc_balance b
              , acc_account a
            where
                f.account_id = a.id
            and
                f.balance_id = b.id) g
        group by g.account_id;

    elsif i_mode = 'EXMDHTBL' then
        select
            xmlelement("accounts", xmlattributes('http://sv.bpc.in/SVXP' as "xmlns"),
                xmlelement("file_type",      l_file_type),
                xmlelement("date_purpose",   i_date_type),
                xmlelement("start_date",     to_char(l_start_date, 'yyyy-mm-dd')),
                xmlelement("end_date",       to_char(l_end_date, 'yyyy-mm-dd')),
                xmlelement("inst_id",        i_inst_id),
                xmlagg(xmlelement("account", xmlattributes(g.account_id as "id"),
                    xmlelement("account_number", min(g.account_number)),
                    xmlelement("currency",       min(g.currency)),
                    xmlelement("account_type",   min(g.account_type)),
                    xmlelement("account_status", min(g.status)),
                    xmlelement("aval_balance", min(g.aval_balance)),
                    xmlagg(xmlelement("balance", xmlattributes(g.balance_id as "id"),
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
                    ) --limits
                  , case when l_unload_limits = com_api_type_pkg.TRUE then
                             acc_prc_account_export_pkg.generate_limit_xml(
                                 i_account_id => g.account_id
                             )
                         else null
                    end                
                ))
            ).getclobval()
          , count(1)
        into l_file
           , l_estimate_count
        from (
            select f.account_id
                 , a.currency
                 , a.account_type
                 , a.status
                 , a.account_number
                 , b.balance_type
                 , f.balance_id
                 , f.debits_amount
                 , f.credits_amount
                 , f.debits_count
                 , f.credits_count
                 , nvl(f.incoming_balance, 0) as incoming_balance
                 , nvl(f.outgoing_balance, 0) as outgoing_balance
                 , acc_api_balance_pkg.get_aval_balance_amount_only(f.account_id, l_sysdate, com_api_const_pkg.DATE_PURPOSE_PROCESSING, 1) aval_balance
            from (
                select
                    aa.id as account_id
                  , ab.id as balance_id
                  , nvl(sum(case ae.balance_impact when -1 then ae.amount end),0)  debits_amount
                  , nvl(sum(case ae.balance_impact when 1 then ae.amount end), 0) credits_amount
                  , count(case ae.balance_impact when -1 then 1 else null end) debits_count
                  , count(case ae.balance_impact when 1 then 1 else null end) credits_count
                  , min(ae.balance - ae.balance_impact * ae.amount) keep ( dense_rank first order by ae.posting_order asc) as incoming_balance
                  , min(ae.balance) keep ( dense_rank first order by ae.posting_order desc ) as outgoing_balance
                from acc_balance ab
                   , acc_account aa
                   , acc_entry ae
               where aa.id = ab.account_id
                 and ae.account_id = aa.id
                 and (ae.status <> 'ENTRCNCL' or ae.status is null)
                 and ae.balance_type = ab.balance_type
                 and (i_array_account_type_id is null or aa.account_type in (select element_value from com_array_element where array_id = i_array_account_type_id))
                 and ab.split_hash in (select split_hash from com_api_split_map_vw)
                 and (aa.inst_id = i_inst_id or nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST) = ost_api_const_pkg.DEFAULT_INST)
                 and((i_date_type = com_api_const_pkg.DATE_PURPOSE_PROCESSING
                       and ae.posting_date between l_start_date and l_end_date
                      )
                    or
                      (i_date_type = com_api_const_pkg.DATE_PURPOSE_BANK
                       and
                       ae.sttl_date between l_start_date and l_end_date
                      )
                    )
                and (
                        (
                            i_balance_type is not null
                            and (i_balance_type = '%' or ab.balance_type = i_balance_type)
                        )
                        or
                        (
                            i_balance_type is null
                            and ab.balance_type in (select element_value from com_array_element where array_id = 12)
                        )
                    )
              group by aa.id, ab.id
            ) f
              , acc_balance b
              , acc_account a
            where f.account_id = a.id
              and f.balance_id = b.id)g
        group by g.account_id;

    elsif i_mode = 'EXMDINCR' then

        select o.id
             , ae.id
          bulk collect into
               l_event_tab
             , l_entry_id_tab
          from evt_event_object o
             , acc_entry ae
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ACC_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER'
           and o.eff_date    <= l_sysdate
           and (o.inst_id = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and o.entity_type  = 'ENTTENTR'
           and ae.id          = o.object_id + 0
           and ae.split_hash  = o.split_hash
           and (
                   (
                       i_date_type = com_api_const_pkg.DATE_PURPOSE_PROCESSING
                       and ae.posting_date between l_start_date and l_end_date
                   )
                   or
                   (
                       i_date_type = com_api_const_pkg.DATE_PURPOSE_BANK
                       and ae.sttl_date between l_start_date and l_end_date
                   )
               )
           and (ae.status != 'ENTRCNCL' or ae.status is null)
           and (o.container_id is null or o.container_id = l_container_id)
           and (
                   (
                       i_balance_type is not null
                       and (i_balance_type = '%' or ae.balance_type = i_balance_type)
                   )
                   or
                   (
                       i_balance_type is null
                       and ae.balance_type in (select element_value from com_array_element where array_id = 12)
                   )
               );

        select
            xmlelement("accounts", xmlattributes('http://sv.bpc.in/SVXP' as "xmlns"),
                xmlelement("file_type",    l_file_type),
                xmlelement("date_purpose", i_date_type),
                xmlelement("start_date",   to_char(l_start_date, 'yyyy-mm-dd')),
                xmlelement("end_date",     to_char(l_end_date, 'yyyy-mm-dd')),
                xmlelement("inst_id",      i_inst_id),
                xmlagg(xmlelement("account", xmlattributes(g.account_id as "id"),
                    xmlelement("account_number", min(g.account_number)),
                    xmlelement("currency", min(g.currency)),
                    xmlelement("account_type", min(g.account_type)),
                    xmlelement("account_status", min(g.status)),
                    xmlelement("aval_balance", min(g.aval_balance)),
                    xmlagg(
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
                    ) --limits
                  , case when l_unload_limits = com_api_type_pkg.TRUE then
                             acc_prc_account_export_pkg.generate_limit_xml(
                                 i_account_id => g.account_id
                             )
                         else null
                    end                
                )
              )
            ).getclobval()
          , count(1)
        into l_file
           , l_estimate_count
        from (
            select f.account_id
                 , a.currency
                 , a.account_type
                 , a.status
                 , a.account_number
                 , b.balance_type
                 , f.balance_id
                 , f.debits_amount
                 , f.credits_amount
                 , f.debits_count
                 , f.credits_count
                 , nvl(f.incoming_balance, 0) as incoming_balance
                 , nvl(f.outgoing_balance, 0) as outgoing_balance
                 , acc_api_balance_pkg.get_aval_balance_amount_only(f.account_id, l_sysdate, 'DTPR0001', 1) aval_balance
            from (
                select aa.id as account_id
                     , ab.id as balance_id
                     , nvl(sum(case ae.balance_impact when -1 then ae.amount end),0)  debits_amount
                     , nvl(sum(case ae.balance_impact when 1 then ae.amount end), 0) credits_amount
                     , count(case ae.balance_impact when -1 then 1 else null end) debits_count
                     , count(case ae.balance_impact when 1 then 1 else null end) credits_count
                     , min(ae.balance - ae.balance_impact * ae.amount) keep ( dense_rank first order by ae.posting_order asc ) as incoming_balance
                     , min(ae.balance) keep ( dense_rank first order by ae.posting_order desc ) as outgoing_balance
                  from acc_entry ae
                     , acc_account aa
                     , acc_balance ab
                 where ae.id in (select column_value from table(cast(l_entry_id_tab as num_tab_tpt)))
                   and ae.account_id = aa.id
                   and aa.id = ab.account_id
                   and ae.balance_type = ab.balance_type
                   and (i_array_account_type_id is null or aa.account_type in (select element_value from com_array_element where array_id = i_array_account_type_id))
                   and ab.split_hash in (select split_hash from com_api_split_map_vw)
                   and (
                           aa.inst_id = i_inst_id
                           or nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST) = ost_api_const_pkg.DEFAULT_INST
                       )
                   and (
                           (
                               i_balance_type is not null
                               and (i_balance_type = '%' or ab.balance_type = i_balance_type)
                           )
                           or
                           (
                               i_balance_type is null
                               and ab.balance_type in (select element_value from com_array_element where array_id = 12)
                           )
                       )
                 group by
                    aa.id, ab.id
              ) f
              , acc_balance b
              , acc_account a
          where f.account_id = a.id
            and f.balance_id = b.id
        ) g
        group by g.account_id;

    else
        null;
    end if;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimate_count
    );

    if l_estimate_count > 0 then
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

    if i_mode = 'EXMDINCR' then
        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab    => l_event_tab
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total  => l_estimate_count
      , i_excepted_total   => 0
      , i_rejected_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        rollback to process_;

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

end process_unload_turnover;

/*
 * This process is obsolete. 
 * It is recommended to use the process process_turnover_info.
 */
procedure process_unload_turnover_info(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_mode                  in     com_api_type_pkg.t_dict_value
  , i_date_type             in     com_api_type_pkg.t_dict_value
  , i_start_date            in     date                              default null
  , i_end_date              in     date                              default null
  , i_shift_from            in     com_api_type_pkg.t_tiny_id        default 0
  , i_shift_to              in     com_api_type_pkg.t_tiny_id        default 0
  , i_balance_type          in     com_api_type_pkg.t_dict_value     default null
  , i_account_number        in     com_api_type_pkg.t_account_number default null
  , i_masking_card          in     com_api_type_pkg.t_boolean        default com_api_type_pkg.TRUE
  , i_load_reversals        in     com_api_type_pkg.t_boolean        default com_api_type_pkg.TRUE 
) is
    l_estimate_count       number;
    l_session_file_id      com_api_type_pkg.t_long_id;
    l_file                 clob;
    l_start_date           date;
    l_end_date             date;
    l_sysdate              date;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_container_id         com_api_type_pkg.t_long_id :=  prc_api_session_pkg.get_container_id;
    l_account_id           com_api_type_pkg.t_account_id;
    l_cursor_stmt          com_api_type_pkg.t_lob_data;
    l_count_stmt           com_api_type_pkg.t_text := 'select count(1) as cnt from (#)';
    l_xml_head             com_api_type_pkg.t_lob_data;
    l_balance              com_api_type_pkg.t_name;
    l_balance_type         com_api_type_pkg.t_dict_value;
    l_inst                 com_api_type_pkg.t_name;
    l_inst_id              com_api_type_pkg.t_inst_id;
    l_account              com_api_type_pkg.t_name;
    l_date1                com_api_type_pkg.t_name;
    l_date2                com_api_type_pkg.t_name := '1=1';
    l_params               com_api_type_pkg.t_param_tab;
    l_sql                  dbms_sql.varchar2s;
    l_upperbound           number;
    l_cur                  number;
    l_res                  number;
    l_reversal             com_api_type_pkg.t_text := '1=1';
begin
    savepoint process_unload_turnover;
    prc_api_stat_pkg.log_start;

    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    -- check account number
    if i_account_number is not null then
        l_account_id := acc_api_account_pkg.get_account_id(i_account_number);
        if l_account_id = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'ACCOUNT_NOT_FOUND'
              , i_env_param1 => i_account_number
            );
        end if;
    end if;

    l_start_date := trunc(coalesce(i_start_date, l_sysdate),'DD') + nvl(i_shift_from, 0);
    l_end_date   := nvl(trunc(i_end_date,'DD'), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND + nvl(i_shift_to, 0);

    trc_log_pkg.info(
        i_text       => 'process_unload_turnover_info, i_mask_card_number=[#1]'
      , i_env_param1 => i_masking_card
    );

    trc_log_pkg.info(
        i_text =>'process_unload_turnover, container_id=#1, inst=#2, mode=#3, date_type=#4, date_from=#5, date_to=#6'
      , i_env_param1 => l_container_id
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_mode
      , i_env_param4 => i_date_type
      , i_env_param5 => to_char(l_start_date, 'dd.mm.yyyy hh24:mi:ss')
      , i_env_param6 => to_char(l_end_date, 'dd.mm.yyyy hh24:mi:ss')
    );

    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    if l_file_type is null then
        com_api_error_pkg.raise_error(
            i_error      => 'FILE_TYPE_NOT_FOUND'
          , i_env_param1 => prc_api_session_pkg.get_process_id
        );
    end if;

    trc_log_pkg.info(
        i_text       => 'process_unload_turnover, shift_from=#1, shift_to=#2, balance_type=#3, file_type=#4' ||
                        ', account_number=#5, thread_number=#6'
      , i_env_param1 => i_shift_from
      , i_env_param2 => i_shift_to
      , i_env_param3 => i_balance_type
      , i_env_param4 => l_file_type
      , i_env_param5 => nvl(i_account_number, '')
      , i_env_param6 => get_thread_number
    );

    l_xml_head := '
        select
            xmlelement("clearing"
              , xmlattributes(''http://bpc.ru/sv/SVXP/clearing'' as "xmlns")
              , xmlelement("file_id",        :file_id)
              , xmlelement("file_type",      :file_type)
              , xmlelement("inst_id",        i_inst_id)
              , xmlagg(
                    xmlelement("operation"
                      , xmlelement("oper_id", g.oper_id)
                      , xmlelement("oper_type",g.oper_type)
                      , xmlelement("msg_type",  g.msg_type)
                      , xmlelement("sttl_type", g.sttl_type)
                      , xmlelement("oper_date", to_char(g.oper_date, ''yyyy-mm-dd"T"hh24:mi:ss''))
                      , xmlelement("host_date", to_char(g.host_date, ''yyyy-mm-dd"T"hh24:mi:ss''))
                      , xmlelement("oper_amount"
                            , xmlelement("amount_value", g.oper_amount)
                            , xmlelement("currency", g.oper_currency)
                        )
                      , (select xmlagg(
                                    xmlelement("oper_cashback_amount"
                                        , xmlelement("amount_value", g.oper_cashback_amount)
                                        , xmlelement("currency", g.oper_currency)
                                    )
                                )
                           from dual
                          where g.oper_cashback_amount is not null
                        )
                      , (select xmlagg(
                                    xmlelement("sttl_amount"
                                        , xmlelement("amount_value", g.sttl_amount)
                                        , xmlelement("currency", g.sttl_currency)
                                    )
                                )
                           from dual
                          where g.sttl_amount is not null
                            and g.sttl_currency is not null
                        )
                      , xmlelement("network_refnum", g.network_refnum)
                      , xmlelement("response_code", g.response_code)
                      , xmlelement("merchant_number", g.merchant_number)
                      , xmlelement("mcc", g.mcc)
                      , xmlelement("merchant_name", g.merchant_name)
                      , xmlelement("merchant_street", g.merchant_street)
                      , xmlelement("merchant_city", g.merchant_city)
                      , xmlelement("merchant_country", g.merchant_country)
                      , xmlelement("terminal_type", g.terminal_type)
                      , xmlelement("terminal_number", g.terminal_number)
                      , xmlelement("issuer"
                            , xmlelement("client_id_type",  g.client_id_type)
                            , xmlelement("client_id_value", g.client_id_value)
                            , xmlelement("card_number",     g.card_mask)
                            , xmlelement("card_id",         g.card_id)
                            , xmlelement("card_seq_number", g.card_seq_number)
                            , xmlelement("card_expir_date", g.card_expir_date)
                            , xmlelement("inst_id",         g.iss_inst_id)
                            , xmlelement("network_id",      g.iss_network_id)
                            , xmlelement("auth_code",       g.auth_code)
                      )
                      , (select xmlagg(
                               xmlelement("transaction"
                                    , xmlelement("transaction_id", xa.transaction_id)
                                    , xmlelement("transaction_type", xa.transaction_type)
                                    , xmlelement("transaction_date", to_char(min(xa.posting_date), ''yyyy-mm-dd"T"hh24:mi:ss''))
                                    , (select xmlagg(
                                            xmlelement("debit_entry"
                                              , xmlelement("entry_id", z.id)
                                              , xmlelement("posting_date", to_char(z.posting_date, ''yyyy-mm-dd''))
                                              , xmlelement("sttl_date", to_char(z.sttl_date, ''yyyy-mm-dd''))
                                              , xmlelement("posting_order", to_char(z.posting_order,''TM9''))
                                              , xmlelement("sttl_day", to_char(sttl_day, ''TM9''))
                                              , xmlelement("account"
                                                , xmlelement("account_number", zz.account_number)
                                                , xmlelement("currency", zz.currency)
                                              )
                                              , xmlelement("amount"
                                                , xmlelement("amount_value", z.amount)
                                                , xmlelement("currency", z.currency)
                                              )
                                            )
                                         )
                                       from acc_entry z
                                          , acc_account zz
                                      where z.transaction_id = xa.transaction_id
                                        and z.balance_impact = -1
                                        and z.account_id     = zz.id
                                      )
                                    , (select
                                         xmlagg(
                                             xmlelement("credit_entry"
                                               , xmlelement("entry_id", z.id)
                                               , xmlelement("posting_date", to_char(z.posting_date, ''yyyy-mm-dd''))
                                               , xmlelement("sttl_date", to_char(z.sttl_date, ''yyyy-mm-dd''))
                                               , xmlelement("posting_order", to_char(z.posting_order,''TM9''))
                                               , xmlelement("sttl_day", to_char(sttl_day, ''TM9''))
                                               , xmlelement("account"
                                                 , xmlelement("account_number", zz.account_number)
                                                 , xmlelement("currency", zz.currency)
                                               )
                                               , xmlelement("amount"
                                                 , xmlelement("amount_value", z.amount)
                                                 , xmlelement("currency", z.currency)
                                               )
                                             )
                                           )
                                       from acc_entry z
                                          , acc_account zz
                                      where z.transaction_id = xa.transaction_id
                                        and z.balance_impact = 1
                                        and z.account_id     = zz.id
                                      )
                                    , cst_api_document_pkg.get_document_block(
                                          i_operation_id   => g.oper_id
                                        , i_transaction_id => xa.transaction_id
                                      )
                                    )
                                )
                           from acc_entry xa
                              , acc_macros xm
                          where xa.macros_id = xm.id
                            and xm.entity_type = ''ENTTOPER''
                            and xm.object_id = g.oper_id
                          group by xa.transaction_id, xa.transaction_type
                        ) transactions
                    )
                )
            ).getclobval()
        from (#) g';


    if i_mode in ('EXMDFULL', 'EXMDOPBL') then
        l_cursor_stmt := '
            select
                (select min(x.purpose_id) from pmo_order x where x.id = oo.payment_order_id) purpose_id
              , oo.payment_order_id
              , x.oper_id
              , oo.oper_type
              , oo.msg_type
              , oo.sttl_type
              , oo.oper_date
              , oo.host_date
              , oo.oper_amount
              , oo.oper_currency
              , oo.sttl_amount
              , oo.sttl_currency
              , oo.network_refnum
              , oo.status_reason as response_code
              , oo.merchant_number
              , oo.mcc
              , oo.merchant_name
              , oo.merchant_street
              , oo.merchant_city
              , oo.merchant_country
              , oo.terminal_type
              , oo.terminal_number
              , b.client_id_type
              , b.client_id_value
              , #MASK_CARD_NUMBER
              , b.card_id
              , b.card_seq_number
              , b.card_expir_date
              , b.inst_id as iss_inst_id
              , b.network_id as iss_network_id
              , b.auth_code
              , oo.oper_cashback_amount
            from (
               select o.id as oper_id
                    , min(f.posting_date) as transaction_date
                 from opr_operation o
                    , acc_entry f
                    , acc_macros m
                    , acc_balance ab
                    , acc_account aa
                where m.entity_type = ''ENTTOPER''
                  and m.id = f.macros_id
                  and m.object_id = o.id
                  and f.account_id = aa.id
                  and ab.account_id = aa.id
                  and ab.balance_type = f.balance_type
                  and f.status        != ''ENTRCNCL''
                  and #DATE1
                  and #ACCOUNT
                  and #DATE2
                  and #BALANCE
                  and #INST
                group by
                    o.id ) x
              , opr_operation oo
              , opr_participant b
              , opr_card c
            where x.oper_id = oo.id
              and x.oper_id = b.oper_id
              and b.participant_type = ''PRTYISS''
              and c.oper_id(+) = b.oper_id
              and c.participant_type(+) = b.participant_type
              and #REVERSAL
            order by x.oper_id';
        else
            l_cursor_stmt := '
            select
                (select min(x.purpose_id) from pmo_order x where x.id = oo.payment_order_id) purpose_id
              , oo.payment_order_id
              , x.oper_id
              , oo.oper_type
              , oo.msg_type
              , oo.sttl_type
              , oo.oper_date
              , oo.host_date
              , oo.oper_amount
              , oo.oper_currency
              , oo.sttl_amount
              , oo.sttl_currency
              , oo.network_refnum
              , oo.status_reason as response_code
              , oo.merchant_number
              , oo.mcc
              , oo.merchant_name
              , oo.merchant_street
              , oo.merchant_city
              , oo.merchant_country
              , oo.terminal_type
              , oo.terminal_number
              , b.client_id_type
              , b.client_id_value
              , #MASK_CARD_NUMBER
              , b.card_id
              , b.card_seq_number
              , b.card_expir_date
              , b.inst_id as iss_inst_id
              , b.network_id as iss_network_id
              , b.auth_code
              , oo.oper_cashback_amount
            from (
               select o.id as oper_id
                    , min(f.posting_date) as transaction_date
                 from opr_operation o
                    , acc_entry f
                    , acc_macros m
                    , acc_balance ab
                    , acc_account aa
                where m.entity_type = ''ENTTOPER''
                  and m.id = f.macros_id
                  and m.object_id = o.id
                  and f.account_id = aa.id
                  and ab.account_id = aa.id
                  and ab.balance_type = f.balance_type
                  and f.status        != ''ENTRCNCL''
                  and #DATE1
                  and #ACCOUNT
                  and #DATE2
                  and #BALANCE
                  and #INST
               group by
                     o.id ) x
              , opr_operation oo
              , opr_participant b
              , opr_card c
            where x.oper_id = oo.id
              and x.oper_id = b.oper_id
              and b.participant_type = ''PRTYISS''
              and c.oper_id(+) = b.oper_id
              and c.participant_type(+) = b.participant_type
              and #REVERSAL
         order by x.oper_id';
        end if;

    --i_mask_card_number
    if nvl(i_masking_card, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
        if set_ui_value_pkg.get_inst_param_n(
               i_param_name => 'MASKING_CARD_IN_DBAL_FILE'
             , i_inst_id    => i_inst_id) = com_api_const_pkg.TRUE then 
            l_cursor_stmt := replace(l_cursor_stmt, '#MASK_CARD_NUMBER', 'iss_api_card_pkg.get_card_mask(i_card_number => iss_api_token_pkg.decode_card_number(i_card_number => c.card_number))  as card_mask');
        else
            l_cursor_stmt := replace(l_cursor_stmt, '#MASK_CARD_NUMBER', 'b.card_mask as card_mask');
        end if;
    else
        l_cursor_stmt := replace(l_cursor_stmt, '#MASK_CARD_NUMBER', 'iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_mask');
    end if;

    -- date1
    if i_date_type = com_api_const_pkg.DATE_PURPOSE_PROCESSING then
        l_date1 := 'f.posting_date between :start_date and :end_date';
    elsif i_date_type = com_api_const_pkg.DATE_PURPOSE_BANK then
        l_date1 := 'f.sttl_date between :start_date and :end_date';
    end if;
    l_cursor_stmt := replace(l_cursor_stmt, '#DATE1', l_date1);
    -- date2
    if i_mode = 'EXMDOPBL' then
        if i_date_type = com_api_const_pkg.DATE_PURPOSE_PROCESSING then
            l_date2 := 'ab.open_date >= :start_date and nvl(ab.close_date, :end_date) <= :end_date';
        elsif i_date_type = com_api_const_pkg.DATE_PURPOSE_BANK then
            l_date2 := 'ab.open_sttl_date >= :start_date and nvl(ab.close_sttl_date, :end_date) <= :end_date';
        end if;
    end if;
    l_cursor_stmt := replace(l_cursor_stmt, '#DATE2', l_date2);

    -- balance type
    l_balance_type := nvl(i_balance_type, 'NONE');
    if i_balance_type is null then
        l_balance := '(:balance_type = ''NONE'' and
                        f.balance_type in (select element_value from com_array_element where array_id = 12))';
    elsif i_balance_type = '%' then
        l_balance := ':balance_type = ''%''';
    else
        l_balance := 'f.balance_type = :balance_type';
    end if;
    l_cursor_stmt := replace(l_cursor_stmt, '#BALANCE', l_balance);

    -- inst
    l_inst_id := nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST);
    if l_inst_id = ost_api_const_pkg.DEFAULT_INST then
        l_inst := ':inst_id = 9999';
    else
        l_inst := 'aa.inst_id = :inst_id';
    end if;
    l_cursor_stmt := replace(l_cursor_stmt, '#INST', l_inst);

    -- account
    if i_account_number is not null then
        l_account := 'ab.account_id = :account';
    else
        l_account := ':account is null';
    end if;
    l_cursor_stmt := replace(l_cursor_stmt, '#ACCOUNT', l_account);

    --reversal
    if nvl(i_load_reversals, com_api_type_pkg.TRUE) = com_api_type_pkg.FALSE then
        l_reversal := '((oo.is_reversal = 1 and not exists(select 1 from opr_operation where id = oo.original_id and oo.oper_date between :start_date and :end_date)) 
                        or
                       (oo.is_reversal = 0 and not exists(select 1 from opr_operation where original_id = oo.id and oo.oper_date between :start_date and :end_date)))';
    end if;
    l_cursor_stmt := replace(l_cursor_stmt, '#REVERSAL', l_reversal);

    -- estimate count
    l_count_stmt := replace(l_count_stmt, '#', l_cursor_stmt);

    trc_log_pkg.debug('Estimate count cursor: ' || l_count_stmt );

    l_upperbound := ceil(dbms_lob.getlength(l_count_stmt)/256);
    for i in 1..l_upperbound
    -- cut query
    loop
       l_sql(i) := dbms_lob.substr(l_count_stmt, 256,((i-1)*256)+1);
    end loop;
    l_cur := dbms_sql.open_cursor(1);
    dbms_sql.parse(l_cur, l_sql, 1, l_upperbound, false, dbms_sql.native);

    dbms_sql.bind_variable(l_cur, ':start_date', l_start_date);
    dbms_sql.bind_variable(l_cur, ':end_date', l_end_date);
    dbms_sql.bind_variable(l_cur, ':account', l_account_id);
    dbms_sql.bind_variable(l_cur, ':balance_type', l_balance_type);
    dbms_sql.bind_variable(l_cur, ':inst_id', l_inst_id);
    dbms_sql.define_column(l_cur, 1, l_estimate_count);
    l_res := dbms_sql.execute_and_fetch(l_cur);
    dbms_sql.column_value(l_cur, 1, l_estimate_count);
    dbms_sql.close_cursor(l_cur);
    trc_log_pkg.info('Estimate:' || l_estimate_count);
    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimate_count
    );

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

    prc_api_file_pkg.open_file(
        o_sess_file_id => l_session_file_id
      , i_file_type    => l_file_type
      , i_file_purpose => prc_api_const_pkg.FILE_PURPOSE_OUT
      , io_params      => l_params
    );

    -- get xml
    l_cursor_stmt := replace(l_xml_head, '#', l_cursor_stmt);

    trc_log_pkg.debug('File cursor: ' || substr(l_cursor_stmt,1,3000));

    l_upperbound := ceil(dbms_lob.getlength(l_cursor_stmt)/256);
    for i in 1..l_upperbound
    loop
       l_sql(i) := dbms_lob.substr(l_cursor_stmt,256,((i-1)*256)+1);
       trc_log_pkg.debug(l_sql(i));
    end loop;
    trc_log_pkg.debug (':start_date'|| to_char(l_start_date, get_date_format));
    trc_log_pkg.debug(':end_date'||to_char(l_end_date, get_date_format));
    trc_log_pkg.debug(':account'|| l_account_id);
    trc_log_pkg.debug(':balance_type'||l_balance_type);
    trc_log_pkg.debug(':inst_id'||l_inst_id);
    trc_log_pkg.debug(':file_id'||l_session_file_id);
    trc_log_pkg.debug(':file_type='||l_file_type);
    trc_log_pkg.debug(':i_masking_card='||i_masking_card);

    l_cur := dbms_sql.open_cursor(1);
    dbms_sql.parse(l_cur, l_sql, 1, l_upperbound, false, dbms_sql.native);
    dbms_sql.bind_variable(l_cur, ':start_date', l_start_date);
    dbms_sql.bind_variable(l_cur, ':end_date', l_end_date);
    dbms_sql.bind_variable(l_cur, ':account', l_account_id);
    dbms_sql.bind_variable(l_cur, ':balance_type', l_balance_type);
    dbms_sql.bind_variable(l_cur, ':inst_id', l_inst_id);
    dbms_sql.bind_variable(l_cur, ':file_id', l_session_file_id);
    dbms_sql.bind_variable(l_cur, ':file_type', l_file_type);
    dbms_sql.define_column(l_cur, 1, l_file);
    l_res := dbms_sql.execute_and_fetch(l_cur);
    dbms_sql.column_value(l_cur, 1, l_file);

    dbms_sql.close_cursor(l_cur);

    prc_api_file_pkg.put_file(
        i_sess_file_id  => l_session_file_id
      , i_clob_content  => l_file
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug('file saved, cnt='||l_estimate_count||', length='||length(l_file));

    prc_api_stat_pkg.log_end(
        i_processed_total  => l_estimate_count
      , i_excepted_total   => 0
      , i_rejected_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to process_unload_turnover;

        if dbms_sql.is_open(l_cur) then
            dbms_sql.close_cursor(l_cur);
        end if;

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

end process_unload_turnover_info;

--- WARNING! This process is obsolete and is no longer supported. 
-- Instead, you should use acc_prc_account_export_pkg.process_turnover_info, 
-- which has more parameters and is updated to unload the full format of clearing.
procedure process_unload_transactions(
    i_inst_id   in  com_api_type_pkg.t_inst_id
) is
    l_sysdate                 date                          := com_api_sttl_day_pkg.get_sysdate;
    l_sess_file_id            com_api_type_pkg.t_long_id;
    l_file                    clob;
    l_start_date              date;
    l_end_date                date;
    l_estimated_count         pls_integer                   := 0;
    l_transaction_id_tab      num_tab_tpt;
    l_event_tab               com_api_type_pkg.t_number_tab;
    l_params                  com_api_type_pkg.t_param_tab;
    l_entry_id_tab            com_api_type_pkg.t_long_tab;
    l_inst_id_tab             com_api_type_pkg.t_inst_id_tab;
    l_split_hash_tab          com_api_type_pkg.t_tiny_tab;

    cursor cu_event_objects is
        select ae.transaction_id
             , o.id as event_object_id
             , ae.id as entry_id
             , o.inst_id
             , o.split_hash
          from evt_event_object o
             , opr_operation oo
             , acc_entry ae
             , acc_macros am
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ACC_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TRANSACTIONS'
           and o.eff_date      <= l_sysdate
           and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
           and o.object_id      = ae.transaction_id
           and am.entity_type   = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and am.object_id     = oo.id
           and ae.macros_id     = am.id
           and ae.status       != acc_api_const_pkg.ENTRY_STATUS_CANCELED
           and (o.inst_id       = i_inst_id or i_inst_id is null)
      order by ae.transaction_id;

    cursor main_xml_cur is
             select xmlelement("clearing", xmlattributes('http://sv.bpc.in/SVXP' as "xmlns")
                  , xmlelement("file_id",   to_char(l_sess_file_id,'TM9') )
                  , xmlelement("file_type", acc_api_const_pkg.FILE_TYPE_POSTINGS )
                  , xmlelement("file_date", to_char(com_api_sttl_day_pkg.get_sysdate, com_api_const_pkg.XML_DATE_FORMAT) )
                  , xmlelement("start_date", to_char(l_start_date, com_api_const_pkg.XML_DATE_FORMAT) )
                  , xmlelement("end_date", to_char(l_end_date, com_api_const_pkg.XML_DATE_FORMAT) )
                  , xmlelement("inst_id", to_char(i_inst_id, 'TM9') )
                  ,     xmlagg(                    
                            xmlelement("operation"
                            , xmlforest(to_char(o.id, 'TM9') as "operation_id"
                                      , to_char(o.host_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "host_date"
                                      , to_char(o.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "oper_date"  
                                      , xmlforest(
                                            o.oper_amount      as "amount_value"
                                          , o.oper_currency    as "currency"
                                        ) as "oper_amount"
                                      , o.originator_refnum    as "originator_refnum"
                                      , o.network_refnum       as "network_refnum"  
                                      , o.status_reason        as "response_code"
                                      , xmlforest(
                                            o.sttl_amount      as "amount_value"
                                          , o.sttl_currency    as "currency"
                                        ) as "sttl_amount"
                              )
                            , (select
                                xmlelement("payment_order"
                                    , xmlelement("payment_order_id", x.id)
                                    , xmlelement("payment_order_status", x.status)
                                    , (select 
                                           xmlagg(
                                               xmlelement("payment_parameter"
                                                   , xmlelement("payment_parameter_name", xp.param_name)
                                                   , xmlelement("payment_parameter_value", xod.param_value)
                                               )
                                           ) 
                                         from pmo_parameter xp
                                            , pmo_order_data xod
                                        where xp.id = xod.param_id
                                          and xod.order_id = x.id
                                      ) --parameters
                                    , (select 
                                            xmlagg(
                                                xmlelement("document"
                                                    , xmlelement("document_id", x.id)
                                                    , xmlelement("document_type", x.document_type)
                                                    , xmlelement("document_date", to_char(x.document_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                                    , xmlelement("document_number", x.document_number)
                                                    , xmlagg(
                                                        xmlelement("document_content"
                                                            , xmlelement("content_type", xc.content_type)
                                                            , xmlelement("content", com_api_hash_pkg.base64_encode(xc.document_content))
                                                        )    
                                                      )
                                                )
                                            )
                                         from rpt_document x
                                            , rpt_document_content xc
                                        where x.entity_type = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
                                          and x.object_id = x.id
                                          and x.id = xc.document_id(+)
                                     group by x.id, x.document_type, x.document_date, x.document_number            
                                      ) --document   
                                )
                                 from pmo_order x
                                where x.id = o.payment_order_id     
                              )
                            , (select xmlagg(
                                         xmlelement("transaction"
                                           , xmlelement("transaction_id", xa.transaction_id)
                                           , xmlelement("transaction_type", xa.transaction_type)
                                           , xmlelement("posting_date", to_char(min(xa.posting_date), com_api_const_pkg.XML_DATETIME_FORMAT))
                                           , (select xmlagg(
                                                         xmlelement("debit_entry"
                                                           , xmlelement("entry_id", z.id)
                                                           , xmlelement("account"
                                                               , xmlelement("account_number", zz.account_number)
                                                               , xmlelement("currency", zz.currency)
                                                             )
                                                           , xmlelement("amount"
                                                               , xmlelement("amount_value", z.amount)
                                                               , xmlelement("currency", z.currency)
                                                             )
                                                           , xmlforest(case check_inst_id(i_inst_id      => zz.inst_id)
                                                                           when com_api_const_pkg.TRUE then z.is_settled
                                                                           else null
                                                                        end as "is_settled")
                                                         )
                                                     )
                                                from acc_entry z
                                                   , acc_account zz
                                               where z.transaction_id = xa.transaction_id
                                                 and z.balance_impact = -1
                                                 and z.account_id     = zz.id
                                             ) --debit entry
                                           , (select xmlagg(
                                                         xmlelement("credit_entry"
                                                           , xmlelement("entry_id", z.id)
                                                           , xmlelement("account"
                                                               , xmlelement("account_number", zz.account_number)
                                                               , xmlelement("currency", zz.currency)
                                                             )
                                                           , xmlelement("amount"
                                                               , xmlelement("amount_value", z.amount)
                                                               , xmlelement("currency", z.currency)
                                                             )
                                                           , xmlforest(case check_inst_id(i_inst_id      => zz.inst_id)
                                                                           when com_api_const_pkg.TRUE then z.is_settled
                                                                           else null
                                                                        end as "is_settled")
                                                         )
                                                     )
                                                from acc_entry z
                                                   , acc_account zz
                                               where z.transaction_id = xa.transaction_id
                                                 and z.balance_impact = 1
                                                 and z.account_id     = zz.id
                                             ) --credit entry  
                                           , (select xmlagg(
                                                         xmlelement("document"
                                                           , xmlelement("document_id", x.id)
                                                           , xmlelement("document_type", x.document_type)
                                                           , xmlelement("document_date", to_char(x.document_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                                           , xmlelement("document_number", x.document_number)
                                                           , xmlagg(
                                                                 xmlelement("document_content"
                                                                   , xmlelement("content_type", xc.content_type)
                                                                   , xmlelement("content", com_api_hash_pkg.base64_encode(xc.document_content))
                                                                 )    
                                                             )
                                                         )
                                                     )
                                                from rpt_document x
                                                   , rpt_document_content xc
                                               where x.entity_type = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
                                                 and x.object_id = xa.transaction_id
                                                 and x.id = xc.document_id(+)
                                               group by x.id, x.document_type, x.document_date, x.document_number            
                                             ) --document  
                                         ) --xmlelement transaction
                                     )--xmlagg
                                from acc_entry xa
                                   , acc_macros xm
                               where xa.macros_id = xm.id
                                 and xm.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION 
                                 and xm.object_id = o.id   
                               group by xa.transaction_id, xa.transaction_type   
                              )
                            , (select xmlagg(
                                            xmlelement("document"
                                                , xmlelement("document_id", x.id)
                                                , xmlelement("document_type", x.document_type)
                                                , xmlelement("document_date", to_char(x.document_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                                , xmlelement("document_number", x.document_number)
                                                , xmlagg(
                                                    xmlelement("document_content"
                                                        , xmlelement("content_type", xc.content_type)
                                                        , xmlelement("content", com_api_hash_pkg.base64_encode(xc.document_content))
                                                    )    
                                                  )
                                            )
                                      )
                                 from rpt_document x
                                    , rpt_document_content xc
                                where x.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                  and x.object_id = o.id
                                  and x.id = xc.document_id(+)
                                group by x.id, x.document_type, x.document_date, x.document_number            
                              )
                            , (select xmlelement("issuer"
                                       , xmlforest(
                                             x.client_id_type  as "client_id_type"
                                           , x.client_id_value as "client_id_value"
                                           , x.inst_id         as "inst_id"
                                         )
                                     )  
                                 from opr_participant x
                                where x.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER 
                                  and x.oper_id = o.id
                              )
                            , (select xmlelement("acquirer"
                                       , xmlforest(
                                             x.client_id_type  as "client_id_type"
                                           , x.client_id_value as "client_id_value"
                                           , x.inst_id         as "inst_id"
                                         )
                                     )  
                                 from opr_participant x
                                where x.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER 
                                  and x.oper_id = o.id
                              ) 
                            , (select xmlelement("destination"
                                       , xmlforest(
                                             x.client_id_type  as "client_id_type"
                                           , x.client_id_value as "client_id_value"
                                           , x.inst_id         as "inst_id"
                                         )
                                     )  
                                 from opr_participant x
                                where x.participant_type = com_api_const_pkg.PARTICIPANT_DEST 
                                  and x.oper_id = o.id
                              ) 
                            , (select xmlelement("aggregator"
                                       , xmlforest(
                                             x.client_id_type  as "client_id_type"
                                           , x.client_id_value as "client_id_value"
                                           , x.inst_id         as "inst_id"
                                         )
                                     ) 
                                 from opr_participant x
                                where x.participant_type = com_api_const_pkg.PARTICIPANT_AGGREGATOR 
                                  and x.oper_id = o.id
                              ) 
                            , (select xmlelement("service_provider"
                                       , xmlforest(
                                             x.client_id_type  as "client_id_type"
                                           , x.client_id_value as "client_id_value"
                                           , x.inst_id         as "inst_id"
                                         )
                                     )  
                                 from opr_participant x
                                where x.participant_type = com_api_const_pkg.PARTICIPANT_SERVICE_PROVIDER 
                                  and x.oper_id = o.id
                              ) 
                           )
                       )
                    ).getclobval()
               from opr_operation o
              where o.id in (select am.object_id
                               from acc_entry  ae
                                  , acc_macros am
                              where am.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                and am.id              = ae.macros_id
                                and ae.status         <> acc_api_const_pkg.ENTRY_STATUS_CANCELED
                                and ae.transaction_id in (select column_value from table(cast(l_transaction_id_tab as num_tab_tpt))));

    procedure save_file is
    begin
        l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

        prc_api_file_pkg.put_file(
            i_sess_file_id  => l_sess_file_id
          , i_clob_content  => l_file
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_sess_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count  => l_transaction_id_tab.count 
        );
                    
        trc_log_pkg.debug('file saved, cnt='||l_transaction_id_tab.count||', length='||length(l_file));
                                          
        prc_api_stat_pkg.log_current (
            i_current_count     => l_transaction_id_tab.count
            , i_excepted_count  => 0
        );
    end;
begin
    trc_log_pkg.debug(
        i_text          => 'Start transactions export: l_sysdate [#1], thread_number [#2], i_inst_id [#3]'
      , i_env_param1    => l_sysdate
      , i_env_param2    => prc_api_session_pkg.get_thread_number
      , i_env_param3    => i_inst_id
    );

    prc_api_stat_pkg.log_start;

    savepoint sp_transactions_export;
    
    select count(1)
         , min(event_timestamp)
         , max(event_timestamp)
      into l_estimated_count
         , l_start_date
         , l_end_date
      from (
            select ae.transaction_id
                 , o.id as event_object_id
                 , o.event_timestamp
              from evt_event_object o
                 , opr_operation oo
                 , acc_entry ae
                 , acc_macros am
             where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ACC_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TRANSACTIONS'
               and o.eff_date      <= l_sysdate
               and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
               and o.object_id      = ae.transaction_id
               and am.entity_type   = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and am.object_id     = oo.id
               and ae.macros_id     = am.id
               and ae.status       != acc_api_const_pkg.ENTRY_STATUS_CANCELED
               and (o.inst_id       = i_inst_id or i_inst_id is null)
           );        

    trc_log_pkg.debug(
        i_text =>'Estimate count = [' || l_estimated_count || ']'
    );
               
    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );
        
    open cu_event_objects;

    fetch cu_event_objects bulk collect into
          l_transaction_id_tab
        , l_event_tab
        , l_entry_id_tab
        , l_inst_id_tab
        , l_split_hash_tab;
        
    trc_log_pkg.debug(
        i_text =>'l_balance_id_tab.count = [' || l_transaction_id_tab.count || ']'
    );
    --generate xml
    if l_transaction_id_tab.count > 0 then
            
        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            , i_value    => i_inst_id
            , io_params  => l_params
        );

        set_ui_value_pkg.get_inst_by_param_n(
            i_param_name        => 'CBS_SETTLEMENT_FLAG'
          , o_inst_id           => g_inst_flag_tab
        );

        remain_active_inst_param(io_inst_flag_tab  => g_inst_flag_tab);

        if g_inst_flag_tab.count > 0 then
            for i in 1..l_entry_id_tab.count
            loop
                if g_inst_flag_tab.exists(l_inst_id_tab(i)) then
                    acc_api_entry_pkg.set_is_settled(
                        i_entry_id                  => l_entry_id_tab(i)
                      , i_is_settled                => com_api_const_pkg.FALSE
                      , i_inst_id                   => l_inst_id_tab(i)
                      , i_sttl_flag_date            => null
                      , i_split_hash                => l_split_hash_tab(i)
                    );
                end if;
            end loop;
        end if;

        prc_api_file_pkg.open_file(
            o_sess_file_id => l_sess_file_id
          , io_params      => l_params
        );

        open  main_xml_cur;
        fetch main_xml_cur into l_file;
        close main_xml_cur; 
                           
        save_file; 
                
        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab    => l_event_tab
        );                          

    end if;
            
    close cu_event_objects;    

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_estimated_count
      , i_excepted_total    => 0
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('Transactions exporting finished');

exception
    when others then
        rollback to sp_transactions_export;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_sess_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_sess_file_id
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

end process_unload_transactions;

procedure generate_transaction(
    i_operation_id          in     com_api_type_pkg.t_long_id
  , i_use_custom_method     in     com_api_type_pkg.t_boolean
  , o_xml_block                out nocopy com_api_type_pkg.t_lob_data
)
is
    l_method_name                  com_api_type_pkg.t_name := 'generate_transaction';
    l_label_name                   com_api_type_pkg.t_name := 'xml_block';

    l_entry_list_tab               t_entry_list_tab;
    l_index                        com_api_type_pkg.t_long_id;

    l_account_number               com_api_type_pkg.t_account_number;
    l_account_currency             com_api_type_pkg.t_dict_value;
    l_agent_number                 com_api_type_pkg.t_name;

    l_old_transaction_id           com_api_type_pkg.t_long_id;
    l_old_transaction_type         com_api_type_pkg.t_dict_value;
    l_old_amount_purpose           com_api_type_pkg.t_dict_value;
    l_old_conversion_rate          com_api_type_pkg.t_rate;
    l_old_rate_type                com_api_type_pkg.t_dict_value;
    l_old_posting_date             date;

    l_debit_entry                  com_api_type_pkg.t_lob_data;
    l_credit_entry                 com_api_type_pkg.t_lob_data;

    function get_entry_block(
        i_entry_rec    t_entry_rec
    ) return com_api_type_pkg.t_lob_data
    is
        l_result    com_api_type_pkg.t_lob_data;
    begin
        l_result := '<entry_id>'       || i_entry_rec.entry_id                      || '</entry_id>'
                 || '<status>'         || i_entry_rec.entry_status                  || '</status>'
                 || '<account>'
                 || '<account_number>' || l_account_number                          || '</account_number>'
                 || '<currency>'       || l_account_currency                        || '</currency>'
                 || '<balance_type>'   || i_entry_rec.balance_type                  || '</balance_type>'
                 || '<agent_number>'   || l_agent_number                            || '</agent_number>'
                 || '</account>'
                 || '<amount>'
                 || '<amount_value>'   || i_entry_rec.amount_value                  || '</amount_value>'
                 || '<currency>'       || i_entry_rec.entry_currency                || '</currency>'
                 || '</amount>'
                 || '<is_settled>'
                 || case check_inst_id(i_inst_id  => i_entry_rec.inst_id)
                        when com_api_const_pkg.TRUE
                        then i_entry_rec.is_settled
                        else null
                    end
                 || '</is_settled>';

        return l_result;
    end get_entry_block;

    function get_begin_transaction_block
    return com_api_type_pkg.t_lob_data
    is
        l_result    com_api_type_pkg.t_lob_data;
    begin
        l_result := '<transaction>'
                 || '<transaction_id>'        || l_old_transaction_id     || '</transaction_id>'
                 || '<transaction_type>'      || l_old_transaction_type   || '</transaction_type>'
                 || '<posting_date>'          || to_char(l_old_posting_date, com_api_const_pkg.XML_DATETIME_FORMAT) || '</posting_date>';

        return l_result;
    end get_begin_transaction_block;

    function get_end_transaction_block
    return com_api_type_pkg.t_lob_data
    is
        l_result    com_api_type_pkg.t_lob_data;
    begin
        l_result := case
                        when l_debit_entry is not null
                        then  '<debit_entry>' || l_debit_entry            || '</debit_entry>'
                    end
                 || case
                        when l_credit_entry is not null
                        then  '<credit_entry>' || l_credit_entry          || '</credit_entry>'
                    end
                 || case
                        when i_use_custom_method = com_api_type_pkg.TRUE
                        then cst_api_document_pkg.get_document_block(
                                 i_operation_id   => i_operation_id
                               , i_transaction_id => l_old_transaction_id
                             )
                        else null
                    end
                 || '<conversion_rate>' || coalesce(to_char(l_old_conversion_rate, com_api_const_pkg.XML_FLOAT_FORMAT), '1') || '</conversion_rate>'
                 || '<rate_type>'       || coalesce(l_old_rate_type,               com_api_const_pkg.CUST_RATE_TYPE)         || '</rate_type>'
                 || '<amount_purpose>'  || l_old_amount_purpose                                                              || '</amount_purpose>'
                 || '</transaction>';

        return l_result;
    end get_end_transaction_block;

begin
    prc_api_performance_pkg.start_performance_metric(
        i_method_name => l_method_name
      , i_label_name  => l_label_name
    );

    l_index := g_entry_by_oper_tab(i_operation_id).first;

    while l_index is not null loop
        l_entry_list_tab(l_entry_list_tab.count + 1) := g_entry_by_oper_tab(i_operation_id)(l_index);
        l_index := g_entry_by_oper_tab(i_operation_id).next(l_index);
    end loop;

    for i in 1 .. l_entry_list_tab.count loop

        -- All events for every single operation should be marked as processed
        g_event_object_id_tab.extend;
        g_event_object_id_tab(g_event_object_id_tab.count) := l_entry_list_tab(i).event_object_id;

        if l_entry_list_tab(i).transaction_id       = l_old_transaction_id
           and l_entry_list_tab(i).transaction_type = l_old_transaction_type
           and l_entry_list_tab(i).amount_purpose   = l_old_amount_purpose
           and l_entry_list_tab(i).conversion_rate  = l_old_conversion_rate
           and l_entry_list_tab(i).rate_type        = l_old_rate_type
        then
            l_old_posting_date     := least(l_old_posting_date, l_entry_list_tab(i).posting_date);
        else
            if l_old_transaction_id is not null then
                o_xml_block        := o_xml_block || get_end_transaction_block;
                l_debit_entry      := null;
                l_credit_entry     := null;
            end if;

            l_old_transaction_id   := l_entry_list_tab(i).transaction_id;
            l_old_transaction_type := l_entry_list_tab(i).transaction_type;
            l_old_amount_purpose   := l_entry_list_tab(i).amount_purpose;
            l_old_conversion_rate  := l_entry_list_tab(i).conversion_rate;
            l_old_rate_type        := l_entry_list_tab(i).rate_type;
            l_old_posting_date     := l_entry_list_tab(i).posting_date;

            o_xml_block            := o_xml_block || get_begin_transaction_block;
        end if;

        select a.account_number
             , a.currency
             , (select ag.agent_number from ost_agent ag where ag.id = a.agent_id)
          into l_account_number
             , l_account_currency
             , l_agent_number
          from acc_account a
         where a.id = l_entry_list_tab(i).account_id;

        if l_entry_list_tab(i).balance_impact = com_api_const_pkg.DEBIT then
            l_debit_entry      := l_debit_entry  || get_entry_block(i_entry_rec => l_entry_list_tab(i));

        elsif l_entry_list_tab(i).balance_impact = com_api_const_pkg.CREDIT then
            l_credit_entry     := l_credit_entry || get_entry_block(i_entry_rec => l_entry_list_tab(i));
        
        end if;

    end loop;

    if l_entry_list_tab.count > 0 then
        o_xml_block := o_xml_block || get_end_transaction_block;
    end if;

    prc_api_performance_pkg.finish_performance_metric(
        i_method_name => l_method_name
      , i_label_name  => l_label_name
    );

end generate_transaction;

procedure process_turnover_info(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_full_export                  in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_date_type                    in     com_api_type_pkg.t_dict_value
  , i_start_date                   in     date                              default null
  , i_end_date                     in     date                              default null
  , i_shift_from                   in     com_api_type_pkg.t_tiny_id        default 0
  , i_shift_to                     in     com_api_type_pkg.t_tiny_id        default 0
  , i_balance_type                 in     com_api_type_pkg.t_dict_value     default null
  , i_account_number               in     com_api_type_pkg.t_account_number default null
  , i_masking_card                 in     com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
  , i_load_reversals               in     com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE 
  , i_array_balance_type_id        in     com_api_type_pkg.t_medium_id      default null
  , i_array_trans_type_id          in     com_api_type_pkg.t_medium_id      default null
  , i_array_settl_type_id          in     com_api_type_pkg.t_medium_id      default null
  , i_use_matched_data             in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_use_custom_method            in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_include_auth                 in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_include_Visa_clearing        in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_include_MasterCard_clearing  in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_include_document             in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_lang                         in     com_api_type_pkg.t_dict_value     default null 
  , i_count                        in     com_api_type_pkg.t_medium_id      default null
  , i_include_payment_order        in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_include_note                 in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_include_additional_amount    in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_include_canceled_entries     in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
) is
    BULK_LIMIT            constant com_api_type_pkg.t_count     := 2000;
    l_bulk_limit                   com_api_type_pkg.t_count     := nvl(i_count, BULK_LIMIT);
    cur_objects                    sys_refcursor;
    l_file                         clob;

    l_fetched_event_object_id_tab  num_tab_tpt                 := num_tab_tpt();
    l_fetched_entry_id_tab         num_tab_tpt                 := num_tab_tpt();
    l_fetched_oper_id_tab          num_tab_tpt                 := num_tab_tpt();
    l_fetched_inst_id_tab          num_tab_tpt                 := num_tab_tpt();
    l_fetched_split_hash_tab       num_tab_tpt                 := num_tab_tpt();

    l_entry_id_tab                 num_tab_tpt                 := num_tab_tpt();
    l_oper_id_tab                  num_tab_tpt                 := num_tab_tpt();
    l_inst_id_tab                  num_tab_tpt                 := num_tab_tpt();
    l_split_hash_tab               num_tab_tpt                 := num_tab_tpt();
    l_current_oper_id              com_api_type_pkg.t_long_id;
    l_last_oper_id                 com_api_type_pkg.t_long_id;

    l_fetched_transaction_id_tab   num_tab_tpt                  := num_tab_tpt();
    l_fetched_transaction_type_tab com_dict_tpt                 := com_dict_tpt();
    l_fetched_posting_date_tab     date_tab_tpt                 := date_tab_tpt();
    l_fetched_amount_purpose_tab   com_dict_tpt                 := com_dict_tpt();
    l_fetched_conversion_rate_tab  num_tab_tpt                  := num_tab_tpt();
    l_fetched_rate_type_tab        com_dict_tpt                 := com_dict_tpt();
    l_fetched_balance_impact_tab   num_tab_tpt                  := num_tab_tpt();
    l_fetched_sttl_date_tab        date_tab_tpt                 := date_tab_tpt();
    l_fetched_posting_order_tab    num_tab_tpt                  := num_tab_tpt();
    l_fetched_sttl_day_tab         num_tab_tpt                  := num_tab_tpt();
    l_fetched_account_id_tab       num_tab_tpt                  := num_tab_tpt();
    l_fetched_amount_value_tab     num_tab_tpt                  := num_tab_tpt();
    l_fetched_entry_currency_tab   com_dict_tpt                 := com_dict_tpt();
    l_fetched_is_settled_tab       num_tab_tpt                  := num_tab_tpt();

    l_estimated_count              com_api_type_pkg.t_long_id;
    l_processed_count              com_api_type_pkg.t_long_id   := 0;
    l_total_file_count             com_api_type_pkg.t_count     := 0;
    l_thread_number                com_api_type_pkg.t_tiny_id;

    l_masking_card                 com_api_type_pkg.t_boolean   := nvl(i_masking_card,             com_api_const_pkg.TRUE);
    l_use_matched_data             com_api_type_pkg.t_boolean   := nvl(i_use_matched_data,         com_api_const_pkg.FALSE);
    l_use_custom_method            com_api_type_pkg.t_boolean   := nvl(i_use_custom_method,        com_api_const_pkg.FALSE);
    l_include_canceled_entries     com_api_type_pkg.t_boolean   := nvl(i_include_canceled_entries, com_api_const_pkg.FALSE);
    l_array_balance_type_id        com_api_type_pkg.t_medium_id := nvl(i_array_balance_type_id,    12);

    l_session_file_id              com_api_type_pkg.t_long_id;
    l_sysdate                      date;
    l_start_date                   date;
    l_end_date                     date;
    l_file_type                    com_api_type_pkg.t_dict_value;
    l_container_id                 com_api_type_pkg.t_long_id;
    l_account_id                   com_api_type_pkg.t_account_id;
    l_balance_type                 com_api_type_pkg.t_dict_value;
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_params                       com_api_type_pkg.t_param_tab;
    l_lang                         com_api_type_pkg.t_dict_value;

    l_load_reversed                com_api_type_pkg.t_boolean;
    l_full_export                  com_api_type_pkg.t_boolean;
    l_masking_card_in_file         com_api_type_pkg.t_boolean;

    l_include_Visa_clearing        com_api_type_pkg.t_boolean;
    l_include_MasterCard_clearing  com_api_type_pkg.t_boolean;
    l_include_auth                 com_api_type_pkg.t_boolean;
    l_include_document             com_api_type_pkg.t_boolean;
    l_include_payment_order        com_api_type_pkg.t_boolean;
    l_include_note                 com_api_type_pkg.t_boolean;
    l_include_additional_amount    com_api_type_pkg.t_boolean;

    cursor cur_xml is
        select
            g.oper_id
          , xmlconcat(
                xmlelement("oper_id",          g.oper_id)
              , xmlelement("oper_type",        g.oper_type)
              , xmlelement("msg_type",         g.msg_type)
              , xmlelement("sttl_type",        g.sttl_type)
              , xmlelement("oper_date",        to_char(g.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT))
              , xmlelement("host_date",        to_char(g.host_date, com_api_const_pkg.XML_DATETIME_FORMAT))
              , xmlelement("oper_amount"
                  , xmlelement("amount_value", g.oper_amount)
                  , xmlelement("currency",     g.oper_currency)
                )
              , (select xmlagg(
                            xmlelement("oper_cashback_amount"
                              , xmlelement("amount_value", g.oper_cashback_amount)
                              , xmlelement("currency", g.oper_currency)
                            )
                        )
                   from dual
                  where g.oper_cashback_amount is not null
                )
              , (select xmlagg(
                            xmlelement("sttl_amount"
                              , xmlelement("amount_value", g.sttl_amount)
                              , xmlelement("currency",     g.sttl_currency)
                            )
                        )
                   from dual
                  where g.sttl_amount   is not null
                    and g.sttl_currency is not null
                )
              , xmlelement("originator_refnum"
                         , coalesce(
                               g.originator_refnum
                             , case
                                   when l_use_matched_data  = com_api_const_pkg.TRUE
                                        and g.match_id     is not null
                                   then (
                                            -- The Visa incoming clearing file does not contain value of "originator_refnum"
                                            -- for presentments like TC05 therefore get "originator_refnum" from matched authorization.
                                            select auth.originator_refnum
                                              from opr_operation auth
                                             where auth.id  = g.match_id
                                        )
                                   else null
                               end
                           )
                )
              , xmlelement("network_refnum",    g.network_refnum)
              , nvl2(g.response_code,           xmlelement("response_code",           g.response_code),           null)
              , nvl2(g.merchant_number,         xmlelement("merchant_number",         g.merchant_number),         null)
              , nvl2(g.mcc,                     xmlelement("mcc",                     g.mcc),                     null)
              , nvl2(g.merchant_name,           xmlelement("merchant_name",           g.merchant_name),           null)
              , nvl2(g.merchant_street,         xmlelement("merchant_street",         g.merchant_street),         null)
              , nvl2(g.merchant_city,           xmlelement("merchant_city",           g.merchant_city),           null)
              , nvl2(g.merchant_country,        xmlelement("merchant_country",        g.merchant_country),        null)
              , nvl2(g.terminal_type,           xmlelement("terminal_type",           g.terminal_type),           null)
              , nvl2(g.terminal_number,         xmlelement("terminal_number",         g.terminal_number),         null)
              , nvl2(g.clearing_sequence_num,   xmlelement("clearing_sequence_num",   g.clearing_sequence_num),   null)
              , nvl2(g.clearing_sequence_count, xmlelement("clearing_sequence_count", g.clearing_sequence_count), null)
                --
              , case when l_include_payment_order = com_api_const_pkg.TRUE
                     then
                    (select
                     xmlelement("payment_order"
                       , xmlforest(
                             po.id                    as "payment_order_id"
                           , po.status                as "payment_order_status"
                           , po.purpose_id            as "purpose_id"
                           , pp.purpose_number        as "purpose_number"
                           , xmlforest(
                                 po.amount            as "amount_value"
                               , po.currency          as "currency"
                             ) as "payment_amount"
                           , to_char(po.event_date, com_api_const_pkg.XML_DATETIME_FORMAT)
                                                      as "payment_date"
                         )
                       , (select xmlagg(
                                     xmlelement("payment_parameter"
                                       , xmlforest(
                                             xp.param_name    as "payment_parameter_name"
                                           , xod.param_value  as "payment_parameter_value"
                                         )
                                     ) 
                                 )
                            from pmo_parameter xp
                            join pmo_order_data xod on xod.param_id = xp.id
                           where xod.order_id = po.id
                         ) -- payment_parameter
                       , (select xmlagg(
                                     xmlelement("document"
                                       , xmlelement("document_id",               d.id)
                                       , xmlelement("document_type",             d.document_type)
                                       , xmlelement("document_date",             to_char(d.document_date, com_api_const_pkg.XML_DATE_FORMAT))
                                       , xmlelement("document_number",           d.document_number)
                                       , xmlagg(
                                             case when dc.document_content is not null then
                                                 xmlelement("document_content"
                                                    , xmlelement("content_type", dc.content_type)
                                                    , xmlelement("content",      com_api_hash_pkg.base64_encode(dc.document_content))
                                                 )
                                             end
                                         )
                                     ) -- document
                                 )
                            from rpt_document d
                            left join rpt_document_content dc on dc.document_id = d.id
                           where d.object_id   = po.id
                             and d.entity_type = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
                           group by
                                 d.id
                               , d.document_type
                               , d.document_date
                               , d.document_number
                         ) -- document
                     ) -- payment_order
                  from pmo_order po
                  left join pmo_purpose pp on pp.id = po.purpose_id
                 where po.id = g.payment_order_id
                )
                end
                --
              , case when l_include_document = com_api_const_pkg.TRUE
                     then
                    (select xmlagg(
                                xmlelement("document"
                                  , xmlelement("document_id",              d.id)
                                  , xmlelement("document_type",            d.document_type)
                                  , xmlelement("document_date",            to_char(d.document_date, com_api_const_pkg.XML_DATE_FORMAT))
                                  , xmlelement("document_number",          d.document_number)
                                  , xmlagg(
                                        case when dc.document_content is not null then
                                            xmlelement("document_content"
                                              , xmlelement("content_type", dc.content_type)
                                              , xmlelement("content",      com_api_hash_pkg.base64_encode(dc.document_content))
                                            )
                                        end
                                    )
                                )
                            )
                       from rpt_document d
                       left join rpt_document_content dc on dc.document_id = d.id
                      where d.object_id   = g.oper_id
                        and d.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      group by
                            d.id
                          , d.document_type
                          , d.document_date
                          , d.document_number
                    ) 
                    end
              , (select xmlforest(
                            xmlforest(
                                b.client_id_type          as "client_id_type"
                              , b.client_id_value         as "client_id_value"
                              , (case when l_masking_card_in_file = com_api_const_pkg.TRUE
                                       and l_masking_card         = com_api_const_pkg.TRUE
                                      then (select iss_api_card_pkg.get_card_mask(i_card_number => 
                                                       iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
                                                   )
                                              from opr_card c
                                             where c.oper_id = b.oper_id
                                           )
                                      when l_masking_card         = com_api_const_pkg.TRUE
                                      then b.card_mask
                                      else (select iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
                                              from opr_card c
                                              where c.oper_id = b.oper_id
                                           )
                                      end
                                )                         as "card_number"
                              , b.card_id                 as "card_id"
                              , b.card_seq_number         as "card_seq_number"
                              , b.card_expir_date         as "card_expir_date"
                              , b.inst_id                 as "inst_id"
                              , (select a.agent_number
                                   from iss_card     c
                                      , prd_contract p
                                      , ost_agent    a
                                  where c.id         = b.card_id
                                    and c.split_hash = b.split_hash
                                    and p.id         = c.contract_id
                                    and p.split_hash = c.split_hash
                                    and a.id         = p.agent_id
                                )                         as "agent_number"
                              , b.network_id              as "network_id"
                              , b.auth_code               as "auth_code"
                            ) as "issuer"
                        )
                   from opr_participant b
                  where b.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                    and b.oper_id          = g.oper_id
                )
              , (select xmlforest(
                            xmlforest(
                                a.client_id_type          as "client_id_type"
                              , a.client_id_value         as "client_id_value"
                              , a.inst_id                 as "inst_id"
                              , a.network_id              as "network_id"
                              , a.account_number          as "account_number"
                              , a.account_amount          as "account_amount"
                              , a.account_currency        as "account_currency"
                              , a.auth_code               as "auth_code"
                            ) as "acquirer"
                        )
                   from opr_participant a
                  where a.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                    and a.oper_id          = g.oper_id
                )
                --
              , case when l_include_note = com_api_const_pkg.TRUE
                     then
                    (select xmlagg(
                            xmlelement("note"
                              , xmlelement("note_type", n.note_type)
                              , xmlagg(
                                    xmlelement("note_content"
                                      , xmlattributes(l.lang as "language")
                                      , xmlforest(
                                            com_api_i18n_pkg.get_text(
                                                i_table_name  => 'ntb_note'
                                              , i_column_name => 'header'
                                              , i_object_id   => n.id
                                              , i_lang        => l.lang
                                            ) as "note_header"
                                          , com_api_i18n_pkg.get_text(
                                                i_table_name  => 'ntb_note'
                                              , i_column_name => 'text'
                                              , i_object_id   => n.id
                                              , i_lang        => l.lang
                                            ) as "note_text"
                                        )
                                    )
                                )
                            )
                        )
                   from ntb_note n
                      , com_language_vw l
                  where n.object_id   = g.oper_id
                    and n.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                    and l.lang        = l_lang
               group by n.note_type
                )
                end
                --
              , case when l_include_auth = com_api_const_pkg.TRUE
                     then
                     (select
                          xmlagg(
                              xmlelement("auth_data"
                                , xmlforest(
                                      a.resp_code                             as "resp_code"
                                    , a.proc_type                             as "proc_type"
                                    , a.proc_mode                             as "proc_mode"
                                    , to_char(a.is_advice, com_api_const_pkg.XML_NUMBER_FORMAT)           as "is_advice"
                                    , to_char(a.is_repeat, com_api_const_pkg.XML_NUMBER_FORMAT)           as "is_repeat"
                                    , to_char(a.bin_amount, com_api_const_pkg.XML_NUMBER_FORMAT)          as "bin_amount"
                                    , a.bin_currency                          as "bin_currency"
                                    , to_char(a.bin_cnvt_rate, com_api_const_pkg.XML_NUMBER_FORMAT)       as "bin_cnvt_rate"
                                    , to_char(a.network_amount, com_api_const_pkg.XML_NUMBER_FORMAT)      as "network_amount"
                                    , a.network_currency                      as "network_currency"
                                    , to_char(a.network_cnvt_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "network_cnvt_date"
                                    , to_char(a.account_cnvt_rate, com_api_const_pkg.XML_NUMBER_FORMAT)   as "account_cnvt_rate"
                                    , a.addr_verif_result                     as "addr_verif_result"
                                    , a.acq_resp_code                         as "acq_resp_code"
                                    , a.acq_device_proc_result                as "acq_device_proc_result"
                                    , a.cat_level                             as "cat_level"
                                    , a.card_data_input_cap                   as "card_data_input_cap"
                                    , a.crdh_auth_cap                         as "crdh_auth_cap"
                                    , a.card_capture_cap                      as "card_capture_cap"
                                    , a.terminal_operating_env                as "terminal_operating_env"
                                    , a.crdh_presence                         as "crdh_presence"
                                    , a.card_presence                         as "card_presence"
                                    , a.card_data_input_mode                  as "card_data_input_mode"
                                    , a.crdh_auth_method                      as "crdh_auth_method"
                                    , a.crdh_auth_entity                      as "crdh_auth_entity"
                                    , a.card_data_output_cap                  as "card_data_output_cap"
                                    , a.terminal_output_cap                   as "terminal_output_cap"
                                    , a.pin_capture_cap                       as "pin_capture_cap"
                                    , a.pin_presence                          as "pin_presence"
                                    , a.cvv2_presence                         as "cvv2_presence"
                                    , a.cvc_indicator                         as "cvc_indicator"
                                    , a.pos_entry_mode                        as "pos_entry_mode"
                                    , a.pos_cond_code                         as "pos_cond_code"
                                    , a.emv_data                              as "emv_data"
                                    , a.atc                                   as "atc"
                                    , a.tvr                                   as "tvr"
                                    , a.cvr                                   as "cvr"
                                    , a.addl_data                             as "addl_data"
                                    , a.service_code                          as "service_code"
                                    , a.device_date                           as "device_date"
                                    , a.cvv2_result                           as "cvv2_result"
                                    , a.certificate_method                    as "certificate_method"
                                    , a.merchant_certif                       as "merchant_certif"
                                    , a.cardholder_certif                     as "cardholder_certif"
                                    , a.ucaf_indicator                        as "ucaf_indicator"
                                    , to_char(a.is_early_emv, com_api_const_pkg.XML_NUMBER_FORMAT)        as "is_early_emv"
                                    , a.is_completed                          as "is_completed"
                                    , a.amounts                               as "amounts"
                                    , a.agent_unique_id                       as "agent_unique_id"
                                    , a.external_auth_id                      as "external_auth_id"
                                    , a.external_orig_id                      as "external_orig_id"
                                    , a.auth_purpose_id                       as "auth_purpose_id"
                                    , a.system_trace_audit_number             as "system_trace_audit_number"
                                    , a.transaction_id                        as "auth_transaction_id"
                                  )
                                , (select
                                       xmlagg(
                                           xmlelement("auth_tag"
                                             , xmlelement("tag_id",     t.tag)
                                             , xmlelement("tag_value",  v.tag_value)
                                             , xmlelement("tag_name",   t.reference)
                                             , xmlelement("seq_number", v.seq_number)
                                           )
                                       )
                                     from aup_tag t
                                        , aup_tag_value v
                                    where v.tag_id  = t.tag
                                      and v.auth_id = a.id
                                  )
                              )
                          )
                       from aut_auth a
                      where a.id = g.oper_id
                     )
                end
                --
              , case when l_include_MasterCard_clearing = com_api_const_pkg.TRUE
                     then (
                         select
                             xmlforest(
                                 xmlforest(
                                     to_char(m.is_incoming, com_api_const_pkg.XML_NUMBER_FORMAT) as "is_incoming"
                                   , to_char(m.is_reversal, com_api_const_pkg.XML_NUMBER_FORMAT) as "is_reversal"
                                   , to_char(m.is_rejected, com_api_const_pkg.XML_NUMBER_FORMAT) as "is_rejected"
                                   , to_char(m.impact, com_api_const_pkg.XML_NUMBER_FORMAT)      as "impact"
                                   , m.mti              as "mti"
                                   , m.de024            as "de024"
                                   , m.de002            as "de002"
                                   , m.de003_1          as "de003_1"
                                   , m.de003_2          as "de003_2"
                                   , m.de003_3          as "de003_3"
                                   , to_char(m.de004, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de004"
                                   , to_char(m.de005, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de005"
                                   , to_char(m.de006, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de006"
                                   , m.de009            as "de009"
                                   , m.de010            as "de010"
                                   , to_char(m.de012, com_api_const_pkg.XML_DATETIME_FORMAT)     as "de012"
                                   , to_char(m.de014, com_api_const_pkg.XML_DATETIME_FORMAT)     as "de014" 
                                   , m.de022_1          as "de022_1"
                                   , m.de022_2          as "de022_2"
                                   , m.de022_3          as "de022_3"
                                   , m.de022_4          as "de022_4"     
                                   , m.de022_5          as "de022_5"
                                   , m.de022_6          as "de022_6"
                                   , m.de022_7          as "de022_7"
                                   , m.de022_8          as "de022_8"
                                   , m.de022_9          as "de022_9" 
                                   , m.de022_10         as "de022_10"
                                   , m.de022_11         as "de022_11"
                                   , m.de022_12         as "de022_12"
                                   , to_char(m.de023, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de023"
                                   , m.de025            as "de025"
                                   , m.de026            as "de026"
                                   , to_char(m.de030_1, com_api_const_pkg.XML_NUMBER_FORMAT)     as "de030_1"
                                   , to_char(m.de030_2, com_api_const_pkg.XML_NUMBER_FORMAT)     as "de030_2"
                                   , m.de031            as "de031"
                                   , m.de032            as "de032"
                                   , m.de033            as "de033"
                                   , m.de037            as "de037"
                                   , m.de038            as "de038"
                                   , m.de040            as "de040"
                                   , m.de041            as "de041"
                                   , m.de042            as "de042"
                                   , m.de043_1          as "de043_1"
                                   , m.de043_2          as "de043_2"
                                   , m.de043_3          as "de043_3"
                                   , m.de043_4          as "de043_4"
                                   , m.de043_5          as "de043_5"
                                   , m.de043_6          as "de043_6"
                                   , m.de049            as "de049"
                                   , m.de050            as "de050"
                                   , m.de051            as "de051"
                                   , m.de054            as "de054"
                                   , m.de055            as "de055"
                                   , m.de063            as "de063"
                                   , to_char(m.de071, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de071"
                                   , regexp_replace(m.de072, '[[:cntrl:]]', null)                as "de072"
                                   , to_char(m.de073, com_api_const_pkg.XML_DATETIME_FORMAT)     as "de073"
                                   , m.de093            as "de093"
                                   , m.de094            as "de094"
                                   , m.de095            as "de095"
                                   , m.de100            as "de100"
                                   , to_char(m.de111, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de111"
                                   , m.p0002            as "p0002"
                                   , m.p0023            as "p0023"
                                   , m.p0025_1          as "p0025_1"
                                   , to_char(m.p0025_2, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0025_2"
                                   , m.p0043            as "p0043"
                                   , m.p0052            as "p0052"
                                   , m.p0137            as "p0137"
                                   , m.p0148            as "p0148"
                                   , m.p0146            as "p0146"
                                   , to_char(m.p0146_net, com_api_const_pkg.XML_NUMBER_FORMAT)   as "p0146_net"
                                   , m.p0147            as "p0147"
                                   , m.p0149_1          as "p0149_1"
                                   , lpad(m.p0149_2, 3, '0') as "p0149_2"
                                   , m.p0158_1          as "p0158_1"
                                   , m.p0158_2          as "p0158_2"
                                   , m.p0158_3          as "p0158_3"           
                                   , m.p0158_4          as "p0158_4"
                                   , to_char(m.p0158_5, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0158_5"
                                   , to_char(m.p0158_6, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0158_6"
                                   , m.p0158_7          as "p0158_7"
                                   , m.p0158_8          as "p0158_8"
                                   , m.p0158_9          as "p0158_9"
                                   , m.p0158_10         as "p0158_10"
                                   , m.p0159_1          as "p0159_1"
                                   , m.p0159_2          as "p0159_2"
                                   , to_char(m.p0159_3, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0159_3"
                                   , m.p0159_4          as "p0159_4"
                                   , m.p0159_5          as "p0159_5"
                                   , to_char(m.p0159_6, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0159_6"
                                   , to_char(m.p0159_7, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0159_7"
                                   , to_char(m.p0159_8, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0159_8"
                                   , to_char(m.p0159_9, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0159_9"
                                   , m.p0165            as "p0165"
                                   , m.p0176            as "p0176"
                                   , to_char(m.p0228, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0228" 
                                   , to_char(m.p0230, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0230"
                                   , m.p0241            as "p0241"
                                   , m.p0243            as "p0243"
                                   , m.p0244            as "p0244"
                                   , m.p0260            as "p0260"
                                   , to_char(m.p0261, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0261"
                                   , to_char(m.p0262, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0262"
                                   , to_char(m.p0264, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0264"
                                   , m.p0265            as "p0265"
                                   , m.p0266            as "p0266"
                                   , m.p0267            as "p0267"
                                   , to_char(m.p0268_1, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0268_1"
                                   , m.p0268_2          as "p0268_2"
                                   , m.p0375            as "p0375"
                                   , m.emv_9f26         as "emv_9f26"
                                   , to_char(m.emv_9f02, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f02"
                                   , m.emv_9f27         as "emv_9f27"
                                   , m.emv_9f10         as "emv_9f10"
                                   , m.emv_9f36         as "emv_9f36"
                                   , m.emv_95           as "emv_95"
                                   , m.emv_82           as "emv_82"
                                   , to_char(m.emv_9a, com_api_const_pkg.XML_DATETIME_FORMAT)    as "emv_9a"
                                   , to_char(m.emv_9c, com_api_const_pkg.XML_NUMBER_FORMAT)      as "emv_9c"
                                   , m.emv_9f37         as "emv_9f37"
                                   , to_char(m.emv_5f2a, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_5f2a"
                                   , m.emv_9f33         as "emv_9f33"
                                   , m.emv_9f34         as "emv_9f34"
                                   , to_char(m.emv_9f1a, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f1a"
                                   , to_char(m.emv_9f35, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f35"
                                   , m.emv_9f53         as "emv_9f53"
                                   , m.emv_84           as "emv_84"
                                   , m.emv_9f09         as "emv_9f09"
                                   , to_char(m.emv_9f03, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f03"
                                   , m.emv_9f1e         as "emv_9f1e"
                                   , to_char(m.emv_9f41, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f41"
                                   , m.p0042            as "p0042"
                                   , m.p0158_11         as "p0158_11"
                                   , m.p0158_12         as "p0158_12"
                                   , m.p0158_13         as "p0158_13"
                                   , m.p0158_14         as "p0158_14"
                                   , m.p0198            as "p0198"
                                   , to_char(m.p0200_1, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0200_1"
                                   , to_char(m.p0200_2, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0200_2"
                                   , m.p0210_1          as "p0210_1"
                                   , m.p0210_2          as "p0210_2"                                   
                                 ) as "ipm_data" -- xmlforest
                             ) -- xmlforest
                          from mcw_fin m
                         where m.id = g.oper_id
                    )
                end
                --   
              , case when l_include_Visa_clearing = com_api_const_pkg.TRUE
                     then (
                         select
                             xmlforest(
                                 xmlforest(
                                     to_char(v.is_reversal, com_api_const_pkg.XML_NUMBER_FORMAT)    as "is_reversal"
                                   , to_char(v.is_incoming, com_api_const_pkg.XML_NUMBER_FORMAT)    as "is_incoming"
                                   , to_char(v.is_returned, com_api_const_pkg.XML_NUMBER_FORMAT)    as "is_returned"
                                   , to_char(v.is_invalid, com_api_const_pkg.XML_NUMBER_FORMAT)     as "is_invalid"
                                   , v.rrn                    as "rrn"
                                   , v.trans_code             as "trans_code"
                                   , v.trans_code_qualifier   as "trans_code_qualifier"
                                   , v.card_mask              as "card_mask"
                                   , to_char(v.oper_amount, com_api_const_pkg.XML_NUMBER_FORMAT)    as "oper_amount"
                                   , v.oper_currency          as "oper_currency"
                                   , to_char(v.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT)    as "oper_date"
                                   , to_char(v.sttl_amount, com_api_const_pkg.XML_NUMBER_FORMAT)    as "sttl_amount"
                                   , v.sttl_currency          as "sttl_currency"
                                   , to_char(v.network_amount, com_api_const_pkg.XML_NUMBER_FORMAT) as "network_amount"
                                   , v.network_currency       as "network_currency"
                                   , v.floor_limit_ind        as "floor_limit_ind"
                                   , v.exept_file_ind         as "exept_file_ind"
                                   , v.pcas_ind               as "pcas_ind"
                                   , v.arn                    as "arn"
                                   , v.acquirer_bin           as "acquirer_bin"
                                   , v.acq_business_id        as "acq_business_id"
                                   , v.merchant_name          as "merchant_name"
                                   , v.merchant_city          as "merchant_city"
                                   , v.merchant_country       as "merchant_country"
                                   , v.merchant_postal_code   as "merchant_postal_code"
                                   , v.merchant_region        as "merchant_region"
                                   , v.merchant_street        as "merchant_street"
                                   , v.mcc                    as "mcc"
                                   , v.req_pay_service        as "req_pay_service"
                                   , v.usage_code             as "usage_code"
                                   , v.reason_code            as "reason_code"
                                   , v.settlement_flag        as "settlement_flag"
                                   , v.auth_char_ind          as "auth_char_ind"
                                   , v.auth_code              as "auth_code"
                                   , v.pos_terminal_cap       as "pos_terminal_cap"
                                   , v.inter_fee_ind          as "inter_fee_ind"
                                   , v.crdh_id_method         as "crdh_id_method"
                                   , v.collect_only_flag      as "collect_only_flag"
                                   , v.pos_entry_mode         as "pos_entry_mode"
                                   , v.central_proc_date      as "central_proc_date"
                                   , v.reimburst_attr         as "reimburst_attr"
                                   , v.iss_workst_bin         as "iss_workst_bin"
                                   , v.acq_workst_bin         as "acq_workst_bin"
                                   , v.chargeback_ref_num     as "chargeback_ref_num"
                                   , v.docum_ind              as "docum_ind"
                                   , v.member_msg_text        as "member_msg_text"
                                   , v.spec_cond_ind          as "spec_cond_ind"
                                   , v.fee_program_ind        as "fee_program_ind"
                                   , v.issuer_charge          as "issuer_charge"
                                   , v.merchant_number        as "merchant_number"
                                   , v.terminal_number        as "terminal_number"
                                   , v.national_reimb_fee     as "national_reimb_fee"
                                   , v.electr_comm_ind        as "electr_comm_ind"
                                   , v.spec_chargeback_ind    as "spec_chargeback_ind"
                                   , v.interface_trace_num    as "interface_trace_num"
                                   , v.unatt_accept_term_ind  as "unatt_accept_term_ind"
                                   , v.prepaid_card_ind       as "prepaid_card_ind"
                                   , v.service_development    as "service_development"
                                   , v.avs_resp_code          as "avs_resp_code"
                                   , v.auth_source_code       as "auth_source_code"
                                   , v.purch_id_format        as "purch_id_format"
                                   , v.account_selection      as "account_selection"
                                   , v.installment_pay_count  as "installment_pay_count"
                                   , v.purch_id               as "purch_id"
                                   , v.cashback               as "cashback"
                                   , v.chip_cond_code         as "chip_cond_code"
                                   , v.pos_environment        as "pos_environment"
                                   , v.transaction_type       as "transaction_type"
                                   , v.card_seq_number        as "card_seq_number"
                                   , v.terminal_profile       as "terminal_profile"
                                   , v.unpredict_number       as "unpredict_number"
                                   , v.appl_trans_counter     as "appl_trans_counter"
                                   , v.appl_interch_profile   as "appl_interch_profile"
                                   , v.cryptogram             as "cryptogram"
                                   , v.term_verif_result      as "term_verif_result"
                                   , v.cryptogram_amount      as "cryptogram_amount"
                                   , v.card_verif_result      as "card_verif_result"
                                   , v.issuer_appl_data       as "issuer_appl_data"
                                   , v.issuer_script_result   as "issuer_script_result"
                                   , v.card_expir_date        as "card_expir_date"
                                   , v.cryptogram_version     as "cryptogram_version"
                                   , v.cvv2_result_code       as "cvv2_result_code"
                                   , v.auth_resp_code         as "auth_resp_code"
                                   , v.cryptogram_info_data   as "cryptogram_info_data"
                                   , v.transaction_id         as "transaction_id"
                                   , v.merchant_verif_value   as "merchant_verif_value"
                                   , v.proc_bin               as "proc_bin"
                                   , v.chargeback_reason_code as "chargeback_reason_code"
                                   , v.destination_channel    as "destination_channel"
                                   , v.source_channel         as "source_channel"
                                   , v.acq_inst_bin           as "acq_inst_bin"
                                   , v.spend_qualified_ind    as "spend_qualified_ind"
                                   , v.service_code           as "service_code"
                                   , v.product_id             as "product_id"
                                 ) as "baseII_data" -- xmlforest
                             ) -- xmlforest
                          from vis_fin_message v
                         where v.id = g.oper_id
                    )
                end
                --
              , case when l_include_additional_amount = com_api_const_pkg.TRUE
                     then (
                        select xmlagg(
                            xmlelement("additional_amount"
                              , xmlelement("amount_value", a.amount)
                              , xmlelement("currency",     a.currency)
                              , xmlelement("amount_type",  a.amount_type)
                            )
                        )
                   from opr_additional_amount a
                  where a.oper_id = g.oper_id
                    and a.amount is not null
                )
                end
            ).getclobval()
          from (
              select o.id as oper_id
                   , o.oper_type
                   , o.msg_type
                   , o.sttl_type
                   , o.oper_date
                   , o.host_date
                   , o.oper_amount
                   , o.oper_currency
                   , o.sttl_amount
                   , o.sttl_currency
                   , o.originator_refnum
                   , o.network_refnum
                   , o.status_reason as response_code
                   , o.merchant_number
                   , o.mcc
                   , o.merchant_name
                   , o.merchant_street
                   , o.merchant_city
                   , o.merchant_country
                   , o.terminal_type
                   , o.terminal_number
                   , o.clearing_sequence_num
                   , o.clearing_sequence_count
                   , o.match_id
                   , o.payment_order_id
                   , o.oper_cashback_amount
              from opr_operation o
             where o.id in (select/*+ cardinality(ids 10) */ column_value from table(cast(l_oper_id_tab as num_tab_tpt)) ids)
             order by o.id
          ) g;

    -- Function returns a reference for a cursor with operations being processed.
    -- In case of incremental unloading it also returns event objects' identifiers.
    procedure open_cur_objects(
        o_cursor                   out sys_refcursor
    ) is
    begin
        trc_log_pkg.debug('Opening a cursor for all operations those are processed...');

        if l_account_id is null
           and l_full_export = com_api_const_pkg.FALSE
        then
            -- It's the query plan for case when l_account_id is null and incremental export.
            open o_cursor for
                select /*+ ordered use_nl(sm, eo, f, m, o) full(sm) index(eo evt_event_object_status) index(f acc_entry_transaction_ndx) index(m acc_macros_pk) index(o opr_operation_pk) */
                       eo.id
                     , f.id
                     , o.id
                     , eo.inst_id
                     , eo.split_hash
                     , f.transaction_id
                     , f.transaction_type
                     , f.posting_date
                     , m.amount_purpose
                     , m.conversion_rate
                     , m.rate_type
                     , f.balance_impact
                     , f.sttl_date
                     , f.posting_order
                     , f.sttl_day
                     , f.account_id
                     , f.amount
                     , f.currency
                     , f.is_settled
                  from com_split_map    sm
                     , evt_event_object eo
                     , acc_entry        f
                     , acc_macros       m
                     , opr_operation    o
                 where l_account_id     is null
                   and l_full_export     = com_api_const_pkg.FALSE
                   and l_thread_number  in (sm.thread_number, prc_api_const_pkg.DEFAULT_THREAD)
                   and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'ACC_PRC_ACCOUNT_EXPORT_PKG.PROCESS_TURNOVER_INFO'
                   and decode(eo.status, 'EVST0001', eo.split_hash,     null) = sm.split_hash
                   and eo.entity_type    = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
                   and eo.eff_date      <= l_sysdate
                   and l_inst_id        in (eo.inst_id, ost_api_const_pkg.DEFAULT_INST)
                   and f.transaction_id  = eo.object_id
                   and (f.status        != acc_api_const_pkg.ENTRY_STATUS_CANCELED or l_include_canceled_entries = com_api_const_pkg.TRUE)
                   and f.split_hash      = eo.split_hash
                   and m.id              = f.macros_id
                   and m.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                   and o.id              = m.object_id
                   and decode(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING, f.posting_date
                                         , com_api_const_pkg.DATE_PURPOSE_BANK,       f.sttl_date, null) between l_start_date and l_end_date
                   and (
                        l_balance_type = 'NONE' and f.balance_type in (select element_value from com_array_element where array_id = l_array_balance_type_id)
                        or
                        l_balance_type in (f.balance_type, '%')
                       )
                   and (l_load_reversed = com_api_const_pkg.TRUE
                        or
                        l_load_reversed = com_api_const_pkg.FALSE
                        and (
                            o.is_reversal = 1
                            and not exists (select /*+ ordered use_nl(o2, m2, f2) index(o2 opr_operation_pk) index(m2 acc_macros_object_ndx) index(f2 acc_entry_macros_ndx) */
                                                   1
                                              from opr_operation o2
                                                 , acc_macros    m2
                                                 , acc_entry     f2
                                             where o2.id             = o.original_id
                                               and m2.object_id      = o2.id
                                               and m2.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                               and f2.macros_id      = m2.id
                                               and (f2.status       != acc_api_const_pkg.ENTRY_STATUS_CANCELED or l_include_canceled_entries = com_api_const_pkg.TRUE)
                                               and decode(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING, f2.posting_date
                                                                     , com_api_const_pkg.DATE_PURPOSE_BANK,       f2.sttl_date, null) between l_start_date and l_end_date
                                               and o2.oper_amount    = o.oper_amount
                                    )
                            or
                            o.is_reversal = 0
                            and not exists (select /*+ ordered use_nl(o2, m2, f2) index(o2 opr_oper_original_id_ndx) index(m2 acc_macros_object_ndx) index(f2 acc_entry_macros_ndx) */
                                                   1
                                              from opr_operation o2
                                                 , acc_macros    m2
                                                 , acc_entry     f2
                                             where o2.original_id    = o.id
                                               and m2.object_id      = o2.id
                                               and m2.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                               and f2.macros_id      = m2.id
                                               and (f2.status       != acc_api_const_pkg.ENTRY_STATUS_CANCELED or l_include_canceled_entries = com_api_const_pkg.TRUE)
                                               and decode(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING, f2.posting_date
                                                                     , com_api_const_pkg.DATE_PURPOSE_BANK,       f2.sttl_date, null) between l_start_date and l_end_date
                                               and o2.oper_amount    = o.oper_amount
                                    )
                        )
                       )
                   and (i_array_trans_type_id is null or f.transaction_type in (select element_value from com_array_element where array_id = i_array_trans_type_id))
                   and (i_array_settl_type_id is null or o.sttl_type        in (select element_value from com_array_element where array_id = i_array_settl_type_id))
              order by o.id;

        elsif l_account_id is null
              and l_full_export = com_api_const_pkg.TRUE
        then
            -- It's the query plan for case when l_account_id is null and full export.
            open o_cursor for
                select to_number(null)
                     , f.id
                     , o.id
                     , to_number(null)
                     , to_number(null)
                     , f.transaction_id
                     , f.transaction_type
                     , f.posting_date
                     , m.amount_purpose
                     , m.conversion_rate
                     , m.rate_type
                     , f.balance_impact
                     , f.sttl_date
                     , f.posting_order
                     , f.sttl_day
                     , f.account_id
                     , f.amount
                     , f.currency
                     , f.is_settled
                  from com_split_map    sm
                     , evt_event_object eo
                     , acc_entry        f
                     , acc_macros       m
                     , opr_operation    o
                 where l_account_id       is null
                   and l_full_export       = com_api_const_pkg.TRUE
                   and l_thread_number    in (sm.thread_number, prc_api_const_pkg.DEFAULT_THREAD)
                   and eo.procedure_name   = 'ACC_PRC_ACCOUNT_EXPORT_PKG.PROCESS_TURNOVER_INFO'
                   and eo.entity_type      = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
                   and eo.eff_date        <= l_sysdate
                   and l_inst_id          in (eo.inst_id, ost_api_const_pkg.DEFAULT_INST)
                   and f.transaction_id    = eo.object_id
                   and f.split_hash        = eo.split_hash
                   and (f.status          != acc_api_const_pkg.ENTRY_STATUS_CANCELED or l_include_canceled_entries = com_api_const_pkg.TRUE)
                   and m.id                = f.macros_id
                   and m.entity_type       = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                   and o.id                = m.object_id
                   and decode(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING, f.posting_date
                                         , com_api_const_pkg.DATE_PURPOSE_BANK,       f.sttl_date, null) between l_start_date and l_end_date
                   and (
                        l_balance_type = 'NONE' and f.balance_type in (select element_value from com_array_element where array_id = l_array_balance_type_id)
                        or
                        l_balance_type in (f.balance_type, '%')
                       )
                   and (l_load_reversed = com_api_const_pkg.TRUE
                        or
                        l_load_reversed = com_api_const_pkg.FALSE
                        and (
                            o.is_reversal = 1
                            and not exists (select 1
                                              from opr_operation o2
                                                 , acc_macros m2
                                                 , acc_entry f2
                                             where o2.id            = o.original_id
                                               and m2.object_id     = o2.id
                                               and m2.entity_type   = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                               and f2.macros_id     = m2.id
                                               and (f2.status      != acc_api_const_pkg.ENTRY_STATUS_CANCELED or l_include_canceled_entries = com_api_const_pkg.TRUE)
                                               and decode(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING, f2.posting_date
                                                                     , com_api_const_pkg.DATE_PURPOSE_BANK,       f2.sttl_date, null) between l_start_date and l_end_date
                                               and o2.oper_amount = o.oper_amount
                                    )
                            or
                            o.is_reversal = 0
                            and not exists (select 1
                                              from opr_operation o2
                                                 , acc_macros m2
                                                 , acc_entry f2
                                             where o2.original_id   = o.id
                                               and m2.object_id     = o2.id
                                               and m2.entity_type   = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                               and f2.macros_id     = m2.id
                                               and (f2.status      != acc_api_const_pkg.ENTRY_STATUS_CANCELED or l_include_canceled_entries = com_api_const_pkg.TRUE)
                                               and decode(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING, f2.posting_date
                                                                     , com_api_const_pkg.DATE_PURPOSE_BANK,       f2.sttl_date, null) between l_start_date and l_end_date
                                               and o2.oper_amount = o.oper_amount
                                    )
                        )
                       )
                   and (i_array_trans_type_id is null or f.transaction_type in (select element_value from com_array_element where array_id = i_array_trans_type_id))
                   and (i_array_settl_type_id is null or o.sttl_type        in (select element_value from com_array_element where array_id = i_array_settl_type_id))
              order by o.id;

        elsif l_account_id is not null then
            -- It's the query plan for case when l_account_id is not null.
            open o_cursor for
                select /*+ ordered use_nl(sm, f, eo, m, o) full(sm) index(f acc_entry_account_ndx) index(eo evt_event_object_entity_ndx) index(m acc_macros_pk) index(o opr_operation_pk) */
                       to_number(null)
                     , f.id
                     , o.id
                     , to_number(null)
                     , to_number(null)
                     , f.transaction_id
                     , f.transaction_type
                     , f.posting_date
                     , m.amount_purpose
                     , m.conversion_rate
                     , m.rate_type
                     , f.balance_impact
                     , f.sttl_date
                     , f.posting_order
                     , f.sttl_day
                     , f.account_id
                     , f.amount
                     , f.currency
                     , f.is_settled
                  from com_split_map    sm
                     , acc_entry        f
                     , evt_event_object e
                     , acc_macros       m
                     , opr_operation    o
                 where l_thread_number  in (sm.thread_number, prc_api_const_pkg.DEFAULT_THREAD)
                   and f.account_id      = l_account_id
                   and (f.status        != acc_api_const_pkg.ENTRY_STATUS_CANCELED or l_include_canceled_entries = com_api_const_pkg.TRUE)
                   and f.split_hash      = sm.split_hash
                   and e.object_id       = f.transaction_id
                   and e.entity_type     = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
                   and e.procedure_name  = 'ACC_PRC_ACCOUNT_EXPORT_PKG.PROCESS_TURNOVER_INFO'
                   and e.eff_date       <= l_sysdate
                   and e.split_hash      = f.split_hash
                   and l_inst_id        in (e.inst_id, ost_api_const_pkg.DEFAULT_INST)
                   and m.id              = f.macros_id
                   and m.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                   and o.id              = m.object_id
                   and decode(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING, f.posting_date
                                         , com_api_const_pkg.DATE_PURPOSE_BANK,       f.sttl_date, null) between l_start_date and l_end_date
                   and (
                        l_balance_type = 'NONE' and f.balance_type in (select element_value from com_array_element where array_id = l_array_balance_type_id)
                        or
                        l_balance_type in (f.balance_type, '%')
                       )
                   and (l_load_reversed = com_api_const_pkg.TRUE
                        or
                        l_load_reversed = com_api_const_pkg.FALSE
                        and (
                            o.is_reversal = 1
                            and not exists (select /*+ ordered use_nl(o2, m2, f2) index(o2 opr_operation_pk) index(m2 acc_macros_object_ndx) index(f2 acc_entry_macros_ndx) */
                                                   1
                                              from opr_operation o2
                                                 , acc_macros m2
                                                 , acc_entry f2
                                             where o2.id            = o.original_id
                                               and m2.object_id     = o2.id
                                               and m2.entity_type   = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                               and f2.macros_id     = m2.id
                                               and (f2.status      != acc_api_const_pkg.ENTRY_STATUS_CANCELED or l_include_canceled_entries = com_api_const_pkg.TRUE)
                                               and decode(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING, f2.posting_date
                                                                     , com_api_const_pkg.DATE_PURPOSE_BANK,       f2.sttl_date, null) between l_start_date and l_end_date
                                               and o2.oper_amount = o.oper_amount
                                    )
                            or
                            o.is_reversal = 0
                            and not exists (select /*+ ordered use_nl(o2, m2, f2) index(o2 opr_oper_original_id_ndx) index(m2 acc_macros_object_ndx) index(f2 acc_entry_macros_ndx) */
                                                   1
                                              from opr_operation o2
                                                 , acc_macros m2
                                                 , acc_entry f2
                                             where o2.original_id   = o.id
                                               and m2.object_id     = o2.id
                                               and m2.entity_type   = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                               and f2.macros_id     = m2.id
                                               and (f2.status      != acc_api_const_pkg.ENTRY_STATUS_CANCELED or l_include_canceled_entries = com_api_const_pkg.TRUE)
                                               and decode(i_date_type, com_api_const_pkg.DATE_PURPOSE_PROCESSING, f2.posting_date
                                                                     , com_api_const_pkg.DATE_PURPOSE_BANK,       f2.sttl_date, null) between l_start_date and l_end_date
                                               and o2.oper_amount = o.oper_amount
                                    )
                        )
                       )
                   and (i_array_trans_type_id is null or f.transaction_type in (select element_value from com_array_element where array_id = i_array_trans_type_id))
                   and (i_array_settl_type_id is null or o.sttl_type        in (select element_value from com_array_element where array_id = i_array_settl_type_id))
              order by o.id;
          
        end if;

        trc_log_pkg.debug('Cursor was opened...');
    end open_cur_objects;

    procedure open_file is
        l_params                   com_api_type_pkg.t_param_tab;
        l_report_id                com_api_type_pkg.t_short_id;
        l_report_template_id       com_api_type_pkg.t_short_id;
    begin
        -- Preparing for passing into <prc_api_file_pkg.open_file> Id of the institute
        l_params := evt_api_shared_data_pkg.g_params;

        rul_api_param_pkg.set_param(
            i_name    => 'INST_ID'
          , i_value   => to_char(i_inst_id)
          , io_params => l_params
        );

        rul_api_param_pkg.set_param(
            i_name    => 'START_DATE'
          , i_value   => l_start_date
          , io_params => l_params
        );

        rul_api_param_pkg.set_param(
            i_name    => 'END_DATE'
          , i_value   => l_end_date
          , io_params => l_params
        );

        l_total_file_count := l_total_file_count + 1;

        rul_api_param_pkg.set_param(
            i_name    => 'FILE_NUMBER'
          , i_value   => l_total_file_count
          , io_params => l_params
        );

        prc_api_file_pkg.open_file (
            o_sess_file_id        => l_session_file_id
          , i_file_name           => null
          , i_file_type           => l_file_type
          , i_file_purpose        => prc_api_const_pkg.FILE_PURPOSE_OUT
          , io_params             => l_params
          , o_report_id           => l_report_id
          , o_report_template_id  => l_report_template_id
          , i_no_session_id       => com_api_const_pkg.FALSE
        );

        prc_api_file_pkg.set_session_file_id (
            i_sess_file_id => l_session_file_id
        );

    end open_file;

    -- Generate XML file
    procedure generate_xml is
        l_fetched_count            com_api_type_pkg.t_count    := 0;
        l_operation_id_tab         com_api_type_pkg.t_long_tab;
        l_xml_block_tab            com_api_type_pkg.t_lob_tab;
        l_xml_block                com_api_type_pkg.t_lob_data;

        l_xml_transaction          com_api_type_pkg.t_lob_data;

        l_changed_entry_id_tab     com_api_type_pkg.t_long_tab;
        l_changed_inst_id_tab      com_api_type_pkg.t_inst_id_tab;
        l_changed_split_hash_tab   com_api_type_pkg.t_tiny_tab;
    begin
        if l_oper_id_tab.count() > 0 then

            l_estimated_count := nvl(l_estimated_count, 0) + l_oper_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
              , i_measure         => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            );
            trc_log_pkg.debug('Estimated count of operations is [' || l_estimated_count || ']');

            if g_inst_flag_tab.count > 0 then
                for i in 1 .. l_entry_id_tab.count loop
                    if g_inst_flag_tab.exists(l_inst_id_tab(i)) then

                        l_changed_entry_id_tab(l_changed_entry_id_tab.count + 1)     := l_entry_id_tab(i);
                        l_changed_inst_id_tab(l_changed_inst_id_tab.count + 1)       := l_inst_id_tab(i);
                        l_changed_split_hash_tab(l_changed_split_hash_tab.count + 1) := l_split_hash_tab(i);

                    end if;
                end loop;

                if l_changed_entry_id_tab.count > 0 then
                    acc_api_entry_pkg.set_is_settled(
                        i_entry_id_tab  => l_changed_entry_id_tab
                      , i_is_settled    => com_api_const_pkg.FALSE
                      , i_inst_id       => l_changed_inst_id_tab
                      , i_sttl_flag_date => null
                      , i_split_hash    => l_changed_split_hash_tab
                    );
                end if;

            end if;

            open_file;

            -- Create temporary LOB
            dbms_lob.createtemporary(lob_loc => l_file,
                                     cache   => true,
                                     dur     => dbms_lob.session);
          
            if dbms_lob.isopen(l_file) = 0 then
              dbms_lob.open(l_file, dbms_lob.lob_readwrite);
            end if;

            l_xml_block := com_api_const_pkg.XML_HEADER || CRLF
                        || '<clearing xmlns="http://bpc.ru/sv/SVXP/clearing">'
                        || '<file_id>'   || l_session_file_id || '</file_id>'
                        || '<file_type>' || l_file_type       || '</file_type>'
                        || '<inst_id>'   || i_inst_id         || '</inst_id>';

            if l_xml_block is not null then
                dbms_lob.writeappend(l_file, dbms_lob.getlength(l_xml_block), l_xml_block);
            end if;

            prc_api_performance_pkg.start_performance_metric(
                i_method_name => 'generate_xml'
              , i_label_name  => 'open cur_xml'
            );

            -- For every processing batch of operations we fetch data and save it in a separate file
            open cur_xml;

            prc_api_performance_pkg.finish_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'open cur_xml'
            );


            prc_api_performance_pkg.start_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'fetch cur_xml'
            );

            fetch cur_xml
               bulk collect
               into l_operation_id_tab
                  , l_xml_block_tab;

            l_fetched_count := l_operation_id_tab.count;

            prc_api_performance_pkg.finish_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'fetch cur_xml'
              , i_fetched_count => l_fetched_count
            );

            close cur_xml;

            prc_api_performance_pkg.start_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'for loop'
            );

            for i in 1 .. l_operation_id_tab.count loop
                generate_transaction(
                    i_operation_id       => l_operation_id_tab(i)
                  , i_use_custom_method  => l_use_custom_method
                  , o_xml_block          => l_xml_transaction
                );

                prc_api_performance_pkg.start_performance_metric(
                    i_method_name   => 'generate_xml'
                  , i_label_name    => 'build_xml'
                );

                l_xml_block := '<operation>'
                            || l_xml_block_tab(i)
                            || l_xml_transaction
                            || '</operation>';

                if l_xml_block is not null then
                    dbms_lob.writeappend(l_file, dbms_lob.getlength(l_xml_block), l_xml_block);
                end if;

                prc_api_performance_pkg.finish_performance_metric(
                    i_method_name   => 'generate_xml'
                  , i_label_name    => 'build_xml'
                );

            end loop;

            prc_api_performance_pkg.finish_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'for loop'
              , i_fetched_count => l_fetched_count
            );


            l_xml_block := '</clearing>';

            if l_xml_block is not null then
                dbms_lob.writeappend(l_file, dbms_lob.getlength(l_xml_block), l_xml_block);
            end if;

            prc_api_performance_pkg.start_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'save_file'
            );

            prc_api_file_pkg.put_file (
                i_sess_file_id   => l_session_file_id
              , i_clob_content   => l_file
              , i_add_to         => com_api_const_pkg.FALSE
            );

            trc_log_pkg.debug(
                i_text           =>'save_file: i_record_count [#1]'
              , i_env_param1     => l_fetched_count      
            );

            prc_api_file_pkg.close_file(
                i_sess_file_id   => l_session_file_id
              , i_status         => prc_api_const_pkg.FILE_STATUS_ACCEPTED
              , i_record_count   => l_fetched_count
            );

            if dbms_lob.isopen(l_file) = 1 then
              dbms_lob.close(l_file);
            end if;
          
            dbms_lob.freetemporary(lob_loc => l_file);

            prc_api_performance_pkg.finish_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'save_file'
              , i_fetched_count => l_fetched_count
            );

            l_processed_count := l_processed_count + l_fetched_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_processed_count
              , i_excepted_count => 0
            );
        end if;

        if l_account_id is null
           and l_full_export = com_api_const_pkg.FALSE
        then
            -- Mark processed event object
            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab  => g_event_object_id_tab
            );
        end if;

        trc_log_pkg.debug(
            i_text       => '[#1] event objects marked as PROCESSED.'
          , i_env_param1 => g_event_object_id_tab.count
        );

        l_entry_id_tab.delete;
        l_oper_id_tab.delete;
        l_inst_id_tab.delete;
        l_split_hash_tab.delete;
        g_entry_by_oper_tab.delete;
        g_event_object_id_tab.delete;

        -- After event processing: Reset current "session_file_id" which is calculated in "prc_api_file_pkg.save_file"
        prc_api_file_pkg.set_session_file_id(
            i_sess_file_id => null
        );

    end generate_xml;

begin
    savepoint process_unload_turnover;

    prc_api_stat_pkg.log_start;

    prc_api_performance_pkg.reset_performance_metrics;

    l_container_id         := prc_api_session_pkg.get_container_id;

    l_masking_card_in_file := set_ui_value_pkg.get_inst_param_n(
                                  i_param_name => 'MASKING_CARD_IN_DBAL_FILE'
                                , i_inst_id    => i_inst_id
                              );

    l_lang       := coalesce(i_lang, get_user_lang);
    l_sysdate    := com_api_sttl_day_pkg.get_sysdate;
    l_start_date := trunc(coalesce(i_start_date, l_sysdate), 'DD') + nvl(i_shift_from, 0);
    l_end_date   := nvl(trunc(i_end_date, 'DD'), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND + nvl(i_shift_to, 0);

    trc_log_pkg.info(
        i_text       => 'process_turnover_info: inst_id [#1], full_export [#2], date_type [#3], balance_type [#4], account_number [#5], masking_card [#6]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_full_export
      , i_env_param3 => i_date_type
      , i_env_param4 => i_balance_type
      , i_env_param5 => nvl(i_account_number, '')
      , i_env_param6 => i_masking_card
    );

    trc_log_pkg.info(
        i_text       => 'process_turnover_info: start_date [#1], end_date [#2], shift_from [#3], shift_to [#4], load_reversals [#5], bulk_limit [#6]'
      , i_env_param1 => to_char(l_start_date, com_api_const_pkg.XML_DATE_FORMAT)
      , i_env_param2 => to_char(l_end_date,   com_api_const_pkg.XML_DATE_FORMAT)
      , i_env_param3 => i_shift_from
      , i_env_param4 => i_shift_to
      , i_env_param5 => i_load_reversals
      , i_env_param6 => l_bulk_limit
    );

    trc_log_pkg.info(
        i_text       => 'process_turnover_info: i_array_balance_type_id [#1], i_array_trans_type_id [#2], i_array_settl_type_id [#3], i_use_matched_data [#4], i_use_custom_method [#5], i_include_auth [#6]'
      , i_env_param1 => i_array_balance_type_id
      , i_env_param2 => i_array_trans_type_id
      , i_env_param3 => i_array_settl_type_id
      , i_env_param4 => i_use_matched_data
      , i_env_param5 => i_use_custom_method
      , i_env_param6 => i_include_auth
    );

    trc_log_pkg.info(
        i_text       => 'process_turnover_info, i_include_Visa_clearing=[#1], i_include_MasterCard_clearing=[#2], i_include_document=[#3]'
      , i_env_param1 => i_include_Visa_clearing
      , i_env_param2 => i_include_MasterCard_clearing
      , i_env_param3 => i_include_document
    );

    l_balance_type                := nvl(i_balance_type,                'NONE');
    l_inst_id                     := nvl(i_inst_id,                     ost_api_const_pkg.DEFAULT_INST);
    l_load_reversed               := nvl(i_load_reversals,              com_api_const_pkg.TRUE); 
    l_full_export                 := nvl(i_full_export,                 com_api_const_pkg.FALSE);
    l_include_auth                := nvl(i_include_auth,                com_api_const_pkg.TRUE);
    l_include_Visa_clearing       := nvl(i_include_Visa_clearing,       com_api_const_pkg.TRUE);
    l_include_MasterCard_clearing := nvl(i_include_MasterCard_clearing, com_api_const_pkg.TRUE);
    l_include_document            := nvl(i_include_document,            com_api_const_pkg.TRUE);
    l_include_payment_order       := nvl(i_include_payment_order,       com_api_const_pkg.TRUE);
    l_include_note                := nvl(i_include_note,                com_api_const_pkg.TRUE);
    l_include_additional_amount   := nvl(i_include_additional_amount,   com_api_const_pkg.TRUE);
    l_thread_number               := prc_api_session_pkg.get_thread_number;

    set_ui_value_pkg.get_inst_by_param_n(
        i_param_name       => 'CBS_SETTLEMENT_FLAG'
      , o_inst_id          => g_inst_flag_tab
    );

    remain_active_inst_param(io_inst_flag_tab => g_inst_flag_tab);

    trc_log_pkg.debug('Count of institutions with active CBS_SETTLEMENT_FLAG: [' || g_inst_flag_tab.count || ']');

    -- check account number
    if i_account_number is not null then
        l_account_id := acc_api_account_pkg.get_account_id(i_account_number);
        if l_account_id = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'ACCOUNT_NOT_FOUND'
              , i_env_param1 => i_account_number
            );
        end if;
    end if;

    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    if l_file_type is null then
        com_api_error_pkg.raise_error(
            i_error      => 'FILE_TYPE_NOT_FOUND'
          , i_env_param1 => prc_api_session_pkg.get_process_id
        );
    end if;

    prc_api_performance_pkg.start_performance_metric(
        i_method_name => 'process_turnover_info'
      , i_label_name  => 'open_cur_objects'
    );

    open_cur_objects(
        o_cursor => cur_objects
    );

    prc_api_performance_pkg.finish_performance_metric(
        i_method_name => 'process_turnover_info'
      , i_label_name  => 'open_cur_objects'
    );

    loop
        prc_api_performance_pkg.start_performance_metric(
            i_method_name   => 'process_turnover_info'
          , i_label_name    => 'fetch events'
        );

        -- Select IDs of all event objects need to proceed
        fetch cur_objects
            bulk collect
            into l_fetched_event_object_id_tab
               , l_fetched_entry_id_tab
               , l_fetched_oper_id_tab
               , l_fetched_inst_id_tab
               , l_fetched_split_hash_tab
               , l_fetched_transaction_id_tab
               , l_fetched_transaction_type_tab
               , l_fetched_posting_date_tab
               , l_fetched_amount_purpose_tab
               , l_fetched_conversion_rate_tab
               , l_fetched_rate_type_tab
               , l_fetched_balance_impact_tab
               , l_fetched_sttl_date_tab
               , l_fetched_posting_order_tab
               , l_fetched_sttl_day_tab
               , l_fetched_account_id_tab
               , l_fetched_amount_value_tab
               , l_fetched_entry_currency_tab
               , l_fetched_is_settled_tab
           limit l_bulk_limit;

        prc_api_performance_pkg.finish_performance_metric(
            i_method_name   => 'process_turnover_info'
          , i_label_name    => 'fetch events'
        );

        trc_log_pkg.debug('l_fetched_oper_id_tab.count  = ' || l_fetched_oper_id_tab.count);

        if l_fetched_oper_id_tab.count > 0 then

            l_last_oper_id := l_fetched_oper_id_tab(l_fetched_oper_id_tab.count);

            for i in 1 .. l_fetched_oper_id_tab.count loop

                -- Decrease operation count and get entries for last operation id from previous iteration
                if l_fetched_oper_id_tab(i) != l_current_oper_id
                   or l_current_oper_id is null
                then
                    if l_oper_id_tab.count >= l_bulk_limit
                       and l_fetched_oper_id_tab(i) != l_last_oper_id
                    then
                        -- Generate XML file for current portion of the "l_bulk_limit" operations
                        generate_xml;
                    end if;

                    l_current_oper_id := l_fetched_oper_id_tab(i);

                    l_oper_id_tab.extend;
                    l_oper_id_tab(l_oper_id_tab.count) := l_current_oper_id;
                end if;

                l_entry_id_tab.extend;
                l_entry_id_tab(l_entry_id_tab.count)     := l_fetched_entry_id_tab(i);

                l_inst_id_tab.extend;
                l_inst_id_tab(l_inst_id_tab.count)       := l_fetched_inst_id_tab(i);

                l_split_hash_tab.extend;
                l_split_hash_tab(l_split_hash_tab.count) := l_fetched_split_hash_tab(i);

                g_entry_by_oper_tab(l_fetched_oper_id_tab(i))(l_fetched_entry_id_tab(i)).event_object_id  := l_fetched_event_object_id_tab(i);
                g_entry_by_oper_tab(l_fetched_oper_id_tab(i))(l_fetched_entry_id_tab(i)).transaction_id   := l_fetched_transaction_id_tab(i);
                g_entry_by_oper_tab(l_fetched_oper_id_tab(i))(l_fetched_entry_id_tab(i)).transaction_type := l_fetched_transaction_type_tab(i);
                g_entry_by_oper_tab(l_fetched_oper_id_tab(i))(l_fetched_entry_id_tab(i)).posting_date     := l_fetched_posting_date_tab(i);
                g_entry_by_oper_tab(l_fetched_oper_id_tab(i))(l_fetched_entry_id_tab(i)).amount_purpose   := l_fetched_amount_purpose_tab(i);
                g_entry_by_oper_tab(l_fetched_oper_id_tab(i))(l_fetched_entry_id_tab(i)).conversion_rate  := l_fetched_conversion_rate_tab(i);
                g_entry_by_oper_tab(l_fetched_oper_id_tab(i))(l_fetched_entry_id_tab(i)).rate_type        := l_fetched_rate_type_tab(i);
                g_entry_by_oper_tab(l_fetched_oper_id_tab(i))(l_fetched_entry_id_tab(i)).balance_impact   := l_fetched_balance_impact_tab(i);
                g_entry_by_oper_tab(l_fetched_oper_id_tab(i))(l_fetched_entry_id_tab(i)).entry_id         := l_fetched_entry_id_tab(i);
                g_entry_by_oper_tab(l_fetched_oper_id_tab(i))(l_fetched_entry_id_tab(i)).sttl_date        := l_fetched_sttl_date_tab(i);
                g_entry_by_oper_tab(l_fetched_oper_id_tab(i))(l_fetched_entry_id_tab(i)).posting_order    := l_fetched_posting_order_tab(i);
                g_entry_by_oper_tab(l_fetched_oper_id_tab(i))(l_fetched_entry_id_tab(i)).sttl_day         := l_fetched_sttl_day_tab(i);
                g_entry_by_oper_tab(l_fetched_oper_id_tab(i))(l_fetched_entry_id_tab(i)).account_id       := l_fetched_account_id_tab(i);
                g_entry_by_oper_tab(l_fetched_oper_id_tab(i))(l_fetched_entry_id_tab(i)).amount_value     := l_fetched_amount_value_tab(i);
                g_entry_by_oper_tab(l_fetched_oper_id_tab(i))(l_fetched_entry_id_tab(i)).entry_currency   := l_fetched_entry_currency_tab(i);
                g_entry_by_oper_tab(l_fetched_oper_id_tab(i))(l_fetched_entry_id_tab(i)).inst_id          := l_fetched_inst_id_tab(i);
                g_entry_by_oper_tab(l_fetched_oper_id_tab(i))(l_fetched_entry_id_tab(i)).is_settled       := l_fetched_is_settled_tab(i);

            end loop;
        end if;

        trc_log_pkg.debug('events were processed, cnt = ' || l_fetched_event_object_id_tab.count);

        exit when cur_objects%notfound;

    end loop;

    -- Generate XML file for last portion of records
    generate_xml;

    if l_estimated_count is null then
        prc_api_stat_pkg.log_estimation(
            i_estimated_count => 0
          , i_measure         => opr_api_const_pkg.ENTITY_TYPE_OPERATION
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total  => l_estimated_count
      , i_excepted_total   => 0
      , i_rejected_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    prc_api_performance_pkg.print_performance_metrics(
        i_processed_count => l_processed_count
    );

    trc_log_pkg.debug('process_turnover_info: FINISHED');
exception
    when others then
        rollback to process_unload_turnover;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        prc_api_performance_pkg.print_performance_metrics(
            i_processed_count => l_processed_count
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

end process_turnover_info;

function get_limit_id (
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id is

    l_params            com_api_type_pkg.t_param_tab;
    l_limit_id          com_api_type_pkg.t_long_id;
begin
    l_limit_id := prd_api_product_pkg.get_limit_id (
                      i_product_id     => i_product_id
                      , i_entity_type  => i_entity_type
                      , i_object_id    => i_object_id
                      , i_limit_type   => i_limit_type
                      , i_params       => l_params
                      , i_eff_date     => get_sysdate
                      , i_mask_error   => com_api_type_pkg.TRUE
                      , i_inst_id      => i_inst_id
                  );
    return l_limit_id;                            
end;

function generate_limit_xml(
    i_account_id         in      com_api_type_pkg.t_account_id
) return xmltype 
is
    l_limits    xmltype;
    l_sysdate   date;
begin
    l_sysdate   := com_api_sttl_day_pkg.get_sysdate;

    select xmlelement("limits",
        xmlagg(
            xmlelement("limit"
              , xmlelement("limit_type", c.limit_type)
              , xmlelement("limit_usage", nvl(t.limit_usage, fcl_api_const_pkg.LIMIT_USAGE_SUM_COUNT))
              , xmlelement("sum_limit", nvl(fcl_api_limit_pkg.get_sum_limit(c.limit_type, c.entity_type, c.object_id, null, com_api_type_pkg.TRUE), 0))
              , xmlelement("count_limit", nvl(fcl_api_limit_pkg.get_count_limit(c.limit_type, c.entity_type, c.object_id, null, com_api_type_pkg.TRUE), 0))
              , xmlelement("sum_current", nvl(fcl_api_limit_pkg.get_limit_sum_curr(c.limit_type, c.entity_type, c.object_id), 0))
              , xmlelement("currency", fcl_api_limit_pkg.get_limit_currency(c.limit_type, c.entity_type, c.object_id, null, com_api_type_pkg.TRUE))
              , (case when t.cycle_type is not null then 
                     (select xmlforest(case when b.next_date > l_sysdate or b.next_date is null then b.next_date
                                            else fcl_api_cycle_pkg.calc_next_date(b.cycle_type, c.entity_type, c.object_id, c.split_hash, l_sysdate)
                                       end "next_date"
                             )
                        from fcl_cycle_counter b
                       where t.cycle_type  = b.cycle_type
                         and c.entity_type = b.entity_type
                         and c.object_id   = b.object_id
                     ) 
                      else null 
                 end)                              
              , (case when t.cycle_type is not null then 
                     (select xmlconcat(
                                 xmlelement("length_type", b.length_type)
                               , xmlelement("cycle_length", b.cycle_length)
                             )
                        from fcl_limit a
                           , fcl_cycle b
                       where a.id = acc_prc_account_export_pkg.get_limit_id (
                                           i_product_id   => prd_api_product_pkg.get_product_id(
                                                                 i_entity_type   => c.entity_type
                                                               , i_object_id     => c.object_id
                                                             )
                                         , i_entity_type  => c.entity_type
                                         , i_object_id    => c.object_id
                                         , i_limit_type   => c.limit_type
                                         , i_mask_error   => com_api_type_pkg.TRUE
                                       )
                           and b.id         = a.cycle_id                            
                           and a.limit_type = t.limit_type                    
                     )
                     else null 
                 end)
            )
        )
    )
    into l_limits
    from fcl_limit_counter c
       , fcl_limit_type t
       , (select distinct
                 a.object_type limit_type
            from prd_attribute a
               , prd_service_type t 
           where t.entity_type     = 'ENTTACCT'
             and a.service_type_id = t.id
             and a.entity_type     = 'ENTTLIMT'
         ) x
   where c.limit_type  = t.limit_type
     and c.entity_type = 'ENTTACCT'
     and c.object_id   = i_account_id
     and x.limit_type  = c.limit_type;

    return l_limits;

exception
    when others then
        trc_log_pkg.error('Error when generate limits on account = ' || i_account_id);
        trc_log_pkg.error(sqlerrm);
        return null;
end;

end acc_prc_account_export_pkg;
/
