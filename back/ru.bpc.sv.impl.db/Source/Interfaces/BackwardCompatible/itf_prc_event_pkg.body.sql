create or replace package body itf_prc_event_pkg is

C_CRLF           constant  com_api_type_pkg.t_name := chr(13)||chr(10);

procedure process_event_object(
    i_inst_id           in      com_api_type_pkg.t_inst_id
)
is 
    l_session_file_id      com_api_type_pkg.t_long_id;
    l_file                 clob;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_container_id         com_api_type_pkg.t_long_id :=  prc_api_session_pkg.get_container_id;
    l_event_id_tab         num_tab_tpt;    
    l_processed_count      com_api_type_pkg.t_medium_id;
begin
    trc_log_pkg.debug('process_merchant - Start');

    prc_api_stat_pkg.log_start;

    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    trc_log_pkg.debug(
        i_text =>'process_merchant, container_id=#1, inst=#2'
      , i_env_param1 => l_container_id
      , i_env_param2 => i_inst_id
    );

    savepoint sp_event_export;    

    -- Remove unprocessed events.
    delete from evt_event_object o
     where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_EVENT_PKG.PROCESS_EVENT_OBJECT'
       and i_inst_id         in (o.inst_id
                               , ost_api_const_pkg.DEFAULT_INST)
       and o.entity_type not in (acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                               , crd_api_const_pkg.ENTITY_TYPE_INVOICE)
       and exists (
               select 1
                 from evt_event e
                where e.id = o.event_id
                  and e.event_type in (crd_api_const_pkg.INVOICE_CREATION_EVENT
                                     , crd_api_const_pkg.INCREASE_LIMIT_EVENT
                                     , crd_api_const_pkg.AGING_1_EVENT)
           );

    -- Get collection of processed events.
    select o.id      
      bulk collect into l_event_id_tab
      from evt_event_object o
         , evt_event e
     where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_EVENT_PKG.PROCESS_EVENT_OBJECT'
       and e.id = o.event_id  
       and i_inst_id     in (o.inst_id
                           , ost_api_const_pkg.DEFAULT_INST)
       and o.entity_type in (acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                           , crd_api_const_pkg.ENTITY_TYPE_INVOICE)
       and e.event_type  in (crd_api_const_pkg.INVOICE_CREATION_EVENT
                           , crd_api_const_pkg.INCREASE_LIMIT_EVENT
                           , crd_api_const_pkg.AGING_1_EVENT ); 
                           -- 'EVNT1018', 'EVNT1021', 'EVNT1011'
        
    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_event_id_tab.count
      , i_measure         => evt_api_const_pkg.ENTITY_TYPE_EVENT
    );
    
    trc_log_pkg.debug(
        i_text =>'l_estimate_count =#1'
      , i_env_param1 => l_event_id_tab.count
    );

    select            
        xmlelement("events", 
            xmlelement("file_type",   l_file_type),
            xmlelement("inst_id",     i_inst_id),
            xmlelement("file_date",   to_char(get_sysdate, com_api_const_pkg.XML_DATE_FORMAT)),
            xmlagg(
                xmlelement("event",
                    xmlelement("event_id",       e.id),
                    xmlelement("event_type",     e.event_type),
                    xmlelement("entity_type",    e.entity_type),
                    xmlelement("eff_date",       to_char(e.eff_date, com_api_const_pkg.XML_DATETIME_FORMAT)),
                    generate_card_block(
                        i_account_id => e.account_id
                    ) ,
                    generate_account_block(
                        i_account_id => e.account_id
                    ),
                    generate_invoice_block(
                        i_invoice_id => e.invoice_id
                      , i_account_id => e.account_id
                    )
                )
           )
        ).getclobval()
    into l_file         
    from (            
        select o.id 
             , e.event_type
             , o.entity_type
             , o.eff_date    
             , case when o.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then o.object_id
                    when o.entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE then (select account_id from crd_invoice where id = o.object_id)
                    else null
               end account_id  
             , case when o.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then crd_invoice_pkg.get_last_invoice_id(o.object_id, o.split_hash, com_api_type_pkg.TRUE)
                    when o.entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE then o.object_id
                    else null
               end invoice_id  
          from evt_event_object o
             , evt_event e
         where o.id in (select column_value from table(cast(l_event_id_tab as num_tab_tpt))) 
           and e.id = o.event_id  
           and (i_inst_id is null or i_inst_id = o.inst_id)
    ) e;

    l_processed_count := l_event_id_tab.count;
    if l_processed_count > 0 then
        prc_api_file_pkg.open_file(
            o_sess_file_id => l_session_file_id
          , i_file_type    => l_file_type
        );

        l_file := com_api_const_pkg.XML_HEADER || C_CRLF || l_file;

        prc_api_file_pkg.put_file(
            i_sess_file_id  => l_session_file_id
          , i_clob_content  => l_file
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count  => l_processed_count
        );
        trc_log_pkg.debug('file saved, cnt='||l_processed_count||', length='||length(l_file));
    end if;
    
    evt_api_event_pkg.process_event_object(
        i_event_object_id_tab    => l_event_id_tab
    );
    
    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => 0
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('process_event - End');

exception
    when others then
        rollback to sp_event_export;
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
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
end;


function generate_card_block(
    i_account_id          in      com_api_type_pkg.t_account_id
) return xmltype 
is 
    l_card_block    xmltype;
begin
    select 
        xmlelement("card",
            xmlelement("card_number"     , c.card_number),
            xmlelement("expir_date"      , to_char(c.expir_date, com_api_const_pkg.XML_DATE_FORMAT)),
            xmlelement("cardholder_name" , c.cardholder_name)
        ) 
      into l_card_block       
      from (  
          select n.card_id
               , n.card_number
               , i.expir_date
               , i.cardholder_name
            from acc_account_object o
               , iss_card c
               , iss_card_instance i 
               , iss_card_number n
           where o.account_id  = i_account_id
             and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
             and c.id          = o.object_id
             and c.id          = i.card_id
             and c.id          = n.card_id
           order by decode(c.category, 'CRCG0800', 1, 2)
    ) c where rownum = 1;

    return l_card_block;

exception 
    when others then
        trc_log_pkg.error('Error when generate card block on account_id = ' || i_account_id);       
        trc_log_pkg.error(sqlerrm);       
        return null;                                                            
end;

function generate_account_block(
    i_account_id          in      com_api_type_pkg.t_account_id
) return xmltype 
is 
    l_account_block    xmltype;
begin
    select 
        xmlelement("account",
            xmlelement("account_number"   , a.account_number),
            xmlelement("currency"         , a.currency),
            xmlelement("aval_balance"     , acc_api_balance_pkg.get_aval_balance_amount_only(a.id, com_api_sttl_day_pkg.get_sysdate, com_api_const_pkg.DATE_PURPOSE_PROCESSING, 1)),
            xmlelement("exceed_limit"     , b.balance),
            xmlelement("first_name"       , com_ui_person_pkg.get_first_name(c.object_id)),
            xmlelement("second_name"      , com_ui_person_pkg.get_second_name(c.object_id)),
            xmlelement("surname"          , com_ui_person_pkg.get_surname(c.object_id))
        ) 
      into l_account_block     
      from acc_account a
         , acc_balance b
         , prd_customer c
     where a.id           = i_account_id
       and a.id           = b.account_id
       and b.balance_type = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED --'BLTP1001'
       and a.customer_id  = c.id;

    return l_account_block;

exception 
    when others then
        trc_log_pkg.error('Error when generate account block on id = ' || i_account_id);       
        trc_log_pkg.error(sqlerrm);       
        return null;                                                            
end;

function generate_invoice_block(
    i_invoice_id          in      com_api_type_pkg.t_account_id
  , i_account_id          in      com_api_type_pkg.t_account_id  := null
) return xmltype 
is 
    l_invoice_block    xmltype;
begin
    if i_invoice_id is null then
        trc_log_pkg.warn(
            i_text          => 'ACCOUNT_HAS_NO_INVOICES'
          , i_env_param1    => i_account_id
        );
        return null;                                                            
    end if;

    select     
        xmlelement("invoice",
            xmlelement("invoice_date"          , to_char(i.invoice_date, com_api_const_pkg.XML_DATE_FORMAT)),
            xmlelement("grace_date"            , to_char(i.grace_date, com_api_const_pkg.XML_DATE_FORMAT)),
            xmlelement("due_date"              , to_char(i.due_date, com_api_const_pkg.XML_DATE_FORMAT)),        
            xmlelement("total_amount_due"      , i.total_amount_due),
            xmlelement("min_amount_due"        , i.min_amount_due),        
            xmlelement("overdue_amount"        , nvl(ob.balance, 0)),
            xmlelement("interest_amount"       , nvl(ib.balance, 0))
        )  
      into l_invoice_block    
      from crd_invoice i
         , acc_account a
         , acc_balance ob
         , acc_balance ib
     where i.id               = i_invoice_id
       and i.account_id       = a.id
       and a.id               = ob.account_id(+)
       and ob.balance_type(+) = acc_api_const_pkg.BALANCE_TYPE_OVERDUE   --'BLTP1004'     
       and a.id               = ib.account_id(+)
       and ib.balance_type(+) = crd_api_const_pkg.BALANCE_TYPE_INTEREST; --'BLTP1003'; 

    return l_invoice_block;

exception 
    when others then
        trc_log_pkg.error('Error when generate invoice block on id = ' || i_invoice_id);       
        trc_log_pkg.error(sqlerrm);       
        return null;                                                            
end;

end;
/
