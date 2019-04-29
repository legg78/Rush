create or replace package body cst_bof_api_report_pkg is
/*********************************************************
 *  Custom reports API for BOA <br />
 *  Created by Gogolev I.(i.gogolev@bpcbt.com) at 25.04.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: cst_bof_api_report_pkg <br />
 *  @headcom
 **********************************************************/
function get_header (
    i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_start_date    in  date
  , i_end_date      in  date
  , i_lang          in  com_api_type_pkg.t_dict_value
) return xmltype is
    l_header    xmltype;
begin
    select
           xmlconcat(
               xmlelement("inst_id", i_inst_id)
                 , xmlelement(
                       "inst"
                     , com_api_i18n_pkg.get_text(
                           i_table_name  => 'OST_INSTITUTION'
                         , i_column_name => 'NAME'
                         , i_object_id   => i_inst_id
                         , i_lang        => i_lang
                       )
                   )
                 , xmlelement("start_date", to_char(i_start_date, 'dd.mm.yyyy'))
                 , xmlelement("end_date", to_char(i_end_date, 'dd.mm.yyyy'))
           )
      into
           l_header
      from dual;
    return l_header;
end get_header;

procedure reissued_cards(
    o_xml          out    clob
  , i_inst_id       in    com_api_type_pkg.t_inst_id        default null
  , i_start_date    in    date
  , i_end_date      in    date
  , i_lang          in    com_api_type_pkg.t_dict_value     default null
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.reissued_cards: ';
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_start_date                   date;
    l_end_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_detail                       xmltype;
    l_result                       xmltype;
begin
    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || 'Start with params - inst_id [#1] start_date [#2] end_date [#3] lang [#4]'
      , i_env_param1    => i_inst_id
      , i_env_param2    => i_start_date
      , i_env_param3    => i_end_date
      , i_env_param4    => i_lang
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id :=nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST);
    
    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || 'Begin performing with params inst_id [#1] start_date [#2] end_date [#3] lang [#4]'
      , i_env_param1    => l_inst_id
      , i_env_param2    => com_api_type_pkg.convert_to_char(l_start_date)
      , i_env_param3    => com_api_type_pkg.convert_to_char(l_end_date)
      , i_env_param4    => l_lang
    );    

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
                         , xmlelement("old_card_number", old_card_number)
                         , xmlelement("reg_date", to_char(reg_date, 'dd.mm.yyyy'))
                         , xmlelement("expir_date", to_char(expir_date, 'dd.mm.yyyy'))
                         , xmlelement("old_product_type", old_product_type)
                         , xmlelement("old_product_type_name", old_product_type_name)
                         , xmlelement("old_product_name", old_product_name)
                         , xmlelement("product_type", product_type)
                         , xmlelement("product_type_name", product_type_name)
                         , xmlelement("product_name", product_name)
                         , xmlelement("card_type_id", card_type_id)
                         , xmlelement("card_type_name", card_type)
                         , xmlelement("status", status)
                         , xmlelement("status_name", status_name)
                         , xmlelement("state", state)
                         , xmlelement("state_name", state_name)
                         , xmlelement("cardholder_id", cardholder_id)
                         , xmlelement("person_name", person_name)
                         , xmlelement("blank_type_id", blank_type_id)
                         , xmlelement("blank_type_name", blank_type_name)
                       )
                       order by 
                             card_number
                           , account_number
                   )
               )
          into l_detail
          from ( select i.inst_id
                      , com_api_i18n_pkg.get_text(
                            i_table_name  => 'OST_INSTITUTION'
                          , i_column_name => 'NAME'
                          , i_object_id   => i.inst_id
                          , i_lang        => l_lang
                        ) as inst
                      , i.agent_id
                      , com_api_i18n_pkg.get_text(
                            i_table_name  => 'OST_AGENT'
                          , i_column_name => 'NAME'
                          , i_object_id   => i.agent_id
                          , i_lang        => l_lang
                        ) as agent
                      , a.account_number
                      , n.card_number
                      , no.card_number as old_card_number
                      , i.reg_date
                      , i.expir_date
                      , po.product_type as old_product_type
                      , com_api_dictionary_pkg.get_article_text(
                            i_article => po.product_type
                          , i_lang    => l_lang
                        ) as old_product_type_name
                      , com_api_i18n_pkg.get_text(
                            i_table_name  => 'PRD_PRODUCT'
                          , i_column_name => 'LABEL'
                          , i_object_id   => po.id
                          , i_lang        => l_lang
                        ) as old_product_name
                      , p.product_type as product_type
                      , com_api_dictionary_pkg.get_article_text(
                            i_article => p.product_type
                          , i_lang    => l_lang
                        ) as product_type_name
                      , com_api_i18n_pkg.get_text(
                            i_table_name  => 'PRD_PRODUCT'
                          , i_column_name => 'LABEL'
                          , i_object_id   => p.id
                          , i_lang        => l_lang
                        ) as product_name
                      , c.card_type_id
                      , com_api_i18n_pkg.get_text(
                            i_table_name  => 'NET_CARD_TYPE'
                          , i_column_name => 'NAME'
                          , i_object_id   => c.card_type_id
                          , i_lang        => l_lang
                        ) as card_type
                      , i.status
                      , com_api_dictionary_pkg.get_article_text(
                            i_article => i.status
                          , i_lang    => l_lang
                        ) as status_name
                      , i.state
                      , com_api_dictionary_pkg.get_article_text(
                            i_article => i.state
                          , i_lang    => l_lang
                        ) as state_name
                      , c.cardholder_id
                      , com_ui_person_pkg.get_person_name(
                            i_person_id => h.person_id
                          , i_lang      => l_lang
                        ) as person_name
                      , i.blank_type_id
                      , com_api_i18n_pkg.get_text(
                            i_table_name  => 'PRS_BLANK_TYPE'
                          , i_column_name => 'NAME'
                          , i_object_id   => i.blank_type_id
                          , i_lang        => l_lang
                        ) as blank_type_name
                   from iss_card c
                      , iss_card co
                      , iss_card_instance i
                      , iss_card_instance io
                      , iss_card_number_vw n
                      , iss_card_number_vw no
                      , iss_cardholder h
                      , acc_account_object o
                      , acc_account a
                      , prd_contract s
                      , prd_contract so
                      , prd_product p
                      , prd_product po
                  where c.id = i.card_id
                    and c.id = n.card_id
                    and c.id = o.object_id
                    and c.cardholder_id = h.id
                    and a.id = o.account_id
                    and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                    and (l_inst_id = ost_api_const_pkg.DEFAULT_INST or i.inst_id = l_inst_id)
                    and i.reg_date between l_start_date and l_end_date
                    and (i.seq_number > 1 or i.preceding_card_instance_id is not null)
                    and c.contract_id = s.id
                    and p.id = s.product_id
                    and io.id = nvl(i.preceding_card_instance_id, i.id)
                    and co.id = io.card_id
                    and no.card_id = co.id
                    and so.id = co.contract_id
                    and po.id = so.product_id
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
             , get_header(l_inst_id, l_start_date, l_end_date, l_lang)
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

end cst_bof_api_report_pkg;
/
