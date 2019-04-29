create or replace package body itf_prc_incoming_pkg is
/************************************************************
 * Interface for loading files <br />
 * Created by Kondratyev A.(kondratyev@bpc.ru)  at 03.06.2013 <br />
 * Last changed by $Author: Kondratyev A. $ <br />
 * $LastChangedDate:: 2013-06-03 13:30:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: itf_prc_incoming_pkg <br />
 * @headcom
 ************************************************************/
    BULK_LIMIT      constant integer := 400;

g_error_flag        com_api_type_pkg.t_boolean := 0;
g_errors_count      com_api_type_pkg.t_long_id := 0;

procedure create_operation(
    io_oper             in out  opr_api_type_pkg.t_oper_rec
  , io_iss_part         in out  opr_api_type_pkg.t_oper_part_rec
  , io_acq_part         in out  opr_api_type_pkg.t_oper_part_rec
) is
begin
    opr_api_create_pkg.create_operation (
        io_oper_id                => io_oper.id
      , i_session_id              => io_oper.session_id
      , i_status                  => io_oper.status
      , i_status_reason           => io_oper.status_reason
      , i_sttl_type               => io_oper.sttl_type
      , i_msg_type                => io_oper.msg_type
      , i_oper_type               => io_oper.oper_type
      , i_oper_reason             => io_oper.oper_reason
      , i_is_reversal             => io_oper.is_reversal
      , i_oper_amount             => io_oper.oper_amount
      , i_oper_currency           => io_oper.oper_currency
      , i_sttl_amount             => io_oper.sttl_amount
      , i_sttl_currency           => io_oper.sttl_currency
      , i_oper_date               => io_oper.oper_date
      , i_host_date               => io_oper.host_date
      , i_terminal_type           => io_oper.terminal_type
      , i_mcc                     => io_oper.mcc
      , i_originator_refnum       => io_oper.originator_refnum
      , i_acq_inst_bin            => io_oper.acq_inst_bin
      , i_merchant_number         => io_oper.merchant_number
      , i_terminal_number         => io_oper.terminal_number
      , i_merchant_name           => io_oper.merchant_name
      , i_merchant_street         => io_oper.merchant_street
      , i_merchant_city           => io_oper.merchant_city
      , i_merchant_region         => io_oper.merchant_region
      , i_merchant_country        => io_oper.merchant_country
      , i_merchant_postcode       => io_oper.merchant_postcode
      , i_dispute_id              => io_oper.dispute_id
      , i_payment_order_id        => io_oper.payment_order_id
      , i_match_status            => io_oper.match_status
    );

    opr_api_create_pkg.add_participant(
        i_oper_id               => io_oper.id
      , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
      , i_oper_type             => io_oper.oper_type
      , i_participant_type      => com_api_const_pkg.PARTICIPANT_ISSUER
      , i_host_date             => io_oper.host_date
      , i_inst_id               => io_iss_part.inst_id
      , i_network_id            => io_iss_part.network_id
      , i_customer_id           => io_iss_part.customer_id
      , i_card_id               => io_iss_part.card_id
      , i_card_type_id          => io_iss_part.card_type_id
      , i_card_expir_date       => io_iss_part.card_expir_date
      , i_card_seq_number       => io_iss_part.card_seq_number
      , i_card_number           => io_iss_part.card_number
      , i_card_country          => io_iss_part.card_country
      , i_card_inst_id          => io_iss_part.card_inst_id
      , i_card_network_id       => io_iss_part.card_network_id
      , i_account_id            => io_iss_part.account_id
      , i_account_number        => io_iss_part.account_number
      , i_account_amount        => io_iss_part.account_amount
      , i_account_currency      => io_iss_part.account_currency
      , i_auth_code             => io_iss_part.auth_code
      , i_split_hash            => io_iss_part.split_hash
      , i_payment_order_id      => io_oper.payment_order_id
      , i_without_checks        => com_api_const_pkg.TRUE
    );

    opr_api_create_pkg.add_participant(
        i_oper_id               => io_oper.id
      , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
      , i_oper_type             => io_oper.oper_type
      , i_participant_type      => com_api_const_pkg.PARTICIPANT_ACQUIRER
      , i_host_date             => io_oper.host_date
      , i_inst_id               => io_acq_part.inst_id
      , i_network_id            => io_acq_part.network_id
      , i_merchant_id           => io_acq_part.merchant_id
      , i_terminal_id           => io_acq_part.terminal_id
      , i_terminal_number       => io_oper.terminal_number
      , i_split_hash            => io_acq_part.split_hash
      , i_payment_order_id      => io_oper.payment_order_id
      , i_without_checks        => com_api_const_pkg.TRUE
    );

end;

procedure process_file_header (
    i_header_data  in      com_api_type_pkg.t_raw_data
  , o_file_header     out  itf_api_type_pkg.t_file_header
) is
begin
    o_file_header.record_type      := substr(i_header_data, 1, 6);
    o_file_header.record_number    := to_number(substr(i_header_data, 9, 12));
    o_file_header.file_id          := to_number(substr(i_header_data, 21, 18));
    o_file_header.file_type        := trim(substr(i_header_data, 40, 8));
    o_file_header.file_dt          := to_date(substr(i_header_data, 48, 8)||' '||substr(i_header_data, 56, 6),'MMDDYYYY HH24MISS');
    o_file_header.inst_id          := trim(substr(i_header_data, 63, 12));
    o_file_header.agent_inst_id    := trim(substr(i_header_data, 75, 12));
    o_file_header.fe_sett_dt       := to_date(trim(substr(i_header_data, 88, 8)||' '||substr(i_header_data, 96, 6)),'MMDDYYYY HH24MISS');
--    o_file_header.bo_sett_dt       := to_date(trim(substr(i_header_data, 102, 8)||' '||substr(i_header_data, 110, 6)),'MMDDYYYY HH24MISS');
    o_file_header.bo_sett_day      := to_number(trim(substr(i_header_data, 116, 6)));
    o_file_header.fh_length        := length(i_header_data);
end;

procedure process_ocp_batch_trailer(
    i_record_data       in      com_api_type_pkg.t_raw_data
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) is
    l_batch             itf_api_type_pkg.t_ocp_batch_rec;
    l_oper              opr_api_type_pkg.t_oper_rec;
    l_acq_part          opr_api_type_pkg.t_oper_part_rec;
    l_iss_part          opr_api_type_pkg.t_oper_part_rec;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_payment_order_id  com_api_type_pkg.t_long_id;
    l_customer_id       com_api_type_pkg.t_medium_id;
    l_purpose_id        com_api_type_pkg.t_short_id;
    l_account_id        com_api_type_pkg.t_long_id;
    l_attempt_count     com_api_type_pkg.t_tiny_id;
    l_entity_type       com_api_type_pkg.t_dict_value;
    l_param_value       com_api_type_pkg.t_param_value;
    lc_raw_data_length  constant  com_api_type_pkg.t_tiny_id := 654;
    lc_ready_status     constant  com_api_type_pkg.t_dict_value := opr_api_const_pkg.OPERATION_STATUS_PROCESSED;
    lc_send_status      constant  com_api_type_pkg.t_dict_value := opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY;
    l_status            com_api_type_pkg.t_dict_value;
begin
    l_batch.record_type            := substr(i_record_data, 1, 6);
    l_batch.record_number          := to_number(substr(i_record_data, 9, 12));
    l_batch.account_number         := trim(substr(i_record_data, 21, 32));
    l_batch.bo_account_type        := trim(substr(i_record_data, 53, 8));
    l_batch.amount                 := to_number(substr(i_record_data, 62, 12));
    l_batch.dc_indicator           := substr(i_record_data, 74, 2);
    l_batch.currency_code          := substr(i_record_data, 76, 3);
    l_batch.effect_date            := to_date(substr(i_record_data, 80, 8),'MMDDYYYY');
    l_batch.trans_id               := to_number(substr(i_record_data, 89, 16));
    l_batch.bo_trans_type          := trim(substr(i_record_data, 106, 8));
    l_batch.user_id                := trim(substr(i_record_data, 115, 3));
    l_batch.cor_account            := trim(substr(i_record_data, 119, 32));
    l_batch.fe_trans_type          := trim(substr(i_record_data, 151, 8));
    l_batch.customs_office         := trim(substr(i_record_data, 160, 40));
    l_batch.customs_address        := trim(substr(i_record_data, 200, 64));
    l_batch.trans_date             := to_date(trim(substr(i_record_data, 264, 8)),'MMDDYYYY');
    l_batch.card_number            := trim(substr(i_record_data, 273, 16));
    l_batch.receipt_number         := trim(substr(i_record_data, 290, 4));
    l_batch.approval_code          := trim(substr(i_record_data, 295, 6));
    l_batch.payer_inn              := trim(substr(i_record_data, 302, 12));
    l_batch.payer_kpp              := trim(substr(i_record_data, 315, 9));
    l_batch.payer_okpo             := trim(substr(i_record_data, 325, 10));
    l_batch.declarant_inn          := trim(substr(i_record_data, 336, 12));
    l_batch.declarant_kpp          := trim(substr(i_record_data, 349, 9));
    l_batch.declarant_okpo         := trim(substr(i_record_data, 359, 10));
    l_batch.customs_code           := to_number(trim(substr(i_record_data, 370, 8)));
    l_batch.pay_doc_type           := trim(substr(i_record_data, 378, 2));
    l_batch.pay_doc_id             := trim(substr(i_record_data, 380, 7));
    l_batch.pay_doc_date           := trim(substr(i_record_data, 387, 10));
    l_batch.pay_kind               := to_number(trim(substr(i_record_data, 397, 4)));
    l_batch.cbc                    := to_number(trim(substr(i_record_data, 401, 20)));
    l_batch.pay_status             := to_number(trim(substr(i_record_data, 421, 2)));
    l_batch.receiver_kpp           := to_number(trim(substr(i_record_data, 423, 9)));
    l_batch.receiver_okato         := to_number(trim(substr(i_record_data, 432, 11)));
    l_batch.pay_type               := trim(substr(i_record_data, 443, 2));
    l_batch.pay_details            := trim(substr(i_record_data, 445, 210));
    l_batch.r_length               := length(i_record_data);

    if l_batch.r_length != lc_raw_data_length then
        com_api_error_pkg.raise_error(
            i_error       => 'OCP_FILE_RAW_LENGTH_INCORRECT'
          , i_env_param1  => to_char(l_batch.r_length)
          , i_env_param2  => to_char(l_batch.record_number)
        );
    end if;

    begin
        select aa.id, aa.customer_id, pc.entity_type
          into l_account_id, l_customer_id, l_entity_type
          from acc_account aa
             , prd_customer pc
         where aa.account_number = l_batch.account_number
           and aa.customer_id = pc.id
           and aa.inst_id = i_inst_id;
    exception
      when no_data_found then
           trc_log_pkg.debug (i_text => 'Account not found. Account: '||trim(l_batch.account_number));
           g_error_flag := com_api_type_pkg.TRUE;
           return;
    end;

    if    l_batch.dc_indicator = itf_api_const_pkg.DC_IND_DEBIT then
         l_purpose_id              := pmo_api_const_pkg.EXTERNAL_INCOMING_PAYMENT;
    elsif l_batch.dc_indicator = itf_api_const_pkg.DC_IND_CREDIT then
         if    l_entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY then
             l_purpose_id              := pmo_api_const_pkg.TRANSFER_TO_ORGANIZATION;
         elsif l_entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON then
             l_purpose_id              := pmo_api_const_pkg.TRANSFER_TO_PERSON;
         end if;
    end if;
    pmo_api_order_pkg.add_order(
        o_id                 => l_payment_order_id
      , i_customer_id        => l_customer_id
      , i_entity_type        => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id          => l_account_id
      , i_purpose_id         => l_purpose_id
      , i_template_id        => null
      , i_amount             => l_batch.amount
      , i_currency           => l_batch.currency_code
      , i_event_date         => get_sysdate
      , i_status             => pmo_api_const_pkg.PMO_STATUS_PROCESSED
      , i_inst_id            => i_inst_id
      , i_attempt_count      => 0
      , i_is_prepared_order  => com_api_type_pkg.FALSE
      , i_is_template        => com_api_type_pkg.FALSE
    );

    for vp in (select pp.id, trim(pp.param_name) as param_name
                 from pmo_parameter pp
                    , pmo_purpose_parameter ppp
                where pp.id = ppp.param_id
                  and ppp.purpose_id = l_purpose_id
                order by pp.id)
    loop
        l_param_value := null;
        case vp.param_name
           when 'CBS_TRANSFER_BIC' then l_param_value := null;
           when 'CBS_TRANSFER_BANK_NAME' then l_param_value := null;
           when 'CBS_TRANSFER_BANK_BRANCH_NAME' then l_param_value := l_batch.customs_office;
           when 'CBS_TRANSFER_RECIPIENT_ACCOUNT' then
                  if l_purpose_id != pmo_api_const_pkg.EXTERNAL_INCOMING_PAYMENT then l_param_value := l_batch.account_number; end if;
           when 'CBS_TRANSFER_RECIPIENT_TAX_ID' then l_param_value := null;
           when 'CBS_TRANSFER_RECIPIENT_NAME' then
                  select case pc.entity_type
                           when 'ENTTCOMP' then get_text('COM_COMPANY','LABEL', pc.object_id)
                           when 'ENTTPERS' then com_ui_person_pkg.get_person_name(pc.object_id)
                         end as name_of_customer
                    into l_param_value
                    from prd_customer pc
                   where id = l_customer_id
                     and l_purpose_id != pmo_api_const_pkg.EXTERNAL_INCOMING_PAYMENT;
           when 'CBS_TRANSFER_PAYER_NAME' then
                  select case pc.entity_type
                           when 'ENTTCOMP' then get_text('COM_COMPANY','LABEL', pc.object_id)
                           when 'ENTTPERS' then com_ui_person_pkg.get_person_name(pc.object_id)
                         end as name_of_customer
                    into l_param_value
                    from prd_customer pc
                   where id = l_customer_id
                     and l_purpose_id = pmo_api_const_pkg.EXTERNAL_INCOMING_PAYMENT;
           when 'CBS_TRANSFER_PAYMENT_PURPOSE' then l_param_value := l_batch.pay_details;
           when 'CBS_TRANSFER_BANK_CORR_ACC' then l_param_value := l_batch.cor_account;
           when 'CBS_TRANSFER_BANK_CITY' then l_param_value := l_batch.customs_address;
           when 'SOURCE_CLIENT_ID_TYPE' then l_param_value := 'CITPACCT';
           when 'SOURCE_CLIENT_ID_VALUE' then l_param_value := null;
           when 'CBS_TRANSFER_BANK_REG_NUM' then l_param_value := null;
           when 'CBS_TRANSFER_PAYER_ACCOUNT' then l_param_value := l_batch.account_number;
           when 'CBS_TRANSFER_CHECK_NUMBER' then l_param_value := l_batch.receipt_number;
           when 'CBS_TRANSFER_INVOICE_DATE' then l_param_value := to_char(l_batch.trans_date,'MMDDYYYY');
           when 'CBS_CODE_BUDGET_CLASSIFICATION' then l_param_value := to_char(l_batch.cbc);
           when 'CBS_CUSTOMS_CODE' then l_param_value := to_char(l_batch.customs_code);
           when 'CBS_PAYMENT_DOCUMENT_TYPE' then l_param_value := l_batch.pay_doc_type;
           when 'CBS_PAYMENT_DOCUMENT_ID' then l_param_value := l_batch.pay_doc_id;
           when 'CBS_PAYMENT_DOCUMENT_DATE' then l_param_value := l_batch.pay_doc_date;
           when 'CBS_PAYMENT_KIND' then l_param_value := l_batch.pay_type;
           when 'CBS_PAYER_INN' then l_param_value := l_batch.payer_inn;
           when 'CBS_PAYER_KPP' then l_param_value := l_batch.payer_kpp;
           when 'CBS_PAYER_OKPO' then l_param_value := l_batch.payer_okpo;
           when 'CBS_APPROVAL_CODE' then l_param_value := l_batch.approval_code;
           when 'CBS_CARD_NUMBER' then l_param_value := l_batch.card_number;
           when 'CBS_TRANSFER_PAYER_ACCOUNT' then
                  if l_purpose_id = pmo_api_const_pkg.EXTERNAL_INCOMING_PAYMENT then l_param_value := l_batch.account_number; end if;
           when 'CBS_TRANSACTION_TYPE' then l_param_value := l_batch.bo_trans_type;
           when 'CBS_FEE_TYPE' then l_param_value := l_batch.fe_trans_type;
           when 'CBS_ORIGINAL_TRANSACTION_ID' then l_param_value := to_char(l_batch.trans_id);
           when 'CBS_PAY_KIND' then l_param_value := to_char(l_batch.pay_kind);
           else null;
         end case;
        pmo_api_order_pkg.add_order_data(
            i_order_id    => l_payment_order_id
          , i_param_name  => vp.param_name
          , i_param_value => l_param_value
        );
    end loop;

    l_oper.payment_order_id        := l_payment_order_id;
    l_oper.oper_amount             := l_batch.amount;
    l_oper.oper_currency           := l_batch.currency_code;
    l_oper.oper_date               := l_batch.trans_date;
    l_oper.host_date               := l_batch.effect_date;
    if    l_batch.bo_trans_type = itf_api_const_pkg.TT_BO_CUSTOMS_PAY then
         l_oper.oper_type          := itf_api_const_pkg.OPERATION_TYPE_CUSTOMS_PAYMENT;
    elsif l_batch.bo_trans_type = itf_api_const_pkg.TT_ISSUER_FEE then
         l_oper.oper_type          := itf_api_const_pkg.OPERATION_TYPE_FEECUST_PAYMENT;
    end if;
    l_oper.status                  := opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY;
    begin
        select t.id, t.terminal_number, t.terminal_type
          into l_acq_part.terminal_id, l_oper.terminal_number, l_oper.terminal_type
          from pmo_purpose r
             , acq_terminal t
         where r.terminal_id = t.id
           and R.ID = l_purpose_id;
    exception
      when no_data_found then
        l_acq_part.terminal_id := null;
        l_oper.terminal_number := null;
        l_oper.terminal_type   := null;
    end;
    l_oper.msg_type                := opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT;
    l_oper.sttl_type               := opr_api_const_pkg.SETTLEMENT_USONUS;
    l_oper.is_reversal             := 0;

    l_iss_part.inst_id             := i_inst_id;
    l_iss_part.network_id          := ost_api_institution_pkg.get_inst_network(i_inst_id);
    l_iss_part.customer_id         := iss_api_card_pkg.get_customer_id (i_card_number => l_batch.card_number);
    l_iss_part.card_number         := l_batch.card_number;
    iss_api_card_pkg.get_card (
        i_card_number     => l_batch.card_number
      , io_seq_number     => l_iss_part.card_seq_number
      , io_expir_date     => l_iss_part.card_expir_date
      , o_card_id         => l_iss_part.card_id
      , o_card_type_id    => l_iss_part.card_type_id
      , o_card_country    => l_iss_part.card_country
      , o_card_inst_id    => l_iss_part.card_inst_id
      , o_card_network_id => l_iss_part.card_network_id
      , o_split_hash      => l_split_hash
    );
    l_iss_part.account_id          := acc_api_account_pkg.get_account_id(i_account_number => l_batch.account_number);
    l_iss_part.account_number      := l_batch.account_number;
    l_acq_part.inst_id             := i_inst_id;
    l_acq_part.network_id          := ost_api_institution_pkg.get_inst_network(i_inst_id);

    create_operation(
           io_oper     => l_oper
         , io_iss_part => l_iss_part
         , io_acq_part => l_acq_part
    );
    if l_oper.id is not null then
        update opr_operation
           set status = lc_send_status
         where id = l_oper.id;

        opr_api_process_pkg.process_operation(
            i_operation_id  => l_oper.id
          , i_stage         => opr_api_const_pkg.PROCESSING_STAGE_UDEFINED
          , i_mask_error    => com_api_type_pkg.TRUE
        );

        select status
          into l_status
          from opr_operation
         where id = l_oper.id;
        if l_status != lc_ready_status then
            update opr_operation
               set status = lc_ready_status
             where id = l_oper.id;
        end if;
    end if;
end;

procedure process_r_ibi_batch_trailer(
    i_record_data       in      com_api_type_pkg.t_raw_data
) is
    l_batch             itf_api_type_pkg.t_r_ibi_batch_rec;
    l_operation_id      com_api_type_pkg.t_long_id;
    l_resp_operation    com_api_type_pkg.t_dict_value;
    lc_raw_data_length  constant  com_api_type_pkg.t_tiny_id := 498;
    lc_send_status      constant  com_api_type_pkg.t_dict_value := opr_api_const_pkg.OPERATION_STATUS_WAIT_SETTL;
    lc_ready_status     constant  com_api_type_pkg.t_dict_value := opr_api_const_pkg.OPERATION_STATUS_PROCESSED;
    l_status            com_api_type_pkg.t_dict_value;
    v_count             com_api_type_pkg.t_tiny_id;
begin
    l_batch.record_type            := substr(i_record_data, 1, 6);
    l_batch.record_number          := to_number(substr(i_record_data, 9, 12));
    l_batch.file_id                := to_number(substr(i_record_data, 22, 18));
    l_batch.rejected_mess_number   := to_number(substr(i_record_data, 40, 12));
    l_batch.reject_reason          := trim(substr(i_record_data, 53, 8));
    l_batch.reason_descr           := trim(substr(i_record_data, 61, 100));
    l_batch.pay_id                 := to_number(trim(substr(i_record_data, 162, 16)));
    l_batch.r_length               := length(i_record_data);

    if l_batch.r_length != lc_raw_data_length then
        com_api_error_pkg.raise_error(
            i_error       => 'R_IBI_FILE_RAW_LENGTH_INCORRECT'
          , i_env_param1  => to_char(l_batch.r_length)
          , i_env_param2  => to_char(l_batch.record_number)
        );
    end if;

    begin
/*        select oo.id
          into l_operation_id
          from opr_operation oo
             , prc_session_file b
         where b.id = l_batch.file_id
           and oo.session_id = b.session_id
           and oo.id = (select min(id) + nvl(l_batch.rejected_mess_number,0) - 2
                          from opr_operation op
                         where op.session_id = oo.session_id);*/
        select oo.id
          into l_operation_id
          from opr_operation oo
         where oo.id = nvl(l_batch.pay_id,-1);
    exception
      when no_data_found then
        if l_batch.reject_reason = itf_api_const_pkg.NO_ERROR then
           l_resp_operation := aup_api_const_pkg.RESP_CODE_OK;
        end if;
    end;

    -- Mapping with RESP codes
    if    l_batch.reject_reason in (itf_api_const_pkg.NO_ERROR
                                  , itf_api_const_pkg.PAYMENT_ACCEPTED
                                  , itf_api_const_pkg.PAYMENT_PROCESSED)
    then
         l_resp_operation := aup_api_const_pkg.RESP_CODE_OK;
    elsif l_batch.reject_reason in (itf_api_const_pkg.CUSTOMER_ACCOUNT_NUMBER
                                  , itf_api_const_pkg.CUSTOMER_ID
                                  , itf_api_const_pkg.CUSTOMER_NAME)
    then
         l_resp_operation := aup_api_const_pkg.RESP_CODE_CANT_GET_CUSTOMER;
    elsif l_batch.reject_reason in (itf_api_const_pkg.MERCHANT_ACCOUNT_NUMBER
                                  , itf_api_const_pkg.MERCHANT_NUMBER)
    then
         l_resp_operation := 'RESP0065';
    elsif l_batch.reject_reason = itf_api_const_pkg.CORRESPONDING_ACCOUNT_NUMBER then
         l_resp_operation := aup_api_const_pkg.RESP_CODE_CANT_FIND_DEST;
    elsif l_batch.reject_reason = itf_api_const_pkg.CARD_NUMBER then
         l_resp_operation := aup_api_const_pkg.RESP_CODE_CARD_NOT_FOUND;
    elsif l_batch.reject_reason in (itf_api_const_pkg.ADDRESS_ERROR
                                  , itf_api_const_pkg.ADDRESS)
    then
         l_resp_operation := 'RESP0033';
    elsif l_batch.reject_reason = itf_api_const_pkg.TERMINAL_NUMBER then
         l_resp_operation := 'RESP0040';
    elsif l_batch.reject_reason in (itf_api_const_pkg.TRANSACTION_TYPE_ERROR
                                  , itf_api_const_pkg.DC_FLAG_ERROR
                                  , itf_api_const_pkg.CURRENCY_ERROR
                                  , itf_api_const_pkg.TRANSACTION_DATE
                                  , itf_api_const_pkg.TRANSACTION_ID
                                  , itf_api_const_pkg.TRANSACTION_TYPE
                                  , itf_api_const_pkg.CRC_ERROR
                                  , itf_api_const_pkg.OTHER_ERROR)
    then
         l_resp_operation := aup_api_const_pkg.RESP_CODE_ERROR;
    elsif l_batch.reject_reason = itf_api_const_pkg.ACCOUNT_ERROR then
         l_resp_operation := aup_api_const_pkg.RESP_CODE_ACCT_NOT_FOUND;
    elsif l_batch.reject_reason = itf_api_const_pkg.AMOUNT_ERROR then
         l_resp_operation := 'RESP0051';
    elsif l_batch.reject_reason = itf_api_const_pkg.FORMATING_ERROR then
         l_resp_operation := 'RESP0061';
    elsif l_batch.reject_reason = itf_api_const_pkg.INSUFFICIENT_FUNDS then
         l_resp_operation := aup_api_const_pkg.RESP_CODE_UNSUFFICIENT_FUNDS;
    else
        com_api_error_pkg.raise_error(
            i_error       => 'R_IBI_FILE_REJECT_REASON_INCORRECT'
          , i_env_param1  => l_batch.reject_reason
          , i_env_param2  => to_char(l_batch.record_number)
        );
    end if;

    select count(*)
      into v_count
      from opr_operation
     where id = l_operation_id
       and status = lc_send_status
       and rownum < 2;

    if v_count > 0 then
        update opr_operation
           set status_reason = l_resp_operation
         where id = l_operation_id;

        if l_resp_operation = aup_api_const_pkg.RESP_CODE_OK then
            update opr_operation
               set status = opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                 , host_date = com_api_sttl_day_pkg.get_sysdate
             where id = l_operation_id;

            opr_api_process_pkg.process_operation(
                i_operation_id  => l_operation_id
              , i_stage         => opr_api_const_pkg.PROCESSING_STAGE_UDEFINED
              , i_mask_error    => com_api_type_pkg.TRUE
            );
            select status
              into l_status
              from opr_operation
             where id = l_operation_id;
            if l_status != lc_ready_status then
                update opr_operation
                   set status = lc_ready_status
                 where id = l_operation_id;
            end if;
        end if;
    end if;

end;

procedure process_ibi_batch_trailer(
    i_record_type       in      com_api_type_pkg.t_dict_value
  , i_record_data       in      com_api_type_pkg.t_raw_data
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) is
    l_batch             itf_api_type_pkg.t_ibi_batch_rec;
    l_oper              opr_api_type_pkg.t_oper_rec;
    l_acq_part          opr_api_type_pkg.t_oper_part_rec;
    l_iss_part          opr_api_type_pkg.t_oper_part_rec;
    l_customer_id       com_api_type_pkg.t_medium_id;
    l_account_id        com_api_type_pkg.t_long_id;
    l_operation_id      com_api_type_pkg.t_long_id;
    l_entity_type       com_api_type_pkg.t_dict_value;
    l_resp_operation    com_api_type_pkg.t_dict_value;
    lc_raw_data_length  constant  com_api_type_pkg.t_tiny_id := 498;
    lc_send_status      constant  com_api_type_pkg.t_dict_value := opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY;
    l_status            com_api_type_pkg.t_dict_value;
    v_count             com_api_type_pkg.t_tiny_id;
begin
    l_batch.record_type            := trim(substr(i_record_data, 1, 6));
    l_batch.record_number          := to_number(substr(i_record_data, 9, 12));
    l_batch.account_number         := trim(substr(i_record_data, 21, 32));
    l_batch.account_type           := trim(substr(i_record_data, 53, 8));
    l_batch.amount                 := to_number(trim(substr(i_record_data, 62, 16)));
    l_batch.dc_indicator           := trim(substr(i_record_data, 78, 2));
    l_batch.currency_code          := trim(substr(i_record_data, 80, 3));
    l_batch.pay_date               := to_date(substr(i_record_data, 84, 8),'MMDDYYYY');
    l_batch.effect_date            := to_date(trim(substr(i_record_data, 92, 8)),'MMDDYYYY');
    l_batch.trans_type             := trim(substr(i_record_data, 101, 8));
    l_batch.user_id                := trim(substr(i_record_data, 110, 3));
    l_batch.pay_id                 := to_number(trim(substr(i_record_data, 113, 16)));
    l_batch.trans_decr             := trim(substr(i_record_data, 129, 40));
    l_batch.r_length               := length(i_record_data);

    if l_batch.r_length != lc_raw_data_length then
        com_api_error_pkg.raise_error(
            i_error       => 'IBI_FILE_RAW_LENGTH_INCORRECT'
          , i_env_param1  => to_char(l_batch.r_length)
          , i_env_param2  => to_char(l_batch.record_number)
        );
    end if;

    begin
        select aa.id, aa.customer_id, pc.entity_type
          into l_account_id, l_customer_id, l_entity_type
          from acc_account aa
             , prd_customer pc
         where aa.account_number = l_batch.account_number
           and aa.customer_id = pc.id
           and aa.inst_id = i_inst_id;
    exception
      when no_data_found then
           trc_log_pkg.debug (i_text => 'Account not found. Account: '||trim(l_batch.account_number)||' Inst_ID: '||to_char(i_inst_id));
           g_error_flag := com_api_type_pkg.TRUE;
           return;
    end;

    l_oper.oper_amount             := l_batch.amount;
    l_oper.oper_currency           := l_batch.currency_code;
    l_oper.oper_date               := l_batch.pay_date;
    l_oper.host_date               := l_batch.effect_date;
    if    l_batch.trans_type = itf_api_const_pkg.TT_WITHDRAW then
         l_oper.oper_type          := itf_api_const_pkg.OPERATION_TYPE_ACCOUNT_WITHDR;
    elsif l_batch.trans_type = itf_api_const_pkg.TT_PAYMENT then
         l_oper.oper_type          := itf_api_const_pkg.OPERATION_TYPE_ACCOUNT_PAYMENT;
    end if;
    l_oper.status                  := opr_api_const_pkg.OPERATION_STATUS_WAIT_CLEARING; 
    l_oper.msg_type                := opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT;
    l_oper.sttl_type               := opr_api_const_pkg.SETTLEMENT_USONUS;
    l_oper.is_reversal             := 0;

    l_iss_part.inst_id             := i_inst_id;
    l_iss_part.network_id          := ost_api_institution_pkg.get_inst_network(i_inst_id);
    l_iss_part.customer_id         := l_customer_id;
    l_iss_part.account_id          := acc_api_account_pkg.get_account_id(i_account_number => l_batch.account_number);
    l_iss_part.account_number      := l_batch.account_number;
    l_acq_part.inst_id             := i_inst_id;
    l_acq_part.network_id          := ost_api_institution_pkg.get_inst_network(i_inst_id);
    -- Creating of operations
    create_operation(
           io_oper     => l_oper
         , io_iss_part => l_iss_part
         , io_acq_part => l_acq_part
    );
end;

procedure process_file_trailer(
    i_trailer_data      in      com_api_type_pkg.t_raw_data
  , o_file_trailer         out  itf_api_type_pkg.t_file_trailer
) is
begin
    o_file_trailer.record_type      := substr(i_trailer_data, 1, 6);
    o_file_trailer.record_number    := to_number(substr(i_trailer_data, 9, 12));
    o_file_trailer.last_record_flag := substr(i_trailer_data, 21, 2);
    o_file_trailer.crc              := substr(i_trailer_data, 23, 8);
    o_file_trailer.ft_length        := length(i_trailer_data);
end;

procedure process
is
    l_count             com_api_type_pkg.t_long_id;
    l_rt                com_api_type_pkg.t_dict_value;
    l_buffer            itf_api_type_pkg.t_buffer;
    l_ocp_file          itf_api_type_pkg.t_ocp_batch_rec;
    l_file_header       itf_api_type_pkg.t_file_header;
    l_file_trailer      itf_api_type_pkg.t_file_trailer;
    l_record_number     com_api_type_pkg.t_long_id := 0;
    l_errors_count      com_api_type_pkg.t_long_id := 0;
    l_session_file_id   com_api_type_pkg.t_long_id;
    l_inst_id           com_api_type_pkg.t_inst_id;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
begin
    savepoint sp_ocp_start_load;

    trc_log_pkg.debug (i_text => 'File Processing start');
    prc_api_stat_pkg.log_start;

    -- estimate records
    open  cu_records_count;
    fetch cu_records_count into l_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation (
          i_estimated_count  => l_count * 3
    );
    for v in (
        select id session_file_id
             , record_count
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) loop
        l_errors_count := 0;
        begin
            savepoint sp_ocp_incoming_file;

            l_record_number := 1;
            l_buffer.delete;

            for r in (
                select record_number
                     , raw_data
                     , count(*) over() cnt
                     , row_number() over(order by record_number) rn
                     , row_number() over(order by record_number desc) rn_desc
                from (
                      select record_number, raw_data, lead(raw_data) over (order by record_number) next_data
                        from prc_file_raw_data
                       where session_file_id = v.session_file_id
                     )
                order by record_number
            ) loop
                g_error_flag := com_api_type_pkg.FALSE;
                l_buffer(l_buffer.count+1) := r.raw_data;
                l_rt         := substr(r.raw_data, 1, 6);

                if l_rt = itf_api_const_pkg.RT_FILE_HEADER then
                    process_file_header(
                            i_header_data => l_buffer(r.record_number)
                          , o_file_header => l_file_header
                    );
                elsif l_rt = itf_api_const_pkg.RT_OCP_BATCH_TRAILER
                  and l_file_header.file_type = itf_api_const_pkg.FT_OCP_FILE_TYPE then
                    l_inst_id := cst_institute_pkg.get_pc_mps_inst(i_inst_id => l_file_header.inst_id);
                    process_ocp_batch_trailer(
                            i_record_data => l_buffer(r.record_number)
                          , i_inst_id     => l_inst_id
                    );
                elsif l_rt = itf_api_const_pkg.RT_R_IBI_BATCH_TRAILER then
                    process_r_ibi_batch_trailer(
                            i_record_data => l_buffer(r.record_number)
                    );
                elsif l_rt in (itf_api_const_pkg.RT_IBI03_BATCH_TRAILER
                              ,itf_api_const_pkg.RT_IBI07_BATCH_TRAILER) then
                    l_inst_id := cst_institute_pkg.get_pc_abs_inst(i_inst_id => l_file_header.inst_id);
                    process_ibi_batch_trailer(
                            i_record_type => l_rt
                          , i_record_data => l_buffer(r.record_number)
                          , i_inst_id     => l_inst_id
                    );
                elsif l_rt = itf_api_const_pkg.RT_FILE_TRAILER then
                    process_file_trailer(
                            i_trailer_data      => l_buffer(r.record_number)
                          , o_file_trailer      => l_file_trailer
                    );
                end if;
                l_record_number := r.record_number;

                -- cleanup buffer before loading next record(s)
                --l_buffer.delete;
                if g_error_flag = com_api_type_pkg.TRUE then
                    l_errors_count := l_errors_count + 1;
                end if;
                if mod(r.rn, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_count + r.rn
                      , i_excepted_count => g_errors_count + l_errors_count
                    );
                end if;

                if r.rn_desc = 1 then
                    g_errors_count := g_errors_count + l_errors_count;
                    l_errors_count := 0;
                    l_count := l_count + r.cnt;

                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_count
                      , i_excepted_count => g_errors_count
                    );
                    trc_log_pkg.debug (i_text => 'Transactions:           '||to_char(r.cnt-2));
                    trc_log_pkg.debug (i_text => 'Processed successfully: '||to_char(r.cnt-2-g_errors_count));
                    trc_log_pkg.debug (i_text => 'Processed with errors:  '||to_char(g_errors_count));
                end if;
            end loop;

            prc_api_file_pkg.close_file(
                i_sess_file_id          => v.session_file_id
              , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        exception
            when com_api_error_pkg.e_application_error then
                rollback to sp_ocp_incoming_file;

                g_errors_count := g_errors_count + v.record_count;
                l_errors_count := 0;
                l_count        := l_count + v.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_count
                  , i_excepted_count => l_errors_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id          => v.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
        end;
    end loop;
    trc_log_pkg.debug (i_text => 'File Processing count [#1]', i_env_param1 => l_count);

    prc_api_stat_pkg.log_end (
          i_processed_total  => l_count
        , i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug (i_text => 'File Processing end');
exception
    when others then
        rollback to savepoint sp_ocp_start_load;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;
        
        trc_log_pkg.debug (i_text => 'File Processing end with error');

        if com_api_error_pkg.is_fatal_error(SQLCODE) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end;

    procedure load_operation_account is
        l_inst_id                 com_api_type_pkg.t_inst_id;
        l_oper_id                 com_api_type_pkg.t_long_id;
        l_oper_type               com_api_type_pkg.t_dict_value;
        l_account_id              com_api_type_pkg.t_medium_id;
        l_account_type            com_api_type_pkg.t_dict_value;
        l_account_number          com_api_type_pkg.t_account_number;
        l_customer_id             com_api_type_pkg.t_medium_id;
        l_oper_amount             com_api_type_pkg.t_money;
        l_oper_currency           com_api_type_pkg.t_curr_code;
        l_indicator               com_api_type_pkg.t_curr_code;
        l_oper_status             com_api_type_pkg.t_dict_value;
        l_oper_reason             com_api_type_pkg.t_dict_value;
        l_oper_date               date;
        l_host_date               date;
        l_originator_refnum       com_api_type_pkg.t_long_id;

        l_record_type             com_api_type_pkg.t_dict_value;
        l_session_files           com_api_type_pkg.t_number_tab;
        l_file_name               com_api_type_pkg.t_name_tab;
        l_raw_data                com_api_type_pkg.t_raw_tab;

        l_session_file_id         com_api_type_pkg.t_long_id;

        l_rec_raw                 com_api_type_pkg.t_raw_tab;
        l_rec_num                 com_api_type_pkg.t_integer_tab;

        l_estimated_count         com_api_type_pkg.t_long_id := 0;
        l_excepted_count          com_api_type_pkg.t_long_id := 0;
        l_processed_count         com_api_type_pkg.t_long_id := 0;

        l_file_excepted_count     com_api_type_pkg.t_long_id := 0;

        l_crc                     integer;

        procedure put_header (
            i_session_file_id     in com_api_type_pkg.t_long_id
        )  is
        begin
            l_file_excepted_count := 1;

            -- put header
            l_rec_raw(l_rec_raw.count + 1) :=
            -- Record Type
            itf_api_type_pkg.pad_char(itf_api_const_pkg.RT_FILE_HEADER, 8, 8)
            -- Record Number
            || itf_api_type_pkg.pad_number(l_file_excepted_count, 12, 12)
            -- Original File ID
            || itf_api_type_pkg.pad_number(to_char(i_session_file_id), 18, 18)
            -- Filler
            || ' '
            -- File Type
            || 'FTYPIBI '
            -- Date
            || itf_api_type_pkg.pad_char(to_char(get_sysdate, 'mmddyyyyy'), 8, 8)
            -- Time
            || itf_api_type_pkg.pad_char(to_char(get_sysdate, 'hhmmss'), 6, 6)
            -- Filler
            || ' '
            -- Institution ID
            || itf_api_type_pkg.pad_char(l_inst_id, 12, 12)
            -- Agent Institution ID
            || itf_api_type_pkg.pad_char(' ', 12, 12)
            -- Filler
            || ' '
            -- FE Settlement
            || itf_api_type_pkg.pad_char(' ', 8, 8)
            -- FE Settlement Time
            || itf_api_type_pkg.pad_char(' ', 6, 6)
            -- BO Settlement Day Start Date
            || itf_api_type_pkg.pad_char(' ', 8, 8)
            -- BO Settlement Day Start Time
            || itf_api_type_pkg.pad_char(' ', 6, 6)
            -- BO Settlement Day Number
            || itf_api_type_pkg.pad_char(' ', 6, 6)
            -- Filler
            || itf_api_type_pkg.pad_char(' ', 377, 377)
            ;
            l_rec_num(l_rec_num.count + 1) := l_file_excepted_count;

            l_crc := itf_api_utils_pkg.crc32 (
                i_raw_data  => l_rec_raw(l_rec_raw.count)
                , i_crc     => l_crc
            );
        end;

        procedure open_file is
        begin
            --l_session_file_id := 123456;
            prc_api_file_pkg.open_file (
                o_sess_file_id    => l_session_file_id
                , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
            );
            --dbms_output.put_line('open_file');
        end;

        procedure close_file is
        begin
            l_file_excepted_count := l_file_excepted_count + 1;

            -- put trailer
            l_rec_raw(l_rec_raw.count + 1) :=
            -- Record Type
            itf_api_type_pkg.pad_char(itf_api_const_pkg.RT_FILE_TRAILER, 8, 8)
            -- Record Number
            || itf_api_type_pkg.pad_number(l_file_excepted_count, 12, 12)
            -- Last Record Flag
            || itf_api_const_pkg.LR_FLAG
            -- Hash Totals
            || itf_api_type_pkg.pad_number(trim(to_char(l_crc,'XXXXXXXX')), 8, 8)
            -- Filler
            || itf_api_type_pkg.pad_char(' ', 468, 468)
            ;
            l_rec_num(l_rec_num.count + 1) := l_file_excepted_count;

            /*for j in 1 .. l_rec_raw.count loop
                dbms_output.put_line('record_number:'||l_rec_num(j));
                dbms_output.put_line(l_rec_raw(j));
            end loop;*/

            prc_api_file_pkg.put_bulk (
                i_sess_file_id  => l_session_file_id
                , i_raw_tab     => l_rec_raw
                , i_num_tab     => l_rec_num
            );

            --dbms_output.put_line('close_file');
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );

            l_session_file_id := null;
            l_file_excepted_count := 0;
            l_rec_raw.delete;
            l_rec_num.delete;

        end;

        procedure mark_error is
        begin
            /*for j in 1 .. l_rec_raw.count loop
                dbms_output.put_line('record_number:'||l_rec_num(j));
                dbms_output.put_line(l_rec_raw(j));
            end loop;*/
            prc_api_file_pkg.put_bulk (
                i_sess_file_id  => l_session_file_id
                , i_raw_tab     => l_rec_raw
                , i_num_tab     => l_rec_num
            );
            l_rec_raw.delete;
            l_rec_num.delete;
        end;

        procedure register_error (
            i_session_file_id     in com_api_type_pkg.t_long_id
            , i_message_number    in binary_integer
        ) is
        begin
            l_file_excepted_count := l_file_excepted_count + 1;

            -- put body
            l_rec_raw(l_rec_raw.count + 1) :=
            -- Record Type
            itf_api_type_pkg.pad_char(itf_api_const_pkg.RT_R_IBI_BATCH_TRAILER, 8, 8)
            -- Record Number
            || itf_api_type_pkg.pad_number(l_file_excepted_count, 12, 12)
            -- Filler
            || ' '
            -- Original File ID
            || itf_api_type_pkg.pad_number(to_char(i_session_file_id), 18, 18)
            -- Rejected message number
            || itf_api_type_pkg.pad_number(to_char(i_message_number), 12, 12)
            -- Filler
            || ' '
            -- Reason for reject
            || itf_api_type_pkg.pad_char(l_oper_reason, 8, 8)
            -- Reason for description
            || itf_api_type_pkg.pad_char(get_article_text(i_article => l_oper_reason), 100, 100)
            -- Filler
            || ' '
            -- Reference
            || itf_api_type_pkg.pad_number(l_originator_refnum, 16, 16)
            -- Filler
            || ' '
            ;
            l_rec_num(l_rec_num.count + 1) := l_file_excepted_count;

            l_crc := itf_api_utils_pkg.crc32 (
                i_raw_data  => l_rec_raw(l_rec_raw.count)
                , i_crc     => l_crc
            );
        end;

        procedure check_error is
        begin
            if l_rec_num.count >= BULK_LIMIT then
                mark_error;
            end if;
        end;
    begin
        savepoint sp_start_loading;

        trc_log_pkg.debug (
            i_text          => 'starting loading payments to / withdrawals from account'
        );

        prc_api_stat_pkg.log_start;

        trc_log_pkg.debug (
            i_text          => 'enumerating messages'
        );
        -- estimate records for load
        select
            count(s.id)
        into
            l_estimated_count
        from
            prc_session_file s
            , prc_file_raw_data d
            , prc_file_attribute a
            , prc_file f
        where
            s.session_id = get_session_id
            and s.id = d.session_file_id
            and a.file_id = f.id
            and s.file_attr_id = a.id
            and f.file_purpose = prc_api_file_pkg.get_file_purpose_in;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count => l_estimated_count
        );

        select
            id
            , file_name
        bulk collect into
            l_session_files
            , l_file_name
        from
            prc_session_file
        where
            session_id = get_session_id
        order by
            id;

        for i in 1..l_session_files.count loop
            trc_log_pkg.debug (
                i_text          => 'Process file [#1]'
                , i_env_param1  => l_file_name(i)
            );

            -- open r file
            open_file;

            select
                d.raw_data
            bulk collect into
                l_raw_data
            from
                prc_file_raw_data d
            where
                d.session_file_id = l_session_files(i)
            order by
                d.record_number;

            for j in 1 .. l_raw_data.count loop
                begin
                    savepoint process_operation;

                    l_oper_id := null;
                    l_record_type := substr(l_raw_data(j), 1, 6);

                    case l_record_type
                    when itf_api_const_pkg.RT_FILE_HEADER then
                        l_inst_id := trim(substr(l_raw_data(j), 63, 4));

                        -- put header r file
                        put_header (
                            i_session_file_id   => l_session_files(i)
                        );

                    when itf_api_const_pkg.RT_IBI03_BATCH_TRAILER then

                        l_account_number := trim(substr(l_raw_data(j), 21, 32));
                        l_account_type := trim(substr(l_raw_data(j), 53, 8));
                        l_oper_amount := to_number(trim(substr(l_raw_data(j), 62, 16)));
                        l_indicator := substr(l_raw_data(j), 78, 2);
                        l_oper_currency := substr(l_raw_data(j), 80, 3);
                        l_oper_date := to_date(substr(l_raw_data(j), 84, 8),'MMDDYYYY');
                        l_host_date := to_date(substr(l_raw_data(j), 92, 8),'MMDDYYYY');
                        l_oper_reason := substr(l_raw_data(j), 101, 8);
                        l_originator_refnum := to_number(trim(substr(l_raw_data(j), 113, 16)));

                        case l_indicator
                        when itf_api_const_pkg.DC_IND_DEBIT then
                            l_oper_type := 'OPTP0400';
                        when itf_api_const_pkg.DC_IND_DEBIT_ADJUSTMENT then
                            l_oper_type := 'OPTP0402';
                        when itf_api_const_pkg.DC_IND_CREDIT then
                            l_oper_type := 'OPTP0428';
                        when itf_api_const_pkg.DC_IND_CREDIT_ADJUSTMENT then
                            l_oper_type := 'OPTP0422';
                        else
                            trc_log_pkg.debug (
                                i_text          => 'Unsupported indicator [#1]'
                                , i_env_param1  => l_indicator
                            );
                        end case;

                        select
                            min(id)
                            , min(customer_id)
                        into
                            l_account_id
                            , l_customer_id
                        from
                            acc_account_vw
                        where
                            account_number = l_account_number;

                        opr_api_create_pkg.create_operation (
                            io_oper_id                   => l_oper_id
                            , i_session_id               => get_session_id
                            , i_is_reversal              => com_api_type_pkg.FALSE
                            , i_original_id              => null
                            , i_oper_type                => l_oper_type
                            , i_oper_reason              => null
                            , i_msg_type                 => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                            , i_status                   => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                            , i_status_reason            => l_oper_reason
                            , i_sttl_type                => opr_api_const_pkg.SETTLEMENT_INTERNAL
                            , i_terminal_type            => null
                            , i_acq_inst_bin             => null
                            , i_forw_inst_bin            => null
                            , i_merchant_number          => null
                            , i_terminal_number          => null
                            , i_merchant_name            => null
                            , i_merchant_street          => null
                            , i_merchant_city            => null
                            , i_merchant_region          => null
                            , i_merchant_country         => null
                            , i_merchant_postcode        => null
                            , i_mcc                      => null
                            , i_originator_refnum        => l_originator_refnum
                            , i_network_refnum           => null
                            , i_oper_count               => 1
                            , i_oper_request_amount      => l_oper_amount * 100
                            , i_oper_amount_algorithm    => null
                            , i_oper_amount              => l_oper_amount * 100
                            , i_oper_currency            => l_oper_currency
                            , i_oper_cashback_amount     => null
                            , i_oper_replacement_amount  => null
                            , i_oper_surcharge_amount    => null
                            , i_oper_date                => l_oper_date
                            , i_host_date                => l_host_date
                            , i_match_status             => null
                            , i_sttl_amount              => null
                            , i_sttl_currency            => null
                            , i_dispute_id               => null
                            , i_payment_order_id         => null
                            , i_payment_host_id          => null
                            , i_forced_processing        => null
                        );

                        opr_api_create_pkg.add_participant (
                            i_oper_id             => l_oper_id
                            , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                            , i_oper_type         => opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                            , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
                            , i_client_id_type    => aup_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT
                            , i_client_id_value   => l_account_number
                            , i_inst_id           => l_inst_id
                            , i_customer_id       => l_customer_id
                            , i_account_id        => l_account_id
                            , i_account_number    => l_account_number
                            , i_account_type      => l_account_type
                            , i_without_checks    => com_api_const_pkg.TRUE
                        );

                        opr_api_process_pkg.process_operation(
                            i_operation_id  => l_oper_id
                          , i_stage         => opr_api_const_pkg.PROCESSING_STAGE_UDEFINED
                          , i_mask_error    => com_api_type_pkg.TRUE
                        );

                        select
                            status
                            , status_reason
                        into
                            l_oper_status
                            , l_oper_reason
                        from
                            opr_operation
                        where
                            id = l_oper_id;

                        trc_log_pkg.debug (
                            i_text          => 'After operation[#1]: status[#2], reason[#3]'
                            , i_env_param1  => l_oper_id
                            , i_env_param2  => l_oper_status
                            , i_env_param3  => l_oper_reason
                        );
                        if l_oper_status != opr_api_const_pkg.OPERATION_STATUS_PROCESSED then
                            com_api_error_pkg.raise_error (
                                i_error        => 'ERROR_PROCESSING_OPERATION'
                                , i_env_param1  => l_oper_id
                                , i_env_param2  => com_api_error_pkg.get_last_error_id
                            );
                        end if;

                    when itf_api_const_pkg.RT_FILE_TRAILER then
                        null;

                    else
                        null;
                    end case;

                    l_processed_count := l_processed_count + 1;
                exception
                    when com_api_error_pkg.e_application_error then
                        rollback to savepoint process_operation;

                        register_error (
                            i_session_file_id   => l_session_files(i)
                            , i_message_number  => j
                        );
                        l_excepted_count := l_excepted_count + 1;
                end;

                check_error;
            end loop;

            prc_api_stat_pkg.log_current (
                i_current_count     => l_processed_count
                , i_excepted_count  => l_excepted_count
            );

            -- clear
            l_raw_data.delete;

            mark_error;
            -- close r file
            close_file;
        end loop;

        trc_log_pkg.debug (
            i_text          => 'finished loading payments to / withdrawals from account'
        );

        prc_api_stat_pkg.log_end (
            i_excepted_total     => l_excepted_count
            , i_processed_total  => l_processed_count
            , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            rollback to savepoint sp_start_loading;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => sqlerrm
                );
            end if;

            raise;
    end;
    
    procedure process_account_event(
        i_event_type               in  com_api_type_pkg.t_dict_value
      , i_entity_type              in  com_api_type_pkg.t_dict_value   default null
      , i_account_number_column    in  com_api_type_pkg.t_name         default null
      , i_separate_char            in  com_api_type_pkg.t_byte_char    default null
    )
    is
        LOG_PREFIX                     constant com_api_type_pkg.t_name        := lower($$PLSQL_UNIT) || '.process_account_event: ';
        ACCOUNT_NUMBER_COLUMN_DEFAULT  constant com_api_type_pkg.t_name        := 'ACCOUNT NUMBER';
        DELIMETER                      constant com_api_type_pkg.t_byte_char   := ';';
        
        type account_data_by_num_tab   is table of acc_api_type_pkg.t_account_rec index by com_api_type_pkg.t_oracle_name;
        
        l_record_count      com_api_type_pkg.t_long_id := 0;
        l_estimated_count   com_api_type_pkg.t_long_id := 0;
        l_excepted_count    com_api_type_pkg.t_long_id := 0;
        l_processed_count   com_api_type_pkg.t_long_id := 0;
        l_errors_count      com_api_type_pkg.t_long_id := 0;
        
        l_count             com_api_type_pkg.t_long_id := 0;
        l_eff_date          date                       := get_sysdate;
        
        l_header_flag       com_api_type_pkg.t_boolean;
        l_err_read_flag     com_api_type_pkg.t_boolean;
        
        l_param_tab         com_api_type_pkg.t_param_tab;
        
        l_locate_account_number    com_api_type_pkg.t_tiny_id;
        
        l_account_rec              acc_api_type_pkg.t_account_rec;
        
        l_account_number_tab       account_data_by_num_tab;
        l_array_index              com_api_type_pkg.t_oracle_name;
        l_index                    com_api_type_pkg.t_long_id := 0;
        
        cursor cu_records_count is
            select count(1)
              from prc_file_raw_data a
                 , prc_session_file b
             where b.session_id      = prc_api_session_pkg.get_session_id
               and a.session_file_id = b.id;
        
        function get_element_position(
            i_header               com_api_type_pkg.t_raw_data
          , i_col_name             com_api_type_pkg.t_name
          , i_separate_char        com_api_type_pkg.t_byte_char
        ) return com_api_type_pkg.t_tiny_id
        is
            l_result       com_api_type_pkg.t_tiny_id;
            l_instr        com_api_type_pkg.t_tiny_id;
        begin
            l_instr := instr(i_header, i_col_name);
            
            if l_instr = 1 then
                l_result := l_instr;
            elsif l_instr > 1 then
                l_result := 0;
                for i in 1 .. l_instr - 1
                loop
                    if substr(i_header, i, 1) = i_separate_char then
                        l_result := l_result + 1;
                    end if;
                end loop;
                l_result := l_result + 1;
            else
                com_api_error_pkg.raise_error(
                    i_error         => 'UNABLE_TO_PARSE_RECORD'
                  , i_env_param1    => 'HEADER'
                  , i_env_param2    => i_header
                );
            end if;
            
            return l_result;
        end get_element_position;
        
        function get_element_value(
            i_raw_data             com_api_type_pkg.t_raw_data
          , i_element_position     com_api_type_pkg.t_tiny_id
          , i_separate_char        com_api_type_pkg.t_byte_char
        ) return com_api_type_pkg.t_oracle_name
        is
            l_result       com_api_type_pkg.t_oracle_name;
            l_element_beg  com_api_type_pkg.t_tiny_id;
            l_element_len  com_api_type_pkg.t_tiny_id;
        begin
            if i_element_position = 1 then
                l_element_beg := i_element_position;
            elsif i_element_position > 1 then
                l_element_beg := instr(i_raw_data, i_separate_char, 1, i_element_position - 1) + 1;
            else
                com_api_error_pkg.raise_error(
                    i_error         => 'UNABLE_TO_PARSE_RECORD'
                  , i_env_param1    => 'RAW'
                  , i_env_param2    => i_raw_data
                );
            end if;
            
            l_element_len := case 
                                 when instr(i_raw_data, i_separate_char, 1, i_element_position) > 0
                                     then instr(i_raw_data, i_separate_char, 1, i_element_position) - l_element_beg
                                 when instr(i_raw_data, i_separate_char, 1, i_element_position) = 0
                                     then length(substr(i_raw_data, l_element_beg))
                                 else
                                     null
                             end;
                             
            if l_element_len is null then
                com_api_error_pkg.raise_error(
                    i_error         => 'UNABLE_TO_PARSE_RECORD'
                  , i_env_param1    => 'RAW'
                  , i_env_param2    => i_raw_data
                );
            end if;
            
            l_result := substr(i_raw_data, l_element_beg, l_element_len);
            
            if l_result is null then
                com_api_error_pkg.raise_error(
                    i_error         => 'UNABLE_TO_PARSE_RECORD'
                  , i_env_param1    => 'RAW'
                  , i_env_param2    => i_raw_data
                );
            end if;
            
            return l_result;
        end get_element_value;
    begin
        
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'Start with params: event_type [#1], entity_type [#2], account_number_column [#3], separate_char {#4]'
          , i_env_param1 => i_event_type
          , i_env_param2 => i_entity_type
          , i_env_param3 => i_account_number_column
          , i_env_param4 => i_separate_char
        );
        
        prc_api_stat_pkg.log_start;

        open cu_records_count;
        fetch cu_records_count into l_record_count;
        close cu_records_count;
        
        trc_log_pkg.debug(i_text => LOG_PREFIX || 'FOUND ' || l_record_count || ' IN FILE');

        for p in (
            select id session_file_id
              from prc_session_file
             where session_id = prc_api_session_pkg.get_session_id
             order by id
        ) loop
            trc_log_pkg.debug(
                i_text => 'Processing session_file_id [' || p.session_file_id
                       || ']'
            );
            l_errors_count := 0;
            l_count := 0;
            l_locate_account_number := null;
            l_header_flag           := null;
            l_err_read_flag         := com_api_const_pkg.FALSE;
            for r in (
                select record_number
                     , raw_data
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number asc
            ) loop
            begin
                l_account_rec.account_number := null;
                l_account_rec.account_id     := null;
                if l_header_flag is null then
                    if upper(r.raw_data) like '%' || upper(nvl(i_account_number_column, ACCOUNT_NUMBER_COLUMN_DEFAULT)) || '%' then
                        l_header_flag := com_api_const_pkg.TRUE;
                    else
                        l_header_flag := com_api_const_pkg.FALSE;
                    end if;
                    if l_header_flag = com_api_const_pkg.FALSE then
                        l_locate_account_number      := 1;
                        l_estimated_count            := l_estimated_count + 1;
                        l_account_rec.account_number := replace(r.raw_data, nvl(i_separate_char, DELIMETER), '');
                        l_account_rec                := acc_api_account_pkg.get_account(
                                                            i_account_id     => null
                                                          , i_account_number => l_account_rec.account_number
                                                          , i_inst_id        => null
                                                          , i_mask_error     => com_api_const_pkg.FALSE
                                                        );
                    else
                        l_locate_account_number := get_element_position(
                                                       i_header        => upper(r.raw_data)
                                                     , i_col_name      => upper(nvl(i_account_number_column, ACCOUNT_NUMBER_COLUMN_DEFAULT))
                                                     , i_separate_char => nvl(i_separate_char, DELIMETER)
                                                   );
                    end if;
                else
                    l_estimated_count            := l_estimated_count + 1;
                    l_account_rec.account_number := get_element_value(                             
                                                        i_raw_data         => r.raw_data
                                                      , i_element_position => l_locate_account_number
                                                      , i_separate_char    => nvl(i_separate_char, DELIMETER)
                                                    );
                    l_account_rec := acc_api_account_pkg.get_account(
                                         i_account_id     => null
                                       , i_account_number => l_account_rec.account_number
                                       , i_inst_id        => null
                                       , i_mask_error     => com_api_const_pkg.FALSE
                                     );
                end if;
                    
                if l_account_rec.account_number is not null
                   and not l_account_number_tab.exists(l_account_rec.account_number)
                then
                    l_account_number_tab(l_account_rec.account_number) := l_account_rec;
                end if;
                l_count := r.record_number;
            exception
                when others then
                    if l_locate_account_number is null then
                        l_err_read_flag := com_api_const_pkg.TRUE;
                        exit;
                    else
                        l_excepted_count := l_excepted_count + 1;
                    end if;
            end;
            end loop;
            trc_log_pkg.debug(
                i_text => 'Processing session_file_id [' || p.session_file_id
                       || '] finished, record_count [' || nvl(l_count, 0) || ']'
            );
            if l_err_read_flag = com_api_const_pkg.TRUE then
                prc_api_file_pkg.close_file(
                    i_sess_file_id => p.session_file_id
                  , i_status       => prc_api_const_pkg.FILE_STATUS_REJECTED
                  , i_record_count => nvl(l_count, 0)
                );
            else
                prc_api_file_pkg.close_file(
                    i_sess_file_id => p.session_file_id
                  , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                  , i_record_count => nvl(l_count, 0)
                );
            
            end if;    

        end loop;
        prc_api_stat_pkg.log_estimation (
            i_estimated_count => l_estimated_count
        );
        if l_account_number_tab.count > 0 then
            l_array_index := l_account_number_tab.first;
            l_index       := 1;
            loop
                exit when l_array_index is null or l_index > l_account_number_tab.count;
                begin
                    evt_api_event_pkg.register_event(
                        i_event_type  => i_event_type
                      , i_eff_date    => l_eff_date
                      , i_entity_type => nvl(i_entity_type, acc_api_const_pkg.ENTITY_TYPE_ACCOUNT)
                      , i_object_id   => l_account_number_tab(l_array_index).account_id
                      , i_inst_id     => l_account_number_tab(l_array_index).inst_id
                      , i_split_hash  => l_account_number_tab(l_array_index).split_hash
                      , i_param_tab   => l_param_tab
                    );
                        
                    l_processed_count := l_processed_count + 1;
                        
                exception
                    when others then
                        l_excepted_count := l_excepted_count + 1;
                        trc_log_pkg.debug(
                            i_text => LOG_PREFIX || 'Error register event: ' || SQLERRM
                                   || ' account_number - ' || l_array_index
                        );
                end;
                l_array_index := l_account_number_tab.next(l_array_index);
                l_index       := l_index + 1;
            end loop;
        end if;

        prc_api_stat_pkg.log_end(
            i_processed_total => l_processed_count
          , i_excepted_total  => l_excepted_count
          , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

        trc_log_pkg.debug(LOG_PREFIX || 'Finished success');
        
    exception
        when others then
            if cu_records_count%isopen then
                
                close cu_records_count;
                
            end if;

            prc_api_stat_pkg.log_end(
                i_processed_total => l_processed_count
              , i_excepted_total  => l_excepted_count
              , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
                
                raise;
                
            elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                
                raise;
                
            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                
                com_api_error_pkg.raise_fatal_error(
                    i_error      => 'UNHANDLED_EXCEPTION'
                  , i_env_param1 => sqlerrm
                );
                
            end if;
            
    end ;

end;
/
