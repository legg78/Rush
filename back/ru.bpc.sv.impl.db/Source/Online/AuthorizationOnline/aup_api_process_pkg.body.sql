create or replace package body aup_api_process_pkg as
/************************************************************
 * Authorization Online Process<br />
 * Created by Khougaev A.(khougaev@bpc.ru)  at 02.09.2010  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: AUT_API_PROCESS_PKG <br />
 * @headcom
 ************************************************************/

procedure save_auth is
begin
    update aut_auth
       set network_amount          = opr_api_shared_data_pkg.g_auth.network_amount
         , network_currency        = opr_api_shared_data_pkg.g_auth.network_currency
         , bin_amount              = opr_api_shared_data_pkg.g_auth.bin_amount
         , bin_currency            = opr_api_shared_data_pkg.g_auth.bin_currency
     where rowid                   = opr_api_shared_data_pkg.g_auth.row_id;

    trc_log_pkg.debug (
        i_text              => 'Saving operation ' || opr_api_shared_data_pkg.g_auth.id || ' amount ' || opr_api_shared_data_pkg.g_auth.oper_amount
    );

    trc_log_pkg.debug (
        i_text              => 'opr_api_shared_data_pkg.g_iss_participant.account_id ' || opr_api_shared_data_pkg.g_iss_participant.account_id || ' opr_api_shared_data_pkg.g_iss_participant.account_number ' || opr_api_shared_data_pkg.g_iss_participant.account_number
    );

    update opr_operation
       set oper_amount             = opr_api_shared_data_pkg.g_auth.oper_amount
         , oper_currency           = opr_api_shared_data_pkg.g_auth.oper_currency
         , oper_request_amount     = opr_api_shared_data_pkg.g_auth.oper_request_amount
         , oper_cashback_amount    = opr_api_shared_data_pkg.g_auth.oper_cashback_amount
         , oper_surcharge_amount   = opr_api_shared_data_pkg.g_auth.oper_surcharge_amount
         , oper_replacement_amount = opr_api_shared_data_pkg.g_auth.oper_replacement_amount
         , unhold_date             = opr_api_shared_data_pkg.g_auth.unhold_date
     where id                      = opr_api_shared_data_pkg.g_auth.id;

    update opr_participant
       set account_id              = nvl(opr_api_shared_data_pkg.g_iss_participant.account_id, account_id)
         , account_number          = nvl(opr_api_shared_data_pkg.g_iss_participant.account_number, account_number)
         , account_amount          = nvl(opr_api_shared_data_pkg.g_auth.account_amount, account_amount)
         , account_currency        = nvl(opr_api_shared_data_pkg.g_auth.account_currency, account_currency)
     where oper_id                 = opr_api_shared_data_pkg.g_auth.id
       and participant_type        = com_api_const_pkg.PARTICIPANT_ISSUER;

    update opr_participant
       set account_id              = nvl(opr_api_shared_data_pkg.g_auth.dst_account_id, account_id)
         , account_number          = nvl(opr_api_shared_data_pkg.g_auth.dst_account_number, account_number)
         , account_amount          = nvl(opr_api_shared_data_pkg.g_auth.dst_account_amount, account_amount)
         , account_currency        = nvl(opr_api_shared_data_pkg.g_auth.dst_account_currency, account_currency)
     where oper_id                 = opr_api_shared_data_pkg.g_auth.id
       and participant_type        = com_api_const_pkg.PARTICIPANT_DEST;
end;

function auth_process (
    i_id                        in com_api_type_pkg.t_long_id
    , i_stage                   in com_api_type_pkg.t_dict_value
    , o_amounts                 out com_api_type_pkg.t_amount_by_name_tab
    , o_accounts                out acc_api_type_pkg.t_account_by_name_tab
    , o_tags                    out com_api_type_pkg.t_desc_tab
) return com_api_type_pkg.t_dict_value is

    l_rules_count               number := 0;
    l_total_rules_count         number := 0;
    l_auth_tab                  aut_api_type_pkg.t_auth_tab;
    l_oper_rec                  opr_api_type_pkg.t_oper_rec;
    l_oper_participant          opr_api_type_pkg.t_oper_part_rec;
    l_resp_code                 com_api_type_pkg.t_dict_value;
    l_auth_id                   com_api_type_pkg.t_long_id;
    cu_oper_participants        sys_refcursor;

    procedure save_job is
    begin
        acc_api_entry_pkg.flush_job;
    end;

    procedure cancel_job is
    begin
        acc_api_entry_pkg.cancel_job;
    end;

    procedure collect_tags (
        o_tags     in out com_api_type_pkg.t_desc_tab
    ) is
        attr_name  com_api_type_pkg.t_name;
        tag_index  integer;
    begin
        o_tags.delete;

        if opr_api_shared_data_pkg.g_dates.count > 0 then
            attr_name := opr_api_shared_data_pkg.g_dates.first;

            loop
                tag_index := aup_api_tag_pkg.find_tag_by_reference(attr_name);

                if tag_index is not null then
                    o_tags(tag_index) := to_char(opr_api_shared_data_pkg.g_dates(attr_name), com_api_const_pkg.DATE_FORMAT);
                end if;

                attr_name := opr_api_shared_data_pkg.g_dates.next(attr_name);
                exit when attr_name is null;
            end loop;
        end if;

        if opr_api_shared_data_pkg.g_params.count > 0 then
            attr_name := opr_api_shared_data_pkg.g_params.first;

            loop
                tag_index := aup_api_tag_pkg.find_tag_by_reference(attr_name);

                if tag_index is not null then
                    o_tags(tag_index) := rul_api_param_pkg.get_param_char (
                        i_name      => attr_name
                        , io_params => opr_api_shared_data_pkg.g_params
                    );
                end if;

                attr_name := opr_api_shared_data_pkg.g_params.next(attr_name);
                exit when attr_name is null;
            end loop;
        end if;
    end;

begin
    savepoint start_processing_auth;

    trc_log_pkg.set_object (
        i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
        , i_object_id  => i_id
    );

    trc_log_pkg.debug (
        i_text              => 'Processing authorization [#1][#2]'
        , i_env_param1      => i_id
        , i_env_param2      => i_stage
    );

    select
        nvl(s.proc_stage, i_stage) proc_stage
        , min(a.rowid)
        , min(a.id)
        , min(null) split_hash
        , min(o.session_id)
        , min(o.is_reversal)
        , min(o.original_id)
        , min(a.parent_id)
        , min(o.id) oper_id
        , min(o.msg_type)
        , min(o.oper_type)
        , min(o.oper_reason)
        , min(a.resp_code)
        , min(o.status)
        , min(o.status_reason)
        , min(a.proc_type)
        , min(a.proc_mode)
        , min(o.sttl_type)
        , min(o.match_status)
        , min(o.forced_processing)
        , min(a.is_advice)
        , min(a.is_repeat)
        , min(a.is_completed)
        , min(o.host_date)
        , min(o.sttl_date)
        , min(o.acq_sttl_date)
        , min(o.unhold_date)
        , min(o.oper_date)
        , min(o.oper_count)
        , min(o.oper_request_amount)
        , min(o.oper_amount_algorithm)
        , min(o.oper_amount)
        , min(o.oper_currency)
        , min(o.oper_cashback_amount)
        , min(o.oper_replacement_amount)
        , min(o.oper_surcharge_amount)
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.client_id_type, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.client_id_value, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.inst_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.network_id, null))
        , min(a.iss_network_device_id)
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.split_hash, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_inst_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_network_id, null))
        , min(decode(p.participant_type
                   , com_api_const_pkg.PARTICIPANT_ISSUER
                   , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
                   , null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_instance_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_type_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_mask, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_hash, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_seq_number, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_expir_date, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_service_code, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_country, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.customer_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.account_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.account_type, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.account_number, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.account_amount, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.account_currency, null))
        , min(a.account_cnvt_rate)
        , min(a.bin_amount)
        , min(a.bin_currency)
        , min(a.bin_cnvt_rate)
        , min(a.network_amount)
        , min(a.network_currency)
        , min(a.network_cnvt_date)
        , min(a.network_cnvt_rate)
        , min(a.addr_verif_result)
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.auth_code, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.client_id_type, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.client_id_value, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.inst_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.network_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_inst_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_network_id, null))
        , min(decode(p.participant_type
                   , com_api_const_pkg.PARTICIPANT_DEST
                   , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
                   , null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_instance_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_type_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_mask, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_hash, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_seq_number, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_expir_date, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_service_code, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.card_country, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.customer_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.account_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.account_type, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.account_number, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.account_amount, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.account_currency, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_DEST, p.auth_code, null))
        , min(a.acq_device_id)
        , min(a.acq_resp_code)
        , min(a.acq_device_proc_result)
        , min(o.acq_inst_bin)
        , min(o.forw_inst_bin)
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.inst_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.network_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.split_hash, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.merchant_id, null))
        , min(o.merchant_number)
        , min(o.terminal_type)
        , min(o.terminal_number)
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.terminal_id, null))
        , min(o.merchant_name)
        , min(o.merchant_street)
        , min(o.merchant_city)
        , min(o.merchant_region)
        , min(o.merchant_country)
        , min(o.merchant_postcode)
        , min(a.cat_level)
        , min(o.mcc)
        , min(o.originator_refnum)
        , min(o.network_refnum)
        , min(a.card_data_input_cap)
        , min(a.crdh_auth_cap)
        , min(a.card_capture_cap)
        , min(a.terminal_operating_env)
        , min(a.crdh_presence)
        , min(a.card_presence)
        , min(a.card_data_input_mode)
        , min(a.crdh_auth_method)
        , min(a.crdh_auth_entity)
        , min(a.card_data_output_cap)
        , min(a.terminal_output_cap)
        , min(a.pin_capture_cap)
        , min(a.pin_presence)
        , min(a.cvv2_presence)
        , min(a.cvc_indicator)
        , min(a.pos_entry_mode)
        , min(a.pos_cond_code)
        , min(o.payment_order_id)
        , min(o.payment_host_id)
        , min(a.emv_data)
        , min(a.atc)
        , min(a.tvr)
        , min(a.cvr)
        , min(a.addl_data)
        , min(a.service_code)
        , min(a.device_date)
        , min(a.cvv2_result)
        , min(a.certificate_method)
        , min(a.certificate_type)
        , min(a.merchant_certif)
        , min(a.cardholder_certif)
        , min(a.ucaf_indicator)
        , min(a.is_early_emv)
        , min(a.amounts)
        , min(a.cavv_presence)
        , min(a.aav_presence)
        , min(a.transaction_id)
        , min(a.system_trace_audit_number)
        , min(a.external_auth_id)
        , min(a.external_orig_id)
        , min(a.agent_unique_id)
        , min(a.native_resp_code)
        , min(a.trace_number)
        , min(a.auth_purpose_id)
        , min(a.is_incremental)
    bulk collect into
        l_auth_tab
    from
        aut_auth a
        , opr_card c
        , opr_operation o
        , opr_participant p
        , opr_proc_stage s
    where
        a.id = i_id
        and a.id = o.id
        and o.id = p.oper_id
        and p.oper_id = c.oper_id(+)
        and p.participant_type = c.participant_type(+)
        and o.sttl_type like s.sttl_type(+)
        and o.oper_type like s.oper_type(+)
        and o.msg_type like s.msg_type(+)
        and s.parent_stage(+) = i_stage
    group by nvl(s.proc_stage, i_stage);

    select id
      into l_auth_id
      from aut_auth
     where id = i_id
    for update of resp_code;

    opr_api_shared_data_pkg.clear_shared_data;
    l_resp_code := aup_api_const_pkg.RESP_CODE_OK;
    l_total_rules_count := 0;

    trc_log_pkg.debug (
        i_text              => 'Processing authorization fetched [#1] recs'
        , i_env_param1      => l_auth_tab.count
    );

    for i in 1 .. l_auth_tab.count loop

        if i = 1 then
            savepoint processing_new_auth;
            opr_api_shared_data_pkg.clear_shared_data;
            opr_api_shared_data_pkg.g_auth := l_auth_tab(1);
            opr_api_shared_data_pkg.collect_auth_params;

            l_oper_rec.id                       := l_auth_tab(1).id;
            l_oper_rec.proc_stage               := l_auth_tab(1).proc_stage;
            l_oper_rec.exec_order               := null;
            l_oper_rec.session_id               := l_auth_tab(1).session_id;
            l_oper_rec.is_reversal              := l_auth_tab(1).is_reversal;
            l_oper_rec.original_id              := l_auth_tab(1).original_id;
            l_oper_rec.oper_type                := l_auth_tab(1).oper_type;
            l_oper_rec.oper_reason              := l_auth_tab(1).oper_reason;
            l_oper_rec.msg_type                 := l_auth_tab(1).msg_type;
            l_oper_rec.status                   := l_auth_tab(1).status;
            l_oper_rec.status_reason            := l_auth_tab(1).status_reason;
            l_oper_rec.sttl_type                := l_auth_tab(1).sttl_type;
            l_oper_rec.terminal_type            := l_auth_tab(1).terminal_type;
            l_oper_rec.acq_inst_bin             := l_auth_tab(1).acq_inst_bin;
            l_oper_rec.forw_inst_bin            := l_auth_tab(1).forw_inst_bin;
            l_oper_rec.merchant_number          := l_auth_tab(1).merchant_number;
            l_oper_rec.terminal_number          := l_auth_tab(1).terminal_number;
            l_oper_rec.merchant_name            := l_auth_tab(1).merchant_name;
            l_oper_rec.merchant_street          := l_auth_tab(1).merchant_street;
            l_oper_rec.merchant_city            := l_auth_tab(1).merchant_city;
            l_oper_rec.merchant_region          := l_auth_tab(1).merchant_region;
            l_oper_rec.merchant_country         := l_auth_tab(1).merchant_country;
            l_oper_rec.merchant_postcode        := l_auth_tab(1).merchant_postcode;
            l_oper_rec.mcc                      := l_auth_tab(1).mcc;
            l_oper_rec.originator_refnum        := l_auth_tab(1).originator_refnum;
            l_oper_rec.network_refnum           := l_auth_tab(1).network_refnum;
            l_oper_rec.oper_count               := l_auth_tab(1).oper_count;
            l_oper_rec.oper_request_amount      := l_auth_tab(1).oper_request_amount;
            l_oper_rec.oper_amount_algorithm    := l_auth_tab(1).oper_amount_algorithm;
            l_oper_rec.oper_amount              := l_auth_tab(1).oper_amount;
            l_oper_rec.oper_currency            := l_auth_tab(1).oper_currency;
            l_oper_rec.oper_cashback_amount     := l_auth_tab(1).oper_cashback_amount;
            l_oper_rec.oper_replacement_amount  := l_auth_tab(1).oper_replacement_amount;
            l_oper_rec.oper_surcharge_amount    := l_auth_tab(1).oper_surcharge_amount;
            l_oper_rec.oper_date                := l_auth_tab(1).oper_date;
            l_oper_rec.host_date                := l_auth_tab(1).host_date;
            l_oper_rec.unhold_date              := l_auth_tab(1).unhold_date;
            l_oper_rec.match_status             := l_auth_tab(1).match_status;
            l_oper_rec.sttl_amount              := l_auth_tab(1).network_amount;
            l_oper_rec.sttl_currency            := l_auth_tab(1).network_currency;
            l_oper_rec.dispute_id               := null;
            l_oper_rec.payment_order_id         := l_auth_tab(1).payment_order_id;
            l_oper_rec.payment_host_id          := l_auth_tab(1).payment_host_id;
            l_oper_rec.forced_processing        := l_auth_tab(1).forced_processing;

            opr_api_shared_data_pkg.set_operation(l_oper_rec);

            open cu_oper_participants for
                select p.oper_id
                     , p.participant_type
                     , p.client_id_type
                     , p.client_id_value
                     , p.inst_id
                     , p.network_id
                     , p.card_inst_id
                     , p.card_network_id
                     , p.card_id
                     , p.card_instance_id
                     , p.card_type_id
                     , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
                     , p.card_mask
                     , p.card_hash
                     , p.card_seq_number
                     , p.card_expir_date
                     , p.card_service_code
                     , p.card_country
                     , p.customer_id
                     , to_number(null) contract_id
                     , p.account_id
                     , p.account_type
                     , p.account_number
                     , p.account_amount
                     , p.account_currency
                     , p.auth_code
                     , p.merchant_id
                     , p.terminal_id
                     , p.split_hash
                     , to_number(null) acq_inst_id
                     , to_number(null) acq_network_id
                     , to_number(null) iss_inst_id
                     , to_number(null) iss_network_id
                  from opr_participant p
                     , opr_card c
                 where p.oper_id = opr_api_shared_data_pkg.g_auth.id
                   and p.oper_id = c.oper_id(+)
                   and p.participant_type = c.participant_type(+);
            loop

                fetch cu_oper_participants into l_oper_participant;
                exit when cu_oper_participants%notfound;

                opr_api_shared_data_pkg.set_participant(
                    i_oper_participant      => l_oper_participant
                );
            end loop;

            close cu_oper_participants;

            opr_api_shared_data_pkg.collect_oper_params;
            opr_api_shared_data_pkg.collect_global_oper_params;
        else
            opr_api_shared_data_pkg.put_auth_params;
            opr_api_shared_data_pkg.put_oper_params;
            opr_api_shared_data_pkg.g_auth.proc_stage := l_auth_tab(i).proc_stage;
        end if;

        trc_log_pkg.set_object (
            i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            , i_object_id  => opr_api_shared_data_pkg.g_auth.id
        );

        trc_log_pkg.debug (
            i_text              => 'Processing authorization stage [#1]'
            , i_env_param1      => l_auth_tab(i).proc_stage
        );

        begin
            opr_api_process_pkg.process_rules (
                i_msg_type              => opr_api_shared_data_pkg.g_auth.msg_type
                , i_proc_stage          => opr_api_shared_data_pkg.g_auth.proc_stage
                , i_sttl_type           => opr_api_shared_data_pkg.g_auth.sttl_type
                , i_oper_type           => opr_api_shared_data_pkg.g_auth.oper_type
                , i_oper_reason         => opr_api_shared_data_pkg.g_auth.oper_reason
                , i_is_reversal         => opr_api_shared_data_pkg.g_auth.is_reversal
                , i_iss_inst_id         => opr_api_shared_data_pkg.g_auth.iss_inst_id
                , i_acq_inst_id         => opr_api_shared_data_pkg.g_auth.acq_inst_id
                , i_terminal_type       => opr_api_shared_data_pkg.g_auth.terminal_type
                , i_oper_currency       => opr_api_shared_data_pkg.g_auth.oper_currency
                , i_account_currency    => opr_api_shared_data_pkg.g_auth.account_currency
                , i_sttl_currency       => opr_api_shared_data_pkg.g_auth.network_currency
                , i_proc_mode           => opr_api_shared_data_pkg.g_auth.proc_mode
                , o_rules_count         => l_rules_count
                , io_params             => opr_api_shared_data_pkg.g_params
            );

            l_total_rules_count := l_total_rules_count + l_rules_count;

            trc_log_pkg.debug (
                i_text              => 'Processed ' || l_rules_count || ' rules'
            );
        exception
            when com_api_error_pkg.e_stop_process_operation then
                trc_log_pkg.debug (
                    i_text              => 'catched signal e_stop_process_operation'
                );
                l_total_rules_count := l_total_rules_count + 1;
                o_amounts := opr_api_shared_data_pkg.g_amounts;
                o_accounts := opr_api_shared_data_pkg.g_accounts;
                exit;

            when com_api_error_pkg.e_rollback_process_operation then
                trc_log_pkg.debug (
                    i_text              => 'catched signal e_rollback_process_operation'
                );
                cancel_job;
                l_total_rules_count := l_total_rules_count + 1;
                rollback to savepoint processing_new_auth;
                o_amounts := opr_api_shared_data_pkg.g_amounts;
                o_accounts := opr_api_shared_data_pkg.g_accounts;
                exit;

            when others then
                cancel_job;
                rollback to savepoint processing_new_auth;
                l_total_rules_count := l_total_rules_count + 1;

                if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                    trc_log_pkg.error (
                        i_text              => 'ERROR_PROCESSING_AUTHORIZATION'
                        , i_env_param1      => sqlerrm
                        , i_env_param2      => com_api_error_pkg.get_last_error
                    );

                    l_resp_code := aup_api_const_pkg.RESP_CODE_ERROR;
                    exit;
                else
                    trc_log_pkg.error (
                        i_text              => 'ERROR_PROCESSING_AUTHORIZATION'
                        , i_env_param1      => sqlerrm
                    );

                    l_resp_code := aup_api_const_pkg.RESP_CODE_ERROR;
                    exit;
                end if;
        end;
    end loop;

    save_job;

    trc_log_pkg.debug (
        i_text              => 'Totally processed [#1] rules, resp id [#2][#3]'
        , i_env_param1      => l_total_rules_count
        , i_env_param2      => l_resp_code
        , i_env_param3      => opr_api_shared_data_pkg.get_returning_resp_code
    );

    if l_resp_code = aup_api_const_pkg.RESP_CODE_OK then
        l_resp_code := opr_api_shared_data_pkg.get_returning_resp_code;
    end if;

    if l_resp_code = aup_api_const_pkg.RESP_CODE_OK then
        if l_total_rules_count = 0 then
            l_resp_code := aup_api_const_pkg.RESP_CODE_NO_RULES;
        else
            o_amounts := opr_api_shared_data_pkg.g_amounts;
            o_accounts := opr_api_shared_data_pkg.g_accounts;

            collect_tags(
                o_tags      => o_tags
            );
            
        end if;
    end if;

    trc_log_pkg.debug (
        i_text              => 'Finalizing job'
    );

    opr_api_shared_data_pkg.put_auth_params;
    opr_api_shared_data_pkg.put_oper_params;
    save_auth;

    trc_log_pkg.debug (
        i_text              => 'Exiting with [#1]'
        , i_env_param1      => l_resp_code
    );

    trc_log_pkg.clear_object;

    return l_resp_code;
exception
    when others then
        rollback to savepoint start_processing_auth;

        if cu_oper_participants%isopen then
            close cu_oper_participants;
        end if;

        cancel_job;
        trc_log_pkg.clear_object;

        raise;
end;

function unhold (
    i_id                        in com_api_type_pkg.t_long_id
    , i_reason                  in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value is
    l_result            com_api_type_pkg.t_dict_value := aup_api_const_pkg.RESP_CODE_OK;
begin
    trc_log_pkg.set_object (
        i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
        , i_object_id  => opr_api_shared_data_pkg.g_auth.id
    );

    aut_api_process_pkg.unhold (
        i_id        => i_id
        , i_reason  => nvl(i_reason, aut_api_const_pkg.AUTH_REASON_UNHOLD_CUSTOMER)
    );

    trc_log_pkg.clear_object;

    return l_result;
exception
    when others then
        if (
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        ) then
            l_result :=
                case com_api_error_pkg.get_last_error
                    when 'AUTH_CANT_BE_UNHOLDED' then aup_api_const_pkg.RESP_CODE_CANCEL_NOT_ALLOWED
                    when 'AUTH_ALREADY_UNHOLDED' then aup_api_const_pkg.RESP_CODE_REVERSAL_DUBLICATED
                    when 'AUTH_NOT_FOUND'        then aup_api_const_pkg.RESP_CODE_NO_ORIGINAL_OPER
                    else aup_api_const_pkg.RESP_CODE_ERROR
                end;

            trc_log_pkg.clear_object;
            return l_result;
        else
            trc_log_pkg.warn(
                i_text              => 'UNHANDLED_EXCEPTION'
                , i_env_param1      => sqlerrm
                , i_env_param2      => sqlcode
                , i_env_param3      => 'Unhold failed'
                , i_entity_type     => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                , i_object_id       => i_id
            );
            trc_log_pkg.clear_object;
            return aup_api_const_pkg.RESP_CODE_ERROR;
        end if;
end;

procedure save_amounts (
    i_auth_id                   in com_api_type_pkg.t_long_id
    , i_amounts                 in com_api_type_pkg.t_raw_data
)is
begin
    update aut_auth a
       set a.amounts = i_amounts
     where a.id = i_auth_id;

    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.save_amounts: i_auth_id [' || i_auth_id
                                          || '], updated ' || sql%rowcount || ' records' );
end;

procedure get_amounts (
    i_auth_id                   in  com_api_type_pkg.t_long_id
    , o_amounts                 out com_api_type_pkg.t_raw_data
)is
begin
    for rec in (
        select a.amounts
          from aut_auth a
         where a.id = i_auth_id
    )
    loop
        o_amounts := rec.amounts;
    end loop;
end;

/*
 * Function returns string with serialized amount record that should be used
 * for saving in <aut_auth.amounts> field (this field contains amount as raw data).
 */
function serialize_auth_amount(
    i_amount_type        in     com_api_type_pkg.t_dict_value
  , i_amount_rec         in     com_api_type_pkg.t_amount_rec
) return com_api_type_pkg.t_name
is
begin
    com_api_dictionary_pkg.check_article(
        i_dict => substr(i_amount_type, 1, 4)
      , i_code => i_amount_type
    );

    return i_amount_type
        || nvl(i_amount_rec.currency, com_api_const_pkg.ZERO_CURRENCY)
        || case when i_amount_rec.amount < 0 then 'N' else 'P' end
        || to_char(abs(i_amount_rec.amount), com_api_const_pkg.NUMBER_FORMAT)
    ;
exception
    when others then
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.serialize_auth_amount FAILED: '
                         || 'i_amount_type [#1], '
                         || 'i_amount_rec.currency [' || i_amount_rec.currency || '], '
                         || 'i_amount_rec.amount [' || i_amount_rec.amount || ']'
          , i_env_param1 => i_amount_type
        );
        raise;
end serialize_auth_amount;

end;
/
