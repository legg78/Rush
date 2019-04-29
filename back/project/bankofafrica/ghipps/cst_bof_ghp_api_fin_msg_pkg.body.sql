create or replace package body cst_bof_ghp_api_fin_msg_pkg as

-- Fields of a fin. message
G_COLUMN_LIST               constant com_api_type_pkg.t_text :=
   '  f.id'
|| ', f.status'
|| ', f.is_reversal'
|| ', f.is_incoming'
|| ', f.is_returned'
|| ', f.is_invalid'
|| ', f.inst_id'
|| ', f.network_id'
|| ', f.trans_code'
|| ', f.card_id'
|| ', f.card_hash'
|| ', f.card_mask'
|| ', iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number'
|| ', f.oper_date'
|| ', f.oper_amount'
|| ', f.oper_currency'
|| ', f.sttl_amount'
|| ', f.sttl_currency'
|| ', f.dest_amount'
|| ', f.dest_currency'
|| ', f.arn'
|| ', f.merchant_number'
|| ', f.merchant_name'
|| ', f.merchant_city'
|| ', f.merchant_country'
|| ', f.merchant_type'
|| ', f.merchant_region'
|| ', f.mcc'
|| ', f.terminal_number'
|| ', f.terminal_country'
|| ', f.terminal_profile'
|| ', f.terminal_type'
|| ', f.usage_code'
|| ', f.reason_code'
|| ', f.auth_code'
|| ', f.crdh_id_method'
|| ', f.chargeback_ref_num'
|| ', f.docum_ind'
|| ', f.member_msg_text'
|| ', f.spec_cond_ind'
|| ', f.electr_comm_ind'
|| ', f.spec_chargeback_ind'
|| ', f.account_selection'
|| ', f.transaction_type'
|| ', f.card_seq_number'
|| ', f.card_expir_date'
|| ', f.unpredict_number'
|| ', f.appl_trans_counter'
|| ', f.appl_interch_profile'
|| ', f.cryptogram'
|| ', f.cryptogram_info_data'
|| ', f.cryptogram_amount'
|| ', f.term_verif_result'
|| ', f.issuer_appl_data'
|| ', f.issuer_script_result'
|| ', f.iss_reimb_fee'
|| ', f.iss_auth_data'
|| ', f.transaction_type_tcr3'
|| ', f.trans_status'
|| ', f.trans_currency'
|| ', f.trans_code_header'
|| ', f.trans_inter_proc_date'
|| ', f.trans_date'
|| ', f.trans_category_code'
|| ', f.trans_seq_number'
|| ', f.crdh_cardnum_cap_ind'
|| ', f.crdh_billing_amount'
|| ', f.crdh_verif_method'
|| ', f.electronic_term_ind'
|| ', f.reconciliation_ind'
|| ', f.payment_product_ind'
|| ', f.dispute_id'
|| ', f.file_id'
|| ', f.record_number'
|| ', f.rrn'
|| ', f.host_inst_id'
|| ', f.acq_inst_bin'
|| ', f.proc_bin'
|| ', f.auth_code_src_ind'
|| ', f.forw_inst_id'
|| ', f.void_ind'
|| ', f.receiv_inst_id'
|| ', f.value_date'
|| ', f.voucher_dep_bank_code'
|| ', f.voucher_dep_branch_code'
|| ', f.reconciliation_date'
|| ', f.merch_serv_charge'
|| ', f.acq_msc_revenue'
|| ', f.cashback_amount'
|| ', f.rate_dst_loc_currency'
|| ', f.rate_loc_dst_currency'
|| ', f.logical_file'
;

/*
 * Function parses incoming value card_data_input_mode and returns POS entry mode.
 */
function get_pos_entry_mode(
    i_card_data_input_mode in     com_api_type_pkg.t_dict_value
) return aut_api_type_pkg.t_pos_entry_mode
is
begin
    return
        case
            -- Magnetic stripe read and exact content of Track 1 or Track 2 included (CVV check is possible)
            when i_card_data_input_mode = 'F227000B'                then '90'
            -- Integrated circuit card read; CVV or iCVV data reliable
            when i_card_data_input_mode in ('F227000C', 'F227000F') then '05'
            -- Manual key entry
            when i_card_data_input_mode in ('F2270006', 'F227000S', 'F2270005', 'F2270007', 'F2270009') then '01'
            -- Proximity Payment using VSDC chip data rules
            when i_card_data_input_mode = 'F227000M'                then '07'
            -- Proximity payment using magnetic stripe data rules
            when i_card_data_input_mode = 'F227000A'                then '91'
            -- Magnetic stripe read; CVV checking may not be possible
            when i_card_data_input_mode = 'F2270002'                then '02'
            -- Credential on file
            when i_card_data_input_mode = 'F227000E'                then '10'
                                                                    else null
        end;
end;

procedure get_fin_message(
    i_id                   in     com_api_type_pkg.t_long_id
  , o_fin_rec                 out cst_bof_ghp_api_type_pkg.t_ghp_fin_mes_rec
  , i_mask_error           in     com_api_type_pkg.t_boolean                    default com_api_const_pkg.FALSE
) is
    l_fin_cur                     sys_refcursor;
    l_statement                   com_api_type_pkg.t_text;
begin
    l_statement :=
    'select ' || G_COLUMN_LIST        ||
     ' from cst_bof_ghp_fin_msg_vw f' ||
         ', cst_bof_ghp_card c'       ||
    ' where f.id = :i_id'            ||
      ' and f.id = c.id(+)';

    open l_fin_cur for l_statement using i_id;
    fetch l_fin_cur into o_fin_rec;
    close l_fin_cur;

    if o_fin_rec.id is null then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error       => 'FINANCIAL_MESSAGE_NOT_FOUND'
              , i_env_param1  => i_id
            );
        else
            trc_log_pkg.error(
                i_text        => 'FINANCIAL_MESSAGE_NOT_FOUND'
              , i_env_param1  => i_id
            );
        end if;
    end if;
exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;
        raise;
end get_fin_message;

function estimate_messages_for_upload(
    i_network_id           in     com_api_type_pkg.t_network_id
  , i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_host_inst_id         in     com_api_type_pkg.t_inst_id
  , i_start_date           in     date                                          default null
  , i_end_date             in     date                                          default null
) return number
is
    l_result                      number;
begin
    select count(f.id)
      into l_result
      from cst_bof_ghp_fin_msg f
         , opr_operation o
     where decode(f.status, 'CLMS0010', 'CLMS0010', null) = 'CLMS0010'
       and f.is_incoming  = 0
       and f.id           = o.id
       and f.network_id   = i_network_id
       and f.inst_id      = i_inst_id
       and f.host_inst_id = i_host_inst_id
       and (
            (i_start_date is null and i_end_date is null)
            or
            (f.oper_date between nvl(i_start_date, trunc(f.oper_date)) and nvl(i_end_date, trunc(f.oper_date)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_const_pkg.FALSE
            )
            or
            (o.host_date between nvl(i_start_date, trunc(o.host_date)) and nvl(i_end_date, trunc(o.host_date)) + 1 - com_api_const_pkg.ONE_SECOND
                and f.is_reversal = com_api_const_pkg.TRUE
            )
           );

    return l_result;
end;

procedure enum_messages_for_upload(
    o_fin_cur              in out sys_refcursor
  , i_network_id           in     com_api_type_pkg.t_network_id
  , i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_host_inst_id         in     com_api_type_pkg.t_inst_id
  , i_start_date           in     date default null
  , i_end_date             in     date default null
) is
    DATE_PLACEHOLDER     constant com_api_type_pkg.t_name := '##DATE##';
    l_stmt                        com_api_type_pkg.t_text;
begin
    l_stmt := '
select ' || G_COLUMN_LIST || '
  from cst_bof_ghp_fin_msg_vw f
     , cst_bof_ghp_card c
     , opr_operation o
where decode(f.status, ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY
               || ''', ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY
      || ''' , null) = ''' || net_api_const_pkg.CLEARING_MSG_STATUS_READY || '''
  and f.is_incoming  = :is_incoming
  and f.id           = o.id
  and f.network_id   = :i_network_id
  and f.inst_id      = :i_inst_id
  and f.host_inst_id = :i_host_inst_id
  and c.id(+)        = f.id ' || DATE_PLACEHOLDER || '
order by f.logical_file
       , f.trans_code';

    l_stmt := replace(
        l_stmt
      , DATE_PLACEHOLDER
      , case
            when i_start_date is not null or i_end_date is not null then '
    and (f.oper_date between nvl(:i_start_date, trunc(f.oper_date)) and nvl(:i_end_date, trunc(f.oper_date)) + 1 - 1/86400
        and f.is_reversal = ' || com_api_const_pkg.FALSE || '
     or
        o.host_date between nvl(:i_start_date, trunc(o.host_date)) and nvl(:i_end_date, trunc(o.host_date)) + 1 - 1/86400
        and f.is_reversal = ' || com_api_type_pkg.TRUE || ') '
            else
                ' '
        end
    );

    if i_start_date is not null or i_end_date is not null then
        open o_fin_cur for l_stmt
        using com_api_const_pkg.FALSE, i_network_id, i_inst_id, i_host_inst_id
            , i_start_date, i_end_date, i_start_date, i_end_date;
    else
        open o_fin_cur for l_stmt
        using com_api_const_pkg.FALSE, i_network_id, i_inst_id, i_host_inst_id;
    end if;

exception
    when others then
        trc_log_pkg.debug(
            i_text => lower($$PLSQL_UNIT)  || '.enum_messages_for_upload >> FAILED with l_stmt:'
                   || chr(13) || chr(10)   || l_stmt
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end enum_messages_for_upload;

function get_original_id(
    i_fin_rec              in     cst_bof_ghp_api_type_pkg.t_ghp_fin_mes_rec
  , i_fee_rec              in     cst_bof_ghp_api_type_pkg.t_fee_rec            default null
) return com_api_type_pkg.t_long_id
is
    l_need_original_id            com_api_type_pkg.t_boolean;
begin
    return get_original_id(
               i_fin_rec          => i_fin_rec
             , i_fee_rec          => i_fee_rec
             , o_need_original_id => l_need_original_id
           );
end;

function get_original_id(
    i_fin_rec              in     cst_bof_ghp_api_type_pkg.t_ghp_fin_mes_rec
  , i_fee_rec              in     cst_bof_ghp_api_type_pkg.t_fee_rec            default null
  , o_need_original_id        out com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_long_id
is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_original_id: ';
    l_original_id                 com_api_type_pkg.t_long_id;
    l_usage_code                  com_api_type_pkg.t_curr_code;
    l_tc1                         com_api_type_pkg.t_curr_code;
    l_tc2                         com_api_type_pkg.t_curr_code;
    l_tc3                         com_api_type_pkg.t_curr_code;
    l_tc4                         com_api_type_pkg.t_curr_code;
    l_tc5                         com_api_type_pkg.t_curr_code;
    l_tc6                         com_api_type_pkg.t_curr_code;
    l_tc7                         com_api_type_pkg.t_curr_code;
    l_fee_code                    com_api_type_pkg.t_curr_code;
begin
    o_need_original_id := com_api_const_pkg.FALSE;

    if i_fin_rec.usage_code = '1' then
        l_usage_code := '1';
        case
            when i_fin_rec.trans_code in (cst_bof_ghp_api_const_pkg.TC_SALES
                                        , cst_bof_ghp_api_const_pkg.TC_VOUCHER
                                        , cst_bof_ghp_api_const_pkg.TC_CASH)
            then
                return null;

            when i_fin_rec.trans_code in (cst_bof_ghp_api_const_pkg.TC_SALES_CHARGEBACK_REV
                                        , cst_bof_ghp_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                                        , cst_bof_ghp_api_const_pkg.TC_CASH_CHARGEBACK_REV)
            then
                l_tc1 := cst_bof_ghp_api_const_pkg.TC_SALES_CHARGEBACK;
                l_tc2 := cst_bof_ghp_api_const_pkg.TC_VOUCHER_CHARGEBACK;
                l_tc3 := cst_bof_ghp_api_const_pkg.TC_CASH_CHARGEBACK;

            when i_fin_rec.trans_code in (cst_bof_ghp_api_const_pkg.TC_FUNDS_DISBURSEMENT)
            then
                l_tc1 := cst_bof_ghp_api_const_pkg.TC_FEE_COLLECTION;
                l_tc2 := cst_bof_ghp_api_const_pkg.TC_SALES;
                l_tc3 := cst_bof_ghp_api_const_pkg.TC_VOUCHER;
                l_tc4 := cst_bof_ghp_api_const_pkg.TC_CASH;
                l_tc5 := cst_bof_ghp_api_const_pkg.TC_SALES_CHARGEBACK;
                l_tc6 := cst_bof_ghp_api_const_pkg.TC_VOUCHER_CHARGEBACK;
                l_tc7 := cst_bof_ghp_api_const_pkg.TC_CASH_CHARGEBACK;

            else
                l_tc1 := cst_bof_ghp_api_const_pkg.TC_SALES;
                l_tc2 := cst_bof_ghp_api_const_pkg.TC_VOUCHER;
                l_tc3 := cst_bof_ghp_api_const_pkg.TC_CASH;
        end case;
    else
        l_usage_code := '2';
        case
            when i_fin_rec.trans_code in (cst_bof_ghp_api_const_pkg.TC_SALES_CHARGEBACK_REV
                                        , cst_bof_ghp_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                                        , cst_bof_ghp_api_const_pkg.TC_CASH_CHARGEBACK_REV) then
                l_tc1 := cst_bof_ghp_api_const_pkg.TC_SALES_CHARGEBACK;
                l_tc2 := cst_bof_ghp_api_const_pkg.TC_VOUCHER_CHARGEBACK;
                l_tc3 := cst_bof_ghp_api_const_pkg.TC_CASH_CHARGEBACK;
            when i_fin_rec.trans_code in (cst_bof_ghp_api_const_pkg.TC_SALES
                                        , cst_bof_ghp_api_const_pkg.TC_VOUCHER
                                        , cst_bof_ghp_api_const_pkg.TC_CASH) then
                l_usage_code := '1';
                l_tc1 := cst_bof_ghp_api_const_pkg.TC_SALES_CHARGEBACK;
                l_tc2 := cst_bof_ghp_api_const_pkg.TC_VOUCHER_CHARGEBACK;
                l_tc3 := cst_bof_ghp_api_const_pkg.TC_CASH_CHARGEBACK;
            else
                l_tc1 := cst_bof_ghp_api_const_pkg.TC_SALES;
                l_tc2 := cst_bof_ghp_api_const_pkg.TC_VOUCHER;
                l_tc3 := cst_bof_ghp_api_const_pkg.TC_CASH;
        end case;
    end if;

    if l_usage_code is not null then
        select min(f.id)
          into l_original_id
          from cst_bof_ghp_fin_msg f
             , cst_bof_ghp_card c
         where f.trans_code in (l_tc1, l_tc2, l_tc3, l_tc4, l_tc5, l_tc6, l_tc7)
           and f.usage_code  = l_usage_code
           and c.card_number = iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.card_number)
           and f.id          = c.id
           and f.arn         = i_fin_rec.arn
           and f.id         != i_fin_rec.id;
    end if;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX
               || 'l_original_id [' || l_original_id
               || '] was found by i_fin_rec = {trans_code [' || i_fin_rec.trans_code
               || '], arn [' || i_fin_rec.arn || ']}'
               || ']}'
    );

    if l_original_id is null and (l_usage_code is not null or l_fee_code is not null) then
        o_need_original_id := com_api_const_pkg.TRUE;

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'The required original id is not found'
        );
    end if;

    return l_original_id;

exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX
                         || 'FAILED with i_fee_rec.trans_id [#6]'
                         || ', i_fin_rec = {id [#5], usage_code [#1], trans_code [#2], card_number [#3], arn [#4]}'
          , i_env_param1 => i_fin_rec.usage_code
          , i_env_param2 => i_fin_rec.trans_code
          , i_env_param3 => iss_api_card_pkg.get_card_mask(i_card_number => i_fin_rec.card_number)
          , i_env_param4 => i_fin_rec.arn
          , i_env_param5 => i_fin_rec.id
        );
        raise;
end get_original_id;

procedure get_fee(
    i_id                   in     com_api_type_pkg.t_long_id
  , o_fee_rec                 out cst_bof_ghp_api_type_pkg.t_fee_rec
) is
    l_fee_cur                     sys_refcursor;
    l_statement                   com_api_type_pkg.t_text;
begin
    l_statement := '
select f.id
     , f.file_id
     , f.fee_type_ind
     , f.forw_inst_country_code
     , f.reason_code
     , f.collection_branch_code
     , f.trans_count
     , f.unit_fee
     , f.event_date
     , f.source_amount_cfa
     , f.control_number
     , f.message_text
  from cst_bof_ghp_fee f
 where f.id = :i_id';

    open l_fee_cur for l_statement using i_id;
    fetch l_fee_cur into o_fee_rec;
    close l_fee_cur;

exception
    when others then
        if l_fee_cur%isopen then
            close l_fee_cur;
        end if;
        raise;
end;

procedure get_retrieval(
    i_id                   in     com_api_type_pkg.t_long_id
  , o_retrieval_rec           out cst_bof_ghp_api_type_pkg.t_retrieval_rec
) is
    l_retrieval_cur               sys_refcursor;
    l_statement                   com_api_type_pkg.t_text;
begin
    l_statement := '
select f.id
     , f.file_id
     , f.iss_inst_id
     , f.acq_inst_id
     , f.document_type
     , f.card_iss_ref_num
     , f.cancellation_ind
     , f.potential_chback_reason_code
     , f.response_type
  from cst_bof_ghp_retrieval f
 where f.id = :i_id';

    open l_retrieval_cur for l_statement using i_id;
    fetch l_retrieval_cur into o_retrieval_rec;
    close l_retrieval_cur;

exception
    when others then
        if l_retrieval_cur%isopen then
            close l_retrieval_cur;
        end if;
        raise;
end;

procedure get_fraud(
    i_id                   in     com_api_type_pkg.t_long_id
  , o_fraud_rec               out cst_bof_ghp_api_type_pkg.t_fraud_rec
) is
begin
    select f.id
         , f.status
         , f.file_id
         , f.record_number
         , f.is_incoming
         , f.is_invalid
         , f.dispute_id
         , f.network_id
         , f.inst_id
         , f.host_inst_id
         , f.forw_inst_id
         , f.receiv_inst_id
         , f.arn
         , f.oper_date
         , f.merchant_name
         , f.merchant_city
         , f.merchant_country
         , f.mcc
         , f.merchant_region
         , frd.fraud_amount
         , frd.fraud_currency
         , frd.vic_processing_date
         , frd.notification_code
         , frd.account_seq_number
         , frd.insurance_year
         , frd.fraud_type
         , frd.card_expir_date
         , frd.debit_credit_indicator
         , frd.trans_generation_method
         , f.electr_comm_ind
         , f.card_id
         , f.card_hash
         , f.card_mask
         , c.card_number
         , f.logical_file
      into o_fraud_rec.id
         , o_fraud_rec.status
         , o_fraud_rec.file_id
         , o_fraud_rec.record_number
         , o_fraud_rec.is_incoming
         , o_fraud_rec.is_invalid
         , o_fraud_rec.dispute_id
         , o_fraud_rec.network_id
         , o_fraud_rec.inst_id
         , o_fraud_rec.host_inst_id
         , o_fraud_rec.forw_inst_id
         , o_fraud_rec.receiv_inst_id
         , o_fraud_rec.arn
         , o_fraud_rec.oper_date
         , o_fraud_rec.merchant_name
         , o_fraud_rec.merchant_city
         , o_fraud_rec.merchant_country
         , o_fraud_rec.mcc
         , o_fraud_rec.merchant_region
         , o_fraud_rec.fraud_amount
         , o_fraud_rec.fraud_currency
         , o_fraud_rec.vic_processing_date
         , o_fraud_rec.notification_code
         , o_fraud_rec.account_seq_number
         , o_fraud_rec.insurance_year
         , o_fraud_rec.fraud_type
         , o_fraud_rec.card_expir_date
         , o_fraud_rec.debit_credit_indicator
         , o_fraud_rec.trans_generation_method
         , o_fraud_rec.electr_comm_ind
         , o_fraud_rec.card_id
         , o_fraud_rec.card_hash
         , o_fraud_rec.card_mask
         , o_fraud_rec.card_number
         , o_fraud_rec.logical_file
      from      cst_bof_ghp_fin_msg f
           join cst_bof_ghp_fraud   frd    on frd.id = f.id
      left join cst_bof_ghp_card    c      on c.id   = f.id
     where f.id = i_id;
exception
    when no_data_found then
        null;
end;

procedure process_auth(
    i_auth_rec             in     aut_api_type_pkg.t_auth_rec
  , i_inst_id              in     com_api_type_pkg.t_inst_id                    default null
  , i_network_id           in     com_api_type_pkg.t_network_id                 default null
  , i_status               in     com_api_type_pkg.t_dict_value                 default null
  , io_fin_mess_id         in out com_api_type_pkg.t_long_id
) is
    l_standard_id                 com_api_type_pkg.t_tiny_id;
    l_host_id                     com_api_type_pkg.t_tiny_id;
    l_emv_tag_tab                 com_api_type_pkg.t_tag_value_tab;
    l_pre_auth                    aut_api_type_pkg.t_auth_rec;
    l_fin_rec                     cst_bof_ghp_api_type_pkg.t_ghp_fin_mes_rec;
    l_param_tab                   com_api_type_pkg.t_param_tab;

    function get_msg_proc_bin(
        i_parent_network_id    in    com_api_type_pkg.t_network_id
    ) return com_api_type_pkg.t_auth_code
    is
        l_new_standard_id            com_api_type_pkg.t_tiny_id;
        l_new_host_id                com_api_type_pkg.t_tiny_id;
        l_result                     com_api_type_pkg.t_auth_code;
    begin
        trc_log_pkg.debug(
            i_text          => 'get_msg_proc_bin: Read msg_proc_bin'
        );

        l_new_host_id     := net_api_network_pkg.get_default_host(i_network_id => i_parent_network_id);
        l_new_standard_id := net_api_network_pkg.get_offline_standard(i_network_id => i_parent_network_id);

        l_result :=
            cmn_api_standard_pkg.get_varchar_value(
                i_inst_id       => l_fin_rec.inst_id
              , i_standard_id   => l_new_standard_id
              , i_object_id     => l_new_host_id
              , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name    => cst_bof_ghp_api_const_pkg.CMID
              , i_param_tab     => l_param_tab
            );

        trc_log_pkg.debug(
            i_text          => 'get_msg_proc_bin: cmid = ' || l_result
        );

        if l_result is null then
            com_api_error_pkg.raise_error(
                i_error         => 'GHP_ACQ_PROC_BIN_NOT_DEFINED'
                , i_env_param1  => l_fin_rec.inst_id
                , i_env_param2  => l_new_standard_id
                , i_env_param3  => l_new_host_id
            );
        end if;

        return l_result;
    end;

begin
    if io_fin_mess_id is null then
        io_fin_mess_id := opr_api_create_pkg.get_id;
    end if;

    l_fin_rec.id          := io_fin_mess_id;
    l_fin_rec.status      := nvl(i_status, net_api_const_pkg.CLEARING_MSG_STATUS_READY);

    l_fin_rec.is_reversal := i_auth_rec.is_reversal;

    l_fin_rec.is_incoming := com_api_const_pkg.FALSE;
    l_fin_rec.is_returned := com_api_const_pkg.FALSE;
    l_fin_rec.is_invalid  := com_api_const_pkg.FALSE;
    l_fin_rec.inst_id     := nvl(i_inst_id, i_auth_rec.acq_inst_id);
    l_fin_rec.network_id  := nvl(i_network_id, i_auth_rec.iss_network_id);

    -- get network communication standard
    l_host_id     :=
        net_api_network_pkg.get_default_host(
            i_network_id => l_fin_rec.network_id
        );
    l_standard_id :=
        net_api_network_pkg.get_offline_standard(
            i_network_id => l_fin_rec.network_id
        );

    trc_log_pkg.debug(
        i_text        => 'process_auth: inst_id[#1] network_id[#2] host_id[#3] standard_id[#4]'
      , i_env_param1  => l_fin_rec.inst_id
      , i_env_param2  => l_fin_rec.network_id
      , i_env_param3  => l_host_id
      , i_env_param4  => l_standard_id
    );

    rul_api_shared_data_pkg.load_oper_params(
        i_oper_id  => i_auth_rec.id
      , io_params  => l_param_tab
    );

    -- get Acquirer Processing BIN
    l_fin_rec.proc_bin :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id       => l_fin_rec.inst_id
          , i_standard_id   => l_standard_id
          , i_object_id     => l_host_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name    => cst_bof_ghp_api_const_pkg.CMID
          , i_param_tab     => l_param_tab
        );

    trc_log_pkg.debug('process_auth: proc_bin='||l_fin_rec.proc_bin);
    if l_fin_rec.proc_bin is null then
        com_api_error_pkg.raise_error(
            i_error       => 'GHP_ACQ_PROC_BIN_NOT_DEFINED'
          , i_env_param1  => l_fin_rec.inst_id
          , i_env_param2  => l_standard_id
          , i_env_param3  => l_host_id
        );
    end if;

    l_fin_rec.logical_file           := cst_bof_ghp_api_const_pkg.TC_FL_HEADER;

    l_fin_rec.dispute_id             := null;
    l_fin_rec.file_id                := null;
    l_fin_rec.record_number          := null;
    l_fin_rec.rrn                    := nvl(i_auth_rec.network_refnum, i_auth_rec.originator_refnum);

    -- converting reversal flag and operation type into transaction code
    l_fin_rec.trans_code :=
        case
            when i_auth_rec.is_reversal = com_api_const_pkg.FALSE then
                case
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                                , opr_api_const_pkg.OPERATION_TYPE_POS_CASH)
                        then cst_bof_ghp_api_const_pkg.TC_CASH
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                                                , opr_api_const_pkg.OPERATION_TYPE_UNIQUE
                                                , opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                                                , opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT)
                        then cst_bof_ghp_api_const_pkg.TC_SALES
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_REFUND
                                                , opr_api_const_pkg.OPERATION_TYPE_PAYMENT
                                                , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT
                                                , opr_api_const_pkg.OPERATION_TYPE_CASHIN)
                        then cst_bof_ghp_api_const_pkg.TC_VOUCHER
                    else
                        null
                end
            when i_auth_rec.is_reversal = com_api_type_pkg.TRUE then
                case
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                                , opr_api_const_pkg.OPERATION_TYPE_POS_CASH)
                        then cst_bof_ghp_api_const_pkg.TC_CASH_REVERSAL
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                                                , opr_api_const_pkg.OPERATION_TYPE_UNIQUE
                                                , opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                                                , opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT)
                        then cst_bof_ghp_api_const_pkg.TC_SALES_REVERSAL
                    when i_auth_rec.oper_type in (opr_api_const_pkg.OPERATION_TYPE_REFUND
                                                , opr_api_const_pkg.OPERATION_TYPE_PAYMENT
                                                , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT
                                                , opr_api_const_pkg.OPERATION_TYPE_CASHIN)
                        then cst_bof_ghp_api_const_pkg.TC_VOUCHER_REVERSAL
                    else
                        null
                end
            end;
    if l_fin_rec.trans_code is null then
        trc_log_pkg.error(
            i_text          => 'UNABLE_DETERMINE_GHP_TRANSACTION_CODE'
          , i_env_param1    => l_fin_rec.id
        );
    end if;

    -- define original authorization for completion
    if  i_auth_rec.msg_type = aut_api_const_pkg.MESSAGE_TYPE_COMPLETION
        or l_fin_rec.trans_code = cst_bof_ghp_api_const_pkg.TC_VOUCHER
    then
        opr_api_shared_data_pkg.load_auth(
            i_id            => i_auth_rec.original_id
          , io_auth         => l_pre_auth
        );
    end if;

    trc_log_pkg.debug('process_auth: TC='||l_fin_rec.trans_code);

    trc_log_pkg.debug('process_auth: g_trans_code(l_count)='||l_fin_rec.trans_code||', i_auth_rec.original_id='||i_auth_rec.original_id);
    trc_log_pkg.debug('process_auth: l_pre_auth.originator_refnum='||l_pre_auth.network_refnum||', g_rrn(l_count)='||l_fin_rec.rrn);

    if l_fin_rec.logical_file = cst_bof_ghp_api_const_pkg.TC_FL_HEADER then
        l_fin_rec.terminal_number := case when length(i_auth_rec.terminal_number) >= 8 
                                        then substr(i_auth_rec.terminal_number, -8) 
                                        else i_auth_rec.terminal_number
                                     end;
    end if;
    l_fin_rec.merchant_number     := i_auth_rec.merchant_number;
    l_fin_rec.merchant_name       := substrb(i_auth_rec.merchant_name, 1, 25);
    l_fin_rec.merchant_city       := substrb(i_auth_rec.merchant_city, 1, 13);
    l_fin_rec.merchant_country    := i_auth_rec.merchant_country;
    l_fin_rec.mcc                 := i_auth_rec.mcc;
    l_fin_rec.merchant_type       := ' ';
    l_fin_rec.spec_cond_ind       := '  ';
    l_fin_rec.electronic_term_ind := '0';
    l_fin_rec.usage_code          := '1'; -- first presentment
    l_fin_rec.reconciliation_ind  := '000';
    l_fin_rec.member_msg_text     := ' ';
    l_fin_rec.reason_code         := '0000';
    l_fin_rec.chargeback_ref_num  := '000000';
    l_fin_rec.docum_ind           := null;
    l_fin_rec.payment_product_ind :=
        case l_fin_rec.logical_file
            when cst_bof_ghp_api_const_pkg.TC_FV_HEADER then '1'
            when cst_bof_ghp_api_const_pkg.TC_FM_HEADER then '2'
            when cst_bof_ghp_api_const_pkg.TC_FL_HEADER then '3'
        end;

    l_fin_rec.card_id          := i_auth_rec.card_id;
    l_fin_rec.card_hash        := com_api_hash_pkg.get_card_hash(i_auth_rec.card_number);
    l_fin_rec.card_mask        := iss_api_card_pkg.get_card_mask(i_auth_rec.card_number);
    l_fin_rec.card_number      := i_auth_rec.card_number;
    l_fin_rec.card_expir_date  := nvl(to_char(i_auth_rec.card_expir_date, 'MMYY'), '0000');

    l_fin_rec.crdh_id_method :=
        case
            -- Signature
            when i_auth_rec.crdh_auth_method in ('F2280002', 'F2280005')
            then '1'
            -- PIN
            when i_auth_rec.crdh_auth_method in ('F2280001')
            then '2'
            -- Unattended terminal; no PIN pad
            when i_auth_rec.cat_level        in ('F22D0003')
            then '3'
            -- Not specified
            else '0'
        end;
    l_fin_rec.crdh_cardnum_cap_ind := '0';

    if i_auth_rec.mcc = '6011' then
        l_fin_rec.account_selection  :=
            case i_auth_rec.account_type
                when 'ACCT0010' then '1'
                when 'ACCT0020' then '2'
                when 'ACCT0030' then '3'
                else '0'
            end;
    else
        l_fin_rec.account_selection  := '0';
    end if;

    l_fin_rec.trans_status := '00000';
    l_fin_rec.trans_code_header :=
        case l_fin_rec.logical_file
            when cst_bof_ghp_api_const_pkg.TC_FV_HEADER then cst_bof_ghp_api_const_pkg.TC_FV_HEADER
            when cst_bof_ghp_api_const_pkg.TC_FM_HEADER then cst_bof_ghp_api_const_pkg.TC_FMC_HEADER
            when cst_bof_ghp_api_const_pkg.TC_FL_HEADER then cst_bof_ghp_api_const_pkg.TC_FL_HEADER
        end;

    l_fin_rec.oper_date := nvl(l_pre_auth.oper_date, i_auth_rec.oper_date);
    l_fin_rec.auth_code := i_auth_rec.auth_code;

    l_fin_rec.auth_code_src_ind := '0';
    l_fin_rec.transaction_type  := '0';

    if i_auth_rec.is_reversal = com_api_type_pkg.TRUE then
        begin
            select arn
              into l_fin_rec.arn
              from cst_bof_ghp_fin_msg
             where id = i_auth_rec.original_id;
        exception
             when no_data_found then
                 com_api_error_pkg.raise_error(
                     i_error      => 'FINANCIAL_MESSAGE_NOT_FOUND'
                   , i_env_param1 => i_auth_rec.original_id
                 );
        end;
    else
        l_fin_rec.arn :=
            acq_api_merchant_pkg.get_arn(
                i_acquirer_bin => l_fin_rec.proc_bin
              , i_proc_date    => i_auth_rec.oper_date
            );
    end if;

    l_fin_rec.forw_inst_id := '00000000';
    l_fin_rec.void_ind := ' ';

    l_fin_rec.oper_currency  := i_auth_rec.oper_currency;
    l_fin_rec.oper_amount    := i_auth_rec.oper_amount;
    l_fin_rec.sttl_currency  := cst_bof_ghp_api_const_pkg.GHP_CURR_CODE;
    l_fin_rec.sttl_amount :=
         round(
             com_api_rate_pkg.convert_amount(
                 i_src_amount        => l_fin_rec.oper_amount
               , i_src_currency      => l_fin_rec.oper_currency
               , i_dst_currency      => cst_bof_ghp_api_const_pkg.GHP_CURR_CODE
               , i_rate_type         => cst_bof_ghp_api_const_pkg.GHP_RATE_TYPE
               , i_inst_id           => l_fin_rec.inst_id
               , i_eff_date          => l_fin_rec.oper_date
               , i_mask_exception    => com_api_const_pkg.FALSE
             )
         );
    -- In according to LIS specification field(16) DESTINATION AMOUNT (TCR 1) is not defined for local files (FL),
    -- field <rate_loc_dst_currency> (see below) should be also undefined (or be equal to 0)
    l_fin_rec.dest_amount    := 0;
    l_fin_rec.dest_currency  := null;

    l_fin_rec.receiv_inst_id          := '00000000';
    l_fin_rec.spec_chargeback_ind     := ' ';
    l_fin_rec.iss_reimb_fee           := 0;
    l_fin_rec.value_date              :=
        case
            when l_fin_rec.trans_code in (cst_bof_ghp_api_const_pkg.TC_CASH) then
                l_fin_rec.oper_date

            when l_fin_rec.trans_code in (cst_bof_ghp_api_const_pkg.TC_SALES
                                        , cst_bof_ghp_api_const_pkg.TC_VOUCHER) then
                trunc(com_api_sttl_day_pkg.get_sysdate()) -- It is equal to header (90) FILE PROCESSING DATE
        end;
    -- It is equal to header (90) FILE PROCESSING DATE
    l_fin_rec.trans_inter_proc_date   := trunc(com_api_sttl_day_pkg.get_sysdate());
    l_fin_rec.merchant_region         := '   ';
    l_fin_rec.voucher_dep_bank_code   := '00';
    l_fin_rec.voucher_dep_branch_code := '0000';
    l_fin_rec.card_seq_number         := i_auth_rec.card_seq_number;
    l_fin_rec.reconciliation_date     := null;
    l_fin_rec.rrn                     := nvl(l_fin_rec.rrn, l_pre_auth.network_refnum);

    l_fin_rec.merch_serv_charge       := 0;
    l_fin_rec.acq_msc_revenue         := 0;
    l_fin_rec.electr_comm_ind         := ' '; -- decode
    l_fin_rec.crdh_billing_amount     := 0;

    l_fin_rec.rate_loc_dst_currency   := 0;
    l_fin_rec.rate_dst_loc_currency   := com_api_rate_pkg.get_rate(
                                             i_src_currency      => l_fin_rec.oper_currency
                                           , i_dst_currency      => cst_bof_ghp_api_const_pkg.GHP_CURR_CODE
                                           , i_rate_type         => cst_bof_ghp_api_const_pkg.GHP_RATE_TYPE
                                           , i_inst_id           => l_fin_rec.inst_id
                                           , i_eff_date          => l_fin_rec.oper_date
                                           , i_mask_exception    => com_api_const_pkg.TRUE
                                           , i_exception_value   => 0
                                         );

    if  get_pos_entry_mode(i_card_data_input_mode => i_auth_rec.card_data_input_mode) in ('05', '07')
        and
        l_fin_rec.is_reversal = com_api_const_pkg.FALSE
    then
        emv_api_tag_pkg.parse_emv_data(
            i_emv_data    => i_auth_rec.emv_data
          , o_emv_tag_tab => l_emv_tag_tab
          , i_is_binary   => com_api_const_pkg.FALSE
        );

        l_fin_rec.cryptogram           := emv_api_tag_pkg.get_tag_value('9F26', l_emv_tag_tab, com_api_const_pkg.FALSE);
        l_fin_rec.cryptogram_info_data := emv_api_tag_pkg.get_tag_value('9F27', l_emv_tag_tab, com_api_const_pkg.FALSE);
        l_fin_rec.issuer_appl_data     := emv_api_tag_pkg.get_tag_value('9F10', l_emv_tag_tab, com_api_const_pkg.FALSE);
        l_fin_rec.unpredict_number     := emv_api_tag_pkg.get_tag_value('9F37', l_emv_tag_tab, com_api_const_pkg.FALSE);
        l_fin_rec.appl_trans_counter   := emv_api_tag_pkg.get_tag_value('9F36', l_emv_tag_tab, com_api_const_pkg.FALSE);
        l_fin_rec.term_verif_result    := emv_api_tag_pkg.get_tag_value('95',   l_emv_tag_tab, com_api_const_pkg.FALSE);
        begin
            l_fin_rec.trans_date :=
                to_date(
                    emv_api_tag_pkg.get_tag_value(
                        i_tag          => '9A'
                      , i_emv_tag_tab  => l_emv_tag_tab
                      , i_mask_error   => com_api_const_pkg.FALSE
                    )
                  , 'YYMMDD'
                );
        exception
            when com_api_error_pkg.e_application_error then
                raise;
            when others then
                com_api_error_pkg.raise_error(
                    i_error      => 'EMV_INCORRECT_DATE_FORMAT'
                  , i_env_param1 => '9A'
                  , i_env_param2 => emv_api_const_pkg.DATA_TYPE_DATE_NUMERIC
                );
        end;
        l_fin_rec.cryptogram_amount    := emv_api_tag_pkg.get_tag_value('9F02', l_emv_tag_tab, com_api_const_pkg.FALSE);
        l_fin_rec.trans_currency       :=
            nvl(
                emv_api_tag_pkg.get_tag_value(
                    i_tag          => '5F2E'
                  , i_emv_tag_tab  => l_emv_tag_tab
                  , i_mask_error   => com_api_const_pkg.TRUE
                )
              , l_fin_rec.oper_currency
            );
        l_fin_rec.appl_interch_profile := emv_api_tag_pkg.get_tag_value('82',   l_emv_tag_tab, com_api_const_pkg.FALSE);
        l_fin_rec.terminal_country     := emv_api_tag_pkg.get_tag_value('9F1A', l_emv_tag_tab, com_api_const_pkg.FALSE);
        l_fin_rec.cashback_amount      :=
            nvl(
                emv_api_tag_pkg.get_tag_value(
                    i_tag          => '9F03'
                  , i_emv_tag_tab  => l_emv_tag_tab
                  , i_mask_error   => com_api_const_pkg.TRUE
                )
              , 0
            );
        l_fin_rec.transaction_type_tcr3 :=
            emv_api_tag_pkg.get_tag_value(
                i_tag          => '9C'
              , i_emv_tag_tab  => l_emv_tag_tab
              , i_mask_error   => com_api_const_pkg.FALSE
            );
        l_fin_rec.crdh_verif_method    := emv_api_tag_pkg.get_tag_value('9F34', l_emv_tag_tab, com_api_const_pkg.FALSE);
        l_fin_rec.terminal_profile     := emv_api_tag_pkg.get_tag_value('9F33', l_emv_tag_tab, com_api_const_pkg.FALSE);
        l_fin_rec.terminal_type        := emv_api_tag_pkg.get_tag_value('9F35', l_emv_tag_tab, com_api_const_pkg.TRUE);
        l_fin_rec.trans_category_code  :=
            nvl(
                emv_api_tag_pkg.get_tag_value(
                    i_tag          => '9F53'
                  , i_emv_tag_tab  => l_emv_tag_tab
                  , i_mask_error   => com_api_const_pkg.TRUE
                )
              , chr(0)
            );
        l_fin_rec.trans_seq_number     := emv_api_tag_pkg.get_tag_value('9F41', l_emv_tag_tab, com_api_const_pkg.TRUE);
        l_fin_rec.iss_auth_data        := emv_api_tag_pkg.get_tag_value('91',   l_emv_tag_tab, com_api_const_pkg.TRUE);
        l_fin_rec.issuer_script_result := emv_api_tag_pkg.get_tag_value('9F5B', l_emv_tag_tab, com_api_const_pkg.TRUE);
    end if;

    l_fin_rec.host_inst_id := net_api_network_pkg.get_inst_id(l_fin_rec.network_id);

    if i_auth_rec.is_reversal = com_api_type_pkg.TRUE then
        update cst_bof_ghp_fin_msg
           set status = decode(
                            status
                          , net_api_const_pkg.CLEARING_MSG_STATUS_READY
                          , net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                          , status
                        )
         where id = i_auth_rec.original_id
     returning decode(
                   status
                 , net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                 , net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                 , net_api_const_pkg.CLEARING_MSG_STATUS_READY
               )
          into l_fin_rec.status;

        if sql%rowcount = 0 then
            com_api_error_pkg.raise_error(
                i_error       => 'FINANCIAL_MESSAGE_NOT_FOUND'
              , i_env_param1  => i_auth_rec.original_id
            );
        end if;

        l_fin_rec.status := nvl(l_fin_rec.status, net_api_const_pkg.CLEARING_MSG_STATUS_READY);
    end if;

    l_fin_rec.id := put_message(i_fin_rec => l_fin_rec);
end process_auth;

procedure create_operation(
    i_fin_rec              in     cst_bof_ghp_api_type_pkg.t_ghp_fin_mes_rec
  , i_standard_id          in     com_api_type_pkg.t_tiny_id
  , i_fee_rec              in     cst_bof_ghp_api_type_pkg.t_fee_rec            default null
  , i_status               in     com_api_type_pkg.t_dict_value                 default null
  , i_create_disp_case     in     com_api_type_pkg.t_boolean                    default com_api_const_pkg.FALSE
  , i_incom_sess_file_id   in     com_api_type_pkg.t_long_id                    default null
) is
    l_iss_inst_id                       com_api_type_pkg.t_inst_id;
    l_acq_inst_id                 com_api_type_pkg.t_inst_id;
    l_card_inst_id                com_api_type_pkg.t_inst_id;
    l_iss_network_id              com_api_type_pkg.t_network_id;
    l_acq_network_id              com_api_type_pkg.t_network_id;
    l_card_network_id             com_api_type_pkg.t_network_id;
    l_card_type_id                com_api_type_pkg.t_tiny_id;
    l_card_country                com_api_type_pkg.t_country_code;
    l_bin_currency                com_api_type_pkg.t_curr_code;
    l_sttl_currency               com_api_type_pkg.t_curr_code;
    l_country_code                com_api_type_pkg.t_country_code;
    l_sttl_type                   com_api_type_pkg.t_dict_value;
    l_match_status                com_api_type_pkg.t_dict_value;

    l_oper                        opr_api_type_pkg.t_oper_rec;
    l_iss_part                    opr_api_type_pkg.t_oper_part_rec;
    l_acq_part                    opr_api_type_pkg.t_oper_part_rec;

    l_operation                   opr_api_type_pkg.t_oper_rec;
    l_participant                 opr_api_type_pkg.t_oper_part_rec;
    l_need_sttl_type              com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    l_oper.id := i_fin_rec.id;
    if l_oper.id is null then
        l_oper.id := opr_api_create_pkg.get_id;
    end if;
    if i_status is not null then
        l_oper.status := i_status;
    end if;

    if  i_fin_rec.dispute_id is not null
     or i_fin_rec.is_reversal = com_api_type_pkg.TRUE
     and (i_fin_rec.is_incoming = com_api_const_pkg.FALSE
           or
          i_fee_rec.id is not null)
    then
        l_oper.original_id :=
            get_original_id(
                i_fin_rec => i_fin_rec
              , i_fee_rec => i_fee_rec
            );
        opr_api_operation_pkg.get_operation(
            i_oper_id   => l_oper.original_id
          , o_operation => l_operation
        );

        l_sttl_type := l_operation.sttl_type;

        opr_api_operation_pkg.get_participant(
            i_oper_id           => l_operation.id
          , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
          , o_participant       => l_participant
        );

        l_iss_inst_id         := l_participant.inst_id;
        l_iss_network_id      := l_participant.network_id;
        l_iss_part.split_hash := l_participant.split_hash;
        l_card_type_id        := l_participant.card_type_id;
        l_card_country        := l_participant.card_country;
        l_card_inst_id        := l_participant.card_inst_id;
        l_card_network_id     := l_participant.card_network_id;

        opr_api_operation_pkg.get_participant(
            i_oper_id           => l_operation.id
          , i_participaint_type => com_api_const_pkg.PARTICIPANT_ACQUIRER
          , o_participant       => l_participant
        );

        l_acq_inst_id          := l_participant.inst_id;
        l_acq_network_id       := l_participant.network_id;
        l_acq_part.merchant_id := l_participant.merchant_id;
        l_acq_part.terminal_id := l_participant.terminal_id;
        l_acq_part.split_hash  := l_participant.split_hash;

        l_oper.terminal_type   := l_operation.terminal_type;
    else
        iss_api_bin_pkg.get_bin_info(
            i_card_number      => i_fin_rec.card_number
          , o_iss_inst_id      => l_iss_inst_id
          , o_iss_network_id   => l_iss_network_id
          , o_card_inst_id     => l_card_inst_id
          , o_card_network_id  => l_card_network_id
          , o_card_type        => l_card_type_id
          , o_card_country     => l_country_code
          , o_bin_currency     => l_bin_currency
          , o_sttl_currency    => l_sttl_currency
        );

        if l_card_inst_id is null then
            l_iss_inst_id := i_fin_rec.inst_id;
            l_iss_network_id := ost_api_institution_pkg.get_inst_network(i_fin_rec.inst_id);
        end if;

        l_acq_network_id := i_fin_rec.network_id;
        l_acq_inst_id := net_api_network_pkg.get_inst_id(i_fin_rec.network_id);

        l_need_sttl_type := com_api_type_pkg.TRUE;
    end if;

    l_oper.oper_type :=
        case
            when i_fin_rec.trans_code in (cst_bof_ghp_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY
                                        , cst_bof_ghp_api_const_pkg.TC_FRAUD_ADVICE)
            then
                l_operation.oper_type
            when i_fin_rec.trans_code in (cst_bof_ghp_api_const_pkg.TC_FEE_COLLECTION
                                        , cst_bof_ghp_api_const_pkg.TC_FUNDS_DISBURSEMENT)
            then
                net_api_map_pkg.get_oper_type(
                    i_network_oper_type => i_fin_rec.trans_code || i_fee_rec.reason_code
                  , i_standard_id       => i_standard_id
                  , i_mask_error        => com_api_const_pkg.FALSE
                )
            else
                net_api_map_pkg.get_oper_type(
                    i_network_oper_type => i_fin_rec.trans_code || i_fin_rec.mcc
                  , i_standard_id       => i_standard_id
                  , i_mask_error        => com_api_const_pkg.FALSE
                )
        end;

    if l_need_sttl_type = com_api_type_pkg.TRUE then
        net_api_sttl_pkg.get_sttl_type(
            i_iss_inst_id      => l_iss_inst_id
          , i_acq_inst_id      => l_acq_inst_id
          , i_card_inst_id     => l_card_inst_id
          , i_iss_network_id   => l_iss_network_id
          , i_acq_network_id   => l_acq_network_id
          , i_card_network_id  => l_card_network_id
          , i_acq_inst_bin     => i_fin_rec.acq_inst_bin
          , o_sttl_type        => l_sttl_type
          , o_match_status     => l_match_status
          , i_oper_type        => l_oper.oper_type
        );
    end if;

    l_oper.sttl_type := l_sttl_type;
    l_oper.msg_type  := net_api_map_pkg.get_msg_type(
                            i_network_msg_type  => i_fin_rec.usage_code || i_fin_rec.trans_code
                          , i_standard_id       => i_standard_id
                          , i_mask_error        => com_api_const_pkg.FALSE
                        );

    l_oper.is_reversal        := i_fin_rec.is_reversal;
    l_oper.oper_amount        := i_fin_rec.oper_amount;
    l_oper.oper_currency      := i_fin_rec.oper_currency;
    l_oper.sttl_amount        := i_fin_rec.sttl_amount;
    l_oper.sttl_currency      := i_fin_rec.sttl_currency;
    l_oper.oper_date          := i_fin_rec.oper_date;
    l_oper.host_date          := null;

    if l_oper.terminal_type is null then
        l_oper.terminal_type :=
        case i_fin_rec.mcc
            when cst_bof_ghp_api_const_pkg.MCC_ATM
            then acq_api_const_pkg.TERMINAL_TYPE_ATM
            else acq_api_const_pkg.TERMINAL_TYPE_POS
        end;
    end if;

    l_oper.mcc                := i_fin_rec.mcc;
    l_oper.originator_refnum  := i_fin_rec.rrn;
    l_oper.acq_inst_bin       := i_fin_rec.acq_inst_bin;
    l_oper.terminal_number    := i_fin_rec.terminal_number;
    l_oper.merchant_number    := i_fin_rec.merchant_number;
    l_oper.merchant_name      := i_fin_rec.merchant_name;
    l_oper.merchant_city      := i_fin_rec.merchant_city;
    l_oper.merchant_country   := i_fin_rec.merchant_country;
    l_oper.dispute_id         := i_fin_rec.dispute_id;
    l_oper.match_status       := l_match_status;
    l_oper.original_id        := coalesce(l_oper.original_id, get_original_id(i_fin_rec => i_fin_rec));
    l_oper.incom_sess_file_id := i_incom_sess_file_id;

    if  i_fin_rec.trans_code in (cst_bof_ghp_api_const_pkg.TC_SALES
                               , cst_bof_ghp_api_const_pkg.TC_VOUCHER
                               , cst_bof_ghp_api_const_pkg.TC_CASH)
        and i_fin_rec.usage_code = com_api_type_pkg.TRUE
        and iss_api_card_pkg.get_card_id(i_card_number => i_fin_rec.card_number) is null
    then
        l_oper.proc_mode := aut_api_const_pkg.AUTH_PROC_MODE_CARD_ABSENT;
        l_oper.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
        trc_log_pkg.warn(
            i_text         => 'CARD_NOT_FOUND'
          , i_env_param1   => iss_api_card_pkg.get_card_mask(i_fin_rec.card_number)
          , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id    => l_oper.id
        );
    end if;

    l_iss_part.inst_id         := l_iss_inst_id;
    l_iss_part.network_id      := l_iss_network_id;
    l_iss_part.client_id_type  := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
    l_iss_part.client_id_value := i_fin_rec.card_number;
    l_iss_part.customer_id     := iss_api_card_pkg.get_customer_id(i_card_number => i_fin_rec.card_number);
    l_iss_part.card_id         := i_fin_rec.card_id;
    l_iss_part.card_type_id    := l_card_type_id;

    if nvl(i_fin_rec.card_expir_date, '*') = '0000' then
        begin
            select expir_date
              into l_iss_part.card_expir_date
              from (select i.expir_date
                      from iss_card_vw c
                         , iss_card_instance i
                     where c.id = i_fin_rec.card_id
                       and c.id = i.card_id
                  order by i.seq_number desc
           ) where rownum = 1;
        exception
            when no_data_found then
                l_iss_part.card_expir_date := null;
        end;
    else
        begin
            l_iss_part.card_expir_date := to_date(i_fin_rec.card_expir_date, 'MMYY');
        exception
            when others then
                trc_log_pkg.debug(
                    i_text         => 'Wrong date format for i_fin_rec.card_expir_date [#1]'
                  , i_env_param1   => i_fin_rec.card_expir_date
                  , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  , i_object_id    => l_oper.id
                );
                raise;
        end;
    end if;

    l_iss_part.card_seq_number   := trim(i_fin_rec.card_seq_number);
    l_iss_part.card_number       := i_fin_rec.card_number;
    l_iss_part.card_mask         := i_fin_rec.card_mask;
    l_iss_part.card_country      := l_card_country;
    l_iss_part.card_inst_id      := l_card_inst_id;
    l_iss_part.card_network_id   := l_card_network_id;
    l_iss_part.account_id        := null;
    l_iss_part.account_number    := null;
    l_iss_part.account_amount    := null;
    l_iss_part.account_currency  := null;
    l_iss_part.auth_code         := i_fin_rec.auth_code;

    l_acq_part.inst_id           := l_acq_inst_id;
    l_acq_part.network_id        := l_acq_network_id;

    opr_api_create_pkg.create_operation(
        i_oper      => l_oper
      , i_iss_part  => l_iss_part
      , i_acq_part  => l_acq_part
    );
end create_operation;

function put_message(
    i_fin_rec              in     cst_bof_ghp_api_type_pkg.t_ghp_fin_mes_rec
) return com_api_type_pkg.t_long_id
is
    l_id                          com_api_type_pkg.t_long_id;
begin
    l_id := coalesce(i_fin_rec.id, opr_api_create_pkg.get_id);

    insert into cst_bof_ghp_fin_msg(
        id
      , status
      , file_id
      , record_number
      , is_reversal
      , is_incoming
      , is_returned
      , is_invalid
      , dispute_id
      , rrn
      , inst_id
      , network_id
      , trans_code
      , card_id
      , card_mask
      , card_hash
      , oper_amount
      , oper_currency
      , oper_date
      , sttl_amount
      , sttl_currency
      , arn
      , merchant_number
      , merchant_name
      , merchant_city
      , merchant_country
      , merchant_region
      , merchant_type
      , mcc
      , usage_code
      , reason_code
      , auth_code
      , crdh_id_method
      , chargeback_ref_num
      , docum_ind
      , member_msg_text
      , spec_cond_ind
      , terminal_number
      , electr_comm_ind
      , spec_chargeback_ind
      , account_selection
      , transaction_type
      , card_seq_number
      , terminal_profile
      , unpredict_number
      , appl_trans_counter
      , appl_interch_profile
      , cryptogram
      , term_verif_result
      , cryptogram_amount
      , issuer_appl_data
      , issuer_script_result
      , card_expir_date
      , cryptogram_info_data
      , acq_inst_bin
      , host_inst_id
      , proc_bin
      , terminal_country
      , electronic_term_ind
      , reconciliation_ind
      , payment_product_ind
      , crdh_cardnum_cap_ind
      , trans_status
      , trans_code_header
      , auth_code_src_ind
      , forw_inst_id
      , void_ind
      , receiv_inst_id
      , dest_amount
      , dest_currency
      , iss_reimb_fee
      , value_date
      , trans_inter_proc_date
      , voucher_dep_bank_code
      , voucher_dep_branch_code
      , reconciliation_date
      , merch_serv_charge
      , acq_msc_revenue
      , crdh_billing_amount
      , trans_date
      , cashback_amount
      , crdh_verif_method
      , terminal_type
      , trans_category_code
      , trans_seq_number
      , transaction_type_tcr3
      , iss_auth_data
      , rate_dst_loc_currency
      , rate_loc_dst_currency
      , trans_currency
      , logical_file
    ) values (
        i_fin_rec.id
      , i_fin_rec.status
      , i_fin_rec.file_id
      , i_fin_rec.record_number
      , i_fin_rec.is_reversal
      , i_fin_rec.is_incoming
      , i_fin_rec.is_returned
      , i_fin_rec.is_invalid
      , i_fin_rec.dispute_id
      , i_fin_rec.rrn
      , i_fin_rec.inst_id
      , i_fin_rec.network_id
      , i_fin_rec.trans_code
      , i_fin_rec.card_id
      , i_fin_rec.card_mask
      , i_fin_rec.card_hash
      , i_fin_rec.oper_amount
      , i_fin_rec.oper_currency
      , i_fin_rec.oper_date
      , i_fin_rec.sttl_amount
      , i_fin_rec.sttl_currency
      , i_fin_rec.arn
      , i_fin_rec.merchant_number
      , i_fin_rec.merchant_name
      , i_fin_rec.merchant_city
      , i_fin_rec.merchant_country
      , i_fin_rec.merchant_region
      , i_fin_rec.merchant_type
      , i_fin_rec.mcc
      , i_fin_rec.usage_code
      , i_fin_rec.reason_code
      , i_fin_rec.auth_code
      , i_fin_rec.crdh_id_method
      , i_fin_rec.chargeback_ref_num
      , i_fin_rec.docum_ind
      , i_fin_rec.member_msg_text
      , i_fin_rec.spec_cond_ind
      , i_fin_rec.terminal_number
      , i_fin_rec.electr_comm_ind
      , i_fin_rec.spec_chargeback_ind
      , i_fin_rec.account_selection
      , i_fin_rec.transaction_type
      , i_fin_rec.card_seq_number
      , i_fin_rec.terminal_profile
      , i_fin_rec.unpredict_number
      , i_fin_rec.appl_trans_counter
      , i_fin_rec.appl_interch_profile
      , i_fin_rec.cryptogram
      , i_fin_rec.term_verif_result
      , i_fin_rec.cryptogram_amount
      , i_fin_rec.issuer_appl_data
      , i_fin_rec.issuer_script_result
      , i_fin_rec.card_expir_date
      , i_fin_rec.cryptogram_info_data
      , i_fin_rec.acq_inst_bin
      , i_fin_rec.host_inst_id
      , i_fin_rec.proc_bin
      , i_fin_rec.terminal_country
      , i_fin_rec.electronic_term_ind
      , i_fin_rec.reconciliation_ind
      , i_fin_rec.payment_product_ind
      , i_fin_rec.crdh_cardnum_cap_ind
      , i_fin_rec.trans_status
      , i_fin_rec.trans_code_header
      , i_fin_rec.auth_code_src_ind
      , i_fin_rec.forw_inst_id
      , i_fin_rec.void_ind
      , i_fin_rec.receiv_inst_id
      , i_fin_rec.dest_amount
      , i_fin_rec.dest_currency
      , i_fin_rec.iss_reimb_fee
      , i_fin_rec.value_date
      , i_fin_rec.trans_inter_proc_date
      , i_fin_rec.voucher_dep_bank_code
      , i_fin_rec.voucher_dep_branch_code
      , i_fin_rec.reconciliation_date
      , i_fin_rec.merch_serv_charge
      , i_fin_rec.acq_msc_revenue
      , i_fin_rec.crdh_billing_amount
      , i_fin_rec.trans_date
      , i_fin_rec.cashback_amount
      , i_fin_rec.crdh_verif_method
      , i_fin_rec.terminal_type
      , i_fin_rec.trans_category_code
      , i_fin_rec.trans_seq_number
      , i_fin_rec.transaction_type_tcr3
      , i_fin_rec.iss_auth_data
      , i_fin_rec.rate_dst_loc_currency
      , i_fin_rec.rate_loc_dst_currency
      , i_fin_rec.trans_currency
      , i_fin_rec.logical_file
    );

    insert into cst_bof_ghp_card(
        id
      , card_number
    ) values (
        l_id
      , iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.card_number)
    );

    trc_log_pkg.debug(
        i_text        => 'put_message >> fin. message ID [#1]'
      , i_env_param1  => l_id
    );

    return l_id;
end;

procedure put_retrieval(
    i_retrieval_rec        in     cst_bof_ghp_api_type_pkg.t_retrieval_rec
) is
    l_id                          com_api_type_pkg.t_long_id;
begin
    l_id := coalesce(i_retrieval_rec.id, opr_api_create_pkg.get_id);

    insert into cst_bof_ghp_retrieval(
        id
      , file_id
      , iss_inst_id
      , acq_inst_id
      , document_type
      , card_iss_ref_num
      , cancellation_ind
      , potential_chback_reason_code
      , response_type
    )
    values (
        l_id
      , i_retrieval_rec.file_id
      , i_retrieval_rec.iss_inst_id
      , i_retrieval_rec.acq_inst_id
      , i_retrieval_rec.document_type
      , i_retrieval_rec.card_iss_ref_num
      , i_retrieval_rec.cancellation_ind
      , i_retrieval_rec.potential_chback_reason_code
      , i_retrieval_rec.response_type
    );

    trc_log_pkg.debug(
        i_text        => 'put_retrieval >> retrieval request ID [#1]'
      , i_env_param1  => l_id
    );
end put_retrieval;

procedure put_fee(
    i_fee_rec              in     cst_bof_ghp_api_type_pkg.t_fee_rec
) is
    l_id                          com_api_type_pkg.t_long_id;
begin
    l_id := coalesce(i_fee_rec.id, opr_api_create_pkg.get_id);

    insert into cst_bof_ghp_fee (
        id
      , file_id
      , fee_type_ind
      , forw_inst_country_code
      , reason_code
      , collection_branch_code
      , trans_count
      , unit_fee
      , event_date
      , source_amount_cfa
      , control_number
      , message_text
    )
    values (
        l_id
      , i_fee_rec.file_id
      , i_fee_rec.fee_type_ind
      , i_fee_rec.forw_inst_country_code
      , i_fee_rec.reason_code
      , i_fee_rec.collection_branch_code
      , i_fee_rec.trans_count
      , i_fee_rec.unit_fee
      , i_fee_rec.event_date
      , i_fee_rec.source_amount_cfa
      , i_fee_rec.control_number
      , i_fee_rec.message_text
    );

    trc_log_pkg.debug(
        i_text        => 'put_fee >> fee collection/funds disbursement ID [#1]'
      , i_env_param1  => l_id
    );
end put_fee;

procedure put_fraud(
    i_fraud_rec            in     cst_bof_ghp_api_type_pkg.t_fraud_rec
) is
    l_id                          com_api_type_pkg.t_long_id;
begin
    l_id := coalesce(i_fraud_rec.id, opr_api_create_pkg.get_id());

    insert into cst_bof_ghp_fin_msg(
        id
      , status
      , file_id
      , record_number
      , is_reversal
      , is_incoming
      , is_returned
      , is_invalid
      , dispute_id
      , inst_id
      , network_id
      , host_inst_id
      , trans_code
      , card_id
      , card_mask
      , card_hash
      , arn
      , merchant_name
      , merchant_city
      , merchant_country
      , merchant_region
      , mcc
      , forw_inst_id
      , receiv_inst_id
      , logical_file
    ) values (
        l_id
      , i_fraud_rec.status
      , i_fraud_rec.file_id
      , i_fraud_rec.record_number
      , com_api_const_pkg.FALSE
      , i_fraud_rec.is_incoming
      , com_api_const_pkg.FALSE
      , i_fraud_rec.is_invalid
      , i_fraud_rec.dispute_id
      , i_fraud_rec.inst_id
      , i_fraud_rec.network_id
      , i_fraud_rec.host_inst_id
      , cst_bof_ghp_api_const_pkg.TC_FRAUD_ADVICE
      , i_fraud_rec.card_id
      , i_fraud_rec.card_mask
      , i_fraud_rec.card_hash
      , i_fraud_rec.arn
      , i_fraud_rec.merchant_name
      , i_fraud_rec.merchant_city
      , i_fraud_rec.merchant_country
      , i_fraud_rec.merchant_region
      , i_fraud_rec.mcc
      , i_fraud_rec.forw_inst_id
      , i_fraud_rec.receiv_inst_id
      , i_fraud_rec.logical_file
    );

    insert into cst_bof_ghp_fraud(
        id
      , fraud_amount
      , fraud_currency
      , vic_processing_date
      , notification_code
      , account_seq_number
      , insurance_year
      , fraud_type
      , card_expir_date
      , debit_credit_indicator
      , trans_generation_method
    )
    values (
        l_id
      , i_fraud_rec.fraud_amount
      , i_fraud_rec.fraud_currency
      , i_fraud_rec.vic_processing_date
      , i_fraud_rec.notification_code
      , i_fraud_rec.account_seq_number
      , i_fraud_rec.insurance_year
      , i_fraud_rec.fraud_type
      , i_fraud_rec.card_expir_date
      , i_fraud_rec.debit_credit_indicator
      , i_fraud_rec.trans_generation_method
    );

    if i_fraud_rec.card_number is not null then
        insert into cst_bof_ghp_card(
            id
          , card_number
        ) values (
            l_id
          , iss_api_token_pkg.encode_card_number(i_card_number => i_fraud_rec.card_number)
        );
    end if;

    trc_log_pkg.debug(
        i_text        => 'put_fraud >> fraud advice ID [#1]'
      , i_env_param1  => l_id
    );
end put_fraud;

end;
/
