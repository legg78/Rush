create or replace package aut_api_load_pkg is
/************************************************************
 * Authorizations loads<br />
 * Created by Khougaev A.(khougaev@bpc.ru)  at 19.03.2010  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: AUT_API_LOAD_PKG <br />
 * @headcom
 ************************************************************/

function neg_active_buffer_num (
    i_active_num            in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_tiny_id; 

function get_active_buffer_num return com_api_type_pkg.t_tiny_id; 

procedure switch_active_buffer;
    
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
    );
*/
procedure flush_auth;

procedure clear_global_data;

procedure load_auth;

procedure revalidate_auth;

function get_status_by_resp (
    i_resp_code               in com_api_type_pkg.t_dict_value
  , i_oper_type               in com_api_type_pkg.t_dict_value
  , i_msg_type                in com_api_type_pkg.t_dict_value
  , i_is_reversal             in com_api_type_pkg.t_boolean
  , i_is_completed            in com_api_type_pkg.t_dict_value
  , i_sttl_type               in com_api_type_pkg.t_dict_value
  , i_oper_reason             in com_api_type_pkg.t_dict_value
) return aut_api_type_pkg.aut_resp_code;

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
);

end;
/
