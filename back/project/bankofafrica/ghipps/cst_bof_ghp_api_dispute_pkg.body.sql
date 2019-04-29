create or replace package body cst_bof_ghp_api_dispute_pkg is

procedure update_dispute_id(
    i_id                            in     com_api_type_pkg.t_long_id
  , i_dispute_id                    in     com_api_type_pkg.t_long_id
) is
begin
    update cst_bof_ghp_fin_msg
       set dispute_id = i_dispute_id
     where id = i_id;

    update opr_operation
       set dispute_id = i_dispute_id
     where id = i_id;
end;

procedure generate_message_draft(
    o_fin_id                           out com_api_type_pkg.t_long_id
  , i_original_fin_id               in     com_api_type_pkg.t_long_id
  , i_select_item                   in     binary_integer
  , i_oper_amount                   in     com_api_type_pkg.t_money         default null
  , i_oper_currency                 in     com_api_type_pkg.t_curr_code     default null
  , i_member_msg_text               in     com_api_type_pkg.t_name          default null
  , i_docum_ind                     in     com_api_type_pkg.t_name          default null
  , i_usage_code                    in     com_api_type_pkg.t_name          default null
  , i_spec_chargeback_ind           in     com_api_type_pkg.t_name          default null
  , i_reason_code                   in     com_api_type_pkg.t_name          default null
  , i_message_reason_code           in     com_api_type_pkg.t_dict_value    default null
  , i_dispute_condition             in     com_api_type_pkg.t_curr_code     default null
  , i_vrol_financial_id             in     com_api_type_pkg.t_region_code   default null
  , i_vrol_case_number              in     com_api_type_pkg.t_postal_code   default null
  , i_vrol_bundle_number            in     com_api_type_pkg.t_postal_code   default null
  , i_client_case_number            in     com_api_type_pkg.t_attr_name     default null
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.generate_message_draft ';
    l_fin_rec                       cst_bof_ghp_api_type_pkg.t_ghp_fin_mes_rec;
    l_host_id                       com_api_type_pkg.t_tiny_id;
    l_standard_id                   com_api_type_pkg.t_tiny_id;
    l_dispute_id                    com_api_type_pkg.t_long_id;
    l_count                         com_api_type_pkg.t_boolean;
    l_stage                         com_api_type_pkg.t_name;
    l_trans_code_1                  com_api_type_pkg.t_byte_char;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_original_fin_id [#1], i_select_item [#2]'
      , i_env_param1 => i_original_fin_id
      , i_env_param2 => i_select_item
    );

    cst_bof_ghp_api_fin_msg_pkg.get_fin_message(
        i_id       => i_original_fin_id
      , o_fin_rec  => l_fin_rec
    );

    l_dispute_id := l_fin_rec.dispute_id;
    if l_fin_rec.dispute_id is null then
        l_fin_rec.dispute_id := dsp_api_shared_data_pkg.get_id();
    end if;

    -- Update original message
    if l_dispute_id is null then
        update_dispute_id(
            i_id          => i_original_fin_id
          , i_dispute_id  => l_fin_rec.dispute_id
        );
    end if;

    -- Checks
    if i_select_item in (cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_FIRST_PRES
                       , cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_SECOND_PRES
                       , cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_PRES_CHRGBCK)
    then
        l_trans_code_1 :=
            case i_select_item
                when cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_PRES_CHRGBCK
                then '3'
                else '2'
            end;

        select case when count(id) > 0 then 1 else 0 end
          into l_count
          from cst_bof_ghp_fin_msg
         where dispute_id               = l_fin_rec.dispute_id
           and substr(trans_code, 1, 1) = l_trans_code_1;

        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error      => 'DISPUTE_DOUBLE_REVERSAL'
              , i_env_param1 => l_fin_rec.dispute_id
            );
        end if;
    end if;

    if i_select_item in (cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_FIRST_PRES
                       , cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_SECOND_PRES)
    then
        if nvl(l_fin_rec.oper_amount, 0) < nvl(i_oper_amount, 0) then
            com_api_error_pkg.raise_error(
                i_error       => 'REVERSAL_AMOUNT_GREATER_ORIGINAL_AMOUNT'
              , i_env_param1  => nvl(l_fin_rec.oper_amount, 0)
              , i_env_param2  => nvl(i_oper_amount, 0)
            );
        end if;
    end if;

    l_stage := 'init';

    o_fin_id               := opr_api_create_pkg.get_id();
    l_fin_rec.id           := o_fin_id;
    l_fin_rec.is_returned  := com_api_const_pkg.FALSE;
    l_fin_rec.is_incoming  := com_api_const_pkg.FALSE;
    l_fin_rec.file_id      := null;
    l_fin_rec.status       := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
    l_fin_rec.logical_file := cst_bof_ghp_api_const_pkg.TC_FL_HEADER;

    l_fin_rec.is_reversal :=
        case i_select_item
            when cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_FIRST_PRES   then com_api_const_pkg.TRUE
            when cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_SECOND_PRES  then com_api_const_pkg.TRUE
            when cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_PRES_CHRGBCK then com_api_const_pkg.TRUE
                                                                          else com_api_const_pkg.FALSE
        end;

    l_fin_rec.trans_code :=
        case i_select_item
            when cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_FIRST_PRES    -- 1 - Reversal on First Presentment
                then '2' || substr(l_fin_rec.trans_code, 2)    -- TC_*_REVERSAL
            when cst_bof_ghp_api_const_pkg.DSP_ITEM_FIRST_CHARGEBACK       -- 2 - Chargeback on TC05, TC06, TC07
                then '1' || substr(l_fin_rec.trans_code, 2)    -- TC_*_CHARGEBACK
            when cst_bof_ghp_api_const_pkg.DSP_ITEM_SECOND_PRESENTMENT     -- 3 - Second Presentment on TC05, TC06, TC07
                then '0' || substr(l_fin_rec.trans_code, 2)    -- TC_*
            when cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_SECOND_PRES   -- 4 - Reversal on Second Presentment
                then '2' || substr(l_fin_rec.trans_code, 2)    -- TC_*_REVERSAL
            when cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_PRES_CHRGBCK  -- 5 - Presentment Chargeback Reversal
                then '3' || substr(l_fin_rec.trans_code, 2)    -- TC_*_CHARGEBACK_REV
            when cst_bof_ghp_api_const_pkg.DSP_ITEM_SECOND_PRES_CHRGBCK    -- 6 - Chargeback on Second Presentment
                then '1' || substr(l_fin_rec.trans_code, 2)    -- TC_*_CHARGEBACK
            else
                l_fin_rec.trans_code
        end;

    if i_select_item in (cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_PRES_CHRGBCK) then
        l_fin_rec.sttl_amount   := l_fin_rec.oper_amount;
        l_fin_rec.sttl_currency := l_fin_rec.oper_currency;
    else
        l_fin_rec.sttl_amount   := i_oper_amount;
        l_fin_rec.sttl_currency := i_oper_currency;
        l_fin_rec.oper_amount   := i_oper_amount;
        l_fin_rec.oper_currency := i_oper_currency;
    end if;

    l_fin_rec.usage_code :=
        case
            when i_select_item in (cst_bof_ghp_api_const_pkg.DSP_ITEM_SECOND_PRESENTMENT
                                 , cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_SECOND_PRES)
                then '2'
            when i_select_item in (cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_FIRST_PRES)
                then '1'
            when i_select_item in (cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_PRES_CHRGBCK)
                then l_fin_rec.usage_code
            else
                i_usage_code
        end;

    l_fin_rec.reason_code :=
        case
            when i_select_item in (cst_bof_ghp_api_const_pkg.DSP_ITEM_FIRST_CHARGEBACK
                                 , cst_bof_ghp_api_const_pkg.DSP_ITEM_SECOND_PRES_CHRGBCK)
            then i_reason_code
            else l_fin_rec.reason_code
        end;

    l_fin_rec.chargeback_ref_num :=
        case
            when i_select_item in (cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_PRES_CHRGBCK
                                 , cst_bof_ghp_api_const_pkg.DSP_ITEM_SECOND_PRESENTMENT)
                then l_fin_rec.chargeback_ref_num
            when i_select_item in (cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_FIRST_PRES)
             and l_dispute_id is null
                then lpad('0', 6, '0')
            when i_select_item not in (cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_FIRST_PRES)
             and l_dispute_id is null
                then lpad(nvl(to_char(mod(l_fin_rec.dispute_id, 1000000)), '0'), 6, '0')
            else
                null
        end;

    l_fin_rec.docum_ind :=
        case
            when i_select_item in (cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_FIRST_PRES
                                 , cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_SECOND_PRES
                                 , cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_PRES_CHRGBCK)
            then l_fin_rec.docum_ind
            else i_docum_ind
        end;

    l_fin_rec.member_msg_text :=
        case
            when i_select_item in (cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_FIRST_PRES
                                 , cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_SECOND_PRES
                                 , cst_bof_ghp_api_const_pkg.DSP_ITEM_RVRSL_ON_PRES_CHRGBCK)
            then l_fin_rec.member_msg_text
            else i_member_msg_text
        end;

    l_fin_rec.spec_chargeback_ind :=
        case
            when i_select_item in (cst_bof_ghp_api_const_pkg.DSP_ITEM_FIRST_CHARGEBACK
                                 , cst_bof_ghp_api_const_pkg.DSP_ITEM_SECOND_PRES_CHRGBCK)
                then l_fin_rec.spec_chargeback_ind
            when i_select_item in (cst_bof_ghp_api_const_pkg.DSP_ITEM_SECOND_PRESENTMENT)
                then ' '
            else
                i_spec_chargeback_ind
        end;

    l_host_id     := net_api_network_pkg.get_default_host(i_network_id => l_fin_rec.network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

    l_stage  := 'put_message';
    o_fin_id := cst_bof_ghp_api_fin_msg_pkg.put_message(i_fin_rec => l_fin_rec);

    l_stage := 'create_operation';
    cst_bof_ghp_api_fin_msg_pkg.create_operation(
        i_fin_rec      => l_fin_rec
      , i_standard_id  => l_standard_id
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> dispute message draft ID [#1]'
      , i_env_param1 => l_fin_rec.id
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'FAILED on stage [' || l_stage || ']: ' || sqlerrm
        );
        raise;
end generate_message_draft;

procedure generate_retrieval_request(
    o_fin_id                           out com_api_type_pkg.t_long_id
  , i_original_fin_id               in     com_api_type_pkg.t_long_id
  , i_trans_code                    in     com_api_type_pkg.t_byte_char
  , i_billing_amount                in     com_api_type_pkg.t_money
  , i_billing_currency              in     com_api_type_pkg.t_curr_code
  , i_reason_code                   in     com_api_type_pkg.t_name
  , i_document_type                 in     com_api_type_pkg.t_byte_char
  , i_card_iss_ref_num              in     com_api_type_pkg.t_name
  , i_cancellation_ind              in     com_api_type_pkg.t_byte_char
  , i_response_type                 in     com_api_type_pkg.t_byte_char
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.generate_retrieval_request ';
    l_original_fin_rec              cst_bof_ghp_api_type_pkg.t_ghp_fin_mes_rec;
    l_fin_rec                       cst_bof_ghp_api_type_pkg.t_ghp_fin_mes_rec;
    l_retrieval_rec                 cst_bof_ghp_api_type_pkg.t_retrieval_rec;
    l_dispute_id                    com_api_type_pkg.t_long_id;
    l_stage                         varchar2(100);
    l_host_id                       com_api_type_pkg.t_tiny_id;
    l_standard_id                   com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_original_fin_id [#1], i_billing_amount [#2], i_billing_currency [#3]'
      , i_env_param1 => i_original_fin_id
      , i_env_param2 => i_billing_amount
      , i_env_param3 => i_billing_currency
    );

    cst_bof_ghp_api_fin_msg_pkg.get_fin_message(
        i_id       => i_original_fin_id
      , o_fin_rec  => l_original_fin_rec
    );

    l_dispute_id := l_original_fin_rec.dispute_id;
    if l_original_fin_rec.dispute_id is null then
        l_original_fin_rec.dispute_id := dsp_api_shared_data_pkg.get_id();
    end if;

    -- Update original mesage
    if l_dispute_id is null then
        update_dispute_id(
            i_id          => i_original_fin_id
          , i_dispute_id  => l_original_fin_rec.dispute_id
        );
    end if;

    l_fin_rec.dispute_id := l_original_fin_rec.dispute_id;

    l_stage := 'init';
    o_fin_id                    := opr_api_create_pkg.get_id;
    l_fin_rec.id                := o_fin_id;
    l_fin_rec.is_returned       := com_api_const_pkg.FALSE;
    l_fin_rec.is_incoming       := com_api_const_pkg.FALSE;
    l_fin_rec.is_reversal       := com_api_const_pkg.FALSE;
    l_fin_rec.is_invalid        := com_api_const_pkg.FALSE;
    l_fin_rec.file_id           := null;
    l_fin_rec.status            := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
    l_fin_rec.logical_file      := cst_bof_ghp_api_const_pkg.TC_FL_HEADER;

    l_fin_rec.trans_code        := i_trans_code;
    l_fin_rec.usage_code        := l_original_fin_rec.usage_code;
    l_fin_rec.card_number       := l_original_fin_rec.card_number;
    l_fin_rec.card_hash         := l_original_fin_rec.card_hash;
    l_fin_rec.card_mask         := l_original_fin_rec.card_mask;
    l_fin_rec.arn               := l_original_fin_rec.arn;
    l_fin_rec.merchant_name     := l_original_fin_rec.merchant_name;
    l_fin_rec.merchant_city     := l_original_fin_rec.merchant_city;
    l_fin_rec.merchant_country  := l_original_fin_rec.merchant_country;
    l_fin_rec.mcc               := l_original_fin_rec.mcc;
    l_fin_rec.merchant_region   := l_original_fin_rec.merchant_region;
    l_fin_rec.inst_id           := l_original_fin_rec.inst_id;
    l_fin_rec.network_id        := l_original_fin_rec.network_id;
    l_fin_rec.host_inst_id      := l_original_fin_rec.host_inst_id;
    l_fin_rec.proc_bin          := l_original_fin_rec.proc_bin;
    l_fin_rec.account_selection := l_original_fin_rec.account_selection;
    l_fin_rec.oper_date         := l_original_fin_rec.oper_date;
    l_fin_rec.oper_amount       := nvl(i_billing_amount,   l_original_fin_rec.oper_amount);
    l_fin_rec.oper_currency     := nvl(i_billing_currency, l_original_fin_rec.oper_currency);

    l_host_id := net_api_network_pkg.get_default_host(i_network_id => l_fin_rec.network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

    l_stage := 'put_message';
    o_fin_id := cst_bof_ghp_api_fin_msg_pkg.put_message(i_fin_rec => l_fin_rec);

    l_stage := 'set_retrieval';
    l_retrieval_rec.id          := l_fin_rec.id;
    l_retrieval_rec.iss_inst_id := net_api_network_pkg.get_inst_id(l_original_fin_rec.network_id);
    l_retrieval_rec.acq_inst_id := l_original_fin_rec.inst_id;

    l_retrieval_rec.document_type                := i_document_type;
    l_retrieval_rec.card_iss_ref_num             := i_card_iss_ref_num;
    l_retrieval_rec.cancellation_ind             := i_cancellation_ind;
    l_retrieval_rec.potential_chback_reason_code := i_reason_code;
    l_retrieval_rec.response_type                := i_response_type;

    l_stage := 'put_retrieval';
    cst_bof_ghp_api_fin_msg_pkg.put_retrieval(i_retrieval_rec => l_retrieval_rec);

    l_stage := 'create_operation';
    cst_bof_ghp_api_fin_msg_pkg.create_operation(
        i_fin_rec      => l_fin_rec
      , i_standard_id  => l_standard_id
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> retrieval request ID [#1]'
      , i_env_param1 => l_fin_rec.id
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'FAILED on stage [' || l_stage || ']: ' || sqlerrm
        );
        raise;
end generate_retrieval_request;

procedure generate_fee_debit_credit(
    o_fin_id                           out com_api_type_pkg.t_long_id
  , i_original_fin_id               in     com_api_type_pkg.t_long_id
  , i_trans_code                    in     com_api_type_pkg.t_byte_char
  , i_inst_id                       in     com_api_type_pkg.t_inst_id
  , i_network_id                    in     com_api_type_pkg.t_network_id
  , i_reason_code                   in     com_api_type_pkg.t_name
  , i_event_date                    in     date
  , i_oper_amount                   in     com_api_type_pkg.t_money
  , i_oper_currency                 in     com_api_type_pkg.t_curr_code
  , i_country_code                  in     com_api_type_pkg.t_name
  , i_member_msg_text               in     com_api_type_pkg.t_name
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.generate_fee_debit_credit ';
    l_original_fin_rec                     cst_bof_ghp_api_type_pkg.t_ghp_fin_mes_rec;
    l_fin_rec                              cst_bof_ghp_api_type_pkg.t_ghp_fin_mes_rec;
    l_fee_rec                              cst_bof_ghp_api_type_pkg.t_fee_rec;
    l_standard_id                          com_api_type_pkg.t_tiny_id;
    l_host_id                              com_api_type_pkg.t_tiny_id;
    l_param_tab                            com_api_type_pkg.t_param_tab;
    l_dispute_id                           com_api_type_pkg.t_long_id;
    l_stage                                varchar2(100);
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_trans_code [TC#2], i_original_fin_id [#1]'
      , i_env_param1 => i_original_fin_id
      , i_env_param2 => i_trans_code
    );

    cst_bof_ghp_api_fin_msg_pkg.get_fin_message(
        i_id       => i_original_fin_id
      , o_fin_rec  => l_original_fin_rec
    );

    l_dispute_id := l_original_fin_rec.dispute_id;
    if l_original_fin_rec.dispute_id is null then
        l_original_fin_rec.dispute_id := dsp_api_shared_data_pkg.get_id();
    end if;

    -- Update original mesage
    if l_dispute_id is null then
        update_dispute_id(
            i_id          => i_original_fin_id
          , i_dispute_id  => l_original_fin_rec.dispute_id
        );
    end if;

    l_fin_rec.dispute_id := l_original_fin_rec.dispute_id;

    l_stage := 'init';
    o_fin_id := opr_api_create_pkg.get_id();
    l_fin_rec.id := o_fin_id;

    l_fin_rec.is_returned           := com_api_const_pkg.FALSE;
    l_fin_rec.is_incoming           := com_api_const_pkg.FALSE;
    l_fin_rec.file_id               := null;
    l_fin_rec.status                := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
    l_fin_rec.logical_file          := cst_bof_ghp_api_const_pkg.TC_FL_HEADER;

    l_fin_rec.trans_code            := i_trans_code;
    l_fin_rec.is_reversal           := com_api_const_pkg.FALSE;

    l_stage := 'network_id & inst_id';
    l_fin_rec.inst_id               := i_inst_id;
    l_fin_rec.network_id            := i_network_id;
    l_fin_rec.host_inst_id          := net_api_network_pkg.get_inst_id(l_fin_rec.network_id);
    l_fin_rec.oper_currency         := i_oper_currency;
    l_fin_rec.oper_amount           := i_oper_amount;
    l_fin_rec.sttl_currency         := i_oper_currency;
    l_fin_rec.sttl_amount           := i_oper_amount;

    l_fin_rec.forw_inst_id          := l_original_fin_rec.forw_inst_id;
    l_fin_rec.receiv_inst_id        := l_original_fin_rec.receiv_inst_id;
    l_fin_rec.trans_inter_proc_date := l_original_fin_rec.trans_inter_proc_date;

    l_fin_rec.card_number           := l_original_fin_rec.card_number;
    l_fin_rec.card_id               := l_original_fin_rec.card_id;
    l_fin_rec.card_mask             := l_original_fin_rec.card_mask;
    l_fin_rec.card_hash             := l_original_fin_rec.card_hash;

    l_stage := 'acq_business_id';
    l_host_id                       := net_api_network_pkg.get_default_host(i_network_id => l_fin_rec.network_id);
    l_standard_id                   := net_api_network_pkg.get_offline_standard(i_network_id => l_fin_rec.network_id);

    l_fin_rec.oper_date             := com_api_sttl_day_pkg.get_sysdate();
    l_fin_rec.usage_code            := '1';

    l_fin_rec.proc_bin :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id      => l_fin_rec.inst_id
          , i_standard_id  => l_standard_id
          , i_object_id    => l_host_id
          , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name   => cst_bof_ghp_api_const_pkg.CMID
          , i_param_tab    => l_param_tab
        );

    l_fin_rec.arn :=
        case
            when l_original_fin_rec.arn is null then
                acq_api_merchant_pkg.get_arn(i_acquirer_bin => l_fin_rec.proc_bin)
            else
                l_original_fin_rec.arn
        end;

    l_stage := 'put_message';
    o_fin_id := cst_bof_ghp_api_fin_msg_pkg.put_message(i_fin_rec => l_fin_rec);

    l_stage := 'set_fee';
    l_fee_rec.id := l_fin_rec.id;

    l_fee_rec.file_id                := null;
    l_fee_rec.unit_fee               := 0;
    l_fee_rec.reason_code            := i_reason_code;
    l_fee_rec.forw_inst_country_code := i_country_code;
    l_fee_rec.event_date             := coalesce(i_event_date, com_api_sttl_day_pkg.get_sysdate());
    l_fee_rec.source_amount_cfa      := i_oper_amount;
    l_fee_rec.message_text           := i_member_msg_text;
    l_fee_rec.trans_count            := 0;
    l_fee_rec.fee_type_ind           := '0';

    l_stage := 'put_fee';
    cst_bof_ghp_api_fin_msg_pkg.put_fee(i_fee_rec => l_fee_rec);

    l_stage := 'create_operation';
    cst_bof_ghp_api_fin_msg_pkg.create_operation(
        i_fin_rec      => l_fin_rec
      , i_standard_id  => l_standard_id
      , i_fee_rec      => l_fee_rec
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> fee message (TC#2) ID [#1]'
      , i_env_param1 => l_fin_rec.id
      , i_env_param2 => i_trans_code
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'FAILED on stage [' || l_stage || ']: ' || sqlerrm
        );
        raise;
end generate_fee_debit_credit;

procedure genetate_message_fraud(
    o_fin_id                           out com_api_type_pkg.t_long_id
  , i_original_fin_id               in     com_api_type_pkg.t_long_id
  , i_oper_amount                   in     com_api_type_pkg.t_money
  , i_oper_currency                 in     com_api_type_pkg.t_curr_code
  , i_notification_code             in     com_api_type_pkg.t_dict_value
  , i_account_seq_number            in     com_api_type_pkg.t_name
  , i_insurance_year                in     com_api_type_pkg.t_name
  , i_fraud_type                    in     com_api_type_pkg.t_dict_value
  , i_expir_date                    in     date
  , i_debit_credit_indicator        in     com_api_type_pkg.t_byte_char
  , i_trans_generation_method       in     com_api_type_pkg.t_byte_char
) is
    LOG_PREFIX                    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.genetate_message_fraud ';
    l_fin_rec                              cst_bof_ghp_api_type_pkg.t_ghp_fin_mes_rec;
    l_fraud_rec                            cst_bof_ghp_api_type_pkg.t_fraud_rec;
    l_standard_id                          com_api_type_pkg.t_tiny_id;
    l_host_id                              com_api_type_pkg.t_tiny_id;
    l_dispute_id                           com_api_type_pkg.t_long_id;
    l_stage                                varchar2(100);
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_original_fin_id [#1]'
      , i_env_param1 => i_original_fin_id
    );

    cst_bof_ghp_api_fin_msg_pkg.get_fin_message(
        i_id       => i_original_fin_id
      , o_fin_rec  => l_fin_rec
    );

    l_dispute_id := l_fin_rec.dispute_id;
    if l_fin_rec.dispute_id is null then
        l_fin_rec.dispute_id := dsp_api_shared_data_pkg.get_id();
    end if;

    -- Update original mesage
    if l_dispute_id is null then
        update_dispute_id(
            i_id          => i_original_fin_id
          , i_dispute_id  => l_fin_rec.dispute_id
        );
    end if;

    l_fraud_rec.dispute_id := l_fin_rec.dispute_id;

    l_stage := 'init';
    o_fin_id       := opr_api_create_pkg.get_id();
    l_fraud_rec.id := o_fin_id;

    l_fraud_rec.is_incoming              := com_api_const_pkg.FALSE;
    l_fraud_rec.status                   := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
    l_fraud_rec.logical_file             := cst_bof_ghp_api_const_pkg.TC_FL_HEADER;

    l_fraud_rec.fraud_currency           := i_oper_currency;
    l_fraud_rec.fraud_amount             := i_oper_amount;
    l_fraud_rec.notification_code        := i_notification_code;
    l_fraud_rec.account_seq_number       := i_account_seq_number;
    l_fraud_rec.insurance_year           := i_insurance_year;
    l_fraud_rec.fraud_type               := i_fraud_type;
    l_fraud_rec.card_expir_date          := to_char(i_expir_date, 'MMYY');
    l_fraud_rec.debit_credit_indicator   := i_debit_credit_indicator;
    l_fraud_rec.trans_generation_method  := i_trans_generation_method;

    l_fraud_rec.inst_id                  := l_fin_rec.inst_id;
    l_fraud_rec.host_inst_id             := l_fin_rec.host_inst_id;
    l_fraud_rec.network_id               := l_fin_rec.network_id;
    l_fraud_rec.card_number              := l_fin_rec.card_number;
    l_fraud_rec.oper_date                := l_fin_rec.oper_date;
    l_fraud_rec.arn                      := l_fin_rec.arn;
    l_fraud_rec.vic_processing_date      := l_fin_rec.trans_inter_proc_date;
    l_fraud_rec.electr_comm_ind          := l_fin_rec.electr_comm_ind;

    l_fraud_rec.merchant_name            := l_fin_rec.merchant_name;
    l_fraud_rec.merchant_city            := l_fin_rec.merchant_city;
    l_fraud_rec.merchant_country         := l_fin_rec.merchant_country;
    l_fraud_rec.merchant_region          := l_fin_rec.merchant_region;
    l_fraud_rec.mcc                      := l_fin_rec.mcc;

    l_stage := 'put_fraud';
    cst_bof_ghp_api_fin_msg_pkg.put_fraud(i_fraud_rec => l_fraud_rec);

    l_stage := 'get_offline_standard';
    l_host_id      := net_api_network_pkg.get_default_host(i_network_id => l_fraud_rec.network_id);
    l_standard_id  := net_api_network_pkg.get_offline_standard(i_network_id => l_fraud_rec.network_id);

    l_stage := 'create_operation';
    l_fin_rec.id          := o_fin_id;
    l_fin_rec.is_incoming := com_api_const_pkg.FALSE;
    l_fin_rec.is_reversal := com_api_const_pkg.FALSE;
    l_fin_rec.is_invalid  := com_api_const_pkg.FALSE;
    l_fin_rec.file_id     := null;
    l_fin_rec.status      := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
    l_fin_rec.trans_code  := cst_bof_ghp_api_const_pkg.TC_FRAUD_ADVICE;

    cst_bof_ghp_api_fin_msg_pkg.create_operation(
        i_fin_rec      => l_fin_rec
      , i_standard_id  => l_standard_id
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> fraud advice ID [#1]'
      , i_env_param1 => l_fraud_rec.id
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'FAILED on stage [' || l_stage || ']: ' || sqlerrm
        );
        raise;
end genetate_message_fraud;

end;
/
