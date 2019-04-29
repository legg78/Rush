create or replace package body prd_prc_customer_export_pkg is
/*********************************************************
 *  process for customers export to XML file <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 29.05.2012 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: prd_prc_customer_export_pkg <br />
 *  @headcom
 **********************************************************/
 
procedure process(
    i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_full_export   in  com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , i_lang          in  com_api_type_pkg.t_dict_value   default com_api_const_pkg.DEFAULT_LANGUAGE
) is
    l_sysdate            date := get_sysdate;
    l_sess_file_id       com_api_type_pkg.t_long_id;
    l_file               clob;
    l_estimated_count    pls_integer := 0;
    l_count              pls_integer := 0;
    c_crlf               constant  com_api_type_pkg.t_name := chr(13)||chr(10);
    l_customer_id_tab    num_tab_tpt;
    l_event_tab          com_api_type_pkg.t_number_tab;
    l_full_export        com_api_type_pkg.t_boolean;
    BULK_LIMIT           simple_integer := 2000;
    
    cursor cu_event_objects is
        select c.id as customer_id
             , o.id as event_object_id
          from evt_event_object o
             , evt_event e
             , evt_subscriber s
             , prd_customer c
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'PRD_PRC_CUSTOMER_EXPORT_PKG.PROCESS'
           and o.eff_date      <= l_sysdate
           and e.id             = o.event_id
           and e.event_type     = s.event_type
           and o.procedure_name = s.procedure_name
           and o.object_id      = c.id
           and (c.inst_id       = i_inst_id or i_inst_id is null)
           and c.entity_type in ('ENTTUNDF',  'ENTTPERS')
      order by o.id;
    
    cursor cu_all_customers is
        select c.id as customer_id
          from prd_customer c
         where (c.inst_id       = i_inst_id or i_inst_id is null)
           and c.entity_type in ('ENTTUNDF',  'ENTTPERS')
      order by c.id;

    cursor main_xml_cur is
             select xmlelement("customers", xmlattributes('http://sv.bpc.in/SVXP' as "xmlns")
                  , xmlelement("file_id",   to_char(l_sess_file_id,'TM9') )
                  , xmlelement("file_type", 'FLTP5016' )
                  , xmlelement("file_date", to_char(get_sysdate,'yyyy-mm-dd') )
                  ,     xmlagg(                    
                            xmlelement("customer"
                            ,  xmlattributes(to_char(c.id, 'TM9') as "id")
                            ,  xmlelement("customer_number",      c.customer_number )
                            ,  xmlelement("customer_type",        c.entity_type )
                            ,  xmlelement("customer_category",    c.category )
                            ,  case when c.relation is not null then xmlelement("customer_relation", c.relation ) end
                            ,  case when c.resident is not null then xmlelement("resident",          c.resident ) end
                            ,  case when c.nationality is not null then xmlelement("nationality", c.nationality ) end  
                            ,  case when c.credit_rating is not null  then xmlelement("credit_rating",  c.credit_rating ) end
                            ,  case when c.money_laundry_risk is not null then xmlelement("money_laundry_risk",  c.money_laundry_risk ) end 
                            ,  case when c.money_laundry_reason is not null then xmlelement("money_laundry_reason", c.money_laundry_reason ) end
                            ,  xmlelement("customer_status", c.status)
                            ,  case when c.status_reason is not null then xmlelement("customer_status", c.status_reason) end
                            ,  case when c.reg_date is not null then xmlelement("reg_date", c.reg_date) end
                            ,  case when c.status = prd_api_const_pkg.CUSTOMER_STATUS_INACTIVE then xmlelement("close_date", c.last_modify_date) end
                            ,  (select xmlagg(
                                   xmlelement("contract"
                                         , xmlelement("contract_number", x.contract_number) 
                                             , xmlelement("start_date", to_char(x.start_date, 'yyyy-mm-dd'))
                                           ) )
                                  from prd_contract x
                                 where x.customer_id = c.id
                                   and contract_type in ('CNTPBANK','CNTPEWLT')
                               )
                            ,  xmlagg( 
                                  (select xmlelement("person"
                                        , xmlattributes(to_char(p.id, 'TM9') as "id")
                                        , case when p.title is not null then xmlelement("person_title", p.title   ) end
                                        , xmlagg(
                                             (select xmlagg(
                                                         xmlelement("person_name"
                                                       , xmlattributes(q.lang as "language")
                                                       , xmlelement("surname",     q.surname      )
                                                       , xmlelement("first_name",  q.first_name   )
                                                       , case when q.second_name is not null 
                                                              then xmlelement("second_name", q.second_name  ) 
                                                         end
                                                         )
                                                     )
                                                from com_person q
                                               where q.id = p.id
                                             )
                                           )
                                        , case when p.suffix is not null then xmlelement("suffix",   p.suffix  ) end
                                        , case when p.birthday is not null then xmlelement("birthday", p.birthday) end
                                        , case when p.place_of_birth is not null then xmlelement("place_of_birth", p.place_of_birth) end
                                        , case when p.gender is not null then xmlelement("gender", p.gender) end
                                        , xmlagg(   
                                             (select xmlagg( 
                                                         xmlelement("identity_card" 
                                                       , xmlelement("id_type",        o.id_type   )
                                                       , xmlelement("id_series",      o.id_series )
                                                       , xmlelement("id_number",      o.id_number )
                                                       , xmlelement("id_issuer",      o.id_issuer )
                                                       , case when o.id_issue_date  is not null then xmlelement("id_issue_date",  o.id_issue_date) end
                                                       , case when o.id_expire_date is not null then xmlelement("id_expire_date", o.id_expire_date) end 
                                                       , (select xmlelement("id_desc", min(t.id_type_desc)  ) 
                                                            from com_ui_id_type_vw t
                                                          where t.lang = nvl(i_lang, com_api_const_pkg.DEFAULT_LANGUAGE) and t.id_type = o.id_type)
                                                         )
                                                     )
                                                from com_id_object o 
                                               where o.entity_type = c.entity_type and o.object_id = c.object_id
                                             )
                                           )
                                          ) 
                                       from com_person p 
                                      where c.entity_type = 'ENTTPERS'
                                        and p.id          = c.object_id
                                        and rownum        = 1
                                   group by p.id , p.title, p.surname, p.suffix, p.birthday, p.place_of_birth, p.gender
                                     having p.id is not null
                                  )
                               )
                            ,  (select xmlagg(
                                            xmlelement("contact"
                                            ,  xmlelement("contact_type",   y.contact_type   )
                                            ,  xmlelement("preferred_lang", x.preferred_lang   )
                                            ,  case when x.job_title is not null then xmlelement("job_title", x.job_title) end
                                            ,  (select xmlelement("person"
                                                    ,  xmlattributes(to_char(z.id, 'TM9') as "id")
                                                    ,  case when z.title is not null then xmlelement("person_title", z.title) end
                                                    ,  xmlelement("person_name"
                                                        ,  xmlattributes(z.lang as "language")
                                                        ,  xmlelement("surname",     z.surname     )
                                                        ,  xmlelement("first_name",  z.first_name  )
                                                        ,  case when z.second_name is not null 
                                                           then xmlelement("second_name", z.second_name  ) 
                                                           end
                                                       )
                                                    ,  xmlelement("suffix",       z.suffix  )
                                                    ,  case when z.birthday is not null then xmlelement("birthday", z.birthday) end
                                                    ,  case when z.place_of_birth is not null then xmlelement("place_of_birth", z.place_of_birth) end 
                                                    ,  case when z.gender is not null then xmlelement("gender", z.gender) end 
                                                       )
                                                  from com_person    z 
                                                 where z.id = x.person_id and z.id is not null
                                               )
                                             , (select xmlagg(
                                                           xmlelement("contact_data"
                                                             , xmlelement("commun_method",  d.commun_method)
                                                             , xmlelement("commun_address", d.commun_address)
                                                           )
                                                       )
                                                 from com_contact_data d
                                                where d.contact_id  = y.contact_id
                                                  and (d.end_date is null or d.end_date > l_sysdate)
                                               )
                                            )
                                       ) 
                                  from com_contact x
                                     , com_contact_object y
                                 where x.id          = y.contact_id
                                   and y.entity_type = 'ENTTCUST'
                                   and y.object_id   = c.id
                               )
                            ,  (select xmlagg(
                                          xmlelement("address"
                                           ,  xmlattributes(to_char(a.id, 'TM9') as "id")
                                           ,  xmlelement("address_type", o.address_type)
                                           ,  xmlelement("country",      a.country) 
                                           , (select xmlagg(
                                                         xmlelement("address_name"
                                                           , xmlattributes(q.lang as "language" )
                                                           , xmlelement("region", q.region  )
                                                           , xmlelement("city",   q.city    )
                                                           , xmlelement("street", q.street  )
                                                         )
                                                     )
                                                from com_address q
                                               where q.id = a.id
                                             )
                                           ,  xmlelement("house",        a.house)
                                           ,  xmlelement("apartment",    a.apartment) 
                                           ,  xmlelement("postal_code",  a.postal_code) 
                                           ,  xmlelement("region_code",  a.region_code)
                                           , case when a.latitude is not null then xmlelement("latitude",  a.latitude) end
                                           , case when a.longitude is not null then xmlelement("longitude", a.longitude) end
                                          )
                                       )
                                  from com_address a
                                     , com_address_object o
                                 where o.object_id   = c.id
                                   and o.entity_type = 'ENTTCUST'
                                   and o.address_id  = a.id
                               ) 
                            )
                        )
                    ).getclobval() as customer_data
               from (
                 select c.id
                      , c.customer_number
                      , c.entity_type
                      , c.category
                      , c.relation
                      , c.resident
                      , c.nationality
                      , c.credit_rating
                      , c.money_laundry_risk
                      , c.money_laundry_reason
                      , c.status
                      , c.last_modify_date
                      , c.reg_date
                      , c.object_id
                      , evt_api_status_pkg.get_status_reason(
                            i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                          , i_object_id     => c.id
                          , i_raise_error   => com_api_const_pkg.FALSE
                        ) as status_reason
                   from prd_customer c
                  where c.id in (select column_value from table(cast(l_customer_id_tab as num_tab_tpt))) 
               group by c.id
                      , c.customer_number
                      , c.entity_type
                      , c.category
                      , c.relation
                      , c.resident
                      , c.nationality
                      , c.credit_rating
                      , c.money_laundry_risk
                      , c.money_laundry_reason
                      , c.status
                      , c.last_modify_date
                      , c.reg_date
                      , c.object_id
               ) c;

    procedure save_file is
    begin
        l_file := com_api_const_pkg.XML_HEADER || C_CRLF || l_file;

        prc_api_file_pkg.put_file(
            i_sess_file_id  => l_sess_file_id
          , i_clob_content  => l_file
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_sess_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count  => l_customer_id_tab.count 
        );
                    
        trc_log_pkg.debug('file saved, cnt='||l_customer_id_tab.count||', length='||length(l_file));
                                          
        prc_api_stat_pkg.log_current (
            i_current_count     => l_customer_id_tab.count
            , i_excepted_count  => 0
        );
    end;

begin
    trc_log_pkg.debug('Start documents export: sysdate=['||l_sysdate||'] thread_number=['||get_thread_number||']');

    prc_api_stat_pkg.log_start;

    savepoint sp_customers_export;

    l_full_export   := nvl(i_full_export, com_api_type_pkg.FALSE);    

    if l_full_export = com_api_type_pkg.TRUE then

        select count(1)
          into l_estimated_count
          from prd_customer c
         where (c.inst_id = i_inst_id or i_inst_id is null)
           and c.entity_type in ('ENTTUNDF',  'ENTTPERS')
        ;
        
        trc_log_pkg.debug(
            i_text =>'Estimate count = [' || l_estimated_count || ']'
        );
               
        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
          , i_measure         => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
        );
        
        open cu_all_customers;
        
        loop
            fetch cu_all_customers bulk collect into
                  l_customer_id_tab       
            limit BULK_LIMIT;
            
            --generate xml
            if l_customer_id_tab.count > 0 then
            
                prc_api_file_pkg.open_file(
                    o_sess_file_id => l_sess_file_id
                );

                open  main_xml_cur;
                fetch main_xml_cur into l_file;
                close main_xml_cur; 
                                            
                save_file;           
                
            end if;
            
            exit when cu_all_customers%notfound;

        end loop;

        close cu_all_customers;    

    else       

        select count(1)
          into l_estimated_count
          from (
                select c.id as customer_id
                     , o.id as event_object_id
                  from evt_event_object o
                     , evt_event e
                     , evt_subscriber s
                     , prd_customer c
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = 'PRD_PRC_CUSTOMER_EXPORT_PKG.PROCESS'
                   and o.eff_date      <= l_sysdate
                   and e.id             = o.event_id
                   and e.event_type     = s.event_type
                   and o.procedure_name = s.procedure_name
                   and o.object_id      = c.id
                   and (c.inst_id       = i_inst_id or i_inst_id is null)
                   and c.entity_type in ('ENTTUNDF',  'ENTTPERS')
        );        

        trc_log_pkg.debug(
            i_text =>'Estimate count = [' || l_estimated_count || ']'
        );
               
        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
          , i_measure         => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
        );
        
        open cu_event_objects;
        
        loop
            fetch cu_event_objects bulk collect into
                  l_customer_id_tab
                , l_event_tab
            limit BULK_LIMIT;
            
            trc_log_pkg.debug(
                i_text =>'l_customer_id_tab.count = [' || l_customer_id_tab.count || ']'
            );
            --generate xml
            if l_customer_id_tab.count > 0 then
            
                prc_api_file_pkg.open_file(
                    o_sess_file_id => l_sess_file_id
                );

                open  main_xml_cur;
                fetch main_xml_cur into l_file;
                close main_xml_cur; 
                           
                save_file; 
                
                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab    => l_event_tab
                );                          
                
            end if;
            
            exit when cu_event_objects%notfound;

        end loop;

        close cu_event_objects;    
    
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_estimated_count
      , i_excepted_total    => 0
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('finish');
exception
    when others then
        rollback to savepoint sp_customers_export;
            
        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        select count(*)
          into l_count
          from prc_session_file f
         where f.id = l_sess_file_id;
         
        if l_sess_file_id is not null and l_count > 0 then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_sess_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
        raise;

end;

end;
/
