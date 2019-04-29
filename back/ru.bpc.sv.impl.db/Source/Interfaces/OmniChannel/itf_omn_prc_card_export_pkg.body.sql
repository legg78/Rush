create or replace package body itf_omn_prc_card_export_pkg is
/*********************************************************
 *  Card export process <br />
 *  Created by Nick (shalnov@bpcbt.com) at 25.04.2018 <br />
 *  Last changed by $Author: Nick $ <br />
 *  $LastChangedDate:: 2018-04-25 11:28:00 +0400#$ <br />
 *  Module: itf_omn_prc_card_export_pkg <br />
 *  @headcom
 **********************************************************/

procedure export_card_engine_1_0(
    i_inst_id           in    com_api_type_pkg.t_inst_id
  , i_array_service_id  in    com_api_type_pkg.t_tiny_id
  , i_masking_card      in    com_api_type_pkg.t_boolean
  , i_full_export       in    com_api_type_pkg.t_boolean
  , i_lang              in    com_api_type_pkg.t_dict_value
)
is
    LOG_PREFIX    constant com_api_type_pkg.t_name       := lower($$PLSQL_UNIT) || '.export_cards(export_card_engine_1_0): ';
    C_CRLF       constant  com_api_type_pkg.t_name := chr(13)||chr(10);
    l_sysdate              date := get_sysdate;
    l_sess_file_id         com_api_type_pkg.t_long_id;
    l_file                 clob;
    l_estimated_count      pls_integer := 0;
    l_card_id_tab          num_tab_tpt := num_tab_tpt();
    l_event_tab            num_tab_tpt := num_tab_tpt();
    l_stage                com_api_type_pkg.t_name;

    cursor main_xml_cur is
        with rawdata as (
            select ci.card_uid                                   as card_uid
                 , case when i_masking_card = com_api_const_pkg.TRUE
                       then
                           iss_api_card_pkg.get_card_mask(i_card_number => icn.card_number)
                       else
                           iss_api_token_pkg.decode_card_number(i_card_number => icn.card_number)
                   end                                           as card_number
                 , c.card_type_id                                as card_type_id
                 , cu.id                                         as customer_id
                 , cu.customer_number                            as customer_number
                 , co.id                                         as contract_id
                 , co.contract_number                            as contract_number
                 , cast(multiset(select com_api_i18n_pkg.get_text(
                                            i_table_name  => 'PRD_SERVICE_TYPE'
                                          , i_column_name => 'LABEL'
                                          , i_object_id   => st.id
                                          , i_lang        => i_lang
                                        )                        as service_type_name
                                      , to_char(st.id)           as service_type_id
                                      , s.service_number         as service_number
                                      , st.external_code         as service_type_ext_code
                                   from prd_service_object so
                                   left join prd_service s on so.service_id = s.id
                                                          and s.status      = prd_api_const_pkg.SERVICE_STATUS_ACTIVE
                                   left join prd_service_type st on s.service_type_id = st.id
                                  where so.object_id   = c.id
                                    and so.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                       ) as service_tab_tpt
                   )                                             as active_service_list
                 , cast(multiset((select com_api_i18n_pkg.get_text(
                                             i_table_name  => 'PRD_SERVICE_TYPE'
                                           , i_column_name => 'LABEL'
                                           , i_object_id   => st.id
                                           , i_lang        => i_lang
                                         )                       as service_type_name
                                       , to_char(st.id)          as service_type_id
                                       , s.service_number        as service_number
                                       , st.external_code        as service_type_ext_code
                                   from prd_product_service ps
                                   left join prd_service    s on ps.service_id = s.id
                                                             and s.status      = prd_api_const_pkg.SERVICE_STATUS_ACTIVE
                                   left join prd_service_type st on s.service_type_id = st.id
                                  where ps.product_id = p.id
                                    and ps.max_count > 0                                        
                                 )
                       ) as service_tab_tpt
                   )                                             as avaiable_service_list
              from iss_card c
              join iss_card_instance     ci on c.id             = ci.card_id
              join iss_card_number      icn on c.id             = icn.card_id
              join prd_customer          cu on cu.id            = c.customer_id
              join prd_contract          co on co.id            = cu.contract_id
              left join prd_product          p on p.id          = co.product_id
              where c.id in (
                  select column_value
                    from table(l_card_id_tab)
              )
        )
        select com_api_const_pkg.XML_HEADER || C_CRLF ||
               xmlelement(
                   "cards"
                 , xmlattributes('http://sv.bpc.in/SVXP/Cards' as "xmlns")
                 , xmlelement("file_id"  , to_char(l_sess_file_id))
                 , xmlelement("file_type", itf_api_const_pkg.FILE_TYPE_CARD_SERVICE)
                 , xmlelement("inst_id"  , to_char(i_inst_id))
                 ,     xmlagg(                    
                           xmlelement(
                               "card"
                             , xmlelement("card_id"              , card_uid)
                             , xmlelement("card_number"          , card_number)
                             , xmlelement("card_type"            , card_type_id)
                             , xmlelement(
                                   "customer"
                                 , xmlelement("customer_id"      , customer_id)
                                 , xmlelement("customer_number"  , customer_number)
                               )
                             , xmlelement(
                                   "contract"
                                 , xmlelement("contract_id"      , contract_id)
                                 , xmlelement("contract_number"  , contract_number)
                               )
                             , (select xmlagg(
                                   xmlelement(
                                       "available_services"
                                     , xmlelement("service_type"          , service_type_id)
                                     , xmlelement("service_type_name"     , service_type_name)
                                     , xmlelement("service_external_code" , service_type_ext_code)
                                     , xmlelement("service_number"        , service_number)
                                   )
                                ) from table(avaiable_service_list)
                               )
                             , (select xmlagg(
                                   xmlelement(
                                       "attached_services"
                                     , xmlelement("service_type"          , service_type_id)
                                     , xmlelement("service_type_name"     , service_type_name)
                                     , xmlelement("service_external_code" , service_type_ext_code)
                                     , xmlelement("service_number"        , service_number)
                                   )
                                ) from table(active_service_list)
                               )
                           )
                       )
               ).getclobval() as card_data
          from rawdata;
begin
    trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'Start'
    );
    l_stage := 'Init';
    prc_api_stat_pkg.log_start;
    
    if i_full_export = com_api_const_pkg.TRUE then
        select c.id
          bulk collect
          into l_card_id_tab
          from iss_card c
          join prd_contract con on c.contract_id = con.id
          join prd_product p on con.product_id = p.id
                            and p.status = prd_api_const_pkg.PRODUCT_STATUS_ACTIVE
                            and exists (
                                select 1
                                  from prd_product_service ps
                                  join prd_service s on ps.service_id = s.id
                                                    and s.status = prd_api_const_pkg.SERVICE_STATUS_ACTIVE 
                                  join prd_service_type pt on s.service_type_id = pt.id
                                                          and pt.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD 
                                 where ps.product_id = p.id
                                   and ps.max_count > 0
                                   and ps.service_id in (select to_number(element_value) val
                                                           from com_array_element
                                                          where array_id = i_array_service_id)
                            )
         where 1 = 1
           and (c.inst_id = i_inst_id or i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST);
    else
        select card_id
             , ev_obj_id
          bulk collect
          into l_card_id_tab
             , l_event_tab
          from (
            select c.id as card_id
                 , e.id as ev_obj_id
          from iss_card c
          join prd_contract con on c.contract_id = con.id
          join prd_product p on con.product_id = p.id
                            and p.status = prd_api_const_pkg.PRODUCT_STATUS_ACTIVE
                            and exists (
                                select 1
                                  from prd_product_service ps
                                  join prd_service s on ps.service_id = s.id
                                                    and s.status = prd_api_const_pkg.SERVICE_STATUS_ACTIVE
                                  join prd_service_type pt on s.service_type_id = pt.id
                                                          and pt.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD 
                                 where ps.product_id = p.id
                                   and ps.max_count > 0
                                   and ps.service_id in (select to_number(element_value) val
                                                           from com_array_element
                                                          where array_id = i_array_service_id)
                            )
          join evt_event_object e on e.object_id = p.id
                                 and e.entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                                 and decode(e.status, 'EVST0001', e.procedure_name, null) = 'ITF_OMN_PRC_CARD_EXPORT_PKG.EXPORT_CARDS'
             where (c.inst_id = i_inst_id or i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
             union
            select e.object_id as card_id
                 , e.id        as ev_obj_id
              from evt_event_object e
               where e.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                 and decode(e.status, 'EVST0001', e.procedure_name, null) = 'ITF_OMN_PRC_CARD_EXPORT_PKG.EXPORT_CARDS'
                 and exists (
                    select 1
                      from iss_card ic
                      join prd_contract c on ic.contract_id = c.id
                      join prd_product p on c.product_id = p.id
                                        and p.status = prd_api_const_pkg.PRODUCT_STATUS_ACTIVE
                     where ic.id = e.object_id
                       and (c.inst_id = i_inst_id or i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                       and exists (
                            select 1
                              from prd_product_service ps
                              join prd_service s on ps.service_id = s.id
                                                and s.status = prd_api_const_pkg.SERVICE_STATUS_ACTIVE
                              join prd_service_type pt on s.service_type_id = pt.id
                                                      and pt.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                             where ps.product_id = p.id
                               and ps.max_count > 0
                               and ps.service_id in (select to_number(element_value) val
                                                       from com_array_element
                                                      where array_id = i_array_service_id)
                        )
                 )
          );
    end if;
    
    trc_log_pkg.debug(
        i_text => 'non uniq card count [' || l_card_id_tab.count || '] eo to process count [' || l_event_tab.count ||']'
    );
    l_card_id_tab := set(l_card_id_tab);
    
    l_estimated_count := l_card_id_tab.count;
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' estimated [#1] unique cards'
      , i_env_param1 => l_estimated_count
    );
    l_stage := 'Process ' || l_estimated_count;
    
    if l_estimated_count > 0 then
        prc_api_file_pkg.open_file(
            o_sess_file_id => l_sess_file_id
          , i_file_type    => itf_api_const_pkg.FILE_TYPE_CARD_SERVICE
          , i_file_purpose => prc_api_const_pkg.FILE_PURPOSE_OUT
        );
        
        l_stage := 'Fetch';
        --
         open main_xml_cur;
        fetch main_xml_cur
         into l_file;
        close main_xml_cur; 
        
        l_stage := 'Put';
        prc_api_file_pkg.put_file(
            i_sess_file_id  => l_sess_file_id
          , i_clob_content  => l_file
        );
        
        if i_full_export = com_api_const_pkg.FALSE then
            l_stage := 'Set event object';
            
            l_event_tab := set(l_event_tab);
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || ' estimated [#1] processed events'
              , i_env_param1 => l_event_tab.count
            );
            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab    => l_event_tab
            );
            select id
              bulk collect
              into l_event_tab
              from evt_event_object e
             where e.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and decode(e.status, 'EVST0001', e.procedure_name, null) = 'ITF_OMN_PRC_CARD_EXPORT_PKG.EXPORT_CARDS'
               and exists (
                    select 1
                      from iss_card c
                     where c.id = e.object_id
                       and (c.inst_id = i_inst_id or i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
               );
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'mark as processed remains [#1] event'
              , i_env_param1 => l_event_tab.count
            );
            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab    => l_event_tab
            );
        end if;
        
        l_stage := 'Close';
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_sess_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count  => l_estimated_count
        );
                    
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'file saved, cnt=' || l_estimated_count || ', length=' || length(l_file)
        );
                                          
        prc_api_stat_pkg.log_current (
            i_current_count   => l_estimated_count
          , i_excepted_count  => 0
        );
    else
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'no data to export'
        );
    end if;
    
    prc_api_stat_pkg.log_end(
        i_processed_total   => l_estimated_count
      , i_excepted_total    => 0
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || sqlerrm || ' on stage ' || l_stage
        );
        raise;
end;

-- entry point, interface
procedure export_cards(
    i_omni_version      in    com_api_type_pkg.t_attr_name
  , i_inst_id           in    com_api_type_pkg.t_inst_id
  , i_array_service_id  in    com_api_type_pkg.t_tiny_id
  , i_export_clear_pan  in    com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE  
  , i_full_export       in    com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_lang              in    com_api_type_pkg.t_dict_value default com_api_const_pkg.DEFAULT_LANGUAGE
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name       := lower($$PLSQL_UNIT) || '.export_cards: ';
    l_lang                 com_api_type_pkg.t_dict_value := nvl(i_lang, com_api_const_pkg.DEFAULT_LANGUAGE);
    l_full_export          com_api_type_pkg.t_boolean    := nvl(i_full_export, com_api_const_pkg.FALSE);
    l_masking_card         com_api_type_pkg.t_boolean    := com_api_type_pkg.boolean_not(nvl(i_export_clear_pan, com_api_const_pkg.TRUE));
begin

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START'
    );
    
    if i_omni_version between '1.0' and '1.0' then
        export_card_engine_1_0(
            i_inst_id          => i_inst_id
          , i_array_service_id => i_array_service_id
          , i_masking_card     => l_masking_card
          , i_full_export      => l_full_export
          , i_lang             => l_lang
        );
    elsif i_omni_version between '2.0' and '3.0' then
        export_card_engine_1_0(
            i_inst_id          => i_inst_id
          , i_array_service_id => i_array_service_id
          , i_masking_card     => l_masking_card
          , i_full_export      => l_full_export
          , i_lang             => l_lang
        );
    else
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1  => i_omni_version
        );
    end if;
    
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'END' 
    );
    
exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || sqlerrm
        );

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
        else
            raise;
        end if;
        
end export_cards;

end itf_omn_prc_card_export_pkg;
/
