create or replace package body itf_mpt_prc_cust_export_pkg is

procedure process_1_2(
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
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_MPT_PRC_CUST_EXPORT_PKG.PROCESS'
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
             , prd_contract cn
             , prd_product  pr
         where (c.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and c.contract_id   = cn.id
           and cn.product_id   = pr.id
           and pr.product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ
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
                           ,  xmlforest(c.category        as "customer_category")
                           ,  (
                               select xmlelement(
                                          "company"
                                        , xmlattributes(p.id as "company_id")
                                        , xmlforest(
                                              p.incorp_form as "incorp_form"
                                          )
                                        , (
                                            select xmlforest(d.field_value as "presence_on_location")
                                              from com_flexible_data d
                                                 , com_flexible_field f
                                             where d.field_id = f.id
                                               and f.name = 'PRESENCE_ON_LOCATION'
                                               and f.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
                                               and d.object_id = p.id
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
                                      )
                                 from com_company p
                                where p.id = c.object_id
                                  and c.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
                                  and rownum        = 1
                              )
                           ,  (select xmlagg(
                                          xmlelement(
                                              "contract"
                                             , xmlattributes(to_char(x.id) as "contract_id")
                                             , xmlelement("agent_id"       , x.agent_id)
                                             , xmlelement("agent_number"   , a.agent_number)
                                             , xmlelement("contract_number", x.contract_number)
                                             , xmlelement("contract_type"  , x.contract_type)
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
                           ,  (select xmlagg(
                                          xmlelement(
                                              "contact"
                                            , xmlattributes(x.id as "contact_id")
                                            , xmlelement("contact_type",   y.contact_type)
                                            , xmlforest(
                                                  x.job_title as "job_title"
                                                , x.preferred_lang as "preferred_lang"
                                              )
                                            , (select xmlagg(
                                                          xmlelement(
                                                              "contact_data"
                                                            , xmlelement("commun_method"  , d.commun_method)
                                                            , xmlelement("commun_address" , d.commun_address)
                                                          )
                                                      )
                                                from com_contact_data d
                                               where d.contact_id  = y.contact_id
                                                 and (d.end_date is null or d.end_date > l_sysdate)
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
                                                      )
                                                 from com_person z
                                                where z.id = x.person_id
                                                  and (z.lang = i_lang or i_lang is null)
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
                                                            , xmlelement("region", aa.region)
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
    trc_log_pkg.debug('Start customers export version 1.2');
    prc_api_stat_pkg.log_start;
    savepoint sp_mpt_customers_export;
    l_full_export   := nvl(i_full_export, com_api_const_pkg.FALSE);

    if l_full_export = com_api_const_pkg.TRUE then
        select count(1)
          into l_estimated_count
          from prd_customer c
             , prd_contract cn
             , prd_product  pr
         where (c.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and c.contract_id   = cn.id
           and cn.product_id   = pr.id
           and pr.product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ;
        
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
                    o_sess_file_id  => l_sess_file_id
                  , i_file_type     => prd_api_const_pkg.FILE_TYPE_CUSTOMERS
                  , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
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
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_MPT_PRC_CUST_EXPORT_PKG.PROCESS'
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
        rollback to savepoint sp_mpt_customers_export;
        
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

procedure process_1_6(
    i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_full_export   in  com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_lang          in  com_api_type_pkg.t_dict_value default null
) is
    l_sysdate           date := get_sysdate;
    l_sess_file_id      com_api_type_pkg.t_long_id;
    l_file              clob;
    l_estimated_count   pls_integer := 0;
    l_count             pls_integer := 0;
    l_customer_id_tab   num_tab_tpt;
    l_event_tab         com_api_type_pkg.t_number_tab;
    l_full_export       com_api_type_pkg.t_boolean;

    BULK_LIMIT          simple_integer := 2000;
    C_CRLF              constant  com_api_type_pkg.t_name := chr(13)||chr(10);
    
    cursor cu_event_objects is
        select c.id as customer_id
             , o.id as event_object_id
          from evt_event_object o
             , evt_event e
             , evt_subscriber s
             , prd_customer c
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_MPT_PRC_CUST_EXPORT_PKG.PROCESS'
           and o.eff_date      <= l_sysdate
           and e.id             = o.event_id
           and e.event_type     = s.event_type
           and o.procedure_name = s.procedure_name
           and o.object_id      = c.id
           and (c.inst_id       = i_inst_id 
                   or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
      order by o.id;
    
    cursor cu_all_customers is
        select c.id as customer_id
          from prd_customer c
             , prd_contract cn
             , prd_product  pr
         where (c.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and c.contract_id   = cn.id
           and cn.product_id   = pr.id
           and pr.product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ
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
                           ,  xmlforest(c.category        as "customer_category")
                           ,  xmlforest(c.status          as "customer_status")
                           ,  (select xmlelement(
                                          "company"
                                        , xmlattributes(p.id as "company_id")
                                        , xmlforest(p.incorp_form as "incorp_form")
                                        , (select xmlforest(d.field_value as "presence_on_location")
                                             from com_flexible_data d
                                                , com_flexible_field f
                                            where d.field_id = f.id
                                              and f.name = 'PRESENCE_ON_LOCATION'
                                              and f.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
                                              and d.object_id = p.id)
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
                                                        , xmlelement("id_type",        o.id_type   )
                                                        , xmlelement("id_series",      o.id_series )
                                                        , xmlelement("id_number",      o.id_number )
                                                        , xmlelement("id_issuer",      o.id_issuer )
                                                        , case when o.id_issue_date  is not null then xmlelement("id_issue_date",  o.id_issue_date) end
                                                        , case when o.id_expire_date is not null then xmlelement("id_expire_date", o.id_expire_date) end 
                                                        , xmlelement(
                                                              "id_desc"
                                                            , com_api_i18n_pkg.get_text(
                                                                   i_table_name  => 'COM_ID_OBJECT'
                                                                 , i_column_name => com_api_const_pkg.TEXT_IN_DESCRIPTION
                                                                 , i_object_id   => o.id
                                                                 , i_lang        => nvl(i_lang, com_api_const_pkg.DEFAULT_LANGUAGE)
                                                              )
                                                          )
                                                      )
                                                  )
                                                from com_id_object o 
                                               where o.entity_type = c.entity_type 
                                                 and o.object_id = c.object_id)
                                      )
                                 from com_company p
                                where p.id = c.object_id
                                  and c.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
                                  and rownum        = 1
                              )
                           ,  (select xmlagg(
                                          xmlelement(
                                              "contract"
                                             , xmlattributes(to_char(x.id) as "contract_id")
                                             , xmlelement("agent_id"       , x.agent_id)
                                             , xmlelement("agent_number"   , a.agent_number)
                                             , xmlelement("contract_number", x.contract_number)
                                             , xmlelement("contract_type"  , x.contract_type)
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
                           ,  (select xmlagg(
                                          xmlelement(
                                              "contact"
                                            , xmlattributes(x.id as "contact_id")
                                            , xmlelement("contact_type",   y.contact_type)
                                            , xmlforest(
                                                  x.job_title as "job_title"
                                                , x.preferred_lang as "preferred_lang"
                                              )
                                            , (select xmlagg(
                                                          xmlelement(
                                                              "contact_data"
                                                            , xmlelement("commun_method"  , d.commun_method)
                                                            , xmlelement("commun_address" , d.commun_address)
                                                          )
                                                      )
                                                from com_contact_data d
                                               where d.contact_id  = y.contact_id
                                                 and (d.end_date is null or d.end_date > l_sysdate)
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
                                                      )
                                                 from com_person z
                                                where z.id = x.person_id
                                                  and (z.lang = i_lang or i_lang is null)
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
                                                            , xmlelement("region", aa.region)
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
    trc_log_pkg.debug('Start customers export version 1.6');
    prc_api_stat_pkg.log_start;
    savepoint sp_mpt_customers_export;
    l_full_export   := nvl(i_full_export, com_api_const_pkg.FALSE);

    if l_full_export = com_api_const_pkg.TRUE then
        select count(1)
          into l_estimated_count
          from prd_customer c
             , prd_contract cn
             , prd_product  pr
         where (c.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and c.contract_id   = cn.id
           and cn.product_id   = pr.id
           and pr.product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ;
        
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
                    o_sess_file_id  => l_sess_file_id
                  , i_file_type     => prd_api_const_pkg.FILE_TYPE_CUSTOMERS
                  , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
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
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_MPT_PRC_CUST_EXPORT_PKG.PROCESS'
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
        rollback to savepoint sp_mpt_customers_export;
        
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

procedure process_1_7(
    i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_full_export   in  com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_lang          in  com_api_type_pkg.t_dict_value default null
) is
    l_sysdate           date := get_sysdate;
    l_sess_file_id      com_api_type_pkg.t_long_id;
    l_file              clob;
    l_estimated_count   pls_integer := 0;
    l_count             pls_integer := 0;
    l_customer_id_tab   num_tab_tpt;
    l_event_tab         com_api_type_pkg.t_number_tab;
    l_full_export       com_api_type_pkg.t_boolean;

    BULK_LIMIT          simple_integer := 2000;
    C_CRLF              constant  com_api_type_pkg.t_name := chr(13)||chr(10);
    
    cursor cu_event_objects is
        select c.id as customer_id
             , o.id as event_object_id
          from evt_event_object o
             , evt_event e
             , evt_subscriber s
             , prd_customer c
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_MPT_PRC_CUST_EXPORT_PKG.PROCESS'
           and o.eff_date      <= l_sysdate
           and e.id             = o.event_id
           and e.event_type     = s.event_type
           and o.procedure_name = s.procedure_name
           and o.object_id      = c.id
           and (c.inst_id       = i_inst_id 
                   or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
      order by o.id;
    
    cursor cu_all_customers is
        select c.id as customer_id
          from prd_customer c
             , prd_contract cn
             , prd_product  pr
         where (c.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and c.contract_id   = cn.id
           and cn.product_id   = pr.id
           and pr.product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ
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
                           ,  xmlforest(c.category        as "customer_category")
                           ,  xmlforest(c.status          as "customer_status")
                           ,  xmlforest(
                                  evt_api_status_pkg.get_status_reason(
                                     i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                   , i_object_id     => c.id
                                   , i_raise_error   => com_api_const_pkg.FALSE
                                  ) as status_reason
                              )
                           ,  (select xmlelement(
                                          "company"
                                        , xmlattributes(p.id as "company_id")
                                        , xmlforest(p.incorp_form as "incorp_form")
                                        , (select xmlforest(d.field_value as "presence_on_location")
                                             from com_flexible_data d
                                                , com_flexible_field f
                                            where d.field_id = f.id
                                              and f.name = 'PRESENCE_ON_LOCATION'
                                              and f.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
                                              and d.object_id = p.id)
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
                                                        , xmlelement("id_type",        o.id_type   )
                                                        , xmlelement("id_series",      o.id_series )
                                                        , xmlelement("id_number",      o.id_number )
                                                        , xmlelement("id_issuer",      o.id_issuer )
                                                        , case when o.id_issue_date  is not null then xmlelement("id_issue_date",  o.id_issue_date) end
                                                        , case when o.id_expire_date is not null then xmlelement("id_expire_date", o.id_expire_date) end 
                                                        , xmlelement(
                                                              "id_desc"
                                                            , com_api_i18n_pkg.get_text(
                                                                   i_table_name  => 'COM_ID_OBJECT'
                                                                 , i_column_name => com_api_const_pkg.TEXT_IN_DESCRIPTION
                                                                 , i_object_id   => o.id
                                                                 , i_lang        => nvl(i_lang, com_api_const_pkg.DEFAULT_LANGUAGE)
                                                              )
                                                          )
                                                      )
                                                  )
                                                from com_id_object o 
                                               where o.entity_type = c.entity_type 
                                                 and o.object_id = c.object_id)
                                      )
                                 from com_company p
                                where p.id = c.object_id
                                  and c.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
                                  and rownum        = 1
                              )
                           ,  (select xmlagg(
                                          xmlelement(
                                              "contract"
                                             , xmlattributes(to_char(x.id) as "contract_id")
                                             , xmlelement("agent_id"       , x.agent_id)
                                             , xmlelement("agent_number"   , a.agent_number)
                                             , xmlelement("contract_number", x.contract_number)
                                             , xmlelement("contract_type"  , x.contract_type)
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
                           ,  (select xmlagg(
                                          xmlelement(
                                              "contact"
                                            , xmlattributes(x.id as "contact_id")
                                            , xmlelement("contact_type",   y.contact_type)
                                            , xmlforest(
                                                  x.job_title as "job_title"
                                                , x.preferred_lang as "preferred_lang"
                                              )
                                            , (select xmlagg(
                                                          xmlelement(
                                                              "contact_data"
                                                            , xmlelement("commun_method"  , d.commun_method)
                                                            , xmlelement("commun_address" , d.commun_address)
                                                          )
                                                      )
                                                from com_contact_data d
                                               where d.contact_id  = y.contact_id
                                                 and (d.end_date is null or d.end_date > l_sysdate)
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
                                                      )
                                                 from com_person z
                                                where z.id = x.person_id
                                                  and (z.lang = i_lang or i_lang is null)
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
                                                            , xmlelement("region", aa.region)
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
    trc_log_pkg.debug('Start customers export version 1.6');
    prc_api_stat_pkg.log_start;
    savepoint sp_mpt_customers_export;
    l_full_export   := nvl(i_full_export, com_api_const_pkg.FALSE);

    if l_full_export = com_api_const_pkg.TRUE then
        select count(1)
          into l_estimated_count
          from prd_customer c
             , prd_contract cn
             , prd_product  pr
         where (c.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and c.contract_id   = cn.id
           and cn.product_id   = pr.id
           and pr.product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ;
        
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
                    o_sess_file_id  => l_sess_file_id
                  , i_file_type     => prd_api_const_pkg.FILE_TYPE_CUSTOMERS
                  , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
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
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_MPT_PRC_CUST_EXPORT_PKG.PROCESS'
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
        rollback to savepoint sp_mpt_customers_export;
        
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
    i_mpt_version   in  com_api_type_pkg.t_name
  , i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_full_export   in  com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , i_lang          in  com_api_type_pkg.t_dict_value   default null
) is
begin
    trc_log_pkg.debug(
        i_text        => 'i_mpt_version=' || i_mpt_version
    );
    
    if i_mpt_version between '1.2' and '1.5' then
        process_1_2(
            i_inst_id     => i_inst_id
          , i_full_export => i_full_export
          , i_lang        => i_lang
        );
    elsif i_mpt_version = '1.6' then
        process_1_6(
            i_inst_id     => i_inst_id
          , i_full_export => i_full_export
          , i_lang        => i_lang
        );
    elsif i_mpt_version = '1.7' then
        process_1_7(
            i_inst_id     => i_inst_id
          , i_full_export => i_full_export
          , i_lang        => i_lang
        );
    else
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1  => i_mpt_version
        );
    end if;
end;

end;
/
