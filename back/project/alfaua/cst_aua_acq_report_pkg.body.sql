CREATE OR REPLACE PACKAGE BODY cst_aua_acq_report_pkg is
/*********************************************************
 *  Issuer reports API <br />
 *  Created by Sidorik R.(sidorik@bpcbt.com)  at 14.02.2018 <br />
 *  Last changed by $Author: sidorik $ <br />
 *  $LastChangedDate:: 2018-02-14 15:26:00 +0200#$ <br />
 *  Revision: $LastChangedRevision: 00000 $ <br />
 *  Module: cst_aua_api_report_pkg <br />
 *  @headcom
 **********************************************************/
PACKAGE_NAME         constant com_api_type_pkg.t_name         := 'cst_aua_acq_report_pkg';
----------------------------------------------------------------
function get_header (
    i_inst_id                      in com_api_type_pkg.t_inst_id
    , i_start_date                 in date
    , i_end_date                   in date
    , i_lang                       in com_api_type_pkg.t_dict_value
    , i_date_format                in com_api_type_pkg.t_name         default 'dd.mm.yyyy'
    , i_sysdate_format             in com_api_type_pkg.t_name         default 'dd.mm.yyyy hh24:mi:ss'
) return xmltype is
    l_header                       xmltype;
begin
    select
        xmlconcat(
            xmlelement("inst_id", i_inst_id)
            , xmlelement("inst", nvl(com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', i_inst_id, i_lang),'ALL'))
            , xmlelement("start_date", to_char(i_start_date, i_date_format))
            , xmlelement("end_date", to_char(i_end_date, i_date_format))
            , xmlelement("fsysdate", to_char(com_api_sttl_day_pkg.get_sysdate, i_sysdate_format))
        )
    into l_header from dual;
    return l_header;
end;
----------------------------------------------------------------
procedure acq_transaction (
    o_xml                          out clob
    , i_inst_id                    in com_api_type_pkg.t_inst_id
    , i_start_date                 in date                                default null
    , i_end_date                   in date                                default null
    , i_tran_curr                  in com_api_type_pkg.t_curr_code        default null
    , i_merchant_number            in com_api_type_pkg.t_merchant_number  default null
    , i_terminal_number            in com_api_type_pkg.t_terminal_number  default null
    , i_terminal_type              in com_api_type_pkg.t_dict_value       default null
    , i_lang                       in com_api_type_pkg.t_dict_value       default null
) is
    l_start_date                   date;
    l_end_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_inst_id                      com_api_type_pkg.t_inst_id;

    l_detail                       xmltype;
    l_result                       xmltype;

    PROCEDURE_NAME        constant com_api_type_pkg.t_name := 'acq_transaction';
begin
    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc( nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date :=   trunc( nvl(i_end_date,   com_api_sttl_day_pkg.get_sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id := nvl(i_inst_id, 0);
    trc_log_pkg.debug (
        i_text          => PACKAGE_NAME||'.'||PROCEDURE_NAME||' [#1][#2][#3][#4][#5][#6]'
        , i_env_param1  => l_inst_id
        , i_env_param2  => com_api_type_pkg.convert_to_char(l_start_date)
        , i_env_param3  => com_api_type_pkg.convert_to_char(l_end_date)
        , i_env_param4  => i_tran_curr
        , i_env_param5  => i_merchant_number
        , i_env_param6  => i_terminal_type||':'||i_terminal_number
    );
    --details
    begin
        select
            xmlelement("details"
              , xmlagg(
                    xmlelement("detail"
                      , xmlelement("card_type", card_type)
                      , xmlelement("transaction_currency", transaction_currency)
                      , xmlelement("terminal_type", terminal_type)
                      , xmlelement("merchant_number", merchant_number)
                      , xmlelement("merchant_name", merchant_name)
                      , xmlelement("merchant_country", merchant_country)
                      , xmlelement("merchant_region", merchant_region)
                      , xmlelement("merchant_city", merchant_city)
                      , xmlelement("merchant_street", merchant_street)
                      , xmlelement("terminal_number", terminal_number)
                      , xmlelement("service_name", service_name)
                      , xmlelement("date_transaction", to_char(date_transaction, 'dd.mm.yyyy'))
                      , xmlelement("amount", amount_local + amount_no_local)
                      , xmlelement("turnover", turnover_local + turnover_no_local)
                      , xmlelement("amount_local", amount_local)
                      , xmlelement("turnover_local", turnover_local)
                      , xmlelement("amount_no_local", amount_no_local)
                      , xmlelement("turnover_no_local", turnover_no_local)
                      , xmlelement("sttl_currency", sttl_currency)
                      , xmlelement("sttl_amount", sttl_amount)
                      , xmlelement("sttl_turnover", sttl_turnover)
                      , xmlelement("ic_fee_db", ic_fee_db)
                      , xmlelement("ic_fee_cr", ic_fee_cr)
                    )
                    order by card_type, transaction_currency, terminal_type
                           , merchant_number, terminal_number, date_transaction
                )
            )
        into
            l_detail
        from (
        ---------------
        select card_type, terminal_type, merchant_number, merchant_name, merchant_country
             , merchant_region, merchant_city, merchant_street, terminal_number
             , service_name, date_transaction, transaction_currency, sttl_currency
             , sum(case when is_local = 1 then 1 else 0 end) as amount_local
             , sum(case when is_local = 1 then oper_sign*reversal_sign*oper_amount else 0 end) as turnover_local
             , sum(case when is_local = 1 then 0 else 1 end) as amount_no_local
             , sum(case when is_local = 1 then 0 else oper_sign*reversal_sign*oper_amount end) as turnover_no_local
             , sum(case when sttl_currency is not null then 1 else 0 end) as sttl_amount
             , sum(case when sttl_currency is not null then sttl_amnt else null end) as sttl_turnover
             , sum(case when ic_fee > 0 then ic_fee else 0 end) as ic_fee_db
             , sum(case when ic_fee < 0 then ic_fee else 0 end) as ic_fee_cr
        from (
            select
                   case when pi.inst_id=1001 then
                       com_api_i18n_pkg.get_text('net_network', 'NAME', pi.card_network_id, l_lang)
                   else
                       com_api_i18n_pkg.get_text('ost_institution', 'NAME', pi.inst_id, l_lang)
                   end as card_type
                 , get_article_text(o.terminal_type) as terminal_type
                 , o.merchant_number
                 , o.merchant_name
                 , o.merchant_country
                 , o.merchant_region
                 , o.merchant_city
                 , o.merchant_street
                 , o.terminal_number
                 , com_api_i18n_pkg.get_text('prd_service', 'LABEL', srv.service_id, l_lang) as service_name
                 , trunc(o.host_date) as date_transaction
                 , sc.name as transaction_currency
                 , o.oper_amount/100 as oper_amount
                 , case when pi.inst_id = pa.inst_id then 1 else 0 end is_local
                 , case when o.oper_type in ('OPTP0020','OPTP0022','OPTP0026') then -1
                        else 1
                   end oper_sign
                 , case when o.is_reversal = 0 then 1 else -1 end reversal_sign
                 , (case when pi.network_id = cmp_api_const_pkg.VISA_NETWORK--1003
                           then vi.trxn_amount/100
                            when pi.network_id = cmp_api_const_pkg.MC_NETWORK--1002
                           then mi.p0394_2 * decode(mi.p0394_1, 'D', -1, 1) / 100
                           else null
                       end)                                                                  as sttl_amnt
                 , (case when pi.network_id = cmp_api_const_pkg.VISA_NETWORK--1003
                           then com_api_currency_pkg.get_currency_name( i_curr_code => vi.currency_code)
                            when pi.network_id = cmp_api_const_pkg.MC_NETWORK--1002
                           then com_api_currency_pkg.get_currency_name( i_curr_code => mi.de050)
                           else null
                       end)                                                                  as sttl_currency
                 , nvl(case when pi.network_id = cmp_api_const_pkg.VISA_NETWORK--1003
                           then vic.inter_fee_amount--stored with point (2.25)
                            when pi.network_id = cmp_api_const_pkg.MC_NETWORK--1002
                           then mi.p0395_2 * decode(mi.p0395_1, 'D', -1, 1) / 100
                           else 0
                       end, 0)                                                               as ic_fee
            from opr_operation o
              join aut_auth a on a.id = o.id
              join opr_participant pa on pa.oper_id = o.id and pa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER--PRTYACQ
              join opr_participant pi on pi.oper_id = o.id and pi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER--PRTYISS
              join acq_merchant m on m.merchant_number = o.merchant_number
              join acq_terminal t on t.terminal_number = o.terminal_number
                left join prd_service_object srv on entity_type = 'ENTTTRMN' and srv.object_id = t.id
                left join com_currency_vw sc on sc.code = o.oper_currency
                --sttl
                left join vis_multipurpose vi on vi.match_auth_id = o.id --TC33
                                       and vi.status = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED--CLMS0040
                left join mcw_fin mf on mf.id = o.id
                left join mcw_fpd mi on mi.p0375 = to_char(o.id) --and mi.id = mf.fpd_id
                --ic
                left join cst_vis_arr0100 vic on vic.fin_id = o.id
            where 1=1
              and o.status in (opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES, opr_api_const_pkg.OPERATION_STATUS_PROCESSED)--OPST0404,OPST0400
              and pa.inst_id = l_inst_id
              and trunc(o.host_date) between l_start_date and l_end_date
              and o.oper_amount <> 0
              and (i_tran_curr is null or o.oper_currency = i_tran_curr)
              and (i_merchant_number is null or o.merchant_number = i_merchant_number)
              and (i_terminal_number is null or o.terminal_number = i_terminal_number)
              and (i_terminal_type is null or o.terminal_type = i_terminal_type)
              and case when o.oper_type in ('OPTP0040','OPTP0042','OPTP0010','OPTP0026') and o.sttl_type = 'STTT0010' then 0
                       when o.oper_type in ('OPTP0011','OPTP0030','OPTP0038','OPTP0070','OPTP0071','OPTP0173') then 0
                       when o.msg_type not in ('MSGTAUTH','MSGTCMPL') then 0
                       else 1
                  end = 1
        )
        group by card_type, terminal_type, merchant_number, merchant_name, merchant_country
         , merchant_region, merchant_city, merchant_street, terminal_number
         , service_name, date_transaction, transaction_currency, sttl_currency
        ---------------
        );
    exception
        when no_data_found then
            select
                xmlelement("details", '')
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
        i_text => PACKAGE_NAME||'.'||PROCEDURE_NAME||' - ok'
    );

exception
    when others then
        trc_log_pkg.error (
            i_text   => sqlerrm
        );
        raise;
end;
----------------------------------------------------------------
procedure atm_report (
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
    l_tag_amt                      com_api_type_pkg.t_short_id;
    l_tag_cur                      com_api_type_pkg.t_short_id;

    PROCEDURE_NAME        constant com_api_type_pkg.t_name := 'atm_report';

begin
    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc( nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date   := trunc( nvl(i_end_date,   com_api_sttl_day_pkg.get_sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id := nvl(i_inst_id, 0);
    l_tag_amt    := aup_api_tag_pkg.find_tag_by_reference('DF8A76');
    l_tag_cur    := aup_api_tag_pkg.find_tag_by_reference('DF8A77');
    trc_log_pkg.debug (
        i_text          => PACKAGE_NAME||'.'||PROCEDURE_NAME||' [#1][#2][#3]'
        , i_env_param1  => l_inst_id
        , i_env_param2  => com_api_type_pkg.convert_to_char(l_start_date)
        , i_env_param3  => com_api_type_pkg.convert_to_char(l_end_date)
    );
    --details
    begin
        select
            xmlelement("details"
              , xmlagg(
                    xmlelement("detail"
                      , xmlelement("card_type", card_type)
                      , xmlelement("transaction_currency", transaction_currency)
                      , xmlelement("merchant_number", merchant_number)
                      , xmlelement("terminal_number", terminal_number)
                      , xmlelement("onus_kol", onus_kol)
                      , xmlelement("onus_amount", onus_amount)
                      , xmlelement("dom_kol", dom_kol)
                      , xmlelement("dom_amount", dom_amount)
                      , xmlelement("inter_kol", inter_kol)
                      , xmlelement("inter_amount", inter_amount)
                      , xmlelement("sc_fee", sc_fee)
                      , xmlelement("ic_fee", ic_fee)
                    )
                    order by card_type, transaction_currency, merchant_number, terminal_number
                )
            )
        into
            l_detail
        from (
        ---------------
        select card_type, transaction_currency, merchant_number, terminal_number
             , sum(case when card_location = 1 then 1 else 0 end)           as onus_kol
             , sum(case when card_location = 1 then oper_amount else 0 end) as onus_amount
             , sum(case when card_location = 2 then 1 else 0 end)           as dom_kol
             , sum(case when card_location = 2 then oper_amount else 0 end) as dom_amount
             , sum(case when card_location = 3 then 1 else 0 end)           as inter_kol
             , sum(case when card_location = 3 then oper_amount else 0 end) as inter_amount
             , sum(sc_fee) sc_fee
             , sum(ic_fee) ic_fee
        from (
            select card_type
                 , case when is_dcc = 0 then transaction_currency else dcc_cash_curr end as transaction_currency
                 , merchant_number, terminal_number
                 , reversal_sign * (case when is_dcc = 0 then oper_amount else dcc_cash_amnt end) as oper_amount
                 , card_location
                 , reversal_sign * sc_fee as sc_fee
                 , reversal_sign * ic_fee as ic_fee
                 , is_dcc
              from (
                    select
                           com_api_i18n_pkg.get_text('net_network', 'NAME', nvl(pi.card_network_id, pi.network_id), l_lang) as card_type
                         , sc.name as transaction_currency
                         , o.merchant_number
                         , o.terminal_number
                         , o.oper_amount/100 - nvl(o.oper_surcharge_amount/100, 0) as oper_amount
                         , case when pi.inst_id = pa.inst_id then 1
                                when pi.card_country = 804  then 2
                                else 3
                           end as card_location
                         , nvl(o.oper_surcharge_amount/100, 0) as sc_fee
                         , nvl(case when pi.network_id = cmp_api_const_pkg.VISA_NETWORK--1003
                                   then vi.inter_fee_amount--stored with point (2.25)
                                    when pi.network_id = cmp_api_const_pkg.MC_NETWORK--1002
                                   then mi.p0395_2 * decode(mi.p0395_1, 'D', -1, 1) / 100
                                   else 0
                               end, 0) ic_fee
                         , (select count(1) from aup_tag_value v
                             where v.auth_id = a.id
                               and v.tag_id in (l_tag_amt, l_tag_cur)
                           ) is_dcc
                         , to_number(aup_api_tag_pkg.get_tag_value(
                                         i_auth_id => a.id
                                       , i_tag_id  => l_tag_amt
                                    )
                           )/100                                                                        as dcc_cash_amnt
                         , com_api_currency_pkg.get_currency_name(
                               i_curr_code => aup_api_tag_pkg.get_tag_value(
                                                  i_auth_id => a.id
                                                , i_tag_id  => l_tag_cur
                                              )
                           )                                                                            as dcc_cash_curr
                         , case when o.is_reversal = 0 then 1 else -1 end reversal_sign
                    from opr_operation o
                     join aut_auth a on a.id = o.id
                     join opr_participant pa on pa.oper_id = o.id and pa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER--PRTYACQ
                     join opr_participant pi on pi.oper_id = o.id and pi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER--PRTYISS
                     left join com_currency_vw sc on sc.code = o.oper_currency
                     left join cst_vis_arr0100 vi on vi.fin_id = o.id
                     left join mcw_fin mf on mf.id = o.id
                     left join mcw_fpd mi on mi.p0375 = to_char(o.id) --and mi.id = mf.fpd_id
                    where 1=1
                      and o.status in (opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES, opr_api_const_pkg.OPERATION_STATUS_PROCESSED)--OPST0404,OPST0400
                      and pa.inst_id = l_inst_id
                      and trunc(o.host_date) between l_start_date and l_end_date
                      and o.oper_amount <> 0
                      and o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM
                      and o.oper_type = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH--OPTP0001
                )
            )
        group by card_type, transaction_currency, merchant_number, terminal_number
        ---------------
        );
    exception
        when no_data_found then
            select
                xmlelement("details", '')
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
        i_text => PACKAGE_NAME||'.'||PROCEDURE_NAME||' - ok'
    );

exception
    when others then
        trc_log_pkg.error (
            i_text   => sqlerrm
        );
        raise;
end;
----------------------------------------------------------------

end cst_aua_acq_report_pkg;
/
