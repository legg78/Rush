create or replace package body aut_api_auth_pkg is
/*********************************************************
 *  Authorization API <br />
 *  Created by Shalnov N. (shalnov@bpcbt.com) at 10.09.2018 <br />
 *  Module: aut_api_auth_pkg <br />
 *  @headcom
 **********************************************************/

function get_auth(
    i_id                    in     com_api_type_pkg.t_long_id
  , i_mask_error            in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return aut_api_type_pkg.t_auth_rec
is
    l_auth                         aut_api_type_pkg.t_auth_rec;
begin
    begin
        select id
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
             , transaction_id
             , system_trace_audit_number
             , external_auth_id
             , external_orig_id
             , agent_unique_id
             , native_resp_code
             , trace_number
             , auth_purpose_id
             , is_incremental
          into l_auth.id
             , l_auth.resp_code
             , l_auth.proc_type
             , l_auth.proc_mode
             , l_auth.is_advice
             , l_auth.is_repeat
             , l_auth.bin_amount
             , l_auth.bin_currency
             , l_auth.bin_cnvt_rate
             , l_auth.network_amount
             , l_auth.network_currency
             , l_auth.network_cnvt_date
             , l_auth.network_cnvt_rate
             , l_auth.account_cnvt_rate
             , l_auth.parent_id
             , l_auth.addr_verif_result
             , l_auth.iss_network_device_id
             , l_auth.acq_device_id
             , l_auth.acq_resp_code
             , l_auth.acq_device_proc_result
             , l_auth.cat_level
             , l_auth.card_data_input_cap
             , l_auth.crdh_auth_cap
             , l_auth.card_capture_cap
             , l_auth.terminal_operating_env
             , l_auth.crdh_presence
             , l_auth.card_presence
             , l_auth.card_data_input_mode
             , l_auth.crdh_auth_method
             , l_auth.crdh_auth_entity
             , l_auth.card_data_output_cap
             , l_auth.terminal_output_cap
             , l_auth.pin_capture_cap
             , l_auth.pin_presence
             , l_auth.cvv2_presence
             , l_auth.cvc_indicator
             , l_auth.pos_entry_mode
             , l_auth.pos_cond_code
             , l_auth.emv_data
             , l_auth.atc
             , l_auth.tvr
             , l_auth.cvr
             , l_auth.addl_data
             , l_auth.service_code
             , l_auth.device_date
             , l_auth.cvv2_result
             , l_auth.certificate_method
             , l_auth.certificate_type
             , l_auth.merchant_certif
             , l_auth.cardholder_certif
             , l_auth.ucaf_indicator
             , l_auth.is_early_emv
             , l_auth.is_completed
             , l_auth.amounts
             , l_auth.cavv_presence
             , l_auth.aav_presence
             , l_auth.transaction_id
             , l_auth.system_trace_audit_number
             , l_auth.external_auth_id
             , l_auth.external_orig_id
             , l_auth.agent_unique_id
             , l_auth.native_resp_code
             , l_auth.trace_number
             , l_auth.auth_purpose_id
             , l_auth.is_incremental
          from aut_auth
         where id = i_id;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error       => 'AUTH_NOT_FOUND'
                  , i_env_param1  => i_id
                );
            else
                trc_log_pkg.warn(
                    i_text        => 'AUTH_NOT_FOUND'
                  , i_env_param1  => i_id
                );
            end if;
    end;

    return l_auth;
end get_auth;

procedure save_auth(
    i_auth                  in     aut_api_type_pkg.t_auth_rec
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.save_auth';
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ' << i_auth.id [#1]'
      , i_env_param1  => i_auth.id
    );

    insert into aut_auth(
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
      , transaction_id
      , system_trace_audit_number
      , external_auth_id
      , external_orig_id
      , agent_unique_id
      , native_resp_code
      , trace_number
      , auth_purpose_id
      , is_incremental
    ) values (
        i_auth.id
      , i_auth.resp_code
      , i_auth.proc_type
      , i_auth.proc_mode
      , i_auth.is_advice
      , i_auth.is_repeat
      , i_auth.bin_amount
      , i_auth.bin_currency
      , i_auth.bin_cnvt_rate
      , i_auth.network_amount
      , i_auth.network_currency
      , i_auth.network_cnvt_date
      , i_auth.network_cnvt_rate
      , i_auth.account_cnvt_rate
      , i_auth.parent_id
      , i_auth.addr_verif_result
      , i_auth.iss_network_device_id
      , i_auth.acq_device_id
      , i_auth.acq_resp_code
      , i_auth.acq_device_proc_result
      , i_auth.cat_level
      , i_auth.card_data_input_cap
      , i_auth.crdh_auth_cap
      , i_auth.card_capture_cap
      , i_auth.terminal_operating_env
      , i_auth.crdh_presence
      , i_auth.card_presence
      , i_auth.card_data_input_mode
      , i_auth.crdh_auth_method
      , i_auth.crdh_auth_entity
      , i_auth.card_data_output_cap
      , i_auth.terminal_output_cap
      , i_auth.pin_capture_cap
      , i_auth.pin_presence
      , i_auth.cvv2_presence
      , i_auth.cvc_indicator
      , i_auth.pos_entry_mode
      , i_auth.pos_cond_code
      , i_auth.emv_data
      , i_auth.atc
      , i_auth.tvr
      , i_auth.cvr
      , i_auth.addl_data
      , i_auth.service_code
      , i_auth.device_date
      , i_auth.cvv2_result
      , i_auth.certificate_method
      , i_auth.certificate_type
      , i_auth.merchant_certif
      , i_auth.cardholder_certif
      , i_auth.ucaf_indicator
      , i_auth.is_early_emv
      , i_auth.is_completed
      , i_auth.amounts
      , i_auth.cavv_presence
      , i_auth.aav_presence
      , i_auth.transaction_id
      , i_auth.system_trace_audit_number
      , i_auth.external_auth_id
      , i_auth.external_orig_id
      , i_auth.agent_unique_id
      , i_auth.native_resp_code
      , i_auth.trace_number
      , i_auth.auth_purpose_id
      , i_auth.is_incremental
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error       => 'DUPLICATE_AUTH_DATA'
          , i_env_param1  => i_auth.id
        );
end save_auth;

procedure save_auth(
    i_auth_tab              in     auth_data_tpt
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.save_auth';
    l_auth                         aut_api_type_pkg.t_auth_rec;
    l_index                        com_api_type_pkg.t_count := 0;
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ' << i_auth_tab.count() = #1'
      , i_env_param1  => i_auth_tab.count()
    );

    l_index := i_auth_tab.first();

    while l_index is not null loop
        l_auth.id                        := i_auth_tab(l_index).oper_id;
        l_auth.resp_code                 := i_auth_tab(l_index).resp_code;
        l_auth.proc_type                 := i_auth_tab(l_index).proc_type;
        l_auth.proc_mode                 := i_auth_tab(l_index).proc_mode;
        l_auth.is_advice                 := i_auth_tab(l_index).is_advice;
        l_auth.is_repeat                 := i_auth_tab(l_index).is_repeat;
        l_auth.bin_amount                := i_auth_tab(l_index).bin_amount;
        l_auth.bin_currency              := i_auth_tab(l_index).bin_currency;
        l_auth.bin_cnvt_rate             := i_auth_tab(l_index).bin_cnvt_rate;
        l_auth.network_amount            := i_auth_tab(l_index).network_amount;
        l_auth.network_currency          := i_auth_tab(l_index).network_currency;
        l_auth.network_cnvt_date         := to_date(i_auth_tab(l_index).network_cnvt_date, com_api_const_pkg.XML_DATETIME_FORMAT);
        l_auth.network_cnvt_rate         := i_auth_tab(l_index).network_cnvt_rate;
        l_auth.account_cnvt_rate         := i_auth_tab(l_index).account_cnvt_rate;
        l_auth.addr_verif_result         := i_auth_tab(l_index).addr_verif_result;
        l_auth.acq_resp_code             := i_auth_tab(l_index).acq_resp_code;
        l_auth.acq_device_proc_result    := i_auth_tab(l_index).acq_device_proc_result;
        l_auth.cat_level                 := i_auth_tab(l_index).cat_level;
        l_auth.card_data_input_cap       := i_auth_tab(l_index).card_data_input_cap;
        l_auth.crdh_auth_cap             := i_auth_tab(l_index).crdh_auth_cap;
        l_auth.card_capture_cap          := i_auth_tab(l_index).card_capture_cap;
        l_auth.terminal_operating_env    := i_auth_tab(l_index).terminal_operating_env;
        l_auth.crdh_presence             := i_auth_tab(l_index).crdh_presence;
        l_auth.card_presence             := i_auth_tab(l_index).card_presence;
        l_auth.card_data_input_mode      := i_auth_tab(l_index).card_data_input_mode;
        l_auth.crdh_auth_method          := i_auth_tab(l_index).crdh_auth_method;
        l_auth.crdh_auth_entity          := i_auth_tab(l_index).crdh_auth_entity;
        l_auth.card_data_output_cap      := i_auth_tab(l_index).card_data_output_cap;
        l_auth.terminal_output_cap       := i_auth_tab(l_index).terminal_output_cap;
        l_auth.pin_capture_cap           := i_auth_tab(l_index).pin_capture_cap;
        l_auth.pin_presence              := i_auth_tab(l_index).pin_presence;
        l_auth.cvv2_presence             := i_auth_tab(l_index).cvv2_presence;
        l_auth.cvc_indicator             := i_auth_tab(l_index).cvc_indicator;
        l_auth.pos_entry_mode            := i_auth_tab(l_index).pos_entry_mode;
        l_auth.pos_cond_code             := i_auth_tab(l_index).pos_cond_code;
        l_auth.emv_data                  := i_auth_tab(l_index).emv_data;
        l_auth.atc                       := i_auth_tab(l_index).atc;
        l_auth.tvr                       := i_auth_tab(l_index).tvr;
        l_auth.cvr                       := i_auth_tab(l_index).cvr;
        l_auth.addl_data                 := i_auth_tab(l_index).addl_data;
        l_auth.service_code              := i_auth_tab(l_index).service_code;
        l_auth.device_date               := to_date(i_auth_tab(l_index).device_date, com_api_const_pkg.XML_DATETIME_FORMAT);
        l_auth.cvv2_result               := i_auth_tab(l_index).cvv2_result;
        l_auth.certificate_method        := i_auth_tab(l_index).certificate_method;
        l_auth.certificate_type          := i_auth_tab(l_index).certificate_type;
        l_auth.merchant_certif           := i_auth_tab(l_index).merchant_certif;
        l_auth.cardholder_certif         := i_auth_tab(l_index).cardholder_certif;
        l_auth.ucaf_indicator            := i_auth_tab(l_index).ucaf_indicator;
        l_auth.is_early_emv              := i_auth_tab(l_index).is_early_emv;
        l_auth.is_completed              := i_auth_tab(l_index).is_completed;
        l_auth.amounts                   := i_auth_tab(l_index).amounts;
        l_auth.system_trace_audit_number := i_auth_tab(l_index).system_trace_audit_number;
        l_auth.transaction_id            := i_auth_tab(l_index).transaction_id;
        l_auth.external_auth_id          := i_auth_tab(l_index).external_auth_id;
        l_auth.external_orig_id          := i_auth_tab(l_index).external_orig_id;
        l_auth.agent_unique_id           := i_auth_tab(l_index).agent_unique_id;
        l_auth.native_resp_code          := i_auth_tab(l_index).native_resp_code;
        l_auth.trace_number              := i_auth_tab(l_index).trace_number;
        l_auth.auth_purpose_id           := i_auth_tab(l_index).auth_purpose_id;

        save_auth(i_auth => l_auth);

        l_index := i_auth_tab.next(l_index);
    end loop;
end save_auth;

end;
/
