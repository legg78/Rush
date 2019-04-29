create or replace package body cst_cab_api_report_pkg is

function get_account_extra_limit(
    i_account_id        in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_money
is
    l_limit_id          com_api_type_pkg.t_long_id;
    l_limit_value       com_api_type_pkg.t_money;
begin
    if i_account_id is not null then
        l_limit_id := 
            prd_api_product_pkg.get_attr_value_number(
                i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => i_account_id
              , i_attr_name         => 'ACC_ACCOUNT_EXTRA_LIMIT_VALUE'
              , i_mask_error        => com_api_const_pkg.TRUE
            );
        
        if l_limit_id is not null then
            for m in (
                select limit_type
                     , limit_base
                     , limit_rate
                     , sum_limit
                     , currency
                     , inst_id
                  from fcl_limit
                 where id = l_limit_id
            ) loop            
                if m.sum_limit <> -1 and (m.limit_rate is null or m.limit_rate = 0) then 
                    l_limit_value := m.sum_limit;
                else
                l_limit_value := 
                    fcl_api_limit_pkg.get_limit_border_sum(
                        i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id     => i_account_id
                      , i_limit_type    => m.limit_type
                      , i_limit_base    => m.limit_base
                      , i_limit_rate    => m.limit_rate
                      , i_currency      => m.currency
                      , i_inst_id       => m.inst_id
                      , i_product_id    => prd_api_product_pkg.get_product_id(
                                               i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                             , i_object_id   => i_account_id
                                             , i_eff_date    => get_sysdate
                                             , i_inst_id     => m.inst_id
                                           )
                      , i_mask_error    => com_api_const_pkg.TRUE
                    );        
                end if;       
            end loop;         
        end if;
        return l_limit_value;
    end if;
end get_account_extra_limit;

procedure pos_epos_settlement_trans (
    o_xml               out clob
  , i_lang           in     com_api_type_pkg.t_dict_value
  , i_start_date     in     date
  , i_end_date       in     date
  , i_inst_id        in     com_api_type_pkg.t_inst_id  default null
) is
    l_start_date            date;
    l_end_date              date;
    l_lang                  com_api_type_pkg.t_dict_value;

    l_header                xmltype;
    l_detail                xmltype;
    l_result                xmltype;
begin

    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date   := nvl(trunc(i_end_date), l_start_date) + 1 - 1/86400;
    l_lang       := coalesce(i_lang, get_user_lang, com_api_const_pkg.LANGUAGE_ENGLISH);

    trc_log_pkg.debug (
        i_text        => 'cst_cab_api_report_pkg.pos_epos_settlement_trans [#1], [#2], [#3], [#4]'
      , i_env_param1  => l_lang
      , i_env_param2  => com_api_type_pkg.convert_to_char(l_start_date)
      , i_env_param3  => com_api_type_pkg.convert_to_char(l_end_date)
      , i_env_param4  => i_inst_id
    );
    -- header
    select xmlelement(
               "header"
             , xmlelement("p_date_start", to_char(l_start_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT))
             , xmlelement("p_date_end"  , to_char(l_end_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT))
             , xmlelement("p_inst_id"   , decode(
                                              i_inst_id
                                            , null
                                            , '0'
                                            , i_inst_id || ' - ' || get_text('OST_INSTITUTION', 'NAME', i_inst_id, l_lang)
                                          )
                         )
           )
      into l_header
      from dual;
    -- details
    select xmlelement("transactions"
             , xmlagg(
                   xmlelement("transaction"
                     , xmlelement("currency"               , currency)
                     , xmlelement("agent_code"             , ost_ui_agent_pkg.get_agent_number(agent_id))
                     , xmlelement("agent_name"             , nvl( get_text ('OST_AGENT', 'NAME', agent_id, l_lang), ' ' ))
                     , xmlelement("device_number"          , terminal_number)
                     , xmlelement("branch_name"            , nvl(merchant_name,' '))
                     , xmlelement("terminal_type"          , terminal_type)
                     , xmlelement("tran_type"              , oper_type)
                     , xmlelement("merchant_ID"            , merchant_number)
                     , xmlelement("terminal_ID"            , terminal_number)
                     , xmlelement("oper_quantity"          , oper_quantity)
                     , xmlelement("sum_oper_amount"        , sum_oper_amt)
                     , xmlelement("sum_fee_amount"         , sum_fee_amt)
                     , xmlelement("trace_number"           , trace_number)
                     , xmlelement("tran_date"              , to_char(oper_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT))
                     , xmlelement("settle_date"            , to_char(sttl_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT))
                     , xmlelement("merchant_name"          , merchant_name)
                     , xmlelement("outlet_nnumber"         , '')
                     , xmlelement("oper_amount"            , f_oper_amount)
                     , xmlelement("discount_amount"        , discount_amount)
                     , xmlelement("net_amount"             , f_req_amount)
                     , xmlelement("card_number"            , card_number)
                     , xmlelement("merchant_account"       , merchant_account)
                     , xmlelement("card_type"              , card_type)
                     , xmlelement("reversal"               , is_reversal)
                     , xmlelement("referral_number"        , referral_number)
                     , xmlelement("batch_number"           , batch_number )
                     , xmlelement("card_expir_date"        , to_char(card_expir_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT))
                     , xmlelement("pos_entry_mode"         , pos_entry_mode)
                     , xmlelement("auth_code"              , auth_code)
                     , xmlelement("mcc"                    , mcc)
                     , xmlelement("invoice_number"         , '')
                     , xmlelement("arn"                    , arn)
                   )
               )
           )
      into
           l_detail
      from (
           select oper.*
                , acc_api_account_pkg.get_account_number(
                      i_account_id => merchant_account_id
                  ) as merchant_account
                , decode(a.macros_type_id, cst_cab_api_const_pkg.MACROS_MERCHANT_DEBIT_FEE, a.amount, 0) as discount_amount  
                , cst_cab_com_pkg.format_amount(i_amount => oper_amount, i_curr_code => oper_currency) as f_oper_amount
                , cst_cab_com_pkg.format_amount(i_amount => req_amount, i_curr_code => oper_currency) as f_req_amount
                , cst_cab_com_pkg.format_amount(i_amount => fee_amount, i_curr_code => oper_currency) as f_fee_amount
                , count(1) over(partition by merchant_id, batch_number) as oper_quantity
                , cst_cab_com_pkg.format_amount(i_amount => sum(oper_amount) over(partition by merchant_id, batch_number), i_curr_code => oper_currency) as sum_oper_amt
                , cst_cab_com_pkg.format_amount(i_amount => sum(fee_amount) over(partition by merchant_id, batch_number), i_curr_code => oper_currency) as sum_fee_amt
             from (
                  select o.oper_currency
                       , t.inst_id
                       , contr.agent_id
                       , pa.merchant_id
                       , acq_api_merchant_pkg.get_merchant_account_id(i_merchant_id => pa.merchant_id) as merchant_account_id
                       , t.id terminal_id
                       , t.terminal_number
                       , get_article_text(t.terminal_type, l_lang) as terminal_type
                       , a.trace_number
                       , o.merchant_name
                       , o.merchant_number
                       , o.oper_type
                       , o.oper_date
                       , o.sttl_date
                       , o.id as oper_id
                       , o.mcc
                       , d.card_number
                       , pi.card_type_id
                       , com_api_i18n_pkg.get_text('NET_CARD_TYPE','NAME', pi.card_type_id, l_lang) card_type
                       , o.is_reversal
                       , o.originator_refnum referral_number
                       , b.header_batch_reference batch_number
                       , pi.card_expir_date
                       , pi.card_network_id as network_id
                       , pi.auth_code
                       , o.oper_amount * decode(o.is_reversal,1,-1,1)           as oper_amount
                       , o.oper_request_amount * decode(o.is_reversal,1,-1,1)   as req_amount
                       , o.oper_surcharge_amount * decode(o.is_reversal,1,-1,1) as fee_amount
                       , a.pos_entry_mode
                       , f.arn
                       , com_api_currency_pkg.get_currency_name(i_curr_code => o.oper_currency) as currency
                    from opr_operation    o
                       , opr_participant  pa
                       , opr_participant  pi
                       , aut_auth         a
                       , acq_terminal     t
                       , prd_contract     contr
                       , pos_batch_block  b
                       , pos_batch_detail d
                       , opr_ui_arn_fin_message_vw f
                   where o.oper_date between l_start_date and l_end_date
                     and o.status                in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED --OPST0400'
                                                    ,opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES)
                     and o.msg_type              = opr_api_const_pkg.MESSAGE_TYPE_POS_BATCH
                     and o.id                    = pa.oper_id
                     and pa.participant_type     = com_api_const_pkg.PARTICIPANT_ACQUIRER --'PRTYACQ'
                     and o.id                    = pi.oper_id
                     and pi.participant_type     = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
                     and pa.terminal_id          = t.id
                     and contr.id                = t.contract_id
                     and o.sttl_type in ( opr_api_const_pkg.SETTLEMENT_THEMONUS --'STTT0200'
                                        , opr_api_const_pkg.SETTLEMENT_USONUS --'STTT0010'
                                        --, 'STTT5001' --CARDLESS-ON-US
                                        )
                     and ( i_inst_id     is null or t.inst_id = i_inst_id )
                     and o.id                    = a.id
                     and a.external_orig_id      = d.retrieval_reference_number
                     and d.batch_block_id        = b.id
                     and t.terminal_number       = b.header_terminal_id
                     and o.id                    = f.oper_id(+)
                     and pa.terminal_id     is not null
                     and pa.merchant_id     is not null
                     and pi.card_network_id is not null
                  ) oper
                , acc_macros a
            where oper.oper_id = a.object_id(+)
            order by
                  merchant_id
                , batch_number
                , card_type_id
                , oper_type
                , card_number
           );
    --if no data
    if l_detail.getclobval() = '<transactions></transactions>' then
        select xmlelement("transactions"
             , xmlagg(
                   xmlelement("transaction"
                     , xmlelement("currency"               , null)
                     , xmlelement("agent_code"             , null)
                     , xmlelement("agent_name"             , null)
                     , xmlelement("device_number"          , null)
                     , xmlelement("branch_name"            , null)
                     , xmlelement("terminal_type"          , null)
                     , xmlelement("tran_type"              , null)
                     , xmlelement("merchant_ID"            , null)
                     , xmlelement("terminal_ID"            , null)
                     , xmlelement("oper_quantity"          , null)
                     , xmlelement("sum_oper_amount"        , null)
                     , xmlelement("sum_fee_amount"         , null)
                     , xmlelement("trace_number"           , null)
                     , xmlelement("tran_date"              , null)
                     , xmlelement("settle_date"            , null)
                     , xmlelement("merchant_name"          , null)
                     , xmlelement("outlet_nnumber"         , null)
                     , xmlelement("oper_amount"            , null)
                     , xmlelement("discount_amount"        , null)
                     , xmlelement("net_amount"             , null)
                     , xmlelement("card_number"            , null)
                     , xmlelement("merchant_account"       , null)
                     , xmlelement("card_type"              , null)
                     , xmlelement("reversal"               , null)
                     , xmlelement("referral_number"        , null)
                     , xmlelement("batch_number"           , null)
                     , xmlelement("card_expir_date"        , null)
                     , xmlelement("pos_entry_mode"         , null)
                     , xmlelement("auth_code"              , null)
                     , xmlelement("mcc"                    , null)
                     , xmlelement("invoice_number"         , null)
                     , xmlelement("arn"                    , null)
                   )
               )
           )
        into l_detail
        from dual ;
    end if;

    select xmlelement (
               "report"
             , l_header
             , l_detail
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();
    trc_log_pkg.debug ( i_text => 'acq_api_report_pkg.pos_epos_settlement_trans - end' );

exception
when others then
    if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;
    raise;
end pos_epos_settlement_trans;

procedure pos_epos_settlement_stat (
    o_xml               out clob
  , i_lang           in     com_api_type_pkg.t_dict_value
  , i_start_date     in     date
  , i_end_date       in     date
  , i_inst_id        in     com_api_type_pkg.t_inst_id  default null
) is
    l_start_date            date;
    l_end_date              date;
    l_lang                  com_api_type_pkg.t_dict_value;

    l_header                xmltype;
    l_detail                xmltype;
    l_footer                xmltype;
    l_result                xmltype;

    l_bank_name             com_api_type_pkg.t_name;
    l_bank_address          com_api_type_pkg.t_name;
    l_contact_data          com_api_type_pkg.t_name;
begin

    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date   := nvl(trunc(i_end_date), l_start_date) + 1 - 1/86400;
    l_lang       := coalesce(i_lang, get_user_lang, com_api_const_pkg.LANGUAGE_ENGLISH);

    trc_log_pkg.debug (
        i_text        => 'cst_cab_api_report_pkg.pos_epos_settlement_stat [#1], [#2], [#3], [#4]'
      , i_env_param1  => l_lang
      , i_env_param2  => com_api_type_pkg.convert_to_char(l_start_date)
      , i_env_param3  => com_api_type_pkg.convert_to_char(l_end_date)
      , i_env_param4  => i_inst_id
    );
    -- header
    select xmlelement(
               "header"
             , xmlelement("p_date_start", to_char(l_start_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT))
             , xmlelement("p_date_end"  , to_char(l_end_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT))
             , xmlelement("p_inst_id"   , decode(
                                              i_inst_id
                                            , null
                                            , '0'
                                            , i_inst_id || ' - ' || get_text('OST_INSTITUTION', 'NAME', i_inst_id, l_lang)
                                          )
                         )
           )
      into l_header
      from dual;
    -- details
    select xmlelement("transactions"
             , xmlagg(
                   xmlelement("transaction"
                     , xmlelement("currency"                 , currency)
                     , xmlelement("merchant_number"          , merchant_number)
                     , xmlelement("merchant_name"            , merchant_name)
                     , xmlelement("terminal_number"          , terminal_number)
                     , xmlelement("batch_number"             , batch_number)
                     , xmlelement("trans_date"               , trans_date)
                     , xmlelement("network"                  , network)
                     , xmlelement("cubc_card_amount"         , cubc_card_amount)
                     , xmlelement("local_card_amount"        , local_card_amount)
                     , xmlelement("foreign_card_amount"      , foreign_card_amount)
                     , xmlelement("cubc_card_discount"       , cubc_card_discount)
                     , xmlelement("local_card_discount"      , local_card_discount)
                     , xmlelement("foreign_card_discount"    , foreign_card_discount)
                     , xmlelement("net_amount"               , net_amount)
                   )
               )
           )
      into
           l_detail
      from (
           with opr as(
                select o.oper_currency
                     , b.header_merchant_id    merchant_number
                     , b.header_terminal_id    terminal_number
                     , o.merchant_name
                     , b.header_batch_reference batch_number
                     , to_char(o.oper_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT)  trans_date
                     , bin.module_code         network
                     , decode(o.sttl_type, opr_api_const_pkg.SETTLEMENT_USONUS, o.oper_amount * decode(o.is_reversal,1,-1,1), 0) cubc_card_amount
                     , case
                           when o.sttl_type != opr_api_const_pkg.SETTLEMENT_USONUS and bin.country = cst_cab_api_const_pkg.COUNTRY_CAMBODIA
                           then o.oper_amount * decode(o.is_reversal,1,-1,1)
                           else 0
                       end local_card_amount
                     , case
                           when o.sttl_type != opr_api_const_pkg.SETTLEMENT_USONUS and bin.country != cst_cab_api_const_pkg.COUNTRY_CAMBODIA
                           then o.oper_amount * decode(o.is_reversal,1,-1,1)
                           else 0
                       end foreign_card_amount
                     , o.oper_request_amount * decode(o.is_reversal,1,-1,1)   as req_amount
                     , o.oper_surcharge_amount * decode(o.is_reversal,1,-1,1) as fee_amount
                     , com_api_currency_pkg.get_currency_name(i_curr_code => o.oper_currency) as currency
                  from opr_operation    o
                     , opr_participant  p
                     , aut_auth         a
                     , pos_batch_block  b
                     , pos_batch_detail d
                     , net_bin_range    bin
                 where o.oper_date between l_start_date and l_end_date
                   and o.sttl_type in ( opr_api_const_pkg.SETTLEMENT_THEMONUS --'STTT0200'
                                      , opr_api_const_pkg.SETTLEMENT_USONUS --'STTT0010'
                                      --, 'STTT5001' --CARDLESS-ON-US
                                      )
                   and ( i_inst_id     is null or d.acq_inst_id = i_inst_id )
                   and o.id                    = p.oper_id
                   and p.participant_type      = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
                   and p.card_network_id       = bin.card_network_id
                   and o.id                    = a.id
                   and a.external_orig_id      = d.retrieval_reference_number
                   and d.batch_block_id        = b.id
                   and d.card_number between   bin.pan_low and bin.pan_high
                ),
                opr_1 as(
                select currency
                     , oper_currency
                     , merchant_number
                     , merchant_name
                     , terminal_number
                     , batch_number
                     , trans_date
                     , network
                     , cubc_card_amount
                     , local_card_amount
                     , foreign_card_amount
                     , greatest(0, cubc_card_amount - req_amount) as cubc_card_discount
                     , greatest(0, local_card_amount - req_amount) as local_card_discount
                     , greatest(0, foreign_card_amount - req_amount) as foreign_card_discount
                     , req_amount net_amount
                  from opr
                )
                select * from (
                    select 0 as sort_number
                         , currency
                         , merchant_number
                         , merchant_name
                         , terminal_number
                         , batch_number
                         , trans_date
                         , network
                         , cst_cab_com_pkg.format_amount(i_amount => cubc_card_amount, i_curr_code => oper_currency) cubc_card_amount
                         , cst_cab_com_pkg.format_amount(i_amount => local_card_amount, i_curr_code => oper_currency) local_card_amount
                         , cst_cab_com_pkg.format_amount(i_amount => foreign_card_amount, i_curr_code => oper_currency) foreign_card_amount
                         , cst_cab_com_pkg.format_amount(i_amount => cubc_card_discount, i_curr_code => oper_currency) cubc_card_discount
                         , cst_cab_com_pkg.format_amount(i_amount => local_card_discount, i_curr_code => oper_currency) local_card_discount
                         , cst_cab_com_pkg.format_amount(i_amount => foreign_card_discount, i_curr_code => oper_currency) foreign_card_discount
                         , cst_cab_com_pkg.format_amount(i_amount => net_amount, i_curr_code => oper_currency) net_amount
                      from opr_1
                    union all
                    select 1 as sort_number
                         , null
                         , merchant_number
                         , null
                         , null
                         , null
                         , null
                         , null
                         , cst_cab_com_pkg.format_amount(i_amount => sum(cubc_card_amount), i_curr_code => oper_currency) cubc_card_amount
                         , cst_cab_com_pkg.format_amount(i_amount => sum(local_card_amount), i_curr_code => oper_currency) local_card_amount
                         , cst_cab_com_pkg.format_amount(i_amount => sum(foreign_card_amount), i_curr_code => oper_currency) foreign_card_amount
                         , cst_cab_com_pkg.format_amount(i_amount => sum(cubc_card_discount), i_curr_code => oper_currency) cubc_card_discount
                         , cst_cab_com_pkg.format_amount(i_amount => sum(local_card_discount), i_curr_code => oper_currency) local_card_discount
                         , cst_cab_com_pkg.format_amount(i_amount => sum(foreign_card_discount), i_curr_code => oper_currency) foreign_card_discount
                         , cst_cab_com_pkg.format_amount(i_amount => sum(net_amount), i_curr_code => oper_currency) net_amount
                      from opr_1
                     group by merchant_number, oper_currency, 1
                    )
                order by merchant_number, sort_number, trans_date
    );
    begin
        select get_text('OST_INSTITUTION', 'NAME', i_inst_id, l_lang)
          into l_bank_name
          from dual;
    exception
        when no_data_found then
            null;
    end;
    begin
        select com_api_address_pkg.get_address_string(o.address_id, l_lang) address
          into l_bank_address
          from com_address_object o
         where o.entity_type  = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
           and o.object_id    = i_inst_id
           and o.address_type = 'ADTPLGLA'; --'ADTPBSNA'
    exception
        when no_data_found then
            null;
    end;
    begin
        select phone || decode(phone, null, null, ', ') || e_mail
          into l_contact_data
          from (
               select max(decode(d.commun_method, com_api_const_pkg.COMMUNICATION_METHOD_MOBILE, commun_address, null)) as phone
                    , max(decode(d.commun_method, com_api_const_pkg.COMMUNICATION_METHOD_EMAIL, commun_address, null)) as e_mail
                 from com_contact_object o
                    , com_contact_data   d
                where o.object_id    = com_ui_user_env_pkg.get_person_id
                  and o.entity_type  = com_api_const_pkg.ENTITY_TYPE_PERSON
                  and o.contact_type = com_api_const_pkg.CONTACT_TYPE_PRIMARY
                  and d.contact_id   = o.contact_id
                  and commun_method in (com_api_const_pkg.COMMUNICATION_METHOD_MOBILE, com_api_const_pkg.COMMUNICATION_METHOD_EMAIL)  -- mobile phone, e-mail
               );
    exception
        when no_data_found then
            null;
    end;
    -- footer
    select xmlelement("footer"
             , xmlelement("bank_name", l_bank_name)
             , xmlelement("bank_address", l_bank_address)
             , xmlelement("contact_data", l_contact_data)
           ) xml
      into l_footer
      from dual;

    select xmlelement ( "report"
         , l_header
         , l_detail
         , l_footer
           )
    into l_result from dual;

    o_xml := l_result.getclobval();
    trc_log_pkg.debug ( i_text => 'acq_api_report_pkg.pos_epos_settlement_stat - end' );

exception
    when others then
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
        raise;
end pos_epos_settlement_stat;

procedure late_payment_charge (
    o_xml               out clob
  , i_lang           in     com_api_type_pkg.t_dict_value
  , i_start_date     in     date
  , i_end_date       in     date
  , i_inst_id        in     com_api_type_pkg.t_inst_id  default null
) is
    l_start_date            date;
    l_end_date              date;
    l_lang                  com_api_type_pkg.t_dict_value;
    l_invoice_id            com_api_type_pkg.t_medium_id;
    l_invoice               crd_api_type_pkg.t_invoice_rec;
    l_overdue_days          pls_integer;
    l_info_is_present       com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;

    l_header                xmltype;
    l_detail                xmltype;
    l_result                xmltype;
    l_response_data         xmltype;
    l_response_data_part    xmltype;
begin

    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date   := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    l_lang       := coalesce(i_lang, get_user_lang, com_api_const_pkg.LANGUAGE_ENGLISH);

    trc_log_pkg.debug (
        i_text        => 'cst_cab_api_report_pkg.late_payment_charge [#1], [#2], [#3], [#4]'
      , i_env_param1  => l_lang
      , i_env_param2  => com_api_type_pkg.convert_to_char(l_start_date)
      , i_env_param3  => com_api_type_pkg.convert_to_char(l_end_date)
      , i_env_param4  => i_inst_id
    );

    -- header
    select xmlelement (
               "header"
             , xmlelement("date_start", to_char(l_start_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT))
             , xmlelement("date_end"  , to_char(l_end_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT))
             , xmlelement("inst_id"   , nvl(i_inst_id, '0'))
             , xmlelement("inst_name" , decode(
                                            i_inst_id
                                          , null
                                          , null
                                          , get_text('OST_INSTITUTION', 'NAME', i_inst_id, l_lang)
                                        )
                         )
             , xmlelement("report_name", 'Late payment charge')
           )
      into l_header
      from dual;

    for rc in (
        select t.oper_currency
             , t.account_number
             , t.penalty_fee
             , t.overlimit_fee
             , t.mobile_number
             , t.phone_number
             , k.card_instance_id
             , k.reg_date as card_issuance_date
             , k.cardholder_name
             , t.card_mask
             , k.status as card_status
             , com_api_dictionary_pkg.get_article_text(k.status, null) as card_status_description
             , iss_api_token_pkg.decode_card_number(t.card_number) as card_number
             , t.account_id
             , t.oper_date
             , t.split_hash
             , t.inst_id
             , cc.name as oper_currency_name
             , cc.exponent as oper_currency_exponent
          from (
                select oo.oper_amount
                     , oo.oper_currency
                     , oo.oper_reason
                     , oo.oper_date
                     , op.account_id
                     , aa.account_number
                     , aa.split_hash
                     , aa.inst_id
                     , ic.reg_date
                     , ic.card_mask
                     , ic.id as card_id
                     , iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as card_number
                     , cco.contact_id
                     , com_api_contact_pkg.get_contact_string(
                           i_contact_id        => cco.contact_id
                         , i_commun_method     => com_api_const_pkg.COMMUNICATION_METHOD_MOBILE -- 'CMNM0001'
                         , i_start_date        => null -- contact data should started not later than this date, null means sysdate
                       ) as mobile_number
                     , com_api_contact_pkg.get_contact_string(
                           i_contact_id        => cco.contact_id
                         , i_commun_method     => com_api_const_pkg.COMMUNICATION_METHOD_PHONE -- 'CMNM0012'
                         , i_start_date        => null -- contact data should started not later than this date, null means sysdate
                       ) as phone_number
                     , decode(oo.oper_reason, 'FETP1003', oo.oper_amount, 0) * decode(oo.is_reversal, 1, -1, 1) as penalty_fee
                     , decode(oo.oper_reason, 'FETP1014', oo.oper_amount, 0) * decode(oo.is_reversal, 1, -1, 1) as overlimit_fee
                  from opr_operation oo
                     , opr_participant op
                     , com_contact_object cco
                     , acc_account aa
                     , acc_account_object ao
                     , iss_card ic
                     , iss_card_number cn
                 where oo.id = op.oper_id
                   and ic.id = cn.card_id
                   and op.account_id = aa.id
                   and ao.account_id = op.account_id
                   and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD-- 'ENTTCARD'
                   and ao.object_id = ic.id
                   and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
                   and oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE --'OPTP0119'
                   and oo.oper_reason in ('FETP1003', 'FETP1014')
                   and cco.entity_type(+) = com_api_const_pkg.ENTITY_TYPE_CUSTOMER -- 'ENTTCUST'
                   and cco.object_id(+) = op.customer_id
                   and cco.contact_type(+) = com_api_const_pkg.CONTACT_TYPE_PRIMARY -- 'CNTTPRMC'
                   and aa.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT -- 'ACTP0130'
                   and oo.id between com_api_id_pkg.get_from_id(l_start_date)
                                 and com_api_id_pkg.get_till_id(l_end_date)
                   and aa.inst_id = nvl(i_inst_id, aa.inst_id)
               ) t
               , (select id as card_instance_id
                       , card_id
                       , reg_date
                       , cardholder_name
                       , status
                       , row_number() over(partition by card_id order by seq_number desc, reg_date desc) as rn
                    from iss_card_instance
                   where state <> iss_api_const_pkg.CARD_STATE_CLOSED --'CSTE0300'
                ) k
               , com_currency cc
           where k.card_id = t.card_id
             and t.oper_currency = cc.code(+)
             and k.rn = 1
    ) loop
        l_invoice_id :=
            crd_invoice_pkg.get_last_invoice_id(
                i_account_id    => rc.account_id
              , i_eff_date      => rc.oper_date
              , i_split_hash    => rc.split_hash
            );

        if l_invoice_id is null then
            l_overdue_days := 0;
        else
            l_invoice :=
                crd_invoice_pkg.get_invoice(
                    i_invoice_id  => l_invoice_id
                  , i_mask_error  => com_api_const_pkg.TRUE
                );
            l_overdue_days := l_invoice.aging_period * 30;
        end if;

        select xmlelement("record"
                 , xmlconcat(
                       xmlelement("card_number", rc.card_number)
                     , xmlelement("card_mask", rc.card_mask)
                     , xmlelement("account_number", rc.account_number)
                     , xmlelement("cardholder_name", rc.cardholder_name)
                     , xmlelement("issuance_date", rc.card_issuance_date)
                     , xmlelement("issuance_date_char", to_char(rc.card_issuance_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT))
                     , xmlelement("currency_iso_code", rc.oper_currency)
                     , xmlelement("currency_name", rc.oper_currency_name)
                     , xmlelement("currency_exponent", rc.oper_currency_exponent)
                     , xmlelement("penalty_fee", rc.penalty_fee)
                     , xmlelement("penalty_fee_formatted"
                                    , cst_cab_com_pkg.format_amount(
                                          i_amount        => rc.penalty_fee
                                        , i_curr_code     => rc.oper_currency
                                      )
                                 )
                     , xmlelement("overlimit_fee", rc.penalty_fee)
                     , xmlelement("overlimit_fee_formatted"
                                    , cst_cab_com_pkg.format_amount(
                                          i_amount        => rc.penalty_fee
                                        , i_curr_code     => rc.oper_currency
                                      )
                                 )
                     , xmlelement("overdue_days", l_overdue_days)
                     , xmlelement("card_status", rc.card_status)
                     , xmlelement("card_status_description", rc.card_status_description)
                     , xmlelement("collateral", 0)
                     , xmlelement("collateral_formatted", null)
                     , xmlelement("mobile_phone_number", rc.mobile_number)
                     , xmlelement("phone_number", rc.phone_number)
                   )
               )
          into l_response_data_part
          from dual;

        l_info_is_present := com_api_type_pkg.TRUE;

        select xmlconcat(
                   l_response_data
                 , l_response_data_part
               )
          into l_response_data
          from dual;

    end loop;

    if l_info_is_present = com_api_type_pkg.FALSE then
        select xmlelement("record"
                 , xmlconcat(
                       xmlelement("card_number", null)
                     , xmlelement("card_mask", null)
                     , xmlelement("account_number", null)
                     , xmlelement("cardholder_name", null)
                     , xmlelement("issuance_date", null)
                     , xmlelement("issuance_date_char", null)
                     , xmlelement("currency_iso_code", null)
                     , xmlelement("currency_name", null)
                     , xmlelement("currency_exponent", null)
                     , xmlelement("penalty_fee", null)
                     , xmlelement("penalty_fee_formatted", null)
                     , xmlelement("overlimit_fee", null)
                     , xmlelement("overlimit_fee_formatted", null)
                     , xmlelement("overdue_days", null)
                     , xmlelement("card_status", null)
                     , xmlelement("card_status_description", null)
                     , xmlelement("collateral", null)
                     , xmlelement("collateral_formatted", null)
                     , xmlelement("mobile_phone_number", null)
                     , xmlelement("phone_number", null)
                   )
               )
          into l_response_data
          from dual;
    end if;

    select xmlelement ( "report"
             , l_header
             , xmlelement("detail", l_response_data)
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'cst_cab_api_report_pkg.late_payment_charge - end' );

exception
    when others then
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
        raise;
end late_payment_charge;

procedure credit_card_bill_repayment (
    o_xml               out clob
  , i_lang           in     com_api_type_pkg.t_dict_value
  , i_start_date     in     date
  , i_end_date       in     date
  , i_inst_id        in     com_api_type_pkg.t_inst_id  default null
) is
    l_start_date            date;
    l_end_date              date;
    l_lang                  com_api_type_pkg.t_dict_value;

    l_header                xmltype;
    l_detail                xmltype;
    l_result                xmltype;

begin

    trc_log_pkg.debug (
        i_text        => 'cst_cab_api_report_pkg.credit_card_bill_repayment [#1], [#2], [#3], [#4]'
      , i_env_param1  => i_lang
      , i_env_param2  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
      , i_env_param3  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - 1/86400)
      , i_env_param4  => i_inst_id
    );

    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date   := nvl(trunc(i_end_date), l_start_date) + 1 - 1/86400;
    l_lang       := nvl(i_lang, get_user_lang);

    -- header
    select xmlelement (
               "header"
             , xmlelement("date_start", to_char(l_start_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT))
             , xmlelement("date_end",   to_char(l_end_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT))
             , xmlelement("inst_id",    nvl(i_inst_id, '0'))
             , xmlelement("inst_name",  decode(
                                            i_inst_id
                                          , null
                                          , null
                                          , get_text('OST_INSTITUTION', 'NAME', i_inst_id, l_lang)
                                        )
                         )
             , xmlelement("report_name", 'Credit card bill repayment')
           )
      into l_header
      from dual;

    select xmlelement("table"
             , xmlagg(
                   xmlelement("record"
                     , xmlelement("oper_date_yddd", t.oper_date_yddd)
                     , xmlelement("oper_date", t.oper_date)
                     , xmlelement("card_number", iss_api_token_pkg.decode_card_number(icn.card_number))
                     , xmlelement("card_type", get_text ('NET_CARD_TYPE', 'NAME', ic.card_type_id, l_lang))
                     , xmlelement("cardholder_name", ici.cardholder_name)
                     , xmlelement("account_number", t.account_number)
                     , xmlelement("payment_amount", t.account_amount)
                     , xmlelement("payment_currency", t.account_currency)
                     , xmlelement("payment_currency_name", cc.name)
                     , xmlelement("payment_currency_exponent", cc.exponent)
                     , xmlelement("payment_channel", t.payment_channel)
                     , xmlelement("branch_id", t.merchant_number)
                     , xmlelement("user_id", t.terminal_number)
                   )
               )
           )
      into l_detail
      from (
            select oo.id as oper_id
                 , oo.oper_date
                 , to_char(oo.oper_date, 'YDDD') as oper_date_yddd
                 , oo.oper_type || ' - ' ||
                   case when oo.merchant_name is not null then oo.merchant_name
                        else 'Other'
                   end as payment_channel
                 , coalesce(cp.card_id, cst_cab_com_pkg.get_main_card_id(
                                            i_account_id => op.account_id
                                          , i_split_hash => op.split_hash
                                        )
                           ) as card_id
                 , iss_api_card_instance_pkg.get_card_instance_id(
                       i_card_id           => coalesce(cp.card_id, cst_cab_com_pkg.get_main_card_id(
                                                                       i_account_id => op.account_id
                                                                     , i_split_hash => op.split_hash
                                                                   )
                                                      )
                     , i_seq_number        => op.card_seq_number
                     , i_expir_date        => null
                   ) as card_instance_id
                 , oo.merchant_name
                 , oo.terminal_type
                 , oo.originator_refnum
                 , oo.oper_currency
                 , com_api_currency_pkg.get_amount_str(
                       i_amount            => oo.oper_amount
                     , i_curr_code         => oo.oper_currency
                     , i_mask_curr_code    => com_api_type_pkg.TRUE
                     , i_mask_error        => com_api_type_pkg.TRUE
                   ) as oper_amount
                 , nvl(cp.currency, oo.oper_currency) as account_currency
                 , com_api_currency_pkg.get_amount_str(
                       i_amount            => nvl(cp.amount, oo.oper_amount)
                     , i_curr_code         => nvl(cp.currency, oo.oper_currency)
                     , i_mask_curr_code    => com_api_type_pkg.TRUE
                     , i_mask_error        => com_api_type_pkg.TRUE
                   ) as account_amount
                 , aa.account_number
                 , oo.merchant_number
                 , oo.terminal_number
              from crd_payment cp
                 , opr_operation oo
                 , opr_participant op
                 , acc_account aa
             where oo.id = op.oper_id
               and op.account_id = aa.id
               and aa.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT          -- 'ACTP0130'
               and oo.oper_type in (opr_api_const_pkg.OPERATION_TYPE_REFUND         -- 'OPTP0020'
                                  , opr_api_const_pkg.OPERATION_TYPE_FUNDS_TRANSFER -- 'OPTP0040'
                                  , cst_cab_api_const_pkg.OPER_TYPE_PAYMENT_CBS_DD  -- 'OPTP7011'
                                  , cst_cab_api_const_pkg.OPER_TYPE_PAYMENT_MANUAL  -- 'OPTP7033'
                                  )
               and cp.oper_id(+) = oo.id
               and op.participant_type in (com_api_const_pkg.PARTICIPANT_ISSUER
                                         , com_api_const_pkg.PARTICIPANT_DEST
                                         )
               and oo.id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
           ) t
         , iss_card ic
         , iss_card_number icn
         , iss_card_instance ici
         , com_currency cc
     where ic.id = t.card_id
       and ic.id = icn.card_id
       and t.card_instance_id = ici.id
       and t.account_currency = cc.code(+);

    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                 , xmlagg(
                       xmlelement("record"
                         , xmlelement("oper_date_yddd", null)
                         , xmlelement("oper_date", null)
                         , xmlelement("card_number", null)
                         , xmlelement("card_type", null)
                         , xmlelement("cardholder_name", null)
                         , xmlelement("account_number", null)
                         , xmlelement("payment_amount", null)
                         , xmlelement("payment_currency", null)
                         , xmlelement("payment_currency_name", null)
                         , xmlelement("payment_currency_exponent", null)
                         , xmlelement("payment_channel", null)
                         , xmlelement("branch_id", null)
                         , xmlelement("user_id", null)
                       )
                   )
               )
          into l_detail
          from dual;
    end if;

    select xmlelement ( "report"
             , l_header
             , xmlelement("detail", l_detail)
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (i_text => 'cst_cab_api_report_pkg.credit_card_bill_repayment - end');

exception
    when others then
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
        raise;
end credit_card_bill_repayment;

procedure loyalty_daily_redemption (
    o_xml               out clob
  , i_lang           in     com_api_type_pkg.t_dict_value
  , i_eff_date       in     date                         default null
  , i_service_id     in     com_api_type_pkg.t_short_id  default null
  , i_inst_id        in     com_api_type_pkg.t_inst_id   default null
) as
    l_eff_date              date;
    l_header                xmltype;
    l_detail                xmltype;
    l_result                xmltype;
    l_lang                  com_api_type_pkg.t_dict_value;
begin

    l_lang      := coalesce(i_lang, get_user_lang, com_api_const_pkg.LANGUAGE_ENGLISH);
    l_eff_date  := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);

    trc_log_pkg.debug (
        i_text        => 'cst_cab_api_report_pkg.loyalty_daily_redemption [#1], [#2], [#3], [#4]'
      , i_env_param1  => l_lang
      , i_env_param2  => com_api_type_pkg.convert_to_char(l_eff_date)
      , i_env_param3  => i_service_id
      , i_env_param4  => i_inst_id
    );

    -- header
    select xmlelement (
               "header"
             , xmlelement("date_start"  , to_char(l_eff_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT))
             , xmlelement("date_end"    , to_char(l_eff_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT))
             , xmlelement("inst_id"     , nvl(i_inst_id, '0'))
             , xmlelement("inst_name"   , decode(
                                              i_inst_id
                                            , null
                                            , null
                                            , get_text('OST_INSTITUTION', 'NAME', i_inst_id, l_lang)
                                          )
                         )
             , xmlelement("report_name", 'Daily Redeemed point')
           )
      into l_header
      from dual;
    -- details
    select xmlelement("transactions"
             , xmlagg(
                   xmlelement("transaction"
                     , xmlelement("card_number"         , card_number)
                     , xmlelement("cardholder_name"     , cardholder_name)
                     , xmlelement("account_number"      , account_number)
                     , xmlelement("trans_date"          , posting_date)
                     , xmlelement("redeem_point"        , redeem_point)
                     , xmlelement("redeem_amount"       , redeem_amount)
                     , xmlelement("total_point"         , total_point)
                     , xmlelement("total_spent_point"   , total_spent_point)
                     , xmlelement("remain_point"        , remain_point)
                     , xmlelement("point_type"          , 'Loyalty Point')
                     , xmlelement("redemption_type"     , redemption_type)
                   )
               )
           )
      into
           l_detail
      from (
            with lty as (
                select account_id
                     , sum(amount) as total_point
                     , sum(nvl(spent_amount, 0)) as total_spent_point
                  from lty_bonus
                 where inst_id        = nvl(i_inst_id, inst_id)
                   and service_id     = nvl(i_service_id, service_id)
                   and l_eff_date     between start_date and expire_date
                 group by account_id
                )
                select c.card_number
                     , i.cardholder_name
                     , a.account_number
                     , to_char(m1.posting_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT) as posting_date
                     , m1.amount as redeem_point
                     , m2.amount as redeem_amount
                     , b.total_point
                     , b.total_spent_point
                     , (b.total_point -  b.total_spent_point) remain_point
                     , decode(o1.oper_type, cst_cab_api_const_pkg.LOYALTY_REDEMPTION_CASHBACK, 'CASHBACK'
                         , cst_cab_api_const_pkg.LOYALTY_REDEMPTION_COUPON, 'COUPON', 'UNKNOWN') redemption_type
                  from lty b
                     , acc_macros m1
                     , (select m.object_id, m.amount
                          from acc_macros m
                         where m.macros_type_id     = cst_cab_api_const_pkg.MACROS_CREDIT_OPERATION
                           and m.entity_type        = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                        ) m2
                     , acc_account_object o
                     , acc_account a
                     , iss_card_number c
                     , iss_card_instance i
                     , opr_operation o1
                 where b.account_id         = m1.account_id
                   and m1.currency          = cst_cab_api_const_pkg.LOYALTY_CURR
                   and m1.object_id         = m2.object_id(+)
                   and m1.macros_type_id    = cst_cab_api_const_pkg.MACROS_SPENT_LOYALTY_POINT
                   and m1.account_id        = o.account_id
                   and m1.account_id        = a.id
                   and o.entity_type        = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and o.object_id          = c.card_id
                   and c.card_id            = i.card_id
                   and o1.id                = m1.object_id
                   and trunc(l_eff_date)    = trunc(m1.posting_date)
                 order by c.card_number
            );

    if l_detail.getclobval() = '<transactions></transactions>' then
        select xmlelement("transactions"
                 , xmlagg(
                       xmlelement("transaction"
                         , xmlelement("card_number"         , null)
                         , xmlelement("cardholder_name"     , null)
                         , xmlelement("account_number"      , null)
                         , xmlelement("trans_date"          , null)
                         , xmlelement("redeem_point"        , null)
                         , xmlelement("redeem_amount"       , null)
                         , xmlelement("total_point"         , null)
                         , xmlelement("total_spent_point"   , null)
                         , xmlelement("remain_point"        , null)
                         , xmlelement("point_type"          , null)
                         , xmlelement("redemption_type"     , null)
                       )
                   )
               )
          into l_detail
          from dual;
    end if;

    select xmlelement ( "report"
             , l_header
             , xmlelement("detail", l_detail)
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (i_text => 'cst_cab_api_report_pkg.loyalty_daily_redemption - end');

exception
    when others then
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
        raise;
end loyalty_daily_redemption;

function get_latest_redemption_type(
    i_account_id        in      com_api_type_pkg.t_account_id
)return com_api_type_pkg.t_name
as
    l_redemption_type       com_api_type_pkg.t_name;
begin
    select decode(oper_type, cst_cab_api_const_pkg.LOYALTY_REDEMPTION_CASHBACK, 'CASHBACK'
             , cst_cab_api_const_pkg.LOYALTY_REDEMPTION_COUPON, 'COUPON', 'UNKNOWN')
      into l_redemption_type
      from opr_operation
     where id = (
           select max(object_id)
             from acc_macros
            where account_id      = i_account_id
              and macros_type_id  = cst_cab_api_const_pkg.MACROS_SPENT_LOYALTY_POINT
              and entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           );
    return l_redemption_type;
exception
    when no_data_found then
        return null;
end;

procedure loyalty_monthly_redemption (
    o_xml               out clob
  , i_lang           in     com_api_type_pkg.t_dict_value
  , i_eff_date       in     date                         default null
  , i_service_id     in     com_api_type_pkg.t_short_id  default null
  , i_inst_id        in     com_api_type_pkg.t_inst_id   default null
) as
    l_start_date            date;
    l_end_date              date;
    l_eff_date              date;
    l_header                xmltype;
    l_detail                xmltype;
    l_result                xmltype;
    l_lang                  com_api_type_pkg.t_dict_value;
begin

    l_lang          := coalesce(i_lang, get_user_lang, com_api_const_pkg.LANGUAGE_ENGLISH);
    l_eff_date      := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);
    l_start_date    := trunc(l_eff_date, 'MM');
    l_end_date      := add_months(l_start_date, 1) - com_api_const_pkg.ONE_SECOND;

    trc_log_pkg.debug (
        i_text        => 'cst_cab_api_report_pkg.loyalty_monthly_redemption [#1], [#2], [#3], [#4]'
      , i_env_param1  => l_lang
      , i_env_param2  => com_api_type_pkg.convert_to_char(l_eff_date)
      , i_env_param3  => i_service_id
      , i_env_param4  => i_inst_id
    );

    -- header
    select xmlelement (
               "header"
             , xmlelement("date_start", to_char(l_start_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT))
             , xmlelement("date_end",   to_char(l_end_date, cst_cab_api_const_pkg.RPT_DATE_FORMAT))
             , xmlelement("inst_id",    nvl(i_inst_id, '0'))
             , xmlelement("inst_name",  decode(
                                            i_inst_id
                                          , null
                                          , null
                                          , get_text('OST_INSTITUTION', 'NAME', i_inst_id, l_lang)
                                        )
                         )
             , xmlelement("report_name", 'Monthly Loyalty point')
           )
      into l_header
      from dual;
    -- details
    select xmlelement("transactions"
             , xmlagg(
                   xmlelement("transaction"
                     , xmlelement("card_number"         , card_number)
                     , xmlelement("cardholder_name"     , cardholder_name)
                     , xmlelement("account_number"      , account_number)
                     , xmlelement("total_point"         , total_point)
                     , xmlelement("total_spent_point"   , total_spent_point)
                     , xmlelement("remain_point"        , remain_point)
                     , xmlelement("point_type"          , 'Loyalty Point')
                     , xmlelement("redemption_type"     , redemption_type)
                   )
               )
           )
      into l_detail
      from (
            with lty as (
                select account_id
                     , sum(amount) as total_point
                     , sum(nvl(spent_amount, 0)) as total_spent_point
                  from lty_bonus
                 where inst_id        = nvl(i_inst_id, inst_id)
                   and service_id     = nvl(i_service_id, service_id)
                   and l_eff_date     between start_date and expire_date
                 group by account_id
                )
                select c.card_number
                     , i.cardholder_name
                     , a.account_number
                     , b.total_point
                     , b.total_spent_point
                     , (b.total_point - b.total_spent_point) remain_point
                     , get_latest_redemption_type(
                           i_account_id     => b.account_id
                       ) redemption_type
                  from lty b
                     , acc_account a
                     , acc_account_object o1
                     , acc_account_object o2
                     , iss_card_number c
                     , iss_card_instance i
                 where b.account_id         = o1.account_id
                   and o1.object_id         = o2.object_id
                   and o1.entity_type       = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and o2.entity_type       = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and o2.account_id        = a.id
                   and a.account_type       = cst_cab_api_const_pkg.ACCT_TYPE_LOYALTY
                   and o1.object_id         = c.card_id
                   and c.card_id            = i.card_id
                 order by c.card_number
            );

    if l_detail.getclobval() = '<transactions></transactions>' then
        select xmlelement("transactions"
                 , xmlagg(
                       xmlelement("transaction"
                     , xmlelement("card_number"         , null)
                     , xmlelement("cardholder_name"     , null)
                     , xmlelement("account_number"      , null)
                     , xmlelement("total_point"         , null)
                     , xmlelement("total_spent_point"   , null)
                     , xmlelement("remain_point"        , null)
                     , xmlelement("point_type"          , null)
                     , xmlelement("redemption_type"     , null)
                       )
                   )
               )
          into l_detail
          from dual;
    end if;

    select xmlelement ( "report"
             , l_header
             , xmlelement("detail", l_detail)
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (i_text => 'cst_cab_api_report_pkg.loyalty_monthly_redemption - end');

exception
    when others then
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
        raise;
end loyalty_monthly_redemption;

procedure credit_interest_charged(
    o_xml                   out clob
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_start_date        in      date                            default null
  , i_end_date          in      date                            default null
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
)
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.credit_interest_charged: ';
    l_header                    xmltype;
    l_detail                    xmltype;
    l_result                    xmltype;
    l_start_date                date;
    l_end_date                  date;
    l_lang                      com_api_type_pkg.t_dict_value;

begin
    trc_log_pkg.debug (
        i_text          => LOG_PREFIX || 'Begin with input params [#1], [#2], [#3], [#4]'
      , i_env_param1    => i_inst_id
      , i_env_param2    => i_start_date
      , i_env_param3    => i_end_date
      , i_env_param4    => i_lang
    );

    l_start_date    := nvl(i_start_date, trunc(get_sysdate, 'MM'));
    l_end_date      := nvl(i_end_date, get_sysdate);
    l_lang          := nvl(i_lang, get_user_lang);

    -- header
    select xmlelement(
               "header"
             , xmlelement("p_institution", get_text('OST_INSTITUTION', 'NAME', i_inst_id, l_lang))
             , xmlelement("p_report_name", 'Credit Card Interest Charge')
             , xmlelement("p_start_date", to_char(l_start_date, 'dd/mm/yyyy'))
             , xmlelement("p_end_date", to_char(l_end_date, 'dd/mm/yyyy'))
           )
      into l_header
      from dual;

    begin
    select xmlelement(
               "details"
             , xmlagg(
                   xmlelement(
                       "detail"
                     , xmlelement("card_number"     , r.card_number)
                     , xmlelement("account_number"  , r.account_number)
                     , xmlelement("cardholder_name" , r.cardholder_name)
                     , xmlelement("card_iss_date"   , r.reg_date)
                     , xmlelement("interest_pos"    , r.intr_pos)
                     , xmlelement("interest_cash"   , r.intr_cash)
                     , xmlelement("interest_dpp"    , r.intr_dpp)
                     , xmlelement("interest_exlimit", r.intr_ovlimit)
                     , xmlelement("overdue_days"    , r.overdue_days)
                     , xmlelement("card_status"     , r.acc_status)
                     , xmlelement("collateral_amt"  , r.collateral_amt)
                     , xmlelement("home_phone"      , r.home_phone)
                     , xmlelement("mobile_phone"    , r.mobile_phone)
                   )
               )
            )
      into l_detail
      from (select cad.card_number
                 , cad.account_number
                 , cad.cardholder_name
                 , to_char(cad.reg_date, 'dd/mm/yyyy') as reg_date
                 , itr.intr_pos
                 , itr.intr_cash
                 , itr.intr_dpp
                 , itr.intr_ovlimit
                 , cst_cab_com_pkg.get_overdue_days(cad.account_id) as overdue_days
                 , cad.acc_status || '-' || com_api_dictionary_pkg.get_article_text(cad.acc_status) as acc_status
                 , (select d.field_value
                      from com_flexible_field f
                         , com_flexible_data d
                     where d.field_id = f.id
                       and f.name = 'CST_CAB_CARD_COLLATERAL'
                       and f.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
                       and d.object_id = cad.card_id
                    ) as collateral_amt
                 , (select ccd.commun_address
                      from com_contact_data ccd
                         , com_contact_object cco
                     where ccd.contact_id = cco.contact_id
                       and ccd.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_PHONE     --'CMNM0012'
                       and cco.contact_type = com_api_const_pkg.CONTACT_TYPE_PRIMARY            --'CNTTPRMC'
                       and cco.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER             --'ENTTCUST'
                       and cco.object_id = cad.customer_id
                       and rownum = 1
                    ) as home_phone
                 , (select ccd.commun_address
                      from com_contact_data ccd
                         , com_contact_object cco
                     where ccd.contact_id = cco.contact_id
                       and ccd.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE    --'CMNM0001'
                       and cco.contact_type = com_api_const_pkg.CONTACT_TYPE_PRIMARY            --'CNTTPRMC'
                       and cco.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER             --'ENTTCUST'
                       and cco.object_id = cad.customer_id
                       and rownum = 1
                    ) as mobile_phone
              from (select sum(intr_pos) as intr_pos
                         , sum(intr_cash) as intr_cash
                         , sum(intr_ovlimit) as intr_ovlimit
                         , sum(intr_dpp) as intr_dpp
                         , account_id
                      from (select cde.account_id
                                 , nvl(sum(cdb.amount), 0) as intr_pos
                                 , 0 as intr_cash
                                 , 0 as intr_ovlimit
                                 , 0 as intr_dpp
                              from crd_debt cde
                                 , crd_debt_balance cdb
                             where cde.id = cdb.debt_id
                               and decode(cde.status, crd_api_const_pkg.DEBT_STATUS_ACTIVE, cde.account_id, null) = cde.account_id
                               and cdb.balance_type in (crd_api_const_pkg.BALANCE_TYPE_INTEREST         --'BLTP1003'
                                                      , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST --'BLTP1005'
                                                      )
                               and cde.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE          --'OPTP0000'
                                                    , cst_cab_api_const_pkg.OPER_TYPE_MANUAL_PURCHASE   --'OPTP0003'
                                                    )
                             group by cde.account_id
                            union all
                            select cde.account_id
                                 , 0 as intr_pos
                                 , nvl(sum(cdb.amount), 0) as intr_cash
                                 , 0 as intr_ovlimit
                                 , 0 as intr_dpp
                              from crd_debt cde
                                 , crd_debt_balance cdb
                             where cde.id = cdb.debt_id
                               and decode(cde.status, crd_api_const_pkg.DEBT_STATUS_ACTIVE, cde.account_id, null) = cde.account_id
                               and cdb.balance_type in (crd_api_const_pkg.BALANCE_TYPE_INTEREST         --'BLTP1003'
                                                      , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST --'BLTP1005'
                                                      )
                               and cde.oper_type = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH   --'OPTP0001'
                             group by cde.account_id
                            union all
                            select cde.account_id
                                 , 0 as intr_pos
                                 , 0 as intr_cash
                                 , nvl(sum(cdb.amount), 0) as intr_ovlimit
                                 , 0 as intr_dpp
                              from crd_debt cde
                                 , crd_debt_balance cdb
                             where cde.id = cdb.debt_id
                               and decode(cde.status, crd_api_const_pkg.DEBT_STATUS_ACTIVE, cde.account_id, null) = cde.account_id
                               and cdb.balance_type = crd_api_const_pkg.BALANCE_TYPE_INTR_OVERLIMIT --'BLTP1008'
                             group by cde.account_id
                            union all
                            select cd.account_id
                                 , 0 as intr_pos
                                 , 0 as intr_cash
                                 , 0 as intr_ovlimit
                                 , nvl(sum(cd.debt_amount), 0) as intr_dpp 
                              from crd_debt cd
                                 , acc_macros am
                                 , dpp_instalment di
                             where am.id = cd.id
                               and am.id = di.macros_intr_id
                               and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION -- 'ENTTOPER'
                               and am.object_id = cd.oper_id
                             group by cd.account_id
                            )
                     group by account_id
                   ) itr
                 , (select n.card_number
                         , n.card_id
                         , c.customer_id
                         , a.account_number
                         , a.status as acc_status
                         , o.account_id
                         , i.cardholder_name
                         , i.iss_date
                         , i.reg_date
                         , row_number() over(partition by a.id order by c.category desc, i.reg_date) as rn
                      from iss_card c
                         , iss_card_instance i
                         , iss_card_number n
                         , acc_account_object o
                         , acc_account a
                     where c.id = i.card_id
                       and c.id = n.card_id
                       and a.id = o.account_id
                       and o.object_id = c.id
                       and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD  --'ENTTCARD'
                       and a.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT --'ACTP0130'
                       and i.state <>  iss_api_const_pkg.CARD_STATE_CLOSED -- 'CSTE0300'
                       and a.inst_id = nvl(i_inst_id, a.inst_id)
                   ) cad
             where cad.account_id = itr.account_id
               and cad.rn = 1
               and (itr.intr_pos > 0 or itr.intr_cash > 0 or itr.intr_ovlimit > 0 or itr.intr_dpp > 0)
             order by overdue_days
            )r;
    exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => LOG_PREFIX || 'NO DATA FOUND!'
            );
    end;

    select xmlelement(
               "report"
             , l_header
             , l_detail
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Finish.'
    );

exception
    when others then
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
        raise;
end credit_interest_charged;

procedure credit_aging(
    o_xml                   out clob
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_start_date        in      date                            default null
  , i_end_date          in      date                            default null
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
)
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.credit_aging: ';
    l_header                    xmltype;
    l_detail                    xmltype;
    l_result                    xmltype;
    l_start_date                date;
    l_end_date                  date;
    l_lang                      com_api_type_pkg.t_dict_value;

begin
    trc_log_pkg.debug (
        i_text          => LOG_PREFIX || 'Begin with input params [#1], [#2], [#3], [#4]'
      , i_env_param1    => i_inst_id
      , i_env_param2    => i_start_date
      , i_env_param3    => i_end_date
      , i_env_param4    => i_lang
    );

    l_start_date    := nvl(i_start_date, trunc(get_sysdate, 'MM'));
    l_end_date      := nvl(i_end_date, get_sysdate);
    l_lang          := nvl(i_lang, get_user_lang);

    -- header
    select xmlelement(
               "header"
             , xmlelement("p_institution", get_text('OST_INSTITUTION', 'NAME', i_inst_id, l_lang))
             , xmlelement("p_report_name", 'Credit Card Aging Report')
             , xmlelement("p_start_date", to_char(l_start_date, 'dd/mm/yyyy'))
             , xmlelement("p_end_date", to_char(l_end_date, 'dd/mm/yyyy'))
           )
      into l_header
      from dual;

    begin
    select xmlelement(
               "details"
             , xmlagg(
                   xmlelement(
                       "detail"
                     , xmlelement("institution"         , r.institution)
                     , xmlelement("agent"               , r.agent)
                     , xmlelement("card_number"         , r.card_number)
                     , xmlelement("card_category"       , r.card_category)
                     , xmlelement("account_number"      , r.account_number)
                     , xmlelement("cardholder_name"     , r.cardholder_name)
                     , xmlelement("card_iss_date"       , r.iss_date)
                     , xmlelement("card_expir_date"     , r.expir_date)
                     , xmlelement("overdraft_limit"     , r.overdraft_limit)
                     , xmlelement("overdraft_amount"    , r.overdraft_amount)
                     , xmlelement("credit_limit"        , r.credit_limit)
                     , xmlelement("aval_limit"          , r.aval_limit)
                     , xmlelement("hold_balance"        , r.hold_balance)
                     , xmlelement("mad_amount"          , r.mad_amount)
                     , xmlelement("outstanding_cash"    , r.outstanding_cash)
                     , xmlelement("outstanding_pos"     , r.outstanding_pos)
                     , xmlelement("outstanding_serv"    , r.outstanding_service)
                     , xmlelement("outstanding_total"   , r.outstanding_total)                     
                     , xmlelement("overdue_days"        , r.overdue_days)
                     , xmlelement("card_status"         , r.card_status)
                     , xmlelement("birthday"            , r.birthday)
                     , xmlelement("gender"              , r.gender)
                     , xmlelement("home_phone"          , r.home_phone)
                     , xmlelement("mobile_phone"        , r.mobile_phone)
                     , xmlelement("secured_amount"      , r.secured_amount)
                     , xmlelement("secured_account"     , r.secured_account)
                   )
               )
            )
      into l_detail
      from (select t.institution
                 , t.agent
                 , t.card_number
                 , t.card_category
                 , t.account_number
                 , t.cardholder_name
                 , t.iss_date
                 , t.expir_date
                 , com_api_currency_pkg.get_amount_str(
                        i_amount            => t.overdraft_limit
                      , i_curr_code         => t.currency
                      , i_mask_curr_code    => com_api_const_pkg.TRUE
                      , i_mask_error        => com_api_const_pkg.TRUE
                   ) as overdraft_limit
                 , com_api_currency_pkg.get_amount_str(
                        i_amount            => t.overdraft_amount
                      , i_curr_code         => t.currency
                      , i_mask_curr_code    => com_api_const_pkg.TRUE
                      , i_mask_error        => com_api_const_pkg.TRUE
                   ) as overdraft_amount
                 , com_api_currency_pkg.get_amount_str(
                        i_amount            => t.credit_limit
                      , i_curr_code         => t.currency
                      , i_mask_curr_code    => com_api_const_pkg.TRUE
                      , i_mask_error        => com_api_const_pkg.TRUE
                   ) as credit_limit
                 , com_api_currency_pkg.get_amount_str(
                        i_amount            => t.aval_limit
                      , i_curr_code         => t.currency
                      , i_mask_curr_code    => com_api_const_pkg.TRUE
                      , i_mask_error        => com_api_const_pkg.TRUE
                   ) as aval_limit
                 , com_api_currency_pkg.get_amount_str(
                        i_amount            => t.hold_balance
                      , i_curr_code         => t.currency
                      , i_mask_curr_code    => com_api_const_pkg.TRUE
                      , i_mask_error        => com_api_const_pkg.TRUE
                   ) as hold_balance
                 , com_api_currency_pkg.get_amount_str(
                        i_amount            => t.outstanding_cash
                      , i_curr_code         => t.currency
                      , i_mask_curr_code    => com_api_const_pkg.TRUE
                      , i_mask_error        => com_api_const_pkg.TRUE
                   ) as outstanding_cash
                 , com_api_currency_pkg.get_amount_str(
                        i_amount            => t.outstanding_pos
                      , i_curr_code         => t.currency
                      , i_mask_curr_code    => com_api_const_pkg.TRUE
                      , i_mask_error        => com_api_const_pkg.TRUE
                   ) as outstanding_pos
                 , com_api_currency_pkg.get_amount_str(
                        i_amount            => t.outstanding_service
                      , i_curr_code         => t.currency
                      , i_mask_curr_code    => com_api_const_pkg.TRUE
                      , i_mask_error        => com_api_const_pkg.TRUE
                   ) as outstanding_service
                 , com_api_currency_pkg.get_amount_str(
                        i_amount            => case when t.coll_amount > 0 
                                                    then t.coll_amount
                                                    else t.outstanding_pos
                                             + t.outstanding_cash
                                             + t.outstanding_service
                                               end
                      , i_curr_code         => t.currency
                      , i_mask_curr_code    => com_api_const_pkg.TRUE
                      , i_mask_error        => com_api_const_pkg.TRUE
                   ) as outstanding_total
                 , com_api_currency_pkg.get_amount_str(
                        i_amount            => case when t.coll_amount > 0 
                                                    then t.coll_amount
                                                    else t.mad_amount
                                               end
                      , i_curr_code         => t.currency
                      , i_mask_curr_code    => com_api_const_pkg.TRUE
                      , i_mask_error        => com_api_const_pkg.TRUE
                   ) as mad_amount
                 , t.overdue_days
                 , t.card_status
                 , t.birthday
                 , t.gender
                 , t.mobile_phone
                 , t.home_phone
                 , t.secured_amount
                 , t.secured_account  
              from (select ici.inst_id || '-' || get_text('OST_INSTITUTION', 'NAME', ici.inst_id, l_lang) as institution
                         , agt.agent_number || '-' || get_text('OST_AGENT', 'NAME', agt.id, l_lang) as agent
                         , icn.card_number
                         , com_api_dictionary_pkg.get_article_text(ica.category) as card_category
                         , aac.account_number
                         , ici.cardholder_name
                         , to_char(ici.iss_date, 'dd/mm/yyyy') as iss_date
                         , to_char(ici.expir_date, 'dd/mm/yyyy') as expir_date
                         , nvl(get_account_extra_limit(aao.account_id), 0) as overdraft_limit -- Temporary credit limit
                         , (select balance 
                              from acc_balance
                             where balance_type = acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT --'BLTP1007'
                               and account_id = aac.id
                           ) as overdraft_amount     
                         , (select balance 
                              from acc_balance
                             where balance_type = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED --'BLTP1001'
                               and account_id = aac.id
                           ) as credit_limit
                         , acc_api_balance_pkg.get_aval_balance_amount_only(aac.id) as aval_limit      
                         , (select balance 
                              from acc_balance
                             where balance_type = acc_api_const_pkg.BALANCE_TYPE_HOLD  --'BLTP0002'
                               and account_id = aac.id
                           ) as hold_balance       
                         , (select nvl(sum(cdb.amount), 0)
                              from crd_debt cde
                                 , crd_debt_balance cdb
                             where cde.id = cdb.debt_id  
                               and decode(cde.status, crd_api_const_pkg.DEBT_STATUS_ACTIVE, cde.account_id, null) = cde.account_id
                               and cdb.balance_type in (crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT    --'BLTP1002'
                                                      , crd_api_const_pkg.BALANCE_TYPE_OVERDUE      --'BLTP1004'
                                                      , acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT    --'BLTP1007'
                                                      )
                               and cde.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH   --'OPTP0001'
                                                   , opr_api_const_pkg.OPERATION_TYPE_POS_CASH   --'OPTP0012'
                                                   )
                               and cde.fee_type is null
                               and cde.account_id = aac.id
                            ) as outstanding_cash
                         , (select nvl(sum(cdb.amount), 0)
                              from crd_debt cde
                                 , crd_debt_balance cdb
                             where cde.id = cdb.debt_id  
                               and decode(cde.status, crd_api_const_pkg.DEBT_STATUS_ACTIVE, cde.account_id, null) = cde.account_id
                               and cdb.balance_type in (crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT    --'BLTP1002'
                                                      , crd_api_const_pkg.BALANCE_TYPE_OVERDUE      --'BLTP1004'
                                                      , acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT    --'BLTP1007'
                                                      )
                               and cde.oper_type = opr_api_const_pkg.OPERATION_TYPE_PURCHASE   --'OPTP0000'
                               and cde.fee_type is null
                               and cde.account_id = aac.id
                            ) as outstanding_pos    
                         , (select nvl(sum(cdb.amount), 0)
                              from crd_debt cde
                                 , crd_debt_balance cdb
                             where cde.id = cdb.debt_id  
                               and decode(cde.status, crd_api_const_pkg.DEBT_STATUS_ACTIVE, cde.account_id, null) = cde.account_id
                               and cde.account_id = aac.id
                               and ((
                                    cdb.balance_type in (crd_api_const_pkg.BALANCE_TYPE_INTEREST         --'BLTP1003'
                                                       , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST --'BLTP1005'
                                                       ) 
                                    and cde.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE     --'OPTP0000'
                                                        , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH     --'OPTP0001'
                                                        )
                                    )
                                    or(
                                    cde.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE       --'OPTP0119'
                                                    )
                                    )           
                                   )
                            ) as outstanding_service    
                         , (select nvl(sum(cdb.min_amount_due), 0)
                              from crd_debt cde
                                 , crd_debt_balance cdb
                             where cde.id = cdb.debt_id  
                               and decode(cde.status, crd_api_const_pkg.DEBT_STATUS_ACTIVE, cde.account_id, null) = cde.account_id
                               and cde.account_id = aac.id
                           ) as mad_amount   
                         , (select abs(ab.balance)
                              from acc_balance ab
                             where ab.balance_type = cst_cab_api_const_pkg.BALANCE_TYPE_COLLECTION --'BLTP1014'
                               and ab.account_id = aac.id
                            ) as coll_amount
                         , cst_cab_com_pkg.get_overdue_days(aac.id) as overdue_days    
                         , aac.status || '-' || com_api_dictionary_pkg.get_article_text(aac.status) as card_status
                         , to_char(psn.birthday, 'dd/mm/yyyy') as birthday     
                         , psn.gender                 
                         , (select t.commun_address
                              from (select ccd.commun_address
                                         , cco.object_id as customer_id
                                         , row_number() over(partition by cco.object_id order by contact_type, start_date desc) as rn
                                      from com_contact_data ccd
                                         , com_contact_object cco
                                     where ccd.contact_id = cco.contact_id    
                                       and ccd.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE    --'CMNM0001'  
                                       and cco.contact_type in (com_api_const_pkg.CONTACT_TYPE_PRIMARY          --'CNTTPRMC'
                                                              , cst_cab_api_const_pkg.CONTACT_TYPE_SECONDARY    --'CNTTSCNC' 
                                                               )            
                                       and cco.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER -- 'ENTTCUST'                                        
                                    )t
                             where t.rn = 1
                               and t.customer_id = ica.customer_id 
                            ) as mobile_phone
                         , (select t.commun_address
                              from (select ccd.commun_address
                                         , cco.object_id as customer_id
                                         , row_number() over(partition by cco.object_id order by contact_type, start_date desc) as rn
                                      from com_contact_data ccd
                                         , com_contact_object cco
                                     where ccd.contact_id = cco.contact_id    
                                       and ccd.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_PHONE     --'CMNM0012'  
                                       and cco.contact_type in (com_api_const_pkg.CONTACT_TYPE_PRIMARY          --'CNTTPRMC'
                                                              , cst_cab_api_const_pkg.CONTACT_TYPE_SECONDARY    --'CNTTSCNC' 
                                                               )            
                                       and cco.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER -- 'ENTTCUST'
                                    )t
                             where t.rn = 1
                               and t.customer_id = ica.customer_id 
                            ) as home_phone
                         , (select d.field_value
                              from com_flexible_field f
                                 , com_flexible_data d
                             where f.id = d.field_id
                               and f.name = 'CST_CAB_CARD_COLLATERAL'
                               and f.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'  
                               and d.object_id = ica.id
                           ) as secured_amount
                         , null as secured_account  
                         , aac.currency     
                      from iss_card ica
                         , iss_card_number icn
                         , acc_account_object aao
                         , acc_account aac
                         , iss_card_instance ici
                         , ost_agent agt
                         , (select p.birthday
                                 , substr(p.gender, 5, 1) as gender
                                 , c.id
                              from com_person p
                                 , iss_cardholder c
                             where p.id = c.person_id
                            ) psn     
                     where ica.id = icn.card_id
                       and ica.id = ici.card_id   
                       and agt.id = ici.agent_id
                       and psn.id = ica.cardholder_id
                       and aac.id = aao.account_id
                       and aao.object_id = ica.id
                       and aao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD     --'ENTTCARD'   
                       and aac.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT --'ACTP0130'    
                       and ici.state <> iss_api_const_pkg.CARD_STATE_CLOSED         --'CSTE0300' 
                       and ici.inst_id = nvl(i_inst_id, ici.inst_id)
                  order by overdue_days
                    )t
            )r;
    exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => LOG_PREFIX || 'No data found!'
            );
    end;

    select xmlelement(
               "report"
             , l_header
             , l_detail
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Finish.'
    );

exception
    when others then
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
        raise;
end credit_aging;

procedure export_exceed_limit(
    o_xml                      out clob
  , i_lang                  in     com_api_type_pkg.t_dict_value
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_object_id             in      com_api_type_pkg.t_medium_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
)
is
begin
    if i_entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION then
        select
               xmlelement("customer",
                   xmlelement("customer_number"  , c.customer_number),
                   xmlelement("currency"         , com_api_currency_pkg.get_currency_name(i_curr_code => o1.oper_currency)),
                   xmlelement("exceed_limit"     , o1.oper_amount),
                   xmlelement("title"            , com_ui_person_pkg.get_title(c.object_id)),
                   xmlelement("first_name"       , com_ui_person_pkg.get_first_name(c.object_id)),
                   xmlelement("second_name"      , com_ui_person_pkg.get_second_name(c.object_id)),
                   xmlelement("surname"          , com_ui_person_pkg.get_surname(c.object_id))
               ).getclobval()
          into o_xml
          from opr_operation   o1
             , opr_participant o2
             , prd_customer    c
         where o1.id            = o2.oper_id
           and o1.oper_type     = crd_api_const_pkg.OPERATION_TYPE_PROVIDE_CREDIT --'OPTP1001'
           and o2.customer_id   = c.id
           and o1.id            = i_object_id;
    elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        select
               xmlelement("account",
                   xmlelement("account_number"   , a.account_number),
                   xmlelement("currency"         , com_api_currency_pkg.get_currency_name(i_curr_code => a.currency)),
                   xmlelement("aval_balance"     , acc_api_balance_pkg.get_aval_balance_amount_only(a.id, com_api_sttl_day_pkg.get_sysdate, com_api_const_pkg.DATE_PURPOSE_PROCESSING, 1)),
                   xmlelement("exceed_limit"     , b.balance),
                   xmlelement("title"            , com_ui_person_pkg.get_title(c.object_id)),
                   xmlelement("first_name"       , com_ui_person_pkg.get_first_name(c.object_id)),
                   xmlelement("second_name"      , com_ui_person_pkg.get_second_name(c.object_id)),
                   xmlelement("surname"          , com_ui_person_pkg.get_surname(c.object_id))
               ).getclobval()
          into o_xml
          from acc_account  a
             , acc_balance  b
             , prd_customer c
         where a.id             = i_object_id
           and a.id             = b.account_id
           and b.balance_type   = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED --'BLTP1001'
           and a.customer_id    = c.id;
    end if;

exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error             => 'ENTITY_TYPE_NOT_FOUND'
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
        );
end;

end cst_cab_api_report_pkg;
/
