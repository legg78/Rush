create or replace package body vis_api_transaction_pkg as
/*********************************************************
 *  API for getting transactions for VISA financail messages <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 29.03.2017 <br />
 *  Module: VIS_API_TRANSACTION_PKG <br />
 *  @headcom
 **********************************************************/

/*
 * Procedure returns a cursor with unheld entries of uploading incoming VISA messages (after operations matching).
 */
procedure get_unheld_transactions(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_agent_id              in     com_api_type_pkg.t_agent_id
  , i_start_date            in     date
  , i_end_date              in     date
  , o_ref_cur                  out com_api_type_pkg.t_ref_cur
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_unheld_transactions'; 
begin
    open o_ref_cur for
    select acct.account_number
         , iss_api_card_pkg.get_card_mask(i_card_number => vsc.card_number) as card_number
         , vsf.auth_code
         , vsf.oper_date
         , nvl(agnt.agent_number, agnt.id)                                  as agent_number
         , entr.currency                                                    as transaction_currency
         , entr.amount                                                      as transaction_amount
         , cust.customer_number
      from vis_fin_message        vsf
      join vis_card               vsc    on vsc.id            = vsf.id
      join iss_card               crd    on crd.id            = vsf.card_id
      join net_card_type          nct    on nct.id            = crd.card_type_id
                                        and nct.network_id    = vis_api_const_pkg.VISA_NETWORK_ID
      join prd_customer           cust   on cust.id           = crd.customer_id
      join acc_account_object     ao     on ao.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                                        and ao.object_id      = vsf.card_id
      join acc_account            acct   on acct.id           = ao.account_id
      join acc_entry              entr   on entr.account_id   = acct.id
      join ost_agent              agnt   on agnt.id           = acct.agent_id
     where entr.transaction_type in (acc_api_const_pkg.TRAN_TYPE_CANCEL_RESERVATION)
       and acct.inst_id       = i_inst_id
       and acct.agent_id      = i_agent_id
       and entr.posting_date >= trunc(i_start_date)
       and entr.posting_date <  trunc(i_end_date) + 1
       and nct.id in ( -- Debit cards only
               select feature.card_type_id
                 from net_card_type_feature feature
                where feature.card_feature in (net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT)
           )
     order by
           acct.account_number
         , vsc.card_number
         , oper_date
         , auth_code
    ;
exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ' FAILED: i_inst_id [#2], i_agent_id [#3]'
                                       || ', i_start_date [#4], i_end_date [#5], sqlerrm [#1]'
          , i_env_param1 => sqlerrm
          , i_env_param2 => i_inst_id
          , i_env_param3 => i_agent_id
          , i_env_param4 => to_char(i_start_date, com_api_const_pkg.LOG_DATE_FORMAT)
          , i_env_param5 => to_char(i_end_date,   com_api_const_pkg.LOG_DATE_FORMAT)
        );
        raise;
end get_unheld_transactions;

/*
 * Procedure returns a cursor with deducted entries of uploading incoming VISA messages (after operations matching).
 */
procedure get_deducted_transactions(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_agent_id              in     com_api_type_pkg.t_agent_id
  , i_start_date            in     date
  , i_end_date              in     date
  , o_ref_cur                  out com_api_type_pkg.t_ref_cur
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_deducted_transactions'; 
begin
    open o_ref_cur for
    select cust.customer_number
         , nvl(agnt.agent_number, agnt.id)                                  as agent_number
         , acct.account_number
         , sum(entr.amount)                                                 as transaction_amount
      from vis_fin_message    vsf
      join vis_card           vsc    on vsc.id          = vsf.id
      join iss_card           crd    on crd.id          = vsf.card_id
      join net_card_type      nct    on nct.id          = crd.card_type_id
                                    and nct.network_id  = vis_api_const_pkg.VISA_NETWORK_ID
      join prd_customer       cust   on cust.id         = crd.customer_id
      join acc_account_object ao     on ao.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
                                    and ao.object_id    = vsf.card_id
      join acc_account        acct   on acct.id         = ao.account_id
      join acc_entry          entr   on entr.account_id = acct.id
      join ost_agent          agnt   on agnt.id         = acct.agent_id
     where entr.balance_type in (acc_api_const_pkg.BALANCE_TYPE_LEDGER
                               , acc_api_const_pkg.BALANCE_TYPE_FEES)
       and acct.inst_id       = i_inst_id
       and acct.agent_id      = i_agent_id
       and entr.posting_date >= trunc(i_start_date)
       and entr.posting_date <  trunc(i_end_date) + 1
       and nct.id in ( -- Debit cards only
               select feature.card_type_id
                 from net_card_type_feature feature
                where feature.card_feature in (net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT)
           )
     group by
           cust.customer_number
         , nvl(agnt.agent_number, agnt.id)
         , acct.account_number
     order by
           cust.customer_number
         , acct.account_number
    ;
exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ' FAILED: i_inst_id [#2], i_agent_id [#3]'
                                       || ', i_start_date [#4], i_end_date [#5], sqlerrm [#1]'
          , i_env_param1 => sqlerrm
          , i_env_param2 => i_inst_id
          , i_env_param3 => i_agent_id
          , i_env_param4 => to_char(i_start_date, com_api_const_pkg.LOG_DATE_FORMAT)
          , i_env_param5 => to_char(i_end_date,   com_api_const_pkg.LOG_DATE_FORMAT)
        );
        raise;
end get_deducted_transactions;

/*
 * Procedure returns a cursor for a list of transactions without settlement from Visa.
 */
procedure get_transactions_without_sttl(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_agent_id              in     com_api_type_pkg.t_agent_id
  , i_start_date            in     date
  , i_end_date              in     date
  , o_ref_cur                  out com_api_type_pkg.t_ref_cur
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_transactions_without_sttl';
    l_proc_bin                     com_api_type_pkg.t_bin;
    l_param_tab                    com_api_type_pkg.t_param_tab;
    l_host_id                      com_api_type_pkg.t_tiny_id;
begin
    l_host_id  :=
        net_api_network_pkg.get_default_host(
            i_network_id => vis_api_const_pkg.VISA_NETWORK_ID
        );
    l_proc_bin :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => i_inst_id
          , i_standard_id   => vis_api_const_pkg.VISA_BASEII_STANDARD
          , i_object_id     => l_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => vis_api_const_pkg.CMID
          , i_param_tab     => l_param_tab
        );

    if l_proc_bin is null then
        com_api_error_pkg.raise_error(
            i_error       => 'VISA_ACQ_PROC_BIN_NOT_DEFINED'
          , i_env_param1  => i_inst_id
          , i_env_param2  => vis_api_const_pkg.VISA_BASEII_STANDARD
          , i_env_param3  => l_host_id
        );
    end if;

    open o_ref_cur for
    select iss_api_card_pkg.get_card_mask(
               i_card_number => opc.card_number
           )                                                                as card_number
         , acq_api_merchant_pkg.get_arn(
               i_acquirer_bin => l_proc_bin
             , i_proc_date    => opr.oper_date
           )                                                                as arn
         , opr.oper_date
         , opr.oper_amount
         , opr.oper_currency
         , opr.merchant_name
         , opr.merchant_city
         , prtp.auth_code
         , vis_api_fin_message_pkg.get_pos_entry_mode(
               i_card_data_input_mode => auth.card_data_input_mode
           )                                                                as pos_entry_mode
      from      opr_operation      opr
           join opr_card           opc    on opc.oper_id           = opr.id
           join opr_participant    prtp   on prtp.oper_id          = opr.id
                                         and prtp.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           join acc_account        acct   on acct.id               = prtp.account_id
      left join aut_auth           auth   on auth.id               = opr.id
     where opr.msg_type in (
               opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
             , opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
             , opr_api_const_pkg.MESSAGE_TYPE_COMPLETION
           )
       and opr.match_status in (
               opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH
             , opr_api_const_pkg.OPERATION_MATCH_PARTIAL_MATCHE
           )
       and opr.oper_date >= trunc(i_start_date)
       and opr.oper_date <  trunc(i_end_date) + 1
       and acct.inst_id   = i_inst_id
       and acct.agent_id  = i_agent_id
     order by
           opc.card_number
         , opr.oper_date
         , opr.merchant_name
    ;
exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ' FAILED: i_inst_id [' || i_inst_id
                                       || '], i_agent_id [' || i_agent_id
                                       || '], i_start_date [#4], i_end_date [#5]'
                                       ||  ', l_host_id [' || l_host_id || '], l_proc_bin [' || l_proc_bin
                                       || '], sqlerrm [' || sqlerrm || ']'
          , i_env_param4 => to_char(i_start_date, com_api_const_pkg.LOG_DATE_FORMAT)
          , i_env_param5 => to_char(i_end_date,   com_api_const_pkg.LOG_DATE_FORMAT)
        );
        raise;
end get_transactions_without_sttl;

/*
 * Procedure returns a cursor for a list of settlement Visa messages without authorizations from SVFE.
 */
procedure get_transactions_without_auth(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_agent_id              in     com_api_type_pkg.t_agent_id
  , i_start_date            in     date
  , i_end_date              in     date
  , o_ref_cur                  out com_api_type_pkg.t_ref_cur
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_transactions_without_auth'; 
begin
    open o_ref_cur for
    select iss_api_card_pkg.get_card_mask(i_card_number => vsc.card_number) as card_number
         , vsf.arn
         , vsf.oper_date
         , vsf.sttl_amount
         , vsf.sttl_currency
         , vsf.oper_amount
         , vsf.oper_currency
         , vsf.merchant_name
         , vsf.merchant_city
         , vsf.auth_code
         , vsf.pos_entry_mode
      from opr_operation      opr
      join vis_fin_message    vsf    on vsf.id                = opr.id
      join vis_card           vsc    on vsc.id                = vsf.id
      join opr_participant    prtp   on prtp.oper_id          = opr.id
                                    and prtp.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
      join acc_account        acct   on acct.id               = prtp.account_id
     where opr.msg_type in (
               opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
             , opr_api_const_pkg.MESSAGE_TYPE_PARTIAL_AMOUNT
             , opr_api_const_pkg.MESSAGE_TYPE_PART_AMOUNT_COMPL
           )
       and opr.match_status in (
               opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH
             , opr_api_const_pkg.OPERATION_MATCH_PARTIAL_MATCHE
           )
       and opr.oper_date >= trunc(i_start_date)
       and opr.oper_date <  trunc(i_end_date) + 1
       and acct.inst_id   = i_inst_id
       and acct.agent_id  = i_agent_id
     order by
           vsc.card_number
         , vsf.oper_date
         , vsf.merchant_name
    ;
exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ' FAILED: i_inst_id [#2], i_agent_id [#3]'
                                       || ', i_start_date [#4], i_end_date [#5], sqlerrm [#1]'
          , i_env_param1 => sqlerrm
          , i_env_param2 => i_inst_id
          , i_env_param3 => i_agent_id
          , i_env_param4 => to_char(i_start_date, com_api_const_pkg.LOG_DATE_FORMAT)
          , i_env_param5 => to_char(i_end_date,   com_api_const_pkg.LOG_DATE_FORMAT)
        );
        raise;
end get_transactions_without_auth;

end;
/
