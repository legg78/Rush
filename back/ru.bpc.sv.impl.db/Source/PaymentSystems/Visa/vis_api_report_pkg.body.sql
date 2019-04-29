create or replace package body vis_api_report_pkg is
/*********************************************************
 *  Issuer reports API <br />
 *  Created by Kolodkina J.(kolodkina@bpcbt.com)  at 20.03.2013 <br />
 *  Last changed by $Author: truschelev $ <br />
 *  $LastChangedDate:: 2015-08-21 09:26:00 +0400#$ <br />
 *  Revision: $LastChangedRevision: 25841 $ <br />
 *  Module: vis_api_report_pkg <br />
 *  @headcom
 **********************************************************/

    TOTAL_AUTH_TYPE_ALL       constant com_api_type_pkg.t_name := 'ALL';
    TOTAL_AUTH_TYPE_MCC       constant com_api_type_pkg.t_name := 'MCC';
    TOTAL_AUTH_TYPE_MERCHANT  constant com_api_type_pkg.t_name := 'MERCHANT';
    TOTAL_AUTH_TYPE_COUNTRY   constant com_api_type_pkg.t_name := 'COUNTRY';
    NUM_FORMAT                constant com_api_type_pkg.t_name := 'FM999999999999999990,00';

    function get_header (
        i_inst_id                      in com_api_type_pkg.t_inst_id
        , i_start_date                 in date
        , i_end_date                   in date
        , i_lang                       in com_api_type_pkg.t_dict_value
    ) return xmltype is
    l_header                   xmltype;
    l_logo_path                xmltype;
    begin
        l_logo_path := rpt_api_template_pkg.logo_path_xml;      
        select
            xmlconcat(
                xmlelement("inst_id", i_inst_id)
                , l_logo_path
                , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', i_inst_id, i_lang))
                , xmlelement("start_date", to_char(i_start_date, 'dd.mm.yyyy'))
                , xmlelement("end_date", to_char(i_end_date, 'dd.mm.yyyy'))
            )
        into l_header from dual;
        return l_header;
    end;

    function get_header (
        i_inst_id                      in com_api_type_pkg.t_inst_id
        , i_netw_id                    in com_api_type_pkg.t_network_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_lang                       in com_api_type_pkg.t_dict_value
        , i_count                      in com_api_type_pkg.t_short_id
    ) return xmltype is
    l_header                   xmltype;
    l_logo_path                xmltype;    
    begin
        l_logo_path := rpt_api_template_pkg.logo_path_xml;       
        select
            xmlconcat(
                xmlelement("inst", i_inst_id)
                , l_logo_path
                , xmlelement("netw", case when i_netw_id <> 0 then com_api_i18n_pkg.get_text('NET_NETWORK','NAME', i_netw_id, i_lang)
                                     else to_char(i_netw_id)
                                     end)
                , xmlelement("cnt", i_count)
                , xmlelement("start_date", to_char(i_start_date, 'dd.mm.yyyy'))
                , xmlelement("end_date", to_char(i_end_date, 'dd.mm.yyyy'))
            )
        into l_header from dual;
        return l_header;
    end;

    function get_header (
        i_inst_id                      in com_api_type_pkg.t_inst_id
        , i_netw_id                    in com_api_type_pkg.t_network_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_currency                   in com_api_type_pkg.t_curr_code
        , i_mcc                        in com_api_type_pkg.t_mcc default null
        , i_country                    in com_api_type_pkg.t_country_code default null
        , i_sum                        in number
        , i_lang                       in com_api_type_pkg.t_dict_value
    ) return xmltype is
    l_header                   xmltype;
    l_logo_path                xmltype;    
    begin
        l_logo_path := rpt_api_template_pkg.logo_path_xml;  
        select
            xmlconcat(
                xmlelement("inst", i_inst_id)
                , l_logo_path                
                , xmlelement("netw", case when i_netw_id <> 0 then com_api_i18n_pkg.get_text('NET_NETWORK','NAME', i_netw_id, i_lang)
                                     else to_char(i_netw_id)
                                     end)
                , xmlelement("cnt", i_sum)
                , xmlelement("mcc", i_mcc)
                , xmlelement("country", country)
                , xmlelement("currency", i_currency)
                , xmlelement("start_date", to_char(i_start_date, 'dd.mm.yyyy'))
                , xmlelement("end_date", to_char(i_end_date, 'dd.mm.yyyy'))
            )
        into
            l_header
        from (
            select i_inst_id
                   , i_sum
                   , i_mcc
                   , (select visa_country_code from com_country where code = i_country) as country
                   , i_start_date
                   , i_end_date
            from dual
        );
        return l_header;
    end;

    procedure total_auth (
        o_xml                      out clob
        , i_start_date             in date
        , i_end_date               in date
        , i_inst_id                in com_api_type_pkg.t_inst_id          default null
        , i_card_network_id        in com_api_type_pkg.t_network_id       default null
        , i_mcc                    in com_api_type_pkg.t_mcc              default null
        , i_merchant_number        in com_api_type_pkg.t_merchant_number  default null
        , i_merchant_country       in com_api_type_pkg.t_country_code     default null
        , i_count                  in com_api_type_pkg.t_short_id
        , i_report_type            in com_api_type_pkg.t_name
        
        , i_lang                   in com_api_type_pkg.t_dict_value
    ) is
        l_start_date               date;
        l_end_date                 date;
        l_start_id                 com_api_type_pkg.t_long_id;
        l_end_id                   com_api_type_pkg.t_long_id;
        l_lang                     com_api_type_pkg.t_dict_value;
        l_count                    com_api_type_pkg.t_count       := 0;
        l_header                   xmltype;
        l_detail                   xmltype;
        l_result                   xmltype;
    begin
        l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
        l_end_date   := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
        l_lang       := nvl(i_lang, get_user_lang);
        l_count      := nvl(i_count, 1);

        l_start_id   := com_api_id_pkg.get_from_id(l_start_date);
        l_end_id     := com_api_id_pkg.get_till_id(l_end_date);

        trc_log_pkg.debug(
            i_text       => 'vis_api_report_pkg.total_auth: start_date [#1] end_date [#2] start_id [#3] end_id [#4] lang [#5]'
          , i_env_param1 => to_char(l_start_date, com_api_const_pkg.LOG_DATE_FORMAT)
          , i_env_param2 => to_char(l_end_date,   com_api_const_pkg.LOG_DATE_FORMAT)
          , i_env_param3 => l_start_id
          , i_env_param4 => l_end_id
          , i_env_param5 => l_lang
        );

        -- header
        select
            xmlconcat(
                xmlelement("inst",       case when i_inst_id is not null then i_inst_id || ' ' || get_text('ost_institution', 'name', i_inst_id, l_lang) else '0' end)
              , xmlelement("netw",       case when i_card_network_id is not null then i_card_network_id || ' ' || get_text('net_network', 'name', i_card_network_id, l_lang) else '0' end)
              , xmlelement("cnt",        l_count)
              , xmlelement("merchant",   nvl(i_merchant_number, '0'))
              , xmlelement("mcc",        nvl(i_mcc, '0'))
              , xmlelement("country",    (select min(visa_country_code) from com_country where code = i_merchant_country))
              , xmlelement("start_date", to_char(l_start_date, 'dd.mm.yyyy'))
              , xmlelement("end_date",   to_char(l_end_date, 'dd.mm.yyyy'))
            )
          into l_header
          from dual;
        
        begin
            select
                xmlagg(
                    xmlelement("auth"
                        , xmlforest(
                              x.card_number as "card_number"
                            , x.cnt as "cnt"
                            , case when x.inst_id is not null then x.inst_id || ' ' || get_text('ost_institution', 'name', x.inst_id, l_lang) else '' end as "inst"
                            , case when x.card_network_id is not null then x.card_network_id || ' ' || get_text('net_network', 'name', x.card_network_id, l_lang) else '' end as "netw"
                            , x.mcc as "mcc"
                            , x.merchant_number as "merchant"
                        )
                    )
                    order by x.inst_id
                           , x.card_network_id
                           , x.mcc
                           , x.merchant_number
                           , x.cnt
                           , x.card_number
                )
              into l_detail
              from (
                  select (select iss_api_card_pkg.get_card_mask(iss_api_token_pkg.decode_card_number(n.card_number)) from iss_card_number n where n.card_id = c.card_id) card_number
                       , c.inst_id
                       , c.card_network_id
                       , c.mcc
                       , c.merchant_number
                       , c.cnt
                    from (
                        select card.id card_id
                             , case when i_report_type in (TOTAL_AUTH_TYPE_MCC, TOTAL_AUTH_TYPE_MERCHANT) then op.inst_id         else to_number(null) end inst_id
                             , case when i_report_type in (TOTAL_AUTH_TYPE_MCC, TOTAL_AUTH_TYPE_MERCHANT) then op.card_network_id else to_number(null) end card_network_id
                             , case when i_report_type in (TOTAL_AUTH_TYPE_MCC)                           then o.mcc              else to_char(null)   end mcc
                             , case when i_report_type in (TOTAL_AUTH_TYPE_MERCHANT)                      then o.merchant_number  else to_char(null)   end merchant_number
                             , count(1) cnt

                          from  opr_operation o
                              , opr_participant op
                              , iss_card card
                              , (select element_value from com_array_element where array_id = 10000012) iss_sttl
                              , (select element_value from com_array_element where array_id = 10000013) acq_sttl
                              , (select element_value from com_array_element where array_id = 10000020) oper_status
                              , (select element_value from com_array_element where array_id = 10000014) oper_type
                              , (select i_inst_id          as inst_id
                                      , i_card_network_id  as card_network_id 
                                      , i_mcc              as mcc
                                      , i_merchant_number  as merchant_number
                                      , i_merchant_country as merchant_country
                                      , l_start_date       as start_date
                                      , l_end_date         as end_date
                                      , l_start_id         as start_id
                                      , l_end_id           as end_id
                                   from dual) prm

                          where o.sttl_type = iss_sttl.element_value(+)
                            and o.sttl_type = acq_sttl.element_value(+)
                            and (
                                    (iss_sttl.element_value is not null and msg_type in (opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT))
                                    or
                                    (acq_sttl.element_value is not null and msg_type in (opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                                                                                       , opr_api_const_pkg.MESSAGE_TYPE_COMPLETION))
                                )
                            and o.status            = oper_status.element_value
                            and o.oper_type         = oper_type.element_value
                            and o.id                = op.oper_id
                            and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                            and op.card_id          = card.id

                            and o.id        between prm.start_id   and prm.end_id
                            and o.oper_date between prm.start_date and prm.end_date

                            and (prm.inst_id          is null  or  op.inst_id         = prm.inst_id)
                            and (prm.card_network_id  is null  or  op.card_network_id = prm.card_network_id)
                            and (prm.mcc              is null  or  o.mcc              = prm.mcc)
                            and (prm.merchant_number  is null  or  o.merchant_number  = prm.merchant_number)
                            and (prm.merchant_country is null  or  o.merchant_country = prm.merchant_country)
          
                          group by card.id
                                 , case when i_report_type in (TOTAL_AUTH_TYPE_MCC, TOTAL_AUTH_TYPE_MERCHANT) then op.inst_id         else to_number(null) end
                                 , case when i_report_type in (TOTAL_AUTH_TYPE_MCC, TOTAL_AUTH_TYPE_MERCHANT) then op.card_network_id else to_number(null) end
                                 , case when i_report_type in (TOTAL_AUTH_TYPE_MCC)                           then o.mcc              else to_char(null)   end
                                 , case when i_report_type in (TOTAL_AUTH_TYPE_MERCHANT)                      then o.merchant_number  else to_char(null)   end
                          having count(1) > l_count
                    ) c
              ) x;

        exception
            when no_data_found then
                null;
        end;
        
        select xmlelement(
                   "report"
                 , l_header
                 , xmlelement("auths", nvl(l_detail, xmlelement("auth", '')))
               ) r
          into l_result
          from dual;
            
        o_xml := l_result.getclobval();

        trc_log_pkg.debug(
            i_text  => 'vis_api_report_pkg.total_auth - ok'
        );

    exception
        when others then
            trc_log_pkg.debug (
                i_text   => sqlerrm
            );
            raise;
    end;

    procedure total_auth (
        o_xml                      out clob
        , i_inst_id                in com_api_type_pkg.t_inst_id default null
        , i_netw_id                in com_api_type_pkg.t_network_id default null
        , i_start_date             in date
        , i_end_date               in date
        , i_lang                   in com_api_type_pkg.t_dict_value default null
        , i_count                  in com_api_type_pkg.t_short_id
    ) is
    begin
        total_auth (
            o_xml                 => o_xml
            , i_start_date        => i_start_date
            , i_end_date          => i_end_date
            , i_inst_id           => i_inst_id
            , i_card_network_id   => i_netw_id
            , i_mcc               => null
            , i_merchant_number   => null
            , i_merchant_country  => null
            , i_count             => i_count
            , i_report_type       => TOTAL_AUTH_TYPE_ALL
            , i_lang              => i_lang
        );
    end;

    procedure total_auth_mcc (
        o_xml                      out clob
        , i_inst_id                in com_api_type_pkg.t_inst_id default null
        , i_netw_id                in com_api_type_pkg.t_network_id default null
        , i_start_date             in date
        , i_end_date               in date
        , i_lang                   in com_api_type_pkg.t_dict_value default null
        , i_mcc                    in com_api_type_pkg.t_mcc default null
        , i_count                  in com_api_type_pkg.t_short_id
    ) is
    begin
        total_auth (
            o_xml                 => o_xml
            , i_start_date        => i_start_date
            , i_end_date          => i_end_date
            , i_inst_id           => i_inst_id
            , i_card_network_id   => i_netw_id
            , i_mcc               => i_mcc
            , i_merchant_number   => null
            , i_merchant_country  => null
            , i_count             => i_count
            , i_report_type       => TOTAL_AUTH_TYPE_MCC
            , i_lang              => i_lang
        );
    end;

    procedure total_auth_merchant (
        o_xml                      out clob
        , i_inst_id                in com_api_type_pkg.t_inst_id default null
        , i_netw_id                in com_api_type_pkg.t_network_id default null
        , i_start_date             in date
        , i_end_date               in date
        , i_lang                   in com_api_type_pkg.t_dict_value default null
        , i_merchant_id            in com_api_type_pkg.t_merchant_number default null
        , i_count                  in com_api_type_pkg.t_short_id
    ) is
    begin
        total_auth (
            o_xml                 => o_xml
            , i_start_date        => i_start_date
            , i_end_date          => i_end_date
            , i_inst_id           => i_inst_id
            , i_card_network_id   => i_netw_id
            , i_mcc               => null
            , i_merchant_number   => i_merchant_id
            , i_merchant_country  => null
            , i_count             => i_count
            , i_report_type       => TOTAL_AUTH_TYPE_MERCHANT
            , i_lang              => i_lang
        );
    end;
    
    procedure total_auth_country (
        o_xml                      out clob
        , i_inst_id                in com_api_type_pkg.t_inst_id default null
        , i_netw_id                in com_api_type_pkg.t_network_id default null
        , i_start_date             in date
        , i_end_date               in date
        , i_lang                   in com_api_type_pkg.t_dict_value default null
        , i_country                in com_api_type_pkg.t_country_code default null
        , i_count                  in com_api_type_pkg.t_short_id
    ) is
    begin
        total_auth (
            o_xml                 => o_xml
            , i_start_date        => i_start_date
            , i_end_date          => i_end_date
            , i_inst_id           => i_inst_id
            , i_card_network_id   => i_netw_id
            , i_mcc               => null
            , i_merchant_number   => null
            , i_merchant_country  => i_country
            , i_count             => i_count
            , i_report_type       => TOTAL_AUTH_TYPE_COUNTRY
            , i_lang              => i_lang
        );
    end;

    procedure total_invalid_pin (
        o_xml                      out clob
        , i_inst_id                in com_api_type_pkg.t_inst_id     default null
        , i_netw_id                in com_api_type_pkg.t_network_id  default null
        , i_start_date             in date
        , i_end_date               in date
        , i_lang                   in com_api_type_pkg.t_dict_value
        , i_count                  in com_api_type_pkg.t_short_id
    ) is
        l_start_date               date;
        l_end_date                 date;
        l_start_id                 com_api_type_pkg.t_long_id;
        l_end_id                   com_api_type_pkg.t_long_id;
        l_lang                     com_api_type_pkg.t_dict_value;
        l_inst_id                  com_api_type_pkg.t_inst_id;
        l_netw_id                  com_api_type_pkg.t_network_id;
        l_count                    number(4);

        l_detail                   xmltype;
        l_result                   xmltype;

    begin
        trc_log_pkg.debug (
            i_text          => 'vis_api_report_pkg.total_invalid_pin [#1][#2][#3][#4][#5]'
            , i_env_param1  => i_inst_id
            , i_env_param2  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
            , i_env_param3  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
            , i_env_param4  => i_count
            , i_env_param5  => i_netw_id
        );

        l_lang       := nvl(i_lang, get_user_lang);
        l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
        l_end_date   := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
        l_inst_id    := nvl(i_inst_id, 0);
        l_netw_id    := nvl(i_netw_id, 0);
        -- min value 1
        l_count      := nvl(i_count, 1);

        l_start_id   := com_api_id_pkg.get_from_id(l_start_date);
        l_end_id     := com_api_id_pkg.get_till_id(l_end_date);

        -- details
        begin
            select
                xmlelement("cards"
                     , xmlagg(
                        xmlelement("card"
                             , xmlelement("card_number", iss_api_card_pkg.get_card_mask(iss_api_token_pkg.decode_card_number(i_card_number => card_number)))
                             , xmlelement("cnt", cnt)
                        )
                        order by cnt
                               , card_number
                     )
               )
              into l_detail
              from (
                  select c.card_number as card_number
                       , count(1) as cnt
                    from opr_operation o
                       , opr_participant p
                       , opr_card c
                       , aut_auth a
                    where o.id between l_start_id and l_end_id
                      and o.oper_date between l_start_date and l_end_date
                      and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                      and p.oper_id          = o.id 
                      and c.oper_id          = o.id
                      and c.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                      and a.id               = o.id
                      and a.resp_code        = aup_api_const_pkg.RESP_CODE_INVALID_PIN
                      and (l_inst_id = 0 or p.inst_id = l_inst_id)
                      and (l_netw_id = 0 or p.card_network_id = l_netw_id)
                    group by c.card_number
                    having count(1) > l_count
              );
        exception
            when no_data_found then
                select
                    xmlelement("cards", '')
                into
                    l_detail
                from
                    dual;
        end;

        select
            xmlelement (
                "report"
                , get_header(l_inst_id, l_netw_id, l_start_date, l_end_date, l_lang, l_count)
                , l_detail
            ) r
        into
            l_result
        from
            dual;

        o_xml := l_result.getclobval();

        trc_log_pkg.debug (
            i_text => 'vis_api_report_pkg.total_invalid_pin - ok'
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text   => sqlerrm
            );
            raise;
    end;

    procedure total_pos_mode_02 (
        o_xml                      out clob
        , i_inst_id                in com_api_type_pkg.t_inst_id default null
        , i_netw_id                in com_api_type_pkg.t_network_id default null
        , i_start_date             in date
        , i_end_date               in date
        , i_lang                   in com_api_type_pkg.t_dict_value
        , i_count                  in com_api_type_pkg.t_short_id
    ) is
        l_start_date               date;
        l_end_date                 date;
        l_lang                     com_api_type_pkg.t_dict_value;
        l_inst_id                  com_api_type_pkg.t_inst_id;
        l_netw_id                  com_api_type_pkg.t_network_id;
        l_count                    number(4);

        l_detail                   xmltype;
        l_result                   xmltype;

    begin
        trc_log_pkg.debug (
            i_text          => 'vis_api_report_pkg.total_pos_mode_02 [#1][#2][#3][#4][#5]'
            , i_env_param1  => i_inst_id
            , i_env_param2  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
            , i_env_param3  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
            , i_env_param4  => i_count
            , i_env_param5  => l_netw_id
        );

        l_lang := nvl(i_lang, get_user_lang);
        l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
        l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
        l_inst_id := nvl(i_inst_id, 0);
        l_netw_id := nvl(i_netw_id, 0);
        -- min value 1
        l_count := nvl(i_count, 1);

        -- details
        begin
            select
                xmlelement("transactions"
                  , xmlagg(
                        xmlelement("transaction"
                             , xmlelement("card_number", card_number)
                             , xmlelement("cnt", cnt)
                        )
                        order by cnt
                               , card_number
                    )
                )
            into
                l_detail
            from (
                select iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
                     , count(1) as cnt
                  from aut_auth a
                     , opr_operation o
                     , opr_card c
                     , opr_participant p_iss
                 where a.id = o.id
                   and o.id = p_iss.oper_id
                   and o.id = c.oper_id
                   and p_iss.participant_type = 'PRTYISS'
                   and a.card_data_input_mode = 'F227000B' -- code 02
                   and o.id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
                   and o.oper_date between l_start_date and l_end_date
                   and (l_inst_id = 0 or p_iss.inst_id = l_inst_id)
                   and (l_netw_id = 0 or p_iss.card_network_id = l_netw_id)
              group by c.card_number
                having count(1) > l_count
            );
        exception
            when no_data_found then
                select
                    xmlelement("transactions", '')
                into
                    l_detail
                from
                    dual;
        end;

        select
            xmlelement (
                "report"
                , get_header(l_inst_id, l_netw_id, l_start_date, l_end_date, l_lang, l_count)
                , l_detail
            ) r
        into
            l_result
        from
            dual;

        o_xml := l_result.getclobval();

        trc_log_pkg.debug (
            i_text => 'vis_api_report_pkg.total_pos_mode_02 - ok'
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text   => sqlerrm
            );
            raise;
    end;

    procedure total_amount_auths (
        o_xml                      out clob
        , i_inst_id                in com_api_type_pkg.t_inst_id default null
        , i_netw_id                in com_api_type_pkg.t_network_id default null
        , i_start_date             in date
        , i_end_date               in date
        , i_currency               in com_api_type_pkg.t_curr_code
        , i_lang                   in com_api_type_pkg.t_dict_value
        , i_mcc                    in com_api_type_pkg.t_mcc default null
        , i_country                in com_api_type_pkg.t_country_code default null
        , i_sum                    in number
    ) is
        l_start_date               date;
        l_end_date                 date;
        l_lang                     com_api_type_pkg.t_dict_value;
        l_inst_id                  com_api_type_pkg.t_inst_id;
        l_netw_id                  com_api_type_pkg.t_network_id;
        l_sum                      number(22,4);
        l_mcc                      com_api_type_pkg.t_mcc;
        l_country                  com_api_type_pkg.t_country_code;
        l_currency                 com_api_type_pkg.t_curr_code;

        l_detail                   xmltype;
        l_result                   xmltype;

    begin
        trc_log_pkg.debug (
            i_text          => 'vis_api_report_pkg.total_amount_auths [#1][#2][#3][#4][#5][#6]'
            , i_env_param1  => i_inst_id
            , i_env_param2  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
            , i_env_param3  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
            , i_env_param4  => i_mcc
            , i_env_param5  => i_country
            , i_env_param6  => i_sum
            --, i_env_param7  => i_currency  not enough parameters
        );

        l_lang := nvl(i_lang, get_user_lang);
        l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
        l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
        l_inst_id := nvl(i_inst_id, 0);
        l_netw_id := nvl(i_netw_id, 0);
        l_currency := nvl(i_currency, 0);
        l_mcc := nvl(i_mcc, 0);
        l_country := nvl(i_country, 0);
        -- min value 1
        l_sum := nvl(i_sum, 1);

        -- details
        begin
            -- Total authorization value exceeds pre-defined limit in a pre-defined time in specific MCCs
            if l_mcc <> 0 then
                select
                    xmlelement("auths"
                      , xmlagg(
                            xmlelement("auth"
                              , xmlelement("card_number", card_number)
                              , xmlelement("summ", summ)
                            )
                            order by summ
                        )
                    )
                into
                    l_detail
                from (
                    select iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
                         --, sum(o.oper_amount) summ
                         , sum( o.oper_amount / power (10, nvl(y.exponent,0)) ) as summ
                      from aut_auth a
                         , opr_operation o
                         , opr_card c
                         , opr_participant p_iss
                         , com_currency y
                     where a.id = o.id
                       and o.id = p_iss.oper_id
                       and o.id = c.oper_id
                       and p_iss.participant_type = 'PRTYISS'
                       and y.code(+) = o.oper_currency
                       and o.status = 'OPST0400' -- autorization completed
                       and o.msg_type = 'MSGTCMPL'
                       and o.oper_currency = l_currency
                       and o.mcc = l_mcc
                       and o.id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
                       and o.oper_date between l_start_date and l_end_date
                       and (l_inst_id = 0 or p_iss.inst_id = l_inst_id)
                       and (l_netw_id = 0 or p_iss.card_network_id = l_netw_id)
                  group by c.card_number
                    having sum(o.oper_amount) > l_sum
                );
            -- Total authorization value exceeds pre-defined limit in a pre-defined time in specific country.
            elsif l_country <> 0 then
                select
                    xmlelement("auths"
                      , xmlagg(
                            xmlelement("auth"
                              , xmlelement("card_number", card_number)
                              , xmlelement("summ", summ)
                            )
                            order by summ
                        )
                    )
                into
                    l_detail
                from (
                    select iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
                         --, sum(o.oper_amount) summ
                         , sum( o.oper_amount / power (10, nvl(y.exponent,0)) ) as summ
                      from aut_auth a
                         , opr_operation o
                         , opr_card c
                         , opr_participant p_iss
                         , com_currency y
                     where a.id = o.id
                       and o.id = p_iss.oper_id
                       and o.id = c.oper_id
                       and p_iss.participant_type = 'PRTYISS'
                       and y.code(+) = o.oper_currency
                       and o.status = 'OPST0400' -- autorization completed
                       and o.msg_type = 'MSGTCMPL'
                       and o.oper_currency = l_currency
                       and o.merchant_country = l_country
                       and o.id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
                       and o.oper_date between l_start_date and l_end_date
                       and (l_inst_id = 0 or p_iss.inst_id = l_inst_id)
                       and (l_netw_id = 0 or p_iss.card_network_id = l_netw_id)
                  group by c.card_number
                    having sum(o.oper_amount) > l_sum
                );
            else
                -- Total authorization value exceeds pre-defined limit in a pre-defined time
                select
                    xmlelement("auths"
                      , xmlagg(
                            xmlelement("auth"
                              , xmlelement("card_number", card_number)
                              , xmlelement("summ", summ)
                            )
                            order by summ
                        )
                    )
                into
                    l_detail
                from (
                    select iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
                         --, sum(o.oper_amount) summ
                         , sum( o.oper_amount / power (10, nvl(y.exponent,0)) ) as summ
                      from aut_auth a
                         , opr_operation o
                         , opr_card c
                         , opr_participant p_iss
                         , com_currency y
                     where a.id = o.id
                       and o.id = p_iss.oper_id
                       and o.id = c.oper_id
                       and p_iss.participant_type = 'PRTYISS'
                       and y.code(+) = o.oper_currency
                       and o.status = 'OPST0400' -- autorization completed
                       and o.msg_type = 'MSGTCMPL'
                       and o.oper_currency = l_currency
                       and o.id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
                       and o.oper_date between l_start_date and l_end_date
                       and (l_inst_id = 0 or p_iss.inst_id = l_inst_id)
                       and (l_netw_id = 0 or p_iss.card_network_id = l_netw_id)
                  group by c.card_number
                    having sum(o.oper_amount) > l_sum
                  order by sum(o.oper_amount)
                );
            end if;
        exception
            when no_data_found then
                select
                    xmlelement("auths", '')
                into
                    l_detail
                from
                    dual;
        end;

        select
            xmlelement (
                "report"
                , get_header(l_inst_id, l_netw_id, l_start_date, l_end_date, l_currency, l_mcc, l_country, l_sum, l_lang)
                , l_detail
            ) r
        into
            l_result
        from
            dual;

        o_xml := l_result.getclobval();

        trc_log_pkg.debug (
            i_text => 'vis_api_report_pkg.total_amount_auths - ok'
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text   => sqlerrm
            );
            raise;
    end;

    procedure total_amount_individual (
        o_xml                      out clob
        , i_inst_id                in com_api_type_pkg.t_inst_id default null
        , i_netw_id                in com_api_type_pkg.t_network_id default null
        , i_start_date             in date
        , i_end_date               in date
        , i_currency               in com_api_type_pkg.t_curr_code
        , i_lang                   in com_api_type_pkg.t_dict_value
        , i_mcc                    in com_api_type_pkg.t_mcc default null
        , i_country                in com_api_type_pkg.t_country_code default null
        , i_sum                    in number
    ) is
        l_start_date               date;
        l_end_date                 date;
        l_lang                     com_api_type_pkg.t_dict_value;
        l_inst_id                  com_api_type_pkg.t_inst_id;
        l_netw_id                  com_api_type_pkg.t_network_id;
        l_sum                      number(22,4);
        l_mcc                      com_api_type_pkg.t_mcc;
        l_country                  com_api_type_pkg.t_country_code;
        l_currency                 com_api_type_pkg.t_curr_code;

        l_detail                   xmltype;
        l_result                   xmltype;

    begin
        trc_log_pkg.debug (
            i_text          => 'vis_api_report_pkg.total_amount_individual [#1][#2][#3][#4][#5][#6]'
            , i_env_param1  => i_inst_id
            , i_env_param2  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
            , i_env_param3  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
            , i_env_param4  => i_mcc
            , i_env_param5  => i_country
            , i_env_param6  => i_sum
            --, i_env_param7  => i_currency not enough parameters
        );

        l_lang := nvl(i_lang, get_user_lang);
        l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
        l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
        l_inst_id := nvl(i_inst_id, 0);
        l_netw_id := nvl(i_netw_id, 0);
        l_currency := nvl(i_currency, 643);
        l_mcc := nvl(i_mcc, 0);
        l_country := nvl(i_country, 0);
        -- min value 1
        l_sum := nvl(i_sum, 1);

        -- details
        begin
            -- Individual authorizations exceed pre-defined limit in specific MCC
            if l_mcc <> 0 then
                select
                    xmlelement("auths"
                      , xmlagg(
                            xmlelement("auth"
                              , xmlelement("card_number", card_number)
                              , xmlelement("summ", summ)
                            )
                            order by summ
                        )
                    )
                into
                    l_detail
                from (
                    select iss_api_card_pkg.get_card_mask(c.card_number) as card_number
                         --, o.oper_amount summ
                         , o.oper_amount / power (10, nvl(x.exponent,0)) as summ
                      from opr_operation o
                         , opr_card c
                         , opr_participant p_iss
                         , com_currency x
                     where o.id = p_iss.oper_id
                       and o.id = c.oper_id
                       and p_iss.participant_type = 'PRTYISS'
                       and x.code(+) = o.oper_currency
                       and o.status = 'OPST0400' -- autorization completed
                       and o.msg_type = 'MSGTCMPL'
                       and o.oper_currency = l_currency
                       and o.mcc = l_mcc
                       and o.id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
                       and o.oper_date between l_start_date and l_end_date
                       and (l_inst_id = 0 or p_iss.inst_id = l_inst_id)
                       and (l_netw_id = 0 or p_iss.card_network_id = l_netw_id)
                       and o.oper_amount > l_sum
                );
            -- Individual authorizations exceed pre-defined limit in specific country
            elsif l_country <> 0 then
                select
                    xmlelement("auths"
                      , xmlagg(
                            xmlelement("auth"
                              , xmlelement("card_number", card_number)
                              , xmlelement("summ", summ)
                            )
                            order by summ
                        )
                    )
                into
                    l_detail
                from (
                    select iss_api_card_pkg.get_card_mask(c.card_number) as card_number
                         --, o.oper_amount summ
                         , o.oper_amount / power (10, nvl(x.exponent,0)) as summ
                      from opr_operation o
                         , opr_card c
                         , opr_participant p_iss
                         , com_currency x
                     where o.id = p_iss.oper_id
                       and o.id = c.oper_id
                       and p_iss.participant_type = 'PRTYISS'
                       and x.code(+) = o.oper_currency
                       and o.status = 'OPST0400' -- autorization completed
                       and o.msg_type = 'MSGTCMPL'
                       and o.oper_currency = l_currency
                       and o.merchant_country = l_country
                       and o.id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
                       and o.oper_date between l_start_date and l_end_date
                       and (l_inst_id = 0 or p_iss.inst_id = l_inst_id)
                       and (l_netw_id = 0 or p_iss.card_network_id = l_netw_id)
                       and o.oper_amount > l_sum
                );
            else
                -- Individual authorizations value exceeds pre-defined limit
                select
                    xmlelement("auths"
                      , xmlagg(
                            xmlelement("auth"
                              , xmlelement("card_number", card_number)
                              , xmlelement("summ", summ)
                            )
                            order by summ
                        )
                    )
                into
                    l_detail
                from (
                    select iss_api_card_pkg.get_card_mask(c.card_number) as card_number
                         --, o.oper_amount summ
                         , o.oper_amount / power (10, nvl(x.exponent,0)) as summ
                      from opr_operation o
                         , opr_card c
                         , opr_participant p_iss
                         , com_currency x
                     where o.id = p_iss.oper_id
                       and o.id = c.oper_id
                       and p_iss.participant_type = 'PRTYISS'
                       and x.code(+) = o.oper_currency
                       and o.status = 'OPST0400' -- autorization completed
                       and o.msg_type = 'MSGTCMPL'
                       and o.oper_currency = l_currency
                       and o.id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
                       and o.oper_date between l_start_date and l_end_date
                       and (l_inst_id = 0 or p_iss.inst_id = l_inst_id)
                       and (l_netw_id = 0 or p_iss.card_network_id = l_netw_id)
                       and o.oper_amount > l_sum
                );
            end if;
        exception
            when no_data_found then
                select
                    xmlelement("auths", '')
                into
                    l_detail
                from
                    dual;
        end;

        select
            xmlelement (
                "report"
                , get_header(l_inst_id, l_netw_id, l_start_date, l_end_date, l_currency, l_mcc, l_country, l_sum, l_lang)
                , l_detail
            ) r
        into
            l_result
        from
            dual;

        o_xml := l_result.getclobval();

        trc_log_pkg.debug (
            i_text => 'vis_api_report_pkg.total_amount_individual - ok'
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text   => sqlerrm
            );
            raise;
    end;

   procedure total_auths_of_country (
        o_xml                      out clob
        , i_inst_id                in com_api_type_pkg.t_inst_id default null
        , i_netw_id                in com_api_type_pkg.t_network_id default null
        , i_start_date             in date
        , i_end_date               in date
        , i_lang                   in com_api_type_pkg.t_dict_value
    ) is
        l_start_date               date;
        l_end_date                 date;
        l_lang                     com_api_type_pkg.t_dict_value;
        l_inst_id                  com_api_type_pkg.t_inst_id;
        l_netw_id                  com_api_type_pkg.t_network_id;

        l_header                   xmltype;
        l_detail                   xmltype;
        l_result                   xmltype;

    begin
        trc_log_pkg.debug (
            i_text          => 'vis_api_report_pkg.total_auths_of_country [#1][#2][#3][#4]'
            , i_env_param1  => i_inst_id
            , i_env_param2  => i_netw_id
            , i_env_param3  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
            , i_env_param4  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
        );

        l_lang := nvl(i_lang, get_user_lang);
        l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
        l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
        l_inst_id := nvl(i_inst_id, 0);
        l_netw_id := nvl(i_netw_id, 0);

        -- header
        select
            xmlconcat(
                xmlelement("inst", l_inst_id)
                , xmlelement("netw", case when l_netw_id <> 0 
                                          then com_api_i18n_pkg.get_text('NET_NETWORK', 'NAME', l_netw_id, l_lang)
                                          else to_char(l_netw_id)
                                     end)
                , xmlelement("start_date", to_char(l_start_date, 'dd.mm.yyyy'))
                , xmlelement("end_date", to_char(l_end_date, 'dd.mm.yyyy'))
            )
        into l_header from dual;

        -- details
        begin
            select
                xmlelement("auths"
                  , xmlagg(
                        xmlelement("auth"
                          , xmlelement("card_number", card_number)
                          , xmlelement("cnt", cnt)
                        )
                        order by cnt
                               , card_number
                    )
                )
            into
                l_detail
            from (
                select iss_api_card_pkg.get_card_mask(c.card_number) as card_number
                     , count(distinct o.merchant_country) cnt
                  from aut_auth a
                     , opr_operation o
                     , opr_participant p_iss
                     , opr_card c
                 where a.id = o.id
                   and o.id = p_iss.oper_id
                   and o.id = c.oper_id
                   and p_iss.participant_type = 'PRTYISS'
                   and o.status = 'OPST0400' -- autorization completed
                   and o.msg_type = 'MSGTCMPL'
                   and o.id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
                   and o.oper_date between l_start_date and l_end_date
                   and (l_inst_id = 0 or p_iss.inst_id = l_inst_id)
                   and (l_netw_id = 0 or p_iss.card_network_id = l_netw_id)
              group by c.card_number
                having count(distinct o.merchant_country) > 1
            );
        exception
            when no_data_found then
                select
                    xmlelement("auths", '')
                into
                    l_detail
                from
                    dual;
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
            i_text => 'vis_api_report_pkg.total_auths_of_country - ok'
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text   => sqlerrm
            );
            raise;
    end;

   procedure auths_high_amount (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_netw_id                    in com_api_type_pkg.t_network_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_currency                   in com_api_type_pkg.t_curr_code
        , i_interval                   in number
        , i_percent                    in number
        , i_lang                       in com_api_type_pkg.t_dict_value
    ) is
        l_interval                     number(2);
        l_percent                      number(2);
        l_start_date                   date;
        l_end_date                     date;
        l_lang                         com_api_type_pkg.t_dict_value;
        l_inst_id                      com_api_type_pkg.t_inst_id;
        l_netw_id                      com_api_type_pkg.t_network_id;
        l_currency                     com_api_type_pkg.t_curr_code;

        l_header                       xmltype;
        l_detail                       xmltype;
        l_result                       xmltype;

    begin
        trc_log_pkg.debug (
            i_text          => 'vis_api_report_pkg.auths_high_amount [#1][#2][#3][#4][#5][#6]'
            , i_env_param1  => i_inst_id
            , i_env_param2  => i_netw_id
            , i_env_param3  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
            , i_env_param4  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
            , i_env_param5  => i_interval
            , i_env_param6  => i_percent
        );

        l_lang := nvl(i_lang, get_user_lang);
        l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
        l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
        l_inst_id := nvl(i_inst_id, 0);
        l_netw_id := nvl(i_netw_id, 0);
        l_currency := nvl(i_currency, 0);
        l_interval := nvl(i_interval, 0);
        l_percent := nvl(i_percent, 0);

        -- header
        select
            xmlconcat(
                xmlelement("inst", l_inst_id)
                , xmlelement("netw", case when l_netw_id <> 0 then com_api_i18n_pkg.get_text('NET_NETWORK', 'NAME', l_netw_id, l_lang)
                                     else to_char(l_netw_id)
                                     end)
                , xmlelement("start_date", to_char(l_start_date, 'dd.mm.yyyy'))
                , xmlelement("end_date", to_char(l_end_date, 'dd.mm.yyyy'))
                , xmlelement("interval", l_interval)
                , xmlelement("percent", l_percent)
                , xmlelement("currency", l_currency)
            )
        into l_header from dual;

        -- details
        begin
            select
                xmlelement("auths"
                  , xmlagg(
                        xmlelement("auth"
                          , xmlelement("card_number", card_number)
                          , xmlelement("amount1", amount1)
                          , xmlelement("date1", to_char(date1, 'dd.mm.yyyy hh24:mi:ss'))
                          , xmlelement("amount2", amount2)
                          , xmlelement("date2", to_char(date2, 'dd.mm.yyyy hh24:mi:ss'))
                        )
                    )
                )
            into
                l_detail
            from (
                with auth as (
                    select o.id id1
                         , last_value(o.id) over 
                               (partition by c.card_number 
                                    order by oper_date range between current row and numtodsinterval(l_interval, 'MINUTE') following
                                ) id2
                      from aut_auth a
                         , opr_operation o
                         , opr_card c
                         , opr_participant p_iss
                     where a.id = o.id
                       and o.id = p_iss.oper_id
                       and o.id = c.oper_id
                       and p_iss.participant_type = 'PRTYISS'
                       and o.oper_currency = l_currency
                       and o.id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
                       and o.oper_date between l_start_date and l_end_date
                       and (l_inst_id = 0 or p_iss.inst_id = l_inst_id)
                       and (l_netw_id = 0 or p_iss.card_network_id = l_netw_id)
                       and nvl(o.oper_amount, 0) > 0
                )
                select r.id1
                     , iss_api_card_pkg.get_card_mask(c.card_number) as card_number
                     --, o.oper_amount amount1
                     , o.oper_amount / power (10, nvl(x.exponent,0)) as amount1
                     , o.oper_date date1
                     , r.id2
                     --, o2.oper_amount amount2
                     , o2.oper_amount / power (10, nvl(x2.exponent,0)) as amount2
                     , o2.oper_date date2
                     , round(o2.oper_amount * 100/o.oper_amount, 2) as percent
                  from opr_operation o
                     , opr_card c
                     , auth r
                     , opr_operation o2
                     , com_currency x
                     , com_currency x2
                 where r.id1 = o.id
                   and c.oper_id = o.id
                   and x.code(+) = o.oper_currency
                   and x2.code(+) = o2.oper_currency
                   and r.id2 = o2.id
                   and r.id1 <> r.id2
                   and round(o2.oper_amount * 100/o.oper_amount, 2) < l_percent
              order by c.card_number, o.oper_date
             );
        exception
            when no_data_found then
                select
                    xmlelement("auths", '')
                into
                    l_detail
                from
                    dual;
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
            i_text => 'vis_api_report_pkg.auths_high_amount - ok'
        );

    exception
        when others then
            trc_log_pkg.debug (
                i_text   => sqlerrm
            );
            raise;
    end;

   procedure auths_manual_input (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_netw_id                    in com_api_type_pkg.t_network_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_percent                    in number
        , i_lang                       in com_api_type_pkg.t_dict_value
    ) is
        l_percent                      number(2);
        l_start_date                   date;
        l_end_date                     date;
        l_lang                         com_api_type_pkg.t_dict_value;
        l_inst_id                      com_api_type_pkg.t_inst_id;
        l_netw_id                      com_api_type_pkg.t_network_id;

        l_header                       xmltype;
        l_detail                       xmltype;
        l_result                       xmltype;

    begin
        trc_log_pkg.debug (
            i_text          => 'vis_api_report_pkg.auths_manual_input [#1][#2][#3][#4][#5]'
            , i_env_param1  => i_inst_id
            , i_env_param2  => i_netw_id
            , i_env_param3  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
            , i_env_param4  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
            , i_env_param5  => i_percent
        );

        l_lang := nvl(i_lang, get_user_lang);
        l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
        l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
        l_inst_id := nvl(i_inst_id, 0);
        l_netw_id := nvl(i_netw_id, 0);
        l_percent := nvl(i_percent, 0);

        -- header
        select
            xmlconcat(
                xmlelement("inst", l_inst_id)
                , xmlelement("netw", case when l_netw_id <> 0
                                          then com_api_i18n_pkg.get_text('NET_NETWORK', 'NAME', l_netw_id, l_lang)
                                          else to_char(l_netw_id)
                                     end)
                , xmlelement("start_date", to_char(l_start_date, 'dd.mm.yyyy'))
                , xmlelement("end_date", to_char(l_end_date, 'dd.mm.yyyy'))
                , xmlelement("percent", l_percent)
            )
        into l_header from dual;

        -- details
        begin
            select
                xmlelement("auths"
                  , xmlagg(
                        xmlelement("auth"
                          , xmlelement("card_number", card_number)
                          , xmlelement("key_auth", key_auth)
                          , xmlelement("total_auth", total_auth)
                          , xmlelement("percent", prc)
                        )
                        order by card_number
                    )
                )
            into
                l_detail
            from (
                with tbl as (
                    select c.card_number
                         , p_iss.card_id
                         , count(o.id) cnt1
                      from aut_auth a
                         , opr_operation o
                         , opr_card c
                         , opr_participant p_iss
                     where a.id = o.id
                       and o.id = p_iss.oper_id
                       and o.id = c.oper_id
                       and p_iss.participant_type = 'PRTYISS'
                       and a.card_data_input_mode = 'F2270001' -- code
                       and o.id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
                       and o.oper_date between l_start_date and l_end_date
                       and (l_inst_id = 0 or p_iss.inst_id = l_inst_id)
                       and (l_netw_id = 0 or p_iss.card_network_id = l_netw_id)
                  group by c.card_number
                         , p_iss.card_id
                )
                select iss_api_token_pkg.decode_card_number(i_card_number => t.card_number) as card_number
                     , t.cnt1 key_auth
                     , count(o.id) total_auth
                     , round(t.cnt1/count(o.id), 2)*100 prc
                  from aut_auth a
                     , opr_operation o
                     , opr_card c
                     , opr_participant p_iss
                     , tbl t
                 where a.id = o.id
                   and o.id = p_iss.oper_id
                   and o.id = c.oper_id
                   and p_iss.participant_type = 'PRTYISS'
                   and t.card_id = p_iss.card_id
                   and o.id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
                   and o.oper_date between l_start_date and l_end_date
                   and (l_inst_id = 0 or p_iss.inst_id = l_inst_id)
                   and (l_netw_id = 0 or p_iss.card_network_id = l_netw_id)
              group by t.card_number
                     , t.cnt1
                having round(t.cnt1/count(o.id), 2)*100 >= l_percent
              order by t.card_number
               );
        exception
            when no_data_found then
                select
                    xmlelement("auths", '')
                into
                    l_detail
                from
                    dual;
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
            i_text => 'vis_api_report_pkg.auths_manual_input - ok'
        );

    exception
        when others then
            trc_log_pkg.debug (
                i_text   => sqlerrm
            );
            raise;
    end;

    procedure percent_use_balance (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_netw_id                    in com_api_type_pkg.t_network_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_currency                   in com_api_type_pkg.t_curr_code
        , i_algorithm                  in com_api_type_pkg.t_dict_value
        , i_percent                    in number
        , i_lang                       in com_api_type_pkg.t_dict_value
    ) is
        l_percent                      number(2);
        l_start_date                   date;
        l_end_date                     date;
        l_lang                         com_api_type_pkg.t_dict_value;
        l_inst_id                      com_api_type_pkg.t_inst_id;
        l_netw_id                      com_api_type_pkg.t_network_id;
        l_currency                     com_api_type_pkg.t_curr_code;
        l_algorithm                    com_api_type_pkg.t_dict_value;

        l_header                       xmltype;
        l_detail                       xmltype;
        l_result                       xmltype;

    begin
        trc_log_pkg.debug (
            i_text          => 'vis_api_report_pkg.percent_use_balance [#1][#2][#3][#4][#5][#6]'
            , i_env_param1  => i_inst_id
            , i_env_param2  => i_netw_id
            , i_env_param3  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
            , i_env_param4  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
            , i_env_param5  => i_percent
            , i_env_param6  => i_algorithm
        );

        l_lang := nvl(i_lang, get_user_lang);
        l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
        l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
        l_inst_id := nvl(i_inst_id, 0);
        l_netw_id := nvl(i_netw_id, 0);
        l_percent := nvl(i_percent, 50);
        l_currency := nvl(i_currency, 643);
        l_algorithm := nvl(i_algorithm, VIS_API_CONST_PKG.ALG_CALC_BALANCE_AVERAGE);

        -- header
        begin
            select
                xmlconcat(
                    xmlelement("inst", l_inst_id)
                    , xmlelement("netw", case when l_netw_id <> 0 then com_api_i18n_pkg.get_text('NET_NETWORK', 'NAME', l_netw_id, l_lang)
                                         else to_char(l_netw_id)
                                         end)
                    , xmlelement("start_date", to_char(l_start_date, 'dd.mm.yyyy'))
                    , xmlelement("end_date", to_char(l_end_date, 'dd.mm.yyyy'))
                    , xmlelement("percent", l_percent)
                    , xmlelement("currency", l_currency)
                    , xmlelement("algorithm", text)
                )
            into l_header
            from (
                  select text from com_i18n
                  where object_id = (select id from com_dictionary where dict = substr(l_algorithm, 1, 4) and code = substr(l_algorithm, 5, 4))
                    and table_name = 'COM_DICTIONARY'
                    and lang = l_lang
            );

        exception
            when no_data_found then
                select
                    xmlelement("report", '')
                into
                    l_header
                from
                    dual;
        end;

        -- details
        begin
            select
                xmlelement("rows"
                  , xmlagg(
                        xmlelement("row"
                          , xmlelement("day", to_char(oper_date, 'dd.mm.yyyy'))
                          , xmlelement("card_number", card_number)
                          , xmlelement("account_number", account_number)
                          , xmlelement("percent", prc)
                        )
                    )
                )
            into
                l_detail
            from (
                with opr as (
                    select trunc(o.oper_date) oper_date
                         , sum(o.oper_amount) amount
                         , c.card_number
                         , p_iss.account_id
                      from aut_auth a
                         , opr_operation o
                         , opr_card c
                         , opr_participant p_iss
                     where a.id = o.id
                       and o.id = p_iss.oper_id
                       and o.id = c.oper_id
                       and p_iss.participant_type = 'PRTYISS'
                       and o.oper_currency = l_currency
                       and o.id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
                       and o.oper_date between l_start_date and l_end_date
                       and (l_inst_id = 0 or p_iss.inst_id = l_inst_id)
                       and (l_netw_id = 0 or p_iss.card_network_id = l_netw_id)
                  group by trunc(o.oper_date)
                         , c.card_number
                         , p_iss.account_id
                ),
                bal as (
                    select period_day
                         , account_id
                         , account_number
                         , sum(begin_balance) begin_balance
                         , sum(end_balance) end_balance
                     from (
                         select period_day
                              , account_id
                              , account_number
                              , balance_type
                              , lag(end_balance) over (partition by account_id, balance_type order by period_day) begin_balance
                              , end_balance
                           from (
                               select d.period_day
                                    , b.account_id
                                    , a.account_number
                                    , b.balance_type
                                    , b.balance -
                                    nvl(
                                        sum(-1 * e.balance_impact * case when d.period_day < trunc(e.posting_date) then
                                                                            case when e.currency = l_currency then e.amount
                                                                                 else com_api_rate_pkg.convert_amount(e.amount, e.currency, l_currency, t.rate_type, a.inst_id, period_day)
                                                                            end
                                                                       else 0
                                                                  end)
                                        , 0
                                       ) end_balance
                                 from (
                                        select l_start_date + rownum - 2 period_day
                                          from dual connect by rownum <= (l_end_date - l_start_date + 2)
                                       ) d
                                     , acc_entry e
                                     , acc_balance b
                                     , acc_account a
                                     , acc_balance_type t
                                 where e.posting_date >= l_start_date
                                   and e.id >= com_api_id_pkg.get_from_id(l_start_date)
                                   and e.account_id    = b.account_id
                                   and e.balance_type  = b.balance_type
                                   and e.account_id = a.id
                                   and t.account_type = a.account_type
                                   and t.inst_id = a.inst_id
                                   and t.aval_impact != 0
                                   and t.balance_type = b.balance_type
                                 group by b.account_id
                                     , b.balance_type
                                     , b.balance
                                     , d.period_day
                                     , a.account_number
                           )
                     )
                     where period_day >= l_start_date
                  group by period_day
                         , account_id
                         , account_number
                )
                select o.oper_date
                     , iss_api_token_pkg.decode_card_number(i_card_number => o.card_number) as card_number
                     , b.account_number
                     , o.amount s
                     , case when l_algorithm = vis_api_const_pkg.ALG_CALC_BALANCE_AVERAGE then (b.begin_balance + b.end_balance)/2
                            when l_algorithm = vis_api_const_pkg.ALG_CALC_BALANCE_MAX then greatest(b.begin_balance, b.end_balance)
                            else least(b.begin_balance, b.end_balance)
                       end bl
                     , round(case when l_algorithm = vis_api_const_pkg.ALG_CALC_BALANCE_AVERAGE then (b.begin_balance + b.end_balance)/2
                                  when l_algorithm = vis_api_const_pkg.ALG_CALC_BALANCE_MAX then greatest(b.begin_balance, b.end_balance)
                                  else least(b.begin_balance, b.end_balance)
                             end / o.amount*100) prc
                  from opr o
                     , bal b
                 where o.account_id = b.account_id
                   and o.oper_date = b.period_day
                   and round(case when l_algorithm = vis_api_const_pkg.ALG_CALC_BALANCE_AVERAGE then (b.begin_balance + b.end_balance)/2
                                  when l_algorithm = vis_api_const_pkg.ALG_CALC_BALANCE_MAX then greatest(b.begin_balance, b.end_balance)
                                  else least(b.begin_balance, b.end_balance)
                                end / o.amount*100) >= l_percent
              order by o.oper_date
                     , o.card_number
                     , b.account_number

            );
        exception
            when no_data_found then
                select
                    xmlelement("rows", '')
                into
                    l_detail
                from
                    dual;
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
            i_text => 'vis_api_report_pkg.percent_use_balance - ok'
        );

    exception
        when others then
            trc_log_pkg.debug (
                i_text   => sqlerrm
            );
            raise;
    end;

   procedure operation_visa_on_us (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_lang                       in com_api_type_pkg.t_dict_value
    ) is
        l_start_date                   date;
        l_end_date                     date;
        l_lang                         com_api_type_pkg.t_dict_value;
        l_inst_id                      com_api_type_pkg.t_inst_id;

        l_detail                       xmltype;
        l_result                       xmltype;

    begin
        trc_log_pkg.debug (
            i_text          => 'vis_api_report_pkg.operation_visa_on_us [#1][#2][#3]'
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
                xmlelement("operations"
                  , xmlagg(
                        xmlelement("operation"
                          , xmlelement("inst_id", inst_id)
                          , xmlelement("inst", inst)
                          , xmlelement("card_number", card_number)
                          , xmlelement("trans_code", trans_code)
                          , xmlelement("oper_amount", oper_amount)
                          , xmlelement("oper_currency", oper_currency)
                          , xmlelement("account_amount", account_amount)
                          , xmlelement("oper_date", to_char(oper_date, 'dd.mm.yyyy'))
                          , xmlelement("host_date", to_char(host_date, 'dd.mm.yyyy'))
                          , xmlelement("auth_code", auth_code)
                          , xmlelement("merchant_name", merchant_name)
                          , xmlelement("usage_code", usage_code)
                          , xmlelement("merchant_city", merchant_city)
                          , xmlelement("merchant_country", merchant_country)
                          , xmlelement("mcc", mcc)
                          , xmlelement("account_number", account_number)
                          , xmlelement("agent_id", agent_id)
                          , xmlelement("agent", agent)
                          , xmlelement("sttl_amount", sttl_amount)
                          , xmlelement("sttl_currency", sttl_currency)
                          , xmlelement("proc_date", to_char(proc_date, 'dd.mm.yyyy'))
                        )
                        order by inst_id
                               , agent_id
                               , card_number
                    )
                )
            into
                l_detail
            from (
                select v.inst_id
                     , com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', v.inst_id, l_lang) inst
                     , iss_api_token_pkg.decode_card_number(i_card_number => n.card_number) as card_number
                     , v.trans_code
                     --, v.oper_amount
                     , v.oper_amount / power (10, nvl(y.exponent,0)) as oper_amount 
                     , y.name oper_currency
                     --, p.account_amount
                     , p.account_amount / power (10, nvl(x.exponent,0)) as account_amount 
                     , v.oper_date
                     , o.host_date
                     , v.auth_code
                     , v.merchant_name
                     , v.usage_code
                     , v.merchant_city
                     , r.name as merchant_country
                     , v.mcc
                     , p.account_number
                     , i.agent_id
                     , com_api_i18n_pkg.get_text('OST_AGENT','NAME', i.agent_id, l_lang) as agent
                     --, v.sttl_amount
                     , v.sttl_amount / power (10, nvl(c.exponent,0)) as sttl_amount 
                     , c.name sttl_currency
                     , f.proc_date
                  from vis_fin_message v
                     , opr_operation o
                     , vis_card n
                     , opr_participant p
                     , iss_card_instance i
                     , vis_file f
                     , com_currency y
                     , com_currency c
                     , com_currency x
                     , com_country r
                 where v.id = o.id
                   and v.card_id = n.id
                   and p.oper_id = o.id
                   and p.participant_type = 'PRTYISS'
                   and i.card_id = n.id
                   and v.file_id = f.id
                   and v.is_incoming = 1
                   and y.code(+) = v.oper_currency
                   and c.code(+) = v.sttl_currency
                   and x.code(+) = p.account_currency
                   and r.code(+) = v.merchant_country
                   and o.oper_date between l_start_date and l_end_date
                   and (l_inst_id = 0 or v.inst_id = l_inst_id)
             );
        exception
            when no_data_found then
                select
                    xmlelement("operations", '')
                into
                    l_detail
                from
                    dual;
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
            i_text => 'vis_api_report_pkg.operation_visa_on_us - ok'
        );

    exception
        when others then
            trc_log_pkg.debug (
                i_text   => sqlerrm
            );
            raise;
    end;

   procedure rejected_opr_visa_on_us (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_lang                       in com_api_type_pkg.t_dict_value
    ) is
        l_start_date                   date;
        l_end_date                     date;
        l_lang                         com_api_type_pkg.t_dict_value;
        l_inst_id                      com_api_type_pkg.t_inst_id;

        l_detail                       xmltype;
        l_result                       xmltype;

    begin
        trc_log_pkg.debug (
            i_text          => 'vis_api_report_pkg.rejected_opr_visa_on_us [#1][#2][#3]'
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
                xmlelement("operations"
                  , xmlagg(
                        xmlelement("operation"
                          , xmlelement("inst_id", inst_id)
                          , xmlelement("inst", inst)
                          , xmlelement("card_number", card_number)
                          , xmlelement("trans_code", trans_code)
                          , xmlelement("oper_amount", oper_amount)
                          , xmlelement("oper_currency", oper_currency)
                          , xmlelement("account_amount", account_amount)
                          , xmlelement("oper_date", to_char(oper_date, 'dd.mm.yyyy'))
                          , xmlelement("host_date", to_char(host_date, 'dd.mm.yyyy'))
                          , xmlelement("auth_code", auth_code)
                          , xmlelement("merchant_name", merchant_name)
                          , xmlelement("usage_code", usage_code)
                          , xmlelement("merchant_city", merchant_city)
                          , xmlelement("merchant_country", merchant_country)
                          , xmlelement("mcc", mcc)
                          , xmlelement("account_number", account_number)
                          , xmlelement("agent_id", agent_id)
                          , xmlelement("agent", agent)
                          , xmlelement("sttl_amount", sttl_amount)
                          , xmlelement("sttl_currency", sttl_currency)
                          , xmlelement("reason_code", reason_code)
                        )
                        order by inst_id
                               , agent_id
                               , card_number
                    )
                )
            into
                l_detail
            from (
                select v.inst_id
                     , com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', v.inst_id, l_lang) inst
                     , iss_api_token_pkg.decode_card_number(i_card_number => n.card_number) as card_number
                     , v.trans_code
                     --, v.oper_amount
                     , v.oper_amount / power (10, nvl(y.exponent,0)) as oper_amount 
                     , y.name oper_currency
                     --, p.account_amount
                     , p.account_amount / power (10, nvl(x.exponent,0)) as account_amount 
                     , v.oper_date
                     , o.host_date
                     , v.auth_code
                     , v.merchant_name
                     , v.usage_code
                     , v.merchant_city
                     , r.name as merchant_country
                     , v.mcc
                     , p.account_number
                     , i.agent_id
                     , com_api_i18n_pkg.get_text('OST_AGENT','NAME', i.agent_id, l_lang) as agent
                     --, v.sttl_amount
                     , v.sttl_amount / power (10, nvl(c.exponent,0)) as sttl_amount
                     , c.name sttl_currency
                     , v.reason_code
                  from vis_fin_message v
                     , opr_operation o
                     , vis_card n
                     , opr_participant p
                     , iss_card_instance i
                     , vis_file f
                     , com_currency y
                     , com_currency c
                     , com_currency x
                     , com_country r
                 where v.id = o.id
                   and v.card_id = n.id
                   and p.oper_id = o.id
                   and p.participant_type = 'PRTYISS'
                   and i.card_id = n.id
                   and v.file_id = f.id
                   and v.is_incoming = 1
                   and v.is_returned = 1
                   and y.code(+) = v.oper_currency
                   and c.code(+) = v.sttl_currency
                   and x.code(+) = p.account_currency
                   and r.code(+) = v.merchant_country
                   and o.oper_date between l_start_date and l_end_date
                   and (l_inst_id = 0 or v.inst_id = l_inst_id)
             );
        exception
            when no_data_found then
                select
                    xmlelement("operations", '')
                into
                    l_detail
                from
                    dual;
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
            i_text => 'vis_api_report_pkg.rejected_opr_visa_on_us - ok'
        );

    exception
        when others then
            trc_log_pkg.debug (
                i_text   => sqlerrm
            );
            raise;
    end;

    procedure reject_opr_us_on_us (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_lang                       in com_api_type_pkg.t_dict_value
    ) is
        l_start_date                   date;
        l_end_date                     date;
        l_lang                         com_api_type_pkg.t_dict_value;
        l_inst_id                      com_api_type_pkg.t_inst_id;

        l_detail                       xmltype;
        l_result                       xmltype;

    begin
        trc_log_pkg.debug (
            i_text          => 'vis_api_report_pkg.reject_opr_us_on_us [#1][#2][#3]'
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
                xmlelement("operations"
                  , xmlagg(
                        xmlelement("operation"
                          , xmlelement("inst_id", inst_id)
                          , xmlelement("inst", inst)
                          , xmlelement("card_number", card_number)
                          , xmlelement("oper_amount", oper_amount)
                          , xmlelement("oper_currency", oper_currency)
                          , xmlelement("account_amount", account_amount)
                          , xmlelement("account_currency", account_currency)
                          , xmlelement("oper_date", to_char(oper_date, 'dd.mm.yyyy'))
                          , xmlelement("host_date", to_char(host_date, 'dd.mm.yyyy'))
                          , xmlelement("resp_code", resp_code)
                          , xmlelement("mcc", mcc)
                          , xmlelement("merchant_number", merchant_number)
                          , xmlelement("merchant_name", merchant_name)
                          , xmlelement("merchant_city", merchant_city)
                          , xmlelement("merchant_country", merchant_country)
                          , xmlelement("terminal_number", terminal_number)
                          , xmlelement("account_number", account_number)
                          , xmlelement("agent_id", agent_id)
                          , xmlelement("agent", agent)
                        )
                        order by inst_id
                               , agent_id
                               , card_number
                    )
                )
            into
                l_detail
            from (
                select p.inst_id
                     , com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', p.inst_id, l_lang) inst
                     , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
                     --, o.oper_amount
                     , o.oper_amount / power (10, nvl(r.exponent,0)) as oper_amount 
                     , r.name oper_currency
                     --, p.account_amount
                     , p.account_amount / power (10, nvl(y.exponent,0)) as account_amount 
                     , y.name account_currency
                     , o.oper_date
                     , o.host_date
                     , a.resp_code
                     , o.mcc
                     , o.merchant_number
                     , o.merchant_name
                     , o.merchant_city
                     , f.name merchant_country
                     , o.terminal_number
                     , p.account_number
                     , ac.agent_id
                     , com_api_i18n_pkg.get_text('OST_AGENT','NAME', ac.agent_id, l_lang) as agent
                  from aut_auth a
                     , opr_operation o
                     , opr_card c
                     , opr_participant p
                     , com_currency r
                     , com_currency y
                     , com_country f
                     , acc_account ac
                 where a.id = o.id
                   and o.id = c.oper_id
                   and o.id = p.oper_id
                   and p.participant_type = 'PRTYISS'
                   and o.sttl_type in ('STTT0010', 'STTT0011', 'STTT0012')
                   and r.code(+) = o.oper_currency
                   and y.code(+) = p.account_currency
                   and f.code(+) = o.merchant_country
                   and p.account_id = ac.id
                   and o.status = 'OPST0500'
                   and o.id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
                   and o.oper_date between l_start_date and l_end_date
                   and (l_inst_id = 0 or p.inst_id = l_inst_id)
             );
        exception
            when no_data_found then
                select
                    xmlelement("operations", '')
                into
                    l_detail
                from
                    dual;
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
            i_text => 'vis_api_report_pkg.reject_opr_us_on_us - ok'
        );

    exception
        when others then
            trc_log_pkg.debug (
                i_text   => sqlerrm
            );
            raise;
    end;

    procedure general_opr_us_on_us (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_lang                       in com_api_type_pkg.t_dict_value
    ) is
        l_start_date                   date;
        l_end_date                     date;
        l_lang                         com_api_type_pkg.t_dict_value;
        l_inst_id                      com_api_type_pkg.t_inst_id;
        --l_netw_id                      com_api_type_pkg.t_network_id;

        l_header                       xmltype;
        l_detail                       xmltype;
        l_result                       xmltype;
        l_logo_path                    xmltype;

    begin
        trc_log_pkg.debug (
            i_text          => 'vis_api_report_pkg.general_opr_us_on_us [#1][#2][#3][#4]'
            , i_env_param1  => i_inst_id
            , i_env_param3  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
            , i_env_param4  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
        );

        l_lang := nvl(i_lang, get_user_lang);
        l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
        l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
        l_inst_id := nvl(i_inst_id, 0);

        -- header
        l_logo_path := rpt_api_template_pkg.logo_path_xml;
        select
            xmlconcat(
                xmlelement("inst_id", l_inst_id)
                , l_logo_path
                , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
                , xmlelement("start_date", to_char(l_start_date, 'dd.mm.yyyy'))
                , xmlelement("end_date", to_char(l_end_date, 'dd.mm.yyyy'))
            )
        into l_header from dual;

        -- details
        begin
         
            select
                case when count(1) = 0 then          
                    xmlelement ("operations"
                        , xmlelement("operation", null)
                        )        
                else              
                    xmlelement("operations"
                      , xmlagg(
                            xmlelement("operation"
                              , xmlelement("inst_id", inst_id)
                              , xmlelement("inst", inst)
                              , xmlelement("transaction_type", transaction_type)
                              , xmlelement("amount", amount)
                              , xmlelement("currency", currency)
                              , xmlelement("count", cnt)
                            )
                            order by inst_id
                        )
                    )
                end    
            into
                l_detail
            from (
                select b.inst_id
                     , com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', b.inst_id, l_lang) inst
                     , b.oper_type as transaction_type
                     , b.amount
                     , b.currency
                     , b.cnt
                 from (
                     select p.inst_id
                          , o.oper_type || ' - ' || i.text as oper_type
                          --, sum(o.oper_amount) amount
                          , sum( o.oper_amount / power (10, nvl(r.exponent,0)) ) as amount 
                          , r.name currency
                          , count(1) cnt
                       from aut_auth a
                          , opr_operation o
                          , opr_participant p
                          , com_currency r
                          , com_dictionary d
                          , com_i18n i
                      where a.id = o.id
                        and o.id = p.oper_id
                        and p.participant_type = 'PRTYISS'
                        and o.sttl_type in ('STTT0010', 'STTT0011', 'STTT0012')
                        and r.code(+) = o.oper_currency
                        and o.id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
                        and o.oper_date between l_start_date and l_end_date
                        and (l_inst_id = 0 or p.inst_id = l_inst_id)
                        and o.oper_type = d.dict || d.code
                        and d.id = i.object_id
                        and i.lang = i_lang
                        and i.table_name = 'COM_DICTIONARY'
                        and i.column_name = 'NAME'
                   group by p.inst_id
                          , o.oper_type || ' - ' || i.text
                          , r.name
                 ) b
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
            i_text => 'vis_api_report_pkg.general_opr_us_on_us - ok'
        );

    exception
        when others then
            trc_log_pkg.debug (
                i_text   => sqlerrm
            );
            raise;
    end;

   procedure vss_reconciliation (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id
        , i_reconciliation_date        in date
        , i_lang                       in com_api_type_pkg.t_dict_value
    ) is
        l_reconciliation_date          date;
        l_lang                         com_api_type_pkg.t_dict_value;
        l_inst_id                      com_api_type_pkg.t_inst_id;

        l_header                       xmltype;
        l_detail                       xmltype;
        l_result                       xmltype;

    begin
        trc_log_pkg.debug (
            i_text          => 'vis_api_report_pkg.vss_reconciliation [#1][#2]]'
            , i_env_param1  => i_inst_id
            , i_env_param2  => com_api_type_pkg.convert_to_char(trunc(nvl(i_reconciliation_date, com_api_sttl_day_pkg.get_sysdate)))
        );

        l_lang := nvl(i_lang, get_user_lang);
        l_reconciliation_date := trunc(nvl(i_reconciliation_date, com_api_sttl_day_pkg.get_sysdate));
        l_inst_id := nvl(i_inst_id, 0);

        -- header
        select
            xmlelement("header"
                , xmlelement("inst_id", l_inst_id)
                , xmlelement("inst_name", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
                , xmlelement("sttl_date", to_char(l_reconciliation_date, 'dd.mm.yyyy'))
            )
        into l_header from dual;

        -- details
        begin
            select
                xmlelement("table"
                  , xmlagg(
                        xmlelement("record"
                          , xmlelement("summary_level", summary_level)
                          , xmlelement("clear_currency", clear_currency)
                          , xmlelement("currency_name", currency_name)
                          , xmlelement("bus_mode", bus_mode)
                          , xmlelement("bus_tr_type", bus_tr_type)
                          , xmlelement("vss_trans_count", vss_trans_count)
                          , xmlelement("vss_trans_amount", vss_trans_amount)
                          , xmlelement("trans_count", trans_count)
                          , xmlelement("trans_amount", trans_amount)
                          )
                        order by summary_level desc
                               , bus_mode
                               , clear_currency
                               , bus_tr_type
                       )
                   )
              into l_detail
              from (
                    select v6.clear_currency
                         , v6.currency_name
                         , v6.bus_mode
                         , v6.summary_level
                         , ae.element_value as bus_tr_type
                         , v6.vss_trans_count
                         , v6.vss_trans_amount
                         , opr.trans_count
                         , opr.trans_amount
                     from (
                         select v6.inst_id
                              , v6.clear_currency
                              , r.name as currency_name
                              , v6.bus_mode
                              , v6.summary_level
                              , v6.bus_tr_type
                              , sum(v6.trans_count) as vss_trans_count
                              , sum(v6.amount / power (10, nvl(r.exponent,0)) ) as vss_trans_amount 
                           from vis_vss6 v6
                              , com_currency r
                          where v6.rep_id_num = '900'
                            and r.code(+) = v6.clear_currency
                            and v6.sttl_date = l_reconciliation_date
                            and (l_inst_id = 0 or v6.inst_id = l_inst_id)
                            and v6.summary_level in ('01', '05', '06', '07')
                            and v6.trans_dispos in ('80')
                            and v6.rep_id_sfx is null
                       group by v6.inst_id
                              , v6.clear_currency
                              , r.name
                              , v6.bus_mode
                              , v6.summary_level
                              , v6.bus_tr_type
                   ) v6
                 , (
                   with opr as
                       (
                       select l_inst_id as inst_id
                            , o.sttl_currency
                            , case
                                   when pi.inst_id = l_inst_id then '1'
                                   when pa.inst_id = l_inst_id then '2'
                                   else null
                              end
                              as bus_mode
                            , o.id
                            , o.sttl_amount / power(10, nvl(r.exponent, 0)) *
                              case when com_api_array_pkg.is_element_in_array(
                                            i_array_id    => 10000011
                                          , i_elem_value  => o.oper_type
                                        ) = com_api_type_pkg.TRUE
                                   then 1
                                   else -1
                              end
                              as amount
                            , com_api_array_pkg.conv_array_elem_v(
                                   i_lov_id            => 49
                                 , i_array_type_id     => 1036
                                 , i_array_id          => 10000040
                                 , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                 , i_elem_value        => o.oper_type
                              )
                              as bus_tr_type
                         from aut_auth a
                            , opr_operation o
                            , opr_participant pi
                            , opr_participant pa
                            , com_currency r
                        where a.id = o.id
                          and o.msg_type = opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                          and o.status in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                         , opr_api_const_pkg.OPERATION_STATUS_DONE_WO_PROC
                                         , opr_api_const_pkg.OPERATION_STATUS_UNHOLDED
                                         , opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED
                                         , opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD
                                         , opr_api_const_pkg.OPERATION_STATUS_PART_UNHOLD)
                          and o.sttl_amount > 0
                          and o.id = pi.oper_id
                          and o.id = pa.oper_id
                          and pi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                          and pa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                          and o.sttl_type not in (opr_api_const_pkg.SETTLEMENT_USONUS
                                                , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST
                                                , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST)
                          and o.sttl_currency = r.code(+)
                          and (pi.inst_id = l_inst_id or pa.inst_id = l_inst_id)
                          and pi.card_network_id in (1003, 1008)
                          and trunc(nvl(a.network_cnvt_date, o.oper_date)) = l_reconciliation_date
                       )
                   select opr.inst_id
                        , opr.sttl_currency
                        , opr.bus_mode
                        , opr.bus_tr_type
                        , count(opr.id) as trans_count
                        , sum(opr.amount) as trans_amount
                        , '07' as summary_level
                     from opr
                 group by opr.inst_id
                        , opr.sttl_currency
                        , opr.bus_mode
                        , opr.bus_tr_type
                    union
                   select opr.inst_id
                        , opr.sttl_currency
                        , opr.bus_mode
                        , null as bus_tr_type
                        , count(opr.id) as trans_count
                        , sum(opr.amount) as trans_amount
                        , '06' as summary_level
                     from opr
                 group by opr.inst_id
                        , opr.sttl_currency
                        , opr.bus_mode
                    union
                   select opr.inst_id
                        , opr.sttl_currency
                        , null as bus_mode
                        , null as bus_tr_type
                        , count(opr.id) as trans_count
                        , sum(opr.amount) as trans_amount
                        , '05' as summary_level
                     from opr
                 group by opr.inst_id
                        , opr.sttl_currency
                   ) opr
                   , com_ui_array_element_vw ae
               where v6.summary_level = opr.summary_level(+)
                 and v6.inst_id = opr.inst_id(+)
                 and v6.clear_currency = opr.sttl_currency(+)
                 and nvl(v6.bus_mode,'*') = nvl(opr.bus_mode(+),'*')
                 and nvl(v6.bus_tr_type,'*') = nvl(opr.bus_tr_type(+),'*')
                 and nvl(v6.bus_tr_type,'*') = ae.element_value(+)
                 and ae.lang(+) = l_lang
                 and ae.array_id(+) = 10000040
            );
        exception
            when no_data_found then
                select
                    xmlelement("table", '')
                into
                    l_detail
                from
                    dual;
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
            i_text => 'vis_api_report_pkg.vss_reconciliation - ok'
        );

    exception
        when others then
            trc_log_pkg.debug (
                i_text   => sqlerrm
            );
            raise;
    end;

procedure visa_unmatched_presentments (
    o_xml            out clob
  , i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_date_start  in     date
  , i_date_end    in     date
  , i_lang        in     com_api_type_pkg.t_dict_value
) is
    l_date_start        date := i_date_start;
    l_date_end          date := i_date_end;
    l_lang              com_api_type_pkg.t_dict_value;

    l_header            xmltype;
    l_detail            xmltype;
    l_result            xmltype;         
    l_logo_path         xmltype;	
begin
    l_lang       := nvl(i_lang, get_user_lang);

    if l_date_end is null and l_date_start is null then
        l_date_end   := trunc(com_api_sttl_day_pkg.get_sysdate) - interval '1' second;
    end if;
    
    if l_date_start is null  and l_date_end is not null then
        l_date_start := trunc(l_date_end);
    end if;
    
    trc_log_pkg.debug (
        i_text        => 'vis_api_report_pkg.visa_unmatched_presentments [#1][#2][#3][#4]'
      , i_env_param1  => i_lang
      , i_env_param2  => i_inst_id
      , i_env_param3  => to_char(l_date_start, 'dd.mm.yyyy hh24:mi:ss')
      , i_env_param4  => to_char(l_date_end, 'dd.mm.yyyy hh24:mi:ss')
    );

    -- header   
	l_logo_path := rpt_api_template_pkg.logo_path_xml;
    select xmlelement(
               "header"  
			 , l_logo_path  
             , xmlelement("p_date_start", to_char(l_date_start, 'dd.mm.yyyy'))
             , xmlelement("p_date_end"  , to_char(l_date_end, 'dd.mm.yyyy'))
             , xmlelement("p_inst"      , decode (i_inst_id, null, 'All'
                                                   ,i_inst_id || ' - ' || get_text('OST_INSTITUTION','NAME', i_inst_id, l_lang))
                         )
           )
      into l_header
      from dual;

     select xmlelement(
               "details"
             , xmlagg(
                   xmlelement(
                       "detail"
                     , xmlelement("curr",             com_api_currency_pkg.get_currency_name(m.sttl_currency) )
                     , xmlelement("oper_type",        get_article_text(o.oper_type, l_lang) )
                     , xmlelement("oper_date",        to_char(m.oper_date, 'dd.mm.yyyy') )
                     , xmlelement("sttl_amount",      to_char(m.sttl_amount, NUM_FORMAT) )
                     , xmlelement("auth_code",        m.auth_code)
                     , xmlelement("reversal_sign",    decode(m.is_reversal, 1, 'Y', 0, 'N'))
                     , xmlelement("card_number",      iss_api_card_pkg.get_card_mask(c.card_number))
                     , xmlelement("arn",              m.arn)
                     , xmlelement("acquirer_bin",     m.acquirer_bin)
                     , xmlelement("mcc",              m.mcc)
                     , xmlelement("merchant_number",  m.merchant_number)
                     , xmlelement("merchant_name",    m.merchant_name)
                     , xmlelement("merchant_address", m.merchant_postal_code || ',' || 
                                                      m.merchant_street || ',' || 
                                                      m.merchant_city || ',' || 
                                                      m.merchant_region || ',' || 
                                                      m.merchant_country)
                     , xmlelement("terminal_number",  m.terminal_number)
                     , xmlelement("matching_status",  get_article_text(o.match_status, l_lang))
                     
                   )
               order by m.sttl_currency
                     , m.oper_date
                     , o.oper_type
               )
            )
       into l_detail
       from vis_fin_message m
          , opr_operation o
          , opr_card c
      where m.id         = o.id
        and c.oper_id    = o.id
        and m.oper_date >= l_date_start
        and (m.inst_id   = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
        --Only the Visa financial messages of TC 05, 06, 07, 25, 26, and 27
        and m.trans_code 
         in (vis_api_const_pkg.TC_SALES              -- '05'
           , vis_api_const_pkg.TC_VOUCHER            -- '06'
           , vis_api_const_pkg.TC_CASH               -- '07'
           , vis_api_const_pkg.TC_SALES_REVERSAL     -- '25'
           , vis_api_const_pkg.TC_VOUCHER_REVERSAL   -- '26'
           , vis_api_const_pkg.TC_CASH_REVERSAL      -- '27'
        )
        and m.usage_code = 1  -- First presentments
        and m.oper_date < trunc(l_date_end) + 1
        and o.match_status in (OPR_API_CONST_PKG.OPERATION_MATCH_REQ_MATCH
                             , OPR_API_CONST_PKG.OPERATION_MATCH_EXPIRED)
      order by m.sttl_currency
             , m.oper_date
             , o.oper_type 
             ;

    --if no data
    if l_detail.getclobval() = '<details></details>' then
        select xmlelement(
                   "details"
                 , xmlagg(
                       xmlelement(
                           "detail"
                             , xmlelement("curr",             null)
                             , xmlelement("oper_type",        null)
                             , xmlelement("oper_date",        null)
                             , xmlelement("sttl_amount",      null)
                             , xmlelement("auth_code",        null)
                             , xmlelement("reversal_sign",    null)
                             , xmlelement("auth_code",        null)
                             , xmlelement("card_number",      null)
                             , xmlelement("arn",              null)
                             , xmlelement("acquirer_bin",     null)
                             , xmlelement("mcc",              null)
                             , xmlelement("merchant_number",  null)
                             , xmlelement("merchant_name",    null)
                             , xmlelement("merchant_address", null)
                             , xmlelement("terminal_number",  null)
                             , xmlelement("matching_status",  null)
                       )
                   )
               )
        into l_detail
        from dual;
    end if;

    select xmlelement(
               "report"
             , l_header
             , l_detail
           )
    into l_result
    from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(
        i_text => 'vis_api_report_pkg.visa_unmatched_presentments - ok'
    );

exception when others then
    trc_log_pkg.debug(i_text => sqlerrm);
    raise ;
end;  

end;
/
