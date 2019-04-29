create or replace package body rus_api_order_report_pkg is
/*********************************************************
 *  Acquiring application API  <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 02.02.2012 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: RUS_API_ORDER_REPORT_PKG  <br />
 *  @headcom
 **********************************************************/

procedure payment_order (
    o_xml          out clob
  , i_lang      in     com_api_type_pkg.t_dict_value
  , i_object_id in     com_api_type_pkg.t_long_id
) is
    l_result            xmltype;
    l_macros_id         com_api_type_pkg.t_long_id;
    l_oper_id           com_api_type_pkg.t_long_id;
    l_account_id        com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text        => 'rus_api_order_report_pkg.payment_order: object_id[#1] i_lang[#2]'
      , i_env_param1  => to_char(i_object_id, 'TM9')
      , i_env_param2  => i_lang
    );

    select min(macros_id) into l_macros_id from acc_entry where transaction_id = i_object_id;
    select min(object_id) into l_oper_id from acc_macros where id = l_macros_id;
    select min(account_id) into l_account_id from opr_participant
    where oper_id = l_oper_id and participant_type = com_api_const_pkg.PARTICIPANT_ISSUER;

    trc_log_pkg.debug ('macros_id='||to_char(l_macros_id, 'TM9')
                     ||', oper_id='||to_char(l_oper_id, 'TM9')
                     ||', account_id='||to_char(l_account_id, 'TM9')
    );

    select
        XMLElement("report",
            XMLElement("receive_date", to_char(receive_date, 'dd.mm.yyyy'))
          , XMLElement("write_off_date", to_char(write_off_date, 'dd.mm.yyyy'))
          , XMLElement("doc_number", doc_number)
          , XMLElement("doc_date", to_char(doc_date, 'dd.mm.yyyy'))
          , xmlelement("kind_of_payment", get_label_text('KIND_OF_PAYMENT', nvl(i_lang, get_user_lang)))
          , XMLElement("payer_bic"
              , com_api_flexible_data_pkg.get_flexible_value (
                    rus_api_const_pkg.FLX_BANK_ID_CODE
                  , ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                  , payer_inst_id
                )
            )
          , XMLElement("payer_account", payer_account)
          , XMLElement("payer_corr_acc"
              , com_api_flexible_data_pkg.get_flexible_value(
                    i_field_name  => 'CORRESPONDENT_ACCOUNT'
                  , i_entity_type => 'ENTTINST'
                  , i_object_id   => payer_inst_id
               )
            )
          , XMLElement("payer_name",
                case payer_entity_type
                when com_api_const_pkg.ENTITY_TYPE_UNDEFINED
                then get_text(
                         i_table_name  => 'ost_institution'
                       , i_column_name => 'name'
                       , i_object_id   => payer_inst_id
                       , i_lang        => i_lang
                     )
                else com_ui_object_pkg.get_object_desc(
                         i_entity_type => payer_entity_type
                       , i_object_id   => payer_object_id
                       , i_lang        => nvl(i_lang, get_user_lang)
                     )
                end
            )
          , XMLElement("payer_inn"
              , decode(payer_account_type, 'ACTP0120', '0', 'ACTPNEW', com_api_flexible_data_pkg.get_flexible_value(
                    i_field_name  => rus_api_const_pkg.FLX_TAX_ID
                  , i_entity_type => 'ENTTINST'
                  , i_object_id   => payer_inst_id
               ), '')
            )
          , XMLElement("recipient_account"
              , nvl(pmo_api_order_pkg.get_order_data_value(
                        i_order_id   => order_id
                      , i_param_name => rus_api_const_pkg.CBS_TRANSFER_RECIPIENT_ACCOUNT
                    )
                  , recipient_account
                )
            )
          , XMLElement("recipient_name"
              , nvl(pmo_api_order_pkg.get_order_data_value(
                        i_order_id   => order_id
                      , i_param_name => rus_api_const_pkg.CBS_TRANSFER_RECIPIENT_NAME
                    )
                  , case recipient_entity_type
                    when com_api_const_pkg.ENTITY_TYPE_UNDEFINED
                    then get_text(
                             i_table_name  => 'ost_institution'
                           , i_column_name => 'name'
                           , i_object_id   => recipient_inst_id
                           , i_lang        => i_lang
                         )
                    else com_ui_object_pkg.get_object_desc(
                             i_entity_type => recipient_entity_type
                           , i_object_id   => recipient_object_id
                           , i_lang        => nvl(i_lang, get_user_lang)
                         )
                    end
                 )
            )
          , XMLElement("recipient_inn"
              ,nvl( pmo_api_order_pkg.get_order_data_value(
                        i_order_id   => order_id
                      , i_param_name => rus_api_const_pkg.CBS_TRANSFER_RECIPIENT_TAX_ID
                    )
                    , '0')
            )
          , XMLElement("recipient_corr_acc"
              , nvl(pmo_api_order_pkg.get_order_data_value(
                        i_order_id   => order_id
                      , i_param_name => rus_api_const_pkg.CBS_TRANSFER_BANK_CORR_ACC
                    )
                  , com_api_flexible_data_pkg.get_flexible_value(
                        i_field_name  => 'CORRESPONDENT_ACCOUNT'
                      , i_entity_type => 'ENTTINST'
                      , i_object_id   => payer_inst_id
                    )
                )
            )
          , XMLElement("recipient_bic"
              , nvl(pmo_api_order_pkg.get_order_data_value(
                        i_order_id   => order_id
                      , i_param_name => rus_api_const_pkg.CBS_TRANSFER_BIC
                    )
                  , com_api_flexible_data_pkg.get_flexible_value (
                        i_field_name  => rus_api_const_pkg.FLX_BANK_ID_CODE
                      , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                      , i_object_id   => payer_inst_id
                    )
                )
            )
          , XMLElement("recipient_bank_name"
              , nvl(
                    nvl(
                        pmo_api_order_pkg.get_order_data_value(
                            i_order_id   => order_id
                          , i_param_name => rus_api_const_pkg.CBS_TRANSFER_BANK_BRANCH_NAME
                        )
                      , pmo_api_order_pkg.get_order_data_value(
                            i_order_id   => order_id
                          , i_param_name => rus_api_const_pkg.CBS_TRANSFER_BANK_NAME
                        )
                    )
                    , get_text(
                        i_table_name  => 'ost_institution'
                      , i_column_name =>'name'
                      , i_object_id   => payer_inst_id
                      , i_lang        => i_lang
                    )
                  )
              ||', '
              ||nvl(pmo_api_order_pkg.get_order_data_value(
                        i_order_id   => order_id
                      , i_param_name => rus_api_const_pkg.CBS_TRANSFER_BANK_CITY
                    )
                  , ost_ui_institution_pkg.get_inst_city(
                        i_inst_id     => payer_inst_id
                      , i_lang        => i_lang
                      , i_city_alias  => com_api_label_pkg.get_label_text('CITY_ALIAS', nvl(i_lang, get_user_lang))
                    )
                 )
            )
          , XMLElement("doc_amount", to_char(doc_amount, 'FM999999999990D'||lpad('0', exponent, '0'),'NLS_NUMERIC_CHARACTERS = ''- '''))
          , XMLElement("doc_amount_in_words",
                com_api_type_pkg.num2str(
                  i_source   => doc_amount
                , i_lang     => i_lang
                , i_currency => doc_currency
                )
            )
          , XMLElement("auth_number", auth_number)
          , XMLElement("auth_date", to_char(auth_date, 'dd.mm.yyyy'))
          , XMLElement("cypher", 'cypher')
          , XMLElement("payer_bank_name"
              , get_text(
                    i_table_name  =>  'ost_institution'
                  , i_column_name =>'name'
                  , i_object_id   => payer_inst_id
                  , i_lang        => i_lang
                )
              ||ost_ui_institution_pkg.get_inst_city(
                    i_inst_id     => payer_inst_id
                  , i_lang        => i_lang
                  , i_city_alias  => ', ' || com_api_label_pkg.get_label_text('CITY_ALIAS', nvl(i_lang, get_user_lang))
                 )
            )
          , XMLElement("operation_code",  '01')
          , XMLElement("priority", '06')
          , XMLElement("payment_purpose"
              , pmo_api_order_pkg.get_order_data_value(
                    i_order_id   => order_id
                  , i_param_name => rus_api_const_pkg.CBS_TRANSFER_PAYMENT_PURPOSE
                )
            )
        )
    into l_result
    from (
        select cst_api_name_pkg.get_next_number (
                        i_document_type => 'DCMT5003'
                      , i_eff_date      => min(e.posting_date)
                      , i_inst_id       => d.inst_id
              ) doc_number
             , min(e.posting_date) doc_date
             , o.amount/power(10, u.exponent) doc_amount
             , o.currency doc_currency
             , min(x.host_date) receive_date
             , min(x.host_date) write_off_date
             , min(o.purpose_id) as purpose_id
             , min(case when e.balance_impact = -1 then a.account_type end) payer_account_type
             , min(case when e.balance_impact = -1 then a.account_number end) payer_account
             , min(case when e.balance_impact = -1 then a.inst_id end) payer_inst_id
             , min(case when e.balance_impact = 1 then a.account_number end) recipient_account
             , min(case when e.balance_impact = 1 then a.inst_id end) recipient_inst_id
             , min(case when e.balance_impact = 1 then r.entity_type end) recipient_entity_type
             , min(case when e.balance_impact = 1 then r.object_id end) recipient_object_id
             , min(c.entity_type) payer_entity_type
             , min(c.object_id) payer_object_id
             , min(d.document_number) auth_number
             , min(d.document_date) auth_date
             , min(u.exponent) exponent
             , o.id order_id
             , min(case when e.balance_impact = 1 then a.account_number end) recipient_account2
          from pmo_order o
             , rpt_document d
             , prd_customer c
             , com_currency u
             , opr_operation x
             , acc_entry e
             , acc_macros m
             , acc_account a
             , prd_customer r
         where e.transaction_id = i_object_id
           and o.customer_id    = c.id
           and o.currency       = u.code
           and o.id             = x.payment_order_id
           and x.id             = m.object_id
           and e.macros_id      = m.id
           and d.entity_type    = 'ENTTPMNO'
           and d.object_id      = o.id
           and a.id             = e.account_id
           and r.id(+)          = a.customer_id
      group by o.id
             , o.currency
             , o.amount
             , u.exponent
             , d.inst_id
        );
--trc_log_pkg.debug(l_result.getstringval());
    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
        i_text => 'rus_api_order_report_pkg.payment_order - ok'
    );
exception
    when others then
        trc_log_pkg.debug(sqlerrm);
        raise;
end;

procedure memorial_order (
    o_xml          out clob
  , i_lang      in     com_api_type_pkg.t_dict_value
  , i_object_id in     com_api_type_pkg.t_long_id
) is
    l_result                xmltype;
begin
    trc_log_pkg.debug (
        i_text          => 'rus_api_order_report_pkg.memorial_order: object_id[#1]'
        , i_env_param1  => to_char(i_object_id, 'TM9')
    );

    select
        XMLElement("report",
            XMLElement("bank_name", get_text('ost_institution', 'name', inst_id, i_lang))
          , XMLElement("doc_number", doc_number)
          , XMLElement("doc_date", to_char(doc_date, 'dd.mm.yyyy'))
         , XMLElement("payer_rur_amount", to_char(payer_rur_amount, 'FM999999999990D'||lpad('0', exponent, '0'),'NLS_NUMERIC_CHARACTERS = ''- '''))
         , XMLElement("payer_val_amount", to_char(payer_val_amount, 'FM999999999990D'||lpad('0', exponent, '0'),'NLS_NUMERIC_CHARACTERS = ''- '''))
         , XMLElement("recipient_rur_amount", to_char(recipient_rur_amount, 'FM999999999990D'||lpad('0', exponent, '0'),'NLS_NUMERIC_CHARACTERS = ''- '''))
         , XMLElement("recipient_val_amount", to_char(recipient_val_amount, 'FM999999999990D'||lpad('0', exponent, '0'),'NLS_NUMERIC_CHARACTERS = ''- '''))
         , XMLElement("doc_amount_in_words", com_api_type_pkg.num2str(
                i_source   => payer_amount
              , i_currency => payer_currency
              , i_lang     => i_lang))
          , XMLElement("payer_name", payer_name)
          , XMLElement("payer_account", payer_account)
          , XMLElement("recipient_name", recipient_name)
          , XMLElement("recipient_account", recipient_account)
          , XMLElement("auth_number", auth_number)
          , XMLElement("auth_date", to_char(auth_date, 'dd.mm.yyyy'))
          , XMLElement("cypher", '09')
        )
    into l_result
    from (
        select cst_api_name_pkg.get_next_number (
                        i_document_type => 'DCMT5002'
                      , i_eff_date      => min(e.posting_date)
                      , i_inst_id       => a.inst_id
              ) doc_number
             , min(e.posting_date) doc_date
             , min(a.inst_id) inst_id
             , min(case when e.balance_impact = -1 then e.amount/power(10, u.exponent) else null end ) payer_amount
             , min(case when e.balance_impact = -1 then b.currency end) payer_currency
             , min(case when e.balance_impact = -1 and e.currency in ('810', '643') then e.amount/power(10, u.exponent) else null end) payer_rur_amount
             , min(case when e.balance_impact = -1 and e.currency not in ('810', '643') then e.amount/power(10, u.exponent) else null end) payer_val_amount
             , min(case when e.balance_impact = 1  and e.currency in ('810', '643') then e.amount/power(10, u.exponent) else null end) recipient_rur_amount
             , min(case when e.balance_impact = 1  and e.currency not in ('810', '643') then e.amount/power(10, u.exponent) else null end) recipient_val_amount
             , min(case when e.balance_impact = -1
                        then get_account_name(
                                i_account_id    => b.account_id
                              , i_balance_type  => b.balance_type
                              , i_lang          => i_lang
                             )
                    else null end) payer_name
             , min(decode(e.balance_impact, -1, nvl(b.balance_number, a.account_number), null)) payer_account
             , min(case
                   when e.balance_impact = 1
                   then get_account_name(
                            i_account_id    => b.account_id
                          , i_balance_type  => b.balance_type
                          , i_lang          => i_lang
                         )
                   else null end
               ) recipient_name
             , min(case e.balance_impact when  1 then a.account_number else null end) recipient_account
             , min(m.object_id) auth_number
             , min(m.host_date) auth_date
             , min(u.exponent) exponent
          from acc_entry e
             , acc_balance b
             , acc_account a
             , prd_customer c
             , acc_ui_macros_oper_vw m
             , com_currency u
         where e.transaction_id = i_object_id
           and a.id             = b.account_id
           and e.balance_type   = b.balance_type
           and e.account_id     = a.id
           and a.customer_id    = c.id(+)
           and e.macros_id      = m.id
           and e.currency       = u.code
         group by a.inst_id
       );

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
        i_text => 'rus_api_order_report_pkg.memorial_order - ok'
    );
exception
    when others then
        trc_log_pkg.debug(sqlerrm);
        raise;
end;

function get_account_name(
    i_account_id    in     com_api_type_pkg.t_account_id
  , i_balance_type  in     com_api_type_pkg.t_dict_value
  , i_lang          in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name is
    l_entity_type      com_api_type_pkg.t_dict_value;
    l_account_type     com_api_type_pkg.t_dict_value;
    l_category         com_api_type_pkg.t_dict_value;
    l_customer_number  com_api_type_pkg.t_name;
    l_object_id        com_api_type_pkg.t_long_id;
    l_result           com_api_type_pkg.t_name;
    l_inst_id          com_api_type_pkg.t_inst_id;
    l_contract_id      com_api_type_pkg.t_medium_id;
    l_contract_type    com_api_type_pkg.t_dict_value;
begin
    select a.account_type
         , c.category
         , c.customer_number
         , case when c.ext_entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then c.entity_type else nvl(c.ext_entity_type, c.entity_type) end
         , case when c.ext_entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then c.object_id else nvl(c.ext_object_id, c.object_id) end
         , c.inst_id
         , c.contract_id
         , t.contract_type
      into l_account_type
         , l_category
         , l_customer_number
         , l_entity_type
         , l_object_id
         , l_inst_id
         , l_contract_id
         , l_contract_type
      from acc_account a
         , prd_customer c
         , prd_contract t
     where a.id    = i_account_id
       and t.id(+) = a.contract_id
       and c.id(+) = a.customer_id;

    select nvl(l_entity_type, min(x.entity_type))
      into l_entity_type
      from acc_account_type_entity x
     where x.account_type = l_account_type;

    if l_entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION and l_object_id is not null then
        l_result := com_api_i18n_pkg.get_text('OST_INSTITUTION', 'NAME', l_object_id, i_lang);
    elsif l_entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then
        l_result := get_article_text(l_account_type, i_lang);
    elsif l_entity_type = pmo_api_const_pkg.ENTITY_TYPE_SERVICE_PROVIDER then
        l_result := com_api_i18n_pkg.get_text('pmo_provider', 'label', l_object_id, i_lang);
    elsif l_entity_type in (com_api_const_pkg.ENTITY_TYPE_UNDEFINED, com_api_const_pkg.ENTITY_TYPE_PERSON) then
        if l_account_type = acc_api_const_pkg.ACCOUNT_TYPE_FEES then
            l_result := get_article_text(acc_api_const_pkg.BALANCE_TYPE_FEES, i_lang);
        elsif i_balance_type != acc_api_const_pkg.BALANCE_TYPE_LEDGER then
            l_result := get_article_text(i_balance_type, i_lang);--||' ('||l_customer_number||')';
            trc_log_pkg.debug('1, i_balance_type='||i_balance_type);
        else
            if l_contract_type in ('CNTPEWLT', 'CNTPCUSR') then
                --l_result := l_customer_number;
                for rec in (
                    select
                        a.contract_number
                      , a.start_date
                      , get_text('OST_INSTITUTION', 'NAME', a.inst_id, i_lang) inst
                    from
                        prd_contract a
                    where
                        a.id = l_contract_id
                ) loop
                    if l_account_type in (acc_api_const_pkg.ACCOUNT_TYPE_NESP_EXCEED_P) then
                        l_result := rec.inst;
                    else
                        l_result := rec.inst || ' ' || rec.contract_number || ' ' || to_char (rec.start_date, 'dd.mm.yyyy');
                    end if;
                end loop;
                trc_log_pkg.debug('2');
--            elsif l_contract_type in (rus_api_const_pkg.CUSTOMER_CAT_PERSONIFIED) then
--                for rec in (
--                    select
--                        a.contract_number
--                      , a.start_date
--                      , get_text('OST_INSTITUTION', 'NAME', a.inst_id, i_lang) inst
--                    from
--                        prd_contract a
--                    where
--                        a.id = l_contract_id)
--                loop
--                    l_result := com_ui_person_pkg.get_person_name(l_object_id, i_lang) || ' ' ||
--                                rec.inst || ' ' || rec.contract_number || ' ' ||
--                                to_char (rec.start_date, 'dd.mm.yyyy');
--                end loop;
--                --l_result := com_ui_person_pkg.get_person_name(l_object_id, i_lang);
--                trc_log_pkg.debug('3, i_object_id='||l_object_id);
            elsif l_contract_type in ('CNTPBANK') then
                l_result := com_ui_person_pkg.get_person_name(l_object_id, i_lang);
                trc_log_pkg.debug('3.1, i_object_id='||l_object_id);
            end if;

        end if;
    elsif l_entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY then
        if l_account_type = acc_api_const_pkg.ACCOUNT_TYPE_FEES then
           l_result := get_article_text(acc_api_const_pkg.BALANCE_TYPE_FEES, i_lang);
        elsif i_balance_type != acc_api_const_pkg.BALANCE_TYPE_LEDGER then
            l_result := get_article_text(i_balance_type, i_lang);
            trc_log_pkg.debug('4');
        else
            if l_category = rus_api_const_pkg.CUSTOMER_CAT_NON_PERSONIF then
                l_result := l_customer_number;
                trc_log_pkg.debug('5');
            elsif l_category in (
                rus_api_const_pkg.CUSTOMER_CAT_PERSONIFIED
                , rus_api_const_pkg.CUSTOMER_CAT_BANKING
            ) then
                l_result := com_api_i18n_pkg.get_text('COM_COMPANY', 'LABEL', l_object_id, i_lang);
                trc_log_pkg.debug('6');
            else
                l_result := com_api_i18n_pkg.get_text('COM_COMPANY', 'LABEL', l_object_id, i_lang);
            end if;
        end if;
    else
        if l_account_type = acc_api_const_pkg.ACCOUNT_TYPE_FEES then
           l_result := get_article_text(acc_api_const_pkg.BALANCE_TYPE_FEES, i_lang);
        elsif i_balance_type != acc_api_const_pkg.BALANCE_TYPE_LEDGER then
            l_result := get_article_text(i_balance_type, i_lang)||' ('||l_customer_number||')';
            trc_log_pkg.debug('7');
        else
            if l_category = rus_api_const_pkg.CUSTOMER_CAT_NON_PERSONIF then
                l_result := l_customer_number;
                trc_log_pkg.debug('8');
            elsif l_category in (
                rus_api_const_pkg.CUSTOMER_CAT_PERSONIFIED
                , rus_api_const_pkg.CUSTOMER_CAT_BANKING
            ) then
                l_result := com_ui_person_pkg.get_person_name(l_object_id, i_lang);
                trc_log_pkg.debug('9');
            else
                l_result := com_ui_person_pkg.get_person_name(l_object_id, i_lang);
            end if;
        end if;
    end if;

    return l_result;
end;

end;
/
