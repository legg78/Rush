create or replace package body net_api_report_pkg as

procedure net_member_position_report(
    o_xml           out clob
  , i_sttl_date         date
  , i_date_start in     date
  , i_date_end   in     date
  , i_currency   in     com_api_type_pkg.t_curr_code
  , i_inst_id    in     com_api_type_pkg.t_inst_id
  , i_lang       in     com_api_type_pkg.t_dict_value
) is
    l_date_start        date := i_date_start;
    l_date_end          date := i_date_end;
    l_lang              com_api_type_pkg.t_dict_value;

    l_header            xmltype;
    l_detail            xmltype;
    l_result            xmltype;
    l_currency          com_api_type_pkg.t_name;
	l_logo_path         xmltype;

begin
    l_lang       := nvl(i_lang, get_user_lang);
    trc_log_pkg.debug(
        i_text => 'net_api_report_pkg.net_member_position_report - Started'
    );

    if i_currency is not null then
        l_currency :=
            i_currency || ' ' ||
            com_api_currency_pkg.get_currency_name(i_curr_code => i_currency) || ' ' ||
            com_api_currency_pkg.get_currency_full_name(i_curr_code => i_currency, i_lang => l_lang);
    else
        l_currency := '   ';
    end if;

    if i_sttl_date is not null then
        l_date_start := trunc(i_sttl_date);
        l_date_end   := trunc(i_sttl_date);
    else

        if l_date_start is null then
            l_date_start := trunc(com_api_sttl_day_pkg.get_open_sttl_date(i_inst_id => i_inst_id));
        end if;

        if l_date_end is null then
            l_date_end := trunc(com_api_sttl_day_pkg.get_open_sttl_date(i_inst_id => i_inst_id));
        end if;
    end if;

    trc_log_pkg.debug (
              i_text        => 'cst_lvp_report_pkg.card_inventory [#1][#2][#3][#4]'
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
             , xmlelement("p_curr"       , l_currency)
             , xmlelement("p_date_start" , to_char(l_date_start, 'dd/mm/yyyy'))
             , xmlelement("p_date_end"   , to_char(l_date_end  ,  'dd/mm/yyyy'))
             , xmlelement("p_sttl_date"  , nvl2(i_sttl_date    ,  to_char(i_sttl_date , 'dd/mm/yyyy'), ' ') )
             , xmlelement("p_inst"       , decode (i_inst_id, null, '  '
                                                 , i_inst_id || ' - ' || get_text('OST_INSTITUTION','NAME', i_inst_id, l_lang))
                          )
           )
      into l_header
      from dual;

    select xmlelement(
               "details"
             , xmlagg(
                   xmlelement(
                       "detail"
                     , xmlelement("curr"          , currency)
                     , xmlelement("member"        , nvl(x.record_type, inst_id || ' ' || ost_ui_institution_pkg.get_inst_name(inst_id)))
                     , xmlelement("debit_value"   , x.debit_value / x.multiplier  )
                     , xmlelement("credit_value"  , x.credit_value / x.multiplier )
                     , xmlelement("net_value"     , ( credit_value - debit_value) / x.multiplier  )
                     , xmlelement("record_type"   , x.record_type)
                   )
               )
            )
      into l_detail
      from (
          select a.inst_id
               , com_api_currency_pkg.get_currency_name(e.currency) currency
               , nvl(sum(case e.balance_impact when 1 then e.amount end), 0) credit_value
               , nvl(sum(case e.balance_impact when -1 then e.amount end), 0) debit_value
               , case when m.amount_purpose like '%FETP%' then 'Fees' else 'Transactions' end as record_type
               , com_api_currency_pkg.get_multiplier(i_curr_code => e.currency) as multiplier
            from acc_account a
               , acc_entry e
               , acc_macros m
               , opr_operation op
               , opr_participant p_iss
               , opr_participant p_acq
           where a.id                   = e.account_id
             and m.id                   = e.macros_id
             and e.status              != acc_api_const_pkg.ENTRY_STATUS_CANCELED
             and m.entity_type          = opr_api_const_pkg.ENTITY_TYPE_OPERATION
             and op.id                  = m.object_id
             and p_acq.oper_id          = op.id
             and p_acq.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
             and p_iss.oper_id          = op.id
             and p_iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
             and p_iss.inst_id         != p_acq.inst_id -- exclude us_on_us transactions
             and (e.currency            = i_currency or i_currency is null)
             and (a.inst_id             = i_inst_id or i_inst_id is null)
             and e.posting_date        >= trunc(l_date_start) and e.posting_date < trunc(l_date_end) + 1
             and e.split_hash  in (select sm.split_hash from com_api_split_map_vw sm)
        group by grouping sets(
                               (   e.currency
                                 , a.inst_id || case when m.amount_purpose like '%FETP%' then 'Fees' else 'Transactions' end
                                 , a.inst_id
                                 , case when m.amount_purpose like '%FETP%' then 'Fees' else 'Transactions' end
                                )
                              , (  e.currency
                                 , a.inst_id
                                )
                              )
        order by e.currency
               , inst_id
               , decode(record_type, null, 1, 'Transactions', 2, 3)
       ) x;

    --if no data
    if l_detail.getclobval() = '<details></details>' then
        select xmlelement(
                   "details"
                 , xmlagg(
                       xmlelement(
                           "detail"
                         , xmlelement("curr"         , null)
                         , xmlelement("member"       , null)
                         , xmlelement("debit_value"  , null)
                         , xmlelement("credit_value" , null)
                         , xmlelement("net_value"    , null)
                         , xmlelement("record_type"  , null)
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
        i_text => 'net_api_report_pkg.net_member_position_report - ok'
    );
exception when others then
    trc_log_pkg.debug(i_text => sqlerrm);
    raise ;
end;

procedure unmatched_presentments(
    o_xml            out clob
  , i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_network_id  in     com_api_type_pkg.t_tiny_id     default null
  , i_start_date  in     date
  , i_end_date    in     date
  , i_lang        in     com_api_type_pkg.t_dict_value  default null
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.unmatched_presentments: ';
    l_start_date           date;
    l_end_date             date;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_header               xmltype;
    l_detail               xmltype;
    l_result               xmltype;

begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'inst [#1], start_date [#2], end_date [#3], i_network_id [#4], lang [#5]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_start_date
      , i_env_param3 => i_end_date
      , i_env_param4 => i_network_id
      , i_env_param5 => i_lang
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    with rawdata as (
        select o.id                   as oper_id
             , o.original_id
             , o.oper_type
             , get_label_text(
                   i_name => o.oper_type
                 , i_lang => l_lang
               )                      as oper_type_desc
             , o.oper_date
             , o.sttl_amount
             , o.sttl_currency
             , com_api_currency_pkg.get_amount_str(
                   i_amount     => o.sttl_amount
                 , i_curr_code  => o.sttl_currency
                 , i_mask_error => com_api_const_pkg.TRUE
               )                      as sttl_amount_str
             , o.is_reversal
             , o.mcc
             , o.merchant_number
             , o.merchant_name
             , ltrim(nvl2(o.merchant_postcode,         o.merchant_postcode, null) ||
                     nvl2(o.merchant_street,   ', ' || o.merchant_street, null)   ||
                     nvl2(o.merchant_city,     ', ' || o.merchant_city, null)     ||
                     nvl2(o.merchant_region,   ', ' || o.merchant_region, null)   ||
                     nvl2(o.merchant_country,  ', ' || o.merchant_country, null))
                                      as merchant_address
             , op.auth_code
             , iss_api_card_pkg.get_card_mask(
                   i_card_number => oc.card_number
               )                      as card_mask
             , coalesce(mf.de031, vf.arn, jf.de031, muf.de031, am.arn, hf.arn, cmf.arn)
                                      as arn
             , coalesce(mf.de032, vf.acquirer_bin, jf.de032, muf.de032, hf.acq_inst_bin, nm.acq_inst_code)
                                      as acquirer_bin
          from opr_operation o
          join opr_participant op on o.id = op.oper_id
                                      and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                                      and op.inst_id = i_inst_id
          left join opr_card oc on oc.oper_id = op.oper_id
                               and oc.participant_type = op.participant_type
          ---- fin tables ----
          left join mcw_fin          mf on mf.id  = o.id
          left join vis_fin_message  vf on vf.id  = o.id
          left join jcb_fin_message  jf on jf.id  = o.id
          left join mup_fin         muf on muf.id = o.id
          left join cup_fin_message  cf on cf.id  = o.id
          left join din_fin_message  df on df.id  = o.id
          left join amx_fin_message  am on am.id  = o.id
          left join h2h_fin_message  hf on hf.id  = o.id
          left join cmp_fin_message cmf on cmf.id = o.id
          left join nbc_fin_message  nm on nm.id  = o.id
         where o.match_status in (OPR_API_CONST_PKG.OPERATION_MATCH_REQ_MATCH
                                , OPR_API_CONST_PKG.OPERATION_MATCH_EXPIRED)
           and o.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
           and (coalesce(mf.network_id
                       , vf.network_id
                       , jf.network_id
                       , muf.network_id
                       , cf.network_id
                       , df.network_id
                       , am.network_id
                       , hf.network_id
                       , cmf.network_id
                       , nm.network_id) = i_network_id
                or i_network_id is null
               )
           and o.oper_date between l_start_date and l_end_date
    )
    select
        xmlelement(
            "operations"
          , xmlagg(
                xmlelement(
                    "operation"
                   , xmlelement("oper_id"           , oper_id)
                   , xmlelement("original_id"       , original_id)
                   , xmlelement("oper_type"         , oper_type)
                   , xmlelement("oper_type_desc"    , oper_type_desc)
                   , xmlelement("oper_date"         , oper_date)
                   , xmlelement("sttl_amount"       , sttl_amount)
                   , xmlelement("sttl_currency"     , sttl_currency)
                   , xmlelement("sttl_amount_str"   , sttl_amount_str)
                   , xmlelement("auth_code"         , auth_code)
                   , xmlelement("is_reversal"       , is_reversal)
                   , xmlelement("card_mask"         , card_mask)
                   , xmlelement("arn"               , arn)
                   , xmlelement("acquirer_bin"      , acquirer_bin)
                   , xmlelement("mcc"               , mcc)
                   , xmlelement("merchant_number"   , merchant_number)
                   , xmlelement("merchant_name"     , merchant_name)
                   , xmlelement("merchant_address"  , merchant_address)
                )
           )
        ) r
    into
        l_detail
    from
        rawdata;

    select
        xmlelement(
            "header"
          , xmlelement("inst_id"        , nvl(i_inst_id, 0))
          , xmlelement("inst_name"      , ost_ui_institution_pkg.get_inst_name(
                                              i_inst_id => i_inst_id
                                            , i_lang    => l_lang))
          , xmlelement("start_date"     , to_char(l_start_date, 'dd.mm.yyyy'))
          , xmlelement("end_date"       , to_char(l_end_date, 'dd.mm.yyyy'))
          , xmlelement("network_id"     , nvl(i_network_id, 0))
          , xmlelement("network_name"   , get_text (i_table_name    => 'NET_NETWORK'
                                                  , i_column_name   => 'NAME'
                                                  , i_object_id     => i_network_id
                                                  , i_lang          => l_lang))
        ) r
    into
        l_header
    from
        dual;

    if l_detail.getclobval = '<operations></operations>' then
       select
        xmlelement(
            "operations"
          , xmlagg(
                xmlelement(
                    "operation"
                   , xmlelement("oper_id"           , null)
                   , xmlelement("original_id"       , null)
                   , xmlelement("oper_type"         , null)
                   , xmlelement("oper_type_desc"    , null)
                   , xmlelement("oper_date"         , null)
                   , xmlelement("sttl_amount"       , null)
                   , xmlelement("sttl_currency"     , null)
                   , xmlelement("sttl_amount_str"   , null)
                   , xmlelement("auth_code"         , null)
                   , xmlelement("is_reversal"       , null)
                   , xmlelement("card_mask"         , null)
                   , xmlelement("arn"               , null)
                   , xmlelement("acquirer_bin"      , null)
                   , xmlelement("mcc"               , null)
                   , xmlelement("merchant_number"   , null)
                   , xmlelement("merchant_name"     , null)
                   , xmlelement("merchant_address"  , null)
                )
           )
        ) r
       into
           l_detail
       from dual;
   end if;

    select
        xmlelement(
            "report"
            , l_header
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'end'
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || sqlerrm
        );
        raise;
end unmatched_presentments;

end net_api_report_pkg;
/
