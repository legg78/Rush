CREATE OR REPLACE PACKAGE BODY cst_aua_api_report_pkg is
/*********************************************************
 *  Issuer reports API <br />
 *  Created by Sidorik R.(sidorik@bpcbt.com)  at 14.02.2018 <br />
 *  Last changed by $Author: sidorik $ <br />
 *  $LastChangedDate:: 2018-02-14 15:26:00 +0200#$ <br />
 *  Revision: $LastChangedRevision: 00000 $ <br />
 *  Module: cst_aua_api_report_pkg <br />
 *  @headcom
 **********************************************************/
PACKAGE_NAME         constant com_api_type_pkg.t_name         := 'cst_aua_api_report_pkg';
MC_NETWORK_INST      constant com_api_type_pkg.t_network_id   := 9001;
----------------------------------------------------------------
function get_header (
    i_inst_id                      in com_api_type_pkg.t_inst_id
    , i_start_date                 in date
    , i_end_date                   in date
    , i_lang                       in com_api_type_pkg.t_dict_value
    , i_date_format                in com_api_type_pkg.t_name         default 'YYYY-MM-DD'
    , i_acq_bin                    in com_api_type_pkg.t_name         default null
) return xmltype is
    l_header                       xmltype;
begin
    select
        xmlconcat(
            xmlelement("inst_id", i_inst_id)
            , xmlelement("inst", nvl(com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', i_inst_id, i_lang),'ALL'))
            , xmlelement("start_date", to_char(i_start_date, i_date_format))
            , xmlelement("end_date", to_char(i_end_date, i_date_format))
            , xmlelement("acq_bin", i_acq_bin)
            , xmlelement("fsysdate", to_char(com_api_sttl_day_pkg.get_sysdate, i_date_format||' hh24:mi:ss'))
        )
    into l_header from dual;
    return l_header;
end;
----------------------------------------------------------------
    function get_acq_cmid_add (
        i_iss_inst_id           in com_api_type_pkg.t_inst_id
      , i_iss_network_id        in com_api_type_pkg.t_tiny_id
      , i_inst_id               in com_api_type_pkg.t_inst_id
    ) return com_api_type_pkg.t_cmid is
        l_result                com_api_type_pkg.t_cmid;
        l_host_id               com_api_type_pkg.t_tiny_id;
        l_standard_id           com_api_type_pkg.t_tiny_id;
        l_param_tab             com_api_type_pkg.t_param_tab;
    begin

        l_host_id :=
            net_api_network_pkg.get_member_id(
                i_inst_id       => i_iss_inst_id
              , i_network_id    => i_iss_network_id
            );

        l_standard_id :=
            net_api_network_pkg.get_offline_standard(
                i_host_id       => l_host_id
            );

        l_result :=
            cmn_api_standard_pkg.get_varchar_value (
                i_inst_id       => i_inst_id
                , i_standard_id => l_standard_id
                , i_object_id   => l_host_id
                , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
                , i_param_name  => mcw_api_const_pkg.CMID||'_ADD'
                , i_param_tab   => l_param_tab
            );

       return nvl(l_result, ' ');
    end;
----------------------------------------------------------------
procedure mastercard_fpd (
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
    l_business_ica                 com_api_type_pkg.t_param_value;
    l_business_ica_add             com_api_type_pkg.t_param_value;

    l_detail                       xmltype;
    l_result                       xmltype;

    PROCEDURE_NAME        constant com_api_type_pkg.t_name := 'mastercard_fpd';
begin
    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc( nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date :=   trunc( nvl(i_end_date,   com_api_sttl_day_pkg.get_sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id := nvl(i_inst_id, 0);
    begin
        l_business_ica := mcw_utl_pkg.get_acq_cmid(
                              i_iss_inst_id => MC_NETWORK_INST,
                              i_iss_network_id => cmp_api_const_pkg.MC_NETWORK,
                              i_inst_id => l_inst_id
                          );
    exception
        when others then
            l_business_ica := null;
    end;
    begin
        l_business_ica_add := get_acq_cmid_add(
                              i_iss_inst_id => MC_NETWORK_INST,
                              i_iss_network_id => cmp_api_const_pkg.MC_NETWORK,
                              i_inst_id => l_inst_id
                          );
    exception
        when others then
            l_business_ica_add := null;
    end;

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
                      , xmlelement("recon_curr", recon_curr)
                      , xmlelement("group_id", group_id)
                      , xmlelement("business_date", to_char(business_date,'dd.mm.yyyy'))
                      , xmlelement("bank", bank)
                      , xmlelement("trans_func", trans_func)
                      , xmlelement("id", id)
                      , xmlelement("business_cycle", business_cycle)
                      , xmlelement("cnt", cnt)
                      , xmlelement("total_db", total_db)
                      , xmlelement("total_cr", total_cr)
                      , xmlelement("int_fee_db", int_fee_db)
                      , xmlelement("int_fee_cr", int_fee_cr)
                      , xmlelement("atm_fee_db", atm_fee_db)
                      , xmlelement("atm_fee_cr", atm_fee_cr)
                      , xmlelement("cash_fee_db", cash_fee_db)
                      , xmlelement("cash_fee_cr", cash_fee_cr)
                      , xmlelement("net_value", ( total_db    + total_cr
                                                + int_fee_db  + int_fee_cr
                                                + atm_fee_db  + atm_fee_cr
                                                + cash_fee_db + cash_fee_cr )
                                  )
                      , xmlelement("trx_value", trx_value)
                      , xmlelement("trx_ccy", trx_ccy)
                    )
                    order by recon_curr, group_id, id
                )
            )
        into
            l_detail
        from (
        ---------------
        select
              sc.name as recon_curr
             ,dense_rank() over (order by sc.name, business_date, bank, trans_func) as group_id
             ,business_date
             ,bank
             ,trans_func
             ,row_number() over (partition by sc.name, business_date, bank, trans_func order by business_cycle, cc.name) as id
             ,business_cycle
             ,cc.name as trx_ccy
             ,sum(cnt) cnt
             ,sum(total_db) total_db
             ,sum(total_cr) total_cr
             ,sum(int_fee_db) int_fee_db
             ,sum(int_fee_cr) int_fee_cr
             ,sum(atm_fee_db) atm_fee_db
             ,sum(atm_fee_cr) atm_fee_cr
             ,sum(cash_fee_db) cash_fee_db
             ,sum(cash_fee_cr) cash_fee_cr
             ,sum(trx_value) trx_value
        from (
              select
                    t.settlement_currency
                   ,t.business_date
                   ,t.bank
                   ,(t.activity||' / '||t.message_type||' / '||t.function_code) as trans_func
                   ,t.business_cycle
                   ,nvl(t.quantity,0) cnt
                   ,case when t.settlement_amount<0 then t.settlement_amount else 0 end as total_db
                   ,case when t.settlement_amount>0 then t.settlement_amount else 0 end as total_cr
                   ,case when t.rec_type='INT' and t.settlement_fee<0 then t.settlement_fee else 0 end as int_fee_db
                   ,case when t.rec_type='INT' and t.settlement_fee>0 then t.settlement_fee else 0 end as int_fee_cr
                   ,case when t.rec_type='ATM' and t.settlement_fee<0 then t.settlement_fee else 0 end as atm_fee_db
                   ,case when t.rec_type='ATM' and t.settlement_fee>0 then t.settlement_fee else 0 end as atm_fee_cr
                   ,case when t.rec_type='CASH' and t.settlement_fee<0 then t.settlement_fee else 0 end as cash_fee_db
                   ,case when t.rec_type='CASH' and t.settlement_fee>0 then t.settlement_fee else 0 end as cash_fee_cr
                   ,abs(t.clearing_amount) as trx_value
                   ,t.clearing_currency
              from (
                    select
                       de050 as settlement_currency
                     , nvl(p0358_5, to_date(substr(p0300, 4, 6), 'YYMMDD')) as business_date
                     , nvl(de093, substr(p0300, 15, 6)) as bank
                     , nvl(p0358_6, substr(p0300, 21, 2)) as business_cycle
                     , decode(substr(p0300,1,3), '001', 'Issuing'
                                               , '021', 'Issuing'
                                               , '002', 'Acquiring'
                                               ,        'Miscellaneous') as activity
                     , decode(p0372_1, '1240', p0372_1 || ' - Presentment'
                                     , '1442', p0372_1 || ' - Chargeback'
                                     , '1740', p0372_1 || ' - Fee Collection'
                                     ,         p0372_1 || ' - Other') as message_type
                     , decode (p0372_2, '200', p0372_2 || ' - First Presentment'
                                      , '205', p0372_2 || ' - Second presentment (Full)'
                                      , '282', p0372_2 || ' - Second presentment (Partial)'
                                      , '450', p0372_2 || ' - First Chargeback (Full)'
                                      , '451', p0372_2 || ' - Arbitration Chargeback (Full)'
                                      , '453', p0372_2 || ' - First Chargeback (Partial)'
                                      , '454', p0372_2 || ' - Arbitration Chargeback (Partial)'
                                      ,        p0372_2 || ' - Other') as function_code
                     , decode(p0374, '00', p0374 || ' - Purchase'
                                   , '01', p0374 || ' - ATM Cash Withdrawal'
                                   , '12', p0374 || ' - Cash Disbursement'
                                   , '17', p0374 || ' - Convenience Check'
                                   , '18', p0374 || ' - Unique Transaction'
                                   , '19', p0374 || ' - Fee Collection'
                                   , '20', p0374 || ' - Refund'
                                   , '28', p0374 || ' - Payment Transaction'
                                   , '29', p0374 || ' - Fee Collection'
                                   ,       p0374 || ' - Other') as transaction_type
                     , case when p0374 in ('01') then 'ATM'
                            when p0374 in ('12') then 'CASH'
                            else 'INT'
                       end rec_type
                     , case when substr(p0300,1,3) not in ('901', '904') then p0402 else null end as quantity
                     , p0394_2 * decode(p0394_1, 'D', -1, 1) / 100 as settlement_amount
                     , p0395_2 * decode(p0395_1, 'D', -1, 1) / 100 as settlement_fee
                     , p0396_2 * decode(p0396_1, 'D', -1, 1) / 100 as settlement_total
                     , de049 as clearing_currency
                     , case when substr(p0300,1,3) not in ('901', '904')
                            then p0384_2 * decode(p0384_1, 'D', -1, 1) / 100
                            else null end as clearing_amount
                    from mcw_fpd mf
                         join mcw_file mff on mff.id = mf.file_id
                    where mf.network_id = mcw_api_const_pkg.MCW_NETWORK_ID
                      and substr(mff.p0105, 4, 6) between to_char(l_start_date,'YYMMDD') and to_char(l_end_date,'YYMMDD')
                      and (mf.de093 = l_business_ica or mf.de093 = l_business_ica_add or l_business_ica is null)
                   ) t
             ) t
             left join com_currency_vw sc on sc.code = t.settlement_currency
             left join com_currency_vw cc on cc.code = t.clearing_currency
             group by
                      sc.name
                     ,cc.name
                     ,business_date
                     ,bank
                     ,trans_func
                     ,business_cycle
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
procedure mastercard_spd (
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
    l_business_ica                 com_api_type_pkg.t_param_value;
    l_business_ica_add             com_api_type_pkg.t_param_value;

    l_detail                       xmltype;
    l_result                       xmltype;

    PROCEDURE_NAME constant com_api_type_pkg.t_name := 'mastercard_spd';
begin
    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc( nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date :=   trunc( nvl(i_end_date,   com_api_sttl_day_pkg.get_sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id := nvl(i_inst_id, 0);
    begin
        l_business_ica := mcw_utl_pkg.get_acq_cmid(
                              i_iss_inst_id => MC_NETWORK_INST,
                              i_iss_network_id => cmp_api_const_pkg.MC_NETWORK,
                              i_inst_id => l_inst_id
                          );
    exception
        when others then
            l_business_ica := null;
    end;
    begin
        l_business_ica_add := get_acq_cmid_add(
                              i_iss_inst_id => MC_NETWORK_INST,
                              i_iss_network_id => cmp_api_const_pkg.MC_NETWORK,
                              i_inst_id => l_inst_id
                          );
    exception
        when others then
            l_business_ica_add := null;
    end;

    trc_log_pkg.debug (
        i_text          => PACKAGE_NAME||'.'||PROCEDURE_NAME||' [#1][#2][#3]'
        , i_env_param1  => l_inst_id
        , i_env_param2  => com_api_type_pkg.convert_to_char(l_start_date)
        , i_env_param3  => com_api_type_pkg.convert_to_char(l_end_date)
    );

    -- details
    begin
        select
            xmlelement("details"
              , xmlagg(
                    xmlelement("detail"
                      , xmlelement("id", id)
                      , xmlelement("receiver", receiver)
                      , xmlelement("settl_service", settl_service)
                      , xmlelement("card_program", card_program)
                      , xmlelement("trn_function", trn_function)
                      , xmlelement("recon_ccy", recon_ccy)
                      , xmlelement("settl_date", to_char(settl_date,'yymmdd'))
                      , xmlelement("settl_cycle", settl_cycle)
                      , xmlelement("reason", reason)
                      , xmlelement("db_trn_amount", db_trn_amount)
                      , xmlelement("cr_trn_amount", cr_trn_amount)
                      , xmlelement("db_fee_amount", db_fee_amount)
                      , xmlelement("cr_fee_amount", cr_fee_amount)
                      , xmlelement("net_trn_amount", db_trn_amount + cr_trn_amount)
                      , xmlelement("net_fee_amount", db_fee_amount + cr_fee_amount)
                      , xmlelement("net_total", db_trn_amount + cr_trn_amount + db_fee_amount + cr_fee_amount)
                      , xmlelement("repr_repr_id", repr_repr_id)
                      , xmlelement("repr_file_reference", repr_file_reference)
                      , xmlelement("repr_key", repr_key)
                      , xmlelement("db_fee_amount_fpd", db_fee_amount_fpd)
                      , xmlelement("cr_fee_amount_fpd", cr_fee_amount_fpd)
                    )
                    order by id
                )
            )
        into
            l_detail
        from (
        ---------------
              select
                     row_number() over (order by receiver, settl_service, card_program, trn_function, recon_ccy, settl_date, settl_cycle, reason, repr_repr_id, repr_file_reference, repr_key) as id
                   , receiver, settl_service, card_program, trn_function, recon_ccy, settl_date, settl_cycle, reason, repr_repr_id, repr_file_reference, repr_key
                   , sum(case when settlement_amount<0 then settlement_amount else 0 end) as db_trn_amount
                   , sum(case when settlement_amount>0 then settlement_amount else 0 end) as cr_trn_amount
                   , sum(case when settlement_fee<0 then settlement_fee else 0 end) as db_fee_amount
                   , sum(case when settlement_fee>0 then settlement_fee else 0 end) as cr_fee_amount
                   , sum(-to_number(substr(fpd_sttl_fee, 1,12))/100) as db_fee_amount_fpd
                   , sum( to_number(substr(fpd_sttl_fee,13,12))/100) as cr_fee_amount_fpd
              from (
                    select
                           de093 as receiver
                         , (    substr(mf.p0300, 1, 3) || '-' || substr(mf.p0300, 4, 6) || '-'
                             || substr(mf.p0300, 10, 11) || '-' || substr(mf.p0300, 21, 5) || ' / '
                             || mf.p0302 || ' / '
                             || substr(mf.p0359, 41, 10) || ' / '
                             || substr(mf.p0359, 66, 2) || ' / '
                             || substr(mff.p0105, 4, 6) || ' / '
                             || '' || ' / '
                             || mf.p0368 || ' / '
                             || mf.de050
                           ) as repr_key
                         , substr(mf.p0359, 41, 10) as settl_service
                         , mf.p0367 as card_program
                         , decode (mf.p0368, 'FP', 'First Presentment'
                                           , 'SP', 'Second presentment'
                                           , 'FC', 'First Chargeback'
                                           , 'AC', 'Arbitration Chargeback'
                                           , 'FE', 'Fee Collection'
                                           , null
                           ) as trn_function
                         , mf.de050 as recon_ccy
                         , to_date(substr(mf.p0300, 4, 6), 'YYMMDD') as settl_date
                         , substr(mf.p0300, 21, 5) as settl_cycle
                         , case when mf.de025='6861' then 'File Acknowledgement' else 'File Notification' end as reason
                         , mf.file_id as repr_repr_id
                         , mf.p0300 as repr_file_reference
                         , p0394_2 * decode(p0394_1, 'D', -1, 1) / 100 as settlement_amount
                         , p0395_2 * decode(p0395_1, 'D', -1, 1) / 100 as settlement_fee
                         , (
                            select lpad(nvl(to_char(  sum(f.p0395_2 * decode(f.p0395_1, 'D', 1, 0))  ,'FM99999999990'),'0'),12,'0')--D
                                 ||lpad(nvl(to_char(  sum(f.p0395_2 * decode(f.p0395_1, 'D', 0, 1))  ,'FM99999999990'),'0'),12,'0')--C
                                as fpd_sttl_fee
                              from mcw_fpd f
                             where 1=1
                               and f.de025 = mf.de025
                               and f.de050 = mf.de050
                               and f.de093 = mf.de093
                               and f.p0148 = mf.p0148
                               and f.p0300 = mf.p0300
                               and f.p0302 = mf.p0302
                               and case when mf.p0368='FP' and f.p0372_1='1240' and f.p0372_2 in ('200') then 1--First Presentment
                                        when mf.p0368='SP' and f.p0372_1='1240' and f.p0372_2 in ('205','282') then 1--Second presentment
                                        when mf.p0368='FC' and f.p0372_1='1442' and f.p0372_2 in ('450','453') then 1--First Chargeback
                                        when mf.p0368='AC' and f.p0372_1='1442' and f.p0372_2 in ('451','454') then 1--Arbitration Chargeback
                                        when mf.p0368='FE' and f.p0372_1='1740' then 1--Fee Collection
                                        else 0
                                   end = 1
                           ) as fpd_sttl_fee
                    from mcw_spd mf
                         join mcw_file mff on mff.id = mf.file_id
                    where mf.network_id = mcw_api_const_pkg.MCW_NETWORK_ID
                      and substr(mff.p0105, 4, 6) between to_char(l_start_date,'YYMMDD') and to_char(l_end_date,'YYMMDD')
                      and (mf.de093 = l_business_ica or mf.de093 = l_business_ica_add or l_business_ica is null)
                   )
             group by receiver, settl_service, card_program, trn_function, recon_ccy, settl_date, settl_cycle, reason, repr_repr_id, repr_file_reference, repr_key
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
procedure dcc_transaction_daily (
    o_xml                          out clob
    , i_inst_id                    in com_api_type_pkg.t_inst_id default null
    , i_sttl_date                  in date
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

    PROCEDURE_NAME        constant com_api_type_pkg.t_name := 'dcc_transaction_daily';
begin
    l_inst_id    := coalesce(i_inst_id, com_ui_user_env_pkg.get_user_inst, get_def_inst);
    l_lang       := coalesce(i_lang, get_user_lang, get_def_lang);
    l_start_date := trunc(nvl(i_sttl_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date   := trunc(nvl(i_sttl_date, com_api_sttl_day_pkg.get_sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;

    l_tag_amt    := aup_api_tag_pkg.find_tag_by_reference('DF8A76');
    l_tag_cur    := aup_api_tag_pkg.find_tag_by_reference('DF8A77');

    trc_log_pkg.debug (
        i_text          => PACKAGE_NAME||'.'||PROCEDURE_NAME||' [#1][#2][#3]'
        , i_env_param1  => l_inst_id
        , i_env_param2  => com_api_type_pkg.convert_to_char(l_start_date)
        , i_env_param3  => com_api_type_pkg.convert_to_char(l_end_date)
    );

    -- details
    begin
        select
            xmlelement("details"
              , xmlagg(
                    xmlelement("detail"
                      , xmlelement("oper_id",       to_char(oper_id))
                      , xmlelement("oper_date",     to_char(oper_date,   'dd.mm.yyyy hh24:mi:ss'))
                      , xmlelement("cash_amnt",     to_char(cash_amnt,   com_api_const_pkg.XML_FLOAT_FORMAT))
                      , xmlelement("cash_curr",     cash_curr)
                      , xmlelement("auth_amnt",     to_char(auth_amnt,   com_api_const_pkg.XML_FLOAT_FORMAT))
                      , xmlelement("auth_curr",     auth_curr)
                      , xmlelement("dcc_rate",      to_char(cash_amnt/auth_amnt,    'FM999999990.000000000'))
                      , xmlelement("bank_margin",   to_char(bank_margin, 'FM999999990.00000'))
                      , xmlelement("sttl_amnt",     to_char(sttl_amnt,   com_api_const_pkg.XML_FLOAT_FORMAT))
                      , xmlelement("sttl_curr",     sttl_curr)
                      , xmlelement("sttl_rate",     to_char(sttl_amnt/auth_amnt,   'FM999999990.00000'))
                      , xmlelement("dev",           dev)
                      , xmlelement("stan",          stan)
                      , xmlelement("merchant_id",   merchant_id)
                      , xmlelement("merchant_name", merchant_name)
                      , xmlelement("card_number",   card_number)
                      , xmlelement("country",       country)
                    )
                    order by oper_id
                )
            )
        into
            l_detail
        from (
        ---------------
            select o.id                                                                         as oper_id
                 , o.host_date                                                                  as oper_date
                 , to_number(aup_api_tag_pkg.get_tag_value(
                                 i_auth_id => a.id
                               , i_tag_id  => l_tag_amt
                            )
                   )/100                                                                        as cash_amnt
                 , com_api_currency_pkg.get_currency_name(
                       i_curr_code => aup_api_tag_pkg.get_tag_value(
                                          i_auth_id => a.id
                                        , i_tag_id  => l_tag_cur
                                      )
                   )                                                                            as cash_curr
                 , o.oper_amount/100                                                            as auth_amnt
                 , com_api_currency_pkg.get_currency_name( i_curr_code => o.oper_currency )     as auth_curr
                 , 0                                                                            as bank_margin
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
                       end)                                                                  as sttl_curr
                 , get_article_text(
                       i_article => o.terminal_type
                     , i_lang    => com_api_const_pkg.LANGUAGE_ENGLISH
                   )                                                                            as dev
                 , a.system_trace_audit_number                                                  as stan
                 , o.merchant_number                                                            as merchant_id
                 , m.merchant_name                                                              as merchant_name
                 , iss_api_card_pkg.get_card_mask(oc.card_number)                               as card_number
                 , com_api_country_pkg.get_country_full_name(
                       i_code        => o.merchant_country
                     , i_lang        => com_api_const_pkg.LANGUAGE_ENGLISH
                     , i_raise_error => com_api_const_pkg.FALSE
                   )                                                                            as country
            from opr_operation o
                join aut_auth a on a.id = o.id
                join opr_participant pa on pa.oper_id = o.id and pa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER--PRTYACQ
                join opr_participant pi on pi.oper_id = o.id and pi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER--PRTYISS
                left join opr_card oc on oc.oper_id = o.id
                left join acq_merchant m on m.merchant_number = o.merchant_number
                left join vis_multipurpose vi on vi.match_auth_id = o.id --TC33
                                       and vi.status = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
                left join mcw_fin mf on mf.id = o.id
                left join mcw_fpd mi on mi.p0375 = to_char(o.id) and mi.id = mf.fpd_id
            where 1=1
              and o.status in (opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES, opr_api_const_pkg.OPERATION_STATUS_PROCESSED)
              and o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM --TRMT0002
              and o.sttl_type = opr_api_const_pkg.SETTLEMENT_THEMONUS --STTT0200
              and pa.inst_id = l_inst_id
              and trunc(o.host_date) between l_start_date and l_end_date
              and o.oper_amount <> 0
              and exists (select 1
                           from aup_tag_value v
                          where v.auth_id = a.id
                            and v.tag_id in (l_tag_amt, l_tag_cur))
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
            , get_header(l_inst_id, l_start_date, l_end_date, l_lang, 'dd.mm.yyyy')
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
procedure dcc_transaction_month (
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
    l_total                        xmltype;
    l_result                       xmltype;

    l_tag_amt                      com_api_type_pkg.t_short_id;
    l_tag_cur                      com_api_type_pkg.t_short_id;

    PROCEDURE_NAME        constant com_api_type_pkg.t_name := 'dcc_transaction_month';
begin
    l_inst_id    := coalesce(i_inst_id, com_ui_user_env_pkg.get_user_inst, get_def_inst);
    l_lang       := coalesce(i_lang, get_user_lang, get_def_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date   := trunc(nvl(i_end_date,   com_api_sttl_day_pkg.get_sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;

    l_tag_amt    := aup_api_tag_pkg.find_tag_by_reference('DF8A76');
    l_tag_cur    := aup_api_tag_pkg.find_tag_by_reference('DF8A77');

    trc_log_pkg.debug (
        i_text          => PACKAGE_NAME||'.'||PROCEDURE_NAME||' [#1][#2][#3]'
        , i_env_param1  => l_inst_id
        , i_env_param2  => com_api_type_pkg.convert_to_char(l_start_date)
        , i_env_param3  => com_api_type_pkg.convert_to_char(l_end_date)
    );

    -- details
    begin
        with t as (
            select count(id) as tsc_count
                 , sum(cash_amnt)/100 as cash_amnt
                 , cash_curr
                 , sum(auth_amt)/100 as auth_amnt
                 , auth_curr
                 , sum(sttl_amt)/100 as sttl_amnt
                 , sttl_curr
            from (
                select o.id
                     , to_number(aup_api_tag_pkg.get_tag_value(i_auth_id => a.id, i_tag_id => l_tag_amt)) as cash_amnt
                     , com_api_currency_pkg.get_currency_name( i_curr_code =>
                           aup_api_tag_pkg.get_tag_value(i_auth_id => a.id, i_tag_id => l_tag_cur)) as cash_curr
                     , o.oper_amount as auth_amt
                     , com_api_currency_pkg.get_currency_name( i_curr_code => o.oper_currency ) as auth_curr
                     , (case when pi.network_id = cmp_api_const_pkg.VISA_NETWORK
                               then vi.trxn_amount/100
                                when pi.network_id = cmp_api_const_pkg.MC_NETWORK
                               then mi.p0394_2 * decode(mi.p0394_1, 'D', -1, 1) / 100
                               else null
                           end)                                                                  as sttl_amt
                     , (case when pi.network_id = cmp_api_const_pkg.VISA_NETWORK
                               then com_api_currency_pkg.get_currency_name( i_curr_code => vi.currency_code)
                                when pi.network_id = cmp_api_const_pkg.MC_NETWORK
                               then com_api_currency_pkg.get_currency_name( i_curr_code => mi.de050)
                               else null
                           end)                                                                  as sttl_curr
                 from opr_operation o
                  join aut_auth a on a.id = o.id
                  join opr_participant pa on pa.oper_id = o.id and pa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER--PRTYACQ
                  join opr_participant pi on pi.oper_id = o.id and pi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER--PRTYISS
                  left join vis_multipurpose vi on vi.match_auth_id = o.id --TC33
                                         and vi.status = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
                  left join mcw_fin mf on mf.id = o.id
                  left join mcw_fpd mi on mi.p0375 = to_char(o.id) and mi.id = mf.fpd_id
                where 1=1
                  and o.status in (opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES, opr_api_const_pkg.OPERATION_STATUS_PROCESSED)
                  and o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM --TRMT0002
                  and o.sttl_type = opr_api_const_pkg.SETTLEMENT_THEMONUS --STTT0200
                  and pa.inst_id = l_inst_id
                  and trunc(o.host_date) between l_start_date and l_end_date
                  and o.oper_amount <> 0
                  and exists (select 1
                               from aup_tag_value v
                              where v.auth_id = a.id
                                and v.tag_id in (l_tag_amt, l_tag_cur))
            ) group by cash_curr, auth_curr, sttl_curr
        )
        , s as (
            select sum(tsc_count) as total_count
                 , sum(cash_amnt) as total_amnt
             from t
        )
        select (
                select
                    xmlelement("details"
                      , xmlagg(
                            xmlelement("detail"
                              , xmlelement("tcs_count",     to_char(tsc_count))
                              , xmlelement("cash_amnt",     to_char(cash_amnt, com_api_const_pkg.XML_FLOAT_FORMAT))
                              , xmlelement("cash_curr",     cash_curr)
                              , xmlelement("auth_amnt",     to_char(auth_amnt, com_api_const_pkg.XML_FLOAT_FORMAT))
                              , xmlelement("auth_curr",     auth_curr)
                              , xmlelement("sttl_amnt",     to_char(sttl_amnt, com_api_const_pkg.XML_FLOAT_FORMAT))
                              , xmlelement("sttl_curr",     sttl_curr)
                            )
                            order by cash_curr, auth_curr, sttl_curr
                        )
                    )
                from t
              )
            , (
                select
                    xmlelement("totals"
                      , xmlagg(
                            xmlelement("total"
                              , xmlelement("tcs_count",     to_char(total_count))
                              , xmlelement("cash_amnt",     to_char(total_amnt, com_api_const_pkg.XML_FLOAT_FORMAT))
                            )
                        )
                    )
                from s
              )
         into l_detail, l_total
         from dual;
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
            , get_header(l_inst_id, l_start_date, l_end_date, l_lang, 'dd.mm.yyyy')
            , l_detail
            , l_total
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
procedure visa_atm_transaction_extended (
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
    l_no_shipment                  xmltype;
    l_result                       xmltype;

    PROCEDURE_NAME constant com_api_type_pkg.t_name := 'visa_atm_transaction_extended';
begin
    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc( nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date :=   trunc( nvl(i_end_date,   com_api_sttl_day_pkg.get_sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id := nvl(i_inst_id, 0);

    trc_log_pkg.debug (
        i_text          => PACKAGE_NAME||'.'||PROCEDURE_NAME||' [#1][#2][#3]'
        , i_env_param1  => l_inst_id
        , i_env_param2  => com_api_type_pkg.convert_to_char(l_start_date)
        , i_env_param3  => com_api_type_pkg.convert_to_char(l_end_date)
    );

    --
    with tran as (
        --oper with or without TC33
        select o.id
             , o.host_date as oper_date
             , o.merchant_name
             , trim(o.terminal_number||' '||o.merchant_city||' '||o.merchant_name) as client_name
             , iss_api_card_pkg.get_card_mask(oc.card_number) as card_number
             , o.originator_refnum as ref_nr
             , a.system_trace_audit_number as stan

             , s.file_name
             , nvl(v.sttl_date, trunc(o.host_date)+1) as visa_sttl_date
             , o.is_reversal
             , o.oper_amount/100 as oper_amount
             , com_api_currency_pkg.get_currency_name( i_curr_code => o.oper_currency) as oper_currency
             , v.trxn_amount/100 as sttl_amount
             , com_api_currency_pkg.get_currency_name( i_curr_code => v.currency_code) as sttl_currency

             , v.match_auth_id
             , f.proc_bin as acquirer_bin
             , case when v.match_auth_id is not null then 1 else 2 end block_num

        from opr_operation o
        join opr_card oc        on oc.oper_id = o.id
        join aut_auth a         on a.id = o.id
        join opr_participant pa on pa.oper_id = o.id and pa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER--PRTYACQ
        join opr_participant pi on pi.oper_id = o.id
                               and pi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER--PRTYISS
                               and pi.network_id = cmp_api_const_pkg.VISA_NETWORK --1003
        left join vis_multipurpose v on v.match_auth_id = o.id --TC33
                               and v.status = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
        left join vis_file f         on f.id = v.file_id and f.is_incoming = 1
        left join prc_session_file s on s.id = f.session_file_id
        where 1=1
          and pa.inst_id = l_inst_id
          and trunc(o.host_date) between l_start_date and l_end_date
          and o.oper_amount <> 0
          and o.status in (opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES, opr_api_const_pkg.OPERATION_STATUS_PROCESSED)
          and o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM --TRMT0002
          and o.sttl_type = opr_api_const_pkg.SETTLEMENT_THEMONUS --STTT0200
       union all
        --TC33 without oper
        select v.id
             , null as oper_date
             , null as merchant_name
             , null as client_name
             , iss_api_card_pkg.get_card_mask(v.card_number) as card_number
             , v.refnum as ref_nr
             , v.trace_num as stan

             , s.file_name
             , v.sttl_date as visa_sttl_date
             , case when v.req_msg_type in ('0400', '0420') then 1 else 0 end is_reversal
             , null as oper_amount
             , null as oper_currency
             , v.trxn_amount/100 as sttl_amount
             , com_api_currency_pkg.get_currency_name( i_curr_code => v.currency_code) as sttl_currency

             , v.match_auth_id
             , f.proc_bin as acquirer_bin
             , 3 as block_num

         from vis_multipurpose v
             join vis_file f         on f.id = v.file_id and f.is_incoming = 1
             join prc_session_file s on s.id = f.session_file_id
         where v.match_auth_id is null
           and v.iss_acq='A'
           and substr(v.proc_code, 1, 2) in ('01')--ATM CASH
           and v.inst_id = l_inst_id
           and v.sttl_date between l_start_date and l_end_date
    )
    , detail as (
        select
            file_name
          , visa_sttl_date
          , merchant_name
          , id
          , card_number
          , ref_nr
          , oper_date
          , (case when is_reversal=1 then -1 else 1 end) * oper_amount as oper_amount
          , oper_currency
          , (case when is_reversal=1 then -1 else 1 end) * sttl_amount as sttl_amount
          , sttl_currency
          , stan

          , dense_rank() over (partition by 1 order by visa_sttl_date, file_name) as group_id1
          , dense_rank() over (partition by 1 order by visa_sttl_date, file_name, merchant_name) as group_id2

        from tran
        where block_num in (1,2)--oper
    )
    , no_shipment as (
        select t.*
             , (case when is_reversal=1 then -1 else 1 end) * sttl_amount as sttl_amount_sign
        from tran t
        where block_num = 3 --not found in oper
    )
    select
      -- details
        (   select xmlelement("details"
                 , xmlagg(
                       xmlelement("detail"
                          , xmlelement("group_id1", group_id1)
                          , xmlelement("visa_sttl_date", to_char(visa_sttl_date, 'dd.mm.yyyy'))
                          , xmlelement("shipment", to_char(visa_sttl_date,'YYYYMMDD'))
                          , xmlelement("group_id2", group_id2)
                          , xmlelement("merchant_name", merchant_name)
                          , xmlelement("id", id)
                          , xmlelement("card", card_number)
                          , xmlelement("ref_nr", ref_nr)
                          , xmlelement("tran_date_time", to_char(oper_date, 'dd.mm.yyyy hh24:mi:ss'))
                          , xmlelement("amount", to_char(oper_amount,com_api_const_pkg.XML_FLOAT_FORMAT))
                          , xmlelement("ccy", oper_currency)
                          , xmlelement("stan", stan)
                          , xmlelement("sttl_amount", to_char(sttl_amount, com_api_const_pkg.XML_FLOAT_FORMAT))
                          , xmlelement("sttl_ccy", sttl_currency)
                        )
                        order by group_id1, group_id2, id
                    )
                )
            from detail
        )
      -- no_shipment
      , (   select
            xmlelement("no_shipment"
              , xmlagg(
                    xmlelement("detail"
                      , xmlelement("id", id)
                      , xmlelement("card", card_number)
                      , xmlelement("ref_nr", ref_nr)
                      , xmlelement("amount", to_char(sttl_amount_sign,com_api_const_pkg.XML_FLOAT_FORMAT))
                      , xmlelement("ccy", sttl_currency)
                      , xmlelement("stan", stan)
                    )
                    order by visa_sttl_date, id
                )
            )
            from no_shipment
        )
    into l_detail, l_no_shipment
    from dual;

    select
        xmlelement (
            "report"
            , get_header(l_inst_id, l_start_date, l_end_date, l_lang)
            , l_detail
            , l_no_shipment
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
procedure visa_atm_transaction (
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
    l_acq_bin                      com_api_type_pkg.t_name;

    l_detail                       xmltype;
    l_totals                       xmltype;
    l_slips                        xmltype;
    l_result                       xmltype;

    PROCEDURE_NAME constant com_api_type_pkg.t_name := 'visa_atm_transaction';
begin
    l_inst_id    := coalesce(i_inst_id, com_ui_user_env_pkg.get_user_inst, get_def_inst);
    l_lang       := coalesce(i_lang, get_user_lang, get_def_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date   := trunc(nvl(i_end_date,   com_api_sttl_day_pkg.get_sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;

    trc_log_pkg.debug (
        i_text          => PACKAGE_NAME||'.'||PROCEDURE_NAME||' [#1][#2][#3]'
        , i_env_param1  => l_inst_id
        , i_env_param2  => com_api_type_pkg.convert_to_char(l_start_date)
        , i_env_param3  => com_api_type_pkg.convert_to_char(l_end_date)
    );
    --> ACQ_BIN
    declare
        l_param_tab             com_api_type_pkg.t_param_tab;
        l_host_id               com_api_type_pkg.t_long_id;
        l_standard_id           com_api_type_pkg.t_tiny_id;
    begin
        l_host_id     := net_api_network_pkg.get_default_host(i_network_id => cmp_api_const_pkg.VISA_NETWORK);
        l_standard_id := net_api_network_pkg.get_offline_standard(i_network_id => cmp_api_const_pkg.VISA_NETWORK);
        l_acq_bin :=
                cmn_api_standard_pkg.get_varchar_value(
                    i_inst_id       => l_inst_id
                  , i_standard_id   => l_standard_id
                  , i_object_id     => l_host_id
                  , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
                  , i_param_name    => vis_api_const_pkg.CMID
                  , i_param_tab     => l_param_tab
                );
    exception
        when others then
            l_acq_bin := null;
    end;
    --< ACQ_BIN

    with tran as (
        --oper with or without TC33
        select o.id
             , o.host_date as oper_date
             , o.merchant_name
             , trim(o.terminal_number||' '||o.merchant_city||' '||o.merchant_name) as client_name
             , iss_api_card_pkg.get_card_mask(oc.card_number) as card_number
             , o.originator_refnum as ref_nr
             , a.system_trace_audit_number as stan

             , s.file_name
             , nvl(v.sttl_date, trunc(o.host_date)+1) as visa_sttl_date
             , o.is_reversal
             , o.oper_amount/100 as oper_amount
             , com_api_currency_pkg.get_currency_name( i_curr_code => o.oper_currency) as oper_currency
             , v.trxn_amount/100 as sttl_amount
             , com_api_currency_pkg.get_currency_name( i_curr_code => v.currency_code) as sttl_currency

             , v.match_auth_id
             , f.proc_bin as acquirer_bin
             , case when v.match_auth_id is not null then 1 else 2 end block_num

        from opr_operation o
        join opr_card oc        on oc.oper_id = o.id
        join aut_auth a         on a.id = o.id
        join opr_participant pa on pa.oper_id = o.id and pa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER--PRTYACQ
        join opr_participant pi on pi.oper_id = o.id
                               and pi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER--PRTYISS
                               and pi.network_id = cmp_api_const_pkg.VISA_NETWORK --1003
        left join vis_multipurpose v on v.match_auth_id = o.id --TC33
                               and v.status = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
        left join vis_file f         on f.id = v.file_id and f.is_incoming = 1
        left join prc_session_file s on s.id = f.session_file_id
        where 1=1
          and pa.inst_id = l_inst_id
          and trunc(o.host_date) between l_start_date and l_end_date
          and o.oper_amount <> 0
          and o.status in (opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES, opr_api_const_pkg.OPERATION_STATUS_PROCESSED)
          and o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM --TRMT0002
          and o.sttl_type = opr_api_const_pkg.SETTLEMENT_THEMONUS --STTT0200
       union all
        --TC33 without oper
        select v.id
             , null as oper_date
             , null as merchant_name
             , null as client_name
             , iss_api_card_pkg.get_card_mask(v.card_number) as card_number
             , v.refnum as ref_nr
             , v.trace_num as stan

             , s.file_name
             , v.sttl_date as visa_sttl_date
             , case when v.req_msg_type in ('0400', '0420') then 1 else 0 end is_reversal
             , null as oper_amount
             , null as oper_currency
             , v.trxn_amount/100 as sttl_amount
             , com_api_currency_pkg.get_currency_name( i_curr_code => v.currency_code) as sttl_currency

             , v.match_auth_id
             , f.proc_bin as acquirer_bin
             , 3 as block_num

         from vis_multipurpose v
             join vis_file f         on f.id = v.file_id and f.is_incoming = 1
             join prc_session_file s on s.id = f.session_file_id
         where v.match_auth_id is null
           and v.iss_acq='A'
           and substr(v.proc_code, 1, 2) in ('01')--ATM CASH
           and v.inst_id = l_inst_id
           and v.sttl_date between l_start_date and l_end_date
    )
    , detail as (
        select
            file_name
          , visa_sttl_date
          , client_name
          , count(*) as cnt
          , sum((case when is_reversal=1 then -1 else 1 end) * nvl(oper_amount,0)) as oper_amount
          , oper_currency
          , sum((case when is_reversal=1 then -1 else 1 end) * nvl(sttl_amount,0)) as sttl_amount
          , sttl_currency

          , dense_rank() over (partition by 1 order by visa_sttl_date, file_name) as group_id1
          , dense_rank() over (partition by 1 order by visa_sttl_date, file_name, oper_currency) as group_id2

        from tran
        where block_num in (1,3)--oper
        group by visa_sttl_date, file_name, client_name, oper_currency, sttl_currency
    )
    , total as (
        select nvl(count(id)       , 0) as total_cnt
             , nvl(sum((case when is_reversal=1 then -1 else 1 end) * nvl(oper_amount,0)), 0) as total_amount
             , oper_currency            as total_ccy
             , nvl(sum((case when is_reversal=1 then -1 else 1 end) * nvl(sttl_amount,0)), 0) as total_sttl_amount
             , sttl_currency            as total_sttl_ccy
         from tran where block_num in (1,3)--oper
         group by oper_currency, sttl_currency
    )
    , slip as (
        select t.*
             , (case when is_reversal=1 then -1 else 1 end) * nvl(oper_amount,0) as oper_amount_sign
        from tran t
        where block_num = 2 --not found in RAW
    )
    select
      -- details
        (   select xmlelement("details"
                 , xmlagg(
                       xmlelement("detail"
                          , xmlelement("group_id1", group_id1)
                          , xmlelement("file_name", file_name)
                          , xmlelement("visa_sttl_date", to_char(visa_sttl_date, 'dd.mm.yyyy'))
                          , xmlelement("group_id2", group_id2)
                          , xmlelement("sttl_ccy", sttl_currency)
                          , xmlelement("client", client_name)
                          , xmlelement("cnt", cnt)
                          , xmlelement("amount", to_char(oper_amount, com_api_const_pkg.XML_FLOAT_FORMAT))
                          , xmlelement("ccy", oper_currency)
                          , xmlelement("sttl_amount", to_char(sttl_amount, com_api_const_pkg.XML_FLOAT_FORMAT))
                        )
                        order by group_id1, group_id2
                    )
                )
            from detail
        )
      -- totals
      , (   select xmlelement("totals"
                 , xmlagg(
                       xmlelement("total"
                          , xmlelement("total_cnt", total_cnt)
                          , xmlelement("total_amount", to_char(total_amount, com_api_const_pkg.XML_FLOAT_FORMAT))
                          , xmlelement("total_ccy", total_ccy)
                          , xmlelement("total_sttl_amount", to_char(total_sttl_amount, com_api_const_pkg.XML_FLOAT_FORMAT))
                          , xmlelement("total_sttl_ccy", total_sttl_ccy)
                        )
                        order by total_ccy, total_sttl_ccy
                    )
                )
            from total
        )
      -- slips
      , (   select xmlelement("slips"
                 , xmlagg(
                       xmlelement("slip"
                          , xmlelement("id", id)
                          , xmlelement("merchant_name", merchant_name)
                          , xmlelement("tran_date_time", to_char(oper_date, 'dd.mm.yyyy hh24:mi:ss'))
                          , xmlelement("card", card_number)
                          , xmlelement("ref_nr", ref_nr)
                          , xmlelement("stan", stan)
                          , xmlelement("amount", to_char(oper_amount_sign, com_api_const_pkg.XML_FLOAT_FORMAT))
                          , xmlelement("ccy", oper_currency)
                        )
                        order by visa_sttl_date,id
                   )
                )
            from slip
        )
    into l_detail, l_totals, l_slips
    from dual;

    --report
    select
        xmlelement (
            "report"
            , get_header(l_inst_id, l_start_date, l_end_date, l_lang, 'dd.mm.yyyy', l_acq_bin)
            , l_detail
            , l_totals
            , l_slips
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

end cst_aua_api_report_pkg;
/
