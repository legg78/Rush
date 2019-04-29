create or replace package body lty_prc_lottery_tickets_pkg as
/*********************************************************
 *  Process for lottery tickets <br /> 
 *  Created by Kondratyev A.(kondratyev@bpc.ru)  at 11.04.2017 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: lty_prc_lottery_tickets_pkg <br />
 *  @headcom
 **********************************************************/ 

CRLF          constant     com_api_type_pkg.t_name    := chr(13) || chr(10); 

procedure export_file (
    i_inst_id       in     com_api_type_pkg.t_inst_id
) is
    l_session_file_id      com_api_type_pkg.t_long_id;
    l_file                 clob;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_container_id         com_api_type_pkg.t_long_id :=  prc_api_session_pkg.get_container_id;
    l_estimated_count      com_api_type_pkg.t_long_id := 0;
    l_params               com_api_type_pkg.t_param_tab;
    l_event_tab            com_api_type_pkg.t_number_tab;
    l_tickets_id_tab       num_tab_tpt; 
    l_sysdate              date;

    cursor main_xml_cur is
        select
            xmlelement("tickets", xmlattributes('http://sv.bpc.in/SVAP' as "xmlns")
              , xmlagg(xmlelement("lottery_tickets"
                  , xmlelement("inst_id", i_inst_id)
                  , xmlelement("file_date", to_char(l_sysdate, com_api_const_pkg.XML_DATE_FORMAT))
                  , (select xmlagg(xmlelement("lottery_ticket"
                              , xmlelement("customer_number", c.customer_number)
                              , xmlelement("loyalty_member_number", 
                                               case 
                                                   when lt.card_id is not null
                                                   then prd_api_product_pkg.get_attr_value_char(
                                                            i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                          , i_object_id         => lt.card_id
                                                          , i_attr_name         => lty_api_const_pkg.LOYALTY_EXTERNAL_NUMBER
                                                          , i_service_id        => lt.service_id
                                                          , i_eff_date          => l_sysdate
                                                          , i_mask_error        => com_api_const_pkg.TRUE
                                                        )
                                                   else prd_api_product_pkg.get_attr_value_char(
                                                            i_entity_type       => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                                          , i_object_id         => lt.customer_id
                                                          , i_attr_name         => lty_api_const_pkg.LOYALTY_EXTERNAL_NUMBER
                                                          , i_service_id        => lt.service_id
                                                          , i_eff_date          => l_sysdate
                                                          , i_mask_error        => com_api_const_pkg.TRUE
                                                        )
                                               end 
                                          )
                              , xmlelement("ticket_number", lt.ticket_number)
                              , xmlelement("registration_date", to_char(lt.registration_date, com_api_const_pkg.XML_DATE_FORMAT))
                            )) -- xmlagg(xmlelement("lottery_ticket"...
                       from prd_customer c
                          , lty_lottery_ticket lt
                      where lt.id in (select column_value from table(cast(l_tickets_id_tab as num_tab_tpt))) 
                        and c.id = lt.customer_id
                    )
                )) -- xmlagg(xmlelement("lottery_tickets"...
            ).getclobval()
        from dual;

    procedure save_file is
        l_cnt   pls_integer;
    begin
        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            , i_value    => i_inst_id
            , io_params  => l_params
        );

        prc_api_file_pkg.open_file(
            o_sess_file_id => l_session_file_id
          , i_file_type    => l_file_type
          , io_params      => l_params
        );

        l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

        prc_api_file_pkg.put_file(
            i_sess_file_id  => l_session_file_id
          , i_clob_content  => l_file
        );

        l_cnt := l_tickets_id_tab.count;

        prc_api_file_pkg.close_file(
            i_sess_file_id   => l_session_file_id
          , i_status         => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count   => l_cnt
        );

        trc_log_pkg.debug('file saved, cnt=' || l_cnt || ', length=' || length(l_file));

        prc_api_stat_pkg.log_current(
            i_current_count  => l_cnt
          , i_excepted_count => 0
        );
    end save_file;

begin
    trc_log_pkg.debug('export_file - Start');

    prc_api_stat_pkg.log_start;

    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    l_sysdate         := get_sysdate;

    savepoint sp_lottery_tickets_export;

    select o.id
         , lt.id
      bulk collect into 
           l_event_tab
         , l_tickets_id_tab   
      from evt_event_object o
         , lty_lottery_ticket lt
         , prd_customer c
     where decode(o.status, 'EVST0001', o.procedure_name, null) = 'LTY_PRC_LOTTERY_TICKETS_PKG.EXPORT_FILE'
       and o.eff_date      <= l_sysdate
       and (i_inst_id       = ost_api_const_pkg.DEFAULT_INST or lt.inst_id = i_inst_id)
       and o.entity_type    = lty_api_const_pkg.ENTITY_TYPE_LOTTERY_TICKET
       and o.object_id      = lt.id
       and c.id             = lt.customer_id;

    l_estimated_count := l_tickets_id_tab.count;
    
    trc_log_pkg.debug(
        i_text => 'Estimate count = [' || l_estimated_count || ']'
    );

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );

    -- generate xml
    if l_estimated_count > 0 then
        open  main_xml_cur;
        fetch main_xml_cur into l_file;
        close main_xml_cur;

        save_file;

        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab    => l_event_tab
        );

        -- set ticket status closed
        forall i in 1 .. l_tickets_id_tab.count
            update lty_lottery_ticket
               set status = lty_api_const_pkg.LOTTERY_TICKET_CLOSED
             where id = l_tickets_id_tab(i);
    end if;
    
    prc_api_stat_pkg.log_end(
        i_processed_total   => l_estimated_count
      , i_excepted_total    => 0
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('export_file - End');

exception
    when others then
        rollback to sp_lottery_tickets_export;

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

end export_file;

end;
/
