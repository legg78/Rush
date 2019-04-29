create or replace package body evt_api_notif_report_data_pkg is
/**********************************************************
 * Generate data for construction send event notification <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 14.10.2016 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate:: $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: EVT_API_NOTIF_REPORT_DATA_PKG
 * @headcom
 **********************************************************/
 
/* Obsolete. Do not use */
procedure generate_account_data(
    i_account_id           in            com_api_type_pkg.t_medium_id
  , i_lang                 in            com_api_type_pkg.t_dict_value default null
  , o_account_report_data  out           xmltype
) is
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_account_data(' || i_account_id || '): START');
    
    begin
    
        select  xmlelement("account"
                  , xmlelement("account_id", smd.account_id)
                  , xmlelement("account_number", smd.account_number)
                  , xmlelement("account_type", smd.account_type)
                  , xmlelement("account_type_name", smd.account_type_name)
                  , xmlelement("institution_id", smd.institution_id)
                  , xmlelement("institution_name", smd.institution_name)
                  , xmlelement("agent_id", smd.agent_id)
                  , xmlelement("agent_name", smd.agent_name)
                  , xmlelement("account_currency", smd.account_currency)
                  , xmlelement("account_currency_name", smd.account_currency_name)
                  , xmlelement("customer_id", smd.customer_id)
                  , xmlelement("customer_entity_type", smd.customer_entity_type)
                  , xmlelement("customer_entity_type_name", smd.customer_entity_type_name)
                  , xmlelement("customer_object_id", smd.customer_object_id)
                  , xmlelement("customer_number", smd.customer_number)
                  , xmlelement("person_first_name", smd.person_first_name)
                  , xmlelement("person_second_name", smd.person_second_name)
                  , xmlelement("person_surname", smd.person_surname)
                  , xmlelement("company_name", smd.company_name)
                  , xmlelement("company_description", smd.company_description)
                  , xmlelement("customer_bank_relation", smd.customer_bank_relation)
                  , xmlelement("customer_bank_relation_name", smd.customer_bank_relation_name)
                  , xmlelement("customer_status", smd.customer_status)
                  , xmlelement("customer_status_name", smd.customer_status_name)
                  , xmlelement("customer_reg_date", smd.customer_reg_date)
                  , xmlelement("customer_last_modify_date", smd.customer_last_modify_date)
                  , xmlelement("contract_id", smd.contract_id)
                  , xmlelement("contract_type", smd.contract_type)
                  , xmlelement("contract_type_name", smd.contract_type_name)
                  , xmlelement("contract_number", smd.contract_number)
                  , xmlelement("contract_start_date", smd.contract_start_date)
                  , xmlelement("contract_end_date", smd.contract_end_date)
                  , xmlelement("contract_product_id", smd.contract_product_id)
                  , xmlelement("product_type", smd.product_type)
                  , xmlelement("product_type_name", smd.product_type_name)
                  , xmlelement("product_number", smd.product_number)
                  , xmlelement("product_status", smd.product_status)
                  , xmlelement("product_status_name", smd.product_status_name)
                  , xmlelement("account_status", smd.account_status)
                  , xmlelement("account_status_name", smd.account_status_name)
                  , xmlelement("account_balance", smd.account_current_balance)
                  , sed.err_data
                ) as result
          into  o_account_report_data
          from
                (
                    select a.id                                                      as account_id
                         , a.account_number                                          as account_number
                         , a.account_type                                            as account_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => a.account_type
                             , i_lang    => i_lang
                           )                                                         as account_type_name
                         , a.inst_id                                                 as institution_id
                         , ost_ui_institution_pkg.get_inst_name(
                               i_inst_id => a.inst_id
                             , i_lang    => i_lang
                           )                                                         as institution_name
                         , a.agent_id                                                as agent_id
                         , ost_ui_agent_pkg.get_agent_name(
                               i_agent_id => a.agent_id
                             , i_lang     => i_lang
                           )                                                         as agent_name
                         , a.currency                                                as account_currency
                         , com_api_currency_pkg.get_currency_full_name(
                               i_curr_code => a.currency
                             , i_lang      => i_lang
                           )                                                         as account_currency_name
                         , a.customer_id                                             as customer_id
                         , pc.entity_type                                            as customer_entity_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => pc.entity_type
                             , i_lang    => i_lang
                           )                                                         as customer_entity_type_name
                         , pc.object_id                                              as customer_object_id
                         , pc.customer_number                                        as customer_number
                         , cp.first_name                                             as person_first_name
                         , cp.second_name                                            as person_second_name
                         , cp.surname                                                as person_surname
                         , com_api_i18n_pkg.get_text(
                               i_table_name  =>  'COM_COMPANY'
                             , i_column_name =>  'LABEL'
                             , i_object_id   =>  decode(
                                                     pc.entity_type
                                                   , com_api_const_pkg.ENTITY_TYPE_COMPANY
                                                   , pc.object_id
                                                   , null
                                                 )
                             , i_lang        =>  i_lang
                           )                                                         as company_name
                         , com_api_i18n_pkg.get_text(
                               i_table_name  =>  'COM_COMPANY'
                             , i_column_name =>  'DESCRIPTION'
                             , i_object_id   =>  decode(
                                                     pc.entity_type
                                                   , com_api_const_pkg.ENTITY_TYPE_COMPANY
                                                   , pc.object_id
                                                   , null
                                                 )
                             , i_lang        =>  i_lang
                           )                                                         as company_description
                         , pc.relation                                               as customer_bank_relation
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => pc.relation
                             , i_lang    => i_lang
                           )                                                         as customer_bank_relation_name
                         , pc.status                                                 as customer_status
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => pc.status
                             , i_lang    => i_lang
                           )                                                         as customer_status_name
                         , to_char(pc.reg_date, 'dd/mm/yyyy hh24:mi:ss')             as customer_reg_date
                         , to_char(pc.last_modify_date, 'dd/mm/yyyy hh24:mi:ss')     as customer_last_modify_date
                         , a.contract_id                                             as contract_id
                         , pcr.contract_type                                         as contract_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => pcr.contract_type
                             , i_lang    => i_lang
                           )                                                         as contract_type_name
                         , pcr.contract_number                                       as contract_number
                         , to_char(pcr.start_date, 'dd/mm/yyyy hh24:mi:ss')          as contract_start_date
                         , to_char(pcr.end_date, 'dd/mm/yyyy hh24:mi:ss')            as contract_end_date
                         , pcr.product_id                                            as contract_product_id
                         , prd.product_type                                          as product_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => prd.product_type
                             , i_lang    => i_lang
                           )                                                         as product_type_name
                         , prd.product_number                                        as product_number
                         , prd.status                                                as product_status
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => prd.status
                             , i_lang    => i_lang
                           )                                                         as product_status_name
                         , a.status                                                  as account_status
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => a.status
                             , i_lang    => i_lang
                           )                                                         as account_status_name
                         , to_char(
                               acc_api_balance_pkg.get_aval_balance_amount_only(
                                   i_account_id => a.id
                               ) / power(10, cc.exponent)
                              , com_api_const_pkg.XML_NUMBER_FORMAT
                                || rpad('.'
                                     , case cc.exponent 
                                            when 0
                                                then 0 
                                            else cc.exponent + 1
                                       end
                                     , '0'
                                   )
                            )                                                        as account_current_balance
                      from acc_account a
                         , prd_customer pc
                         , com_person cp
                         , prd_contract pcr
                         , prd_product prd
                         , com_currency cc
                     where a.id = i_account_id
                       and pc.id = a.customer_id
                       and decode(
                               pc.entity_type
                             , com_api_const_pkg.ENTITY_TYPE_PERSON
                             , pc.object_id
                             , null
                           ) = cp.id(+)
                       and nvl(
                               i_lang
                             , com_api_const_pkg.LANGUAGE_ENGLISH
                           ) = cp.lang(+)
                       and pcr.id = a.contract_id
                       and prd.id = pcr.product_id
                       and cc.code = a.currency
                ) smd
                left outer join
                (
                    select xmlelement(
                               "errors"
                             , xmlelement(
                                   "error"
                                 , xmlelement("error_code", com_api_error_pkg.get_last_error)
                                 , xmlelement(
                                       "error_element"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                           else null
                                       end
                                   )
                                 , xmlelement("error_desc", com_api_error_pkg.get_last_message)
                                 , xmlelement(
                                       "error_details"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   'ERROR_ID['||com_api_error_pkg.get_last_error_id||']'
                                           else null
                                       end
                                   )
                               )
                           ) as err_data
                      from dual
                ) sed on (1 = 1);
                
    exception
        when no_data_found then
            
            com_api_error_pkg.raise_error(
                i_error         => 'REPORT_DATA_NOT_FOUND'
            );
            
    end;
    
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_account_data(' || i_account_id || '): FINISH SUCCESS');
        
end generate_account_data;

/* Obsolete. Do not use */
procedure generate_application_data(
    i_appl_id            in            com_api_type_pkg.t_long_id
  , i_lang               in            com_api_type_pkg.t_dict_value default null
  , o_appl_report_data   out           xmltype
) is
    l_appl_id    com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_application_data(' || i_appl_id || '): START');
    
    l_appl_id := app_api_application_pkg.get_appl_id;
    
    if  l_appl_id is null
     or i_appl_id <> l_appl_id
    then
        com_api_error_pkg.raise_error(
            i_error         => 'REPORT_DATA_NOT_FOUND'
        );
    end if;
    
    begin
    
        select  xmlelement("application"
                  , xmlelement("application_id", sa.application_id)
                  , xmlelement("application_type", sa.application_type)
                  , xmlelement("appl_type_name", sa.appl_type_name)
                  , xmlelement("application_number", sa.application_number)
                  , xmlelement("flow_id", sa.flow_id)
                  , xmlelement("flow_name", sa.flow_name)
                  , xmlelement("application_status", sa.application_status)
                  , xmlelement("appl_status_name", sa.appl_status_name)
                  , xmlelement("appl_reject_code", sa.appl_reject_code)
                  , xmlelement("agent_id", sa.agent_id)
                  , xmlelement("agent_name", sa.agent_name)
                  , xmlelement("institution_id", sa.institution_id)
                  , xmlelement("institution_name", sa.institution_name)
                  , sd.app_data
                ) as result
          into  o_appl_report_data
          from
                (
                    select a.id                                       as application_id
                         , a.appl_type                                as application_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => a.appl_type
                             , i_lang    => i_lang
                           )                                          as appl_type_name
                         , a.appl_number                              as application_number
                         , a.flow_id                                  as flow_id
                         , com_api_i18n_pkg.get_text(
                               i_table_name  =>  'APP_FLOW'
                             , i_column_name =>  'LABEL'
                             , i_object_id   =>  a.flow_id
                             , i_lang        =>  i_lang
                           )                                          as flow_name
                         , a.appl_status                              as application_status
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => a.appl_status
                             , i_lang    => i_lang
                           )                                          as appl_status_name
                         , a.reject_code                              as appl_reject_code
                         , a.agent_id                                 as agent_id
                         , ost_ui_agent_pkg.get_agent_name(
                               i_agent_id => a.agent_id
                             , i_lang     => i_lang
                           )                                          as agent_name
                         , a.inst_id                                  as institution_id
                         , ost_ui_institution_pkg.get_inst_name(
                               i_inst_id => a.inst_id
                             , i_lang    => i_lang
                           )                                          as institution_name
                      from app_application a
                     where a.id = i_appl_id
                ) sa
                left outer join 
                (
                    select xmlelement(
                               "errors"
                             , xmlagg(
                                   xmlelement(
                                       "error"
                                     , xmlelement(
                                           "error_code"
                                         , app_api_application_pkg.get_element_value_v(
                                               i_element_name   => 'ERROR_CODE'
                                             , i_parent_id      => apd.id
                                           )
                                       )
                                     , xmlelement(
                                           "error_element"
                                         , app_api_application_pkg.get_element_value_v(
                                               i_element_name   => 'ERROR_ELEMENT'
                                             , i_parent_id      => apd.id
                                           )
                                       )
                                     , xmlelement(
                                           "error_desc"
                                         , app_api_application_pkg.get_element_value_v(
                                               i_element_name   => 'ERROR_DESC'
                                             , i_parent_id      => apd.id
                                           )
                                       )
                                     , xmlelement(
                                           "error_details"
                                         , app_api_application_pkg.get_element_value_v(
                                               i_element_name   => 'ERROR_DETAILS'
                                             , i_parent_id      => apd.id
                                           )
                                       )
                                   ) order by apd.id
                               )
                           ) as app_data
                      from app_data    apd,
                           app_element ape
                     where apd.appl_id      = i_appl_id
                       and ape.id           = apd.element_id
                       and ape.element_type = app_api_const_pkg.APPL_ELEMENT_TYPE_COMPLEX
                       and ape.name         = app_api_const_pkg.APPL_ELEMENT_NAME_ERROR
                ) sd on (1 = 1);
                            
    exception
        when no_data_found then
            
            com_api_error_pkg.raise_error(
                i_error         => 'REPORT_DATA_NOT_FOUND'
            );

    end;
     
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_application_data(' || i_appl_id || '): FINISH SUCCESS');
        
end generate_application_data;

/* Obsolete. Do not use */
procedure generate_credit_invoice_data(
    i_credit_invoice_id           in            com_api_type_pkg.t_medium_id
  , i_lang                        in            com_api_type_pkg.t_dict_value default null
  , o_credit_invoice_report_data  out           xmltype
) is

begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_credit_invoice_data(' || i_credit_invoice_id || '): START');
    
    begin
    
        select  xmlelement("credit_invoice"
                  , xmlelement("invoice_id", smd.invoice_id)
                  , xmlelement("account_main_info"
                      , xmlelement("account_id", smd.account_id)
                      , xmlelement("account_number", smd.account_number)
                      , xmlelement("account_type", smd.account_type)
                      , xmlelement("account_type_name", smd.account_type_name)
                      , xmlelement("account_currency", smd.account_currency)
                      , xmlelement("account_currency_name", smd.account_currency_name)
                      , xmlelement("customer_id", smd.customer_id)
                      , xmlelement("customer_entity_type", smd.customer_entity_type)
                      , xmlelement("customer_entity_type_name", smd.customer_entity_type_name)
                      , xmlelement("customer_object_id", smd.customer_object_id)
                      , xmlelement("customer_number", smd.customer_number)
                      , xmlelement("person_first_name", smd.person_first_name)
                      , xmlelement("person_second_name", smd.person_second_name)
                      , xmlelement("person_surname", smd.person_surname)
                      , xmlelement("company_name", smd.company_name)
                      , xmlelement("company_description", smd.company_description)
                      , xmlelement("account_status", smd.account_status)
                      , xmlelement("account_status_name", smd.account_status_name)
                    )
                  , xmlelement("invoice_serial_number", smd.invoice_serial_number)
                  , xmlelement("invoice_type", smd.invoice_type)
                  , xmlelement("invoice_type_name", smd.invoice_type_name)
                  , xmlelement("invoice_exceed_limit", smd.invoice_exceed_limit)
                  , xmlelement("total_amount_due", smd.total_amount_due)
                  , xmlelement("own_funds", smd.own_funds)
                  , xmlelement("min_amount_due", smd.min_amount_due)
                  , xmlelement("invoice_start_date", smd.invoice_start_date)
                  , xmlelement("invoice_date", smd.invoice_date)
                  , xmlelement("invoice_grace_date", smd.invoice_grace_date)
                  , xmlelement("invoice_due_date", smd.invoice_due_date)
                  , xmlelement("invoice_penalty_date", smd.invoice_penalty_date)
                  , xmlelement("invoice_aging_period", smd.invoice_aging_period)
                  , xmlelement("is_gp_total_amount_paid", smd.is_gp_total_amount_paid)
                  , xmlelement("is_dp_min_amount_paid", smd.is_dp_min_amount_paid)
                  , xmlelement("institution_id", smd.institution_id)
                  , xmlelement("institution_name", smd.institution_name)
                  , xmlelement("agent_id", smd.agent_id)
                  , xmlelement("agent_name", smd.agent_name)
                  , xmlelement("invoice_overdue_date", smd.invoice_overdue_date)
                  , sed.err_data
                ) as result
          into  o_credit_invoice_report_data
          from
                (
                    select ci.id                                                     as invoice_id
                         , a.id                                                      as account_id
                         , a.account_number                                          as account_number
                         , a.account_type                                            as account_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => a.account_type
                             , i_lang    => i_lang
                           )                                                         as account_type_name
                         
                         , a.currency                                                as account_currency
                         , com_api_currency_pkg.get_currency_full_name(
                               i_curr_code => a.currency
                             , i_lang      => i_lang
                           )                                                         as account_currency_name
                         , a.customer_id                                             as customer_id
                         , pc.entity_type                                            as customer_entity_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => pc.entity_type
                             , i_lang    => i_lang
                           )                                                         as customer_entity_type_name
                         , pc.object_id                                              as customer_object_id
                         , pc.customer_number                                        as customer_number
                         , cp.first_name                                             as person_first_name
                         , cp.second_name                                            as person_second_name
                         , cp.surname                                                as person_surname
                         , com_api_i18n_pkg.get_text(
                               i_table_name  =>  'COM_COMPANY'
                             , i_column_name =>  'LABEL'
                             , i_object_id   =>  decode(
                                                     pc.entity_type
                                                   , com_api_const_pkg.ENTITY_TYPE_COMPANY
                                                   , pc.object_id
                                                   , null
                                                 )
                             , i_lang        =>  i_lang
                           )                                                         as company_name
                         , com_api_i18n_pkg.get_text(
                               i_table_name  =>  'COM_COMPANY'
                             , i_column_name =>  'DESCRIPTION'
                             , i_object_id   =>  decode(
                                                     pc.entity_type
                                                   , com_api_const_pkg.ENTITY_TYPE_COMPANY
                                                   , pc.object_id
                                                   , null
                                                 )
                             , i_lang        =>  i_lang
                           )                                                         as company_description
                         , a.status                                                  as account_status
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => a.status
                             , i_lang    => i_lang
                           )                                                         as account_status_name
                         , ci.serial_number                                          as invoice_serial_number
                         , ci.invoice_type                                           as invoice_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => ci.invoice_type
                             , i_lang    => i_lang
                           )                                                         as invoice_type_name
                         , to_char(
                                ci.exceed_limit / power(10, cr.exponent)
                              , com_api_const_pkg.XML_NUMBER_FORMAT
                                || rpad('.'
                                     , case cr.exponent 
                                            when 0
                                                then 0 
                                            else cr.exponent + 1
                                       end
                                     , '0'
                                   )
                            )                                                        as invoice_exceed_limit
                         , to_char(
                                ci.total_amount_due / power(10, cr.exponent)
                              , com_api_const_pkg.XML_NUMBER_FORMAT
                                || rpad('.'
                                     , case cr.exponent 
                                            when 0
                                                then 0 
                                            else cr.exponent + 1
                                       end
                                     , '0'
                                   )
                            )                                                        as total_amount_due
                         , to_char(
                                ci.own_funds / power(10, cr.exponent)
                              , com_api_const_pkg.XML_NUMBER_FORMAT
                                || rpad('.'
                                     , case cr.exponent 
                                            when 0
                                                then 0 
                                            else cr.exponent + 1
                                       end
                                     , '0'
                                   )
                            )                                                        as own_funds
                         , to_char(
                                ci.min_amount_due / power(10, cr.exponent)
                              , com_api_const_pkg.XML_NUMBER_FORMAT
                                || rpad('.'
                                     , case cr.exponent 
                                            when 0
                                                then 0 
                                            else cr.exponent + 1
                                       end
                                     , '0'
                                   )
                            )                                                        as min_amount_due
                         , to_char(ci.start_date, 'dd/mm/yyyy')                      as invoice_start_date
                         , to_char(ci.invoice_date, 'dd/mm/yyyy')                    as invoice_date
                         , to_char(ci.grace_date, 'dd/mm/yyyy')                      as invoice_grace_date
                         , to_char(ci.due_date, 'dd/mm/yyyy')                        as invoice_due_date
                         , to_char(ci.penalty_date, 'dd/mm/yyyy')                    as invoice_penalty_date
                         , ci.aging_period                                           as invoice_aging_period
                         , ci.is_tad_paid                                            as is_gp_total_amount_paid
                         , ci.is_mad_paid                                            as is_dp_min_amount_paid
                         , ci.inst_id                                                as institution_id
                         , ost_ui_institution_pkg.get_inst_name(
                               i_inst_id => ci.inst_id
                             , i_lang    => i_lang
                           )                                                         as institution_name
                         , ci.agent_id                                               as agent_id
                         , ost_ui_agent_pkg.get_agent_name(
                               i_agent_id => ci.agent_id
                             , i_lang     => i_lang
                           )                                                         as agent_name
                         , to_char(ci.overdue_date, 'dd/mm/yyyy')                    as invoice_overdue_date
                      from crd_invoice ci
                         , acc_account a
                         , com_currency cr
                         , prd_customer pc
                         , com_person cp
                     where ci.id = i_credit_invoice_id
                       and a.id = ci.account_id
                       and cr.code = a.currency
                       and pc.id = a.customer_id
                       and decode(
                               pc.entity_type
                             , com_api_const_pkg.ENTITY_TYPE_PERSON
                             , pc.object_id
                             , null
                           ) = cp.id(+)
                       and nvl(
                               i_lang
                             , com_api_const_pkg.LANGUAGE_ENGLISH
                           ) = cp.lang(+)
                ) smd
                left outer join
                (
                    select xmlelement(
                               "errors"
                             , xmlelement(
                                   "error"
                                 , xmlelement("error_code", com_api_error_pkg.get_last_error)
                                 , xmlelement(
                                       "error_element"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   crd_api_const_pkg.ENTITY_TYPE_INVOICE
                                           else null
                                       end
                                   )
                                 , xmlelement("error_desc", com_api_error_pkg.get_last_message)
                                 , xmlelement(
                                       "error_details"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   'ERROR_ID['||com_api_error_pkg.get_last_error_id||']'
                                           else null
                                       end
                                   )
                               )
                           ) as err_data
                      from dual
                ) sed on (1 = 1);
                
    exception
        when no_data_found then
            
            com_api_error_pkg.raise_error(
                i_error         => 'REPORT_DATA_NOT_FOUND'
            );

    end;
    
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_credit_invoice_data(' || i_credit_invoice_id || '): FINISH SUCCESS');

end generate_credit_invoice_data;

/* Obsolete. Do not use */
procedure generate_card_data(
    i_card_id            in            com_api_type_pkg.t_medium_id
  , i_lang               in            com_api_type_pkg.t_dict_value default null
  , o_card_report_data   out           xmltype
) is

begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_card_data(' || i_card_id || '): START');
    
    begin
        
        select  xmlelement("card"
                  , xmlelement("card_id", smd.card_id)
                  , xmlelement("card_mask", smd.card_mask)
                  , xmlelement("card_type_id", smd.card_type_id)
                  , xmlelement("card_type_name", smd.card_type_name)
                  , xmlelement("card_category", smd.card_category)
                  , xmlelement("card_category_name", smd.card_category_name)
                  , xmlelement("card_reg_date", smd.card_reg_date)
                  , xmlelement("card_last_instance_id", smd.card_instance_id)
                  , xmlelement("card_last_issue_reg_date", smd.card_issue_reg_date)
                  , xmlelement("card_last_issue_date", smd.card_issue_date)
                  , xmlelement("card_last_reissue_date", smd.card_reissue_date)
                  , xmlelement("card_last_reissue_reason", smd.card_reissue_reason)
                  , xmlelement("card_last_reissue_reason_name", smd.card_reissue_reason_name)
                  , xmlelement("institution_id", smd.institution_id)
                  , xmlelement("institution_name", smd.institution_name)
                  , xmlelement("country_code", smd.country_code)
                  , xmlelement("country_name", smd.country_name)
                  , xmlelement("customer_id", smd.customer_id)
                  , xmlelement("customer_entity_type", smd.customer_entity_type)
                  , xmlelement("customer_entity_type_name", smd.customer_entity_type_name)
                  , xmlelement("customer_object_id", smd.customer_object_id)
                  , xmlelement("customer_number", smd.customer_number)
                  , xmlelement("person_first_name", smd.person_first_name)
                  , xmlelement("person_second_name", smd.person_second_name)
                  , xmlelement("person_surname", smd.person_surname)
                  , xmlelement("company_name", smd.company_name)
                  , xmlelement("company_description", smd.company_description)
                  , xmlelement("customer_bank_relation", smd.customer_bank_relation)
                  , xmlelement("customer_bank_relation_name", smd.customer_bank_relation_name)
                  , xmlelement("customer_status", smd.customer_status)
                  , xmlelement("customer_status_name", smd.customer_status_name)
                  , xmlelement("customer_reg_date", smd.customer_reg_date)
                  , xmlelement("customer_last_modify_date", smd.customer_last_modify_date)
                  , xmlelement("contract_id", smd.contract_id)
                  , xmlelement("contract_type", smd.contract_type)
                  , xmlelement("contract_type_name", smd.contract_type_name)
                  , xmlelement("contract_number", smd.contract_number)
                  , xmlelement("contract_start_date", smd.contract_start_date)
                  , xmlelement("contract_end_date", smd.contract_end_date)
                  , xmlelement("contract_product_id", smd.contract_product_id)
                  , xmlelement("product_type", smd.product_type)
                  , xmlelement("product_type_name", smd.product_type_name)
                  , xmlelement("product_number", smd.product_number)
                  , xmlelement("product_status", smd.product_status)
                  , xmlelement("product_status_name", smd.product_status_name)
                  , xmlelement("cardholder_id", smd.cardholder_id)
                  , xmlelement("cardholder_person_id", smd.cardholder_person_id)
                  , xmlelement("cardholder_person_first_name", smd.cardholder_person_first_name)
                  , xmlelement("cardholder_person_second_name", smd.cardholder_person_second_name)
                  , xmlelement("cardholder_person_surname", smd.cardholder_person_surname)
                  , xmlelement("cardholder_number", smd.cardholder_number)
                  , xmlelement("cardholder_name", smd.cardholder_name)
                  , sed.err_data
                ) as result
          into  o_card_report_data
          from
                (
                    select c.id                                                      as card_id
                         , c.card_mask                                               as card_mask
                         , c.card_type_id                                            as card_type_id
                         , com_api_i18n_pkg.get_text(
                               i_table_name  =>  'NET_CARD_TYPE'
                             , i_column_name =>  'NAME'
                             , i_object_id   =>  c.card_type_id
                             , i_lang        =>  i_lang
                           )                                                         as card_type_name
                         , c.category                                                as card_category
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => c.category
                             , i_lang    => i_lang
                           )                                                         as card_category_name
                         , to_char(c.reg_date, 'dd/mm/yyyy hh24:mi:ss')              as card_reg_date
                         , row_number() over(
                                            order by ci.seq_number desc,
                                                     ci.id desc
                                        )                                            as last_rank
                         , ci.id                                                     as card_instance_id
                         , to_char(ci.reg_date, 'dd/mm/yyyy hh24:mi:ss')             as card_issue_reg_date
                         , to_char(ci.iss_date, 'dd/mm/yyyy hh24:mi:ss')             as card_issue_date
                         , to_char(ci.reissue_date, 'dd/mm/yyyy hh24:mi:ss')         as card_reissue_date
                         , ci.reissue_reason                                         as card_reissue_reason
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => ci.reissue_reason
                             , i_lang    => i_lang
                           )                                                         as card_reissue_reason_name
                         , c.inst_id                                                 as institution_id
                         , ost_ui_institution_pkg.get_inst_name(
                               i_inst_id => c.inst_id
                             , i_lang    => i_lang
                           )                                                         as institution_name
                         , c.country                                                 as country_code
                         , com_api_country_pkg.get_country_full_name(
                               i_code        => c.country
                             , i_lang        => i_lang
                             , i_raise_error => 0
                           )                                                         as country_name
                         , c.customer_id                                             as customer_id
                         , pc.entity_type                                            as customer_entity_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => pc.entity_type
                             , i_lang    => i_lang
                           )                                                         as customer_entity_type_name
                         , pc.object_id                                              as customer_object_id
                         , pc.customer_number                                        as customer_number
                         , cp.first_name                                             as person_first_name
                         , cp.second_name                                            as person_second_name
                         , cp.surname                                                as person_surname
                         , com_api_i18n_pkg.get_text(
                               i_table_name  =>  'COM_COMPANY'
                             , i_column_name =>  'LABEL'
                             , i_object_id   =>  decode(
                                                     pc.entity_type
                                                   , com_api_const_pkg.ENTITY_TYPE_COMPANY
                                                   , pc.object_id
                                                   , null
                                                 )
                             , i_lang        =>  i_lang
                           )                                                         as company_name
                         , com_api_i18n_pkg.get_text(
                               i_table_name  =>  'COM_COMPANY'
                             , i_column_name =>  'DESCRIPTION'
                             , i_object_id   =>  decode(
                                                     pc.entity_type
                                                   , com_api_const_pkg.ENTITY_TYPE_COMPANY
                                                   , pc.object_id
                                                   , null
                                                 )
                             , i_lang        =>  i_lang
                           )                                                         as company_description
                         , pc.relation                                               as customer_bank_relation
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => pc.relation
                             , i_lang    => i_lang
                           )                                                         as customer_bank_relation_name
                         , pc.status                                                 as customer_status
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => pc.status
                             , i_lang    => i_lang
                           )                                                         as customer_status_name
                         , to_char(pc.reg_date, 'dd/mm/yyyy hh24:mi:ss')             as customer_reg_date
                         , to_char(pc.last_modify_date, 'dd/mm/yyyy hh24:mi:ss')     as customer_last_modify_date
                         , c.contract_id                                             as contract_id
                         , pcr.contract_type                                         as contract_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => pcr.contract_type
                             , i_lang    => i_lang
                           )                                                         as contract_type_name
                         , pcr.contract_number                                       as contract_number
                         , to_char(pcr.start_date, 'dd/mm/yyyy hh24:mi:ss')          as contract_start_date
                         , to_char(pcr.end_date, 'dd/mm/yyyy hh24:mi:ss')            as contract_end_date
                         , pcr.product_id                                            as contract_product_id
                         , prd.product_type                                          as product_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => prd.product_type
                             , i_lang    => i_lang
                           )                                                         as product_type_name
                         , prd.product_number                                        as product_number
                         , prd.status                                                as product_status
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => prd.status
                             , i_lang    => i_lang
                           )                                                         as product_status_name
                         , c.cardholder_id                                           as cardholder_id
                         , ch.person_id                                              as cardholder_person_id
                         , chp.first_name                                            as cardholder_person_first_name
                         , chp.second_name                                           as cardholder_person_second_name
                         , chp.surname                                               as cardholder_person_surname
                         , ch.cardholder_number                                      as cardholder_number
                         , ch.cardholder_name                                        as cardholder_name
                      from iss_card c
                         , iss_card_instance ci
                         , prd_customer pc
                         , com_person cp
                         , prd_contract pcr
                         , prd_product prd
                         , iss_cardholder ch
                         , com_person chp
                     where c.id = i_card_id
                       and ci.card_id  = c.id
                       and pc.id = c.customer_id
                       and decode(
                               pc.entity_type
                             , com_api_const_pkg.ENTITY_TYPE_PERSON
                             , pc.object_id
                             , null
                           ) = cp.id(+)
                       and nvl(
                               i_lang
                             , com_api_const_pkg.LANGUAGE_ENGLISH
                           ) = cp.lang(+)
                       and pcr.id = c.contract_id
                       and prd.id = pcr.product_id
                       and ch.id = c.cardholder_id
                       and chp.id = ch.person_id
                       and chp.lang = com_api_const_pkg.LANGUAGE_ENGLISH
                ) smd
                left outer join
                (
                    select xmlelement(
                               "errors"
                             , xmlelement(
                                   "error"
                                 , xmlelement("error_code", com_api_error_pkg.get_last_error)
                                 , xmlelement(
                                       "error_element"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   iss_api_const_pkg.ENTITY_TYPE_CARD
                                           else null
                                       end
                                   )
                                 , xmlelement("error_desc", com_api_error_pkg.get_last_message)
                                 , xmlelement(
                                       "error_details"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   'ERROR_ID['||com_api_error_pkg.get_last_error_id||']'
                                           else null
                                       end
                                   )
                               )
                           ) as err_data
                      from dual
                ) sed on (1 = 1)
         where smd.last_rank = 1;
            
    exception
        when no_data_found then
            
            com_api_error_pkg.raise_error(
                i_error         => 'REPORT_DATA_NOT_FOUND'
            );

    end;
     
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_card_data(' || i_card_id || '): FINISH SUCCESS');
        
end generate_card_data;

/* Obsolete. Do not use */
procedure generate_card_instance_data(
    i_card_instance_id       in            com_api_type_pkg.t_medium_id
  , i_lang                   in            com_api_type_pkg.t_dict_value default null
  , o_card_inst_report_data  out           xmltype
) is
    l_eff_date     date := get_sysdate;
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_card_instance_data(' || i_card_instance_id || '): START');
    
    begin
        
        select  xmlelement("card_instance"
                  , xmlelement("card_id", smd.card_id)
                  , xmlelement("card_mask", smd.card_mask)
                  , xmlelement("card_short_mask", smd.short_card_mask)
                  , xmlelement("card_type_id", smd.card_type_id)
                  , xmlelement("card_type_name", smd.card_type_name)
                  , xmlelement("card_category", smd.card_category)
                  , xmlelement("card_category_name", smd.card_category_name)
                  , xmlelement("card_reg_date", smd.card_reg_date)
                  , xmlelement("card_instance_id", smd.card_instance_id)
                  , xmlelement("card_issue_reg_date", smd.card_issue_reg_date)
                  , xmlelement("card_issue_date", smd.card_issue_date)
                  , xmlelement("card_expir_date", smd.card_expir_date)
                  , xmlelement("card_reissue_date", smd.card_reissue_date)
                  , xmlelement("card_reissue_reason", smd.card_reissue_reason)
                  , xmlelement("card_reissue_reason_name", smd.card_reissue_reason_name)
                  , xmlelement("institution_id", smd.institution_id)
                  , xmlelement("institution_name", smd.institution_name)
                  , (select xmlelement(
                                "institution_contacts"
                              , xmlagg(
                                    xmlelement(
                                        "contact"
                                      , xmlattributes(co.contact_type as "contact_type", cd.commun_method as "communication_method")
                                      , xmlelement(
                                            "communication_address"
                                          , com_api_contact_pkg.get_contact_string(
                                                i_contact_id    => co.contact_id
                                              , i_commun_method => cd.commun_method
                                              , i_start_date    => l_eff_date
                                            )
                                        )
                                    ) order by co.contact_type, cd.commun_method, co.id desc
                                )
                            )
                       from com_contact_object co
                          , com_contact_data cd
                      where co.object_id = smd.institution_id
                        and co.entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                        and co.contact_id  = cd.contact_id
                    )
                  , xmlelement("agent_id", smd.agent_id)
                  , xmlelement("agent_name", smd.agent_name)
                  , (select xmlelement(
                                "agent_contacts"
                              , xmlagg(
                                    xmlelement(
                                        "contact"
                                      , xmlattributes(co.contact_type as "contact_type", cd.commun_method as "communication_method")
                                      , xmlelement(
                                            "communication_address"
                                          , com_api_contact_pkg.get_contact_string(
                                                i_contact_id    => co.contact_id
                                              , i_commun_method => cd.commun_method
                                              , i_start_date    => l_eff_date
                                            )
                                        )
                                    ) order by co.contact_type, cd.commun_method, co.id desc
                                )
                            )
                       from com_contact_object co
                          , com_contact_data cd
                      where co.object_id = smd.agent_id
                        and co.entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT
                        and co.contact_id  = cd.contact_id
                    )
                  , xmlelement("country_code", smd.country_code)
                  , xmlelement("country_name", smd.country_name)
                  , xmlelement("customer_id", smd.customer_id)
                  , xmlelement("customer_entity_type", smd.customer_entity_type)
                  , xmlelement("customer_entity_type_name", smd.customer_entity_type_name)
                  , xmlelement("customer_object_id", smd.customer_object_id)
                  , xmlelement("customer_number", smd.customer_number)
                  , xmlelement("person_first_name", smd.person_first_name)
                  , xmlelement("person_second_name", smd.person_second_name)
                  , xmlelement("person_surname", smd.person_surname)
                  , xmlelement("company_name", smd.company_name)
                  , xmlelement("company_description", smd.company_description)
                  , xmlelement("customer_bank_relation", smd.customer_bank_relation)
                  , xmlelement("customer_bank_relation_name", smd.customer_bank_relation_name)
                  , xmlelement("customer_status", smd.customer_status)
                  , xmlelement("customer_status_name", smd.customer_status_name)
                  , xmlelement("customer_reg_date", smd.customer_reg_date)
                  , xmlelement("customer_last_modify_date", smd.customer_last_modify_date)
                  , xmlelement("contract_id", smd.contract_id)
                  , xmlelement("contract_type", smd.contract_type)
                  , xmlelement("contract_type_name", smd.contract_type_name)
                  , xmlelement("contract_number", smd.contract_number)
                  , xmlelement("contract_start_date", smd.contract_start_date)
                  , xmlelement("contract_end_date", smd.contract_end_date)
                  , xmlelement("contract_product_id", smd.contract_product_id)
                  , xmlelement("product_type", smd.product_type)
                  , xmlelement("product_type_name", smd.product_type_name)
                  , xmlelement("product_number", smd.product_number)
                  , xmlelement("product_status", smd.product_status)
                  , xmlelement("product_status_name", smd.product_status_name)
                  , xmlelement("cardholder_id", smd.cardholder_id)
                  , xmlelement("cardholder_person_id", smd.cardholder_person_id)
                  , xmlelement("cardholder_person_first_name", smd.cardholder_person_first_name)
                  , xmlelement("cardholder_person_second_name", smd.cardholder_person_second_name)
                  , xmlelement("cardholder_person_surname", smd.cardholder_person_surname)
                  , xmlelement("cardholder_number", smd.cardholder_number)
                  , xmlelement("cardholder_name", smd.cardholder_name)
                  , sed.err_data
                ) as result
          into  o_card_inst_report_data
          from
                (
                    select c.id                                                      as card_id
                         , c.card_mask                                               as card_mask
                         , iss_api_card_pkg.get_short_card_mask(
                               i_card_number => c.card_mask 
                           )                                                         as short_card_mask
                         , c.card_type_id                                            as card_type_id
                         , com_api_i18n_pkg.get_text(
                               i_table_name  =>  'NET_CARD_TYPE'
                             , i_column_name =>  'NAME'
                             , i_object_id   =>  c.card_type_id
                             , i_lang        =>  i_lang
                           )                                                         as card_type_name
                         , c.category                                                as card_category
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => c.category
                             , i_lang    => i_lang
                           )                                                         as card_category_name
                         , to_char(c.reg_date, 'dd/mm/yyyy hh24:mi:ss')              as card_reg_date
                         , ci.id                                                     as card_instance_id
                         , to_char(ci.reg_date, 'dd/mm/yyyy hh24:mi:ss')             as card_issue_reg_date
                         , to_char(ci.iss_date, 'dd/mm/yyyy hh24:mi:ss')             as card_issue_date
                         , to_char(ci.reissue_date, 'dd/mm/yyyy hh24:mi:ss')         as card_reissue_date
                         , to_char(ci.expir_date, 'dd/mm/yyyy')                      as card_expir_date
                         , ci.reissue_reason                                         as card_reissue_reason
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => ci.reissue_reason
                             , i_lang    => i_lang
                           )                                                         as card_reissue_reason_name
                         , c.inst_id                                                 as institution_id
                         , ost_ui_institution_pkg.get_inst_name(
                               i_inst_id => c.inst_id
                             , i_lang    => i_lang
                           )                                                         as institution_name
                         , ci.agent_id                                               as agent_id
                         , ost_ui_agent_pkg.get_agent_name(
                               i_agent_id => ci.agent_id
                             , i_lang     => i_lang
                           )                                                         as agent_name
                         , c.country                                                 as country_code
                         , com_api_country_pkg.get_country_full_name(
                               i_code        => c.country
                             , i_lang        => i_lang
                             , i_raise_error => 0
                           )                                                         as country_name
                         , c.customer_id                                             as customer_id
                         , pc.entity_type                                            as customer_entity_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => pc.entity_type
                             , i_lang    => i_lang
                           )                                                         as customer_entity_type_name
                         , pc.object_id                                              as customer_object_id
                         , pc.customer_number                                        as customer_number
                         , cp.first_name                                             as person_first_name
                         , cp.second_name                                            as person_second_name
                         , cp.surname                                                as person_surname
                         , com_api_i18n_pkg.get_text(
                               i_table_name  =>  'COM_COMPANY'
                             , i_column_name =>  'LABEL'
                             , i_object_id   =>  decode(
                                                     pc.entity_type
                                                   , com_api_const_pkg.ENTITY_TYPE_COMPANY
                                                   , pc.object_id
                                                   , null
                                                 )
                             , i_lang        =>  i_lang
                           )                                                         as company_name
                         , com_api_i18n_pkg.get_text(
                               i_table_name  =>  'COM_COMPANY'
                             , i_column_name =>  'DESCRIPTION'
                             , i_object_id   =>  decode(
                                                     pc.entity_type
                                                   , com_api_const_pkg.ENTITY_TYPE_COMPANY
                                                   , pc.object_id
                                                   , null
                                                 )
                             , i_lang        =>  i_lang
                           )                                                         as company_description
                         , pc.relation                                               as customer_bank_relation
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => pc.relation
                             , i_lang    => i_lang
                           )                                                         as customer_bank_relation_name
                         , pc.status                                                 as customer_status
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => pc.status
                             , i_lang    => i_lang
                           )                                                         as customer_status_name
                         , to_char(pc.reg_date, 'dd/mm/yyyy hh24:mi:ss')             as customer_reg_date
                         , to_char(pc.last_modify_date, 'dd/mm/yyyy hh24:mi:ss')     as customer_last_modify_date
                         , c.contract_id                                             as contract_id
                         , pcr.contract_type                                         as contract_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => pcr.contract_type
                             , i_lang    => i_lang
                           )                                                         as contract_type_name
                         , pcr.contract_number                                       as contract_number
                         , to_char(pcr.start_date, 'dd/mm/yyyy hh24:mi:ss')          as contract_start_date
                         , to_char(pcr.end_date, 'dd/mm/yyyy hh24:mi:ss')            as contract_end_date
                         , pcr.product_id                                            as contract_product_id
                         , prd.product_type                                          as product_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => prd.product_type
                             , i_lang    => i_lang
                           )                                                         as product_type_name
                         , prd.product_number                                        as product_number
                         , prd.status                                                as product_status
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => prd.status
                             , i_lang    => i_lang
                           )                                                         as product_status_name
                         , c.cardholder_id                                           as cardholder_id
                         , ch.person_id                                              as cardholder_person_id
                         , chp.first_name                                            as cardholder_person_first_name
                         , chp.second_name                                           as cardholder_person_second_name
                         , chp.surname                                               as cardholder_person_surname
                         , ch.cardholder_number                                      as cardholder_number
                         , ch.cardholder_name                                        as cardholder_name
                      from iss_card_instance ci
                         , iss_card c
                         , prd_customer pc
                         , com_person cp
                         , prd_contract pcr
                         , prd_product prd
                         , iss_cardholder ch
                         , com_person chp
                     where ci.id = i_card_instance_id
                       and c.id  = ci.card_id
                       and pc.id = c.customer_id
                       and decode(
                               pc.entity_type
                             , com_api_const_pkg.ENTITY_TYPE_PERSON
                             , pc.object_id
                             , null
                           ) = cp.id(+)
                       and nvl(
                               i_lang
                             , com_api_const_pkg.LANGUAGE_ENGLISH
                           ) = cp.lang(+)
                       and pcr.id = c.contract_id
                       and prd.id = pcr.product_id
                       and ch.id = c.cardholder_id
                       and chp.id = ch.person_id
                       and chp.lang = com_api_const_pkg.LANGUAGE_ENGLISH
                ) smd
                left outer join
                (
                    select xmlelement(
                               "errors"
                             , xmlelement(
                                   "error"
                                 , xmlelement("error_code", com_api_error_pkg.get_last_error)
                                 , xmlelement(
                                       "error_element"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                                           else null
                                       end
                                   )
                                 , xmlelement("error_desc", com_api_error_pkg.get_last_message)
                                 , xmlelement(
                                       "error_details"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   'ERROR_ID['||com_api_error_pkg.get_last_error_id||']'
                                           else null
                                       end
                                   )
                               )
                           ) as err_data
                      from dual
                ) sed on (1 = 1);
            
    exception
        when no_data_found then
            
            com_api_error_pkg.raise_error(
                i_error         => 'REPORT_DATA_NOT_FOUND'
            );

    end;
     
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_card_instance_data(' || i_card_instance_id || '): FINISH SUCCESS');
        
end generate_card_instance_data;

/* Obsolete. Do not use */
procedure generate_merchant_data(
    i_merchant_id            in            com_api_type_pkg.t_short_id
  , i_lang                   in            com_api_type_pkg.t_dict_value default null
  , o_merchant_report_data   out           xmltype
) is

begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_merchant_data('||i_merchant_id||'): START');
    
    begin
        
        select  xmlelement("merchant"
                  , xmlelement("merchant_id", smd.merchant_id)
                  , xmlelement("merchant_number", smd.merchant_number)
                  , xmlelement("merchant_name", smd.merchant_name)
                  , xmlelement("merchant_label", smd.merchant_label)
                  , xmlelement("merchant_type", smd.merchant_type)
                  , xmlelement("merchant_type_name", smd.merchant_type_name)
                  , xmlelement("mcc", smd.mcc)
                  , xmlelement("mcc_name", smd.mcc_name)
                  , xmlelement("merchant_status", smd.merchant_status)
                  , xmlelement("merchant_status_name", smd.merchant_status_name)
                  , xmlelement("institution_id", smd.institution_id)
                  , xmlelement("institution_name", smd.institution_name)
                  , xmlelement("contract_id", smd.contract_id)
                  , xmlelement("contract_type", smd.contract_type)
                  , xmlelement("contract_type_name", smd.contract_type_name)
                  , xmlelement("contract_number", smd.contract_number)
                  , xmlelement("contract_start_date", smd.contract_start_date)
                  , xmlelement("contract_end_date", smd.contract_end_date)
                  , xmlelement("contract_product_id", smd.contract_product_id)
                  , xmlelement("product_label", smd.product_label)
                  , xmlelement("product_description", smd.product_description)
                  , xmlelement("product_type", smd.product_type)
                  , xmlelement("product_type_name", smd.product_type_name)
                  , xmlelement("product_number", smd.product_number)
                  , xmlelement("product_status", smd.product_status)
                  , xmlelement("product_status_name", smd.product_status_name)
                  , xmlelement("customer_id", smd.customer_id)
                  , xmlelement("customer_entity_type", smd.customer_entity_type)
                  , xmlelement("customer_entity_type_name", smd.customer_entity_type_name)
                  , xmlelement("customer_object_id", smd.customer_object_id)
                  , xmlelement("customer_number", smd.customer_number)
                  , xmlelement("person_first_name", smd.person_first_name)
                  , xmlelement("person_second_name", smd.person_second_name)
                  , xmlelement("person_surname", smd.person_surname)
                  , xmlelement("company_name", smd.company_name)
                  , xmlelement("company_description", smd.company_description)
                  , xmlelement("customer_bank_relation", smd.customer_bank_relation)
                  , xmlelement("customer_bank_relation_name", smd.customer_bank_relation_name)
                  , xmlelement("customer_status", smd.customer_status)
                  , xmlelement("customer_status_name", smd.customer_status_name)
                  , xmlelement("customer_reg_date", smd.customer_reg_date)
                  , xmlelement("customer_last_modify_date", smd.customer_last_modify_date)
                  , sed.err_data
                ) as result
          into  o_merchant_report_data
          from
                (
                    select am.id                                                     as merchant_id
                         , am.merchant_number                                        as merchant_number
                         , am.merchant_name                                          as merchant_name
                         , com_api_i18n_pkg.get_text(
                               i_table_name  =>  'ACQ_MERCHANT'
                             , i_column_name =>  'LABEL'
                             , i_object_id   =>  am.id
                             , i_lang        =>  i_lang
                           )                                                         as merchant_label
                         , am.merchant_type                                          as merchant_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => am.merchant_type
                             , i_lang    => i_lang
                           )                                                         as merchant_type_name
                         , am.mcc                                                    as mcc
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => cmcc.id
                             , i_lang    => i_lang
                           )                                                         as mcc_name
                         , am.status                                                 as merchant_status
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => am.status
                             , i_lang    => i_lang
                           )                                                         as merchant_status_name
                         , am.inst_id                                                as institution_id
                         , ost_ui_institution_pkg.get_inst_name(
                               i_inst_id => am.inst_id
                             , i_lang    => i_lang
                           )                                                         as institution_name
                         , am.contract_id                                            as contract_id
                         , pcr.contract_type                                         as contract_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => pcr.contract_type
                             , i_lang    => i_lang
                           )                                                         as contract_type_name
                         , pcr.contract_number                                       as contract_number
                         , to_char(pcr.start_date, 'dd/mm/yyyy hh24:mi:ss')          as contract_start_date
                         , to_char(pcr.end_date, 'dd/mm/yyyy hh24:mi:ss')            as contract_end_date
                         , pcr.product_id                                            as contract_product_id
                         , com_api_i18n_pkg.get_text(
                               i_table_name  =>  'PRD_PRODUCT'
                             , i_column_name =>  'LABEL'
                             , i_object_id   =>  pcr.product_id
                             , i_lang        =>  i_lang
                           )                                                         as product_label
                         , com_api_i18n_pkg.get_text(
                               i_table_name  =>  'PRD_PRODUCT'
                             , i_column_name =>  'DESCRIPTION'
                             , i_object_id   =>  pcr.product_id
                             , i_lang        =>  i_lang
                           )                                                         as product_description
                         , prd.product_type                                          as product_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => prd.product_type
                             , i_lang    => i_lang
                           )                                                         as product_type_name
                         , prd.product_number                                        as product_number
                         , prd.status                                                as product_status
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => prd.status
                             , i_lang    => i_lang
                           )                                                         as product_status_name
                         , pcr.customer_id                                           as customer_id
                         , pcu.entity_type                                           as customer_entity_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => pcu.entity_type
                             , i_lang    => i_lang
                           )                                                         as customer_entity_type_name
                         , pcu.object_id                                             as customer_object_id
                         , pcu.customer_number                                       as customer_number
                         , cp.first_name                                             as person_first_name
                         , cp.second_name                                            as person_second_name
                         , cp.surname                                                as person_surname
                         , com_api_i18n_pkg.get_text(
                               i_table_name  =>  'COM_COMPANY'
                             , i_column_name =>  'LABEL'
                             , i_object_id   =>  decode(
                                                     pcu.entity_type
                                                   , com_api_const_pkg.ENTITY_TYPE_COMPANY
                                                   , pcu.object_id
                                                   , null
                                                 )
                             , i_lang        =>  i_lang
                           )                                                         as company_name
                         , com_api_i18n_pkg.get_text(
                               i_table_name  =>  'COM_COMPANY'
                             , i_column_name =>  'DESCRIPTION'
                             , i_object_id   =>  decode(
                                                     pcu.entity_type
                                                   , com_api_const_pkg.ENTITY_TYPE_COMPANY
                                                   , pcu.object_id
                                                   , null
                                                 )
                             , i_lang        =>  i_lang
                           )                                                         as company_description
                         , pcu.relation                                              as customer_bank_relation
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => pcu.relation
                             , i_lang    => i_lang
                           )                                                         as customer_bank_relation_name
                         , pcu.status                                                as customer_status
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => pcu.status
                             , i_lang    => i_lang
                           )                                                         as customer_status_name
                         , to_char(pcu.reg_date, 'dd/mm/yyyy hh24:mi:ss')            as customer_reg_date
                         , to_char(pcu.last_modify_date, 'dd/mm/yyyy hh24:mi:ss')    as customer_last_modify_date
                      from acq_merchant am
                         , com_mcc cmcc
                         , prd_contract pcr
                         , prd_product prd
                         , prd_customer pcu
                         , com_person cp
                     where am.id = i_merchant_id
                       and cmcc.mcc = am.mcc
                       and pcr.id = am.contract_id
                       and prd.id = pcr.product_id
                       and pcu.id = pcr.customer_id
                       and decode(
                               pcu.entity_type
                             , com_api_const_pkg.ENTITY_TYPE_PERSON
                             , pcu.object_id
                             , null
                           ) = cp.id(+)
                       and nvl(
                               i_lang
                             , com_api_const_pkg.LANGUAGE_ENGLISH
                           ) = cp.lang(+)
                ) smd
                left outer join
                (
                    select xmlelement(
                               "errors"
                             , xmlelement(
                                   "error"
                                 , xmlelement("error_code", com_api_error_pkg.get_last_error)
                                 , xmlelement(
                                       "error_element"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                           else null
                                       end
                                   )
                                 , xmlelement("error_desc", com_api_error_pkg.get_last_message)
                                 , xmlelement(
                                       "error_details"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   'ERROR_ID[' || com_api_error_pkg.get_last_error_id || ']'
                                           else null
                                       end
                                   )
                               )
                           ) as err_data
                      from dual
                ) sed on (1 = 1);
            
    exception
        when no_data_found then
            
            com_api_error_pkg.raise_error(
                i_error         => 'REPORT_DATA_NOT_FOUND'
            );

    end;
     
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_merchant_data(' || i_merchant_id || '): FINISH SUCCESS');
        
end generate_merchant_data;

/* Obsolete. Do not use */
procedure generate_session_data(
    i_session_id            in      com_api_type_pkg.t_medium_id
  , i_lang                  in      com_api_type_pkg.t_dict_value default null
  , o_session_report_data   out     xmltype
) is

begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_session_data(' || i_session_id || '): START');
    
    begin
        
        select  xmlelement("session"
                  , xmlelement("session_id", smd.session_id)
                  , xmlelement("process_id", smd.process_id)
                  , xmlelement("process_procedure", smd.process_procedure)
                  , xmlelement("process_is_parallel", smd.process_is_parallel)
                  , xmlelement("process_institution_id", smd.process_institution_id)
                  , xmlelement("process_institution_name", smd.process_institution_name)
                  , xmlelement("process_is_external", smd.process_is_external)
                  , xmlelement("process_is_container", smd.process_is_container)
                  , xmlelement("process_interrupt_threads", smd.process_interrupt_threads)
                  , xmlelement("session_start_time", smd.session_start_time)
                  , xmlelement("session_end_time", smd.session_end_time)
                  , xmlelement("session_thread_count", smd.session_thread_count)
                  , xmlelement("session_estimated_count", smd.session_estimated_count)
                  , xmlelement("session_processed", smd.session_processed)
                  , xmlelement("session_rejected", smd.session_rejected)
                  , xmlelement("session_excepted", smd.session_excepted)
                  , xmlelement("session_user_id", smd.session_user_id)
                  , xmlelement("session_user_login", smd.session_user_login)
                  , xmlelement("session_user_name", smd.session_user_name)
                  , xmlelement("session_user_surname", smd.session_user_surname)
                  , xmlelement("session_result_code", smd.session_result_code)
                  , xmlelement("session_result_name", smd.session_result_name)
                  , xmlelement("session_settlement_day", smd.session_settlement_day)
                  , xmlelement("session_settlement_date", smd.session_settlement_date)
                  , xmlelement("session_ip_address", smd.session_ip_address)
                  , sed.err_data
                ) as result
          into  o_session_report_data
          from
                (
                    select s.id                                                      as session_id
                         , s.process_id                                              as process_id
                         , p.procedure_name                                          as process_procedure
                         , p.is_parallel                                             as process_is_parallel
                         , p.inst_id                                                 as process_institution_id
                         , ost_ui_institution_pkg.get_inst_name(
                               i_inst_id => p.inst_id
                             , i_lang    => i_lang
                           )                                                         as process_institution_name
                         , p.is_external                                             as process_is_external
                         , p.is_container                                            as process_is_container
                         , p.interrupt_threads                                       as process_interrupt_threads
                         , to_char(s.start_time, 'dd/mm/yyyy hh24:mi:ss,ff6')        as session_start_time
                         , to_char(s.end_time, 'dd/mm/yyyy hh24:mi:ss,ff6')          as session_end_time
                         , s.thread_count                                            as session_thread_count
                         , s.estimated_count                                         as session_estimated_count
                         , s.processed                                               as session_processed
                         , s.rejected                                                as session_rejected
                         , s.excepted                                                as session_excepted
                         , s.user_id                                                 as session_user_id
                         , u.name                                                    as session_user_login
                         , c.first_name                                              as session_user_name
                         , c.surname                                                 as session_user_surname
                         , s.result_code                                             as session_result_code
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => s.result_code
                             , i_lang    => i_lang
                           )                                                         as session_result_name
                         , s.sttl_day                                                as session_settlement_day
                         , to_char(s.sttl_date, 'dd/mm/yyyy')                        as session_settlement_date
                         , s.ip_address                                              as session_ip_address
                      from prc_session s
                         , prc_process p
                         , acm_user u
                         , com_person c
                     where s.id = i_session_id
                       and s.process_id = p.id(+)
                       and s.user_id = u.id
                       and u.person_id = c.id(+)
                ) smd
                left outer join
                (
                    select xmlelement(
                               "errors"
                             , xmlelement(
                                   "error"
                                 , xmlelement("error_code", com_api_error_pkg.get_last_error)
                                 , xmlelement(
                                       "error_element"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   prc_api_const_pkg.ENTITY_TYPE_SESSION
                                           else null
                                       end
                                   )
                                 , xmlelement("error_desc", com_api_error_pkg.get_last_message)
                                 , xmlelement(
                                       "error_details"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   'ERROR_ID['||com_api_error_pkg.get_last_error_id||']'
                                           else null
                                       end
                                   )
                               )
                           ) as err_data
                      from dual
                ) sed on (1 = 1);
            
    exception
        when no_data_found then
            
            com_api_error_pkg.raise_error(
                i_error         => 'REPORT_DATA_NOT_FOUND'
            );

    end;
     
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_session_data(' || i_session_id || '): FINISH SUCCESS');
        
end generate_session_data;

/* Obsolete. Do not use */
procedure generate_settlement_data(
    i_sttl_day_id            in            com_api_type_pkg.t_long_id
  , i_lang                   in            com_api_type_pkg.t_dict_value default null
  , o_sttl_day_report_data   out           xmltype
) is

begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_settlement_data(' || i_sttl_day_id || '): START');
    
    begin
        
        select  xmlelement("settlement_day"
                  , xmlelement("settlement_day_id", smd.settlement_day_id)
                  , xmlelement("institution_id", smd.institution_id)
                  , xmlelement("institution_name", smd.institution_name)
                  , xmlelement("settlement_day_number", smd.settlement_day_number)
                  , xmlelement("settlement_date_open", smd.settlement_date_open)
                  , xmlelement("sttl_open_timestamp", smd.sttl_open_timestamp)
                  , xmlelement("settlement_is_open", smd.settlement_is_open)
                  , xmlelement("settlement_date_close", smd.settlement_date_close)
                  , sed.err_data
                ) as result
          into  o_sttl_day_report_data
          from
                (
                    select d.id                                                      as settlement_day_id
                         , d.inst_id                                                 as institution_id
                         , ost_ui_institution_pkg.get_inst_name(
                               i_inst_id => d.inst_id
                             , i_lang    => i_lang
                           )                                                         as institution_name
                         , d.sttl_day                                                as settlement_day_number
                         , to_char(d.sttl_date, 'dd/mm/yyyy')                        as settlement_date_open
                         , to_char(d.open_timestamp, 'dd/mm/yyyy hh24:mi:ss,ff6')    as sttl_open_timestamp
                         , d.is_open                                                 as settlement_is_open
                         , decode(
                               d.is_open
                             , 0
                             , to_char(d.sttl_date, 'dd/mm/yyyy')
                             , null
                           )                                                         as settlement_date_close
                      from com_settlement_day d
                     where d.id = i_sttl_day_id
                ) smd
                left outer join
                (
                    select xmlelement(
                               "errors"
                             , xmlelement(
                                   "error"
                                 , xmlelement("error_code", com_api_error_pkg.get_last_error)
                                 , xmlelement(
                                       "error_element"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   com_api_const_pkg.ENTITY_TYPE_STTL_DATE
                                           else null
                                       end
                                   )
                                 , xmlelement("error_desc", com_api_error_pkg.get_last_message)
                                 , xmlelement(
                                       "error_details"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   'ERROR_ID['||com_api_error_pkg.get_last_error_id||']'
                                           else null
                                       end
                                   )
                               )
                           ) as err_data
                      from dual
                ) sed on (1 = 1);
            
    exception
        when no_data_found then
            
            com_api_error_pkg.raise_error(
                i_error         => 'REPORT_DATA_NOT_FOUND'
            );

    end;
     
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_settlement_data(' || i_sttl_day_id || '): FINISH SUCCESS');

end generate_settlement_data;

/* Obsolete. Do not use */
procedure generate_terminal_data(
    i_terminal_id            in            com_api_type_pkg.t_short_id
  , i_lang                   in            com_api_type_pkg.t_dict_value default null
  , o_terminal_report_data   out           xmltype
) is

begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_terminal_data(' || i_terminal_id || '): START');
    
    begin
        
        select  xmlelement("terminal"
                  , xmlelement("terminal_id", smd.terminal_id)
                  , xmlelement("terminal_is_template", smd.terminal_is_template)
                  , xmlelement("terminal_number", smd.terminal_number)
                  , xmlelement("terminal_type", smd.terminal_type)
                  , xmlelement("terminal_type_name", smd.terminal_type_name)
                  , xmlelement("merchant_id", smd.merchant_id)
                  , xmlelement("merchant_name", smd.merchant_name)
                  , xmlelement("imprinter_plastic_number", smd.imprinter_plastic_number)
                  , xmlelement("card_data_input_cap", smd.card_data_input_cap)
                  , xmlelement("card_data_input_cap_name", smd.card_data_input_cap_name)
                  , xmlelement("crdh_auth_cap", smd.crdh_auth_cap)
                  , xmlelement("crdh_auth_cap_name", smd.crdh_auth_cap_name)
                  , xmlelement("card_capture_cap", smd.card_capture_cap)
                  , xmlelement("card_capture_cap_name", smd.card_capture_cap_name)
                  , xmlelement("term_operating_env", smd.term_operating_env)
                  , xmlelement("term_operating_env_name", smd.term_operating_env_name)
                  , xmlelement("crdh_data_present", smd.crdh_data_present)
                  , xmlelement("crdh_data_present_name", smd.crdh_data_present_name)
                  , xmlelement("card_data_present", smd.card_data_present)
                  , xmlelement("card_data_present_name", smd.card_data_present_name)
                  , xmlelement("card_data_input_mode", smd.card_data_input_mode)
                  , xmlelement("card_data_input_mode_name", smd.card_data_input_mode_name)
                  , xmlelement("crdh_auth_method", smd.crdh_auth_method)
                  , xmlelement("crdh_auth_method_name", smd.crdh_auth_method_name)
                  , xmlelement("crdh_auth_entity", smd.crdh_auth_entity)
                  , xmlelement("crdh_auth_entity_name", smd.crdh_auth_entity_name)
                  , xmlelement("card_data_output_cap", smd.card_data_output_cap)
                  , xmlelement("card_data_output_cap_name", smd.card_data_output_cap_name)
                  , xmlelement("term_data_output_cap", smd.term_data_output_cap)
                  , xmlelement("term_data_output_cap_name", smd.term_data_output_cap_name)
                  , xmlelement("pin_capture_cap", smd.pin_capture_cap)
                  , xmlelement("pin_capture_cap_name", smd.pin_capture_cap_name)
                  , xmlelement("cat_level", smd.cat_level)
                  , xmlelement("cat_level_name", smd.cat_level_name)
                  , xmlelement("terminal_gmt_offset", smd.terminal_gmt_offset)
                  , xmlelement("use_message_auth_code", smd.use_message_auth_code)
                  , xmlelement("device_id", smd.device_id)
                  , xmlelement("terminal_status", smd.terminal_status)
                  , xmlelement("terminal_status_name", smd.terminal_status_name)
                  , xmlelement("cash_dispenser_present", smd.cash_dispenser_present)
                  , xmlelement("payment_possibility", smd.payment_possibility)
                  , xmlelement("use_card_possibility", smd.use_card_possibility)
                  , xmlelement("cash_in_present", smd.cash_in_present)
                  , xmlelement("terminal_profile_id", smd.terminal_profile_id)
                  , sed.err_data
                ) as result
          into  o_terminal_report_data
          from
                (
                    select at.id                                                     as terminal_id
                         , at.is_template                                            as terminal_is_template
                         , at.terminal_number                                        as terminal_number
                         , at.terminal_type                                          as terminal_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => at.terminal_type
                             , i_lang    => i_lang
                           )                                                         as terminal_type_name
                         , at.merchant_id                                            as merchant_id
                         , am.merchant_name                                          as merchant_name
                         , at.plastic_number                                         as imprinter_plastic_number
                         , at.card_data_input_cap                                    as card_data_input_cap
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => at.card_data_input_cap
                             , i_lang    => i_lang
                           )                                                         as card_data_input_cap_name
                         , at.crdh_auth_cap                                          as crdh_auth_cap
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => at.crdh_auth_cap
                             , i_lang    => i_lang
                           )                                                         as crdh_auth_cap_name
                         , at.card_capture_cap                                       as card_capture_cap
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => at.card_capture_cap
                             , i_lang    => i_lang
                           )                                                         as card_capture_cap_name
                         , at.term_operating_env                                     as term_operating_env
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => at.term_operating_env
                             , i_lang    => i_lang
                           )                                                         as term_operating_env_name
                         , at.crdh_data_present                                      as crdh_data_present
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => at.crdh_data_present
                             , i_lang    => i_lang
                           )                                                         as crdh_data_present_name
                         , at.card_data_present                                      as card_data_present
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => at.card_data_present
                             , i_lang    => i_lang
                           )                                                         as card_data_present_name
                         , at.card_data_input_mode                                   as card_data_input_mode
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => at.card_data_input_mode
                             , i_lang    => i_lang
                           )                                                         as card_data_input_mode_name
                         , at.crdh_auth_method                                       as crdh_auth_method
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => at.crdh_auth_method
                             , i_lang    => i_lang
                           )                                                         as crdh_auth_method_name
                         , at.crdh_auth_entity                                       as crdh_auth_entity
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => at.crdh_auth_entity
                             , i_lang    => i_lang
                           )                                                         as crdh_auth_entity_name
                         , at.card_data_output_cap                                   as card_data_output_cap
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => at.card_data_output_cap
                             , i_lang    => i_lang
                           )                                                         as card_data_output_cap_name
                         , at.term_data_output_cap                                   as term_data_output_cap
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => at.term_data_output_cap
                             , i_lang    => i_lang
                           )                                                         as term_data_output_cap_name
                         , at.pin_capture_cap                                        as pin_capture_cap
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => at.pin_capture_cap
                             , i_lang    => i_lang
                           )                                                         as pin_capture_cap_name
                         , at.cat_level                                              as cat_level
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => at.cat_level
                             , i_lang    => i_lang
                           )                                                         as cat_level_name
                         , case
                               when at.gmt_offset = 0
                                   then '0'
                               else to_char(at.gmt_offset, 'S99')
                           end                                                       as terminal_gmt_offset
                         , at.is_mac                                                 as use_message_auth_code
                         , at.device_id                                              as device_id
                         , at.status                                                 as terminal_status
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => at.status
                             , i_lang    => i_lang
                           )                                                         as terminal_status_name
                         , at.cash_dispenser_present                                 as cash_dispenser_present
                         , at.payment_possibility                                    as payment_possibility
                         , at.use_card_possibility                                   as use_card_possibility
                         , at.cash_in_present                                        as cash_in_present
                         , at.terminal_profile                                       as terminal_profile_id
                      from acq_terminal at
                         , acq_merchant am
                     where at.id = i_terminal_id
                       and at.merchant_id = am.id (+)
                ) smd
                left outer join
                (
                    select xmlelement(
                               "errors"
                             , xmlelement(
                                   "error"
                                 , xmlelement("error_code", com_api_error_pkg.get_last_error)
                                 , xmlelement(
                                       "error_element"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                           else null
                                       end
                                   )
                                 , xmlelement("error_desc", com_api_error_pkg.get_last_message)
                                 , xmlelement(
                                       "error_details"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   'ERROR_ID[' || com_api_error_pkg.get_last_error_id || ']'
                                           else null
                                       end
                                   )
                               )
                           ) as err_data
                      from dual
                ) sed on (1 = 1);
            
    exception
        when no_data_found then
            
            com_api_error_pkg.raise_error(
                i_error         => 'REPORT_DATA_NOT_FOUND'
            );

    end;
     
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_terminal_data(' || i_terminal_id || '): FINISH SUCCESS');
        
end generate_terminal_data;

/**********************************************************
 *
 * Generate output data in xml-format of the operation  
 * (card-account) entity for the reports construction
 *
 *********************************************************/
/* Obsolete. Do not use */
procedure generate_oper_acc_iss_data(
    i_operation_id           in            com_api_type_pkg.t_long_id
  , i_lang                   in            com_api_type_pkg.t_dict_value default null
  , o_operation_acc_iss_data out           xmltype
) is

begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_oper_acc_iss_data(' || i_operation_id || '): START');
    
    begin
        select
                xmlelement("operation_acc_iss"
                    , xmlelement("oper_type"
                        , xmlelement("code", smd.oper_type)
                        , xmlelement("name", smd.oper_type_name)
                      )
                    , xmlelement("msg_type"
                        , xmlelement("code", smd.msg_type)
                        , xmlelement("name", smd.msg_type_name)
                      )
                    , xmlelement("oper_date", smd.oper_date_xml_fm)
                    , xmlelement("oper_amount"
                        , xmlelement("amount_value", smd.oper_amount_xml_fm)
                        , xmlelement("currency", smd.oper_currency)
                        , xmlelement("currency_name",smd.oper_currency_name)
                      )
                    , xmlelement("short_card_mask", smd.short_card_mask)
                    , xmlelement("card_mask", smd.card_mask)
                    , xmlelement("account_mask", smd.account_mask)
                    , xmlelement("balance"
                        , xmlelement("amount_value", smd.account_balance_value)
                        , xmlelement("currency", smd.account_currency)
                        , xmlelement("currency_name", smd.account_currency_name)
                      )
                    , xmlelement("merchant"
                        , xmlelement("merchant_name", smd.merchant_name)
                        , xmlelement("merchant_postcode", smd.merchant_postcode)
                        , xmlelement("merchant_street", smd.merchant_street)
                        , xmlelement("merchant_city", smd.merchant_city)
                        , xmlelement("merchant_region", smd.merchant_region)
                        , xmlelement("merchant_country", smd.merchant_country)
                      )
                    , xmlelement("note_text", smd.note_text)
                    , sed.err_data
                )
          into
                o_operation_acc_iss_data
          from
                (
                    select
                            o.oper_type                                              as oper_type
                          , upper(
                                get_article_text(
                                    i_article => o.oper_type
                                  , i_lang => i_lang
                                )
                            )                                                        as oper_type_name
                          , o.msg_type                                               as msg_type
                          , get_article_text(
                                i_article => o.msg_type
                              , i_lang    => i_lang
                            )                                                        as msg_type_name
                          , to_char(
                                o.oper_date
                              , com_api_const_pkg.XML_DATETIME_FORMAT
                            )                                                        as oper_date_xml_fm
                          , to_char(
                                o.oper_amount / power(10, oc.exponent)
                              , com_api_const_pkg.XML_NUMBER_FORMAT
                                || rpad('.'
                                     , case oc.exponent 
                                            when 0
                                                then 0 
                                            else oc.exponent + 1
                                       end
                                     , '0'
                                   )
                            )                                                        as oper_amount_xml_fm
                          , o.oper_currency                                          as oper_currency
                          , oc.name                                                  as oper_currency_name
                          
                          , iss_api_card_pkg.get_short_card_mask(
                                i_card_number => c.card_number
                            )                                                        as short_card_mask
                          , iss_api_card_pkg.get_card_mask(
                                i_card_number => c.card_number
                            )                                                        as card_mask
                          , '*' || substr(p.account_number, -5, 5)                   as account_mask
                          , to_char(
                                av.balance / power(10, ac.exponent)
                              , com_api_const_pkg.XML_NUMBER_FORMAT
                                || rpad('.'
                                       , case ac.exponent 
                                              when 0 
                                                  then 0
                                              else ac.exponent + 1
                                         end
                                       , '0'
                                   )
                            )                                                        as account_balance_value
                          , ac.code                                                  as account_currency
                          , ac.name                                                  as account_currency_name
                          , rtrim(o.merchant_name)                                   as merchant_name
                          , rtrim(o.merchant_postcode)                               as merchant_postcode
                          , rtrim(o.merchant_street)                                 as merchant_street
                          , rtrim(o.merchant_city)                                   as merchant_city
                          , nvl(trim(o.merchant_region), mc.name)                    as merchant_region
                          , rtrim(o.merchant_country)                                as merchant_country
                          , com_api_i18n_pkg.get_text(
                                i_table_name  => 'NTB_NOTE'
                              , i_column_name => 'TEXT'
                              , i_object_id   => n.id
                              , i_lang        => i_lang
                            )                                                        as note_text
                      from
                            opr_operation o
                          , opr_participant p
                          , opr_card c
                          , acc_ui_account_vs_aval_vw av
                          , com_currency ac
                          , com_currency oc
                          , com_country mc
                          , ntb_note n
                     where
                            o.id = i_operation_id
                        and p.oper_id = o.id
                        and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                        and c.oper_id(+) = o.id
                        and c.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
                        and av.id(+) = p.account_id
                        and ac.code(+) = av.currency
                        and oc.code(+) = o.oper_currency
                        and mc.code(+) = o.merchant_country
                        and n.object_id(+) = o.id
                        and n.entity_type(+) = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                ) smd
                left outer join
                (
                    select xmlelement(
                               "errors"
                             , xmlelement(
                                   "error"
                                 , xmlelement("error_code", com_api_error_pkg.get_last_error)
                                 , xmlelement(
                                       "error_element"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                           else null
                                       end
                                   )
                                 , xmlelement("error_desc", com_api_error_pkg.get_last_message)
                                 , xmlelement(
                                       "error_details"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   'ERROR_ID[' || com_api_error_pkg.get_last_error_id || ']'
                                           else null
                                       end
                                   )
                               )
                           ) as err_data
                      from dual
                ) sed on (1 = 1);
            
    exception
        when no_data_found then
            
            com_api_error_pkg.raise_error(
                i_error         => 'REPORT_DATA_NOT_FOUND'
            );

    end;
     
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_oper_acc_iss_data(' || i_operation_id || '): FINISH SUCCESS');
        
end generate_oper_acc_iss_data;

/* Obsolete. Do not use */
procedure generate_bonus_data(
    i_macros_id    in    com_api_type_pkg.t_short_id
  , i_lang         in    com_api_type_pkg.t_dict_value default null
  , o_report_xml   out   xmltype
) is
    l_tmp number;
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_bonus_data(' || i_macros_id || '): started');
    
    select xmlforest(
               o.id as oper_id
             , a.account_number
             , a.currency as account_currency
             , com_api_currency_pkg.get_currency_full_name(
                   i_curr_code => a.currency
                 , i_lang      => i_lang
               ) as account_currency_name
             , acc_api_balance_pkg.get_aval_balance_amount_only(
                   i_account_id => m.account_id
                 , i_date       => m.posting_date
                 , i_date_type  => com_api_const_pkg.DATE_PURPOSE_PROCESSING
                 , i_mask_error => com_api_type_pkg.TRUE
               ) as balance
             , m.amount
             , au.external_auth_id
             , o.oper_amount
             , o.oper_currency
             , o.oper_request_amount
             , o.oper_type
             , to_char(o.oper_date, 'dd.mm.yy') as "DATE"
             , to_char(o.oper_date, 'hh:mi') as "TIME"
             , ich.cardholder_name
             , ci.cardholder_name  as embossed_cardholder_name
             , oi.auth_code
             , oi.card_mask
             , substr(oi.card_mask, -4) as card_mask2
             , to_char(oi.card_expir_date, 'YYYYMM') as card_expir_date
             , oa.merchant_id
             , oa.terminal_id
             , o.terminal_number
             , o.merchant_name
             , o.merchant_city
             , o.merchant_country
             , o.merchant_street
             , o.is_reversal
           )
      into o_report_xml
      from acc_macros m
         , acc_account a
         , opr_operation o
         , opr_participant oi
         , opr_participant oa
         , aut_auth au
         , iss_card ic
         , iss_cardholder ich
         , iss_card_instance ci
     where m.id                   = i_macros_id
       and m.account_id           = a.id
       and m.object_id            = o.id
       and m.entity_type          = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and o.id                   = au.id(+)
       and o.id                   = oi.oper_id(+)
       and oi.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
       and o.id                   = oa.oper_id(+)
       and oa.participant_type(+) = com_api_const_pkg.PARTICIPANT_ACQUIRER
       and oi.card_id             = ic.id(+)
       and ic.cardholder_id       = ich.id(+)
       and oi.card_instance_id    = ci.card_id(+);
       
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_bonus_data(' || i_macros_id || '): finished');
exception when no_data_found then
    com_api_error_pkg.raise_error(
        i_error         => 'REPORT_DATA_NOT_FOUND'
    );
end;

/* Obsolete. Do not use */
procedure generate_service_terms_data(
    i_entity_type     in    com_api_type_pkg.t_dict_value
  , i_object_id       in    com_api_type_pkg.t_long_id
  , o_serv_terms_xml  out   xmltype
) is

begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_service_terms_data(entity type [' || i_entity_type  || '], object_id [' || i_object_id || ']): START');
    
    begin
        
        select xmlElement("service_terms",
                   xmlAgg(xmlElement("service_term"
                            , xmlAttributes(s.attr_name as "name", s.attr_entity as "entity")
                            , case s.attr_entity
                                  when fcl_api_const_pkg.ENTITY_TYPE_FEE
                                      then fcl_ui_fee_pkg.get_fee_desc(
                                               i_fee_id => s.attr_value
                                           )
                                  when fcl_api_const_pkg.ENTITY_TYPE_CYCLE
                                      then fcl_ui_cycle_pkg.get_cycle_desc(
                                               i_cycle_id => s.attr_value
                                           )
                                  when fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                      then fcl_ui_limit_pkg.get_limit_desc(
                                               i_limit_id => s.attr_value
                                           )
                                  else to_char(s.attr_value)
                              end
                           ) order by s.attr_name
                   )
               )
          into o_serv_terms_xml
          from (
                select pa.attr_name
                     , pa.entity_type as attr_entity
                     , prd_api_product_pkg.get_attr_value_number(
                           i_entity_type       => so.entity_type
                         , i_object_id         => so.object_id
                         , i_attr_name         => pa.attr_name
                         , i_mask_error        => 1
                       ) as attr_value
                       
                  from prd_service_object so
                     , prd_service s
                     , prd_attribute pa
                 where so.entity_type = i_entity_type
                   and so.object_id   = i_object_id
                   and s.id           = so.service_id
                   and pa.service_type_id = s.service_type_id
               ) s
        ;
            
    exception
        when no_data_found then
            
            com_api_error_pkg.raise_error(
                i_error         => 'REPORT_DATA_NOT_FOUND'
            );

    end;
     
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_service_terms_data(entity type [' || i_entity_type  || '], object_id [' || i_object_id || ']): FINISH SUCCESS');
        
end generate_service_terms_data;

/* Obsolete. Do not use */
procedure generate_account_merchant_data(
    i_account_id              in    com_api_type_pkg.t_medium_id
  , i_lang                    in    com_api_type_pkg.t_dict_value default null
  , o_account_merchants_xml   out   xmltype
) is

    l_xml_buffer      xmltype;
    
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_account_merchant_data(account ID [' || i_account_id || ']): START');
    
    begin
        
        for r in (select a.id, level
                    from acq_merchant a
                   where a.id in (select ao.object_id
                                    from acc_account_object ao
                                   where ao.account_id  = i_account_id
                                     and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                 )
                  connect
                      by prior id = parent_id
                   start with
                         a.parent_id is null
                   order by
                         level
                 )
        loop
            generate_merchant_data(
                i_merchant_id          => r.id
              , i_lang                 => i_lang
              , o_merchant_report_data => l_xml_buffer
            );
            
            select xmlconcat(
                       o_account_merchants_xml
                     , xmlelement(
                           "merchant"
                         , xmlconcat(
                               extract(l_xml_buffer, '/merchant/merchant_id')
                             , extract(l_xml_buffer, '/merchant/merchant_number')
                             , extract(l_xml_buffer, '/merchant/merchant_name')
                             , extract(l_xml_buffer, '/merchant/merchant_label')
                           )
                       )
                   )
              into o_account_merchants_xml
              from dual;
            
        end loop;
        
        if o_account_merchants_xml is null then
            
            raise no_data_found;
            
        end if;
        
        select xmlelement("merchants", o_account_merchants_xml)
          into o_account_merchants_xml
          from dual;
        
    exception
        when no_data_found then
            
            com_api_error_pkg.raise_error(
                i_error         => 'REPORT_DATA_NOT_FOUND'
            );

    end;
     
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_account_merchant_data(account ID [' || i_account_id || ']): FINISH SUCCESS');
        
end generate_account_merchant_data;

/* Obsolete. Do not use */
procedure generate_account_complex_data(
    i_account_id              in    com_api_type_pkg.t_medium_id
  , i_lang                    in    com_api_type_pkg.t_dict_value default null
  , o_account_complex_xml   out   xmltype
) is

    l_xml_buffer      xmltype;
    
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_account_complex_data(account ID [' || i_account_id || ']): START');
    
    generate_account_data(
        i_account_id          => i_account_id
      , i_lang                => i_lang
      , o_account_report_data => l_xml_buffer
    );
    
    select extract(l_xml_buffer, '/account/*')
      into o_account_complex_xml
      from dual
    ;
    
    begin
        
        generate_service_terms_data(
            i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id       => i_account_id
          , o_serv_terms_xml  => l_xml_buffer
        );
        
        select xmlconcat(o_account_complex_xml, l_xml_buffer)
          into o_account_complex_xml
          from dual
        ;

        
    exception
        when others then
            if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then

                null;
                
            elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
                
                raise;

            else
                
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );
                
            end if;

    end;
    
    begin
        
        generate_account_merchant_data(
            i_account_id             => i_account_id
          , i_lang                   => i_lang
          , o_account_merchants_xml  => l_xml_buffer
        );
        
        select xmlconcat(o_account_complex_xml, l_xml_buffer)
          into o_account_complex_xml
          from dual
        ;

        
    exception
        when others then
            if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then

                null;
                
            elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
                
                raise;

            else
                
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );
                
            end if;

    end;
    
    select xmlelement("account", o_account_complex_xml)
      into o_account_complex_xml
      from dual;
     
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_account_complex_data(account ID [' || i_account_id || ']): FINISH SUCCESS');
        
end generate_account_complex_data;

/* Obsolete. Do not use */
procedure generate_contact_data(
    i_contact_data_id         in    com_api_type_pkg.t_medium_id
  , i_lang                    in    com_api_type_pkg.t_dict_value default null
  , o_contact_data_xml        out   xmltype
) is
    l_eff_date                 date := get_sysdate;
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_contact_data(' || i_contact_data_id || '): START');
    
    begin
    
        select  xmlelement("contact_data"
                  , xmlattributes(smd.contact_data_id as "id", smd.contact_id as "contact_id", smd.contact_type as "contact_type", smd.communication_method as "communication_method")
                  , xmlelement("contact_entity",               smd.contact_entity)
                  , xmlelement("contact_entity_name",          smd.contact_entity_name)
                  , xmlelement("contact_object_id",            smd.contact_object_id)
                  , xmlelement("contact_type_name",            smd.contact_type_name)
                  , xmlelement("communication_method_name",    smd.communication_method_name)
                  , xmlelement("communication_address",        smd.communication_address)
                  , xmlelement("customer"
                      , xmlelement("institution_id",           smd.institution_id)
                      , xmlelement("institution_name",         smd.institution_name)
                      , (select xmlelement(
                                    "institution_contacts"
                                  , xmlagg(
                                        xmlelement(
                                            "contact"
                                          , xmlattributes(co.contact_type as "contact_type", cd.commun_method as "communication_method")
                                          , xmlelement(
                                                "communication_address"
                                              , com_api_contact_pkg.get_contact_string(
                                                    i_contact_id    => co.contact_id
                                                  , i_commun_method => cd.commun_method
                                                  , i_start_date    => l_eff_date
                                                )
                                            )
                                        ) order by co.contact_type, cd.commun_method, co.id desc
                                    )
                                )
                           from com_contact_object co
                              , com_contact_data cd
                          where co.object_id = smd.institution_id
                            and co.entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                            and co.contact_id  = cd.contact_id
                        )
                      , xmlelement("agent_id",                 smd.agent_id)
                      , xmlelement("agent_name",               smd.agent_name)
                      , (select xmlelement(
                                    "agent_contacts"
                                  , xmlagg(
                                        xmlelement(
                                            "contact"
                                          , xmlattributes(co.contact_type as "contact_type", cd.commun_method as "communication_method")
                                          , xmlelement(
                                                "communication_address"
                                              , com_api_contact_pkg.get_contact_string(
                                                    i_contact_id    => co.contact_id
                                                  , i_commun_method => cd.commun_method
                                                  , i_start_date    => l_eff_date
                                                )
                                            )
                                        ) order by co.contact_type, cd.commun_method, co.id desc
                                    )
                                )
                           from com_contact_object co
                              , com_contact_data cd
                          where co.object_id = smd.agent_id
                            and co.entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT
                            and co.contact_id  = cd.contact_id
                        )
                    )
                  , sed.err_data
                ) as result
          into  o_contact_data_xml
          from
                (
                    select cd.id                                                     as contact_data_id
                         , cd.contact_id                                             as contact_id
                         , co.entity_type                                            as contact_entity
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => co.entity_type
                             , i_lang    => i_lang
                           )                                                         as contact_entity_name
                         , co.object_id                                              as contact_object_id
                         , co.contact_type                                           as contact_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => co.contact_type
                             , i_lang    => i_lang
                           )                                                         as contact_type_name
                         , cd.commun_method                                          as communication_method
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => cd.commun_method
                             , i_lang    => i_lang
                           )                                                         as communication_method_name
                         , cd.commun_address                                         as communication_address
                         , cc.inst_id                                                as institution_id
                         , ost_ui_institution_pkg.get_inst_name(
                               i_inst_id => cc.inst_id
                             , i_lang    => i_lang
                           )                                                         as institution_name
                         , cc.agent_id                                               as agent_id
                         , ost_ui_agent_pkg.get_agent_name(
                               i_agent_id => cc.agent_id
                             , i_lang     => i_lang
                           )                                                         as agent_name
                      from com_contact_data cd
                         , com_contact_object co
                         , (select cd.id, c.inst_id, c.agent_id
                              from com_contact_data cd
                                 , com_contact_object co
                                 , iss_cardholder ich
                                 , iss_card ic
                                 , prd_contract c
                             where cd.id = i_contact_data_id
                               and co.contact_id = cd.contact_id
                               and co.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                               and co.object_id   = ich.id
                               and ic.cardholder_id = ich.id
                               and c.id             = ic.contract_id
                               and rownum < 2
                             union
                            select cd.id, c.inst_id, c.agent_id
                              from com_contact_data cd
                                 , com_contact_object co
                                 , prd_customer u
                                 , prd_contract c
                             where cd.id = i_contact_data_id
                               and co.contact_id  = cd.contact_id
                               and co.entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                               and co.object_id   = u.id
                               and c.id           = u.contract_id
                             union
                            select cd.id, c.inst_id, c.agent_id
                              from com_contact_data cd
                                 , com_contact_object co
                                 , acq_merchant m
                                 , prd_contract c
                             where cd.id = i_contact_data_id
                               and co.contact_id  = cd.contact_id
                               and co.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                               and co.object_id   = m.id
                               and c.id           = m.contract_id
                             union
                            select cd.id, c.inst_id, c.agent_id
                              from com_contact_data cd
                                 , com_contact_object co
                                 , acq_terminal t
                                 , prd_contract c
                             where cd.id = i_contact_data_id
                               and co.contact_id  = cd.contact_id
                               and co.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                               and co.object_id   = t.id
                               and c.id           = t.contract_id
                           ) cc
                     where cd.id = i_contact_data_id
                       and cd.contact_id = co.contact_id
                       and cd.id = cc.id(+)
                ) smd
                left outer join
                (
                    select xmlelement(
                               "errors"
                             , xmlelement(
                                   "error"
                                 , xmlelement("error_code", com_api_error_pkg.get_last_error)
                                 , xmlelement(
                                       "error_element"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   com_api_const_pkg.ENTITY_TYPE_CONTACT_DATA
                                           else null
                                       end
                                   )
                                 , xmlelement("error_desc", com_api_error_pkg.get_last_message)
                                 , xmlelement(
                                       "error_details"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   'ERROR_ID['||com_api_error_pkg.get_last_error_id||']'
                                           else null
                                       end
                                   )
                               )
                           ) as err_data
                      from dual
                ) sed on (1 = 1);
                
    exception
        when no_data_found then
            
            com_api_error_pkg.raise_error(
                i_error         => 'REPORT_DATA_NOT_FOUND'
            );
            
    end;
    
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_contact_data(' || i_contact_data_id || '): FINISH SUCCESS');
        
end generate_contact_data;

/* Obsolete. Do not use */
procedure generate_identifier_data(
    i_identifier_object_id    in    com_api_type_pkg.t_medium_id
  , i_lang                    in    com_api_type_pkg.t_dict_value default null
  , o_identifier_data_xml     out   xmltype
) is
    l_eff_date                 date := get_sysdate;
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_identifier_data(' || i_identifier_object_id || '): START');
    
    begin
    
        select  xmlelement("identifier_object_data"
                  , xmlattributes(smd.identifier_object_id as "id", smd.identifier_type as "identifier_type")
                  , xmlelement("owner_entity",             smd.owner_entity)
                  , xmlelement("owner_entity_name",        smd.owner_entity_name)
                  , xmlelement("owner_object_id",          smd.owner_object_id)
                  , xmlelement("identifier_type_name",     smd.identifier_type_name)
                  , xmlelement("identifier_series",        smd.identifier_series)
                  , xmlelement("identifier_number",        smd.identifier_number)
                  , xmlelement("identifier_issuer",        smd.identifier_issuer)
                  , xmlelement("identifier_issue_date",    to_char(smd.identifier_issue_date, 'dd/mm/yyyy'))
                  , xmlelement("identifier_expire_date",   to_char(smd.identifier_expire_date, 'dd/mm/yyyy'))
                  , xmlelement("customer"
                      , xmlelement("institution_id",           smd.institution_id)
                      , xmlelement("institution_name",         smd.institution_name)
                      , (select xmlelement(
                                    "institution_contacts"
                                  , xmlagg(
                                        xmlelement(
                                            "contact"
                                          , xmlattributes(co.contact_type as "contact_type", cd.commun_method as "communication_method")
                                          , xmlelement(
                                                "communication_address"
                                              , com_api_contact_pkg.get_contact_string(
                                                    i_contact_id    => co.contact_id
                                                  , i_commun_method => cd.commun_method
                                                  , i_start_date    => l_eff_date
                                                )
                                            )
                                        ) order by co.contact_type, cd.commun_method, co.id desc
                                    )
                                )
                           from com_contact_object co
                              , com_contact_data cd
                          where co.object_id = smd.institution_id
                            and co.entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                            and co.contact_id  = cd.contact_id
                        )
                      , xmlelement("agent_id",                 smd.agent_id)
                      , xmlelement("agent_name",               smd.agent_name)
                      , (select xmlelement(
                                    "agent_contacts"
                                  , xmlagg(
                                        xmlelement(
                                            "contact"
                                          , xmlattributes(co.contact_type as "contact_type", cd.commun_method as "communication_method")
                                          , xmlelement(
                                                "communication_address"
                                              , com_api_contact_pkg.get_contact_string(
                                                    i_contact_id    => co.contact_id
                                                  , i_commun_method => cd.commun_method
                                                  , i_start_date    => l_eff_date
                                                )
                                            )
                                        ) order by co.contact_type, cd.commun_method, co.id desc
                                    )
                                )
                           from com_contact_object co
                              , com_contact_data cd
                          where co.object_id = smd.agent_id
                            and co.entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT
                            and co.contact_id  = cd.contact_id
                        )
                    )
                  , sed.err_data
                ) as result
          into  o_identifier_data_xml
          from
                (
                    select io.id                                                     as identifier_object_id
                         , io.entity_type                                            as owner_entity
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => io.entity_type
                             , i_lang    => i_lang
                           )                                                         as owner_entity_name
                         , io.object_id                                              as owner_object_id
                         , io.id_type                                                as identifier_type
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => io.id_type
                             , i_lang    => i_lang
                           )                                                         as identifier_type_name
                         , io.id_series                                              as identifier_series
                         , io.id_number                                              as identifier_number
                         , io.id_issuer                                              as identifier_issuer
                         , io.id_issue_date                                          as identifier_issue_date
                         , io.id_expire_date                                         as identifier_expire_date
                         , cn.inst_id                                                as institution_id
                         , ost_ui_institution_pkg.get_inst_name(
                               i_inst_id => cn.inst_id
                             , i_lang    => i_lang
                           )                                                         as institution_name
                         , cn.agent_id                                               as agent_id
                         , ost_ui_agent_pkg.get_agent_name(
                               i_agent_id => cn.agent_id
                             , i_lang     => i_lang
                           )                                                         as agent_name
                      from com_id_object io
                         , prd_customer cu
                         , prd_contract cn
                     where io.id = i_identifier_object_id
                       and io.entity_type = cu.entity_type(+)
                       and io.object_id   = cu.object_id(+)
                       and cu.contract_id = cn.id(+)
                       and rownum < 2
                ) smd
                left outer join
                (
                    select xmlelement(
                               "errors"
                             , xmlelement(
                                   "error"
                                 , xmlelement("error_code", com_api_error_pkg.get_last_error)
                                 , xmlelement(
                                       "error_element"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   com_api_const_pkg.ENTITY_TYPE_IDENTIFY_OBJECT
                                           else null
                                       end
                                   )
                                 , xmlelement("error_desc", com_api_error_pkg.get_last_message)
                                 , xmlelement(
                                       "error_details"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   'ERROR_ID['||com_api_error_pkg.get_last_error_id||']'
                                           else null
                                       end
                                   )
                               )
                           ) as err_data
                      from dual
                ) sed on (1 = 1);
                
    exception
        when no_data_found then
            
            com_api_error_pkg.raise_error(
                i_error         => 'REPORT_DATA_NOT_FOUND'
            );
            
    end;
    
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_identifier_data(' || i_identifier_object_id || '): FINISH SUCCESS');
        
end generate_identifier_data;

/* Obsolete. Do not use */
procedure generate_address_data(
    i_address_id              in    com_api_type_pkg.t_medium_id
  , i_lang                    in    com_api_type_pkg.t_dict_value default null
  , o_address_data_xml        out   xmltype
) is
    l_eff_date                 date := get_sysdate;
    l_customer_id              com_api_type_pkg.t_medium_id;
    l_src_entity_type          com_api_type_pkg.t_dict_value;
    l_src_object_id            com_api_type_pkg.t_long_id;
    l_lang                     com_api_type_pkg.t_dict_value := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang);
    
    l_address_object_data      xmltype;
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_address_data(' || i_address_id || ', ' || l_lang || '): START');
    
    l_src_entity_type := evt_api_shared_data_pkg.get_param_char(
                             i_name       => 'SRC_ENTITY_TYPE'
                           , i_mask_error => com_api_const_pkg.TRUE
                         );
    l_src_object_id   := evt_api_shared_data_pkg.get_param_num(
                             i_name       => 'SRC_OBJECT_ID'
                           , i_mask_error => com_api_const_pkg.TRUE
                         );
    if l_src_entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
        and l_src_object_id is not null
    then
        l_customer_id := l_src_object_id;
    else
        begin
            select customer_id
              into l_customer_id
              from (select c.id as customer_id
                      from com_address_object o
                         , prd_customer c
                     where o.entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                       and o.address_id  = i_address_id
                       and c.id          = o.object_id
                     union
                    select c.id as customer_id
                      from com_address_object o
                         , iss_cardholder h
                         , prd_customer c
                     where o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                       and o.object_id   = h.id
                       and h.person_id   = c.id
                       and c.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                       and o.address_id  = i_address_id
                     union
                    select n.customer_id
                      from com_address_object o
                         , acq_merchant m
                         , prd_contract n
                     where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       and o.address_id  = i_address_id
                       and m.id          = o.object_id
                       and n.id          = m.contract_id
                     union
                    select n.customer_id
                      from com_address_object o
                         , acq_terminal t
                         , prd_contract n
                     where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                       and o.address_id  = i_address_id
                       and t.id          = o.object_id
                       and t.is_template = com_api_type_pkg.FALSE      
                       and n.id          = t.contract_id
              )
             where rownum < 2;
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text       => lower($$PLSQL_UNIT) || '.generate_address_data: customer at the given address [#1] not found'
                  , i_env_param1 => i_address_id
                );
        end;
    end if;
    begin
        select xmlagg(
                   xmlelement(
                       "address_object"
                     , xmlattributes(customer_id as "customer_id", address_type as "address_type")
                     , xmlelement(
                           "object_entity"
                         , entity_type
                       )
                     , xmlelement(
                           "object_entity_name"
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => entity_type
                             , i_lang    => l_lang
                           )
                       )
                     , xmlelement(
                           "object_id"
                         , object_id
                       )
                     , xmlelement(
                           "address_type_name"
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => address_type
                             , i_lang    => l_lang
                           )
                       )
                   ) order by customer_id nulls last, entity_type, object_id, address_type
               )
          into l_address_object_data
          from (select c.id as customer_id
                     , o.entity_type
                     , o.object_id
                     , o.address_type
                  from com_address_object o
                     , prd_customer c
                 where o.entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                   and o.address_id  = i_address_id
                   and c.id          = o.object_id
                 union all
                select c.id as customer_id
                     , o.entity_type
                     , o.object_id
                     , o.address_type
                  from com_address_object o
                     , iss_cardholder h
                     , prd_customer c
                 where o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                   and o.object_id   = h.id
                   and h.person_id   = c.id
                   and c.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                   and o.address_id  = i_address_id
                 union all
                select n.customer_id
                     , o.entity_type
                     , o.object_id
                     , o.address_type
                  from com_address_object o
                     , acq_merchant m
                     , prd_contract n
                 where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and o.address_id  = i_address_id
                   and m.id          = o.object_id
                   and n.id          = m.contract_id
                 union all
                select n.customer_id
                     , o.entity_type
                     , o.object_id
                     , o.address_type
                  from com_address_object o
                     , acq_terminal t
                     , prd_contract n
                 where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                   and o.address_id  = i_address_id
                   and t.id          = o.object_id
                   and t.is_template = com_api_type_pkg.FALSE      
                   and n.id          = t.contract_id
          );
    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text       => lower($$PLSQL_UNIT) || '.generate_address_data: address objects at the given address [#1] not found'
              , i_env_param1 => i_address_id
            );
    end;
    begin
    
        select  xmlelement("address_data"
                  , xmlattributes(smd.address_id as "id", smd.lang_code as "lang")
                  , xmlelement("country_code",                 smd.country_code)
                  , xmlelement("country_code_name",            smd.country_code_name)
                  , xmlelement("country_name",                 smd.country_name)
                  , xmlelement("region",                       smd.region)
                  , xmlelement("city",                         smd.city)
                  , xmlelement("street",                       smd.street)
                  , xmlelement("house",                        smd.house)
                  , xmlelement("apartment",                    smd.apartment)
                  , xmlelement("postal_code",                  smd.postal_code)
                  , xmlelement("region_code",                  smd.region_code)
                  , xmlelement("latitude",                     to_char(smd.latitude, com_api_const_pkg.xml_location_format))
                  , xmlelement("longitude",                    to_char(smd.longitude, com_api_const_pkg.xml_location_format))
                  , xmlelement("place_code",                   smd.place_code)
                  , xmlelement("address_comments",             smd.address_comments)
                  , xmlelement("address_string",               smd.address_string)
                  , xmlelement("address_objects",              l_address_object_data)
                  , xmlelement("customer"
                      , xmlattributes(smd.src_customer_id as "id")
                      , xmlelement("institution_id",           smd.institution_id)
                      , xmlelement("institution_name",         smd.institution_name)
                      , (select xmlelement(
                                    "institution_contacts"
                                  , xmlagg(
                                        xmlelement(
                                            "contact"
                                          , xmlattributes(co.contact_type as "contact_type", cd.commun_method as "communication_method")
                                          , xmlelement(
                                                "communication_address"
                                              , com_api_contact_pkg.get_contact_string(
                                                    i_contact_id    => co.contact_id
                                                  , i_commun_method => cd.commun_method
                                                  , i_start_date    => l_eff_date
                                                )
                                            )
                                        ) order by co.contact_type, cd.commun_method, co.id desc
                                    )
                                )
                           from com_contact_object co
                              , com_contact_data cd
                          where co.object_id = smd.institution_id
                            and co.entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                            and co.contact_id  = cd.contact_id
                        )
                      , xmlelement("agent_id",                 smd.agent_id)
                      , xmlelement("agent_name",               smd.agent_name)
                      , (select xmlelement(
                                    "agent_contacts"
                                  , xmlagg(
                                        xmlelement(
                                            "contact"
                                          , xmlattributes(co.contact_type as "contact_type", cd.commun_method as "communication_method")
                                          , xmlelement(
                                                "communication_address"
                                              , com_api_contact_pkg.get_contact_string(
                                                    i_contact_id    => co.contact_id
                                                  , i_commun_method => cd.commun_method
                                                  , i_start_date    => l_eff_date
                                                )
                                            )
                                        ) order by co.contact_type, cd.commun_method, co.id desc
                                    )
                                )
                           from com_contact_object co
                              , com_contact_data cd
                          where co.object_id = smd.agent_id
                            and co.entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT
                            and co.contact_id  = cd.contact_id
                        )
                    )
                  , sed.err_data
                ) as result
          into  o_address_data_xml
          from
                (
                    select ca.id                                                     as address_id
                         , ca.lang                                                   as lang_code
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => ca.lang
                             , i_lang    => l_lang
                           )                                                         as lang_name
                         , ca.country                                                as country_code
                         , com_api_country_pkg.get_country_name(
                               i_code        => ca.country
                             , i_raise_error => com_api_const_pkg.FALSE
                           )                                                         as country_code_name
                         , com_api_country_pkg.get_country_full_name(
                               i_code        => ca.country
                             , i_lang        => l_lang
                             , i_raise_error => com_api_const_pkg.FALSE
                           )                                                         as country_name
                         , ca.region
                         , ca.city
                         , ca.street
                         , ca.house
                         , ca.apartment
                         , ca.postal_code
                         , ca.region_code
                         , ca.latitude
                         , ca.longitude
                         , ca.place_code
                         , ca.comments                                               as address_comments
                         , com_api_address_pkg.get_address_string(
                               i_address_id   => ca.id
                             , i_lang         => l_lang
                             , i_inst_id      => null
                             , i_enable_empty => com_api_const_pkg.TRUE
                           )                                                         as address_string
                         , cn.inst_id                                                as institution_id
                         , ost_ui_institution_pkg.get_inst_name(
                               i_inst_id => cn.inst_id
                             , i_lang    => i_lang
                           )                                                         as institution_name
                         , cn.agent_id                                               as agent_id
                         , ost_ui_agent_pkg.get_agent_name(
                               i_agent_id => cn.agent_id
                             , i_lang     => i_lang
                           )                                                         as agent_name
                         , cu.id                                                     as src_customer_id
                      from com_address ca
                         , prd_customer cu
                         , prd_contract cn
                     where ca.id          = i_address_id
                       and ca.lang        = l_lang
                       and l_customer_id  = cu.id(+)
                       and cu.contract_id = cn.id(+)
                ) smd
                left outer join
                (
                    select xmlelement(
                               "errors"
                             , xmlelement(
                                   "error"
                                 , xmlelement("error_code", com_api_error_pkg.get_last_error)
                                 , xmlelement(
                                       "error_element"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   com_api_const_pkg.ENTITY_TYPE_ADDRESS
                                           else null
                                       end
                                   )
                                 , xmlelement("error_desc", com_api_error_pkg.get_last_message)
                                 , xmlelement(
                                       "error_details"
                                     , case
                                           when com_api_error_pkg.get_last_error_id is not null 
                                               then
                                                   'ERROR_ID['||com_api_error_pkg.get_last_error_id||']'
                                           else null
                                       end
                                   )
                               )
                           ) as err_data
                      from dual
                ) sed on (1 = 1);
                
    exception
        when no_data_found then
            
            com_api_error_pkg.raise_error(
                i_error         => 'REPORT_DATA_NOT_FOUND'
            );
            
    end;
    
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.generate_address_data(' || i_address_id  || ', ' || l_lang || '): FINISH SUCCESS');
        
end generate_address_data;

end evt_api_notif_report_data_pkg;
/
