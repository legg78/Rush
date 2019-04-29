create or replace package body itf_dwh_prc_cust_export_pkg is

procedure process_1_0(
    i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_full_export   in  com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , i_lang          in  com_api_type_pkg.t_dict_value   default null
) is
    l_sysdate            date := get_sysdate;
    l_sess_file_id       com_api_type_pkg.t_long_id;
    l_file               clob;
    l_estimated_count    pls_integer := 0;
    l_count              pls_integer := 0;
    C_CRLF               constant  com_api_type_pkg.t_name := chr(13)||chr(10);
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
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_DWH_PRC_CUST_EXPORT_PKG.PROCESS'
           and o.eff_date      <= l_sysdate
           and e.id             = o.event_id
           and e.event_type     = s.event_type
           and o.procedure_name = s.procedure_name
           and o.object_id      = c.id
           and (c.inst_id       = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
      order by o.id;
    
    cursor cu_all_customers is
        select c.id as customer_id
          from prd_customer c
         where (c.inst_id       = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
      order by c.id;

    cursor main_xml_cur is
        select xmlelement(
                   "customers"
                 , xmlattributes('http://sv.bpc.in/SVXP/Customers' as "xmlns")
                 , xmlelement("file_id"  , to_char(l_sess_file_id))
                 , xmlelement("file_type", prd_api_const_pkg.FILE_TYPE_CUSTOMERS )
                 , xmlelement("inst_id"  , to_char(i_inst_id))
                 ,     xmlagg(                    
                           xmlelement(
                              "customer"
                           ,  xmlattributes(to_char(c.id) as "customer_id")
                           ,  xmlelement("inst_id"              , c.inst_id)
                           ,  xmlelement("customer_number"      , c.customer_number)
                           ,  xmlforest(c.category              as "customer_category"
                                      , c.ext_entity_type       as "customer_ext_type"
                                      , c.ext_object_id         as "customer_ext_id"
                                      , c.relation              as "customer_relation"
                                      , c.resident              as "resident"
                                      , c.nationality           as "nationality"
                                      , c.credit_rating         as "credit_rating"
                                      , c.money_laundry_risk    as "money_laundry_risk"
                                      , c.money_laundry_reason  as "money_laundry_reason"
                                      , c.status                as "status"
                              )
                           ,  (select xmlagg(
                                          xmlelement(
                                              "contract"
                                             , xmlattributes(to_char(x.id) as "contract_id")
                                             , xmlelement("contract_number", x.contract_number)
                                             , xmlelement("agent_id"       , x.agent_id)
                                             , xmlelement("agent_number"   , a.agent_number)
                                             , xmlelement("contract_type"  , x.contract_type)
                                             , xmlelement("product_id"     , x.product_id)
                                             , xmlforest(p.product_number as "product_number")
                                             , xmlelement("start_date"     , to_char(x.start_date, 'yyyy-mm-dd'))
                                             , xmlforest(to_char(x.end_date, 'yyyy-mm-dd') as "end_date")
                                          ) 
                                      )
                                 from prd_contract x
                                    , ost_agent a
                                    , prd_product p
                                where x.customer_id = c.id
                                  and x.agent_id = a.id(+)
                                  and x.product_id = p.id(+)
                              )
                           ,  (select xmlelement(
                                          "person"
                                        , xmlattributes(p.id as "person_id")
                                        , xmlforest(p.title as "person_title")
                                        , (select xmlagg(
                                                      xmlelement(
                                                          "person_name"
                                                        , xmlattributes(q.lang as "language")
                                                        , xmlelement("surname",     q.surname)
                                                        , xmlelement("first_name",  q.first_name)
                                                        , case when q.second_name is not null
                                                               then xmlelement("second_name", q.second_name  ) 
                                                          end
                                                      )
                                                  )
                                             from com_person q
                                            where q.id = p.id
                                              and (q.lang = i_lang or i_lang is null)
                                          )
                                        , xmlforest(
                                              p.suffix         as "suffix"
                                            , p.birthday       as "birthday"
                                            , p.place_of_birth as "place_of_birth"
                                            , p.gender         as "gender"
                                          )
                                        , (select xmlagg( 
                                                      xmlelement(
                                                          "identity_card"
                                                        , xmlelement("id_type",       o.id_type  )
                                                        , xmlforest(o.id_series as "id_series")
                                                        , xmlelement("id_number",     o.id_number)
                                                        , xmlforest(
                                                              o.id_issuer      as "id_issuer"
                                                            , o.id_issue_date  as "id_issue_date"
                                                            , o.id_expire_date as "id_expire_date"
                                                          )
                                                      )
                                                  )
                                             from com_id_object o 
                                            where o.entity_type = c.entity_type 
                                              and o.object_id = c.object_id
                                          )
                                      )
                                  from com_person p 
                                 where c.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                                   and p.id          = c.object_id
                                   and rownum        = 1
                              )
                           ,  (
                               select xmlelement(
                                          "company"
                                        , xmlattributes(p.id as "company_id")
                                        , xmlforest(
                                              p.incorp_form as "incorp_form"
                                            , p.embossed_name as "embossed_name"
                                          )
                                        , (select xmlagg(
                                                      xmlelement(
                                                          "company_name"
                                                        , xmlattributes(lang.lang as "language")
                                                        , xmlforest(
                                                              h.text as "company_short_name"
                                                            , t.text as "company_full_name"
                                                          )
                                                      )
                                                  )
                                             from com_i18n_vw h
                                                , com_i18n_vw t
                                                , com_language_vw lang
                                            where h.table_name(+)          = 'COM_COMPANY'
                                              and t.table_name(+)          = 'COM_COMPANY'
                                              and coalesce(h.lang, t.lang) = lang.lang
                                              and h.lang(+)                = lang.lang
                                              and t.lang(+)                = lang.lang
                                              and h.column_name(+)         = 'LABEL'
                                              and t.column_name(+)         = 'DESCRIPTION'
                                              and h.object_id(+)           = p.id
                                              and t.object_id(+)           = p.id)
                                        , (select xmlagg( 
                                                      xmlelement(
                                                          "identity_card"
                                                        , xmlelement("id_type",       o.id_type  )
                                                        , xmlforest(o.id_series as "id_series")
                                                        , xmlelement("id_number",     o.id_number)
                                                        , xmlforest(
                                                              o.id_issuer      as "id_issuer"
                                                            , o.id_issue_date  as "id_issue_date"
                                                            , o.id_expire_date as "id_expire_date"
                                                          )
                                                      )
                                                  )
                                             from com_id_object o 
                                            where o.entity_type = c.entity_type 
                                              and o.object_id = c.object_id
                                          )
                                      )
                                 from com_company p
                                where p.id = c.object_id
                                  and c.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
                                  and rownum        = 1
                              )
                           ,  (select xmlagg(
                                          xmlelement(
                                              "contact"
                                            , xmlattributes(x.id as "contact_id")
                                            , xmlelement("contact_type",   y.contact_type)
                                            , xmlforest(
                                                  x.preferred_lang as "preferred_lang"
                                                , x.job_title as "job_title"
                                              )
                                            , (select xmlelement(
                                                          "person"
                                                        , xmlattributes(z.id as "person_id")
                                                        , xmlforest(z.title as "person_title")
                                                        , xmlelement(
                                                              "person_name"
                                                           ,  xmlattributes(z.lang as "language")
                                                           ,  xmlelement("surname",     z.surname)
                                                           ,  xmlelement("first_name",  z.first_name)
                                                           ,  case when z.second_name is not null then
                                                                  xmlelement("second_name", z.second_name)
                                                              end
                                                          )
                                                        , xmlforest(
                                                              z.suffix         as "suffix"
                                                            , z.birthday       as "birthday"
                                                            , z.place_of_birth as "place_of_birth"
                                                            , z.gender         as "gender"
                                                          )
                                                        , (select xmlagg( 
                                                                      xmlelement(
                                                                          "identity_card"
                                                                        , xmlelement("id_type",       o.id_type  )
                                                                        , xmlforest(o.id_series as "id_series")
                                                                        , xmlelement("id_number",     o.id_number)
                                                                        , xmlforest(
                                                                              o.id_issuer      as "id_issuer"
                                                                            , o.id_issue_date  as "id_issue_date"
                                                                            , o.id_expire_date as "id_expire_date"
                                                                          )
                                                                      )
                                                                  )
                                                             from com_id_object o 
                                                            where o.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                                                              and o.object_id = z.id
                                                          )
                                                      )
                                                 from com_person z
                                                where z.id = x.person_id
                                                  and (z.lang = i_lang or i_lang is null)
                                              )
                                            , (select xmlagg(
                                                          xmlelement(
                                                              "contact_data"
                                                            , xmlelement("commun_method"  , d.commun_method)
                                                            , xmlelement("commun_address" , d.commun_address)
                                                            , xmlforest(
                                                                  to_char(d.start_date, 'yyyy-mm-dd') as "start_date"
                                                                , to_char(d.end_date, 'yyyy-mm-dd')   as "end_date"
                                                              )
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
                                  and y.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                  and y.object_id   = c.id
                              )
                            , (select xmlagg(
                                          xmlelement(
                                              "address"
                                            , xmlattributes(a.id as "address_id")
                                            , xmlelement("address_type", a.address_type)
                                            , xmlelement("country",      a.country)
                                            , (select xmlagg(
                                                          xmlelement(
                                                              "address_name"
                                                            , xmlattributes(aa.lang as "language")
                                                            , xmlforest(aa.region  as "region")
                                                            , xmlelement("city",   aa.city)
                                                            , xmlelement("street", aa.street)
                                                          )
                                                      ) 
                                                 from com_address aa
                                                where aa.id = a.id
                                                  and (aa.lang = a.lang or i_lang is null)
                                              )
                                            , xmlforest(
                                                  a.house       as "house" 
                                                , a.apartment   as "apartment"
                                                , a.postal_code as "postal_code"
                                                , a.place_code  as "place_code"
                                                , a.region_code as "region_code"
                                                , a.latitude    as "latitude"
                                                , a.longitude   as "longitude"
                                              )
                                          )
                                      )
                                 from (select a.id
                                            , o.address_type
                                            , a.country
                                            , a.house
                                            , a.apartment
                                            , a.postal_code
                                            , a.place_code
                                            , a.region_code
                                            , a.longitude
                                            , a.latitude
                                            , o.object_id
                                            , a.lang
                                            , row_number() over (partition by o.object_id, o.address_type 
                                                                     order by decode(a.lang
                                                                                   , i_lang, -1
                                                                                   , com_api_const_pkg.DEFAULT_LANGUAGE, 0
                                                                                   , o.address_id)
                                              ) as rn
                                         from com_address_object o
                                            , com_address a
                                        where o.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                          and a.id          = o.address_id
                                          and a.lang in (i_lang, com_api_const_pkg.DEFAULT_LANGUAGE)
                                 ) a
                                where a.rn        = 1
                                  and a.object_id = c.id
                              ) -- end of address
                           , (select xmlagg(
                                         xmlelement("flexible_data"
                                           , xmlelement("field_name",  ff.name)
                                           , xmlelement(
                                                 "field_value"
                                               , case ff.data_type
                                                     when com_api_const_pkg.DATA_TYPE_NUMBER then
                                                         to_char(
                                                             to_number(fd.field_value, nvl(ff.data_format, com_api_const_pkg.NUMBER_FORMAT))
                                                           , com_api_const_pkg.XML_NUMBER_FORMAT
                                                         )
                                                     when com_api_const_pkg.DATA_TYPE_DATE   then
                                                         to_char(
                                                             to_date(fd.field_value, nvl(ff.data_format, com_api_const_pkg.DATE_FORMAT))
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
                               where ff.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                 and fd.field_id    = ff.id
                                 and fd.object_id   = c.id
                             )
                           , (select xmlagg(
                                         xmlelement(
                                             "note"
                                           , xmlelement("note_type", n.note_type)
                                           , (select xmlagg(
                                                         xmlelement(
                                                             "note_content"
                                                           , xmlattributes(lang.lang as "language")
                                                           , xmlforest(
                                                                 h.text as "note_header"
                                                               , t.text as "note_text"
                                                            )
                                                         )
                                                     )
                                                from com_i18n_vw h
                                                   , com_i18n_vw t
                                                   , com_language_vw lang
                                               where h.table_name(+)          = ntb_api_const_pkg.NOTE_TABLE
                                                 and t.table_name(+)          = ntb_api_const_pkg.NOTE_TABLE
                                                 and coalesce(h.lang, t.lang) = lang.lang
                                                 and h.lang(+)                = lang.lang
                                                 and t.lang(+)                = lang.lang
                                                 and h.column_name(+)         = 'HEADER'
                                                 and t.column_name(+)         = 'TEXT'
                                                 and h.object_id(+)           = n.id
                                                 and t.object_id(+)           = n.id)
                                         )
                                     )
                                from ntb_note n
                               where n.entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                 and n.object_id   = c.id
                             )
                       )
                   )
               ).getclobval() as customer_data
          from prd_customer  c
         where c.id in (select column_value from table(cast(l_customer_id_tab as num_tab_tpt)));

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
                    
        trc_log_pkg.debug('file saved, cnt=' || l_customer_id_tab.count || ', length=' || length(l_file));
                                          
        prc_api_stat_pkg.log_current (
            i_current_count   => l_customer_id_tab.count
          , i_excepted_count  => 0
        );
    end;

begin
    trc_log_pkg.debug('Start customers export version 1.0');
    prc_api_stat_pkg.log_start;
    savepoint sp_dwh_customers_export;
    l_full_export   := nvl(i_full_export, com_api_const_pkg.FALSE);

    if l_full_export = com_api_const_pkg.TRUE then
        select count(1)
          into l_estimated_count
          from prd_customer c
         where (c.inst_id = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST);
        
        trc_log_pkg.debug(
            i_text =>'Estimate count = [' || l_estimated_count || ']'
        );
        
        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
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
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_DWH_PRC_CUST_EXPORT_PKG.PROCESS'
                   and o.eff_date      <= l_sysdate
                   and e.id             = o.event_id
                   and e.event_type     = s.event_type
                   and o.procedure_name = s.procedure_name
                   and o.object_id      = c.id
                   and (c.inst_id       = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
        );

        trc_log_pkg.debug(
            i_text =>'Estimate count = [' || l_estimated_count || ']'
        );
               
        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
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
        rollback to savepoint sp_dwh_customers_export;
        
        prc_api_stat_pkg.log_end(
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
end;

procedure process_1_3(
    i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_full_export   in  com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , i_lang          in  com_api_type_pkg.t_dict_value   default null
) is
    l_sysdate            date := get_sysdate;
    l_sess_file_id       com_api_type_pkg.t_long_id;
    l_file               clob;
    l_estimated_count    pls_integer := 0;
    l_count              pls_integer := 0;
    C_CRLF               constant  com_api_type_pkg.t_name := chr(13)||chr(10);
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
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_DWH_PRC_CUST_EXPORT_PKG.PROCESS'
           and o.eff_date      <= l_sysdate
           and e.id             = o.event_id
           and e.event_type     = s.event_type
           and o.procedure_name = s.procedure_name
           and o.object_id      = c.id
           and (c.inst_id       = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
      order by o.id;
    
    cursor cu_all_customers is
        select c.id as customer_id
          from prd_customer c
         where (c.inst_id       = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
      order by c.id;

    cursor main_xml_cur is
        select xmlelement(
                   "customers"
                 , xmlattributes('http://sv.bpc.in/SVXP/Customers' as "xmlns")
                 , xmlelement("file_id"  , to_char(l_sess_file_id))
                 , xmlelement("file_type", prd_api_const_pkg.FILE_TYPE_CUSTOMERS )
                 , xmlelement("inst_id"  , to_char(i_inst_id))
                 ,     xmlagg(                    
                           xmlelement(
                              "customer"
                           ,  xmlattributes(to_char(c.id) as "customer_id")
                           ,  xmlelement("inst_id"              , c.inst_id)
                           ,  xmlelement("customer_number"      , c.customer_number)
                           ,  xmlforest(c.category              as "customer_category"
                                      , c.ext_entity_type       as "customer_ext_type"
                                      , c.ext_object_id         as "customer_ext_id"
                                      , c.relation              as "customer_relation"
                                      , c.resident              as "resident"
                                      , c.nationality           as "nationality"
                                      , c.credit_rating         as "credit_rating"
                                      , c.money_laundry_risk    as "money_laundry_risk"
                                      , c.money_laundry_reason  as "money_laundry_reason"
                                      , c.status                as "status"
                                      , c.status_reason         as "status_reason"
                              )
                           ,  (select xmlagg(
                                          xmlelement(
                                              "contract"
                                             , xmlattributes(to_char(x.id) as "contract_id")
                                             , xmlelement("contract_number", x.contract_number)
                                             , xmlelement("agent_id"       , x.agent_id)
                                             , xmlelement("agent_number"   , a.agent_number)
                                             , xmlelement("contract_type"  , x.contract_type)
                                             , xmlelement("product_id"     , x.product_id)
                                             , xmlforest(p.product_number as "product_number")
                                             , xmlelement("start_date"     , to_char(x.start_date, 'yyyy-mm-dd'))
                                             , xmlforest(to_char(x.end_date, 'yyyy-mm-dd') as "end_date")
                                          ) 
                                      )
                                 from prd_contract x
                                    , ost_agent a
                                    , prd_product p
                                where x.customer_id = c.id
                                  and x.agent_id = a.id(+)
                                  and x.product_id = p.id(+)
                              )
                           ,  (select xmlelement(
                                          "person"
                                        , xmlattributes(p.id as "person_id")
                                        , xmlforest(p.title as "person_title")
                                        , (select xmlagg(
                                                      xmlelement(
                                                          "person_name"
                                                        , xmlattributes(q.lang as "language")
                                                        , xmlelement("surname",     q.surname)
                                                        , xmlelement("first_name",  q.first_name)
                                                        , case when q.second_name is not null
                                                               then xmlelement("second_name", q.second_name  ) 
                                                          end
                                                      )
                                                  )
                                             from com_person q
                                            where q.id = p.id
                                              and (q.lang = i_lang or i_lang is null)
                                          )
                                        , xmlforest(
                                              p.suffix         as "suffix"
                                            , p.birthday       as "birthday"
                                            , p.place_of_birth as "place_of_birth"
                                            , p.gender         as "gender"
                                          )
                                        , (select xmlagg( 
                                                      xmlelement(
                                                          "identity_card"
                                                        , xmlelement("id_type",       o.id_type  )
                                                        , xmlforest(o.id_series as "id_series")
                                                        , xmlelement("id_number",     o.id_number)
                                                        , xmlforest(
                                                              o.id_issuer      as "id_issuer"
                                                            , o.id_issue_date  as "id_issue_date"
                                                            , o.id_expire_date as "id_expire_date"
                                                          )
                                                      )
                                                  )
                                             from com_id_object o 
                                            where o.entity_type = c.entity_type 
                                              and o.object_id = c.object_id
                                          )
                                      )
                                  from com_person p 
                                 where c.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                                   and p.id          = c.object_id
                                   and rownum        = 1
                              )
                           ,  (
                               select xmlelement(
                                          "company"
                                        , xmlattributes(p.id as "company_id")
                                        , xmlforest(
                                              p.incorp_form as "incorp_form"
                                            , p.embossed_name as "embossed_name"
                                          )
                                        , (select xmlagg(
                                                      xmlelement(
                                                          "company_name"
                                                        , xmlattributes(lang.lang as "language")
                                                        , xmlforest(
                                                              h.text as "company_short_name"
                                                            , t.text as "company_full_name"
                                                          )
                                                      )
                                                  )
                                             from com_i18n_vw h
                                                , com_i18n_vw t
                                                , com_language_vw lang
                                            where h.table_name(+)          = 'COM_COMPANY'
                                              and t.table_name(+)          = 'COM_COMPANY'
                                              and coalesce(h.lang, t.lang) = lang.lang
                                              and h.lang(+)                = lang.lang
                                              and t.lang(+)                = lang.lang
                                              and h.column_name(+)         = 'LABEL'
                                              and t.column_name(+)         = 'DESCRIPTION'
                                              and h.object_id(+)           = p.id
                                              and t.object_id(+)           = p.id)
                                        , (select xmlagg( 
                                                      xmlelement(
                                                          "identity_card"
                                                        , xmlelement("id_type",       o.id_type  )
                                                        , xmlforest(o.id_series as "id_series")
                                                        , xmlelement("id_number",     o.id_number)
                                                        , xmlforest(
                                                              o.id_issuer      as "id_issuer"
                                                            , o.id_issue_date  as "id_issue_date"
                                                            , o.id_expire_date as "id_expire_date"
                                                          )
                                                      )
                                                  )
                                             from com_id_object o 
                                            where o.entity_type = c.entity_type 
                                              and o.object_id = c.object_id
                                          )
                                      )
                                 from com_company p
                                where p.id = c.object_id
                                  and c.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
                                  and rownum        = 1
                              )
                           ,  (select xmlagg(
                                          xmlelement(
                                              "contact"
                                            , xmlattributes(x.id as "contact_id")
                                            , xmlelement("contact_type",   y.contact_type)
                                            , xmlforest(
                                                  x.preferred_lang as "preferred_lang"
                                                , x.job_title as "job_title"
                                              )
                                            , (select xmlelement(
                                                          "person"
                                                        , xmlattributes(z.id as "person_id")
                                                        , xmlforest(z.title as "person_title")
                                                        , xmlelement(
                                                              "person_name"
                                                           ,  xmlattributes(z.lang as "language")
                                                           ,  xmlelement("surname",     z.surname)
                                                           ,  xmlelement("first_name",  z.first_name)
                                                           ,  case when z.second_name is not null then
                                                                  xmlelement("second_name", z.second_name)
                                                              end
                                                          )
                                                        , xmlforest(
                                                              z.suffix         as "suffix"
                                                            , z.birthday       as "birthday"
                                                            , z.place_of_birth as "place_of_birth"
                                                            , z.gender         as "gender"
                                                          )
                                                        , (select xmlagg( 
                                                                      xmlelement(
                                                                          "identity_card"
                                                                        , xmlelement("id_type",       o.id_type  )
                                                                        , xmlforest(o.id_series as "id_series")
                                                                        , xmlelement("id_number",     o.id_number)
                                                                        , xmlforest(
                                                                              o.id_issuer      as "id_issuer"
                                                                            , o.id_issue_date  as "id_issue_date"
                                                                            , o.id_expire_date as "id_expire_date"
                                                                          )
                                                                      )
                                                                  )
                                                             from com_id_object o 
                                                            where o.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                                                              and o.object_id = z.id
                                                          )
                                                      )
                                                 from com_person z
                                                where z.id = x.person_id
                                                  and (z.lang = i_lang or i_lang is null)
                                              )
                                            , (select xmlagg(
                                                          xmlelement(
                                                              "contact_data"
                                                            , xmlelement("commun_method"  , d.commun_method)
                                                            , xmlelement("commun_address" , d.commun_address)
                                                            , xmlforest(
                                                                  to_char(d.start_date, 'yyyy-mm-dd') as "start_date"
                                                                , to_char(d.end_date, 'yyyy-mm-dd')   as "end_date"
                                                              )
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
                                  and y.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                  and y.object_id   = c.id
                              )
                            , (select xmlagg(
                                          xmlelement(
                                              "address"
                                            , xmlattributes(a.id as "address_id")
                                            , xmlelement("address_type", a.address_type)
                                            , xmlelement("country",      a.country)
                                            , (select xmlagg(
                                                          xmlelement(
                                                              "address_name"
                                                            , xmlattributes(aa.lang as "language")
                                                            , xmlforest(aa.region  as "region")
                                                            , xmlelement("city",   aa.city)
                                                            , xmlelement("street", aa.street)
                                                          )
                                                      ) 
                                                 from com_address aa
                                                where aa.id = a.id
                                                  and (aa.lang = a.lang or i_lang is null)
                                              )
                                            , xmlforest(
                                                  a.house       as "house" 
                                                , a.apartment   as "apartment"
                                                , a.postal_code as "postal_code"
                                                , a.place_code  as "place_code"
                                                , a.region_code as "region_code"
                                                , a.latitude    as "latitude"
                                                , a.longitude   as "longitude"
                                              )
                                          )
                                      )
                                 from (select a.id
                                            , o.address_type
                                            , a.country
                                            , a.house
                                            , a.apartment
                                            , a.postal_code
                                            , a.place_code
                                            , a.region_code
                                            , a.longitude
                                            , a.latitude
                                            , o.object_id
                                            , a.lang
                                            , row_number() over (partition by o.object_id, o.address_type 
                                                                     order by decode(a.lang
                                                                                   , i_lang, -1
                                                                                   , com_api_const_pkg.DEFAULT_LANGUAGE, 0
                                                                                   , o.address_id)
                                              ) as rn
                                         from com_address_object o
                                            , com_address a
                                        where o.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                          and a.id          = o.address_id
                                          and a.lang in (i_lang, com_api_const_pkg.DEFAULT_LANGUAGE)
                                 ) a
                                where a.rn        = 1
                                  and a.object_id = c.id
                              ) -- end of address
                           , (select xmlagg(
                                         xmlelement("flexible_data"
                                           , xmlelement("field_name",  ff.name)
                                           , xmlelement(
                                                 "field_value"
                                               , case ff.data_type
                                                     when com_api_const_pkg.DATA_TYPE_NUMBER then
                                                         to_char(
                                                             to_number(fd.field_value, nvl(ff.data_format, com_api_const_pkg.NUMBER_FORMAT))
                                                           , com_api_const_pkg.XML_NUMBER_FORMAT
                                                         )
                                                     when com_api_const_pkg.DATA_TYPE_DATE   then
                                                         to_char(
                                                             to_date(fd.field_value, nvl(ff.data_format, com_api_const_pkg.DATE_FORMAT))
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
                               where ff.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                 and fd.field_id    = ff.id
                                 and fd.object_id   = c.id
                             )
                           , (select xmlagg(
                                         xmlelement(
                                             "note"
                                           , xmlelement("note_type", n.note_type)
                                           , (select xmlagg(
                                                         xmlelement(
                                                             "note_content"
                                                           , xmlattributes(lang.lang as "language")
                                                           , xmlforest(
                                                                 h.text as "note_header"
                                                               , t.text as "note_text"
                                                            )
                                                         )
                                                     )
                                                from com_i18n_vw h
                                                   , com_i18n_vw t
                                                   , com_language_vw lang
                                               where h.table_name(+)          = ntb_api_const_pkg.NOTE_TABLE
                                                 and t.table_name(+)          = ntb_api_const_pkg.NOTE_TABLE
                                                 and coalesce(h.lang, t.lang) = lang.lang
                                                 and h.lang(+)                = lang.lang
                                                 and t.lang(+)                = lang.lang
                                                 and h.column_name(+)         = 'HEADER'
                                                 and t.column_name(+)         = 'TEXT'
                                                 and h.object_id(+)           = n.id
                                                 and t.object_id(+)           = n.id)
                                         )
                                     )
                                from ntb_note n
                               where n.entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                 and n.object_id   = c.id
                             )
                       )
                   )
               ).getclobval() as customer_data
          from (
            select c.id
                 , c.object_id
                 , c.entity_type
                 , c.inst_id
                 , c.customer_number
                 , c.category
                 , c.ext_entity_type
                 , c.ext_object_id
                 , c.relation
                 , c.resident
                 , c.nationality
                 , c.credit_rating
                 , c.money_laundry_risk
                 , c.money_laundry_reason
                 , c.status
                 , evt_api_status_pkg.get_status_reason(
                      i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                    , i_object_id     => c.id
                    , i_raise_error   => com_api_const_pkg.FALSE
                  ) as status_reason
              from prd_customer c
             where c.id in (select column_value from table(cast(l_customer_id_tab as num_tab_tpt)))
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
                    
        trc_log_pkg.debug('file saved, cnt=' || l_customer_id_tab.count || ', length=' || length(l_file));
                                          
        prc_api_stat_pkg.log_current (
            i_current_count   => l_customer_id_tab.count
          , i_excepted_count  => 0
        );
    end;

begin
    trc_log_pkg.debug('Start customers export version 1.0');
    prc_api_stat_pkg.log_start;
    savepoint sp_dwh_customers_export;
    l_full_export   := nvl(i_full_export, com_api_const_pkg.FALSE);

    if l_full_export = com_api_const_pkg.TRUE then
        select count(1)
          into l_estimated_count
          from prd_customer c
         where (c.inst_id = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST);
        
        trc_log_pkg.debug(
            i_text =>'Estimate count = [' || l_estimated_count || ']'
        );
        
        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
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
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_DWH_PRC_CUST_EXPORT_PKG.PROCESS'
                   and o.eff_date      <= l_sysdate
                   and e.id             = o.event_id
                   and e.event_type     = s.event_type
                   and o.procedure_name = s.procedure_name
                   and o.object_id      = c.id
                   and (c.inst_id       = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
        );

        trc_log_pkg.debug(
            i_text =>'Estimate count = [' || l_estimated_count || ']'
        );
               
        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
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
        rollback to savepoint sp_dwh_customers_export;
        
        prc_api_stat_pkg.log_end(
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
end;

procedure process(
    i_dwh_version   in  com_api_type_pkg.t_name
  , i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_full_export   in  com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , i_lang          in  com_api_type_pkg.t_dict_value   default null
) is
begin
    trc_log_pkg.debug(
        i_text        => 'i_dwh_version=' || i_dwh_version
    );
    
    if i_dwh_version between '1.0' and '1.1' then
        process_1_0(
            i_inst_id     => i_inst_id
          , i_full_export => i_full_export
          , i_lang        => i_lang
        );
    elsif i_dwh_version = '1.3' then
        process_1_0(
            i_inst_id     => i_inst_id
          , i_full_export => i_full_export
          , i_lang        => i_lang
        );
    else
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1  => i_dwh_version
        );
    end if;
end;

end;
/
