create or replace package body mup_prc_report_pkg is

c_virtual_office_array_id constant com_api_type_pkg.t_short_id := 10000114;
C_PURCHASE                constant com_api_type_pkg.t_name     := 'purchase';

procedure process_form_1_iss_oper(
    i_inst_id      in  com_api_type_pkg.t_tiny_id
  , i_agent_id     in  com_api_type_pkg.t_short_id  default null
  , i_start_date   in  date
  , i_end_date     in  date
  , i_lang         in  com_api_type_pkg.t_dict_value
)
is
    l_start_id              com_api_type_pkg.t_long_id;
    l_end_id                com_api_type_pkg.t_long_id;
    l_count_trans           com_api_type_pkg.t_count := 0;
    l_count_trans_usonthem  com_api_type_pkg.t_count := 0;
    procedure log(i_message in com_api_type_pkg.t_text,
                  i_trace_level in com_api_type_pkg.t_name default trc_api_const_pkg.TRACE_LEVEL_DEBUG) is
    begin
        if i_trace_level = trc_api_const_pkg.TRACE_LEVEL_DEBUG then
            trc_log_pkg.info (i_text => i_message);
        else
            trc_log_pkg.error (i_text => i_message);
        end if;
    end log;
begin
    l_start_id := com_api_id_pkg.get_from_id(i_start_date);
    l_end_id   := com_api_id_pkg.get_till_id(i_end_date);
    prc_api_stat_pkg.log_start;

    log('Start collecting for inst_id=[' || i_inst_id || '], agent_id=[' || i_agent_id 
    || '], start_date=[' || to_char(i_start_date, 'DD.MM.YYYY HH24:MI:SS')
    || '], end_date=[' || to_char(i_end_date, 'DD.MM.YYYY HH24:MI:SS')
    || '], start_id=[' || l_start_id || '], end_id=[' || l_end_id || ']');

    delete from mup_form_1_trans t
     where t.oper_id between l_start_id and l_end_id
       and (t.inst_id = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
       and (i_agent_id is null or t.agent_id = i_agent_id);

    log('Deleted from mup_form_1_trans ' || SQL%rowcount || ' recs.');

    insert into mup_form_1_trans
    select c.inst_id
         , co.agent_id
         , o.id as oper_id
         , case
              when o.sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS   then 1
              when o.sttl_type = opr_api_const_pkg.SETTLEMENT_USONTHEM then 2
              else 9
           end subsection
         , substr(oc.card_number, 1, 8) as card_bin
         , oc.card_number as card_number
         , case
               when o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                  , opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                                   )
               then 'cashout'
               when o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                                  , opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                                  , opr_api_const_pkg.OPERATION_TYPE_REFUND
                                   )
               then C_PURCHASE
               when o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_CASHIN
               ) then 'cashin'
               when ( (o.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P 
                     and oc.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                 )
                      or (o.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT )                    
                    ) then 'p2p_debet'
               when ((o.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P 
                     and oc.participant_type = com_api_const_pkg.PARTICIPANT_DEST
                     )
                  or (o.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT
                      )
                    ) then 'p2p_credit'
               else 'undefined'
           end column_type
         , case
               when o.merchant_country = '643' then 1
               else 0
           end is_rf
         , case
               when a.card_data_input_mode in ('F2270005', 'F2270007', 'F2270009', 'F227000S') then 1
               else 0
           end is_internet
         , case
               when o.is_reversal = 1 or o.oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND
               then -1
               else 1
           end oper_sign
         , round(to_number(com_api_rate_pkg.convert_amount(
                               i_src_amount      => nvl(o_pres.oper_amount, o.oper_amount)
                             , i_src_currency    => o.oper_currency
                             , i_dst_currency    => com_api_currency_pkg.RUBLE
                             , i_rate_type       => mup_api_const_pkg.CBRF_RATE
                             , i_inst_id         => c.inst_id
                             , i_eff_date        => o.oper_date
                             , i_mask_exception  => com_api_const_pkg.FALSE
                             , i_exception_value => 0
                           )
                          )
                  ) - nvl(o.oper_surcharge_amount,0) as oper_amount
         , o.oper_currency
         , o.merchant_number
      from iss_card_vw c
      join opr_card oc on reverse(oc.card_number) = reverse(c.card_number)
                      and oc.oper_id between l_start_id and l_end_id
      join opr_operation o on o.id = oc.oper_id
                           and o.msg_type not in (opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION)
      left join opr_operation o_pres on o_pres.id = o.match_id
                                    and o_pres.msg_type in (opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT )
      join aut_auth a on o.id = a.id
      join prd_contract co on co.id = c.contract_id
     where c.card_type_id in (select id from net_card_type where parent_type_id = 1041)
       and (c.inst_id = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
       and co.agent_id = nvl(i_agent_id, co.agent_id)
       and o.oper_amount > 0
       and exists (select 1 from acc_macros m where object_id = o.id)
       and o.sttl_type != opr_api_const_pkg.SETTLEMENT_USONTHEM  -- subsection 1 and 9
    ;

    l_count_trans := nvl(l_count_trans, 0) + SQL%rowcount;
    log(l_count_trans || ' recs of subsection 1 and 9 inserted into mup_form_1_trans .');
    prc_api_stat_pkg.log_estimation(i_estimated_count => l_count_trans);

    insert into mup_form_1_trans
    select c.inst_id
         , co.agent_id
         , o.id as oper_id
         , case
              when o.sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS   then 1
              when o.sttl_type = opr_api_const_pkg.SETTLEMENT_USONTHEM then 2
              else 9
           end subsection
         , substr(oc.card_number, 1, 8) as card_bin
         , oc.card_number as card_number
         , case
               when o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                  , opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                                   )
               then 'cashout'
               when o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                                  , opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                                  , opr_api_const_pkg.OPERATION_TYPE_REFUND
                                   )
               then C_PURCHASE
               when o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_CASHIN
               ) then 'cashin'
               when ( (o.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P 
                     and oc.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                 )
                      or (o.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT )                    
                    ) then 'p2p_debet'
               when ((o.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P 
                     and oc.participant_type = com_api_const_pkg.PARTICIPANT_DEST
                     )
                  or (o.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT
                      )
                    ) then 'p2p_credit'
               else 'undefined'
           end column_type
         , case
               when o.merchant_country = '643' then 1
               else 0
           end is_rf
         , case
               when a.card_data_input_mode in ('F2270005', 'F2270007', 'F2270009', 'F227000S') then 1
               else 0
           end is_internet
         , case
               when o.is_reversal = 1 or o.oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND
               then -1
               else 1
           end oper_sign
         , round(to_number(com_api_rate_pkg.convert_amount(
                               i_src_amount      => nvl(o_pres.oper_amount, o.oper_amount)
                             , i_src_currency    => o.oper_currency
                             , i_dst_currency    => com_api_currency_pkg.RUBLE
                             , i_rate_type       => mup_api_const_pkg.CBRF_RATE
                             , i_inst_id         => c.inst_id
                             , i_eff_date        => o.oper_date
                             , i_mask_exception  => com_api_const_pkg.FALSE
                             , i_exception_value => 0
                           )
                          )
                  ) - nvl(o.oper_surcharge_amount,0) as oper_amount
         , o.oper_currency
         , o.merchant_number
      from iss_card_vw c
      join opr_card oc on reverse(oc.card_number) = reverse(c.card_number)
      join opr_operation o on o.id = oc.oper_id
                           and o.msg_type not in (opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION)
      left join opr_operation o_pres on o_pres.id = o.match_id
                                    and o_pres.msg_type in (opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT )
      join aut_auth a on o.id = a.id
      join prd_contract co on co.id = c.contract_id
      join mup_fin f on f.id = o.id
     where c.card_type_id in (select id from net_card_type where parent_type_id = 1041)
       and (c.inst_id   = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
       and co.agent_id  = nvl(i_agent_id, co.agent_id)
       and o.oper_amount > 0
--       and o.sttl_date >= trunc(i_start_date) and o.sttl_date < trunc(i_end_date) + 1 -- this field is empty
       and f.p2159_6 >= trunc(i_start_date) and f.p2159_6 < trunc(i_end_date) + 1
       and exists (select 1 from acc_macros m where object_id = o.id)
       and o.sttl_type = opr_api_const_pkg.SETTLEMENT_USONTHEM -- SUBSECTION 2
       and not ( (
                  (o.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P
               and oc.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                  )
                or (o.oper_type = opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT )
                 )
             and 
                 (select count(distinct aa.id)
                    from opr_participant pp
                       , acc_account aa
                   where pp.oper_id  = o.id
                     and aa.id       = pp.account_id
                     and aa.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CARD
                 ) < 2
               ) --*/
    ;
    
    l_count_trans_usonthem := SQL%rowcount;
    log(l_count_trans_usonthem || ' recs of subsection 2 inserted into mup_form_1_trans .');
    l_count_trans := nvl(l_count_trans, 0) + nvl(l_count_trans_usonthem, 0);
    prc_api_stat_pkg.log_estimation(i_estimated_count => l_count_trans);
 
    delete from mup_form_1_aggr a
     where (a.inst_id = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
       and (i_agent_id is null or a.agent_id = i_agent_id);

    log(SQL%rowcount || ' recs deleted from mup_form_1_aggr .' );

    insert into mup_form_1_aggr
    select com_api_flexible_data_pkg.get_flexible_value('MUP_MEMBER_CODE', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, t.inst_id) as member_code
         , com_api_flexible_data_pkg.get_flexible_value('RUS_REG_NUM', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, t.inst_id) as bank_code
         , get_text ('OST_INSTITUTION', 'NAME', t.inst_id, i_lang) as bank_name
         , t.inst_id
         , to_char(null) as agent_id
         , t.subsection
         , t.card_bin
         , (select count(distinct c.id)
              from iss_card_vw c
              join iss_card_instance ci on ci.card_id = c.id
             where c.card_number like t.card_bin||'%'
               and ci.status in ( iss_api_const_pkg.CARD_STATUS_VALID_CARD )
           ) as all_card_count
         , count(distinct card_number) as active_card_count
         , sum(case when t.column_type = 'cashout' and t.is_rf = 1 then t.oper_sign else 0 end) as cashout_rf_count
         , sum(case when t.column_type = 'cashout' and t.is_rf = 1 then t.oper_sign*t.oper_amount else 0 end) as cashout_rf_amount
         , sum(case when t.column_type = 'cashout' and t.is_rf = 0 then t.oper_sign else 0 end) cashout_foreign_count
         , sum(case when t.column_type = 'cashout' and t.is_rf = 0 then t.oper_sign*t.oper_amount else 0 end) as cashout_foreign_amount
         , sum(case when t.column_type = 'cashin' then t.oper_sign else 0 end) as cashin_count
         , sum(case when t.column_type = 'cashin' then t.oper_sign*t.oper_amount else 0 end) as cashin_amount
         , sum(case when t.column_type = C_PURCHASE then t.oper_sign else 0 end) as purch_all_count
         , sum(case when t.column_type = C_PURCHASE then t.oper_sign*t.oper_amount else 0 end) as purch_all_amount
         , sum(case when t.column_type = C_PURCHASE and t.is_rf = 1 then t.oper_sign else 0 end) as purch_rf_count
         , sum(case when t.column_type = C_PURCHASE and t.is_rf = 1 then t.oper_sign*t.oper_amount else 0 end) as purch_rf_amount
         , sum(case when t.column_type = C_PURCHASE and t.is_rf = 1 and t.is_internet = 1 
                     and t.merchant_number not in ( select ae.element_value from com_array_element ae where ae.array_id = c_virtual_office_array_id)
                    then t.oper_sign else 0 end) as purch_rf_int_count
         , sum(case when t.column_type = C_PURCHASE and t.is_rf = 1 and t.is_internet = 1 
                     and t.merchant_number not in ( select ae.element_value from com_array_element ae where ae.array_id = c_virtual_office_array_id)
                    then t.oper_sign*t.oper_amount else 0 end) as purch_rf_int_amount
         , sum(case when t.column_type = C_PURCHASE and t.is_rf = 0 then t.oper_sign else 0 end) as purch_foreign_count
         , sum(case when t.column_type = C_PURCHASE and t.is_rf = 0 then t.oper_sign*t.oper_amount else 0 end) as purch_foreign_amount
         , sum(case when t.column_type = C_PURCHASE and t.is_rf = 0 and t.is_internet = 1 then t.oper_sign else 0 end) as purch_foreign_int_count
         , sum(case when t.column_type = C_PURCHASE and t.is_rf = 0 and t.is_internet = 1 then t.oper_sign*t.oper_amount else 0 end) as purch_foreign_int_amount
         , sum(case when t.column_type = 'p2p_debet' then t.oper_sign else 0 end) as p2p_debet_count
         , sum(case when t.column_type = 'p2p_debet' then t.oper_sign*t.oper_amount else 0 end) as p2p_debet_amount
         , sum(case when t.column_type = 'p2p_credit' then t.oper_sign else 0 end) as p2p_credit_count
         , sum(case when t.column_type = 'p2p_credit' then t.oper_sign*t.oper_amount else 0 end) as p2p_credit_amount
      from mup_form_1_trans t
     where (t.inst_id = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
       and (i_agent_id is null or t.agent_id = i_agent_id)
  group by t.inst_id
         , t.subsection
         , t.card_bin
  order by t.inst_id
         , t.subsection
         , t.card_bin;

    log(SQL%rowcount || ' recs inserted into mup_form_1_aggr. ');
    
    prc_api_stat_pkg.log_end(
        i_processed_total   => l_count_trans
      , i_excepted_total    => 0
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    log('Finish collecting data');
exception
    when com_api_error_pkg.e_application_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => SQLERRM
        );
end process_form_1_iss_oper;

procedure process_form_2_2_acq_oper(
    i_inst_id      in  com_api_type_pkg.t_tiny_id
  , i_agent_id     in  com_api_type_pkg.t_short_id  default null
  , i_start_date   in  date
  , i_end_date     in  date
  , i_lang         in  com_api_type_pkg.t_dict_value
)
is
    l_start_date   date;
    l_end_date     date;
    l_start_id     com_api_type_pkg.t_long_id;
    l_end_id       com_api_type_pkg.t_long_id;
    l_count_recs   number;
    procedure log(i_message     in     com_api_type_pkg.t_text
                , i_trace_level in     com_api_type_pkg.t_name default trc_api_const_pkg.TRACE_LEVEL_DEBUG) is
    begin
        if i_trace_level = trc_api_const_pkg.TRACE_LEVEL_DEBUG then
            trc_log_pkg.info (i_text => i_message);
        else
            trc_log_pkg.error (i_text => i_message);
        end if;
    end log;
begin
    l_start_date := nvl(i_start_date, trunc(add_months(get_sysdate,-3),'Q'));
    l_end_date   := nvl(i_end_date, trunc(get_sysdate,'Q')-1) + 1 - com_api_const_pkg.ONE_SECOND;
    l_start_id   := com_api_id_pkg.get_from_id(l_start_date);
    l_end_id     := com_api_id_pkg.get_till_id(l_end_date);
            
    prc_api_stat_pkg.log_start;

    log('Start collecting for inst_id=[' || i_inst_id || '], agent_id=[' || i_agent_id
    || '], start_date=[' || to_char(l_start_date, 'DD.MM.YYYY HH24:MI:SS')
    || '], end_date=[' || to_char(l_end_date, 'DD.MM.YYYY HH24:MI:SS') || ']');

    delete from mup_form_2_2_trans t
     where t.oper_id between com_api_id_pkg.get_from_id(l_start_date) and com_api_id_pkg.get_till_id(l_end_date)
       and t.inst_id = i_inst_id
       and (i_agent_id is null or t.agent_id = i_agent_id);

    l_count_recs := SQL%rowcount;
    log(l_count_recs || ' recs deleted from mup_form_2_2_trans .');

    insert into mup_form_2_2_trans
    select inst_id
         , agent_id
         , l_start_date
         , l_end_date
         , oper_id
         , case (c6_c7_pay_pos +
                 c8_c9_pay_atm +
                 c10_c11_pay_internet +
                 c12_c13_cashout_atm +
                 c14_c15_cashout_pos +
                 c16_c17_cashin +
                 c18_c19_transfer_credit +
                 c20_c21_transfer_debit)
               when 1 then 1
               else 0
           end as checked_successfully
         , oper_sign
         , oper_amount * oper_sign as oper_amount
         , part
         , c0_region_code
         , c6_c7_pay_pos
         , c8_c9_pay_atm
         , c10_c11_pay_internet
         , c12_c13_cashout_atm
         , c14_c15_cashout_pos
         , c16_c17_cashin
         , c18_c19_transfer_credit
         , c20_c21_transfer_debit
      from (select f.id as oper_id
                 , f.inst_id
                 , cont.agent_id
                 , decode(o.is_reversal, 0, 1, -1) * decode(f.de003_1, 20, -1, 1) as oper_sign
                 , f.de049 as oper_currency
                 , round(to_number(com_api_rate_pkg.convert_amount(i_src_amount      => o.oper_amount
                                                                 , i_src_currency    => o.oper_currency
                                                                 , i_dst_currency    => com_api_currency_pkg.RUBLE
                                                                 , i_rate_type       => mup_api_const_pkg.CBRF_RATE
                                                                 , i_inst_id         => ca.inst_id
                                                                 , i_eff_date        => o.oper_date
                                                                 , i_mask_exception  => 1
                                                                 , i_exception_value => 0
                                                                 )
                                  )
                        ) - o.oper_surcharge_amount as oper_amount
                 , case
                       when o.sttl_type = opr_api_const_pkg.SETTLEMENT_USONTHEM or ca.card_number is not null then 1
                       when o.sttl_type = opr_api_const_pkg.SETTLEMENT_THEMONUS /*and iss_country = '643'*/ then 2
                       else 3
                   end part
                 , coalesce(o.merchant_region, '45') as c0_region_code
                 , case
                      when f.de003_1 in ('00', '20') 
                        and f.de026 not in ('6536', '6538', '6010', '6011') 
                        and f.de022_8 in ('3', '4', '6', '9') and o.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_POS)
                      then 1
                      else 0
                   end c6_c7_pay_pos
                 , case
                      when f.de003_1 in ('00', '20') and f.de026 not in ('6536', '6538') and f.de022_8 in ('1', '2')
                      then 1
                      else 0
                   end c8_c9_pay_atm
                 , case
                      when f.de003_1 in ('00', '20') 
                       and f.de026 not in ('6536', '6538', '6537', '6010', '6011') 
                       and f.de022_5 in ('5') 
                       and o.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_EPOS)
                      then 1
                      else 0
                   end c10_c11_pay_internet
                 , case
                      when f.de003_1 in ('01') 
                       and f.de026 in ('6011') 
                       and o.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_ATM
                        )
                      then 1
                      else 0
                   end c12_c13_cashout_atm
                 , case
                      when f.de003_1 in ('12') 
                       and f.de026 in ('6010') 
                       and o.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_POS
                      )
                      then 1
                      else 0
                   end c14_c15_cashout_pos
                 , case
                      when f.de026 in ('6012') and o.oper_type not in (
                          opr_api_const_pkg.OPERATION_TYPE_P2P
                        , opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                        , opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                        , opr_api_const_pkg.OPERATION_TYPE_REFUND
                        , opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                        )
                      then 1
                      else 0
                   end c16_c17_cashin
                 , case
                      when f.de026 = '6536' and f.de003_1 = '28'
                      then 1
                      else 0
                   end c18_c19_transfer_credit
                 , case
                      when f.de026 = '6538' and f.de003_1 = '00'
                      then 1
                      else 0
                   end c20_c21_transfer_debit
              from mup_fin f
              join opr_operation o       on o.id = f.id
              join opr_participant opa   on opa.oper_id = f.id and opa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
              join opr_card c       on c.oper_id = o.id and c.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
              join iss_card_vw ca   on ca.card_number = c.card_number
              join prd_contract cont     on cont.id = ca.contract_id
             where 1 = 1
               and f.id between l_start_id and l_end_id
               and (opa.inst_id = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
               and (i_agent_id is null or cont.agent_id = i_agent_id)
               and (o.sttl_type = opr_api_const_pkg.SETTLEMENT_USONTHEM or ca.card_number is not null)
               and f.status     = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
               and o.oper_type not in (opr_api_const_pkg.OPERATION_TYPE_CASHIN)
               and o.merchant_country = '643'
             union all -----------------------------------
            select f.id as oper_id
                 , f.inst_id
                 , cont.agent_id
                 , decode(o.is_reversal, 0, 1, -1) * decode(f.de003_1, 20, -1, 1) as oper_sign
                 , f.de049 as oper_currency
                 , round(to_number(com_api_rate_pkg.convert_amount(i_src_amount      => o.oper_amount
                                                                 , i_src_currency    => o.oper_currency
                                                                 , i_dst_currency    => com_api_currency_pkg.RUBLE
                                                                 , i_rate_type       => mup_api_const_pkg.CBRF_RATE
                                                                 , i_inst_id         => ca.inst_id
                                                                 , i_eff_date        => o.oper_date
                                                                 , i_mask_exception  => 1
                                                                 , i_exception_value => 0
                                                                 )
                                  )
                        ) - o.oper_surcharge_amount as oper_amount
                 , case
                       when o.sttl_type = opr_api_const_pkg.SETTLEMENT_USONTHEM or ca.card_number is not null then 1
                       else 3
                   end part
                 , coalesce(a.region_code, '45') as c0_region_code
                 , case
                      when f.de003_1 in ('00', '20') 
                        and f.de026 not in ('6536', '6538', '6010', '6011') 
                        and f.de022_8 in ('3', '4', '6', '9') and o.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_POS)
                      then 1
                      else 0
                   end c6_c7_pay_pos
                 , case
                      when f.de003_1 in ('00', '20') and f.de026 not in ('6536', '6538') and f.de022_8 in ('1', '2')
                      then 1
                      else 0
                   end c8_c9_pay_atm
                 , case
                      when f.de003_1 in ('00', '20') 
                       and f.de026 not in ('6536', '6538', '6537', '6010', '6011') 
                       and f.de022_5 in ('5') 
                       and o.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_EPOS)
                      then 1
                      else 0
                   end c10_c11_pay_internet
                 , case
                      when f.de003_1 in ('01') 
                       and f.de026 in ('6011') 
                       and o.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_ATM
                        )
                      then 1
                      else 0
                   end c12_c13_cashout_atm
                 , case
                      when f.de003_1 in ('12') 
                       and f.de026 in ('6010') 
                       and o.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_POS
                      )
                      then 1
                      else 0
                   end c14_c15_cashout_pos
                 , case
                      when f.de026 in ('6012') and o.oper_type not in (
                          opr_api_const_pkg.OPERATION_TYPE_P2P
                        , opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                        , opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                        , opr_api_const_pkg.OPERATION_TYPE_REFUND
                        , opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                        )
                      then 1
                      else 0
                   end c16_c17_cashin
                 , case
                      when f.de026 = '6536' and f.de003_1 = '28'
                      then 1
                      else 0
                   end c18_c19_transfer_credit
                 , case
                      when f.de026 = '6538' and f.de003_1 = '00'
                      then 1
                      else 0
                   end c20_c21_transfer_debit
              from mup_fin f
              join opr_operation o       on o.id = f.id
              join opr_participant opa   on opa.oper_id = f.id and opa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
              join acq_terminal t        on t.id = opa.terminal_id
              join prd_contract cont     on cont.id = t.contract_id
              join com_address_object ao on ao.object_id = t.id and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
              join com_address a         on a.id = ao.address_id
              left join opr_card c       on c.oper_id = o.id and c.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
              left join iss_card_vw ca   on ca.card_number = c.card_number
             where 1 = 1
               and o.sttl_date >= trunc(i_start_date) and o.sttl_date < trunc(i_end_date) + 1
--               and f.p2159_6 >= trunc(i_start_date) and f.p2159_6 < trunc(i_end_date) + 1    -- this field is empty
               and (opa.inst_id = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
               and (i_agent_id is null or cont.agent_id = i_agent_id)
               and f.status    = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
               and not (o.sttl_type = opr_api_const_pkg.SETTLEMENT_USONTHEM or ca.card_number is not null)
               and o.oper_type not in (opr_api_const_pkg.OPERATION_TYPE_CASHIN)
               and o.merchant_country = 643 -- Russia
          );

    l_count_recs := SQL%rowcount;
    log('Inserted into mup_form_2_2_trans ' || l_count_recs || ' recs.');

    delete from mup_form_2_2_aggr a
     where a.inst_id = i_inst_id
       and (i_agent_id is null or a.agent_id = i_agent_id);

    log(SQL%rowcount || ' recs deleted from mup_form_2_2_aggr.');

    insert into mup_form_2_2_aggr
    select t.inst_id
         , to_number(null) as agent_id
         , part
         , checked_successfully
         , c0_region_code
         , com_api_flexible_data_pkg.get_flexible_value('MUP_MEMBER_CODE', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, t.inst_id) as c1_member_code
         , com_api_flexible_data_pkg.get_flexible_value('RUS_REG_NUM', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, t.inst_id) as c2_bank_code
         , ost_ui_institution_pkg.get_inst_name(t.inst_id, i_lang) as c3_bank_name
         , sum(oper_sign*(c6_c7_pay_pos + c8_c9_pay_atm + c10_c11_pay_internet)) as c4_count_pay
         , sum(oper_amount*(c6_c7_pay_pos + c8_c9_pay_atm + c10_c11_pay_internet)) as c5_sum_pay
         , sum(oper_sign*c6_c7_pay_pos) as c6_count_pay_pos
         , sum(oper_amount*c6_c7_pay_pos) as c7_sum_pay_pos
         , sum(oper_sign*c8_c9_pay_atm) as c8_count_pay_atm
         , sum(oper_amount*c8_c9_pay_atm) as c9_sum_pay_atm
         , sum(oper_sign*c10_c11_pay_internet) as c10_count_pay_internet
         , sum(oper_amount*c10_c11_pay_internet) as c11_sum_pay_internet
         , sum(oper_sign*c12_c13_cashout_atm) as c12_count_cashout_atm
         , sum(oper_amount*c12_c13_cashout_atm) as c13_sum_cashout_atm
         , sum(oper_sign*c14_c15_cashout_pos) as c14_count_cashout_pos
         , sum(oper_amount*c14_c15_cashout_pos) as c15_sum_cashout_pos
         , sum(oper_sign*c16_c17_cashin) as c16_count_cashin
         , sum(oper_amount*c16_c17_cashin) as c17_sum_cashin
         , sum(oper_sign*c18_c19_transfer_credit) as c18_count_transfer_credit
         , sum(oper_amount*c18_c19_transfer_credit) as c19_sum_transfer_credit
         , sum(oper_sign*c20_c21_transfer_debit) as c20_count_transfer_debit
         , sum(oper_amount*c20_c21_transfer_debit) as c21_sum_transfer_debit
      from mup_form_2_2_trans t
     where (t.inst_id = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
       and (i_agent_id is null or t.agent_id = i_agent_id)
  group by t.inst_id
         , part
         , checked_successfully
         , c0_region_code
  order by t.inst_id
         , c0_region_code;

    log(SQL%rowcount || ' recs inserted into mup_form_2_2_aggr .');
    
    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_count_recs
    );
 
    prc_api_stat_pkg.log_end(
        i_processed_total => l_count_recs
      , i_excepted_total  => 0
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    log('Finish collecting data');
exception
    when com_api_error_pkg.e_application_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => SQLERRM
        );
end process_form_2_2_acq_oper;

/*
 * Procedure gather MIR card insfrastructure.
 */
procedure report_card_instrastructure(
    o_xml           out clob
  , i_inst_id    in     com_api_type_pkg.t_long_id
  , i_start_date in     date
  , i_end_date   in     date
  , i_user_id    in     com_api_type_pkg.t_long_id           default null
  , i_lang       in     com_api_type_pkg.t_dict_value        default null
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.report_card_instrastructure: ';

    l_result     xmltype;
    l_header     xmltype;
    l_detail     xmltype;

    l_user_id    com_api_type_pkg.t_long_id;
    l_lang       com_api_type_pkg.t_dict_value;
begin

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'start, i_inst_id [#1], i_start_date [#2], i_end_date [#3], i_user_id [#4], i_lang [#5]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_start_date
      , i_env_param3 => i_end_date
      , i_env_param4 => i_user_id
      , i_env_param5 => i_lang
    );

    l_user_id := nvl(i_user_id, get_user_id());
    l_lang    := get_user_lang();

    -- process here

    -- header
    with rawdata as (
        select id
             , full_name
             , second_name
             , commun_method
             , commun_address
        from (
            select u.id
                 , p.surname || ' ' || p.first_name as full_name
                 , p.second_name
                 , ccd.end_date
                 , cco.contact_type
                 , ccd.commun_method
                 , ccd.commun_address
                 , row_number() over (partition by u.id, ccd.commun_method order by ccd.end_date, cco.id desc) rn
              from acm_user u
              left join com_person p on p.id = u.person_id
              left join com_contact_object cco on p.id = cco.object_id
                     and entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
              left join com_contact_data ccd on ccd.contact_id = cco.contact_id
               and (ccd.end_date is null or ccd.end_date > sysdate)
               and ccd.commun_method in (com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                       , com_api_const_pkg.COMMUNICATION_METHOD_PHONE
                                       , com_api_const_pkg.COMMUNICATION_METHOD_EMAIL
                                        )
        ) where rn = 1
    ) select xmlelement("header"
                            , xmlelement("full_name",   full_name)
                            , xmlelement("second_name", second_name)
                            , xmlelement("phone"      , nvl(sellphone, landphone))
                            , xmlelement("email"      , email)
                       )
    into l_header
    from rawdata
   pivot (
         max(commun_address)
         for commun_method in ('CMNM0001' as sellphone
                             , 'CMNM0012' as landphone
                             , 'CMNM0002' as email
                              )
         )
   where id = l_user_id;

   -- details

   with fulldata as (
    -- source for group
    select
         -- common info
           substr(co.region_code, 1, 2) as territory_code
         , com_api_flexible_data_pkg.get_flexible_value(
               i_field_name  => 'MUP_MEMBER_CODE'
             , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
             , i_object_id   => i_inst_id
           ) as unique_code
         , com_api_flexible_data_pkg.get_flexible_value(
               i_field_name  => 'RUS_REG_NUM'
             , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
             , i_object_id   => i_inst_id
           ) as reg_credit_number
         , get_text(
               i_table_name  => 'OST_INSTITUTION'
             , i_column_name => 'NAME'
             , i_object_id   => i_inst_id
             , i_lang        => l_lang
           ) as institution_name
         -- grid data
         , t.terminal_type
         , t.cash_dispenser_present
         , t.payment_possibility
         , t.available_operation
         , t.cash_in_present
         , t.available_network
         , case
               when not exists(
                   select 1
                     from com_array_element
                    where array_id = 10000084
                      and to_char(element_number) = m.mcc)
               then 1
               else 0
           end                                                              as appr_mcc
      from prd_contract c
      join acq_terminal t on t.contract_id = c.id
                         and t.inst_id     = i_inst_id
                         and t.status      = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE
      left join acq_merchant m on t.merchant_id = m.id
                              and m.inst_id     = i_inst_id
      left join (select object_id
                      , address_id
                      , row_number() over (partition by object_id order by address_id desc) rn
                   from com_address_object
                  where entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                ) cco on cco.object_id = t.id
                     and cco.rn = 1
      left join com_address co on co.id = cco.address_id
                              and co.lang = 'LANGENG' --l_lang
     where (c.inst_id = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
       and c.product_id in (select id
                           from prd_product
                          where product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ
                        )
      -- start_date / end_date filter, [start_date; end_date] should intersect with [i_start_date; i_end_date]
       and (c.start_date <= i_end_date)
       and (c.end_date >= i_start_date or c.end_date is null)
    )
  , rawdata as
 (select territory_code
       , unique_code
       , reg_credit_number
       , institution_name
       -- counters
       , count(*) as contract_count         -- p4
       , sum (case terminal_type when acq_api_const_pkg.TERMINAL_TYPE_EPOS
                   then 1
                                 when acq_api_const_pkg.TERMINAL_TYPE_INTERNET
                   then 1
                   else 0
              end
             ) internet_contract_count      -- p5
       , sum (case when terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_ATM
                                        , acq_api_const_pkg.TERMINAL_TYPE_INFO_KIOSK
                                         )
                   then 1
                   else 0
              end
             ) atm_total_count                -- p6
       , sum (case when terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_ATM
                                        , acq_api_const_pkg.TERMINAL_TYPE_INFO_KIOSK
                                         )
                   then case cash_dispenser_present when 1
                             then 1
                             else 0
                        end
                   else 0
              end
             ) atm_cashout_count    -- p7
       , sum (case when terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_ATM
                                        , acq_api_const_pkg.TERMINAL_TYPE_INFO_KIOSK
                                         )
                   then case when payment_possibility = 1
                             then 1
                             when available_operation is not null   -- ??
                             then 1
                             else 0
                        end
                   else 0
              end
             ) atm_pay_count        -- p8
       , sum (case when terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_ATM
                                        , acq_api_const_pkg.TERMINAL_TYPE_INFO_KIOSK
                                        )
                   then case cash_in_present when 1
                            then 1
                            else 0
                        end
                   else 0
              end
             ) atm_cashin_count     -- p9
       , sum (case when terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_ATM
                                        , acq_api_const_pkg.TERMINAL_TYPE_INFO_KIOSK
                                        )
                   then case when available_operation is not null
                             then 1
                             when available_network is not null
                             then 1
                             else 0
                        end
                   else 0
              end
             ) atm_transfer_count  -- p10
       , sum (case when terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_POS
                                        , acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER
                                         )
                   then 1
                   else 0
              end
             ) eterm_total_count
       , sum (case when terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_POS
                                        , acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER
                                         )
                   then case
                            when appr_mcc = 1
                            then 1
                            else 0
                        end
                   else 0
              end
             ) eterm_pay_count
       , sum (case when terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_POS
                                        , acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER
                                         )
                   then case cash_in_present when 1
                             then 1
                             else 0
                        end
                   else 0
              end
             ) eterm_cashout_count
    from fulldata
group by territory_code
       , unique_code
       , reg_credit_number
       , institution_name)
    select xmlelement("table"
                 , xmlagg(
                       xmlelement("record"
                         , xmlelement("territory_code"          , territory_code)
                         , xmlelement("unique_code"             , unique_code)
                         , xmlelement("reg_credit_number"       , reg_credit_number)
                         , xmlelement("institution_name"        , institution_name)
                         --
                         , xmlelement("contract_count"          , contract_count)
                         , xmlelement("internet_contract_count" , internet_contract_count)
                         --
                         , xmlelement("atm_total_count"         , atm_total_count)
                         , xmlelement("atm_cashout_count"       , atm_cashout_count)
                         , xmlelement("atm_pay_count"           , atm_pay_count)
                         , xmlelement("atm_cashin_count"        , atm_cashin_count)
                         , xmlelement("atm_transfer_count"      , atm_transfer_count)
                         --
                         , xmlelement("eterm_total_count"       , eterm_total_count)
                         , xmlelement("eterm_pay_count"         , eterm_pay_count)
                         , xmlelement("eterm_cashout_count"     , eterm_cashout_count)
                       )
                   )
               )
          into l_detail
          from rawdata;

        --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                 , xmlagg(
                       xmlelement("record"
                         , xmlelement("territory_code"          , null)
                         , xmlelement("unique_code"             , null)
                         , xmlelement("reg_credit_number"       , null)
                         , xmlelement("institution_name"        , null)
                         --
                         , xmlelement("contract_count"          , null)
                         , xmlelement("internet_contract_count" , null)
                         --
                         , xmlelement("atm_total_count"         , null)
                         , xmlelement("atm_cashout_count"       , null)
                         , xmlelement("atm_pay_count"           , null)
                         , xmlelement("atm_cashin_count"        , null)
                         , xmlelement("atm_transfer_count"      , null)
                         --
                         , xmlelement("eterm_total_count"       , null)
                         , xmlelement("eterm_pay_count"         , null)
                         , xmlelement("eterm_cashout_count"     , null)
                       )
                   )
               )
          into l_detail
          from dual;
    end if;

    select xmlelement("report"
         , l_header
         , l_detail
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'end '
    );

exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => SQLERRM
        );
end report_card_instrastructure;

end mup_prc_report_pkg;
/
