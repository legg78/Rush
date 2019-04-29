create or replace package body cst_zb_prc_outgoing_pkg is
/**********************************************************
 * Custom handlers for uploading various data for ZB
 *
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 28.01.2019<br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CST_ZB_PRC_OUTGOING_PKG
 * @headcom
 **********************************************************/

procedure uploading_merchant_rbfile(
    i_inst_id                   in     com_api_type_pkg.t_inst_id
  , i_full_export               in     com_api_type_pkg.t_boolean      default null
) is
    PROC_NAME     constant com_api_type_pkg.t_name      := lower($$PLSQL_UNIT) || '.uploading_merchant_rbfile: ';
    
    ADD_RECORD    constant com_api_type_pkg.t_attr_name := 'add';
    MODIFY_RECORD constant com_api_type_pkg.t_attr_name := 'modify';
    DELETE_RECORD constant com_api_type_pkg.t_attr_name := 'delete';
    
    type t_filtered_data is table of num_tab_tpt index by com_api_type_pkg.t_attr_name;

    l_full_export          com_api_type_pkg.t_boolean   := nvl(i_full_export, com_api_type_pkg.FALSE);

    l_estimated_count      com_api_type_pkg.t_long_id   := 0;
    l_processed_count      com_api_type_pkg.t_long_id   := 0;
    l_excepted_count       com_api_type_pkg.t_long_id   := 0;
    l_rejected_count       com_api_type_pkg.t_long_id   := 0;
    l_merchant_count       com_api_type_pkg.t_long_id   := 0;
    
    l_container_id         com_api_type_pkg.t_long_id;
    
    l_eff_date             date;

    l_evt_objects_tab      num_tab_tpt := num_tab_tpt();
    l_filtered_id          t_filtered_data;
    
    l_session_file_id      com_api_type_pkg.t_long_id;
    l_file_content         clob;
begin

    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text        => PROC_NAME || 'Start'
    );

    l_eff_date      := com_api_sttl_day_pkg.get_sysdate;
    l_container_id  :=  prc_api_session_pkg.get_container_id;

    trc_log_pkg.debug(
        i_text        => PROC_NAME || ' l_full_export [#1]'
      , i_env_param1  => l_full_export
    );
    
    l_filtered_id(ADD_RECORD)    := num_tab_tpt();
    l_filtered_id(MODIFY_RECORD) := num_tab_tpt();
    l_filtered_id(DELETE_RECORD) := num_tab_tpt();
    
    if l_full_export = com_api_type_pkg.TRUE then
        for r in (select m.id
                       , m.status
                    from acq_merchant m
                   where m.inst_id = i_inst_id
                 )
       
        loop
            l_filtered_id(ADD_RECORD).extend;
            l_filtered_id(ADD_RECORD)(l_filtered_id(ADD_RECORD).last) := r.id;
            
            l_filtered_id(MODIFY_RECORD).extend;
            l_filtered_id(MODIFY_RECORD)(l_filtered_id(ADD_RECORD).last) := r.id;
            
            if r.status = acq_api_const_pkg.MERCHANT_STATUS_CLOSED then
                l_filtered_id(DELETE_RECORD).extend;
                l_filtered_id(DELETE_RECORD)(l_filtered_id(DELETE_RECORD).last) := r.id;
            end if;
            
        end loop;

        l_estimated_count := l_filtered_id(ADD_RECORD).count
                           + l_filtered_id(MODIFY_RECORD).count
                           + l_filtered_id(DELETE_RECORD).count;
        l_merchant_count  := l_estimated_count;
    else
        for r in (
                    select s.id
                         , decode(s.rn, 1, s.object_id, null) as merchant_id
                         , decode(s.rn, 1, s.event_type, null) as event_type
                      from (
                            select eo.id
                                 , eo.object_id
                                 , eo.event_type
                                 , row_number() over(partition by eo.object_id, eo.event_type order by eo.id) as rn
                              from evt_event_object eo
                             where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_ZB_PRC_OUTGOING_PKG.UPLOADING_MERCHANT_RBFILE'
                               and eo.entity_type      = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                               and eo.eff_date        <= l_eff_date
                               and eo.inst_id          = i_inst_id
                               and (eo.container_id    = l_container_id  or eo.container_id is null)
                               and eo.event_type      in (
                                       acq_api_const_pkg.EVENT_MERCHANT_CREATION
                                     , acq_api_const_pkg.EVENT_MERCHANT_CHANGE
                                     , acq_api_const_pkg.EVENT_MERCHANT_CLOSE
                                   )
                           ) s
                 )
        loop
            l_evt_objects_tab.extend;
            l_evt_objects_tab(l_evt_objects_tab.last) := r.id;
            
            if r.event_type = acq_api_const_pkg.EVENT_MERCHANT_CREATION then
                l_filtered_id(ADD_RECORD).extend;
                l_filtered_id(ADD_RECORD)(l_filtered_id(ADD_RECORD).last) := r.merchant_id;
            elsif r.event_type = acq_api_const_pkg.EVENT_MERCHANT_CHANGE then
                l_filtered_id(MODIFY_RECORD).extend;
                l_filtered_id(MODIFY_RECORD)(l_filtered_id(ADD_RECORD).last) := r.merchant_id;
            elsif r.event_type = acq_api_const_pkg.EVENT_MERCHANT_CLOSE then
                l_filtered_id(DELETE_RECORD).extend;
                l_filtered_id(DELETE_RECORD)(l_filtered_id(DELETE_RECORD).last) := r.merchant_id;
            end if;
            
        end loop;
        
        l_estimated_count := l_evt_objects_tab.count;
        l_merchant_count  := l_filtered_id(ADD_RECORD).count
                          + l_filtered_id(MODIFY_RECORD).count
                          + l_filtered_id(DELETE_RECORD).count;

    end if;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count    => l_estimated_count
    );
    
    trc_log_pkg.debug(
        i_text        => PROC_NAME || 'Full quantity of merchant records will be processed - [#1]'
      , i_env_param1  => l_merchant_count
    );

    if l_estimated_count > 0 then
        select com_api_const_pkg.XML_HEADER 
            || xmlelement(
                   "xs:script"
                 , xmlattributes(
                       'http://bpc.ru/SVAT/mobilebank/import/service/content/xml' as "xmlns:xs"
                     , 'http://www.w3.org/2001/XMLSchema-instance' as "xmlns:xsi"
                     , 'http://bpc.ru/SVAT/mobilebank/import/service/content/xml service_content_script.xsd' as "xsi:schemaLocation"
                   )
                 , xmlagg(
                         case s.record_type
                               when ADD_RECORD 
                                   then xmlelement(
                                            "xs:add"
                                          , xmlattributes('m-' || s.id as "id")
                                          , xmlelement("xs:merchant", s.xml_data)
                                        )
                               when MODIFY_RECORD 
                                   then xmlelement(
                                            "xs:modify"
                                          , xmlattributes('mm-' || s.id as "id")
                                          , xmlelement(
                                                "xs:merchant-ref"
                                              , xmlelement(
                                                    "xs:referenceId"
                                                  , s.id
                                                )
                                            )
                                          , xmlelement("xs:merchant-changes", s.xml_data)
                                        )
                               when DELETE_RECORD
                                   then xmlelement(
                                           "xs:delete"
                                         , xmlattributes('dm-' || s.id as "id")
                                         , s.xml_data
                                        ) 
                               else null
                          end
                          order by 
                                decode(s.record_type, ADD_RECORD, 0, MODIFY_RECORD, 1, DELETE_RECORD, 2, null) nulls last
                              , s.id
                   )
               ).getClobVal()
          into l_file_content
          from (
                select m.id
                     , d.record_type
                     , case
                           when d.record_type in (ADD_RECORD, MODIFY_RECORD)
                               then
                                   xmlconcat(
                                       decode(d.record_type, ADD_RECORD, xmlelement("xs:referenceId", m.id), null)
                                     , xmlelement("xs:merchant_number", m.merchant_number)
                                     , xmlelement("xs:name", m.merchant_name)
                                     , xmlelement("xs:mcc", m.mcc)
                                     , (select xmlagg(
                                                   xmlelement(
                                                       "xs:contact"
                                                     , xmlelement("xs:contact_type", co.contact_type)
                                                     , xmlagg(
                                                           xmlelement(
                                                               "xs:contact_data"
                                                             , xmlelement("xs:commun_method", cd.commun_method)
                                                             , xmlelement("xs:commun_address", cd.commun_address)
                                                           ) order by cd.id
                                                       )
                                                   ) order by co.contact_id, co.contact_type
                                               )
                                          from com_contact_object co
                                             , com_contact_data cd
                                         where co.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                           and co.object_id   = m.id
                                           and cd.contact_id  = co.contact_id
                                         group by
                                               co.contact_id
                                             , co.contact_type
                                       )
                                     , (select xmlagg(
                                                   xmlelement(
                                                       "xs:address"
                                                     , xmlattributes(ao.address_id as "address_id")
                                                     , xmlelement("xs:address_type", ao.address_type)
                                                     , xmlelement("xs:country",      com_api_country_pkg.get_country_name(i_code => a.country))
                                                     , xmlelement("xs:region",       a.region)
                                                     , xmlelement("xs:city",         a.city)
                                                     , xmlelement("xs:street",       a.street)
                                                     , xmlelement("xs:house",        a.house)
                                                     , xmlelement("xs:apartment",    a.apartment)
                                                     , nvl2(a.latitude,  xmlelement("xs:latitude",   a.latitude), null)
                                                     , nvl2(a.longitude, xmlelement("xs:longitude", a.longitude), null)
                                                     , xmlelement("xs:workingHours", null)
                                                     , (select xmlelement(
                                                                   "xs:localizations"
                                                                 , xmlagg(
                                                                       xmlelement(
                                                                           "xs:localization"
                                                                         , xmlattributes(
                                                                               com_api_array_pkg.conv_array_elem_v(
                                                                                   i_lov_id         =>  cst_zb_api_const_pkg.LANGUAGE_SV_DICT_LOV_ID
                                                                                 , i_array_type_id  =>  cst_zb_api_const_pkg.LANG_ISO_ARRAY_TYPE_ID
                                                                                 , i_array_id       =>  cst_zb_api_const_pkg.LANG_ISO_ARRAY_ID
                                                                                 , i_inst_id        =>  i_inst_id
                                                                                 , i_elem_value     =>  b.lang
                                                                                 , i_mask_error     =>  com_api_const_pkg.TRUE
                                                                               ) as "language"
                                                                           )
                                                                         , xmlelement("xs:region",  b.region)
                                                                         , xmlelement("xs:city",    b.city)
                                                                         , xmlelement("xs:street",  b.street)
                                                                       ) order by b.lang
                                                                   )
                                                               )
                                                          from com_address b
                                                         where b.id    = a.id
                                                           and b.lang <> com_api_const_pkg.LANGUAGE_ENGLISH
                                                       )
                                                   ) order by ao.address_id, ao.address_type
                                               )
                                          from com_address_object ao
                                             , com_address a
                                         where ao.object_id   = m.id
                                           and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                           and a.id           = ao.address_id
                                           and a.lang         = com_api_const_pkg.LANGUAGE_ENGLISH
                                       )
                                     , xmlelement("xs:website", null)
                                     , (select xmlelement(
                                                   "xs:localizations"
                                                 , xmlagg(
                                                       xmlelement(
                                                           "xs:localization"
                                                         , xmlattributes(
                                                               com_api_array_pkg.conv_array_elem_v(
                                                                   i_lov_id         =>  cst_zb_api_const_pkg.LANGUAGE_SV_DICT_LOV_ID
                                                                 , i_array_type_id  =>  cst_zb_api_const_pkg.LANG_ISO_ARRAY_TYPE_ID
                                                                 , i_array_id       =>  cst_zb_api_const_pkg.LANG_ISO_ARRAY_ID
                                                                 , i_inst_id        =>  i_inst_id
                                                                 , i_elem_value     =>  c.lang
                                                                 , i_mask_error     =>  com_api_const_pkg.TRUE
                                                               ) as "language"
                                                           )
                                                         , xmlelement("xs:name", c.text)
                                                       ) order by c.lang
                                                   )
                                               )
                                          from com_i18n c
                                         where c.table_name   = 'ACQ_MERCHANT'
                                           and c.object_id    = m.id
                                           and c.column_name  = 'LABEL'
                                           and c.lang        <> com_api_const_pkg.LANGUAGE_ENGLISH
                                       )
                                   )
                           when d.record_type = DELETE_RECORD
                               then
                                   xmlelement(
                                       "xs:merchant-ref"
                                     , xmlelement(
                                           "xs:referenceId"
                                         , m.id
                                       )
                                   )
                           else null
                       end as xml_data
                  from acq_merchant m
                     , (select column_value as merchant_id
                             , ADD_RECORD as record_type
                          from table(l_filtered_id(ADD_RECORD))
                         union all
                        select column_value as merchant_id
                             , MODIFY_RECORD as record_type
                          from table(l_filtered_id(MODIFY_RECORD))
                         union all
                        select column_value as merchant_id
                             , DELETE_RECORD as record_type
                          from table(l_filtered_id(DELETE_RECORD))
                        ) d
                  where m.id = d.merchant_id
                  order by
                        decode(d.record_type, ADD_RECORD, 0, MODIFY_RECORD, 1, DELETE_RECORD, 2)
                ) s;
                
        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_session_file_id
        );

        trc_log_pkg.debug(
            i_text          => PROC_NAME || 'open file success, file_id: [#1]'
          , i_env_param1    => l_session_file_id
        );

        prc_api_file_pkg.put_file(
            i_sess_file_id  => l_session_file_id
          , i_clob_content  => l_file_content
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );

        trc_log_pkg.debug(
            i_text          => PROC_NAME || 'file close success'
        );
    end if;

    l_processed_count := l_estimated_count;

    trc_log_pkg.debug(
        i_text        => PROC_NAME || ' l_evt_objects_tab.count [#1]'
      , i_env_param1  => l_evt_objects_tab.count
    );
    
    if l_evt_objects_tab.count > 0 then
        -- Mark processed event object
        evt_api_event_pkg.process_event_object (
            i_event_object_id_tab  => l_evt_objects_tab
        );
    end if;
    
    trc_log_pkg.debug(
        i_text               => PROC_NAME || 'Finish'
    );

    prc_api_stat_pkg.log_end(
        i_excepted_total     => l_excepted_count
      , i_processed_total    => l_processed_count
      , i_rejected_total     => l_rejected_count
      , i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text           => PROC_NAME || 'Finished with errors: [#1] [#2]'
          , i_env_param1     => sqlcode
          , i_env_param2     => sqlerrm
        );

        l_excepted_count := l_estimated_count;

        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE
           and com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
        then

            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );

        end if;

        raise;

end uploading_merchant_rbfile;

end cst_zb_prc_outgoing_pkg;
/
