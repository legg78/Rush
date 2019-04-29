create or replace package body iss_api_report_pkg is
/*********************************************************
 *  Issuer reports API <br />
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 04.12.2012 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: iss_api_report_pkg <br />
 *  @headcom
 **********************************************************/

procedure account_statement (
    o_xml                         out clob
  , i_inst_id                      in com_api_type_pkg.t_inst_id
  , i_account_number               in com_api_type_pkg.t_account_number
  , i_start_date                   in date
  , i_end_date                     in date
  , i_lang                         in com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.account_statement: ';
    l_start_date                   date;
    l_end_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_account_id                   com_api_type_pkg.t_medium_id;
    l_customer_id                  com_api_type_pkg.t_medium_id;
    l_currency                     com_api_type_pkg.t_curr_code;

    l_incoming_ledger_balance      com_api_type_pkg.t_money;
    l_outgoing_ledger_balance      com_api_type_pkg.t_money;

    l_incoming_hold_balance        com_api_type_pkg.t_money;
    l_outgoing_hold_balance        com_api_type_pkg.t_money;

    l_header                       xmltype;
    l_detail                       xmltype;
    l_result                       xmltype;
begin
    l_lang       := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date   := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '[#1][#2][#3][#4][#5]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_account_number
      , i_env_param3 => com_api_type_pkg.convert_to_char(l_start_date)
      , i_env_param4 => com_api_type_pkg.convert_to_char(l_end_date)
      , i_env_param5 => i_lang
    );

    select a.id
         , a.customer_id
         , a.currency
      into l_account_id
         , l_customer_id
         , l_currency
      from acc_account a
     where a.account_number = i_account_number
       and a.inst_id        = i_inst_id;

    l_incoming_ledger_balance  := acc_api_balance_pkg.get_balance_amount(
                                      i_account_id   => l_account_id
                                    , i_balance_type => acc_api_const_pkg.BALANCE_TYPE_LEDGER
                                    , i_date         => l_start_date
                                    , i_date_type    => com_api_const_pkg.DATE_PURPOSE_PROCESSING
                                    , i_mask_error   => com_api_type_pkg.FALSE
                                  ).amount;

    l_outgoing_ledger_balance  := acc_api_balance_pkg.get_balance_amount(
                                      i_account_id   => l_account_id
                                    , i_balance_type => acc_api_const_pkg.BALANCE_TYPE_LEDGER
                                    , i_date         => l_end_date
                                    , i_date_type    => com_api_const_pkg.DATE_PURPOSE_PROCESSING
                                    , i_mask_error   => com_api_type_pkg.FALSE
                                  ).amount;

    l_incoming_hold_balance    := acc_api_balance_pkg.get_balance_amount(
                                      i_account_id   => l_account_id
                                    , i_balance_type => acc_api_const_pkg.BALANCE_TYPE_HOLD
                                    , i_date         => l_start_date
                                    , i_date_type    => com_api_const_pkg.DATE_PURPOSE_PROCESSING
                                    , i_mask_error   => com_api_type_pkg.FALSE
                                  ).amount;

    l_outgoing_hold_balance    := acc_api_balance_pkg.get_balance_amount(
                                      i_account_id   => l_account_id
                                    , i_balance_type => acc_api_const_pkg.BALANCE_TYPE_HOLD
                                    , i_date         => l_end_date
                                    , i_date_type    => com_api_const_pkg.DATE_PURPOSE_PROCESSING
                                    , i_mask_error   => com_api_type_pkg.FALSE
                                  ).amount;

    begin
        -- header
        select xmlconcat(
                   xmlelement("inst_id",          i_inst_id)
                 , xmlelement("inst_name",        com_api_i18n_pkg.get_text('ost_institution', 'name', i_inst_id, l_lang))
                 , xmlelement("account_number",   i_account_number)
                 , xmlelement("currency",         (select t.name from com_currency t where t.code = l_currency))
                 , xmlelement("start_date",       to_char(l_start_date,   'dd.mm.yyyy'))
                 , xmlelement("end_date",         to_char(l_end_date,     'dd.mm.yyyy'))
                 , xmlelement("customer_name",    customer_name || nvl2(id_card, ', ' || id_card, ''))
                 , xmlelement("incoming_balance", com_api_currency_pkg.get_amount_str(
                                                      i_amount         => nvl(l_incoming_ledger_balance + l_incoming_hold_balance, 0)
                                                    , i_curr_code      => l_currency
                                                    , i_mask_curr_code => com_api_type_pkg.TRUE
                                                  ))
                 , xmlelement("outgoing_balance", com_api_currency_pkg.get_amount_str(
                                                      i_amount         => nvl(l_outgoing_ledger_balance + l_outgoing_hold_balance, 0)
                                                    , i_curr_code      => l_currency
                                                    , i_mask_curr_code => com_api_type_pkg.TRUE
                                                  ))
               )
          into l_header
          from (
              select com_ui_object_pkg.get_object_desc    (c.entity_type, c.object_id, l_lang) as customer_name
                   , com_ui_id_object_pkg.get_id_card_desc(c.entity_type, c.object_id, l_lang) as id_card
                from prd_customer c
               where c.id = l_customer_id
          );
    exception
        when no_data_found then
            null;
    end;

    -- details
    select xmlelement("operations"
             , nvl(
                   xmlagg(
                       xmlelement("operation"
                         , xmlelement("posting_date", to_char(posting_date, 'dd.mm.yyyy'))
                         , xmlelement("oper_date", to_char(oper_date, 'dd.mm.yyyy'))
                         , xmlelement("currency", currency)
                         , xmlelement("amount"
                                    , com_api_currency_pkg.get_amount_str(
                                          i_amount         => nvl(x.balance_impact * x.amount, 0)
                                        , i_curr_code      => x.currency
                                        , i_mask_curr_code => com_api_type_pkg.TRUE
                                      ))
                         , xmlelement("account_amount"
                                    , com_api_currency_pkg.get_amount_str(
                                          i_amount         => nvl(x.balance_impact * x.account_amount, 0)
                                        , i_curr_code      => x.account_currency
                                        , i_mask_curr_code => com_api_type_pkg.TRUE
                                      ))
                         , xmlelement("card_mask", coalesce(
                                                       x.card_mask
                                                     , com_api_label_pkg.get_label_text('BANK_TRANSACTIONS', l_lang)
                                                   )
                                     )
                         , xmlelement("oper_desc", nvl(cst_api_operation_pkg.build_operation_desc(x.operation_id), x.oper_desc))
                         , xmlelement("auth_code", x.auth_code)
                         , xmlelement("balance_type", com_api_dictionary_pkg.get_article_text(x.balance_type, l_lang))
                         , xmlelement("balance_amount"
                                    , com_api_currency_pkg.get_amount_str(
                                          i_amount         => nvl(x.balance_amount, 0)
                                        , i_curr_code      => x.account_currency
                                        , i_mask_curr_code => com_api_type_pkg.TRUE
                                      ))
                       )
                       order by
                           balance_type
                         , posting_date
                         , transaction_id
                   )
                 , xmlelement("operation", '')
               )
           )
      into l_detail
      from (
          select e.transaction_id
               , o.id operation_id
               , e.posting_date
               , o.oper_date
               , o.oper_currency currency
               , abs(o.oper_amount) amount
               , e.balance_impact
               , a.currency account_currency
               , e.amount account_amount
               , o.card_mask
               , o.auth_code
               , get_article_desc(o.oper_type)
                     ||'-'||o.merchant_name
                     ||'\'||o.merchant_postcode
                     ||'\'||o.merchant_street
                     ||'\'||o.merchant_city
                     ||'\'||o.merchant_region
                     ||'\'||o.merchant_country
                 as oper_desc
              , b.balance_type
              , sum(e.balance_impact*e.amount) over (partition by b.balance_type) as balance_amount
           from acc_account a
              , acc_balance b
              , acc_balance_type t
              , acc_entry e
              , acc_macros m
              , opr_operation_participant_vw o
          where a.account_number = i_account_number
            and b.account_id = a.id
            and b.balance_type in (acc_api_const_pkg.BALANCE_TYPE_LEDGER
                                 , acc_api_const_pkg.BALANCE_TYPE_HOLD)
            and t.account_type = a.account_type
            and t.inst_id = a.inst_id
            and t.balance_type = b.balance_type
            and e.account_id = a.id
            and e.balance_type = b.balance_type
            and e.posting_date between l_start_date and l_end_date
            and m.id = e.macros_id
            and m.object_id = o.id
            and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
            and not exists (select 1
                              from acc_entry ae
                             where ae.id = e.ref_entry_id
                               and ae.posting_date between l_start_date and l_end_date
                           )
      ) x;

    select xmlelement (
               "report"
             , l_header
             , l_detail
           ) r
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'FINISHED'
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text   => sqlerrm
        );
        raise;
end;

procedure account_statement_for_batch(
    o_xml                         out clob
  , i_inst_id                      in com_api_type_pkg.t_inst_id
  , i_entity_type                  in com_api_type_pkg.t_dict_value
  , i_object_id                    in com_api_type_pkg.t_long_id
  , i_start_date                   in date
  , i_end_date                     in date
  , i_lang                         in com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX            constant    com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.account_statement_for_batch: ';
    l_document_rec                    rpt_api_type_pkg.t_document_rec;
    l_account_number                  com_api_type_pkg.t_account_number;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '[#1][#2][#3][#4][#5]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_entity_type
      , i_env_param3 => i_object_id
      , i_env_param4 => com_api_type_pkg.convert_to_char(i_start_date)
      , i_env_param5 => com_api_type_pkg.convert_to_char(i_end_date)
      , i_env_param6 => i_lang
    );

    if i_entity_type = rpt_api_const_pkg.ENTITY_TYPE_DOCUMENT then
        l_document_rec   := rpt_api_document_pkg.get_document(
                                i_document_id  => i_object_id
                              , i_content_type => rpt_api_const_pkg.CONTENT_TYPE_PRINT_FORM
                            );

        if l_document_rec.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
            l_account_number := acc_api_account_pkg.get_account_number(
                                    i_account_id  => l_document_rec.object_id
                                  , i_mask_error  => com_api_const_pkg.FALSE
                                );
        else
            com_api_error_pkg.raise_error(
                i_error           => 'ENTITY_TYPE_NOT_SUPPORTED'
              , i_env_param1      => i_entity_type
            );
        end if;

        account_statement(
            o_xml             => o_xml
          , i_inst_id         => i_inst_id
          , i_account_number  => l_account_number
          , i_start_date      => i_start_date
          , i_end_date        => i_end_date
          , i_lang            => i_lang
        );
    else
        com_api_error_pkg.raise_error(
            i_error           => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1      => i_entity_type
        );
    end if;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'FINISHED'
    );

end account_statement_for_batch;

procedure issued_card_by_network(
    o_xml                             out clob
    , i_inst_id                    in     com_api_type_pkg.t_inst_id       default null
    , i_agent_id                   in     com_api_type_pkg.t_agent_id      default null
    , i_start_date                 in     date
    , i_end_date                   in     date
    , i_lang                       in     com_api_type_pkg.t_dict_value
    
) is
    l_start_date                  date;
    l_end_date                    date;
    l_lang                        com_api_type_pkg.t_dict_value;
    l_detail                      xmltype;
begin
    trc_log_pkg.debug (
        i_text          => 'iss_api_report_pkg.issued_card [#1][#2][#3][#4]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => i_agent_id
        , i_env_param3  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
        , i_env_param4  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    -- details
    begin
        
        select 
            case when count(1) = 0 then          
                xmlelement ("cards"
                    , xmlelement("card", null)
                    )
            else        
                xmlelement ("cards"
                    , xmlagg (
                          xmlelement ("card"
                          , xmlelement ("inst_id", inst_id)
                          , xmlelement ("agent_id", agent_id)
                          , xmlelement ("agent_name", agent_name)
                          , xmlelement ("network_id", network_id)
                          , xmlelement ("network_name", network_name)
                          , xmlelement ("card_number", card_number)
                          , xmlelement ("expir_date", to_char(expir_date, 'dd.mm.yyyy'))
                          , xmlelement ("iss_date", to_char(iss_date, 'dd.mm.yyyy'))
                          , xmlelement ("issuer_range", to_char(min_iss_date, 'dd.mm.yyyy') || ' - ' || to_char(max_expir_date, 'dd.mm.yyyy'))
                          , xmlelement ("cardholder_name", cardholder_name)
                          , xmlelement ("company_name", company_name)
                          , xmlelement ("account_number", account_number)
                          , xmlelement ("person_name", person_name)
                          )
                        order by
                            inst_id
                          , agent_id
                          , network_id
                      )
                )
            end   
        into
            l_detail
        from (
            select bin.inst_id inst_id
                 , ci.agent_id
                 , com_api_i18n_pkg.get_text('ost_agent','name', ci.agent_id, l_lang) agent_name
                 , com_api_i18n_pkg.get_text('net_network','name', network_id, l_lang) network_name
                 , bin.network_id
                 , coalesce(c.card_mask, iss_api_card_pkg.get_card_mask(cn.card_number)) card_number
                 , ch.cardholder_name
                 , ci.company_name
                 , ac.account_number
                 , com_ui_person_pkg.get_person_name(ch.person_id, l_lang) person_name
                 , ci.iss_date
                 , ci.expir_date
                 , min(ci.iss_date) over (partition by bin.inst_id, ci.agent_id, bin.network_id) min_iss_date
                 , max(ci.expir_date) over (partition by bin.inst_id, ci.agent_id, bin.network_id) max_expir_date
              from iss_card_instance ci
                 , iss_card_number_vw cn
                 , iss_bin bin
                 , iss_card c
                 , iss_cardholder ch
                 , acc_account_object obj
                 , acc_account ac
             where c.id = ci.card_id
               and ch.id(+) = c.cardholder_id
               and c.id = cn.card_id
               and bin.id = ci.bin_id
               and bin.inst_id = c.inst_id
               and obj.object_id = c.id
               and obj.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and obj.account_id = ac.id
               and (i_inst_id is null or bin.inst_id = i_inst_id)
               and (i_agent_id is null or ci.agent_id = i_agent_id)
               and ci.iss_date between l_start_date and l_end_date
        );
    end;

    select
        xmlelement (
            "report"
            , get_header(i_inst_id, i_agent_id, l_start_date, l_end_date, l_lang)          
            , l_detail
        ).getclobval()
    into
        o_xml
    from
        dual;

    trc_log_pkg.debug (
         i_text => 'iss_api_report_pkg.issued_card - ok'
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end;

procedure issued_card_by_agent(
    o_xml                             out clob
    , i_inst_id                    in     com_api_type_pkg.t_inst_id       default null
    , i_agent_id                   in     com_api_type_pkg.t_agent_id      default null
    , i_start_date                 in     date
    , i_end_date                   in     date
    , i_lang                       in     com_api_type_pkg.t_dict_value
) is

    l_start_date                   date;
    l_end_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_detail                       xmltype;

begin
    trc_log_pkg.debug (
        i_text          => 'iss_api_report_pkg.issued_card_by_agent [#1][#2][#3][#4]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => i_agent_id
        , i_env_param3  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
        , i_env_param4  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    -- details
    begin
      
        select 
            case when count(1) = 0 then          
                xmlelement ("cards"
                    , xmlelement("card", null)
                    )
            else
        
                xmlelement("cards"
                  , xmlagg(
                      xmlelement("card"
                        , xmlelement("inst_id", inst_id)
                        , xmlelement("inst", inst)
                        , xmlelement("agent_id", agent_id)
                        , xmlelement("agent_name", agent_name)
                        , xmlelement("card_number", card_number)
                        , xmlelement("expir_date", to_char(expir_date, 'dd.mm.yyyy'))
                        , xmlelement("iss_date", to_char(iss_date, 'dd.mm.yyyy'))
                        , xmlelement("issuer_range", to_char(min_iss_date, 'dd.mm.yyyy') || ' - ' || to_char(max_expir_date, 'dd.mm.yyyy'))
                        , xmlelement("cardholder_name", cardholder_name)
                        , xmlelement("company_name", company_name)
                        , xmlelement("account_number", account_number)
                        , xmlelement("person_name", person_name)
                      )
                      order by
                          inst_id
                        , agent_id
                        , account_number
                        , card_number
                    )
                )
            end    
        into
            l_detail
        from (
            select
                  ci.inst_id inst_id
                  , com_api_i18n_pkg.get_text('ost_institution','name', ci.inst_id, l_lang) inst
                  , ci.agent_id
                  , com_api_i18n_pkg.get_text('ost_agent','name', ci.agent_id, l_lang) agent_name
                  , coalesce(c.card_mask, iss_api_card_pkg.get_card_mask(cn.card_number)) card_number
                  , ch.cardholder_name
                  , ci.company_name
                  , ac.account_number
                  , com_ui_person_pkg.get_person_name(ch.person_id, l_lang) person_name
                  , ci.iss_date
                  , ci.expir_date
                  , min(ci.iss_date) over (partition by ci.inst_id, ci.agent_id) min_iss_date
                  , max(ci.expir_date) over (partition by ci.inst_id, ci.agent_id) max_expir_date
              from
                  iss_card_instance ci
                  , iss_card_number_vw cn
                  , iss_card c
                  , iss_cardholder ch
                  , acc_account_object obj
                  , acc_account ac
              where
                  c.id = ci.card_id
                  and ch.id(+) = c.cardholder_id
                  and c.id = cn.card_id
                  and obj.object_id = c.id
                  and obj.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                  and obj.account_id = ac.id
                  and (i_inst_id is null or ci.inst_id = i_inst_id)
                  and (i_agent_id is null or ci.agent_id = i_agent_id)
                  and ci.iss_date between l_start_date and l_end_date
        );
    end;

    select
        xmlelement (
            "report"
            , get_header(i_inst_id, i_agent_id, l_start_date, l_end_date, l_lang)
            , l_detail
        ).getclobval()
    into
        o_xml
    from
        dual;

    trc_log_pkg.debug (
         i_text => 'iss_api_report_pkg.issued_card_by_agent - ok'
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end;

procedure register_card_by_agent(
    o_xml                             out clob
    , i_inst_id                    in     com_api_type_pkg.t_inst_id
    , i_agent_id                   in     com_api_type_pkg.t_agent_id      default null
    , i_start_date                 in     date
    , i_end_date                   in     date
    , i_lang                       in     com_api_type_pkg.t_dict_value
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_agent_id                     com_api_type_pkg.t_agent_id;
    l_start_date                   date;
    l_end_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_detail                       xmltype;
    l_result                       xmltype;
    
begin
    trc_log_pkg.debug (
        i_text          => 'iss_api_report_pkg.register_card_by_agent [#1][#2][#3][#4]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => i_agent_id
        , i_env_param3  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
        , i_env_param4  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1-com_api_const_pkg.ONE_SECOND)
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id := nvl(i_inst_id, 0);
    l_agent_id := nvl(i_agent_id, 0);

    -- details
    begin
       
        select 
            case when count(1) = 0 then          
                xmlelement ("cards"
                    , xmlelement("card", null)
                    )
            else
        
                xmlelement("cards"
                        , xmlagg(
                            xmlelement("card"
                                , xmlelement("inst_id", inst_id)
                                , xmlelement("inst", inst)
                                , xmlelement("agent_id", agent_id)
                                , xmlelement("agent", agent)
                                , xmlelement("card_number", card_number)
                                , xmlelement("company", company)
                                , xmlelement("company_description", company_description)
                                , xmlelement("person_name", person_name)
                            )
                            order by inst
                                   , agent
                                   , card_number
                        )
                    )
            end        
        into
            l_detail
        from(
            select coalesce(c.card_mask, iss_api_card_pkg.get_card_mask(n.card_number)) card_number
                 , i.agent_id
                 , com_api_i18n_pkg.get_text('OST_AGENT','NAME', i.agent_id, l_lang) as agent
                 , i.inst_id
                 , com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', i.inst_id, l_lang) as inst
                 , case when s.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY then (select m.embossed_name from com_company m where m.id = s.object_id)
                        else null
                   end company
                 , nvl(com_api_i18n_pkg.get_text('COM_COMPANY','DESCRIPTION', s.object_id, l_lang),
                       com_api_i18n_pkg.get_text('COM_COMPANY','LABEL', s.object_id, l_lang)) company_description
                 , com_ui_person_pkg.get_person_name(h.person_id, l_lang) as person_name
              from iss_card c
                 , iss_card_instance i
                 , iss_card_number_vw n
                 , ost_agent a
                 , prd_customer s
                 , iss_cardholder h
             where c.id = i.card_id
               and c.id = n.card_id
               and c.cardholder_id = h.id
               and i.agent_id = a.id
               and c.customer_id = s.id
               and (l_inst_id = 0 or i.inst_id = l_inst_id)
               and (l_agent_id = 0 or i.agent_id = l_agent_id)
               and i.iss_date between l_start_date and l_end_date
            );

    end;

    select
        xmlelement (
            "report"
            , get_header(l_inst_id, l_agent_id, l_start_date, l_end_date, l_lang)
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'iss_api_report_pkg.register_card_by_agent - ok'
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end;

procedure register_pin_by_agent(
    o_xml                             out clob
    , i_inst_id                    in     com_api_type_pkg.t_inst_id
    , i_agent_id                   in     com_api_type_pkg.t_agent_id      default null
    , i_start_date                 in     date
    , i_end_date                   in     date
    , i_lang                       in     com_api_type_pkg.t_dict_value
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_agent_id                     com_api_type_pkg.t_agent_id;
    l_start_date                   date;
    l_end_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_detail                       xmltype;
    l_result                       xmltype;
begin
    trc_log_pkg.debug (
        i_text          => 'iss_api_report_pkg.register_pin_by_agent [#1][#2][#3][#4]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => i_agent_id
        , i_env_param3  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
        , i_env_param4  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id := nvl(i_inst_id, 0);
    l_agent_id := nvl(i_agent_id, 0);

    -- details
    begin
      
        select 
            case when count(1) = 0 then          
                xmlelement ("cards"
                    , xmlelement("card", null)
                    )
            else
                xmlelement ("cards"
                     , xmlagg(
                         xmlelement("card"
                             , xmlelement("inst_id", inst_id)
                             , xmlelement("inst", inst)
                             , xmlelement("agent_id", agent_id)
                             , xmlelement("agent", agent)
                             , xmlelement("card_number", card_number)
                             , xmlelement("company", company)
                             , xmlelement("company_description", company_description)
                             , xmlelement("person_name", person_name)
                         )
                         order by inst
                                , agent
                                , card_number
                     )
                )
            end 
        into
            l_detail
        from(
            select coalesce(c.card_mask, iss_api_card_pkg.get_card_mask(n.card_number)) card_number
                 , i.agent_id
                 , com_api_i18n_pkg.get_text('OST_AGENT','NAME', i.agent_id, l_lang) as agent
                 , i.inst_id
                 , com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', i.inst_id, l_lang) as inst
                 , case when s.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY then (select m.embossed_name from com_company m where m.id = s.object_id)
                        else null
                   end company
                 , nvl(com_api_i18n_pkg.get_text('COM_COMPANY','DESCRIPTION', s.object_id, l_lang),
                       com_api_i18n_pkg.get_text('COM_COMPANY','LABEL', s.object_id, l_lang)) company_description
                 , com_ui_person_pkg.get_person_name(h.person_id, l_lang) as person_name
              from iss_card c
                 , iss_card_instance i
                 , iss_card_number_vw n
                 , ost_agent a
                 , prd_customer s
                 , iss_cardholder h
                 , prs_batch b
                 , prs_batch_card bc
             where c.id = i.card_id
               and c.id = n.card_id
               and c.cardholder_id = h.id
               and i.agent_id = a.id
               and c.customer_id = s.id
               and bc.card_instance_id = i.id
               and bc.batch_id = b.id
               and (l_inst_id = 0 or i.inst_id = l_inst_id)
               and (l_agent_id = 0 or i.agent_id = l_agent_id)
               and b.status_date between l_start_date and l_end_date
               and bc.pin_mailer_printed = 1
            );

    end;

    select
        xmlelement (
            "report"
            , get_header(l_inst_id, l_agent_id, l_start_date, l_end_date, l_lang)
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'iss_api_report_pkg.register_pin_by_agent - ok'
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end;

procedure unconfirmed_auth_by_inst(
    o_xml                             out clob
    , i_inst_id                    in     com_api_type_pkg.t_inst_id       default null
    , i_lang                       in     com_api_type_pkg.t_dict_value
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_result                       xmltype;
    l_detail                       xmltype;
    l_lang                         com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug (
        i_text          => 'iss_api_report_pkg.unconfirmed_auth_by_inst [#1]'
        , i_env_param1  => i_inst_id
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_inst_id := nvl(i_inst_id, 0);

    -- details
    begin
        select
            case when count(1) = 0 then          
                xmlelement ("amounts"
                    , xmlelement("amount", null)
                    )        
            else        
                xmlelement("amounts"
                        , xmlagg(
                            xmlelement("amount"
                                , xmlelement("inst_id", inst_id)
                                , xmlelement("currency", currency)
                                , xmlelement("amount", com_api_currency_pkg.get_amount_str(nvl(amount, 0), currency, com_api_type_pkg.TRUE))
                                , xmlelement("cur_date", to_char(cur_date, 'yyyy.mm.dd hh24:mi:ss'))
                            )
                            order by currency
                                   , inst_id
                        )
                    )
            end        
        into
            l_detail
        from(
            select a.inst_id
                 , b.currency
                 , sum(b.balance) as amount
                 , get_sysdate() as cur_date
              from acc_balance b
                 , acc_account a
             where b.balance_type = acc_api_const_pkg.BALANCE_TYPE_HOLD
               and b.account_id = a.id
               and (l_inst_id = 0 or a.inst_id = l_inst_id)
             group by b.currency
                 , a.inst_id
             order by b.currency
                    , a.inst_id
               );

    end;

    select
        xmlelement (
            "report"
            , get_header(l_inst_id, null, null, null, l_lang)
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'iss_api_report_pkg.unconfirmed_auth_by_inst - ok'
    );
end;

procedure issued_card_by_company(
    o_xml                             out clob
    , i_inst_id                    in     com_api_type_pkg.t_inst_id       default null
    , i_company_id                 in     com_api_type_pkg.t_agent_id      default null
    , i_start_date                 in     date
    , i_end_date                   in     date
    , i_lang                       in     com_api_type_pkg.t_dict_value
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_company_id                   com_api_type_pkg.t_agent_id;
    l_start_date                   date;
    l_end_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_object_id                    com_api_type_pkg.t_agent_id;
    l_header                       xmltype;
    l_detail                       xmltype;
    l_result                       xmltype;
    l_logo_path                    xmltype;      
begin
    trc_log_pkg.debug (
        i_text          => 'iss_api_report_pkg.issued_card_by_company [#1][#2][#3][#4]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => i_company_id
        , i_env_param3  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
        , i_env_param4  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id := nvl(i_inst_id, 0);
    l_company_id := nvl(i_company_id, 0);

    select min(c.object_id)
        into l_object_id
        from prd_customer c
    where c.id = l_company_id;

    -- header
    l_logo_path := rpt_api_template_pkg.logo_path_xml;
    select
        xmlconcat(
            xmlelement("inst_id", l_inst_id)
            , l_logo_path
            , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
            , xmlelement("company", com_api_i18n_pkg.get_text('COM_COMPANY','LABEL', l_object_id, l_lang))
            , xmlelement("start_date", to_char(l_start_date, 'dd.mm.yyyy'))
            , xmlelement("end_date", to_char(l_end_date, 'dd.mm.yyyy'))
        )
    into
        l_header
            from dual;

    -- details
    begin
        select
            case when count(1) = 0 then          
                xmlelement ("cards"
                    , xmlelement("card", null)
                    )        
            else   
                xmlelement("cards"
                    , xmlagg(
                        xmlelement("card"
                            , xmlelement("inst_id", inst_id)
                            , xmlelement("inst", inst)
                            , xmlelement("company_id", company_id)
                            , xmlelement("company", company)
                            , xmlelement("account_number", account_number)
                            , xmlelement("card_number", card_number)
                            , xmlelement("expir_date", to_char(expir_date, 'dd.mm.yyyy'))
                            , xmlelement("card_status", status)
                            , xmlelement("person_name", person_name)
                        )
                        order by inst
                               , company
                               , account_number
                               , card_number
                    )
               )
            end   
        into
            l_detail
        from(
            select i.inst_id
                 , com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', i.inst_id, l_lang) as inst
                 , cs.id company_id
                 , com_api_i18n_pkg.get_text('COM_COMPANY','LABEL', cs.object_id, l_lang) as company
                 , ac.account_number
                 , coalesce(c.card_mask, iss_api_card_pkg.get_card_mask(n.card_number)) card_number
                 , i.expir_date
                 , com_api_i18n_pkg.get_text('COM_DICTIONARY','NAME', d.id, l_lang) status --i.status
                 , com_ui_person_pkg.get_person_name(ch.person_id, l_lang) as person_name
              from iss_card c
                 , iss_card_instance i
                 , iss_card_number_vw n
                 , iss_cardholder ch
                 , acc_account_object o
                 , acc_account ac
                 , prd_customer cs
                 , com_dictionary d
             where c.id = i.card_id
               and c.id = n.card_id
               and c.id = o.object_id
               and c.customer_id = cs.id
               and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and o.account_id = ac.id
               and c.cardholder_id = ch.id
               and d.dict = substr(i.status, 1, 4)
               and d.code = substr(i.status, 5, 4)
               and (l_inst_id = 0 or i.inst_id = l_inst_id)
               and (l_company_id = 0 or cs.id = l_company_id)
               and i.iss_date between l_start_date and l_end_date
            );
    
    end;
    select
        xmlelement (
            "report"
            , l_header
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'iss_api_report_pkg.issued_card_by_company - ok'
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end;

procedure expired_card(
    o_xml                             out clob
    , i_inst_id                    in     com_api_type_pkg.t_inst_id       default null
    , i_agent_id                   in     com_api_type_pkg.t_agent_id      default null
    , i_start_date                 in     date
    , i_end_date                   in     date
    , i_lang                       in     com_api_type_pkg.t_dict_value
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_agent_id                     com_api_type_pkg.t_agent_id;
    l_start_date                   date;
    l_end_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_detail                       xmltype;
    l_result                       xmltype;
begin
    trc_log_pkg.debug (
        i_text          => 'iss_api_report_pkg.expired_card [#1][#2][#3][#4]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => i_agent_id
        , i_env_param3  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
        , i_env_param4  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id := nvl(i_inst_id, 0);
    l_agent_id := nvl(i_agent_id, 0);

    -- details
    begin
        select
            case when count(1) = 0 then          
                xmlelement ("cards"
                    , xmlelement("card", null)
                    )        
            else           
                xmlelement("cards"
                        , xmlagg(
                            xmlelement("card"
                                , xmlelement("inst_id", inst_id)
                                , xmlelement("inst", inst)
                                , xmlelement("agent_id", agent_id)
                                , xmlelement("agent", agent)
                                , xmlelement("account_number", account_number)
                                , xmlelement("card_number", card_number)
                                , xmlelement("expir_date", to_char(expir_date, 'dd.mm.yyyy'))
                                , xmlelement("status", status)
                                , xmlelement("cardholder_id", cardholder_id)
                                , xmlelement("currency", currency_name)
                                , xmlelement("company", company)
                                , xmlelement("person_name", person_name)
                                , xmlelement("balance", com_api_currency_pkg.get_amount_str(nvl(balance, 0), currency_code, com_api_type_pkg.TRUE))
                            )
                            order by inst
                                   , agent
                                   , account_number
                                   , card_number
                        )
                    )
            end        
        into
            l_detail
        from(
            select i.inst_id
                 , com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', i.inst_id, l_lang) as inst
                 , i.agent_id
                 , com_api_i18n_pkg.get_text('OST_AGENT','NAME', i.agent_id, l_lang) as agent
                 , a.account_number
                 , coalesce(c.card_mask, iss_api_card_pkg.get_card_mask(n.card_number)) card_number
                 , i.expir_date
                 , com_api_i18n_pkg.get_text('COM_DICTIONARY','NAME', d.id, l_lang) status --i.status
                 , c.cardholder_id
                 , y.code as currency_code
                 , y.name as currency_name
                 , com_api_i18n_pkg.get_text('COM_COMPANY','LABEL', s.object_id, l_lang) company
                 , com_ui_person_pkg.get_person_name(h.person_id, l_lang) as person_name
                 , b.balance
              from iss_card c
                 , iss_card_instance i
                 , iss_card_number_vw n
                 , iss_cardholder h
                 , acc_account_object o
                 , acc_account a
                 , acc_balance b
                 , prd_customer s
                 , com_currency y
                 , com_dictionary d
             where c.id = i.card_id
               and c.id = n.card_id
               and c.id = o.object_id
               and c.cardholder_id = h.id
               and a.id = o.account_id
               and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and a.id = b.account_id
               and b.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and c.customer_id = s.id
               and a.currency = y.code
               and d.dict = substr(i.status, 1, 4)
               and d.code = substr(i.status, 5, 4)
               and i.expir_date between l_start_date and l_end_date
               and (l_inst_id = 0 or i.inst_id = l_inst_id)
               and (l_agent_id = 0 or i.agent_id = l_agent_id)
            );

    end;

    select
        xmlelement (
            "report"
            , get_header(l_inst_id, l_agent_id, l_start_date, l_end_date, l_lang)
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'iss_api_report_pkg.expired_card - ok'
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end;

procedure average_balance(
    o_xml                             out clob
    , i_inst_id                    in     com_api_type_pkg.t_inst_id       default null
    , i_agent_id                   in     com_api_type_pkg.t_agent_id      default null
    , i_company_id                 in     com_api_type_pkg.t_agent_id      default null
    , i_cardholder_number          in     com_api_type_pkg.t_name          default null
    , i_start_date                 in     date
    , i_end_date                   in     date
    , i_lang                       in     com_api_type_pkg.t_dict_value
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_agent_id                     com_api_type_pkg.t_agent_id;
    l_company_id                   com_api_type_pkg.t_agent_id;
    l_object_id                    com_api_type_pkg.t_agent_id;
    l_cardholder_number            com_api_type_pkg.t_name;
    l_start_date                   date;
    l_end_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_header                       xmltype;
    l_detail                       xmltype;
    l_result                       xmltype;
    l_logo_path                    xmltype;     
begin
    trc_log_pkg.debug (
        i_text          => 'iss_api_report_pkg.average_balance [#1][#2][#3][#4]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => i_agent_id
        , i_env_param3  => i_company_id
        , i_env_param4  => i_cardholder_number
        , i_env_param5  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
        , i_env_param6  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id := nvl(i_inst_id, 0);
    l_agent_id := nvl(i_agent_id, 0);
    l_company_id := nvl(i_company_id, 0);
    l_cardholder_number := nvl(i_cardholder_number, '0');

    select nvl(min(c.object_id), 0)
        into l_object_id
        from prd_customer c
    where c.id = l_company_id;

    -- header
    l_logo_path := rpt_api_template_pkg.logo_path_xml;
    select
        xmlconcat(
            xmlelement("inst_id", l_inst_id)
            , l_logo_path
            , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
            , xmlelement("agent_id", l_agent_id)
            , xmlelement("agent", com_api_i18n_pkg.get_text('OST_AGENT','NAME', l_agent_id, l_lang))
            , xmlelement("company_id", l_object_id)
            , xmlelement("company", com_api_i18n_pkg.get_text('COM_COMPANY','LABEL', l_object_id, l_lang))
            , xmlelement("cardholder_id", l_cardholder_number)
            , xmlelement("start_date", to_char(l_start_date, 'dd.mm.yyyy'))
            , xmlelement("end_date", to_char(l_end_date, 'dd.mm.yyyy'))
        )
    into
        l_header
            from dual;

    -- details
    begin
        select
            case when count(1) = 0 then          
                xmlelement ("cards"
                    , xmlelement("card", null)
                    )        
            else  
                xmlelement("cards"
                  , xmlagg(
                        xmlelement("card"
                          , xmlelement("inst_id", inst_id)
                          , xmlelement("inst", inst)
                          , xmlelement("agent_id", agent_id)
                          , xmlelement("agent", agent)
                          , xmlelement("company", company)
                          , xmlelement("account_id", account_id)
                          , xmlelement("account_number", account_number)
                          , xmlelement("card_number", card_number)
                          , xmlelement("expir_date", to_char(expir_date, 'dd.mm.yyyy'))
                          , xmlelement("cardholder_id", cardholder_number)
                          , xmlelement("currency_code", currency_code)
                          , xmlelement("currency", currency)
                          , xmlelement("person_name", person_name)
                          , xmlelement("dt_amount", com_api_currency_pkg.get_amount_str(nvl(dt_amount, 0), currency_code, com_api_type_pkg.TRUE))
                          , xmlelement("ct_amount", com_api_currency_pkg.get_amount_str(nvl(ct_amount, 0), currency_code, com_api_type_pkg.TRUE))
                          , xmlelement("avg_balance", com_api_currency_pkg.get_amount_str(nvl(avg_balance, 0), currency_code, com_api_type_pkg.TRUE))
                        )
                        order by
                            inst
                          , currency_code
                          , agent
                          , cardholder_number
                          , account_number
                          , company
                          , card_number
                          , expir_date
                          , person_name
                    )
                )
            end   
        into
            l_detail
        from (
            select com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', b.inst_id, l_lang) as inst
                 , com_api_i18n_pkg.get_text('OST_AGENT','NAME', b.agent_id, l_lang) as agent
                 , com_api_i18n_pkg.get_text('COM_COMPANY','LABEL', b.object_id, l_lang) company
                 , com_ui_person_pkg.get_person_name(b.person_id, l_lang) as person_name
                 , b.*
                from (
                    select i.inst_id
                         , i.agent_id
                         , s.object_id
                         , a.id account_id
                         , a.account_number
                         , iss_api_token_pkg.decode_card_number(i_card_number => n.card_number) as card_number
                         , i.expir_date
                         , h.cardholder_number
                         , y.code currency_code
                         , y.name currency
                         , h.person_id
                         , round(sum(case when e.balance_impact = -1 then e.amount else 0 end)/case when sum(case when e.balance_impact = -1 then 1 else 0 end) = 0 then 1 else sum(case when e.balance_impact = -1 then 1 else 0 end) end, 2) dt_amount
                         , round(sum(case when e.balance_impact = 1 then e.amount else 0 end)/case when sum(case when e.balance_impact = 1 then 1 else 0 end) = 0 then 1 else sum(case when e.balance_impact = 1 then 1 else 0 end) end, 2)  ct_amount
                         , round(avg(e.balance), 2) avg_balance
                      from iss_card c
                         , iss_card_instance i
                         , iss_card_number n
                         , iss_cardholder h
                         , acc_account_object o
                         , acc_account a
                         , acc_entry e
                         , com_currency y
                         , prd_customer s
                     where c.id = i.card_id
                       and c.id = n.card_id
                       and c.id = o.object_id
                       and c.cardholder_id = h.id
                       and c.customer_id = s.id
                       and a.id = o.account_id
                       and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                       and a.id = e.account_id
                       and a.currency = y.code
                       and e.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
                       and e.posting_date between l_start_date and l_end_date
                       and e.id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
                       and (l_inst_id = 0 or i.inst_id = l_inst_id)
                       and (l_agent_id = 0 or i.agent_id = l_agent_id)
                       and (l_company_id = 0 or s.id = l_company_id)
                       and (l_cardholder_number = '0' or h.cardholder_number = l_cardholder_number)
                     group by i.inst_id
                         , i.agent_id
                         , s.object_id
                         , a.id
                         , a.account_number
                         , n.card_number
                         , i.expir_date
                         , h.cardholder_number
                         , y.code
                         , y.name
                         , h.person_id
                ) b
            );

    exception
        when no_data_found then
            select
                xmlelement("cards", '')
            into
                l_detail
            from
                dual;

            trc_log_pkg.debug (
                i_text  => 'Cards not found'
            );
    end;

    select
        xmlelement (
            "report"
            , l_header
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();


    trc_log_pkg.debug (
         i_text => 'iss_api_report_pkg.average_balance - ok'
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end;

procedure card_balances(
    o_xml                             out clob
    , i_inst_id                    in     com_api_type_pkg.t_inst_id       default null
    , i_lang                       in     com_api_type_pkg.t_dict_value
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_result                       xmltype;
    l_detail                       xmltype;
    l_lang                         com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug (
        i_text          => 'iss_api_report_pkg.card_balances [#1]'
        , i_env_param1  => i_inst_id
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_inst_id := nvl(i_inst_id, 0);

    -- details
    begin
        select
            case when count(1) = 0 then          
                xmlelement ("balances"
                    , xmlelement("balance", null)
                    )        
            else          
                xmlelement("balances"
                        , xmlagg(
                            xmlelement("balance"
                                , xmlelement("inst_id", inst_id)
                                , xmlelement("inst", inst)
                                , xmlelement("agent_id", agent_id)
                                , xmlelement("agent", agent)
                                , xmlelement("account_number", account_number)
                                , xmlelement("card_number", card_number)
                                , xmlelement("expir_date", to_char(expir_date, 'dd.mm.yyyy'))
                                , xmlelement("status", status)
                                , xmlelement("currency", currency_name)
                                , xmlelement("cardholder_name", cardholder_name)
                                , xmlelement("ledger_balance", com_api_currency_pkg.get_amount_str(nvl(ledger_balance, 0), currency_code, com_api_type_pkg.TRUE))
                                , xmlelement("hold_balance", com_api_currency_pkg.get_amount_str(nvl(hold_balance, 0), currency_code, com_api_type_pkg.TRUE))
                                , xmlelement("overdraft_amount", com_api_currency_pkg.get_amount_str(nvl(overdraft_amount, 0), currency_code, com_api_type_pkg.TRUE))
                                , xmlelement("disput_amount", com_api_currency_pkg.get_amount_str(nvl(disput_amount, 0), currency_code, com_api_type_pkg.TRUE))
                                , xmlelement("frozen_amount", com_api_currency_pkg.get_amount_str(nvl(frozen_amount, 0), currency_code, com_api_type_pkg.TRUE))
                                , xmlelement("available_balance", com_api_currency_pkg.get_amount_str(nvl(available_balance, 0), currency_code, com_api_type_pkg.TRUE))
                            )
                            order by inst_id
                                   , agent_id
                                   , card_number
                        )
                    )
            end        
        into
            l_detail
        from(
            select com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', b.inst_id, l_lang) as inst
                 , com_api_i18n_pkg.get_text('OST_AGENT','NAME', b.agent_id, l_lang) as agent
                 , com_api_dictionary_pkg.get_article_text(b.status_card, l_lang) status
                 , b.*
                from(
                    select i.inst_id
                         , i.agent_id
                         , a.account_number
                         , coalesce(c.card_mask, iss_api_card_pkg.get_card_mask(n.card_number)) as card_number
                         , i.expir_date
                         , i.status status_card
                         , y.code as currency_code
                         , y.name as currency_name
                         , h.cardholder_name
                         , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER then b.balance
                                    else 0
                               end) ledger_balance
                         , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_HOLD then b.balance
                                    else 0
                               end) hold_balance
                         , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT then b.balance
                                    else 0
                               end) overdraft_amount
                         , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_DISPUTE then b.balance
                                    else 0
                               end) disput_amount
                         , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_FROZEN then b.balance
                                    else 0
                               end) frozen_amount
                         , (acc_api_balance_pkg.get_aval_balance_amount_only (a.id, get_sysdate(), com_api_const_pkg.DATE_PURPOSE_PROCESSING, 0)) available_balance
                      from iss_card c
                         , iss_card_instance i
                         , iss_card_number n
                         , iss_cardholder h
                         , acc_account_object o
                         , acc_account a
                         , com_currency y
                         , acc_balance b
                     where c.id = i.card_id
                       and c.id = n.card_id
                       and c.id = o.object_id
                       and c.cardholder_id = h.id
                       and a.id = o.account_id
                       and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                       and a.currency = y.code
                       and a.id = b.account_id
                       and a.inst_id = b.inst_id
                       and (l_inst_id = 0 or i.inst_id = l_inst_id)
                  group by i.inst_id
                         , i.agent_id
                         , a.account_number
                         , coalesce(c.card_mask, iss_api_card_pkg.get_card_mask(n.card_number))
                         , i.expir_date
                         , y.code
                         , y.name
                         , h.cardholder_name
                         , a.id
                         , i.status
                 ) b
         );

    end;

    select
        xmlelement (
            "report"
            , get_header(l_inst_id, null, null, null, l_lang)
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'iss_api_report_pkg.card_balances - ok'
    );
end;

procedure active_cards(
    o_xml                             out clob
    , i_inst_id                    in     com_api_type_pkg.t_inst_id       default null
    , i_start_date                 in     date
    , i_end_date                   in     date
    , i_lang                       in     com_api_type_pkg.t_dict_value
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_start_date                   date;
    l_end_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_detail                       xmltype;
    l_result                       xmltype;
begin
    trc_log_pkg.debug (
        i_text          => 'iss_api_report_pkg.active_cards [#1][#2][#3]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
        , i_env_param3  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id := nvl(i_inst_id, 0);

    -- details
    begin
        select
            case when count(1) = 0 then          
                xmlelement ("cards"
                    , xmlelement("card", null)
                    )        
            else             
                xmlelement("cards"
                        , xmlagg(
                            xmlelement("card"
                                , xmlelement("inst_id", inst_id)
                                , xmlelement("inst", inst)
                                , xmlelement("card_number", card_number)
                                , xmlelement("expir_date", to_char(expir_date, 'dd.mm.yyyy'))
                                , xmlelement("person_name", person_name)
                                , xmlelement("account_number", account_number)
                                , xmlelement("currency", currency_name)
                                , xmlelement("ledger_balance", com_api_currency_pkg.get_amount_str(nvl(ledger_balance, 0), currency_code, com_api_type_pkg.TRUE))
                                , xmlelement("hold_balance", com_api_currency_pkg.get_amount_str(nvl(hold_balance, 0), currency_code, com_api_type_pkg.TRUE))
                                , xmlelement("overdraft_amount", com_api_currency_pkg.get_amount_str(nvl(overdraft_amount, 0), currency_code, com_api_type_pkg.TRUE))
                                , xmlelement("disput_amount", com_api_currency_pkg.get_amount_str(nvl(disput_amount, 0), currency_code, com_api_type_pkg.TRUE))
                                , xmlelement("frozen_amount", com_api_currency_pkg.get_amount_str(nvl(frozen_amount, 0), currency_code, com_api_type_pkg.TRUE))
                                , xmlelement("available_balance", com_api_currency_pkg.get_amount_str(nvl(available_balance, 0), currency_code, com_api_type_pkg.TRUE))
                            )
                            order by inst
                                   , card_number
                        )
                    )
            end        
        into
            l_detail
        from(
            select com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', b.inst_id, l_lang) as inst
                 , com_ui_person_pkg.get_person_name(b.person_id, l_lang) as person_name
                 , b.*
                 from (
                    select i.inst_id
                         , a.account_number
                         , coalesce(c.card_mask, iss_api_card_pkg.get_card_mask(n.card_number)) as card_number
                         , i.expir_date
                         , y.code as currency_code
                         , y.name as currency_name
                         , h.person_id
                         , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER then b.balance
                                    else 0
                               end) ledger_balance
                         , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_HOLD then b.balance
                                    else 0
                               end) hold_balance
                         , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT then b.balance
                                    else 0
                               end) overdraft_amount
                         , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_DISPUTE then b.balance
                                    else 0
                               end) disput_amount
                         , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_FROZEN then b.balance
                                    else 0
                               end) frozen_amount
                         , (acc_api_balance_pkg.get_aval_balance_amount_only (a.id, get_sysdate(), com_api_const_pkg.DATE_PURPOSE_PROCESSING, 0)) available_balance
                         , a.id
                      from iss_card c
                         , iss_card_instance i
                         , iss_card_number n
                         , iss_cardholder h
                         , acc_account_object o
                         , acc_account a
                         , com_currency y
                         , acc_balance b
                     where c.id = i.card_id
                       and c.id = n.card_id
                       and c.id = o.object_id
                       and c.cardholder_id = h.id
                       and a.id = o.account_id
                       and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                       and a.currency = y.code
                       and a.id = b.account_id
                       and a.inst_id = b.inst_id
                       and (l_inst_id = 0 or i.inst_id = l_inst_id)
                       and i.expir_date between l_start_date and l_end_date
                       and i.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
                     group by
                           i.inst_id
                         , a.account_number
                         , coalesce(c.card_mask, iss_api_card_pkg.get_card_mask(n.card_number))
                         , i.expir_date
                         , y.code
                         , y.name
                         , h.person_id
                         , a.id
                    ) b
                where b.ledger_balance > 0
            );

    exception
        when no_data_found then
            select
                xmlelement("cards", '')
            into
                l_detail
            from
                dual;

            trc_log_pkg.debug (
                i_text  => 'Cards not found'
            );
    end;

    select
        xmlelement (
            "report"
            , get_header(l_inst_id, l_start_date, l_end_date, l_lang)
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'iss_api_report_pkg.active_cards - ok'
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end;

procedure reissued_cards(
    o_xml                           out clob
  , i_inst_id                    in     com_api_type_pkg.t_inst_id       default null
  , i_agent_id                   in     com_api_type_pkg.t_agent_id      default null
  , i_start_date                 in     date
  , i_end_date                   in     date
  , i_lang                       in     com_api_type_pkg.t_dict_value
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_start_date                   date;
    l_end_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_detail                       xmltype;
    l_result                       xmltype;
    l_agent_id                     com_api_type_pkg.t_agent_id;
begin
    trc_log_pkg.debug(
        i_text          => 'iss_api_report_pkg.reissued_cards [#1][#2][#3][#4]'
      , i_env_param1    => i_inst_id
      , i_env_param2    => i_agent_id
      , i_env_param3    => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
      , i_env_param4    => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id :=nvl(i_inst_id, 0);
    l_agent_id := nvl(i_agent_id, 0);

    -- details
    begin
        select xmlelement("cards"
                 , xmlagg(
                       xmlelement("card"
                         , xmlelement("inst_id", inst_id)
                         , xmlelement("inst", inst)
                         , xmlelement("agent_id", agent_id)
                         , xmlelement("agent", agent)
                         , xmlelement("account_number", account_number)
                         , xmlelement("card_number", card_number)
                         , xmlelement("expir_date", to_char(expir_date, 'dd.mm.yyyy'))
                         , xmlelement("status", status)
                         , xmlelement("cardholder_id", cardholder_id)
                         , xmlelement("currency", currency_name)
                         , xmlelement("ledger_balance", com_api_currency_pkg.get_amount_str(nvl(ledger_balance, 0), currency_code, com_api_type_pkg.TRUE))
                         , xmlelement("company", company)
                         , xmlelement("person_name", person_name)
                       )
                       order by inst
                              , agent
                              , account_number
                              , card_number
                   )
               )
          into l_detail
          from ( select i.inst_id
                      , com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', i.inst_id, l_lang) as inst
                      , i.agent_id
                      , com_api_i18n_pkg.get_text('OST_AGENT','NAME', i.agent_id, l_lang) as agent
                      , a.account_number
                      , coalesce(c.card_mask, iss_api_card_pkg.get_card_mask(n.card_number)) card_number
                      , i.expir_date
                      , com_api_i18n_pkg.get_text('COM_DICTIONARY','NAME', d.id, l_lang) status
                      , c.cardholder_id
                      , y.code as currency_code
                      , y.name as currency_name
                      , b.balance ledger_balance
                      , case when s.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY then (select m.embossed_name from com_company m where m.id = s.object_id)
                            else null
                        end company
                      , com_ui_person_pkg.get_person_name(h.person_id, l_lang) as person_name
                      , a.id
                   from iss_card c
                      , iss_card_instance i
                      , iss_card_number_vw n
                      , iss_cardholder h
                      , acc_account_object o
                      , acc_account a
                      , com_currency y
                      , acc_balance b
                      , com_dictionary d
                      , prd_customer s
                  where c.id = i.card_id
                    and c.id = n.card_id
                    and c.id = o.object_id
                    and c.cardholder_id = h.id
                    and a.id = o.account_id
                    and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                    and a.currency = y.code
                    and a.id = b.account_id
                    and a.inst_id = b.inst_id
                    and (l_inst_id = 0 or i.inst_id = l_inst_id)
                    and i.iss_date between l_start_date and l_end_date
                    and b.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
                    and (i.seq_number > 1 or i.preceding_card_instance_id is not null)
                    and d.dict = substr(i.status, 1, 4)
                    and d.code = substr(i.status, 5, 4)
                    and c.customer_id = s.id
                    and (l_agent_id = 0 or i.agent_id = l_agent_id)
               );

    exception
        when no_data_found then
            select xmlelement("cards", '')
              into l_detail
              from dual;

            trc_log_pkg.debug(
                i_text  => 'Cards not found'
            );
    end;

    select xmlelement(
               "report"
             , get_header(l_inst_id, l_agent_id, l_start_date, l_end_date, l_lang)
             , l_detail
           ) r
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(
        i_text => 'iss_api_report_pkg.reissued_cards - ok'
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text   => sqlerrm
        );
        raise;
end;

procedure cards_exceed_limit(
    o_xml                             out clob
    , i_inst_id                    in     com_api_type_pkg.t_inst_id       default null
    , i_agent_id                   in     com_api_type_pkg.t_agent_id      default null
    , i_lang                       in     com_api_type_pkg.t_dict_value
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_agent_id                     com_api_type_pkg.t_agent_id;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_header                       xmltype;
    l_detail                       xmltype;
    l_result                       xmltype;
begin
    trc_log_pkg.debug (
        i_text          => 'iss_api_report_pkg.cards_exceed_limit [#1][#2]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => i_agent_id
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_inst_id := nvl(i_inst_id, 0);
    l_agent_id := nvl(i_agent_id, 0);

    -- header
    select
        xmlconcat(
            xmlelement("inst_id", l_inst_id)
            , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
            , xmlelement("agent_id", l_agent_id)
            , xmlelement("agent", com_api_i18n_pkg.get_text('OST_AGENT','NAME', l_agent_id, l_lang))
        )
    into
        l_header
            from dual;

    -- details
    begin
        select
            xmlelement("cards"
              , xmlagg(
                    xmlelement("card"
                      , xmlelement("inst_id", inst_id)
                      , xmlelement("inst", inst)
                      , xmlelement("agent_id", agent_id)
                      , xmlelement("agent", agent)
                      , xmlelement("card_number", card_number)
                      , xmlelement("expir_date", to_char(expir_date, 'dd.mm.yyyy'))
                      , xmlelement("status", status)
                      , xmlelement("cardholder_name", cardholder_name)
                      , xmlelement("account_number", account_number)
                      , xmlelement("currency", currency_name)
                      , xmlelement("available_balance", com_api_currency_pkg.get_amount_str(nvl(available_balance, 0), currency_code, com_api_type_pkg.TRUE))
                      , xmlelement("ledger_balance", com_api_currency_pkg.get_amount_str(nvl(ledger_balance, 0), currency_code, com_api_type_pkg.TRUE))
                      , xmlelement("hold_balance", com_api_currency_pkg.get_amount_str(nvl(hold_balance, 0), currency_code, com_api_type_pkg.TRUE))
                      , xmlelement("overdraft_amount", com_api_currency_pkg.get_amount_str(nvl(overdraft_amount, 0), currency_code, com_api_type_pkg.TRUE))
                      , xmlelement("disput_amount", com_api_currency_pkg.get_amount_str(nvl(disput_amount, 0), currency_code, com_api_type_pkg.TRUE))
                      , xmlelement("frozen_amount", com_api_currency_pkg.get_amount_str(nvl(frozen_amount, 0), currency_code, com_api_type_pkg.TRUE))
                      , xmlelement("person_name", person_name)
                    )
                    order by
                        inst
                      , agent
                      , card_number
                )
            )
        into
            l_detail
        from (
            select com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', b.inst_id, l_lang) as inst
                 , com_api_i18n_pkg.get_text('OST_AGENT','NAME', b.agent_id, l_lang) as agent
                 , com_api_dictionary_pkg.get_article_text(b.status_card, l_lang) status
                 , com_ui_person_pkg.get_person_name(b.person_id, l_lang) as person_name
                 , b.*
              from (
                  select i.inst_id
                       , i.agent_id
                       , a.account_number
                       , coalesce(c.card_mask, iss_api_card_pkg.get_card_mask(n.card_number)) as card_number
                       , i.expir_date
                       , i.status status_card
                       , y.code as currency_code
                       , y.name as currency_name
                       , h.cardholder_name
                       , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER then b.balance
                                  else 0
                             end) ledger_balance
                       , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_HOLD then b.balance
                                  else 0
                             end) hold_balance
                       , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT then b.balance
                                  else 0
                             end) overdraft_amount
                       , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_DISPUTE then b.balance
                                  else 0
                             end) disput_amount
                       , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_FROZEN then b.balance
                                  else 0
                             end) frozen_amount
                       , (acc_api_balance_pkg.get_aval_balance_amount_only (a.id, get_sysdate(), com_api_const_pkg.DATE_PURPOSE_PROCESSING, 0)) available_balance
                       , h.person_id
                    from iss_card c
                       , iss_card_instance i
                       , iss_card_number n
                       , iss_cardholder h
                       , acc_account_object o
                       , acc_account a
                       , com_currency y
                       , acc_balance b
                   where c.id = i.card_id
                     and c.id = n.card_id
                     and c.id = o.object_id
                     and c.cardholder_id = h.id
                     and a.id = o.account_id
                     and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                     and a.currency = y.code
                     and a.id = b.account_id
                     and a.inst_id = b.inst_id
                     and (l_inst_id = 0 or i.inst_id = l_inst_id)
                     and (l_agent_id = 0 or i.agent_id = l_agent_id)
                group by i.inst_id
                       , i.agent_id
                       , a.account_number
                       , coalesce(c.card_mask, iss_api_card_pkg.get_card_mask(n.card_number))
                       , i.expir_date
                       , y.code
                       , y.name
                       , h.cardholder_name
                       , a.id
                       , h.person_id
                       , i.status
              ) b
             where b.overdraft_amount <> 0
        );

    exception
        when no_data_found then
            select
                xmlelement("cards", '')
            into
                l_detail
            from
                dual;

            trc_log_pkg.debug (
                i_text  => 'Cards not found'
            );
    end;

    select
        xmlelement (
            "report"
            , l_header
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'iss_api_report_pkg.cards_exceed_limit - ok'
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end;

procedure corporate_cards(
    o_xml                             out clob
    , i_inst_id                    in     com_api_type_pkg.t_inst_id       default null
    , i_agent_id                   in     com_api_type_pkg.t_agent_id      default null
    , i_lang                       in     com_api_type_pkg.t_dict_value
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_agent_id                     com_api_type_pkg.t_agent_id;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_header                       xmltype;
    l_detail                       xmltype;
    l_result                       xmltype;

begin
    trc_log_pkg.debug (
        i_text          => 'iss_api_report_pkg.corporate_cards [#1][#2]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => i_agent_id
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_inst_id := nvl(i_inst_id, 0);
    l_agent_id := nvl(i_agent_id, 0);

    -- header
    select
        xmlconcat(
            xmlelement("inst_id", l_inst_id)
            , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
            , xmlelement("agent_id", l_agent_id)
            , xmlelement("agent", com_api_i18n_pkg.get_text('OST_AGENT','NAME', l_agent_id, l_lang))
        )
    into
        l_header
            from dual;

    -- details
    begin
        select
            xmlelement("cards"
                    , xmlagg(
                        xmlelement("card"
                            , xmlelement("inst_id", inst_id)
                            , xmlelement("inst", inst)
                            , xmlelement("agent_id", agent_id)
                            , xmlelement("agent", agent)
                            , xmlelement("card_number", card_number)
                            , xmlelement("expir_date", to_char(expir_date, 'dd.mm.yyyy'))
                            , xmlelement("status", status)
                            , xmlelement("cardholder_name", cardholder_name)
                            , xmlelement("account_number", account_number)
                            , xmlelement("currency", currency_name)
                            , xmlelement("available_balance", com_api_currency_pkg.get_amount_str(nvl(available_balance, 0), currency_code, com_api_type_pkg.TRUE))
                            , xmlelement("ledger_balance", com_api_currency_pkg.get_amount_str(nvl(ledger_balance, 0), currency_code, com_api_type_pkg.TRUE))
                            , xmlelement("hold_balance", com_api_currency_pkg.get_amount_str(nvl(hold_balance, 0), currency_code, com_api_type_pkg.TRUE))
                            , xmlelement("overdraft_amount", com_api_currency_pkg.get_amount_str(nvl(overdraft_amount, 0), currency_code, com_api_type_pkg.TRUE))
                            , xmlelement("disput_amount", com_api_currency_pkg.get_amount_str(nvl(disput_amount, 0), currency_code, com_api_type_pkg.TRUE))
                            , xmlelement("frozen_amount", com_api_currency_pkg.get_amount_str(nvl(frozen_amount, 0), currency_code, com_api_type_pkg.TRUE))
                        )
                        order by inst
                               , agent
                               , card_number
                    )
                )
        into
            l_detail
        from (
            select com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', b.inst_id, l_lang) as inst
                 , com_api_i18n_pkg.get_text('OST_AGENT','NAME', b.agent_id, l_lang) as agent
                 , com_api_dictionary_pkg.get_article_text(b.status_card, l_lang) status
                 , b.*
              from (
                  select i.inst_id
                       , i.agent_id
                       , a.account_number
                       , coalesce(c.card_mask, iss_api_card_pkg.get_card_mask(n.card_number)) as card_number
                       , i.expir_date
                       , i.status status_card
                       , h.cardholder_name
                       , y.code as currency_code
                       , y.name as currency_name
                       , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER then b.balance
                                  else 0
                             end) ledger_balance
                       , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_HOLD then b.balance
                                  else 0
                             end) hold_balance
                       , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT then b.balance
                                  else 0
                             end) overdraft_amount
                       , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_DISPUTE then b.balance
                                  else 0
                             end) disput_amount
                       , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_FROZEN then b.balance
                                  else 0
                             end) frozen_amount
                       , (acc_api_balance_pkg.get_aval_balance_amount_only (a.id, get_sysdate(), com_api_const_pkg.DATE_PURPOSE_PROCESSING, 0)) available_balance
                    from iss_card c
                       , iss_card_instance i
                       , iss_card_number n
                       , iss_cardholder h
                       , acc_account_object o
                       , acc_account a
                       , acc_balance b
                       , com_currency y
                       , prd_customer s
                   where c.id = i.card_id
                     and c.id = n.card_id
                     and c.id = o.object_id
                     and c.cardholder_id = h.id
                     and a.id = o.account_id
                     and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                     and a.id = b.account_id
                     and a.inst_id = b.inst_id
                     and c.customer_id = s.id
                     and s.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
                     and a.currency = y.code
                     and (l_inst_id = 0 or i.inst_id = l_inst_id)
                     and (l_agent_id = 0 or i.agent_id = l_agent_id)
                group by i.inst_id
                       , i.agent_id
                       , a.account_number
                       , coalesce(c.card_mask, iss_api_card_pkg.get_card_mask(n.card_number))
                       , y.code
                       , y.name
                       , i.expir_date
                       , h.cardholder_name
                       , i.status
                       , a.id
              ) b
        );

    exception
        when no_data_found then
            select
                xmlelement("cards", '')
            into
                l_detail
            from
                dual;

            trc_log_pkg.debug (
                i_text  => 'Cards not found'
            );
    end;

    select
        xmlelement (
            "report"
            , l_header
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'iss_api_report_pkg.corporate_cards - ok'
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end;

procedure out_balances_by_cards(
    o_xml                             out clob
    , i_inst_id                    in     com_api_type_pkg.t_inst_id       default null
    , i_agent_id                   in     com_api_type_pkg.t_agent_id      default null
    , i_start_date                 in     date
    , i_lang                       in     com_api_type_pkg.t_dict_value
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_agent_id                     com_api_type_pkg.t_agent_id;
    l_start_date                   date;
    l_tmp_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_header                       xmltype;
    l_detail                       xmltype;
    l_result                       xmltype;
    l_logo_path                    xmltype;        
begin
    trc_log_pkg.debug (
        i_text          => 'iss_api_report_pkg.out_balances_by_cards [#1][#2][#3]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => i_agent_id
        , i_env_param3  => i_start_date
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_inst_id := nvl(i_inst_id, 0);
    l_agent_id := nvl(i_agent_id, 0);
    l_tmp_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_start_date := trunc(l_tmp_date + 1);

    -- header
    l_logo_path := rpt_api_template_pkg.logo_path_xml;       
    select
        xmlconcat(
            xmlelement("inst_id", l_inst_id)
            , l_logo_path
            , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
            , xmlelement("agent_id", l_agent_id)
            , xmlelement("agent", com_api_i18n_pkg.get_text('OST_AGENT','NAME', l_agent_id, l_lang))
            , xmlelement("start_date", to_char(l_tmp_date, 'dd.mm.yyyy'))
        )
    into
        l_header
            from dual;

    -- details
    begin
        select
            case when count(1) = 0 then          
                xmlelement ("amounts"
                    , xmlelement("amount", null)
                    )        
            else   
                xmlelement("amounts"
                        , xmlagg(
                            xmlelement("amount"
                                , xmlelement("inst_id", inst_id)
                                , xmlelement("inst", inst)
                                , xmlelement("agent_id", agent_id)
                                , xmlelement("agent", agent)
                                , xmlelement("currency", currency_name)
                                , xmlelement("amount", com_api_currency_pkg.get_amount_str(nvl(amount, 0), currency_code, com_api_type_pkg.TRUE))
                            )
                            order by inst_id
                                   , agent_id
                                   , currency_name
                        )
                    )
            end        
        into
            l_detail
        from(
            select sum(b.balance - nvl(d.amount, 0)) amount
                 , a.inst_id
                 , com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', a.inst_id, l_lang) as inst
                 , a.agent_id
                 , com_api_i18n_pkg.get_text('OST_AGENT','NAME', a.agent_id, l_lang) as agent
                 , y.code as currency_code
                 , y.name as currency_name
              from acc_account a
                 , acc_balance b
                 , com_currency y
                 , prd_contract c
                 , prd_product p
                 , (select e.account_id
                         , sum(e.balance_impact * (case when a.currency = e.currency then e.amount
                                                    else com_api_rate_pkg.convert_amount(e.amount, e.currency, a.currency, t.rate_type, a.inst_id, e.posting_date)
                                                   end)
                                ) amount
                      from acc_entry e
                         , acc_account a
                         , acc_balance b
                         , acc_balance_type t
                         , prd_contract c
                         , prd_product p
                     where e.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
                       and a.id = e.account_id
                       and a.id = b.account_id
                       and e.balance_type = b.balance_type
                       and t.account_type = a.account_type
                       and t.inst_id = a.inst_id
                       and t.aval_impact != 0
                       and t.balance_type = b.balance_type
                       and a.contract_id = c.id
                       and c.product_id = p.id
                       and p.product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS -- card accounts
                       and e.posting_date > l_start_date
                       and e.id > com_api_id_pkg.get_from_id(l_start_date)
                       and (l_inst_id = 0 or a.inst_id = l_inst_id)
                       and (l_agent_id = 0 or a.agent_id = l_agent_id)
                     group by e.account_id
                    ) d
             where
               a.id = b.account_id
               and b.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and d.account_id(+) = b.account_id
               and b.currency = y.code
               and a.contract_id = c.id
               and c.product_id = p.id
               and p.product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS -- card accounts
               and (l_inst_id = 0 or a.inst_id = l_inst_id)
               and (l_agent_id = 0 or a.agent_id = l_agent_id)
             group by
                   a.inst_id
                 , a.agent_id
                 , y.code
                 , y.name
              );

    end;

    select
        xmlelement (
            "report"
            , l_header
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'iss_api_report_pkg.out_balances_by_cards - ok'
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end;

procedure account_out_balances(
    o_xml                             out clob
    , i_inst_id                    in     com_api_type_pkg.t_inst_id       default null
    , i_agent_id                   in     com_api_type_pkg.t_agent_id      default null
    , i_start_date                 in     date
    , i_lang                       in     com_api_type_pkg.t_dict_value
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_agent_id                     com_api_type_pkg.t_agent_id;
    l_start_date                   date;
    l_tmp_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_header                       xmltype;
    l_detail                       xmltype;
    l_result                       xmltype;
    l_logo_path                    xmltype;      
begin
    trc_log_pkg.debug (
        i_text          => 'iss_api_report_pkg.account_out_balances [#1][#2][#3]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => i_agent_id
        , i_env_param3  => i_start_date
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_inst_id := nvl(i_inst_id, 0);
    l_agent_id := nvl(i_agent_id, 0);
    l_tmp_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_start_date := trunc(l_tmp_date + 1);

    -- header
    l_logo_path := rpt_api_template_pkg.logo_path_xml;      
    select
        xmlconcat(
            xmlelement("inst_id", l_inst_id)
            , l_logo_path
            , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
            , xmlelement("agent_id", l_agent_id)
            , xmlelement("agent", com_api_i18n_pkg.get_text('OST_AGENT','NAME', l_agent_id, l_lang))
            , xmlelement("start_date", to_char(l_tmp_date, 'dd.mm.yyyy'))
        )
    into
        l_header
            from dual;

    -- details
    begin
        select
            case when count(1) = 0 then          
                xmlelement ("accounts"
                    , xmlelement("account", null)
                    )        
            else           
                xmlelement("accounts"
                        , xmlagg(
                            xmlelement("account"
                                , xmlelement("inst_id", inst_id)
                                , xmlelement("inst", inst)
                                , xmlelement("agent_id", agent_id)
                                , xmlelement("agent", agent)
                                , xmlelement("currency", currency_name)
                                , xmlelement("account_number", account_number)
                                , xmlelement("ledger_balance", com_api_currency_pkg.get_amount_str(nvl(ledger_balance, 0), currency_code, com_api_type_pkg.TRUE))
                                , xmlelement("overdraft_balance", com_api_currency_pkg.get_amount_str(nvl(overdraft_balance, 0), currency_code, com_api_type_pkg.TRUE))
                                , xmlelement("person_name", person_name)
                            )
                            order by inst_id
                                   , agent_id
                                   , account_number
                        )
                    )
            end       
        into
            l_detail
        from(
            select a.inst_id
                 , com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', a.inst_id, l_lang) as inst
                 , a.agent_id
                 , com_api_i18n_pkg.get_text('OST_AGENT','NAME', a.agent_id, l_lang) as agent
                 , y.code as currency_code
                 , y.name as currency_name
                 , a.account_number
                 , a.id account_id
                 , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER then b.balance - nvl(d.ledger_balance, 0) else 0 end) ledger_balance
                 , sum(case when b.balance_type = acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT then b.balance - nvl(d.overdraft_balance, 0) else 0 end) overdraft_balance
                 , com_ui_person_pkg.get_person_name(h.person_id, l_lang) as person_name
              from acc_account a
                 , acc_balance b
                 , com_currency y
                 , acc_account_object o
                 , iss_card c
                 , iss_cardholder h
                 , prd_contract ct
                 , prd_product p
                 , (select e.account_id
                         , e.balance_type
                         , sum(case when e.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER then
                                         e.balance_impact * (case when a.currency = e.currency then e.amount
                                                             else com_api_rate_pkg.convert_amount(e.amount, e.currency, a.currency, t.rate_type, a.inst_id, e.posting_date)
                                                             end)
                                    else 0
                               end
                           ) ledger_balance
                         , sum(case when e.balance_type = acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT then
                                         e.balance_impact * (case when a.currency = e.currency then e.amount
                                                             else com_api_rate_pkg.convert_amount(e.amount, e.currency, a.currency, t.rate_type, a.inst_id, e.posting_date)
                                                             end)
                                    else 0
                               end
                           ) overdraft_balance
                      from acc_entry e
                         , acc_account a
                         , acc_balance b
                         , acc_balance_type t
                         , prd_contract c
                         , prd_product p
                     where e.balance_type in (acc_api_const_pkg.BALANCE_TYPE_LEDGER, acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT)
                       and a.id = e.account_id
                       and a.id = b.account_id
                       and e.balance_type = b.balance_type
                       and t.account_type = a.account_type
                       and t.inst_id = a.inst_id
                       and t.aval_impact != 0
                       and t.balance_type = b.balance_type
                       and a.contract_id = c.id
                       and c.product_id = p.id
                       and p.product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS -- card accounts
                       and e.posting_date > l_start_date
                       and e.id > com_api_id_pkg.get_from_id(l_start_date)
                       and (l_inst_id = 0 or a.inst_id = l_inst_id)
                       and (l_agent_id = 0 or a.agent_id = l_agent_id)
                     group by e.account_id
                         , e.balance_type
                    ) d
             where a.id = b.account_id
               and b.account_id = d.account_id(+)
               and b.balance_type = d.balance_type(+)
               and b.balance_type in (acc_api_const_pkg.BALANCE_TYPE_LEDGER, acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT)
               and b.currency = y.code
               and o.account_id = a.id
               and c.id = o.object_id
               and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and c.cardholder_id = h.id
               and a.contract_id = ct.id
               and ct.product_id = p.id
               and p.product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS -- card accounts
               and (l_inst_id = 0 or a.inst_id = l_inst_id)
               and (l_agent_id = 0 or a.agent_id = l_agent_id)
             group by a.inst_id
                 , a.agent_id
                 , y.code
                 , y.name
                 , a.account_number
                 , a.id
                 , h.person_id
             );

    end;

    select
        xmlelement (
            "report"
            , l_header
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'iss_api_report_pkg.account_out_balances - ok'
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end;

procedure financial_transaction (
    o_xml                             out clob
    , i_inst_id                    in     com_api_type_pkg.t_inst_id       default null
    , i_agent_id                   in     com_api_type_pkg.t_agent_id      default null
    , i_start_date                 in     date
    , i_end_date                   in     date
    , i_lang                       in     com_api_type_pkg.t_dict_value
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_agent_id                     com_api_type_pkg.t_agent_id;
    l_start_date                   date;
    l_end_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_detail                       xmltype;
    l_result                       xmltype;
begin
    trc_log_pkg.debug (
        i_text          => 'iss_api_report_pkg.financial_transaction [#1][#2][#3][#4]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => i_agent_id
        , i_env_param3  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
        , i_env_param4  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id := nvl(i_inst_id, 0);
    l_agent_id := nvl(i_agent_id, 0);

    -- details
    begin
        select
            case when count(1) = 0 then          
                xmlelement ("transactions"
                    , xmlelement("transaction", null)
                    )
            else        
                xmlelement("transactions"
                        , xmlagg(
                            xmlelement("transaction"
                                , xmlelement("inst_id", inst_id)
                                , xmlelement("inst", inst)
                                , xmlelement("agent_id", agent_id)
                                , xmlelement("agent", agent)
                                , xmlelement("account_number", account_number)
                                , xmlelement("acc_currency", acc_currency)
                                , xmlelement("convert_amount", com_api_currency_pkg.get_amount_str(nvl(convert_amount, 0), acc_currency, com_api_type_pkg.TRUE))
                                , xmlelement("transaction_id", transaction_id)
                                , xmlelement("posting_date", to_char(posting_date, 'dd.mm.yyyy'))
                                , xmlelement("sttl_date", to_char(sttl_date, 'dd.mm.yyyy'))
                                , xmlelement("card_number", card_number)
                                , xmlelement("person_name", person_name)
                                , xmlelement("transaction_type_id", transaction_type_id)
                                , xmlelement("trans_description", trans_description)
                            )
                            order by inst
                                   , agent
                                   , account_number
                        )
                    )
            end        
        into
            l_detail
        from (
            select a.id
                 , a.inst_id
                 , com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', a.inst_id, l_lang) as inst
                 , a.agent_id
                 , com_api_i18n_pkg.get_text('OST_AGENT','NAME', a.agent_id, l_lang) as agent
                 , a.account_number
                 , a.currency acc_currency
                 , e.balance_impact
                 , e.balance_impact * (case when a.currency = e.currency then e.amount
                                            else com_api_rate_pkg.convert_amount(e.amount, e.currency, a.currency, t.rate_type, a.inst_id, e.posting_date)
                                       end) convert_amount
                 , e.currency
                 , e.transaction_id
                 , e.posting_date
                 , op.oper_date as sttl_date
                 , coalesce(c.card_mask, iss_api_card_pkg.get_card_mask(n.card_number)) card_number
                 , com_ui_person_pkg.get_person_name(h.person_id, l_lang) as person_name
                 , com_api_dictionary_pkg.get_article_id(
                       i_article => e.transaction_type
                     , i_lang    => l_lang
                   ) transaction_type_id
                 , com_api_dictionary_pkg.get_article_text(
                       i_article => e.transaction_type
                     , i_lang    => l_lang
                   ) trans_description
              from acc_entry e
                 , acc_account a
                 , acc_balance b
                 , acc_balance_type t
                 , acc_account_object o
                 , iss_card c
                 , iss_card_number_vw n
                 , iss_cardholder h
                 , acc_macros m
                 , opr_operation op
             where op.oper_date between l_start_date and l_end_date
               and a.id = e.account_id
               and o.account_id = a.id
               and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and c.id = o.object_id
               and n.card_id = c.id
               and h.id = c.cardholder_id
               and e.account_id = b.account_id
               and e.balance_type = b.balance_type
               and e.macros_id = m.id
               and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and m.object_id = op.id
               and t.account_type = a.account_type
               and t.inst_id = a.inst_id
               and t.aval_impact != 0
               and t.balance_type = b.balance_type
               and (l_inst_id = 0 or a.inst_id = l_inst_id)
               and (l_agent_id = 0 or a.agent_id = l_agent_id)
        );

    end;

    select
        xmlelement (
            "report"
            , get_header(l_inst_id, l_agent_id, l_start_date, l_end_date, l_lang)
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'iss_api_report_pkg.financial_transaction - ok'
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end;

function get_header (
    i_inst_id                      in     com_api_type_pkg.t_inst_id       default 0
    , i_agent_id                   in     com_api_type_pkg.t_agent_id      default 0
    , i_start_date                 in     date
    , i_end_date                   in     date
    , i_lang                       in     com_api_type_pkg.t_dict_value
) return xmltype is
    l_header                       xmltype;
    l_logo_path                    xmltype; 
begin
    l_logo_path := rpt_api_template_pkg.logo_path_xml;
    select
        xmlconcat(
            xmlelement("inst_id", nvl(i_inst_id, 0))
            , l_logo_path
            , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', i_inst_id, i_lang))
            , xmlelement("agent_id", nvl(i_agent_id, 0))
            , xmlelement("agent", com_api_i18n_pkg.get_text('OST_AGENT','NAME', i_agent_id, i_lang))
            , xmlelement("start_date", to_char(i_start_date, 'dd.mm.yyyy'))
            , xmlelement("end_date", to_char(i_end_date, 'dd.mm.yyyy'))
        )
    into
        l_header
    from
        dual;

    return l_header;
end get_header;

function get_header (
    i_inst_id                      in     com_api_type_pkg.t_inst_id       default 0
    , i_start_date                 in     date
    , i_end_date                   in     date
    , i_lang                       in     com_api_type_pkg.t_dict_value
) return xmltype is
    l_header                       xmltype;
    l_logo_path                    xmltype;     
begin
    l_logo_path := rpt_api_template_pkg.logo_path_xml;
    select
        xmlconcat(
            l_logo_path
            , xmlelement("inst_id", i_inst_id)
            , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', i_inst_id, i_lang))
            , xmlelement("start_date", to_char(i_start_date, 'dd.mm.yyyy'))
            , xmlelement("end_date", to_char(i_end_date, 'dd.mm.yyyy'))
        )
    into
        l_header
            from dual;
    return l_header;
end get_header;

procedure iss_objects(
    o_xml                             out clob
  , i_lang                         in     com_api_type_pkg.t_dict_value    default null
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
) is
    l_header                       xmltype;
    l_objects                      xmltype;
    l_result                       xmltype;
    l_lang                         com_api_type_pkg.t_dict_value;
begin
    l_lang := nvl(i_lang, get_user_lang);

    trc_log_pkg.debug(
        i_text         => 'start: iss_api_report_pkg.iss_cards_stat [#1], [#2]'
        , i_env_param1 => l_lang
        , i_env_param2 => i_inst_id
    );

    -- header
    select xmlelement("header"
                     , xmlelement("rep_date", to_char(get_sysdate(), 'dd.mm.yyyy hh24:mi'))
           )
      into l_header
      from dual;

    -- details
    select xmlelement("table"
               , xmlagg(
                   xmlelement("record"
                       , xmlelement("obj_type"   , x.obj_type)
                       , xmlelement("object"     , x.object)
                       , xmlelement("obj_params" , x.obj_params)
                       , xmlelement("obj_cnt"    , x.obj_cnt)
                   )
               )
           )
      into l_objects
      from (
          select 'Clients' as obj_type
               , get_article_text(a.entity_type, l_lang) as object
               , null as obj_params
               , cust_cnt as obj_cnt
            from (
                select c.entity_type
                     , count(c.id) as cust_cnt
                  from prd_customer c
                 where (i_inst_id is null or i_inst_id = c.inst_id)
                   and exists (
                           select 1
                             from prd_contract pc
                                , prd_contract_type pct
                            where pc.contract_type = pct.contract_type
                              and pct.product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS
                              and pc.customer_id   = c.id
                       )
                 group by c.entity_type
            ) a
          union all
          select 'Cards' as obj_type
               , a.card_type_id  || ' - ' || get_text (i_table_name     => 'net_card_type'
                                                      , i_column_name   => 'name'
                                                      , i_object_id     => a.card_type_id
                                                      , i_lang          => l_lang) as object
               , a.state || ' - ' || get_article_text(a.state, l_lang) as obj_params
               , a.card_cnt as obj_cnt
            from (
                select ci.state
                     , card_type_id
                     , count(c.id) as card_cnt
                  from iss_card c
                     , iss_card_instance ci
                 where c.id = ci.card_id
                   and (i_inst_id is null or i_inst_id = c.inst_id)
                 group by ci.state, card_type_id
            ) a
          union all
          select 'Accounts' as obj_type
               , a.account_type || ' - ' || get_article_text(a.account_type, l_lang) as object
               , 'Type: ' || a.balance_type || ' - ' || get_article_text(a.balance_type, l_lang) || ', Currency: ' || a.currency || ', Amount: ' || to_char(a.bal_sum, 'FM999,999,999,999,999,990.00') as obj_params
               , a.acc_cnt as obj_cnt
            from (
                select aa.account_type
                     , aa.currency
                     , ab.balance_type
                     , count(aa.id) as acc_cnt
                     , sum(ab.balance) as bal_sum
                  from acc_account aa
                     , acc_balance ab
                 where aa.id = ab.account_id
                   and exists (
                           select 1
                             from prd_contract pc
                                , prd_contract_type pct
                            where pc.contract_type = pct.contract_type
                              and pct.product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS
                              and pc.id            = aa.contract_id
                       )
                 group by aa.account_type
                     , aa.currency
                     , ab.balance_type
            ) a
        order by 1, 2, 3
      ) x;

    -- 3 output
    select xmlelement("report"
             , l_header
             , l_objects
          )
     into l_result
     from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'end iss_api_report_pkg.iss_objects');

exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text => sqlerrm
        );
end iss_objects;

procedure iss_customers_stat(
    o_xml                             out clob
  , i_lang                         in     com_api_type_pkg.t_dict_value    default null
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
) is
    l_header                       xmltype;
    l_customers                    xmltype;
    l_result                       xmltype;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_total_cnt                    com_api_type_pkg.t_short_id;
begin
    l_lang := nvl(i_lang, get_user_lang);

    trc_log_pkg.debug(
        i_text          => 'start: iss_api_report_pkg.iss_customers_stat [#1], [#2]'
        , i_env_param1  => l_lang
        , i_env_param2  => i_inst_id
    );

    select count(c.id)
      into l_total_cnt
      from prd_customer c
     where (i_inst_id is null or i_inst_id = c.inst_id)
       and exists (
           select 1
             from prd_contract pc
                , prd_contract_type pct
            where pc.contract_type = pct.contract_type
              and pct.product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS
              and pc.customer_id   = c.id);

    -- header
    select xmlelement("header"
                      , xmlelement("rep_date", to_char(get_sysdate(), 'dd.mm.yyyy hh24:mi'))
                      , xmlelement("total_cnt", to_char(l_total_cnt))
           )
      into l_header
      from dual;

    select xmlelement("customers",
               xmlagg(
                   xmlelement("customer_rec"
                                  , xmlelement("cust_name"  , x.cust_name)
                                  , xmlelement("cust_cnt"   , x.cust_cnt)
                              )
               )
           )
    into l_customers
    from (
         select a.entity_type  || ' - ' || get_article_text(a.entity_type, l_lang) cust_name
              , a.cust_cnt
           from (
               select c.entity_type
                    , count(c.id) as cust_cnt
                 from prd_customer c
                where (i_inst_id is null or i_inst_id = c.inst_id)
                  and exists (
                       select 1
                         from prd_contract pc, prd_contract_type pct
                        where pc.contract_type = pct.contract_type
                          and pct.product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS
                          and pc.customer_id   = c.id
                      )
          group by c.entity_type
          ) a
    ) x;

    -- 3 output
    select xmlelement("report"
             , l_header
             , l_customers
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    --dbms_output.put_line(o_xml);

    trc_log_pkg.debug(i_text => 'end iss_api_report_pkg.iss_customers_stat');

exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text => sqlerrm
        );
end iss_customers_stat;

procedure iss_accounts_stat(
    o_xml                             out clob
  , i_lang                         in     com_api_type_pkg.t_dict_value    default null
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
) is
    l_header                       xmltype;
    l_accounts                     xmltype;
    l_result                       xmltype;
    l_lang                         com_api_type_pkg.t_dict_value;
begin
    l_lang := nvl(i_lang, get_user_lang);

    trc_log_pkg.debug(
        i_text         => 'start: iss_api_report_pkg.iss_accounts_stat [#1], [#2]'
        , i_env_param1 => l_lang
        , i_env_param2 => i_inst_id
    );

    --header
    select xmlelement("header"
                , xmlelement("rep_date", to_char(get_sysdate(), 'dd.mm.yyyy hh24:mi'))
           )
      into l_header
      from dual;

    select xmlelement("accounts",
               xmlagg(
                   xmlelement("account_rec"
                       , xmlelement("acc_type_name"       , x.acc_type_name)
                       , xmlelement("currency"            , x.currency)
                       , xmlelement("balance_type_name"   , x.balance_type_name)
                       , xmlelement("acc_cnt"             , x.acc_cnt)
                       , xmlelement("bal_sum_str"         , x.bal_sum_str)
                       , xmlelement("bal_sum_num"         , x.bal_sum_num)
                   )
               )
           )
      into l_accounts
      from (
          select a.account_type || ' - ' || com_api_dictionary_pkg.get_article_text(i_article => a.account_type, i_lang => l_lang) acc_type_name --CP1251 > UTF-8
               , a.currency     || ' - ' || com_api_i18n_pkg.get_text('com_currency', 'name', a.id, l_lang) currency
               , a.balance_type || ' - ' || get_article_text(i_article => a.balance_type, i_lang => l_lang) balance_type_name --CP1251 > UTF-8
               , a.acc_cnt
               , trim(to_char(nvl(a.bal_sum, 0)/power(10, a.exponent), '999G999G999G999G999G990D99', 'NLS_NUMERIC_CHARACTERS = ''. '' ')) bal_sum_str
               , nvl(a.bal_sum, 0)/power(10, a.exponent) as bal_sum_num
        from (
            select aa.account_type
                 , ab.balance_type
                 , aa.currency
                 , cc.id
                 , cc.exponent
                 , count(aa.id) as acc_cnt
                 , sum(ab.balance) as bal_sum
              from acc_account aa
                 , acc_balance ab
                 , com_currency cc
             where aa.id    = ab.account_id
               and cc.code  = aa.currency
               and (i_inst_id is null or i_inst_id = aa.inst_id)
               and exists(select 1
                            from prd_contract pc
                               , prd_contract_type pct
                           where pc.contract_type = pct.contract_type
                             and pct.product_type = iss_api_const_pkg.ENTITY_TYPE_ISS_PRODUCT
                             and pc.id = aa.contract_id
                         )
             group by aa.account_type
                 , aa.currency
                 , cc.id
                 , cc.exponent
                 , ab.balance_type
            ) a
            order by 1, 2, 3
      ) x;

    -- 3 output
    select xmlelement("report"
             , l_header
             , l_accounts
           )
     into l_result
     from dual;

    o_xml := l_result.getclobval();

    --dbms_output.put_line(o_xml);
    trc_log_pkg.debug(i_text => 'end iss_api_report_pkg.iss_accounts_stat');

exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text => sqlerrm
        );
end iss_accounts_stat;

procedure iss_cards_stat(
    o_xml                             out clob
  , i_lang                         in     com_api_type_pkg.t_dict_value    default null
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
) is
    l_header                       xmltype;
    l_cards                        xmltype;
    l_result                       xmltype;
    l_lang                         com_api_type_pkg.t_dict_value;
begin
    l_lang := nvl(i_lang, get_user_lang);

    trc_log_pkg.debug(
        i_text         => 'start: iss_api_report_pkg.iss_cards_stat [#1], [#2]'
        , i_env_param1 => l_lang
        , i_env_param2 => i_inst_id
    );

    -- header
    select xmlelement("header"
         , xmlelement("rep_date", to_char(get_sysdate(), 'dd.mm.yyyy hh24:mi'))
    )
    into l_header
    from dual;

    --detail
    select xmlelement ("cards",
               xmlagg(
                   xmlelement("card_rec"
                       , xmlelement("card_type"  , x.card_type)
                       , xmlelement("card_state" , x.card_state)
                       , xmlelement("card_cnt"   , x.card_cnt)
                   )
               )
          )
     into l_cards
     from (select a.card_type_id  || ' - ' || get_text (i_table_name    => 'net_card_type'
                                                      , i_column_name   => 'name'
                                                      , i_object_id     => a.card_type_id
                                                      , i_lang          => l_lang) as card_type
                , a.status        || ' - ' || get_article_text(a.status, l_lang) card_state
                , a.card_cnt
            from (
                select ci.status
                     , card_type_id
                     , count(c.id) as card_cnt
                 from iss_card c
                    , iss_card_instance ci
                where c.id = ci.card_id
                  and (i_inst_id is null or i_inst_id = c.inst_id)
                group by ci.status
                    , card_type_id
            ) a
        order by 1, 2
     ) x;

    -- all
    select xmlelement("report"
             , l_header
             , l_cards
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();
    --dbms_output.put_line(o_xml);

    trc_log_pkg.debug(i_text => 'end iss_api_report_pkg.iss_cards_stat');

exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text => sqlerrm
        );
end iss_cards_stat;

procedure cards_being_deleted(
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
  , i_start_date                   in     date
  , i_end_date                     in     date
  , i_lang                         in     com_api_type_pkg.t_dict_value
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_start_date                   date;
    l_end_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_detail                       xmltype;
    l_result                       xmltype;
begin
    trc_log_pkg.debug (
        i_text          => 'iss_api_report_pkg.cards_being_deleted [#1][#2][#3]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
        , i_env_param3  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id := nvl(i_inst_id, 0);

    -- details
    begin
        select
            xmlelement("cards"
                    , xmlagg(
                        xmlelement("card"
                            , xmlelement("inst_id", inst_id)
                            , xmlelement("inst", inst)
                            , xmlelement("card_number", card_number)
                        )
                        order by inst
                               , card_number
                    )
                )
        into
            l_detail
        from(
            select i.inst_id
                 , com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', i.inst_id, l_lang) as inst
                 , n.card_number
              from iss_card c
                 , iss_card_instance i
                 , iss_card_number_vw n
                 , acc_account_object o
                 , acc_account a
                 , acc_balance b
             where c.id = i.card_id
               and c.id = n.card_id
               and c.id = o.object_id
               and a.id = o.account_id
               and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and a.id = b.account_id
               and a.inst_id = b.inst_id
               and (l_inst_id = 0 or i.inst_id = l_inst_id)
               and i.expir_date between l_start_date and l_end_date
               and i.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
               and b.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and b.balance = 0
            );

    exception
        when no_data_found then
            select
                xmlelement("cards", '')
            into
                l_detail
            from
                dual;

            trc_log_pkg.debug (
                i_text  => 'Cards not found'
            );
    end;

    select
        xmlelement (
            "report"
            , get_header(l_inst_id, l_start_date, l_end_date, l_lang)
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'iss_api_report_pkg.cards_being_deleted - ok'
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end cards_being_deleted;

end iss_api_report_pkg;
/
