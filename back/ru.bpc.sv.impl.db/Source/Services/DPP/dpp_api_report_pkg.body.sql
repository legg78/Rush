create or replace package body dpp_api_report_pkg is
/************************************************************
* Reports for DPP module <br />
* Created by Gogolev I.(i.gogolev@bpcbt.com) at 14.12.2017  <br />
* Last changed by $Author: gogolev_i $  <br />
* $LastChangedDate:: 2017-12-14 12:44:00 +0400#$ <br />
* Revision: $LastChangedRevision: $ <br />
* Module: DPP_API_REPORT_PKG <br />
* @headcom
************************************************************/
procedure get_payment_plan_data_event(
    o_xml                  out clob
  , i_event_type        in     com_api_type_pkg.t_dict_value
  , i_eff_date          in     date
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_payment_plan_data_event: ';
    l_result            xmltype;
    l_attach            xmltype;
    l_dpp_id            com_api_type_pkg.t_long_id;
begin
     trc_log_pkg.debug (
        i_text       => LOG_PREFIX || ' start report notification with params [#1] [#2] [#3] [#4] [#5]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );
    
    case i_entity_type 
        when opr_api_const_pkg.ENTITY_TYPE_OPERATION then
            select max(pp.id)
              into l_dpp_id
              from dpp_payment_plan pp
             where pp.oper_id = i_object_id;
        when dpp_api_const_pkg.ENTITY_TYPE_PAYMENT_PLAN then
            l_dpp_id := i_object_id;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
              , i_env_param1 => i_entity_type
            );
    end case;
    
    begin
        select xmlagg(    
                   xmlelement(
                       "attachment"
                     , xmlelement("attachment_path", c.save_path)
                     , xmlelement("attachment_name", c.file_name)
                   )  
               )
          into l_attach           
          from (select max(d.id) id --last document
                  from rpt_document d
                 where d.object_id     = i_object_id
                   and d.entity_type   = i_entity_type
                   and d.document_type = rpt_api_const_pkg.DOCUMENT_TYPE_DPP_REPORT
               ) dd
             , rpt_document_content c
         where c.document_id = dd.id;
    exception
        when no_data_found then
            null;
    end;

    --payment plan data, account, card, institution, agent contact data
    select xmlconcat(
               xmlelement(
                   "operation"
                 , xmlattributes(
                       pp.oper_id                as "oper_id"
                   )
                 , xmlelement("oper_type"        , pp.oper_type)
                 , xmlelement("oper_date"        , to_char(pp.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                 , xmlelement("oper_amount"      , com_api_currency_pkg.get_amount_str(nvl(pp.oper_amount, 0), pp.oper_currency, com_api_const_pkg.TRUE))
                 , xmlelement("oper_currency"    , pp.oper_currency)
                 , xmlelement("oper_type_name"   , get_article_text(pp.oper_type))
                 , xmlelement("merchant_name"    , o.merchant_name)
               )
             , xmlelement(
                   "dpp"
                 , xmlattributes(
                       pp.id                            as "dpp_id"
                     , pp.reg_oper_id                   as "reg_oper_id"
                   )
                 , xmlelement("next_instalment_date"    , to_char(pp.next_instalment_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                 , xmlelement("dpp_amount"              , com_api_currency_pkg.get_amount_str(nvl(pp.dpp_amount, 0), pp.dpp_currency, com_api_const_pkg.TRUE))
                 , xmlelement("dpp_currency"            , pp.dpp_currency)
                 , xmlelement("interest_amount"         , com_api_currency_pkg.get_amount_str(nvl(pp.interest_amount, 0), pp.dpp_currency, com_api_const_pkg.TRUE))
                 , xmlelement("instalment_amount"       , com_api_currency_pkg.get_amount_str(nvl(pp.instalment_amount, 0), pp.dpp_currency, com_api_const_pkg.TRUE))
                 , xmlelement("instalment_total"        , pp.instalment_total)
                 , xmlelement("instalment_billed"       , pp.instalment_billed)
                 , xmlelement("instalment_not_billed"   , pp.instalment_total - nvl(pp.instalment_billed, 0))
                 , xmlelement(
                       "instalments"
                     , (select xmlagg(
                                   xmlelement(
                                       "instalment"
                                     , xmlattributes(
                                           pi.id                     as "instalment_id"
                                         , pp.id                     as "dpp_id"
                                       )
                                     , xmlelement("instalment_number", pi.instalment_number)
                                     , xmlelement("instalment_date"  , to_char(pi.instalment_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                     , xmlelement("instalment_amount", com_api_currency_pkg.get_amount_str(nvl(pi.instalment_amount, 0), pp.dpp_currency, com_api_const_pkg.TRUE))
                                     , xmlelement("interest_amount"  , com_api_currency_pkg.get_amount_str(nvl(pi.interest_amount, 0), pp.dpp_currency, com_api_const_pkg.TRUE))
                                   )
                               )
                          from dpp_instalment pi
                         where pi.dpp_id = pp.id
                       )
                   )
               )
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
                                         , i_start_date    => i_eff_date
                                       )
                                   )
                               ) order by co.contact_type, cd.commun_method, co.id desc
                           )
                       )
                  from com_contact_object co
                     , com_contact_data cd
                 where co.object_id = pp.inst_id
                   and co.entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                   and co.contact_id  = cd.contact_id
               )
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
                                         , i_start_date    => i_eff_date
                                       )
                                   )
                               ) order by co.contact_type, cd.commun_method, co.id desc
                           )
                       )
                  from com_contact_object co
                     , com_contact_data cd
                 where co.object_id = a.agent_id
                   and co.entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT
                   and co.contact_id  = cd.contact_id
               )
             , xmlelement(
                   "account"
                 , xmlattributes(
                       a.id                       as "account_id"
                     , a.account_type             as "account_type"
                   )
                 , xmlelement("currency"          , a.currency)
                 , xmlelement("account_number"    , a.account_number)
                 , xmlelement("account_mask"      , '*' || substr(a.account_number, -5, 5))
                 , xmlelement("short_account_mask", '*' || substr(a.account_number, -4, 4))
               )
             , xmlelement(
                   "card"
                 , xmlattributes(
                       ic.id       as "card_id"
                     , ic.category as "card_category"
                   )
                 , xmlelement(
                       "card_mask"
                     , ic.card_mask
                   )
                 , xmlelement(
                       "card_short_mask"
                     , iss_api_card_pkg.get_short_card_mask(
                           i_card_number => ic.card_mask
                       )
                   )
               )
             , xmlelement(
                   "customer"
                 , xmlelement("customer_number", c.customer_number)
                 , (select xmlagg(
                               xmlelement(
                                   "customer_name"
                                 , xmlelement("surname"     , p.surname)
                                 , xmlelement("first_name"  , p.first_name)
                                 , xmlelement("second_name" , p.second_name)
                                 , xmlelement("person_title", p.title)
                               )
                           )
                      from (select p1.id
                                 , min(p1.lang) keep(dense_rank first order by decode(p1.lang, i_lang, 1, 'LANGENG', 2, 3)) lang 
                              from com_person p1
                             group by id
                           ) p2
                         , com_person p         
                     where p2.id  = c.object_id
                       and p.id   = p2.id
                       and p.lang = p2.lang
                   )
                 , (select xmlelement(
                               "delivery_address"
                             , xmlelement("region"     , da.region)
                             , xmlelement("city"       , da.city)
                             , xmlelement("street"     , da.street)
                             , xmlelement("house"      , da.house)
                             , xmlelement("apartment"  , da.apartment)
                             , xmlelement("postal_code", da.postal_code)
                             , xmlelement(
                                   "country"
                                 , com_api_country_pkg.get_country_full_name(
                                       i_code         => da.country
                                     , i_lang         => i_lang
                                     , i_raise_error  => com_api_const_pkg.FALSE
                                   )
                               )
                           )
                      from (select adr.region
                                 , adr.city
                                 , adr.street
                                 , adr.house
                                 , adr.apartment
                                 , adr.postal_code
                                 , adr.country
                                 , ao.object_id
                                 , row_number() over (partition by ao.object_id
                                                          order by decode(
                                                                       ao.address_type
                                                                     , 'ADTPSTDL', 1
                                                                     , 'ADTPLGLA', 2
                                                                     , 'ADTPHOME', 3
                                                                     , 'ADTPBSNA', 4
                                                                     , 5
                                                                   )
                                                                 , decode(
                                                                       adr.lang
                                                                     , i_lang, -1
                                                                     , com_api_const_pkg.DEFAULT_LANGUAGE, 0
                                                                     , ao.address_id
                                                                   )
                                                     ) rn
                              from com_address_object ao
                                 , com_address adr
                             where ao.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                               and adr.id         = ao.address_id
                               and adr.lang       = i_lang
                           ) da
                     where da.object_id = c.id
                       and rn            = 1
                   )
               )
             , xmlelement(
                   "report" 
                 , xmlelement("attachments", l_attach)
               )
           )
      into l_result
      from dpp_payment_plan pp
         , acc_account a
         , iss_card ic
         , opr_operation o
         , prd_customer_vw c
     where pp.id            = l_dpp_id
       and pp.account_id    = a.id(+)
       and pp.card_id       = ic.id(+)
       and pp.oper_id       = o.id(+)
       and a.customer_id    = c.id(+) 
       and c.entity_type(+) = com_api_const_pkg.ENTITY_TYPE_PERSON;
 
    o_xml := l_result.getclobval();  

exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end get_payment_plan_data_event;

procedure get_instalment_data_event(
    o_xml                  out clob
  , i_event_type        in     com_api_type_pkg.t_dict_value
  , i_eff_date          in     date
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_instalment_data_event: ';
    l_result            xmltype;
begin
     trc_log_pkg.debug (
        i_text       => LOG_PREFIX || ' start report notification with params [#1] [#2] [#3] [#4] [#5]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );
    
    if i_entity_type <> dpp_api_const_pkg.ENTITY_TYPE_INSTALMENT then
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => i_entity_type
        );
    end if;
    
    --payment instalment data, account, card, institution, agent contact data
    select xmlconcat(
               xmlelement(
                   "dpp_instalment"
                 , xmlattributes(
                       pi.id                            as "instalment_id"
                     , pp.id                            as "dpp_id"
                   )
                 , xmlelement("instalment_number"       , pi.instalment_number)
                 , xmlelement("instalment_date"         , to_char(pi.instalment_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                 , xmlelement("instalment_amount"       , com_api_currency_pkg.get_amount_str(nvl(pi.instalment_amount, 0), pp.dpp_currency, com_api_const_pkg.TRUE))
                 , xmlelement("interest_amount"         , com_api_currency_pkg.get_amount_str(nvl(pi.interest_amount, 0), pp.dpp_currency, com_api_const_pkg.TRUE))
               )
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
                                         , i_start_date    => i_eff_date
                                       )
                                   )
                               ) order by co.contact_type, cd.commun_method, co.id desc
                           )
                       )
                  from com_contact_object co
                     , com_contact_data cd
                 where co.object_id = pp.inst_id
                   and co.entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                   and co.contact_id  = cd.contact_id
               )
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
                                         , i_start_date    => i_eff_date
                                       )
                                   )
                               ) order by co.contact_type, cd.commun_method, co.id desc
                           )
                       )
                  from com_contact_object co
                     , com_contact_data cd
                 where co.object_id = a.agent_id
                   and co.entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT
                   and co.contact_id  = cd.contact_id
               )
             , xmlelement(
                   "account"
                 , xmlattributes(
                       a.id                       as "account_id"
                     , a.account_type             as "account_type"
                   )
                 , xmlelement("currency"          , a.currency)
                 , xmlelement("account_number"    , a.account_number)
                 , xmlelement("account_mask"      , '*' || substr(a.account_number, -5, 5))
                 , xmlelement("short_account_mask", '*' || substr(a.account_number, -4, 4))
               )
             , xmlelement(
                   "card"
                 , xmlattributes(
                       ic.id       as "card_id"
                     , ic.category as "card_category"
                   )
                 , xmlelement(
                       "card_mask"
                     , ic.card_mask
                   )
                 , xmlelement(
                       "card_short_mask"
                     , iss_api_card_pkg.get_short_card_mask(
                           i_card_number => ic.card_mask
                       )
                   )
               )
           )
      into l_result
      from dpp_instalment pi
         , dpp_payment_plan pp
         , acc_account a
         , iss_card ic
     where pi.id          = i_object_id
       and pp.id          = pi.dpp_id
       and pp.account_id  = a.id(+)
       and pp.card_id     = ic.id(+);
 
    o_xml := l_result.getclobval();  

exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end get_instalment_data_event;

end dpp_api_report_pkg;
/
