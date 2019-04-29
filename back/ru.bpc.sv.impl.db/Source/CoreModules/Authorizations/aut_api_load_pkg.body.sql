create or replace package body aut_api_load_pkg is
/************************************************************
 * Authorizations loads<br />
 * Created by Khougaev A.(khougaev@bpc.ru)  at 19.03.2010  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: AUT_API_LOAD_PKG <br />
 * @headcom
 ************************************************************/
    DEFAULT_ACTIVE_BUFFER_NUM   constant com_api_type_pkg.t_tiny_id := 1;
    BULK_LIMIT                  constant com_api_type_pkg.t_count   := 100;

    g_auth_rowid                com_api_type_pkg.t_rowid_tab;
    g_card_rowid                com_api_type_pkg.t_rowid_tab;
    g_id                        com_api_type_pkg.t_number_tab;
    g_split_hash                com_api_type_pkg.t_number_tab;
    g_source_id                 com_api_type_pkg.t_number_tab;
    g_original_auth_id          com_api_type_pkg.t_number_tab;
    g_is_reversal               com_api_type_pkg.t_boolean_tab;
    g_msg_type                  com_api_type_pkg.t_dict_tab;
    g_oper_type                 com_api_type_pkg.t_dict_tab;
    g_resp_code                 com_api_type_pkg.t_dict_tab;
    g_status                    com_api_type_pkg.t_dict_tab;
    g_status_reason             com_api_type_pkg.t_dict_tab;
    g_proc_type                 com_api_type_pkg.t_dict_tab;
    g_proc_mode                 com_api_type_pkg.t_dict_tab;
    g_acq_inst_id               com_api_type_pkg.t_inst_id_tab;
    g_acq_network_id            com_api_type_pkg.t_inst_id_tab;
    g_terminal_type             com_api_type_pkg.t_dict_tab;
    g_cat_level                 com_api_type_pkg.t_dict_tab;
    g_acq_inst_bin              com_api_type_pkg.t_name_tab;
    g_forw_inst_bin             com_api_type_pkg.t_name_tab;
    g_split_hash_acq            com_api_type_pkg.t_number_tab;
    g_merchant_id               com_api_type_pkg.t_number_tab;
    g_own_merchant_id           com_api_type_pkg.t_number_tab;
    g_merchant_number           com_api_type_pkg.t_name_tab;
    g_terminal_id               com_api_type_pkg.t_number_tab;
    g_terminal_number           com_api_type_pkg.t_name_tab;
    g_merchant_name             com_api_type_pkg.t_name_tab;
    g_merchant_street           com_api_type_pkg.t_name_tab;
    g_merchant_city             com_api_type_pkg.t_name_tab;
    g_merchant_region           com_api_type_pkg.t_name_tab;
    g_merchant_country          com_api_type_pkg.t_name_tab;
    g_merchant_postcode         com_api_type_pkg.t_name_tab;
    g_mcc                       com_api_type_pkg.t_name_tab;
    g_originator_refnum         com_api_type_pkg.t_name_tab;
    g_network_refnum            com_api_type_pkg.t_name_tab;
    g_card_data_input_cap       com_api_type_pkg.t_dict_tab;
    g_crdh_auth_cap             com_api_type_pkg.t_dict_tab;
    g_card_capture_cap          com_api_type_pkg.t_dict_tab;
    g_terminal_operating_env    com_api_type_pkg.t_dict_tab;
    g_crdh_presence             com_api_type_pkg.t_dict_tab;
    g_card_presence             com_api_type_pkg.t_dict_tab;
    g_card_data_input_mode      com_api_type_pkg.t_dict_tab;
    g_crdh_auth_method          com_api_type_pkg.t_dict_tab;
    g_crdh_auth_entity          com_api_type_pkg.t_dict_tab;
    g_card_data_output_cap      com_api_type_pkg.t_dict_tab;
    g_terminal_output_cap       com_api_type_pkg.t_dict_tab;
    g_pin_capture_cap           com_api_type_pkg.t_dict_tab;
    g_pin_presence              com_api_type_pkg.t_dict_tab;
    g_cvv2_presence             com_api_type_pkg.t_dict_tab;
    g_cvc_indicator             com_api_type_pkg.t_dict_tab;
    g_pos_entry_mode            com_api_type_pkg.t_dict_tab;
    g_pos_cond_code             com_api_type_pkg.t_dict_tab;
    g_payment_order_id          com_api_type_pkg.t_number_tab;
    g_payment_host_id           com_api_type_pkg.t_number_tab;
    g_emv_data                  com_api_type_pkg.t_varchar2_tab;
    g_auth_code                 com_api_type_pkg.t_dict_tab;
    g_oper_request_amount       com_api_type_pkg.t_number_tab;
    g_oper_amount               com_api_type_pkg.t_number_tab;
    g_oper_currency             com_api_type_pkg.t_dict_tab;
    g_oper_cashback_amount      com_api_type_pkg.t_number_tab;
    g_oper_replacement_amount   com_api_type_pkg.t_number_tab;
    g_oper_surcharge_amount     com_api_type_pkg.t_number_tab;
    g_oper_date                 com_api_type_pkg.t_date_tab;
    g_host_date                 com_api_type_pkg.t_date_tab;
    g_iss_inst_id               com_api_type_pkg.t_inst_id_tab;
    g_iss_network_id            com_api_type_pkg.t_inst_id_tab;
    g_card_inst_id              com_api_type_pkg.t_inst_id_tab;
    g_card_network_id           com_api_type_pkg.t_inst_id_tab;
    g_card_country              com_api_type_pkg.t_dict_tab;
    g_card_type_id              com_api_type_pkg.t_number_tab;
    g_card_id                   com_api_type_pkg.t_number_tab;
    g_split_hash_iss            com_api_type_pkg.t_number_tab;
    g_card_number               com_api_type_pkg.t_card_number_tab;
    g_card_mask                 com_api_type_pkg.t_card_number_tab;
    g_card_hash                 com_api_type_pkg.t_number_tab;
    g_card_seq_number           com_api_type_pkg.t_number_tab;
    g_card_expir_date           com_api_type_pkg.t_date_tab;
    g_card_service_code         com_api_type_pkg.t_dict_tab;
    g_account_type              com_api_type_pkg.t_dict_tab;
    g_account_number            com_api_type_pkg.t_name_tab;
    g_account_amount            com_api_type_pkg.t_number_tab;
    g_account_currency          com_api_type_pkg.t_dict_tab;
    g_bin_amount                com_api_type_pkg.t_number_tab;
    g_bin_currency              com_api_type_pkg.t_dict_tab;
    g_network_amount            com_api_type_pkg.t_number_tab;
    g_network_currency          com_api_type_pkg.t_dict_tab;
    g_network_cnvt_date         com_api_type_pkg.t_date_tab;
    g_iss_check_own_card        com_api_type_pkg.t_boolean_tab;
    g_iss_check_own_bin         com_api_type_pkg.t_boolean_tab;
    g_iss_check_netw_bin        com_api_type_pkg.t_boolean_tab;
    g_iss_check_common_bin      com_api_type_pkg.t_boolean_tab;
    g_acq_check_own_terminal    com_api_type_pkg.t_boolean_tab;
    g_acq_check_own_merchant    com_api_type_pkg.t_boolean_tab;
    g_sttl_type                 com_api_type_pkg.t_dict_tab;
    g_match_status              com_api_type_pkg.t_dict_tab;
    g_forced_posting            com_api_type_pkg.t_boolean_tab;
    g_parent_id                 com_api_type_pkg.t_number_tab;

function neg_active_buffer_num (
    i_active_num            in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_tiny_id is
begin
    case
        when i_active_num = 1 then return 2;
        when i_active_num = 2 then return 1;
        else return DEFAULT_ACTIVE_BUFFER_NUM;
    end case;
end;

function get_active_buffer_num return com_api_type_pkg.t_tiny_id is

    l_result                com_api_type_pkg.t_tiny_id;

begin
    select
        active_buffer_num
    into
        l_result
    from
        aut_active_buffer;
    return l_result;
exception
    when no_data_found or too_many_rows then
        return DEFAULT_ACTIVE_BUFFER_NUM;
end;

procedure switch_active_buffer is

    pragma autonomous_transaction;
    l_active_num                    com_api_type_pkg.t_tiny_id;
    l_check_count                   number;

begin
    lock table aut_active_buffer in exclusive mode;

    l_active_num := neg_active_buffer_num(get_active_buffer_num);

    execute immediate 'select count(1) from aut_buffer#' || l_active_num || ' where rownum = 1'
    into l_check_count;

    if l_check_count > 0 then
        rollback;
    else
        update
            aut_active_buffer
        set
            active_buffer_num = l_active_num;

        if sql%rowcount != 1 then
            if sql%rowcount > 1 then
                delete from aut_active_buffer;
            end if;

            insert into aut_active_buffer (
                active_buffer_num
            ) values (
                l_active_num
            );
        end if;

        commit;
    end if;
end;

procedure clear_global_data is
begin
    g_auth_rowid.delete;
    g_card_rowid.delete;
    g_id.delete;
    g_split_hash.delete;
    g_source_id.delete;
    g_original_auth_id.delete;
    g_is_reversal.delete;
    g_msg_type.delete;
    g_oper_type.delete;
    g_resp_code.delete;
    g_status.delete;
    g_status_reason.delete;
    g_proc_type.delete;
    g_proc_mode.delete;
    g_acq_inst_id.delete;
    g_acq_network_id.delete;
    g_terminal_type.delete;
    g_cat_level.delete;
    g_acq_inst_bin.delete;
    g_forw_inst_bin.delete;
    g_split_hash_acq.delete;
    g_merchant_id.delete;
    g_own_merchant_id.delete;
    g_merchant_number.delete;
    g_terminal_id.delete;
    g_terminal_number.delete;
    g_merchant_name.delete;
    g_merchant_street.delete;
    g_merchant_city.delete;
    g_merchant_region.delete;
    g_merchant_country.delete;
    g_merchant_postcode.delete;
    g_mcc.delete;
    g_originator_refnum.delete;
    g_network_refnum.delete;
    g_card_data_input_cap.delete;
    g_crdh_auth_cap.delete;
    g_card_capture_cap.delete;
    g_terminal_operating_env.delete;
    g_crdh_presence.delete;
    g_card_presence.delete;
    g_card_data_input_mode.delete;
    g_crdh_auth_method.delete;
    g_crdh_auth_entity.delete;
    g_card_data_output_cap.delete;
    g_terminal_output_cap.delete;
    g_pin_capture_cap.delete;
    g_pin_presence.delete;
    g_cvv2_presence.delete;
    g_cvc_indicator.delete;
    g_pos_entry_mode.delete;
    g_pos_cond_code.delete;
    g_payment_order_id.delete;
    g_payment_host_id.delete;
    g_emv_data.delete;
    g_auth_code.delete;
    g_oper_request_amount.delete;
    g_oper_amount.delete;
    g_oper_currency.delete;
    g_oper_cashback_amount.delete;
    g_oper_replacement_amount.delete;
    g_oper_surcharge_amount.delete;
    g_oper_date.delete;
    g_host_date.delete;
    g_iss_inst_id.delete;
    g_iss_network_id.delete;
    g_card_inst_id.delete;
    g_card_network_id.delete;
    g_card_country.delete;
    g_card_type_id.delete;
    g_card_id.delete;
    g_split_hash_iss.delete;
    g_card_number.delete;
    g_card_mask.delete;
    g_card_hash.delete;
    g_card_seq_number.delete;
    g_card_expir_date.delete;
    g_card_service_code.delete;
    g_account_type.delete;
    g_account_number.delete;
    g_account_amount.delete;
    g_account_currency.delete;
    g_bin_amount.delete;
    g_bin_currency.delete;
    g_network_amount.delete;
    g_network_currency.delete;
    g_network_cnvt_date.delete;
    g_iss_check_own_card.delete;
    g_iss_check_own_bin.delete;
    g_iss_check_netw_bin.delete;
    g_iss_check_common_bin.delete;
    g_acq_check_own_terminal.delete;
    g_acq_check_own_merchant.delete;
    g_sttl_type.delete;
    g_match_status.delete;
    g_forced_posting.delete;
    g_parent_id.delete;
end;

function get_status_by_resp (
    i_resp_code                 in com_api_type_pkg.t_dict_value
    , i_oper_type               in com_api_type_pkg.t_dict_value
    , i_msg_type                in com_api_type_pkg.t_dict_value
    , i_is_reversal             in com_api_type_pkg.t_boolean
    , i_is_completed            in com_api_type_pkg.t_dict_value
    , i_sttl_type               in com_api_type_pkg.t_dict_value
    , i_oper_reason             in com_api_type_pkg.t_dict_value
) return aut_api_type_pkg.aut_resp_code is
    l_result                    aut_api_type_pkg.aut_resp_code;
begin
    select
        *
    into
        l_result
    from (
        select 
            r.resp_code
            , r.is_reversal
            , r.proc_type
            , r.proc_mode
            , r.auth_status
            , r.status_reason
            , r.oper_type
            , r.msg_type
            , r.priority
            , r.is_completed
        from
            aut_resp_code r
        where
            i_resp_code like r.resp_code 
            and i_is_reversal = nvl(r.is_reversal, i_is_reversal) 
            and nvl(i_oper_type, '%') like r.oper_type
            and nvl(i_msg_type, '%') like r.msg_type
            and nvl(i_is_completed, '%') like r.is_completed
            and nvl(i_sttl_type, '%') like r.sttl_type
            and nvl(i_oper_reason, '%') like nvl(r.oper_reason, '%')
        order by
            r.priority
    ) where
        rownum = 1;

    return l_result;
exception
    when no_data_found then
        return null;
end;

procedure get_status_by_resp (
    i_resp_code                 in com_api_type_pkg.t_dict_value
    , i_oper_type               in com_api_type_pkg.t_dict_value
    , i_msg_type                in com_api_type_pkg.t_dict_value
    , i_is_reversal             in com_api_type_pkg.t_boolean
    , i_is_completed            in com_api_type_pkg.t_dict_value
    , i_sttl_type               in com_api_type_pkg.t_dict_value
    , i_oper_reason             in com_api_type_pkg.t_dict_value
    , o_status                  out com_api_type_pkg.t_dict_value
    , o_status_reason           out com_api_type_pkg.t_dict_value
    , o_proc_mode               out com_api_type_pkg.t_dict_value
    , o_proc_type               out com_api_type_pkg.t_dict_value
) is
    l_resp                      aut_api_type_pkg.aut_resp_code;
begin
    l_resp := get_status_by_resp (
        i_resp_code         => i_resp_code
        , i_oper_type       => i_oper_type
        , i_msg_type        => i_msg_type
        , i_is_reversal     => i_is_reversal
        , i_is_completed    => i_is_completed
        , i_sttl_type       => i_sttl_type
        , i_oper_reason     => i_oper_reason
    );

    if l_resp.proc_type is null then
        o_proc_mode := aut_api_const_pkg.DEFAULT_AUTH_PROC_MODE;
        o_proc_type := aut_api_const_pkg.DEFAULT_AUTH_PROC_TYPE;
        o_status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
        o_status_reason := aut_api_const_pkg.AUTH_REASON_NO_RESP_CODE;
    else
        o_status := l_resp.auth_status;
        o_status_reason := l_resp.status_reason;
        o_proc_mode := l_resp.proc_mode;
        o_proc_type := l_resp.proc_type;
    end if;
end;

/*    procedure put_auth (
    i_source_id                 in aut_buffer#1.source_id%type
    , i_id                      in aut_buffer#1.id%type
    , i_original_auth_id        in aut_buffer#1.original_auth_id%type
    , i_is_reversal             in aut_buffer#1.is_reversal%type
    , i_msg_type                in aut_buffer#1.msg_type%type
    , i_oper_type               in aut_buffer#1.oper_type%type
    , i_resp_code               in aut_buffer#1.resp_code%type
    , i_acq_inst_id             in aut_buffer#1.acq_inst_id%type
    , i_acq_network_id          in aut_buffer#1.acq_network_id%type
    , i_terminal_type           in aut_buffer#1.terminal_type%type
    , i_cat_level               in aut_buffer#1.cat_level%type
    , i_acq_inst_bin            in aut_buffer#1.acq_inst_bin%type
    , i_forw_inst_bin           in aut_buffer#1.forw_inst_bin%type
    , i_merchant_id             in aut_buffer#1.merchant_id%type
    , i_merchant_number         in aut_buffer#1.merchant_number%type
    , i_terminal_id             in aut_buffer#1.terminal_id%type
    , i_terminal_number         in aut_buffer#1.terminal_number%type
    , i_merchant_name           in aut_buffer#1.merchant_name%type
    , i_merchant_street         in aut_buffer#1.merchant_street%type
    , i_merchant_city           in aut_buffer#1.merchant_city%type
    , i_merchant_region         in aut_buffer#1.merchant_region%type
    , i_merchant_country        in aut_buffer#1.merchant_country%type
    , i_merchant_postcode       in aut_buffer#1.merchant_postcode%type
    , i_mcc                     in aut_buffer#1.mcc%type
    , i_refnum                  in aut_buffer#1.refnum%type
    , i_network_refnum          in aut_buffer#1.network_refnum%type
    , i_card_data_input_cap     in aut_buffer#1.card_data_input_cap%type
    , i_crdh_auth_cap           in aut_buffer#1.crdh_auth_cap%type
    , i_card_capture_cap        in aut_buffer#1.card_capture_cap%type
    , i_terminal_operating_env  in aut_buffer#1.terminal_operating_env%type
    , i_crdh_presence           in aut_buffer#1.crdh_presence%type
    , i_card_presence           in aut_buffer#1.card_presence%type
    , i_card_data_input_mode    in aut_buffer#1.card_data_input_mode%type
    , i_crdh_auth_method        in aut_buffer#1.crdh_auth_method%type
    , i_crdh_auth_entity        in aut_buffer#1.crdh_auth_entity%type
    , i_card_data_output_cap    in aut_buffer#1.card_data_output_cap%type
    , i_terminal_output_cap     in aut_buffer#1.terminal_output_cap%type
    , i_pin_capture_cap         in aut_buffer#1.pin_capture_cap%type
    , i_pin_presence            in aut_buffer#1.pin_presence%type
    , i_cvv2_presence           in aut_buffer#1.cvv2_presence%type
    , i_cvc_indicator           in aut_buffer#1.cvc_indicator%type
    , i_pos_entry_mode          in aut_buffer#1.pos_entry_mode%type
    , i_pos_cond_code           in aut_buffer#1.pos_cond_code%type
    , i_service_provider_id     in aut_buffer#1.service_provider_id%type
    , i_service_id              in aut_buffer#1.service_id%type
    , i_emv_data                in aut_buffer#1.emv_data%type
    , i_auth_code               in aut_buffer#1.auth_code%type
    , i_oper_request_amount     in aut_buffer#1.oper_request_amount%type
    , i_oper_amount             in aut_buffer#1.oper_amount%type
    , i_oper_currency           in aut_buffer#1.oper_currency%type
    , i_oper_cashback_amount    in aut_buffer#1.oper_cashback_amount%type
    , i_oper_replacement_amount in aut_buffer#1.oper_replacement_amount%type
    , i_oper_surcharge_amount   in aut_buffer#1.oper_surcharge_amount%type
    , i_oper_date               in aut_buffer#1.oper_date%type
    , i_host_date               in aut_buffer#1.host_date%type
    , i_iss_inst_id             in aut_buffer#1.iss_inst_id%type
    , i_iss_network_id          in aut_buffer#1.iss_network_id%type
    , i_card_number             in aut_buffer#1.card_mask%type
    , i_card_seq_number         in aut_buffer#1.card_seq_number%type
    , i_card_expir_date         in aut_buffer#1.card_expir_date%type
    , i_card_service_code       in aut_buffer#1.card_service_code%type
    , i_account_type            in aut_buffer#1.account_type%type
    , i_account_number          in aut_buffer#1.account_number%type
    , i_account_amount          in aut_buffer#1.account_amount%type
    , i_account_currency        in aut_buffer#1.account_currency%type
    , i_bin_amount              in aut_buffer#1.bin_amount%type
    , i_bin_currency            in aut_buffer#1.bin_currency%type
    , i_network_amount          in aut_buffer#1.network_amount%type
    , i_network_currency        in aut_buffer#1.network_currency%type
    , i_network_cnvt_date       in aut_buffer#1.network_cnvt_date%type
) is
    i                           binary_integer;
    l_status                    com_api_type_pkg.t_dict_value;
    l_status_reason             com_api_type_pkg.t_dict_value;
    l_proc_mode                 com_api_type_pkg.t_dict_value;
    l_proc_type                 com_api_type_pkg.t_dict_value;
begin
    get_status_by_resp (
        i_resp_code             => i_resp_code
        , i_is_reversal         => i_is_reversal
        , o_status              => l_status
        , o_status_reason       => l_status_reason
        , o_proc_mode           => l_proc_mode
        , o_proc_type           => l_proc_type
    );

    if l_proc_type = aut_api_const_pkg.AUTH_PROC_TYPE_IGNORE then
        return;
    elsif l_status_reason is null then
        l_status_reason := aut_api_const_pkg.AUTH_REASON_DUE_TO_RESP_CODE;
    end if;

    i := g_id.count + 1;
    g_id(i) := i_id;

    g_split_hash(i) := com_api_hash_pkg.get_split_hash(i_card_number);
    g_source_id(i) := i_source_id;
    g_original_auth_id(i) := i_original_auth_id;
    g_is_reversal(i) := i_is_reversal;
    g_msg_type(i) := i_msg_type;
    g_oper_type(i) := i_oper_type;
    g_resp_code(i) := i_resp_code;
    g_status(i) := l_status;
    g_status_reason(i) := l_status_reason;
    g_proc_type(i) := l_proc_type;
    g_proc_mode(i) := l_proc_mode;
    g_acq_inst_id(i) := i_acq_inst_id;
    g_acq_network_id(i) := i_acq_network_id;
    g_terminal_type(i) := i_terminal_type;
    g_cat_level(i) := i_cat_level;
    g_acq_inst_bin(i) := i_acq_inst_bin;
    g_forw_inst_bin(i) := i_forw_inst_bin;
    g_merchant_id(i) := i_merchant_id;
    g_merchant_number(i) := i_merchant_number;
    g_terminal_id(i) := i_terminal_id;
    g_terminal_number(i) := i_terminal_number;
    g_merchant_name(i) := i_merchant_name;
    g_merchant_street(i) := i_merchant_street;
    g_merchant_city(i) := i_merchant_city;
    g_merchant_region(i) := i_merchant_region;
    g_merchant_country(i) := i_merchant_country;
    g_merchant_postcode(i) := i_merchant_postcode;
    g_mcc(i) := i_mcc;
    g_refnum(i) := i_refnum;
    g_network_refnum(i) := i_network_refnum;
    g_card_data_input_cap(i) := i_card_data_input_cap;
    g_crdh_auth_cap(i) := i_crdh_auth_cap;
    g_card_capture_cap(i) := i_card_capture_cap;
    g_terminal_operating_env(i) := i_terminal_operating_env;
    g_crdh_presence(i) := i_crdh_presence;
    g_card_presence(i) := i_card_presence;
    g_card_data_input_mode(i) := i_card_data_input_mode;
    g_crdh_auth_method(i) := i_crdh_auth_method;
    g_crdh_auth_entity(i) := i_crdh_auth_entity;
    g_card_data_output_cap(i) := i_card_data_output_cap;
    g_terminal_output_cap(i) := i_terminal_output_cap;
    g_pin_capture_cap(i) := i_pin_capture_cap;
    g_pin_presence(i) := i_pin_presence;
    g_cvv2_presence(i) := i_cvv2_presence;
    g_cvc_indicator(i) := i_cvc_indicator;
    g_pos_entry_mode(i) := i_pos_entry_mode;
    g_pos_cond_code(i) := i_pos_cond_code;
    g_service_provider_id(i) := i_service_provider_id;
    g_service_id(i) := i_service_id;
    g_emv_data(i) := i_emv_data;
    g_auth_code(i) := i_auth_code;
    g_oper_request_amount(i) := i_oper_request_amount;
    g_oper_amount(i) := i_oper_amount;
    g_oper_currency(i) := i_oper_currency;
    g_oper_cashback_amount(i) := i_oper_cashback_amount;
    g_oper_replacement_amount(i) := i_oper_replacement_amount;
    g_oper_surcharge_amount(i) := i_oper_surcharge_amount;
    g_oper_date(i) := i_oper_date;
    g_host_date(i) := i_host_date;
    g_iss_inst_id(i) := i_iss_inst_id;
    g_iss_network_id(i) := i_iss_network_id;
    g_card_number(i) := i_card_number;
    g_card_mask(i) := iss_api_card_pkg.get_card_mask(i_card_number);
    g_card_hash(i) := com_api_hash_pkg.get_card_hash(i_card_number);
    g_card_seq_number(i) := i_card_seq_number;
    g_card_expir_date(i) := i_card_expir_date;
    g_card_service_code(i) := i_card_service_code;
    g_account_type(i) := i_account_type;
    g_account_number(i) := i_account_number;
    g_account_amount(i) := i_account_amount;
    g_account_currency(i) := i_account_currency;
    g_bin_amount(i) := i_bin_amount;
    g_bin_currency(i) := i_bin_currency;
    g_network_amount(i) := i_network_amount;
    g_network_currency(i) := i_network_currency;
    g_network_cnvt_date(i) := i_network_cnvt_date;

    if i >= BULK_LIMIT then
        flush_auth;
    end if;
end;
*/
procedure flush_auth is

    l_active_buffer                 com_api_type_pkg.t_tiny_id;
    auth_count                      binary_integer;
    l_split_hash                    com_api_type_pkg.t_number_tab;

begin
    auth_count := g_id.count;

    if auth_count > 0 then
        lock table aut_active_buffer in exclusive mode;
        l_active_buffer := get_active_buffer_num;

        if l_active_buffer = 1 then
            forall i in 1 .. auth_count
                insert into aut_buffer#1 (
                    id
                    , split_hash
                    , source_id
                    , original_auth_id
                    , is_reversal
                    , msg_type
                    , oper_type
                    , resp_code
                    , status
                    , status_reason
                    , proc_type
                    , proc_mode
                    , acq_inst_id
                    , acq_network_id
                    , terminal_type
                    , cat_level
                    , acq_inst_bin
                    , forw_inst_bin
                    , merchant_id
                    , merchant_number
                    , terminal_id
                    , terminal_number
                    , merchant_name
                    , merchant_street
                    , merchant_city
                    , merchant_region
                    , merchant_country
                    , merchant_postcode
                    , mcc
                    , originator_refnum
                    , network_refnum
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
                    , payment_order_id
                    , payment_host_id
                    , emv_data
                    , auth_code
                    , oper_request_amount
                    , oper_amount
                    , oper_currency
                    , oper_cashback_amount
                    , oper_replacement_amount
                    , oper_surcharge_amount
                    , oper_date
                    , host_date
                    , iss_inst_id
                    , iss_network_id
                    , card_mask
                    , card_hash
                    , card_seq_number
                    , card_expir_date
                    , card_service_code
                    , account_type
                    , account_number
                    , account_amount
                    , account_currency
                    , bin_amount
                    , bin_currency
                    , network_amount
                    , network_currency
                    , network_cnvt_date
                    , parent_id
                ) values (
                    g_id(i)
                    , nvl(
                          (select min(c.split_hash)
                             from iss_card c
                                , iss_card_number cn
                            where cn.card_id = c.id
                              and c.card_hash = g_card_hash(i)
                              and reverse(cn.card_number) = reverse(iss_api_token_pkg.encode_card_number(i_card_number => g_card_number(i))) 
                          ) 
                        , g_split_hash(i)
                      )
                    , g_source_id(i)
                    , g_original_auth_id(i)
                    , g_is_reversal(i)
                    , g_msg_type(i)
                    , g_oper_type(i)
                    , g_resp_code(i)
                    , g_status(i)
                    , g_status_reason(i)
                    , g_proc_type(i)
                    , g_proc_mode(i)
                    , g_acq_inst_id(i)
                    , g_acq_network_id(i)
                    , g_terminal_type(i)
                    , g_cat_level(i)
                    , g_acq_inst_bin(i)
                    , g_forw_inst_bin(i)
                    , g_merchant_id(i)
                    , g_merchant_number(i)
                    , g_terminal_id(i)
                    , g_terminal_number(i)
                    , g_merchant_name(i)
                    , g_merchant_street(i)
                    , g_merchant_city(i)
                    , g_merchant_region(i)
                    , g_merchant_country(i)
                    , g_merchant_postcode(i)
                    , g_mcc(i)
                    , g_originator_refnum(i)
                    , g_network_refnum(i)
                    , g_card_data_input_cap(i)
                    , g_crdh_auth_cap(i)
                    , g_card_capture_cap(i)
                    , g_terminal_operating_env(i)
                    , g_crdh_presence(i)
                    , g_card_presence(i)
                    , g_card_data_input_mode(i)
                    , g_crdh_auth_method(i)
                    , g_crdh_auth_entity(i)
                    , g_card_data_output_cap(i)
                    , g_terminal_output_cap(i)
                    , g_pin_capture_cap(i)
                    , g_pin_presence(i)
                    , g_cvv2_presence(i)
                    , g_cvc_indicator(i)
                    , g_pos_entry_mode(i)
                    , g_pos_cond_code(i)
                    , g_payment_order_id(i)
                    , g_payment_host_id(i)
                    , g_emv_data(i)
                    , g_auth_code(i)
                    , g_oper_request_amount(i)
                    , g_oper_amount(i)
                    , g_oper_currency(i)
                    , g_oper_cashback_amount(i)
                    , g_oper_replacement_amount(i)
                    , g_oper_surcharge_amount(i)
                    , g_oper_date(i)
                    , g_host_date(i)
                    , g_iss_inst_id(i)
                    , g_iss_network_id(i)
                    , g_card_mask(i)
                    , g_card_hash(i)
                    , g_card_seq_number(i)
                    , g_card_expir_date(i)
                    , g_card_service_code(i)
                    , g_account_type(i)
                    , g_account_number(i)
                    , g_account_amount(i)
                    , g_account_currency(i)
                    , g_bin_amount(i)
                    , g_bin_currency(i)
                    , g_network_amount(i)
                    , g_network_currency(i)
                    , g_network_cnvt_date(i)
                    , g_parent_id(i)
                ) returning
                    split_hash
                bulk collect into
                    l_split_hash;

        elsif l_active_buffer = 2 then
            forall i in 1 .. auth_count
                insert into aut_buffer#2 (
                    id
                    , split_hash
                    , source_id
                    , original_auth_id
                    , is_reversal
                    , msg_type
                    , oper_type
                    , resp_code
                    , status
                    , status_reason
                    , proc_type
                    , proc_mode
                    , acq_inst_id
                    , acq_network_id
                    , terminal_type
                    , cat_level
                    , acq_inst_bin
                    , forw_inst_bin
                    , merchant_id
                    , merchant_number
                    , terminal_id
                    , terminal_number
                    , merchant_name
                    , merchant_street
                    , merchant_city
                    , merchant_region
                    , merchant_country
                    , merchant_postcode
                    , mcc
                    , originator_refnum
                    , network_refnum
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
                    , payment_order_id
                    , payment_host_id
                    , emv_data
                    , auth_code
                    , oper_request_amount
                    , oper_amount
                    , oper_currency
                    , oper_cashback_amount
                    , oper_replacement_amount
                    , oper_surcharge_amount
                    , oper_date
                    , host_date
                    , iss_inst_id
                    , iss_network_id
                    , card_mask
                    , card_hash
                    , card_seq_number
                    , card_expir_date
                    , card_service_code
                    , account_type
                    , account_number
                    , account_amount
                    , account_currency
                    , bin_amount
                    , bin_currency
                    , network_amount
                    , network_currency
                    , network_cnvt_date
                    , parent_id
                ) values (
                    g_id(i)
                    , nvl(
                          (select min(c.split_hash)
                             from iss_card c
                                , iss_card_number cn
                            where cn.card_id = c.id
                              and c.card_hash = g_card_hash(i)
                              and reverse(cn.card_number) = reverse(iss_api_token_pkg.encode_card_number(i_card_number => g_card_number(i))) 
                          ) 
                        , g_split_hash(i)
                      )
                    , g_source_id(i)
                    , g_original_auth_id(i)
                    , g_is_reversal(i)
                    , g_msg_type(i)
                    , g_oper_type(i)
                    , g_resp_code(i)
                    , g_status(i)
                    , g_status_reason(i)
                    , g_proc_type(i)
                    , g_proc_mode(i)
                    , g_acq_inst_id(i)
                    , g_acq_network_id(i)
                    , g_terminal_type(i)
                    , g_cat_level(i)
                    , g_acq_inst_bin(i)
                    , g_forw_inst_bin(i)
                    , g_merchant_id(i)
                    , g_merchant_number(i)
                    , g_terminal_id(i)
                    , g_terminal_number(i)
                    , g_merchant_name(i)
                    , g_merchant_street(i)
                    , g_merchant_city(i)
                    , g_merchant_region(i)
                    , g_merchant_country(i)
                    , g_merchant_postcode(i)
                    , g_mcc(i)
                    , g_originator_refnum(i)
                    , g_network_refnum(i)
                    , g_card_data_input_cap(i)
                    , g_crdh_auth_cap(i)
                    , g_card_capture_cap(i)
                    , g_terminal_operating_env(i)
                    , g_crdh_presence(i)
                    , g_card_presence(i)
                    , g_card_data_input_mode(i)
                    , g_crdh_auth_method(i)
                    , g_crdh_auth_entity(i)
                    , g_card_data_output_cap(i)
                    , g_terminal_output_cap(i)
                    , g_pin_capture_cap(i)
                    , g_pin_presence(i)
                    , g_cvv2_presence(i)
                    , g_cvc_indicator(i)
                    , g_pos_entry_mode(i)
                    , g_pos_cond_code(i)
                    , g_payment_order_id(i)
                    , g_payment_host_id(i)
                    , g_emv_data(i)
                    , g_auth_code(i)
                    , g_oper_request_amount(i)
                    , g_oper_amount(i)
                    , g_oper_currency(i)
                    , g_oper_cashback_amount(i)
                    , g_oper_replacement_amount(i)
                    , g_oper_surcharge_amount(i)
                    , g_oper_date(i)
                    , g_host_date(i)
                    , g_iss_inst_id(i)
                    , g_iss_network_id(i)
                    , g_card_mask(i)
                    , g_card_hash(i)
                    , g_card_seq_number(i)
                    , g_card_expir_date(i)
                    , g_card_service_code(i)
                    , g_account_type(i)
                    , g_account_number(i)
                    , g_account_amount(i)
                    , g_account_currency(i)
                    , g_bin_amount(i)
                    , g_bin_currency(i)
                    , g_network_amount(i)
                    , g_network_currency(i)
                    , g_network_cnvt_date(i)
                    , g_parent_id(i)
                ) returning
                    split_hash
                bulk collect into
                    l_split_hash;
        end if;

        forall i in 1 .. auth_count
            insert into aut_card (
                auth_id
                , split_hash
                , card_number
            ) values (
                g_id(i)
                , l_split_hash(i)
                , iss_api_token_pkg.encode_card_number(i_card_number => g_card_number(i))
            );
    end if;

    clear_global_data;
end;

procedure get_card_inst_netw (
    i_card_number               in com_api_type_pkg.t_card_number
    , i_iss_network_id          in com_api_type_pkg.t_tiny_id
    , i_iss_inst_id             in com_api_type_pkg.t_inst_id
    , o_card_network_id         out com_api_type_pkg.t_tiny_id
    , o_card_inst_id            out com_api_type_pkg.t_inst_id
    , o_card_type               out com_api_type_pkg.t_tiny_id
    , o_card_country            out com_api_type_pkg.t_curr_code
    , i_iss_check_own_card      in com_api_type_pkg.t_boolean
    , i_iss_check_own_bin       in com_api_type_pkg.t_boolean
    , i_iss_check_netw_bin      in com_api_type_pkg.t_boolean
    , i_iss_check_comm_bin      in com_api_type_pkg.t_boolean
) is
    l_pan_length                com_api_type_pkg.t_tiny_id;
    l_iss_inst_id               com_api_type_pkg.t_inst_id;
    l_iss_host_id               com_api_type_pkg.t_tiny_id;
    l_iss_network_id            com_api_type_pkg.t_tiny_id;
begin
    if (
        i_iss_check_own_card = com_api_type_pkg.FALSE
        and i_iss_check_own_bin = com_api_type_pkg.FALSE
        and i_iss_check_netw_bin = com_api_type_pkg.FALSE
        and i_iss_check_comm_bin = com_api_type_pkg.FALSE
    ) then

        o_card_network_id := i_iss_network_id;
        o_card_inst_id := i_iss_inst_id;
        o_card_type := null;
        o_card_country := null;

    else
        if i_iss_check_own_bin = com_api_type_pkg.TRUE then
            iss_api_bin_pkg.get_bin_info (
                i_card_number       => i_card_number
                , o_card_inst_id    => o_card_inst_id
                , o_card_network_id => o_card_network_id
                , o_card_type       => o_card_type
                , o_card_country    => o_card_country
            );
        end if;

        if o_card_inst_id is null and i_iss_check_netw_bin = com_api_type_pkg.TRUE then
            net_api_bin_pkg.get_bin_info (
                i_card_number           => i_card_number
                , i_network_id          => i_iss_network_id
                , o_iss_inst_id         => l_iss_inst_id
                , o_iss_host_id         => l_iss_host_id
                , o_card_type_id        => o_card_type
                , o_card_country        => o_card_country
                , o_card_inst_id        => o_card_inst_id
                , o_card_network_id     => o_card_network_id
                , o_pan_length          => l_pan_length
                , i_raise_error         => com_api_const_pkg.FALSE
            );
        end if;

        if o_card_inst_id is null and i_iss_check_comm_bin = com_api_type_pkg.TRUE then
            net_api_bin_pkg.get_bin_info (
                i_card_number           => i_card_number
                , o_iss_network_id      => l_iss_network_id
                , o_iss_inst_id         => l_iss_inst_id
                , o_iss_host_id         => l_iss_host_id
                , o_card_type_id        => o_card_type
                , o_card_country        => o_card_country
                , o_card_inst_id        => o_card_inst_id
                , o_card_network_id     => o_card_network_id
                , o_pan_length          => l_pan_length
                , i_raise_error         => com_api_const_pkg.FALSE
            );
        end if;
    end if;
end;

/*
 * Obsolete. Query statement <l_auth_cur_stmt> contains at least 1 error: table aut_buffer#1 has no field <card_number>.
 */
procedure load_auth is

    l_active_buffer             com_api_type_pkg.t_tiny_id;
    l_auth_cur                  sys_refcursor;
    l_auth_cur_stmt             varchar2(4000);
    WHERE_PLACEHOLDER           varchar2(40) := '####WHERE####';
    l_ignored_auth              com_api_type_pkg.t_integer_tab;
    l_rejected_auth             com_api_type_pkg.t_integer_tab;
    l_loaded_auth               com_api_type_pkg.t_integer_tab;
    l_wrong_data                boolean;
    l_status_reason             com_api_type_pkg.t_dict_value;
    l_session_id                com_api_type_pkg.t_long_id := get_session_id;
    l_thread_number             com_api_type_pkg.t_tiny_id := get_thread_number;
    l_estimated_count           com_api_type_pkg.t_long_id := 0;
    l_excepted_count            com_api_type_pkg.t_long_id := 0;

    procedure clear_auth_buffers is
    begin
        l_rejected_auth.delete;
        l_ignored_auth.delete;
        l_loaded_auth.delete;
    end;

    procedure flush_auth is
    begin
/*        if l_loaded_auth.count > 0 then
            forall i in values of l_loaded_auth
                insert into aut_auth (
                    id
                    , split_hash
                    , session_id
                    , source_id
                    , original_auth_id
                    , is_reversal
                    , msg_type
                    , oper_type
                    , resp_code
                    , status
                    , status_reason
                    , proc_type
                    , proc_mode
                    , sttl_type
                    , acq_inst_id
                    , acq_network_id
                    , split_hash_acq
                    , terminal_type
                    , cat_level
                    , acq_inst_bin
                    , forw_inst_bin
                    , merchant_id
                    , merchant_number
                    , terminal_id
                    , terminal_number
                    , merchant_name
                    , merchant_street
                    , merchant_city
                    , merchant_region
                    , merchant_country
                    , merchant_postcode
                    , mcc
                    , originator_refnum
                    , network_refnum
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
                    , payment_order_id
                    , payment_host_id
                    , emv_data
                    , auth_code
                    , oper_request_amount
                    , oper_amount
                    , oper_currency
                    , oper_cashback_amount
                    , oper_replacement_amount
                    , oper_surcharge_amount
                    , oper_date
                    , host_date
                    , iss_inst_id
                    , iss_network_id
                    , split_hash_iss
                    , card_inst_id
                    , card_network_id
                    , card_id
                    , card_type_id
                    , card_mask
                    , card_hash
                    , card_seq_number
                    , card_expir_date
                    , card_service_code
                    , card_country
                    , account_type
                    , account_number
                    , account_amount
                    , account_currency
                    , bin_amount
                    , bin_currency
                    , network_amount
                    , network_currency
                    , network_cnvt_date
                    , match_status
                    , oper_id
                    , parent_id
                ) values (
                    g_id(i)
                    , g_split_hash(i)
                    , l_session_id
                    , g_source_id(i)
                    , g_original_auth_id(i)
                    , g_is_reversal(i)
                    , g_msg_type(i)
                    , g_oper_type(i)
                    , g_resp_code(i)
                    , g_status(i)
                    , g_status_reason(i)
                    , g_proc_type(i)
                    , g_proc_mode(i)
                    , g_sttl_type(i)
                    , g_acq_inst_id(i)
                    , g_acq_network_id(i)
                    , g_split_hash_acq(i)
                    , g_terminal_type(i)
                    , g_cat_level(i)
                    , g_acq_inst_bin(i)
                    , g_forw_inst_bin(i)
                    , g_merchant_id(i)
                    , g_merchant_number(i)
                    , g_terminal_id(i)
                    , g_terminal_number(i)
                    , g_merchant_name(i)
                    , g_merchant_street(i)
                    , g_merchant_city(i)
                    , g_merchant_region(i)
                    , g_merchant_country(i)
                    , g_merchant_postcode(i)
                    , g_mcc(i)
                    , g_originator_refnum(i)
                    , g_network_refnum(i)
                    , g_card_data_input_cap(i)
                    , g_crdh_auth_cap(i)
                    , g_card_capture_cap(i)
                    , g_terminal_operating_env(i)
                    , g_crdh_presence(i)
                    , g_card_presence(i)
                    , g_card_data_input_mode(i)
                    , g_crdh_auth_method(i)
                    , g_crdh_auth_entity(i)
                    , g_card_data_output_cap(i)
                    , g_terminal_output_cap(i)
                    , g_pin_capture_cap(i)
                    , g_pin_presence(i)
                    , g_cvv2_presence(i)
                    , g_cvc_indicator(i)
                    , g_pos_entry_mode(i)
                    , g_pos_cond_code(i)
                    , g_payment_order_id(i)
                    , g_payment_host_id(i)
                    , g_emv_data(i)
                    , g_auth_code(i)
                    , g_oper_request_amount(i)
                    , g_oper_amount(i)
                    , g_oper_currency(i)
                    , g_oper_cashback_amount(i)
                    , g_oper_replacement_amount(i)
                    , g_oper_surcharge_amount(i)
                    , g_oper_date(i)
                    , g_host_date(i)
                    , g_iss_inst_id(i)
                    , g_iss_network_id(i)
                    , g_split_hash_iss(i)
                    , g_card_inst_id(i)
                    , g_card_network_id(i)
                    , g_card_id(i)
                    , g_card_type_id(i)
                    , g_card_mask(i)
                    , g_card_hash(i)
                    , g_card_seq_number(i)
                    , g_card_expir_date(i)
                    , g_card_service_code(i)
                    , g_card_country(i)
                    , g_account_type(i)
                    , g_account_number(i)
                    , g_account_amount(i)
                    , g_account_currency(i)
                    , g_bin_amount(i)
                    , g_bin_currency(i)
                    , g_network_amount(i)
                    , g_network_currency(i)
                    , g_network_cnvt_date(i)
                    , g_match_status(i)
                    , null
                    , g_parent_id(i)
                );
        end if;

        if l_rejected_auth.count > 0 then
            forall i in values of l_rejected_auth
                insert into aut_reject (
                    id
                    , split_hash
                    , session_id
                    , source_id
                    , original_auth_id
                    , is_reversal
                    , msg_type
                    , oper_type
                    , resp_code
                    , acq_inst_id
                    , acq_network_id
                    , terminal_type
                    , cat_level
                    , acq_inst_bin
                    , forw_inst_bin
                    , merchant_id
                    , merchant_number
                    , terminal_id
                    , terminal_number
                    , merchant_name
                    , merchant_street
                    , merchant_city
                    , merchant_region
                    , merchant_country
                    , merchant_postcode
                    , mcc
                    , originator_refnum
                    , network_refnum
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
                    , payment_order_id
                    , payment_host_id
                    , emv_data
                    , auth_code
                    , oper_request_amount
                    , oper_amount
                    , oper_currency
                    , oper_cashback_amount
                    , oper_replacement_amount
                    , oper_surcharge_amount
                    , oper_date
                    , host_date
                    , iss_inst_id
                    , iss_network_id
                    , card_mask
                    , card_hash
                    , card_seq_number
                    , card_expir_date
                    , card_service_code
                    , account_type
                    , account_number
                    , account_amount
                    , account_currency
                    , bin_amount
                    , bin_currency
                    , network_amount
                    , network_currency
                    , network_cnvt_date
                    , parent_id
                ) values (
                    g_id(i)
                    , g_split_hash(i)
                    , l_session_id
                    , g_source_id(i)
                    , g_original_auth_id(i)
                    , g_is_reversal(i)
                    , g_msg_type(i)
                    , g_oper_type(i)
                    , g_resp_code(i)
                    , g_acq_inst_id(i)
                    , g_acq_network_id(i)
                    , g_terminal_type(i)
                    , g_cat_level(i)
                    , g_acq_inst_bin(i)
                    , g_forw_inst_bin(i)
                    , g_merchant_id(i)
                    , g_merchant_number(i)
                    , g_terminal_id(i)
                    , g_terminal_number(i)
                    , g_merchant_name(i)
                    , g_merchant_street(i)
                    , g_merchant_city(i)
                    , g_merchant_region(i)
                    , g_merchant_country(i)
                    , g_merchant_postcode(i)
                    , g_mcc(i)
                    , g_originator_refnum(i)
                    , g_network_refnum(i)
                    , g_card_data_input_cap(i)
                    , g_crdh_auth_cap(i)
                    , g_card_capture_cap(i)
                    , g_terminal_operating_env(i)
                    , g_crdh_presence(i)
                    , g_card_presence(i)
                    , g_card_data_input_mode(i)
                    , g_crdh_auth_method(i)
                    , g_crdh_auth_entity(i)
                    , g_card_data_output_cap(i)
                    , g_terminal_output_cap(i)
                    , g_pin_capture_cap(i)
                    , g_pin_presence(i)
                    , g_cvv2_presence(i)
                    , g_cvc_indicator(i)
                    , g_pos_entry_mode(i)
                    , g_pos_cond_code(i)
                    , g_payment_order_id(i)
                    , g_payment_host_id(i)
                    , g_emv_data(i)
                    , g_auth_code(i)
                    , g_oper_request_amount(i)
                    , g_oper_amount(i)
                    , g_oper_currency(i)
                    , g_oper_cashback_amount(i)
                    , g_oper_replacement_amount(i)
                    , g_oper_surcharge_amount(i)
                    , g_oper_date(i)
                    , g_host_date(i)
                    , g_iss_inst_id(i)
                    , g_iss_network_id(i)
                    , g_card_mask(i)
                    , g_card_hash(i)
                    , g_card_seq_number(i)
                    , g_card_expir_date(i)
                    , g_card_service_code(i)
                    , g_account_type(i)
                    , g_account_number(i)
                    , g_account_amount(i)
                    , g_account_currency(i)
                    , g_bin_amount(i)
                    , g_bin_currency(i)
                    , g_network_amount(i)
                    , g_network_currency(i)
                    , g_network_cnvt_date(i)
                    , g_parent_id(i)
                );
        end if;

        if l_ignored_auth.count > 0 then
            forall i in values of l_ignored_auth
                delete from
                    aut_card
                where
                    rowid = g_card_rowid(i);
        end if;

        if l_active_buffer = 1 then
            forall i in 1 .. g_auth_rowid.count
                delete from
                    aut_buffer#1
                where
                    rowid = g_auth_rowid(i);

        elsif l_active_buffer = 2 then
            forall i in 1 .. g_auth_rowid.count
                delete from
                    aut_buffer#2
                where
                    rowid = g_auth_rowid(i);

        end if;
*/

        clear_auth_buffers;
    end;

begin
    prc_api_stat_pkg.log_start;

    l_active_buffer := neg_active_buffer_num(get_active_buffer_num);

    l_auth_cur_stmt := 'select count(*) from aut_buffer#' || l_active_buffer || ' b';

    if l_thread_number > 0 then
        l_auth_cur_stmt := l_auth_cur_stmt || ' where b.split_hash in (select m.split_hash from com_split_map m where m.thread_number = :tread_number)';
        execute immediate l_auth_cur_stmt into l_estimated_count using l_thread_number;
    else
        execute immediate l_auth_cur_stmt into l_estimated_count;
    end if;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_estimated_count
    );

    l_auth_cur_stmt := '
select --+ ORDERED
    b.rowid auth_rowid
    , b.id
    , b.split_hash
    , b.source_id
    , b.original_auth_id
    , b.is_reversal
    , b.msg_type
    , b.oper_type
    , b.resp_code
    , b.status
    , b.status_reason
    , b.proc_type
    , b.proc_mode
    , b.acq_inst_id
    , b.acq_network_id
    , b.terminal_type
    , b.cat_level
    , b.acq_inst_bin
    , b.forw_inst_bin
    , b.merchant_id
    , b.merchant_number
    , b.terminal_id
    , b.terminal_number
    , b.merchant_name
    , b.merchant_street
    , b.merchant_city
    , b.merchant_region
    , b.merchant_country
    , b.merchant_postcode
    , b.mcc
    , b.originator_refnum
    , b.network_refnum
    , b.card_data_input_cap
    , b.crdh_auth_cap
    , b.card_capture_cap
    , b.terminal_operating_env
    , b.crdh_presence
    , b.card_presence
    , b.card_data_input_mode
    , b.crdh_auth_method
    , b.crdh_auth_entity
    , b.card_data_output_cap
    , b.terminal_output_cap
    , b.pin_capture_cap
    , b.pin_presence
    , b.cvv2_presence
    , b.cvc_indicator
    , b.pos_entry_mode
    , b.pos_cond_code
    , b.payment_order_id
    , b.payment_host_id
    , b.emv_data
    , b.auth_code
    , b.oper_request_amount
    , b.oper_amount
    , b.oper_currency
    , b.oper_cashback_amount
    , b.oper_replacement_amount
    , b.oper_surcharge_amount
    , b.oper_date
    , b.host_date
    , b.iss_inst_id
    , b.iss_network_id
    , b.card_mask
    , b.card_hash
    , b.card_seq_number
    , b.card_expir_date
    , b.card_service_code
    , b.account_type
    , b.account_number
    , b.account_amount
    , b.account_currency
    , b.bin_amount
    , b.bin_currency
    , b.network_amount
    , b.network_currency
    , b.network_cnvt_date
    , c.rowid card_rowid
    , c.card_number
    , oc.inst_id                    card_inst_id
    , oc.id                         card_id
    , oc.split_hash                 split_hash_iss
    , oc.card_type_id               card_type_id
    , oc.country                    card_country
    , ct.network_id                 card_network
    , mrc.id                        own_merchant_id
    , mrc.split_hash                split_hash_acq
    , iss_net.iss_check_own_card
    , iss_net.iss_check_own_bin
    , iss_net.iss_check_netw_bin
    , iss_net.iss_check_common_bin
    , acq_net.acq_check_own_terminal
    , acq_net.acq_check_own_merchant
    , b.parent_id
from
    aut_buffer#' || l_active_buffer || ' b
    , aut_card c
    , iss_card oc
    , iss_card_number cn
    , net_card_type ct
    , net_network iss_net
    , net_network acq_net
    , acq_merchant mrc
where
    ' || WHERE_PLACEHOLDER || '
    -- join auth card number
    b.id = c.auth_id
    cn.card_id = oc.id
    -- try to join own card and internal card type
    and b.card_hash = oc.card_hash(+)
    and b.card_number = oc.card_number(+)
    and oc.card_type_id = ct.id(+)
    -- try to find networks
    and b.iss_network_id = iss_net.id(+)
    and b.acq_network_id = acq_net.id(+)
    -- try to join own merchant
    and b.acq_inst_id = mrc.inst_id(+)
    and b.merchant_number = mrc.merchant_number(+)
order by
    c.card_number,
    b.host_date,
    b.source_id,
    b.source_auth_id
for update of
    b.id,
    c.auth_id';


    if l_thread_number > 0 then
        l_auth_cur_stmt := replace(l_auth_cur_stmt, WHERE_PLACEHOLDER, ' b.split_hash in (select m.split_hash from com_split_map m where m.thread_number = :i_thread_number) and ');
        open l_auth_cur for l_auth_cur_stmt using l_thread_number;
    else
        l_auth_cur_stmt := replace(l_auth_cur_stmt, WHERE_PLACEHOLDER, '');
        open l_auth_cur for l_auth_cur_stmt;
    end if;

    loop
        clear_auth_buffers;

        fetch l_auth_cur
        bulk collect into
            g_auth_rowid
            , g_id
            , g_split_hash
            , g_source_id
            , g_original_auth_id
            , g_is_reversal
            , g_msg_type
            , g_oper_type
            , g_resp_code
            , g_status
            , g_status_reason
            , g_proc_type
            , g_proc_mode
            , g_acq_inst_id
            , g_acq_network_id
            , g_terminal_type
            , g_cat_level
            , g_acq_inst_bin
            , g_forw_inst_bin
            , g_merchant_id
            , g_merchant_number
            , g_terminal_id
            , g_terminal_number
            , g_merchant_name
            , g_merchant_street
            , g_merchant_city
            , g_merchant_region
            , g_merchant_country
            , g_merchant_postcode
            , g_mcc
            , g_originator_refnum
            , g_network_refnum
            , g_card_data_input_cap
            , g_crdh_auth_cap
            , g_card_capture_cap
            , g_terminal_operating_env
            , g_crdh_presence
            , g_card_presence
            , g_card_data_input_mode
            , g_crdh_auth_method
            , g_crdh_auth_entity
            , g_card_data_output_cap
            , g_terminal_output_cap
            , g_pin_capture_cap
            , g_pin_presence
            , g_cvv2_presence
            , g_cvc_indicator
            , g_pos_entry_mode
            , g_pos_cond_code
            , g_payment_order_id
            , g_payment_host_id
            , g_emv_data
            , g_auth_code
            , g_oper_request_amount
            , g_oper_amount
            , g_oper_currency
            , g_oper_cashback_amount
            , g_oper_replacement_amount
            , g_oper_surcharge_amount
            , g_oper_date
            , g_host_date
            , g_iss_inst_id
            , g_iss_network_id
            , g_card_mask
            , g_card_hash
            , g_card_seq_number
            , g_card_expir_date
            , g_card_service_code
            , g_account_type
            , g_account_number
            , g_account_amount
            , g_account_currency
            , g_bin_amount
            , g_bin_currency
            , g_network_amount
            , g_network_currency
            , g_network_cnvt_date
            , g_card_rowid
            , g_card_number
            , g_card_inst_id
            , g_card_id
            , g_split_hash_iss
            , g_card_type_id
            , g_card_country
            , g_card_network_id
            , g_own_merchant_id
            , g_split_hash_acq
            , g_iss_check_own_card
            , g_iss_check_own_bin
            , g_iss_check_netw_bin
            , g_iss_check_common_bin
            , g_acq_check_own_terminal
            , g_acq_check_own_merchant
            , g_parent_id
        limit BULK_LIMIT;

        for i in 1 .. g_auth_rowid.count loop
            if g_proc_type(i) = aut_api_const_pkg.AUTH_PROC_TYPE_REJECT then
                l_rejected_auth(l_rejected_auth.count+1) := i;
            elsif g_proc_type(i) = aut_api_const_pkg.AUTH_PROC_TYPE_IGNORE then
                l_ignored_auth(l_ignored_auth.count+1) := i;
            else
                if g_is_reversal(i) = com_api_type_pkg.TRUE then
                    flush_auth;
                end if;

                l_loaded_auth(l_loaded_auth.count+1) := i;

                if g_status(i) = opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY then

                    l_wrong_data := false;
                    l_status_reason := null;

                    if not l_wrong_data and g_iss_inst_id(i) is null then -- issuer instititution wrong in auth or badly mapped
                        trc_log_pkg.error(
                            i_text          => 'WRONG_INSTITUTION_DEFINITION'
                          , i_env_param1    => 'ISS'
                          , i_env_param2    => g_source_id(i)
                          , i_env_param3    => g_iss_inst_id(i)
                          , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                          , i_object_id     => g_id(i)
                        );

                        l_wrong_data := true;
                        l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_ISS_INST;
                    end if;

                    if not l_wrong_data and g_iss_network_id(i) is null then -- issuer network wrong in auth or badly mapped
                        trc_log_pkg.error(
                            i_text          => 'WRONG_NETWORK_DEFINITION'
                          , i_env_param1    => 'ISS'
                          , i_env_param2    => g_source_id(i)
                          , i_env_param3    => g_iss_network_id(i)
                          , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                          , i_object_id     => g_id(i)
                        );

                        l_wrong_data := true;
                        l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_ISS_NETW;
                    end if;

                    if not l_wrong_data and g_acq_inst_id(i) is null then -- acquirer instititution wrong in auth or badly mapped
                        trc_log_pkg.error(
                            i_text          => 'WRONG_INSTITUTION_DEFINITION'
                          , i_env_param1    => 'ACQ'
                          , i_env_param2    => g_source_id(i)
                          , i_env_param3    => g_acq_inst_id(i)
                          , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                          , i_object_id     => g_id(i)
                        );

                        l_wrong_data := true;
                        l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_ACQ_INST;
                    end if;

                    if not l_wrong_data and g_acq_network_id(i) is null then -- acquirer network wrong in auth or badly mapped
                        trc_log_pkg.error(
                            i_text          => 'WRONG_NETWORK_DEFINITION'
                          , i_env_param1    => 'ACQ'
                          , i_env_param2    => g_source_id(i)
                          , i_env_param3    => g_acq_network_id(i)
                          , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                          , i_object_id     => g_id(i)
                        );

                        l_wrong_data := true;
                        l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_ACQ_NETW;
                    end if;

                    if not l_wrong_data and g_card_inst_id(i) is null then -- own card not found
                        get_card_inst_netw (
                            i_card_number           => g_card_number(i)
                            , i_iss_network_id      => g_iss_network_id(i)
                            , i_iss_inst_id         => g_iss_inst_id(i)
                            , o_card_network_id     => g_card_network_id(i)
                            , o_card_inst_id        => g_card_inst_id(i)
                            , o_card_type           => g_card_type_id(i)
                            , o_card_country        => g_card_country(i)
                            , i_iss_check_own_card  => g_iss_check_own_card(i)
                            , i_iss_check_own_bin   => g_iss_check_own_bin(i)
                            , i_iss_check_netw_bin  => g_iss_check_netw_bin(i)
                            , i_iss_check_comm_bin  => g_iss_check_common_bin(i)
                        );
                    end if;

                    if not l_wrong_data and g_card_inst_id(i) is null then -- card owner not found accordingly to issuer network attributes
                        trc_log_pkg.error(
                            i_text          => 'CANNOT_FIND_CARD_OWNER_INST'
                          , i_env_param1    => g_iss_network_id(i)
                          , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                          , i_object_id     => g_id(i)
                        );

                        l_wrong_data := true;
                        l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_CARD_INST;
                    end if;

                    if not l_wrong_data and g_card_network_id(i) is null then -- card owner network not found accordingly to issuer network attributes
                        trc_log_pkg.error(
                            i_text          => 'CANNOT_FIND_CARD_OWNER_NETW'
                          , i_env_param1    => g_iss_network_id(i)
                          , i_env_param2    => g_iss_inst_id(i)
                          , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                          , i_object_id     => g_id(i)
                        );

                        l_wrong_data := true;
                        l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_CARD_NETW;
                    end if;

                    if not l_wrong_data and (
                        g_acq_check_own_terminal(i) = com_api_type_pkg.TRUE
                        or g_acq_check_own_merchant(i) = com_api_type_pkg.TRUE
                    ) and g_own_merchant_id(i) is null then -- own merchant not found
                            trc_log_pkg.error(
                                i_text          => 'UNKNOWN_MERCHANT'
                              , i_env_param1    => g_merchant_number(i)
                              , i_env_param2    => g_acq_inst_id(i)
                              , i_env_param3    => g_acq_network_id(i)
                              , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                              , i_object_id     => g_id(i)
                            );

                            l_wrong_data := true;
                            l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_MERCHANT;

                    elsif not l_wrong_data and (
                        g_acq_check_own_terminal(i) = com_api_type_pkg.TRUE
                        or g_acq_check_own_merchant(i) = com_api_type_pkg.TRUE
                    ) and nvl(g_merchant_id(i), g_own_merchant_id(i)) != g_own_merchant_id(i) then -- own merchant found but id is different
                            trc_log_pkg.error(
                                i_text          => 'UNKNOWN_MERCHANT'
                              , i_env_param1    => g_merchant_number(i)
                              , i_env_param2    => g_acq_inst_id(i)
                              , i_env_param3    => g_acq_network_id(i)
                              , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                              , i_object_id     => g_id(i)
                            );

                            l_wrong_data := true;
                            l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_MERCHANT;

                    end if;

                    if not l_wrong_data and g_acq_check_own_terminal(i) = com_api_type_pkg.TRUE then
                        acq_api_terminal_pkg.get_terminal (
                            i_merchant_id           => g_own_merchant_id(i)
                            , i_terminal_number     => g_terminal_number(i)
                            , o_terminal_id         => g_terminal_id(i)
                        );

                        if g_terminal_id(i) is null then
                            trc_log_pkg.error(
                                i_text          => 'UNKNOWN_TERMINAL'
                              , i_env_param1    => g_acq_network_id(i)
                              , i_env_param2    => g_acq_inst_id(i)
                              , i_env_param3    => g_merchant_number(i)
                              , i_env_param4    => g_terminal_number(i)
                              , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                              , i_object_id     => g_id(i)
                            );

                            l_wrong_data := true;
                            l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_TERMINAL;
                        end if;
                    end if;

                    if not l_wrong_data then
                        net_api_sttl_pkg.get_sttl_type (
                            i_iss_inst_id           => g_iss_inst_id(i)
                            , i_acq_inst_id         => g_acq_inst_id(i)
                            , i_card_inst_id        => g_card_inst_id(i)
                            , i_iss_network_id      => g_iss_network_id(i)
                            , i_acq_network_id      => g_acq_network_id(i)
                            , i_card_network_id     => g_card_network_id(i)
                            , i_acq_inst_bin        => g_acq_inst_bin(i)
                            , o_sttl_type           => g_sttl_type(i)
                            , o_match_status        => g_match_status(i)
                            , i_oper_type           => g_oper_type(i)
                        );

                        if g_sttl_type(i) is null then
                            trc_log_pkg.error(
                                i_text          => 'UNKNOWN_SETTLEMENT_TYPE'
                              , i_env_param1    => g_iss_network_id(i)
                              , i_env_param2    => g_iss_inst_id(i)
                              , i_env_param3    => g_acq_network_id(i)
                              , i_env_param4    => g_acq_inst_id(i)
                              , i_env_param5    => g_card_network_id(i)
                              , i_env_param6    => g_card_inst_id(i)
                              , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                              , i_object_id     => g_id(i)
                            );

                            l_wrong_data := true;
                            l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_STTL_TYPE;
                        end if;
                    end if;

                    if l_wrong_data then
                        g_status(i) := opr_api_const_pkg.OPERATION_STATUS_WRONG_DATA;
                        g_status_reason(i) := l_status_reason;
                        l_excepted_count := l_excepted_count + 1;
                    end if;
                end if;
            end if;
        end loop;

        flush_auth;

        prc_api_stat_pkg.increase_current (
            i_current_count       => g_auth_rowid.count
          , i_excepted_count      => l_excepted_count
        );

        exit when l_auth_cur%notfound;
    end loop;

    prc_api_stat_pkg.log_end (
        i_excepted_total    => l_excepted_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        if l_auth_cur%isopen then
            close l_auth_cur;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;
end;

/*    function get_network_checks (
        i_iss_network_id            in  com_api_type_pkg.t_inst_id
        , o_iss_check_own_card      out com_api_type_pkg.t_boolean
        , o_iss_check_own_bin       out com_api_type_pkg.t_boolean
        , o_iss_check_netw_bin      out com_api_type_pkg.t_boolean
        , o_iss_check_comm_bin      out com_api_type_pkg.t_boolean
    ) return boolean is
    begin
        select
            n.iss_check_own_card
            , n.iss_check_own_bin
            , n.iss_check_netw_bin
            , n.iss_check_common_bin
        into
            o_iss_check_own_card
            , o_iss_check_own_bin
            , o_iss_check_netw_bin
            , o_iss_check_comm_bin
        from
            net_network n
        where
            n.id = i_iss_network_id;

        return true;
    exception
        when others then
            return false;
    end;

    function get_network_checks (
        i_acq_network_id            in  com_api_type_pkg.t_inst_id
        , o_acq_check_own_merchant  out com_api_type_pkg.t_boolean
        , o_acq_check_own_terminal  out com_api_type_pkg.t_boolean
    ) return boolean is
    begin
        select
            n.acq_check_own_merchant
            , n.acq_check_own_terminal
        into
            o_acq_check_own_merchant
            , o_acq_check_own_terminal
        from
            net_network n
        where
            n.id = i_acq_network_id;

        return true;
    exception
        when others then
            return false;
    end;*/

procedure revalidate_auth is
    l_session_id                com_api_type_pkg.t_long_id := get_session_id;
    l_thread_number             com_api_type_pkg.t_tiny_id := get_thread_number;
    l_auth_cur                  sys_refcursor;
    l_auth_cur_stmt             varchar2(4000);
    WHERE_PLACEHOLDER           varchar2(40) := '####WHERE####';
    l_ignored_auth              com_api_type_pkg.t_integer_tab;
    l_rejected_auth             com_api_type_pkg.t_integer_tab;
    l_loaded_auth               com_api_type_pkg.t_integer_tab;
    l_wrong_data                boolean;
    l_status_reason             com_api_type_pkg.t_dict_value;
    l_estimated_count           com_api_type_pkg.t_long_id := 0;
    l_excepted_count            com_api_type_pkg.t_long_id := 0;
begin
    prc_api_stat_pkg.log_start;

    l_auth_cur_stmt := 'select count(*) from aut_auth a where decode(a.status, ''' || opr_api_const_pkg.OPERATION_STATUS_CORRECTED || ''', ''' || opr_api_const_pkg.OPERATION_STATUS_CORRECTED || ''', null) = :auth_status_corrected';

    if l_thread_number > 0 then
        l_auth_cur_stmt := l_auth_cur_stmt || ' and a.split_hash in (select m.split_hash from com_split_map m where m.thread_number = :tread_number)';

        trc_log_pkg.debug (
            i_text          => l_auth_cur_stmt
        );

        execute immediate l_auth_cur_stmt into l_estimated_count using opr_api_const_pkg.OPERATION_STATUS_CORRECTED, l_thread_number;
    else

        trc_log_pkg.debug (
            i_text          => l_auth_cur_stmt
        );

        execute immediate l_auth_cur_stmt into l_estimated_count using opr_api_const_pkg.OPERATION_STATUS_CORRECTED;
    end if;

    trc_log_pkg.debug (
        i_text          => 'Estimated count for thread [#1] is [#2]'
        , i_env_param1  => l_thread_number
        , i_env_param2  => l_estimated_count
    );

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_estimated_count
    );

    l_auth_cur_stmt := '
select
    b.rowid auth_rowid
    , b.id
    , b.split_hash
    , b.source_id
    , b.source_auth_id
    , b.source_original_auth_id
    , b.is_reversal
    , b.msg_type
    , b.oper_type
    , b.resp_code
    , b.status
    , b.status_reason
    , b.proc_type
    , b.proc_mode
    , b.source_acq_inst
    , b.source_acq_network
    , nvl((select min(m.inst_id) from aut_inst_map m where m.source_id = b.source_id and m.source_inst = b.source_acq_inst), b.source_acq_inst) acq_inst_id
    , nvl((select min(m.network_id) from aut_network_map m where m.source_id = b.source_id and m.source_network = b.source_acq_network), b.source_acq_network) acq_network_id
    , b.terminal_type
    , b.cat_level
    , b.acq_inst_bin
    , b.forw_inst_bin
    , b.merchant_id
    , b.merchant_number
    , b.terminal_id
    , b.terminal_number
    , b.merchant_name
    , b.merchant_street
    , b.merchant_city
    , b.merchant_region
    , b.merchant_country
    , b.merchant_postcode
    , b.mcc
    , b.originator_refnum
    , b.network_refnum
    , b.card_data_input_cap
    , b.crdh_auth_cap
    , b.card_capture_cap
    , b.terminal_operating_env
    , b.crdh_presence
    , b.card_presence
    , b.card_data_input_mode
    , b.crdh_auth_method
    , b.crdh_auth_entity
    , b.card_data_output_cap
    , b.terminal_output_cap
    , b.pin_capture_cap
    , b.pin_presence
    , b.cvv2_presence
    , b.cvc_indicator
    , b.pos_entry_mode
    , b.pos_cond_code
    , b.payment_order_id
    , b.payment_host_id
    , b.emv_data
    , b.auth_code
    , b.oper_request_amount
    , b.oper_amount
    , b.oper_currency
    , b.oper_cashback_amount
    , b.oper_replacement_amount
    , b.oper_surcharge_amount
    , b.oper_date
    , b.source_host_date
    , b.source_iss_inst
    , b.source_iss_network
    , nvl((select min(m.inst_id) from aut_inst_map m where m.source_id = b.source_id and m.source_inst = b.source_iss_inst), b.source_acq_inst) iss_inst_id
    , nvl((select min(m.network_id) from aut_network_map m where m.source_id = b.source_id and m.source_network = b.source_iss_network), b.source_iss_network) iss_network_id
    , b.card_mask
    , b.card_hash
    , b.card_seq_number
    , b.card_expir_date
    , b.card_service_code
    , b.account_type
    , b.account_number
    , b.account_amount
    , b.account_currency
    , b.bin_amount
    , b.bin_currency
    , b.network_amount
    , b.network_currency
    , b.network_cnvt_date
    , c.rowid                       card_rowid
    , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
    , oc.inst_id                    card_inst_id
    , oc.id                         card_id
    , oc.split_hash                 split_hash_iss
    , oc.card_type_id               card_type_id
    , oc.country                    card_country
    , ct.network_id                 card_network
    , b.forced_posting
    , b.parent_id
from
    aut_auth b
    , aut_card c
    , aut_resp_code r
    , iss_card_vw oc
    , net_card_type ct
where
    decode(b.status, ''' || opr_api_const_pkg.OPERATION_STATUS_CORRECTED || ''', ''' || opr_api_const_pkg.OPERATION_STATUS_CORRECTED || ''', null) = :auth_status_corrected
    and b.id = c.auth_id
    and b.card_hash = oc.card_hash
    and c.card_number = oc.card_number(+)
    and oc.card_type_id = ct.id(+)
    ' || WHERE_PLACEHOLDER || '
order by
    c.card_number,
    b.host_date,
    b.source_id,
    b.id
for update of
    b.id,
    c.auth_id';

    if l_thread_number > 0 then
        l_auth_cur_stmt := replace(l_auth_cur_stmt, WHERE_PLACEHOLDER, ' and a.split_hash in (select m.split_hash from com_split_map m where m.thread_number = :tread_number)');
        open l_auth_cur for l_auth_cur_stmt using opr_api_const_pkg.OPERATION_STATUS_CORRECTED, l_thread_number;
    else
        l_auth_cur_stmt := replace(l_auth_cur_stmt, WHERE_PLACEHOLDER, '');
        open l_auth_cur for l_auth_cur_stmt using opr_api_const_pkg.OPERATION_STATUS_CORRECTED;
    end if;

    loop
        l_rejected_auth.delete;
        l_ignored_auth.delete;
        l_loaded_auth.delete;

        fetch l_auth_cur
        bulk collect into
            g_auth_rowid
            , g_id
            , g_split_hash
            , g_source_id
            , g_original_auth_id
            , g_is_reversal
            , g_msg_type
            , g_oper_type
            , g_resp_code
            , g_status
            , g_status_reason
            , g_proc_type
            , g_proc_mode
            , g_acq_inst_id
            , g_acq_network_id
            , g_terminal_type
            , g_cat_level
            , g_acq_inst_bin
            , g_forw_inst_bin
            , g_merchant_id
            , g_merchant_number
            , g_terminal_id
            , g_terminal_number
            , g_merchant_name
            , g_merchant_street
            , g_merchant_city
            , g_merchant_region
            , g_merchant_country
            , g_merchant_postcode
            , g_mcc
            , g_originator_refnum
            , g_network_refnum
            , g_card_data_input_cap
            , g_crdh_auth_cap
            , g_card_capture_cap
            , g_terminal_operating_env
            , g_crdh_presence
            , g_card_presence
            , g_card_data_input_mode
            , g_crdh_auth_method
            , g_crdh_auth_entity
            , g_card_data_output_cap
            , g_terminal_output_cap
            , g_pin_capture_cap
            , g_pin_presence
            , g_cvv2_presence
            , g_cvc_indicator
            , g_pos_entry_mode
            , g_pos_cond_code
            , g_payment_order_id
            , g_payment_host_id
            , g_emv_data
            , g_auth_code
            , g_oper_request_amount
            , g_oper_amount
            , g_oper_currency
            , g_oper_cashback_amount
            , g_oper_replacement_amount
            , g_oper_surcharge_amount
            , g_oper_date
            , g_host_date
            , g_iss_inst_id
            , g_iss_network_id
            , g_card_mask
            , g_card_hash
            , g_card_seq_number
            , g_card_expir_date
            , g_card_service_code
            , g_account_type
            , g_account_number
            , g_account_amount
            , g_account_currency
            , g_bin_amount
            , g_bin_currency
            , g_network_amount
            , g_network_currency
            , g_network_cnvt_date
            , g_card_rowid
            , g_card_number
            , g_card_inst_id
            , g_card_id
            , g_split_hash_iss
            , g_card_type_id
            , g_card_country
            , g_card_network_id
            , g_forced_posting
            , g_parent_id
        limit BULK_LIMIT;

        for i in 1 .. g_auth_rowid.count loop
            get_status_by_resp (
                i_resp_code             => g_resp_code(i)
                , i_oper_type           => g_oper_type(i)
                , i_msg_type            => g_msg_type(i)
                , i_is_reversal         => g_is_reversal(i)
                , i_is_completed        => null
                , i_sttl_type           => g_sttl_type(i)
                , i_oper_reason         => null
                , o_status              => g_status(i)
                , o_status_reason       => g_status_reason(i)
                , o_proc_mode           => g_proc_mode(i)
                , o_proc_type           => g_proc_type(i)
            );

            if g_proc_type(i) = aut_api_const_pkg.AUTH_PROC_TYPE_REJECT or (
                g_status(i) = opr_api_const_pkg.OPERATION_STATUS_MANUAL and
                g_forced_posting(i) = com_api_const_pkg.FALSE
            ) then
                l_rejected_auth(l_rejected_auth.count+1) := i;

            elsif g_proc_type(i) = aut_api_const_pkg.AUTH_PROC_TYPE_IGNORE then
                l_ignored_auth(l_ignored_auth.count+1) := i;

            else
                l_loaded_auth(l_loaded_auth.count+1) := i;

                g_status_reason(i) := nvl(g_status_reason(i), aut_api_const_pkg.AUTH_REASON_DUE_TO_RESP_CODE);

                if g_status(i) = opr_api_const_pkg.OPERATION_STATUS_MANUAL and g_forced_posting(i) = com_api_const_pkg.TRUE then
                    g_status(i) := opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY;
                    g_status_reason(i) := aut_api_const_pkg.AUTH_REASON_DUE_TO_FORCED_FLAG;
                end if;

                if g_status(i) = opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY then
                    l_wrong_data := false;
                    l_status_reason := null;

                    if not l_wrong_data and g_iss_inst_id(i) is null then -- issuer instititution wrong in auth or badly mapped
                        trc_log_pkg.error(
                            i_text          => 'WRONG_INSTITUTION_DEFINITION'
                          , i_env_param1    => 'ISS'
                          , i_env_param2    => g_source_id(i)
                          , i_env_param3    => g_iss_inst_id(i)
                          , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                          , i_object_id     => g_id(i)
                        );

                        l_wrong_data := true;
                        l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_ISS_INST;
                    end if;

                    if not l_wrong_data and g_iss_network_id(i) is null then -- issuer network wrong in auth or badly mapped
                        trc_log_pkg.error(
                            i_text          => 'WRONG_NETWORK_DEFINITION'
                          , i_env_param1    => 'ISS'
                          , i_env_param2    => g_source_id(i)
                          , i_env_param3    => g_iss_network_id(i)
                          , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                          , i_object_id     => g_id(i)
                        );

                        l_wrong_data := true;
                        l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_ISS_NETW;
                    end if;

                    if not l_wrong_data and g_acq_inst_id(i) is null then -- acquirer instititution wrong in auth or badly mapped
                        trc_log_pkg.error(
                            i_text          => 'WRONG_INSTITUTION_DEFINITION'
                          , i_env_param1    => 'ACQ'
                          , i_env_param2    => g_source_id(i)
                          , i_env_param3    => g_acq_inst_id(i)
                          , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                          , i_object_id     => g_id(i)
                        );

                        l_wrong_data := true;
                        l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_ACQ_INST;
                    end if;

                    if (not l_wrong_data) and (g_acq_network_id(i) is null) then -- acquirer network wrong in auth or badly mapped
                        trc_log_pkg.error(
                            i_text          => 'WRONG_NETWORK_DEFINITION'
                          , i_env_param1    => 'ACQ'
                          , i_env_param2    => g_source_id(i)
                          , i_env_param3    => g_acq_network_id(i)
                          , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                          , i_object_id     => g_id(i)
                        );

                        l_wrong_data := true;
                        l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_ACQ_NETW;
                    end if;

                    if (not l_wrong_data) and (g_card_inst_id(i) is null) then -- own card not found
                        if not /*get_network_checks (
                            i_iss_network_id      => g_iss_network_id(i)
                            , o_iss_check_own_card  => g_iss_check_own_card(i)
                            , o_iss_check_own_bin   => g_iss_check_own_bin(i)
                            , o_iss_check_netw_bin  => g_iss_check_netw_bin(i)
                            , o_iss_check_comm_bin  => g_iss_check_common_bin(i)
                        )*/ 1=1 then
                            trc_log_pkg.error(
                                i_text          => 'WRONG_NETWORK_DEFINITION'
                              , i_env_param1    => 'ISS'
                              , i_env_param2    => g_source_id(i)
                              , i_env_param3    => g_iss_network_id(i)
                              , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                              , i_object_id     => g_id(i)
                            );

                            l_wrong_data := true;
                            l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_ISS_NETW;
                        else
                            get_card_inst_netw (
                                i_card_number           => g_card_number(i)
                                , i_iss_network_id      => g_iss_network_id(i)
                                , i_iss_inst_id         => g_iss_inst_id(i)
                                , o_card_network_id     => g_card_network_id(i)
                                , o_card_inst_id        => g_card_inst_id(i)
                                , o_card_type           => g_card_type_id(i)
                                , o_card_country        => g_card_country(i)
                                , i_iss_check_own_card  => g_iss_check_own_card(i)
                                , i_iss_check_own_bin   => g_iss_check_own_bin(i)
                                , i_iss_check_netw_bin  => g_iss_check_netw_bin(i)
                                , i_iss_check_comm_bin  => g_iss_check_common_bin(i)
                            );
                        end if;
                    end if;

                    if not l_wrong_data and g_card_inst_id(i) is null then -- card owner not found accordingly to issuer network attributes
                        trc_log_pkg.error(
                            i_text          => 'CANNOT_FIND_CARD_OWNER_INST'
                          , i_env_param1    => g_iss_network_id(i)
                          , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                          , i_object_id     => g_id(i)
                        );

                        l_wrong_data := true;
                        l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_CARD_INST;
                    end if;

                    if not l_wrong_data and g_card_network_id(i) is null then -- card owner network not found accordingly to issuer network attributes
                        trc_log_pkg.error(
                            i_text          => 'CANNOT_FIND_CARD_OWNER_NETW'
                          , i_env_param1    => g_iss_network_id(i)
                          , i_env_param2    => g_iss_inst_id(i)
                          , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                          , i_object_id     => g_id(i)
                        );

                        l_wrong_data := true;
                        l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_CARD_NETW;
                    end if;

                    if not l_wrong_data then
                        if not 1=1 /*get_network_checks (
                            i_acq_network_id            => g_acq_network_id(i)
                            , o_acq_check_own_merchant  => g_acq_check_own_merchant(i)
                            , o_acq_check_own_terminal  => g_acq_check_own_terminal(i)
                        )*/ then
                            trc_log_pkg.error(
                                i_text          => 'WRONG_NETWORK_DEFINITION'
                              , i_env_param1    => 'ACQ'
                              , i_env_param2    => g_source_id(i)
                              , i_env_param3    => g_acq_network_id(i)
                              , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                              , i_object_id     => g_id(i)
                            );

                            l_wrong_data := true;
                            l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_ACQ_NETW;
                        end if;
                    end if;

                    if not l_wrong_data and (
                        g_acq_check_own_terminal(i) = com_api_type_pkg.TRUE
                        or g_acq_check_own_merchant(i) = com_api_type_pkg.TRUE
                    ) then -- try to find own merchant
                        acq_api_merchant_pkg.get_merchant (
                            i_inst_id               => g_acq_inst_id(i)
                            , i_merchant_number     => g_merchant_number(i)
                            , o_merchant_id         => g_own_merchant_id(i)
                            , o_split_hash          => g_split_hash_acq(i)
                        );

                        if g_own_merchant_id(i) is null then
                            trc_log_pkg.error(
                                i_text          => 'UNKNOWN_MERCHANT'
                              , i_env_param1    => g_merchant_number(i)
                              , i_env_param2    => g_acq_inst_id(i)
                              , i_env_param3    => g_acq_network_id(i)
                              , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                              , i_object_id     => g_id(i)
                            );

                            l_wrong_data := true;
                            l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_MERCHANT;

                        elsif g_own_merchant_id(i) != nvl(g_merchant_id(i), g_own_merchant_id(i)) then
                            trc_log_pkg.error(
                                i_text          => 'UNKNOWN_MERCHANT'
                              , i_env_param1    => g_merchant_number(i)
                              , i_env_param2    => g_acq_inst_id(i)
                              , i_env_param3    => g_acq_network_id(i)
                              , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                              , i_object_id     => g_id(i)
                            );

                            l_wrong_data := true;
                            l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_MERCHANT;
                        else
                            g_merchant_id(i) := g_own_merchant_id(i);
                        end if;
                    end if;

                    if not l_wrong_data and g_acq_check_own_terminal(i) = com_api_type_pkg.TRUE then
                        acq_api_terminal_pkg.get_terminal (
                            i_merchant_id           => g_merchant_id(i)
                            , i_terminal_number     => g_terminal_number(i)
                            , o_terminal_id         => g_terminal_id(i)
                        );

                        if g_terminal_id(i) is null then
                            trc_log_pkg.error(
                                i_text          => 'UNKNOWN_TERMINAL'
                              , i_env_param1    => g_acq_network_id(i)
                              , i_env_param2    => g_acq_inst_id(i)
                              , i_env_param3    => g_merchant_number(i)
                              , i_env_param4    => g_terminal_number(i)
                              , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                              , i_object_id     => g_id(i)
                            );

                            l_wrong_data := true;
                            l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_TERMINAL;
                        end if;
                    end if;

                    if not l_wrong_data then
                        net_api_sttl_pkg.get_sttl_type (
                            i_iss_inst_id           => g_iss_inst_id(i)
                            , i_acq_inst_id         => g_acq_inst_id(i)
                            , i_card_inst_id        => g_card_inst_id(i)
                            , i_iss_network_id      => g_iss_network_id(i)
                            , i_acq_network_id      => g_acq_network_id(i)
                            , i_card_network_id     => g_card_network_id(i)
                            , i_acq_inst_bin        => g_acq_inst_bin(i)
                            , o_sttl_type           => g_sttl_type(i)
                            , o_match_status        => g_match_status(i)
                            , i_oper_type           => g_oper_type(i)
                        );

                        if g_sttl_type(i) is null then
                            trc_log_pkg.error(
                                i_text          => 'UNKNOWN_SETTLEMENT_TYPE'
                              , i_env_param1    => g_iss_network_id(i)
                              , i_env_param2    => g_iss_inst_id(i)
                              , i_env_param3    => g_acq_network_id(i)
                              , i_env_param4    => g_acq_inst_id(i)
                              , i_env_param5    => g_card_network_id(i)
                              , i_env_param6    => g_card_inst_id(i)
                              , i_entity_type   => aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION
                              , i_object_id     => g_id(i)
                            );

                            l_wrong_data := true;
                            l_status_reason := aut_api_const_pkg.AUTH_REASON_WRONG_STTL_TYPE;
                        end if;
                    end if;

                    if l_wrong_data then
                        g_status(i) := opr_api_const_pkg.OPERATION_STATUS_WRONG_DATA;
                        g_status_reason(i) := l_status_reason;
                        l_excepted_count := l_excepted_count + 1;
                    end if;
                end if;
            end if;
        end loop;

--        if l_loaded_auth.count > 0 then
--            forall i in values of l_loaded_auth
--                update aut_auth
--                set
--                    status = g_status(i)
--                    , status_reason = g_status_reason(i)
--                    , proc_type = g_proc_type(i)
--                    , proc_mode = g_proc_mode(i)
--                    , acq_inst_id = g_acq_inst_id(i)
--                    , acq_network_id = g_acq_network_id(i)
--                    , split_hash_acq = g_split_hash_acq(i)
--                    , merchant_id = g_merchant_id(i)
--                    , terminal_id = g_terminal_id(i)
--                    , iss_inst_id = g_iss_inst_id(i)
--                    , iss_network_id = g_iss_network_id(i)
--                    , card_inst_id = g_card_inst_id(i)
--                    , card_network_id = g_card_network_id(i)
--                    , card_id = g_card_id(i)
--                    , split_hash_iss = g_split_hash_iss(i)
--                    , card_type_id = g_card_type_id(i)
--                    , card_country = g_card_country(i)
--                    , sttl_type = g_sttl_type(i)
--                    , match_status = g_match_status(i)
--                where
--                    rowid = g_auth_rowid(i);
--        end if;

        if l_rejected_auth.count > 0 then
            forall i in values of l_rejected_auth
                insert into aut_reject (
                    id
                    , split_hash
                    , session_id
                    , source_id
                    , original_auth_id
                    , is_reversal
                    , msg_type
                    , oper_type
                    , resp_code
                    , acq_inst_id
                    , acq_network_id
                    , terminal_type
                    , cat_level
                    , acq_inst_bin
                    , forw_inst_bin
                    , merchant_id
                    , merchant_number
                    , terminal_id
                    , terminal_number
                    , merchant_name
                    , merchant_street
                    , merchant_city
                    , merchant_region
                    , merchant_country
                    , merchant_postcode
                    , mcc
                    , originator_refnum
                    , network_refnum
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
                    , payment_order_id
                    , payment_host_id
                    , emv_data
                    , auth_code
                    , oper_request_amount
                    , oper_amount
                    , oper_currency
                    , oper_cashback_amount
                    , oper_replacement_amount
                    , oper_surcharge_amount
                    , oper_date
                    , host_date
                    , iss_inst_id
                    , iss_network_id
                    , card_mask
                    , card_hash
                    , card_seq_number
                    , card_expir_date
                    , card_service_code
                    , account_type
                    , account_number
                    , account_amount
                    , account_currency
                    , bin_amount
                    , bin_currency
                    , network_amount
                    , network_currency
                    , network_cnvt_date
                    , parent_id
                ) values (
                    g_id(i)
                    , g_split_hash(i)
                    , l_session_id
                    , g_source_id(i)
                    , g_original_auth_id(i)
                    , g_is_reversal(i)
                    , g_msg_type(i)
                    , g_oper_type(i)
                    , g_resp_code(i)
                    , g_acq_inst_id(i)
                    , g_acq_network_id(i)
                    , g_terminal_type(i)
                    , g_cat_level(i)
                    , g_acq_inst_bin(i)
                    , g_forw_inst_bin(i)
                    , g_merchant_id(i)
                    , g_merchant_number(i)
                    , g_terminal_id(i)
                    , g_terminal_number(i)
                    , g_merchant_name(i)
                    , g_merchant_street(i)
                    , g_merchant_city(i)
                    , g_merchant_region(i)
                    , g_merchant_country(i)
                    , g_merchant_postcode(i)
                    , g_mcc(i)
                    , g_originator_refnum(i)
                    , g_network_refnum(i)
                    , g_card_data_input_cap(i)
                    , g_crdh_auth_cap(i)
                    , g_card_capture_cap(i)
                    , g_terminal_operating_env(i)
                    , g_crdh_presence(i)
                    , g_card_presence(i)
                    , g_card_data_input_mode(i)
                    , g_crdh_auth_method(i)
                    , g_crdh_auth_entity(i)
                    , g_card_data_output_cap(i)
                    , g_terminal_output_cap(i)
                    , g_pin_capture_cap(i)
                    , g_pin_presence(i)
                    , g_cvv2_presence(i)
                    , g_cvc_indicator(i)
                    , g_pos_entry_mode(i)
                    , g_pos_cond_code(i)
                    , g_payment_order_id(i)
                    , g_payment_host_id(i)
                    , g_emv_data(i)
                    , g_auth_code(i)
                    , g_oper_request_amount(i)
                    , g_oper_amount(i)
                    , g_oper_currency(i)
                    , g_oper_cashback_amount(i)
                    , g_oper_replacement_amount(i)
                    , g_oper_surcharge_amount(i)
                    , g_oper_date(i)
                    , g_host_date(i)
                    , g_iss_inst_id(i)
                    , g_iss_network_id(i)
                    , g_card_mask(i)
                    , g_card_hash(i)
                    , g_card_seq_number(i)
                    , g_card_expir_date(i)
                    , g_card_service_code(i)
                    , g_account_type(i)
                    , g_account_number(i)
                    , g_account_amount(i)
                    , g_account_currency(i)
                    , g_bin_amount(i)
                    , g_bin_currency(i)
                    , g_network_amount(i)
                    , g_network_currency(i)
                    , g_network_cnvt_date(i)
                    , g_parent_id(i)
                );
        end if;

        if l_rejected_auth.count > 0 then
            forall i in values of l_rejected_auth
                delete from aut_auth
                where
                    rowid = g_auth_rowid(i);
        end if;

        if l_ignored_auth.count > 0 then
            forall i in values of l_ignored_auth
                delete from
                    aut_card
                where
                    rowid = g_card_rowid(i);
        end if;

        if l_ignored_auth.count > 0 then
            forall i in values of l_ignored_auth
                delete from
                    aut_auth
                where
                    rowid = g_auth_rowid(i);
        end if;

        prc_api_stat_pkg.increase_current (
            i_current_count       => g_auth_rowid.count
          , i_excepted_count      => l_excepted_count
        );

        exit when l_auth_cur%notfound;
    end loop;

    prc_api_stat_pkg.log_end (
        i_excepted_total    => l_excepted_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        if l_auth_cur%isopen then
            close l_auth_cur;
        end if;

        trc_log_pkg.debug (
            i_text          => 'Error revalidating auth: ' || sqlerrm
        );

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;
end;

end;
/
