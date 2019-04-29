create or replace package body cst_ap_tp_load_pkg is
/************************************************************
 * Processes for loading TP files <br />
 * Created by Vasilyeva Y.(vasilieva@bpcbt.com)  at 25.02.2019 <br />
 * Last changed by $Author: Vasilyeva Y. $ <br />
 * $LastChangedDate:: #$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: cst_smt_prc_incoming_pkg <br />
 * @headcom
 ***********************************************************/
function get_merchant_id(
    i_merchant_number       in      com_api_type_pkg.t_merchant_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_short_id is
    l_result                com_api_type_pkg.t_merchant_number;
begin
    select m.id
      into l_result
      from acq_merchant m
     where m.merchant_number = i_merchant_number
       and m.inst_id         = i_inst_id;

    return l_result;
exception
    when no_data_found then
        return null;
end;

function get_mcc( --Aks
    i_merchant_number       in      com_api_type_pkg.t_merchant_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_tiny_id is
    l_result                com_api_type_pkg.t_mcc;
begin
    select m.mcc
      into l_result
      from acq_merchant m
     where m.merchant_number = i_merchant_number
       and m.inst_id         = i_inst_id;

    return l_result;
exception
    when no_data_found then
        return null;
end;

function get_terminal_id(
    i_terminal_number       in      com_api_type_pkg.t_terminal_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_short_id is
    l_result                com_api_type_pkg.t_merchant_number;
begin
    select m.id
      into l_result
      from acq_terminal m
     where m.terminal_number = i_terminal_number
       and m.inst_id         = i_inst_id;

    return l_result;
exception
    when no_data_found then
        return null;
end;

function get_date_from_filename(
    i_file_name in  com_api_type_pkg.t_name
) return date is
    l_datettime   date;
begin
    select to_date(substr(i_file_name, 9),'yyyymmddhh24mi')
    into l_datettime
    from dual;
    return l_datettime;
exception
    when others then
        return null;
end;

procedure insert_tag(
    i_auth_id   in  com_api_type_pkg.t_long_id
  , i_tags      in  cst_ap_api_type_pkg.t_aup_tag_tab
) is
begin
    forall i in 1 .. i_tags.count()
        insert into aup_tag_value(
            auth_id
          , tag_id
          , tag_value
        )
        values (
            i_auth_id
          , i_tags(i).tag_id
          , i_tags(i).tag_value
        );
end insert_tag;

function format_tag_value (
    i_tag_value         in com_api_type_pkg.t_name
) return com_api_type_pkg.t_name
is
    l_tag_length        pls_integer := 0;
    l_tag_value         com_api_type_pkg.t_name;
begin
    l_tag_value  := i_tag_value;
    l_tag_length := length(l_tag_value);

    if mod(l_tag_length, 2) > 0 then

        l_tag_value  := '0' || l_tag_value;
        l_tag_length := l_tag_length + 1;
    end if;

    l_tag_value := prs_api_util_pkg.ber_tlv_length(l_tag_value) || l_tag_value;

    return l_tag_value;
end;


procedure put_auth_data(
    i_auth_data    in aut_api_type_pkg.t_auth_rec
)
is

    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.put_auth_data: ';

begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START for oper_id[' || i_auth_data.id || ']'
    );

    insert into aut_auth (
        id
      , resp_code
      , proc_type
      , proc_mode
      , is_advice
      , is_repeat
      , bin_amount
      , bin_currency
      , bin_cnvt_rate
      , network_amount
      , network_currency
      , network_cnvt_date
      , network_cnvt_rate
      , account_cnvt_rate
      , parent_id
      , addr_verif_result
      , iss_network_device_id
      , acq_device_id
      , acq_resp_code
      , acq_device_proc_result
      , cat_level
      , card_data_input_cap
      , crdh_auth_cap
      , card_capture_cap
      , terminal_operating_env
      , crdh_presence
      , card_presence
      , card_data_input_mode
      , crdh_auth_method
      , crdh_auth_entity
      , card_data_output_cap
      , terminal_output_cap
      , pin_capture_cap
      , pin_presence
      , cvv2_presence
      , cvc_indicator
      , pos_entry_mode
      , pos_cond_code
      , emv_data
      , atc
      , tvr
      , cvr
      , addl_data
      , service_code
      , device_date
      , cvv2_result
      , certificate_method
      , certificate_type
      , merchant_certif
      , cardholder_certif
      , ucaf_indicator
      , is_early_emv
      , is_completed
      , amounts
      , cavv_presence
      , aav_presence
      , system_trace_audit_number
      , transaction_id
      , external_auth_id
      , external_orig_id
      , agent_unique_id
      , native_resp_code
      , trace_number
      , auth_purpose_id
     ) values (
        i_auth_data.id
      , i_auth_data.resp_code
      , i_auth_data.proc_type
      , i_auth_data.proc_mode
      , i_auth_data.is_advice
      , i_auth_data.is_repeat
      , i_auth_data.bin_amount
      , i_auth_data.bin_currency
      , i_auth_data.bin_cnvt_rate
      , i_auth_data.network_amount
      , i_auth_data.network_currency
      , i_auth_data.network_cnvt_date
      , i_auth_data.network_cnvt_rate
      , i_auth_data.account_cnvt_rate
      , i_auth_data.parent_id
      , i_auth_data.addr_verif_result
      , i_auth_data.iss_network_device_id
      , i_auth_data.acq_device_id
      , i_auth_data.acq_resp_code
      , i_auth_data.acq_device_proc_result
      , i_auth_data.cat_level
      , i_auth_data.card_data_input_cap
      , i_auth_data.crdh_auth_cap
      , i_auth_data.card_capture_cap
      , i_auth_data.terminal_operating_env
      , i_auth_data.crdh_presence
      , i_auth_data.card_presence
      , i_auth_data.card_data_input_mode
      , i_auth_data.crdh_auth_method
      , i_auth_data.crdh_auth_entity
      , i_auth_data.card_data_output_cap
      , i_auth_data.terminal_output_cap
      , i_auth_data.pin_capture_cap
      , i_auth_data.pin_presence
      , i_auth_data.cvv2_presence
      , i_auth_data.cvc_indicator
      , i_auth_data.pos_entry_mode
      , i_auth_data.pos_cond_code
      , i_auth_data.emv_data
      , i_auth_data.atc
      , i_auth_data.tvr
      , i_auth_data.cvr
      , i_auth_data.addl_data
      , i_auth_data.service_code
      , i_auth_data.device_date
      , i_auth_data.cvv2_result
      , i_auth_data.certificate_method
      , i_auth_data.certificate_type
      , i_auth_data.merchant_certif
      , i_auth_data.cardholder_certif
      , i_auth_data.ucaf_indicator
      , i_auth_data.is_early_emv
      , i_auth_data.is_completed
      , i_auth_data.amounts
      , i_auth_data.cavv_presence
      , i_auth_data.aav_presence
      , i_auth_data.system_trace_audit_number
      , i_auth_data.transaction_id
      , i_auth_data.external_auth_id
      , i_auth_data.external_orig_id
      , i_auth_data.agent_unique_id
      , i_auth_data.native_resp_code
      , i_auth_data.trace_number
      , i_auth_data.auth_purpose_id
    );

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'FINISH for oper_id[' || i_auth_data.id || ']'
    );

exception
    when dup_val_on_index then
           /* com_api_error_pkg.raise_error(
                i_error      => 'DUPLICATE_AUTH_DATA'
              , i_env_param1 => i_auth_data.id
            );*/
        trc_log_pkg.error(
            i_text => LOG_PREFIX || 'DUPLICATE AUTH_DATA[' || i_auth_data.id || ']'
        );
    when others then
        /*com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );*/
        trc_log_pkg.error(
            i_text => LOG_PREFIX || 'UNHANDLED_EXCEPTION[' || sqlerrm || ']'
        );
end put_auth_data;

procedure process_record(
    i_rec                   in com_api_type_pkg.t_text
  , i_row_number            in com_api_type_pkg.t_count
  , i_incom_sess_file_id    in com_api_type_pkg.t_long_id
  , i_file_name             in com_api_type_pkg.t_name
  , o_processed             out com_api_type_pkg.t_boolean
  , o_excepted              out com_api_type_pkg.t_boolean
  , o_raised                out com_api_type_pkg.t_boolean
)
is
    LOG_PREFIX          constant com_api_type_pkg.t_name   := lower($$PLSQL_UNIT) || '.process_record: ';
    l_tp_rec                     cst_ap_api_type_pkg.t_tp_rec;
    l_opr_operation_rec          opr_api_type_pkg.t_oper_rec;
    l_opr_acq_participant_rec    opr_api_type_pkg.t_oper_part_rec;
    l_opr_iss_participant_rec    opr_api_type_pkg.t_oper_part_rec;
    l_opr_card                   cst_ap_api_type_pkg.t_opr_card_rec;
    l_sysdate                    date;
    l_aup_tag_value_rec          cst_ap_api_type_pkg.t_aup_tag_rec;
    l_aup_tags_tab               cst_ap_api_type_pkg.t_aup_tag_tab;
    l_inst_id                    com_api_type_pkg.t_inst_id;
    i                            com_api_type_pkg.t_short_id;
    l_emv_tags_tab               com_api_type_pkg.t_tag_value_tab;
	l_idx_tag                    com_api_type_pkg.t_tag;
    l_emv_data                   com_api_type_pkg.t_full_desc;
    l_auth                       aut_api_type_pkg.t_auth_rec;
    l_check_duplicate            com_api_type_pkg.t_sign;

    procedure add_to_aup_tags_tab(
        i_tag_id    in com_api_type_pkg.t_short_id
      , i_tag_value in com_api_type_pkg.t_full_desc
    ) is
    begin
        if i_tag_value is not null and i_tag_id is not null then
            i:=i+1;
            l_aup_tags_tab(i).tag_value := i_tag_value;
            l_aup_tags_tab(i).tag_id := i_tag_id;
        end if;
    end;

/*    procedure add_to_emv_tags_tab(
        i_tag_id    in com_api_type_pkg.t_name
      , i_tag_value in com_api_type_pkg.t_param_value
    ) is
    begin
        if i_tag_value is not null and i_tag_id is not null then
            l_emv_tags_tab(i_tag_id) := i_tag_value;
        end if;
    end;*/

begin
    o_excepted := 0;
    o_raised   := 0;
    l_tp_rec.ch_cr_dr                := substr(i_rec, 1, 1);
    l_tp_rec.bin                     := substr(i_rec, 2, 6);
    l_tp_rec.iss_bank_code           := substr(i_rec, 8, 3);
    l_tp_rec.acch_acc_number         := substr(i_rec, 11, 20);
    l_tp_rec.acch_card_number        := trim(substr(i_rec, 31, 19));
    l_tp_rec.mrc_cr_dr               := substr(i_rec, 50, 1);
    l_tp_rec.mrc_acc_number          := trim(substr(i_rec, 51, 20));
    l_tp_rec.acq_bin                 := substr(i_rec, 71, 6);
    l_tp_rec.bank_acq_code           := substr(i_rec, 77, 3);
    l_tp_rec.code_trading_merch      := substr(i_rec, 80, 5);
    l_tp_rec.terminal_number         := substr(i_rec, 85, 15);
    l_tp_rec.merchant_number         := substr(i_rec, 100, 15);
    l_tp_rec.transaction_type        := substr(i_rec, 115, 3);
    l_tp_rec.transaction_date        := substr(i_rec, 118, 8);
    l_tp_rec.transaction_time        := substr(i_rec, 126, 6);
    l_tp_rec.transaction_amount      := substr(i_rec, 132, 15);
    l_tp_rec.invoice_number          := substr(i_rec, 147, 15);
    l_tp_rec.issuer_invoice          := substr(i_rec, 162, 20);
    l_tp_rec.client_id               := substr(i_rec, 182, 20);
    l_tp_rec.tran_ref_number         := substr(i_rec, 202, 12);
    l_tp_rec.auth_number             := substr(i_rec, 214, 15);
    l_tp_rec.cr_dr_ch_fee            := substr(i_rec, 229, 1);
    l_tp_rec.acch_fee                := to_number(substr(i_rec, 230, 12)) * 100;
    l_tp_rec.cr_dr_mrc_fee           := substr(i_rec, 242, 1);
    l_tp_rec.mrc_fee                 := to_number(substr(i_rec, 243, 12)) * 100;
    l_tp_rec.inter_fee               := to_number(substr(i_rec, 255, 12)) * 100;
    l_tp_rec.tech_fee                := to_number(substr(i_rec, 267, 12)) * 100;
    l_tp_rec.l_emv_9f26_qarqc        := substr(i_rec, 279, 16);
    l_tp_rec.l_emv_9F27_crypto       := substr(i_rec, 295, 2);
    l_tp_rec.l_emv_9F36_trn_count    := substr(i_rec, 297, 4);
    l_tp_rec.l_emv_95_term_verif     := substr(i_rec, 301, 10);
    l_tp_rec.merchant_name           := substr(i_rec, 311, 40);
    l_tp_rec.ruf_emv                 := substr(i_rec, 351, 60);
    l_tp_rec.refnum                  := substr(i_rec, 411, 12);
    l_tp_rec.udf1                    := substr(i_rec, 423, 20);
    l_tp_rec.ruf_acq                 := substr(i_rec, 443, 18);

    -- Check duplicate
    select count(1)
      into l_check_duplicate
      from aut_auth aa
         , opr_operation o
     where aa.external_auth_id = l_tp_rec.tran_ref_number
       and o.id                = aa.id
       and o.status           != opr_api_const_pkg.OPERATION_STATUS_DUPLICATE
       and rownum              = 1;
    if l_check_duplicate = com_api_const_pkg.true then
        trc_log_pkg.warn(
            i_text       => 'DUPLICATE_OPERATION'
          , i_env_param1 => l_tp_rec.tran_ref_number
        );
        o_excepted := 1;
    else

        l_opr_operation_rec.terminal_number        := trim(l_tp_rec.terminal_number);
        l_opr_operation_rec.merchant_number        := trim(l_tp_rec.merchant_number);

        if l_tp_rec.transaction_type in ('052', '053', '055', '056') then --Transaction data for purchase (in case of e-commerce)
            l_tp_rec.refnum_refund           := substr(i_rec, 461, 20);
            l_tp_rec.track_id                := substr(i_rec, 481, 10);
            l_tp_rec.tran_num_purch_internet := substr(i_rec, 491, 20);
            l_tp_rec.ruf_ecom                := substr(i_rec, 511, 18);
        elsif l_tp_rec.transaction_type in ('040', '014') then --Transaction data for withdrawal (in case of ATM)
            l_tp_rec.atm_loc                 := substr(i_rec, 461, 40);
            l_tp_rec.atm_connex              := substr(i_rec, 501, 10);
            l_tp_rec.ruf_atm                 := substr(i_rec, 511, 18);
            --find merchant by terminal for ATM only
            begin
                select min(m.merchant_number)
                  into l_opr_operation_rec.merchant_number
                  from acq_terminal t
            inner join acq_merchant m on t.merchant_id = m.id
                 where trim(t.terminal_number) = trim(l_tp_rec.terminal_number);
            exception
                when others then
                    trc_log_pkg.debug(
                        i_text => LOG_PREFIX || 'No mercant is found for terminal ' || l_tp_rec.terminal_number || ']'
                    );
            end;
        end if;
        trc_log_pkg.debug('1');
        select sysdate
          into l_sysdate
          from dual;

        select opr_api_create_pkg.get_id
          into l_opr_card.oper_id
          from dual;

        l_opr_card.card_number                     := l_tp_rec.acch_card_number;
        l_opr_card.participant_type                := com_api_const_pkg.PARTICIPANT_ISSUER; --'PRTYISS'

        l_opr_iss_participant_rec.oper_id          := l_opr_card.oper_id;
        l_opr_iss_participant_rec.participant_type := com_api_const_pkg.PARTICIPANT_ISSUER; --'PRTYISS'
        l_opr_iss_participant_rec.auth_code        := to_number(l_tp_rec.auth_number);
        l_opr_iss_participant_rec.card_number      := l_tp_rec.acch_card_number;
        l_opr_iss_participant_rec.network_id       := cst_ap_api_const_pkg.NETWORK_ID;
        l_opr_iss_participant_rec.client_id_type   := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
        l_opr_iss_participant_rec.customer_id      := iss_api_card_pkg.get_customer_id(l_tp_rec.acch_card_number);

        l_opr_acq_participant_rec.oper_id          := l_opr_card.oper_id;
        l_opr_acq_participant_rec.participant_type := com_api_const_pkg.PARTICIPANT_ACQUIRER; --'PRTYACQ'
        l_opr_acq_participant_rec.card_number      := l_tp_rec.acch_card_number;
        l_opr_acq_participant_rec.network_id       := cst_ap_api_const_pkg.NETWORK_ID;
        l_opr_acq_participant_rec.client_id_type   := opr_api_const_pkg.CLIENT_ID_TYPE_TERMINAL;

        l_opr_operation_rec.id                     := l_opr_card.oper_id;
        l_opr_operation_rec.incom_sess_file_id     := i_incom_sess_file_id;
        l_opr_operation_rec.host_date              := nvl(get_date_from_filename(i_file_name), to_date(l_tp_rec.transaction_date||l_tp_rec.transaction_time,'yyyymmddhh24miss'));
        l_opr_operation_rec.oper_amount            := to_number(l_tp_rec.transaction_amount)*100;
        l_opr_operation_rec.merchant_name          := trim(l_tp_rec.merchant_name); -- Aks
        l_opr_operation_rec.originator_refnum      := l_tp_rec.refnum;
        l_opr_operation_rec.is_reversal            := com_api_const_pkg.FALSE;
        l_opr_operation_rec.msg_type               := opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT;  -- 'MSGTPRES'
        l_opr_operation_rec.status                 := opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY; -- OPST0100
        l_opr_operation_rec.oper_currency          := cst_ap_api_const_pkg.CURRENCY_TP;
        l_opr_operation_rec.sttl_date              := l_sysdate;
        l_opr_operation_rec.match_status           := cst_ap_api_const_pkg.STATUS_TP_FILE_LOADED;

        case
        when l_tp_rec.transaction_type = '002' then
             l_opr_operation_rec.oper_type := opr_api_const_pkg.OPERATION_TYPE_POS_CASH; --'OPTP0012'
             l_opr_operation_rec.terminal_type := acq_api_const_pkg.TERMINAL_TYPE_POS; --'TRMT0003'
        when l_tp_rec.transaction_type = '005' then
             l_opr_operation_rec.oper_type := opr_api_const_pkg.OPERATION_TYPE_PAYMENT; --'OPTP0028'
             l_opr_operation_rec.terminal_type := acq_api_const_pkg.TERMINAL_TYPE_POS; --'TRMT0003'
        when l_tp_rec.transaction_type = '014' then
             l_opr_operation_rec.oper_type := opr_api_const_pkg.OPERATION_TYPE_BALANCE_INQUIRY; --'OPTP0012'
             l_opr_operation_rec.terminal_type := acq_api_const_pkg.TERMINAL_TYPE_ATM; --'TRMT0002'
        when l_tp_rec.transaction_type = '040' then
             l_opr_operation_rec.oper_type := opr_api_const_pkg.OPERATION_TYPE_ATM_CASH; --'OPTP0001'
             l_opr_operation_rec.terminal_type := acq_api_const_pkg.TERMINAL_TYPE_ATM; --'TRMT0002'
        when l_tp_rec.transaction_type = '050' then
             l_opr_operation_rec.oper_type := opr_api_const_pkg.OPERATION_TYPE_PURCHASE; --'OPTP0000'
             l_opr_operation_rec.terminal_type := acq_api_const_pkg.TERMINAL_TYPE_POS; --'TRMT0003'
        when l_tp_rec.transaction_type = '051' then
             l_opr_operation_rec.oper_type := opr_api_const_pkg.OPERATION_TYPE_REFUND; --'OPTP0020'
             l_opr_operation_rec.terminal_type := acq_api_const_pkg.TERMINAL_TYPE_POS; --'TRMT0003'
        when l_tp_rec.transaction_type = '052' then
             l_opr_operation_rec.oper_type := opr_api_const_pkg.OPERATION_TYPE_PURCHASE; --'OPTP0000'
             l_opr_operation_rec.terminal_type := acq_api_const_pkg.TERMINAL_TYPE_EPOS; --'TRMT0004'
        when l_tp_rec.transaction_type = '053' then
             l_opr_operation_rec.oper_type := opr_api_const_pkg.OPERATION_TYPE_PAYMENT; --'OPTP0028'
             l_opr_operation_rec.terminal_type := acq_api_const_pkg.TERMINAL_TYPE_EPOS; --'TRMT0004'
        when l_tp_rec.transaction_type = '054' then
             l_opr_operation_rec.oper_type := cst_ap_api_const_pkg.OPERATION_TYPE_CUSTOMS_PAYMENT; --'OPTP5001'
             l_opr_operation_rec.terminal_type := acq_api_const_pkg.TERMINAL_TYPE_POS; --'TRMT0003'
        when l_tp_rec.transaction_type = '055' then
             l_opr_operation_rec.oper_type := opr_api_const_pkg.OPERATION_TYPE_REFUND; --'OPTP0020'
             l_opr_operation_rec.terminal_type := acq_api_const_pkg.TERMINAL_TYPE_EPOS; --'TRMT0004'
        when l_tp_rec.transaction_type = '056' then
             l_opr_operation_rec.oper_type := cst_ap_api_const_pkg.OPERATION_TYPE_CUSTOMS_PAYMENT; --'OPTP5001'
             l_opr_operation_rec.terminal_type := acq_api_const_pkg.TERMINAL_TYPE_EPOS; --'TRMT0004'
        end case;

        begin
            select inst_id
              into l_inst_id
              from iss_bin i
             where i.bin = l_tp_rec.bin;
        exception
            when no_data_found then
                l_inst_id := null;
                trc_log_pkg.debug(
                    i_text       => 'No bin [#1] found in iss_bin table'
                  , i_env_param1 => l_tp_rec.bin
                );
            l_opr_operation_rec.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
        end;

        if l_inst_id = cst_ap_api_const_pkg.AP_INST_ID then
            l_opr_operation_rec.sttl_type       := cst_ap_api_const_pkg.STTT_US_ON_SATIM;
            l_opr_acq_participant_rec.inst_id   := cst_ap_api_const_pkg.SAT_INST_ID;
            l_opr_iss_participant_rec.inst_id   := l_inst_id;
        else
            l_opr_operation_rec.sttl_type       := cst_ap_api_const_pkg.STTT_SATIM_ON_US;
            l_opr_acq_participant_rec.inst_id   := cst_ap_api_const_pkg.AP_INST_ID;
            l_opr_iss_participant_rec.inst_id   := cst_ap_api_const_pkg.SAT_INST_ID;
        end if;

        l_opr_operation_rec.mcc                    := get_mcc( i_merchant_number => l_opr_operation_rec.merchant_number
                                                             , i_inst_id         => l_opr_acq_participant_rec.inst_id
                                                             ); -- Aks
        l_opr_acq_participant_rec.terminal_id   := get_terminal_id(
                                                       i_terminal_number => l_opr_operation_rec.terminal_number
                                                     , i_inst_id         => l_opr_acq_participant_rec.inst_id
                                                   );
        l_opr_acq_participant_rec.merchant_id   := get_merchant_id(
                                                       i_merchant_number => l_opr_operation_rec.merchant_number
                                                     , i_inst_id         => l_opr_acq_participant_rec.inst_id
                                                   );
        if l_opr_acq_participant_rec.merchant_id is null
            and l_opr_operation_rec.sttl_type = cst_ap_api_const_pkg.STTT_SATIM_ON_US then
                trc_log_pkg.debug(
                    i_text       => 'No merchant found with merchant number ['||l_opr_operation_rec.merchant_number||']'
                );
                l_opr_operation_rec.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL; -- OPST0102
         end if;
         if l_opr_acq_participant_rec.terminal_id is null
             and l_opr_operation_rec.sttl_type = cst_ap_api_const_pkg.STTT_SATIM_ON_US then
                 trc_log_pkg.debug(
                     i_text       => 'No terminal found with terminal number ['||l_opr_operation_rec.terminal_number||']'
                 );
                 l_opr_operation_rec.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL; -- OPST0102
         end if;

        -- Bebore add participant issuer for own card need define account, because necessary check follows.
        if (l_opr_iss_participant_rec.inst_id   = cst_ap_api_const_pkg.AP_INST_ID)
        then
            begin
                select card_id
                 into l_opr_iss_participant_rec.card_id
                 from iss_card_number
                where card_number = l_opr_iss_participant_rec.card_number;

                acc_api_account_pkg.get_account_info(
                    i_entity_type          =>  iss_api_const_pkg.ENTITY_TYPE_CARD
                  , i_object_id            =>  l_opr_iss_participant_rec.card_id
                  , i_curr_code            =>  '012'
                  , o_account_number       =>  l_opr_iss_participant_rec.account_number
                 , o_inst_id              =>  l_opr_iss_participant_rec.inst_id
                );
                trc_log_pkg.debug(
                    i_text       => 'Found account [#1] using card id [#2] for institution [#3]'
                  , i_env_param1 => l_opr_iss_participant_rec.account_number
                  , i_env_param2 => l_opr_iss_participant_rec.card_id
                  , i_env_param3 => l_opr_iss_participant_rec.inst_id
                );
            exception
                when no_data_found then
                    trc_log_pkg.debug(
                        i_text       => 'Account not found [#1] for card id [#2] institution [#3]'
                      , i_env_param1 => l_opr_iss_participant_rec.account_number
                      , i_env_param2 => l_opr_iss_participant_rec.card_id
                      , i_env_param3 => l_opr_iss_participant_rec.inst_id
                    );
                l_opr_operation_rec.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
            end;
        else
            trc_log_pkg.debug(
                i_text       => 'Foreign issuer participant [#1]'
              , i_env_param1 => l_opr_iss_participant_rec.inst_id
            );
        end if;
        -- Aks end

        begin
            opr_api_create_pkg.create_operation(
                io_oper_id                => l_opr_operation_rec.id
              , i_session_id              => get_session_id
              , i_status                  => l_opr_operation_rec.status
              , i_status_reason           => null
              , i_sttl_type               => l_opr_operation_rec.sttl_type
              , i_msg_type                => l_opr_operation_rec.msg_type
              , i_oper_type               => l_opr_operation_rec.oper_type
              , i_oper_reason             => null
              , i_is_reversal             => l_opr_operation_rec.is_reversal
              , i_oper_amount             => l_opr_operation_rec.oper_amount
              , i_oper_currency           => l_opr_operation_rec.oper_currency
              , i_oper_cashback_amount    => l_opr_operation_rec.oper_cashback_amount
              , i_sttl_amount             => l_opr_operation_rec.sttl_amount
              , i_sttl_currency           => l_opr_operation_rec.sttl_currency
              , i_oper_date               => l_opr_operation_rec.oper_date
              , i_host_date               => l_opr_operation_rec.host_date
              , i_sttl_date               => l_opr_operation_rec.sttl_date
              , i_terminal_type           => l_opr_operation_rec.terminal_type
              , i_mcc                     => l_opr_operation_rec.mcc
              , i_originator_refnum       => l_opr_operation_rec.originator_refnum
              , i_network_refnum          => l_opr_operation_rec.network_refnum
              , i_acq_inst_bin            => l_opr_operation_rec.acq_inst_bin
              , i_forw_inst_bin           => l_opr_operation_rec.forw_inst_bin
              , i_merchant_number         => l_opr_operation_rec.merchant_number
              , i_terminal_number         => l_opr_operation_rec.terminal_number
              , i_merchant_name           => l_opr_operation_rec.merchant_name
              , i_merchant_street         => l_opr_operation_rec.merchant_street
              , i_merchant_city           => l_opr_operation_rec.merchant_city
              , i_merchant_region         => l_opr_operation_rec.merchant_region
              , i_merchant_country        => l_opr_operation_rec.merchant_country
              , i_merchant_postcode       => l_opr_operation_rec.merchant_postcode
              , i_dispute_id              => l_opr_operation_rec.dispute_id
              , i_match_status            => case l_opr_operation_rec.status
                                                 when opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                                                     then l_opr_operation_rec.match_status
                                                 else null
                                             end
              , i_original_id             => l_opr_operation_rec.original_id
              , i_proc_mode               => l_opr_operation_rec.proc_mode
              , i_clearing_sequence_num   => l_opr_operation_rec.clearing_sequence_num
              , i_clearing_sequence_count => l_opr_operation_rec.clearing_sequence_count
              , i_incom_sess_file_id      => l_opr_operation_rec.incom_sess_file_id
            );

            opr_api_create_pkg.add_participant(
                i_oper_id                 => l_opr_operation_rec.id
              , i_msg_type                => l_opr_operation_rec.msg_type
              , i_oper_type               => l_opr_operation_rec.oper_type
              , i_participant_type        => l_opr_iss_participant_rec.participant_type
              , i_host_date               => null
              , i_inst_id                 => l_opr_iss_participant_rec.inst_id
              , i_network_id              => l_opr_iss_participant_rec.network_id
              , i_customer_id             => l_opr_iss_participant_rec.customer_id
              , i_client_id_type          => nvl(l_opr_iss_participant_rec.client_id_type, opr_api_const_pkg.CLIENT_ID_TYPE_CARD)
              , i_client_id_value         => l_opr_iss_participant_rec.client_id_value
              , i_card_id                 => l_opr_iss_participant_rec.card_id
              , i_card_type_id            => l_opr_iss_participant_rec.card_type_id
              , i_card_expir_date         => l_opr_iss_participant_rec.card_expir_date
              , i_card_service_code       => l_opr_iss_participant_rec.card_service_code
              , i_card_seq_number         => l_opr_iss_participant_rec.card_seq_number
              , i_card_number             => l_opr_iss_participant_rec.card_number
              , i_card_mask               => l_opr_iss_participant_rec.card_mask
              , i_card_hash               => l_opr_iss_participant_rec.card_hash
              , i_card_country            => l_opr_iss_participant_rec.card_country
              , i_card_inst_id            => l_opr_iss_participant_rec.card_inst_id
              , i_card_network_id         => l_opr_iss_participant_rec.card_network_id
              , i_account_id              => null
              , i_account_number          => l_opr_iss_participant_rec.account_number -- Aks
              , i_account_amount          => null
              , i_account_currency        => null
              , i_auth_code               => l_opr_iss_participant_rec.auth_code
              , i_split_hash              => l_opr_iss_participant_rec.split_hash
              , i_without_checks          => com_api_const_pkg.FALSE
            );

            opr_api_create_pkg.add_participant (
                i_oper_id                 => l_opr_operation_rec.id
              , i_msg_type                => l_opr_operation_rec.msg_type
              , i_oper_type               => l_opr_operation_rec.oper_type
              , i_participant_type        => l_opr_acq_participant_rec.participant_type
              , i_host_date               => l_opr_operation_rec.host_date
              , i_inst_id                 => l_opr_acq_participant_rec.inst_id
              , i_network_id              => l_opr_acq_participant_rec.network_id
              , i_merchant_number         => l_opr_operation_rec.merchant_number -- Aks
              , i_terminal_id             => l_opr_acq_participant_rec.terminal_id
              , i_terminal_number         => l_opr_operation_rec.terminal_number
              , i_split_hash              => l_opr_acq_participant_rec.split_hash
              , i_without_checks          => com_api_const_pkg.FALSE
              , i_client_id_type          => l_opr_acq_participant_rec.client_id_type
              , i_client_id_value         => l_opr_operation_rec.terminal_number --l_opr_acq_participant_rec.client_id_value -- Aks
            );
        exception
            when com_api_error_pkg.e_application_error then
                o_excepted := 1;
                l_opr_operation_rec.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
            when others then
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );
        end;

        i := 0;
        l_aup_tags_tab.delete;

        begin
            add_to_aup_tags_tab(
                aup_api_tag_pkg.find_tag_by_reference(
                    i_reference => 'DF8527'
                ) --Invoice number
              , l_tp_rec.invoice_number
            );

            add_to_aup_tags_tab(
                aup_api_tag_pkg.find_tag_by_reference(
                    i_reference => 'DF8526'
                ) --Issuer of the invoice(The billler)
              , l_tp_rec.issuer_invoice
            );

            add_to_aup_tags_tab(
                 aup_api_tag_pkg.find_tag_by_reference(
                     i_reference => 'DF854B'
                 ) --Client ID
               , l_tp_rec.client_id
            );

            add_to_aup_tags_tab(
                aup_api_tag_pkg.find_tag_by_reference(
                    i_reference => 'DF8402'
                ) --UDF1
              , l_tp_rec.udf1
            );

            add_to_aup_tags_tab(
                aup_api_tag_pkg.find_tag_by_reference(
                    i_reference => 'DF8E02'
                ) --Unique reference number delivered by the platform used for purchase over the internet (Used in case of refund)
              , l_tp_rec.refnum_refund
            );

            add_to_aup_tags_tab(
                aup_api_tag_pkg.find_tag_by_reference(
                    i_reference => 'DF8E01'
                )
              , l_tp_rec.track_id
            );

            add_to_aup_tags_tab(
                aup_api_tag_pkg.find_tag_by_reference(
                    i_reference => 'DF8E02'
                 ) --ID_Origina_Transaction
              , l_tp_rec.tran_num_purch_internet
            );

            add_to_aup_tags_tab(
                aup_api_tag_pkg.find_tag_by_reference(
                    i_reference => 'CST_ISS_PART_CODE'
                 )
              , l_tp_rec.iss_bank_code
            );  --Issuer Bank Code

            add_to_aup_tags_tab(
                aup_api_tag_pkg.find_tag_by_reference(
                    i_reference => 'CST_ACQ_BIN'
                 ) --BIN code Acquirer
              , l_tp_rec.tran_num_purch_internet
            );

            add_to_aup_tags_tab(
                aup_api_tag_pkg.find_tag_by_reference(
                    i_reference => 'CST_ACQ_PART_CODE'
                 ) --Bank Acquirer Code
              , l_tp_rec.tran_num_purch_internet
            );

            if l_opr_operation_rec.sttl_type = cst_ap_api_const_pkg.STTT_SATIM_ON_US then
                add_to_aup_tags_tab(
                    aup_api_tag_pkg.find_tag_by_reference(
                        i_reference => 'CST_AGENT_CODE'
                     ) --ID_Origina_Transaction
                  , '99999'
                );
            else
                add_to_aup_tags_tab(
                    aup_api_tag_pkg.find_tag_by_reference(
                        i_reference => 'CST_AGENT_CODE'
                     ) --ID_Origina_Transaction
                  , l_tp_rec.code_trading_merch
                );
            end if;

            add_to_aup_tags_tab(
                aup_api_tag_pkg.find_tag_by_reference(
                    i_reference => 'DF8E02'
                 ) --Code Trading merchant (ATM)
              , l_tp_rec.tran_num_purch_internet
            );

            add_to_aup_tags_tab(
                aup_api_tag_pkg.find_tag_by_reference(
                    i_reference => 'CST_ATM_CONNECTION'
                 ) --ATM connexion
              , l_tp_rec.atm_connex
            );
            
            begin 
                add_to_aup_tags_tab(
                    i_tag_id    => cst_ap_api_const_pkg.TAG_ID_SESSION_DAY
                  , i_tag_value =>
                        coalesce(
                            cst_ap_api_process_pkg.get_ap_session_id(
                                i_ap_session_status => cst_ap_api_const_pkg.SESSION_ACTIVE
                              , i_eff_date          => l_sysdate
                              , i_mask_error        => com_api_const_pkg.TRUE
                            )
                          , cst_ap_api_process_pkg.get_ap_session_id(
                                i_ap_session_status => cst_ap_api_const_pkg.SESSION_FUTURE
                              , i_eff_date          => l_sysdate
                              , i_mask_error        => com_api_const_pkg.FALSE
                            )
                        )
                );
            exception when NO_DATA_FOUND then
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );
                o_raised   := 1;
                o_excepted := 1;
            end;
            
            insert_tag(
                i_auth_id => l_opr_card.oper_id
              , i_tags => l_aup_tags_tab
            );

            --EMV data

            --l_emv_data := l_emv_data || format_tag_value (l_tp_rec.l_emv_9f26_qarqc);
            --l_emv_data := l_emv_data || format_tag_value (l_tp_rec.l_emv_9F27_crypto);
            --l_emv_data := l_emv_data || format_tag_value (l_tp_rec.l_emv_9F36_trn_count);
            --l_emv_data := l_emv_data || format_tag_value (l_tp_rec.l_emv_95_term_verif);
            --l_emv_data := l_emv_data || format_tag_value (l_tp_rec.l_emv_9f26_qarqc);
            --l_emv_data := l_emv_data || format_tag_value (l_tp_rec.l_emv_9f26_qarqc);

            l_emv_tags_tab('9F26')  := l_tp_rec.l_emv_9f26_qarqc;
            l_emv_tags_tab('9F27')  := l_tp_rec.l_emv_9F27_crypto;
            l_emv_tags_tab('9F36')  := l_tp_rec.l_emv_9F36_trn_count;
            l_emv_tags_tab('95')    := l_tp_rec.l_emv_95_term_verif;

            l_idx_tag := l_emv_tags_tab.last;
            while (l_idx_tag is not null)
            loop
                l_emv_data := l_emv_data
                           || l_idx_tag
                           || prs_api_util_pkg.ber_tlv_length( l_emv_tags_tab(l_idx_tag) )
                           || l_emv_tags_tab(l_idx_tag);

                l_idx_tag := l_emv_tags_tab.prior(l_idx_tag);
            end loop;

            l_auth.id               := l_opr_operation_rec.id;
            l_auth.resp_code        := null; --aup_api_const_pkg.RESP_CODE_OK;
            l_auth.external_auth_id := l_tp_rec.tran_ref_number;
            l_auth.proc_type        := aut_api_const_pkg.DEFAULT_AUTH_PROC_TYPE;
            l_auth.is_advice        := com_api_const_pkg.FALSE;
            l_auth.network_amount   := l_opr_operation_rec.oper_amount;
            l_auth.network_currency := cst_ap_api_const_pkg.CURRENCY_TP;
            l_auth.auth_code        := l_opr_iss_participant_rec.auth_code;
            l_auth.emv_data         := l_emv_data;

            put_auth_data(
                i_auth_data => l_auth
            );

            --Additional amounts saving
            opr_api_additional_amount_pkg.save_amount(
                i_oper_id      => l_opr_card.oper_id
              , i_amount_type  => cst_ap_api_const_pkg.AMOUNT_CARDHOLDER
              , i_amount_value => l_tp_rec.acch_fee
              , i_currency     => cst_ap_api_const_pkg.CURRENCY_TP
            );
            opr_api_additional_amount_pkg.save_amount(
                i_oper_id      => l_opr_card.oper_id
              , i_amount_type  => cst_ap_api_const_pkg.AMOUNT_INTERCHANGE
              , i_amount_value => l_tp_rec.inter_fee
              , i_currency     => cst_ap_api_const_pkg.CURRENCY_TP
            );
            opr_api_additional_amount_pkg.save_amount(
                i_oper_id      => l_opr_card.oper_id
              , i_amount_type  => cst_ap_api_const_pkg.AMOUNT_SATIM
              , i_amount_value => l_tp_rec.tech_fee
              , i_currency     => cst_ap_api_const_pkg.CURRENCY_TP
            );
            opr_api_additional_amount_pkg.save_amount(
                i_oper_id      => l_opr_card.oper_id
              , i_amount_type  => cst_ap_api_const_pkg.AMOUNT_MERCHANT
              , i_amount_value => l_tp_rec.mrc_fee
              , i_currency     => cst_ap_api_const_pkg.CURRENCY_TP
            );
            o_processed := 1;
        exception
            when others then
                l_opr_operation_rec.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
                o_excepted := 1;
        end;
    end if;
end;

procedure process_tp
is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_msstrxn: ';

    l_record_count_all_files      com_api_type_pkg.t_long_id := 0;
    l_record_count                com_api_type_pkg.t_long_id := 0;
    l_record_number               com_api_type_pkg.t_long_id := 0;
    l_processed_count             com_api_type_pkg.t_long_id := 0;
    l_excepted_count              com_api_type_pkg.t_long_id := 0;
    l_rejected_count              com_api_type_pkg.t_long_id := 0;
    l_rec                         com_api_type_pkg.t_text;
    l_processed                   com_api_type_pkg.t_boolean;
    l_excepted                    com_api_type_pkg.t_boolean;
    l_raised                      com_api_type_pkg.t_boolean;

    l_load_date                   date := com_api_sttl_day_pkg.get_sysdate;
    l_eff_date                    date := l_load_date;
    l_input_file_name             com_api_type_pkg.t_name;
    l_original_file_name          com_api_type_pkg.t_name;

    l_params                      com_api_type_pkg.t_param_tab;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
begin
    prc_api_stat_pkg.log_start;

    open cu_records_count;
    fetch cu_records_count into l_record_count_all_files;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_record_count_all_files
    );
    for p in (
        select id session_file_id
             , record_count
             , file_name
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    )
    loop
        begin
            for r in (
                select record_number
                     , raw_data
                     , count(1) over() cnt
                     , row_number() over(order by record_number) rn
                     , row_number() over(order by record_number desc) rn_desc
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
                )
            loop
                savepoint process_string_start;
                l_record_number := r.record_number;
                l_rec           := r.raw_data;

                process_record(
                    i_rec                => r.raw_data
                  , i_row_number         => r.rn
                  , i_incom_sess_file_id => p.session_file_id
                  , i_file_name          => p.file_name
                  , o_processed          => l_processed
                  , o_excepted           => l_excepted
                  , o_raised             => l_raised
                );
                l_processed_count := l_processed_count + l_processed;
                l_excepted_count  := l_excepted_count + l_excepted;

                if l_raised <> 0 then
                    rollback to savepoint process_string_start;
                    exit;
                end if;
            end loop;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_processed_count
              , i_excepted_count => l_excepted_count
            );
            if l_raised = 0 then
                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                );
            else
                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
            end if;
        exception
            when others then
                l_record_count := l_record_count + p.record_count;

                prc_api_stat_pkg.log_current(
                        i_current_count  => l_processed_count
                      , i_excepted_count => l_excepted_count
                );
                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                trc_log_pkg.fatal(
                    i_text          => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );
                raise;
        end;
    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_excepted_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
end process_tp;

end cst_ap_tp_load_pkg;
/
