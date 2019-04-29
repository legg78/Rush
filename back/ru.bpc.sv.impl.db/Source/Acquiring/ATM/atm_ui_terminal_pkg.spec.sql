create or replace package atm_ui_terminal_pkg as
/********************************************************* 
 * User Interface for ATM terminals <br>
 * Created by Fomichev A.(fomichev@bpc.ru)  at 01.12.2010  <br>
 * Last changed by $Author: fomichev $ <br>
 * $LastChangedDate:: 2010-12-01 15:35:03 +0400#$  <br>
 * Revision: $LastChangedRevision: 6830 $ <br>
 * Module: atm_ui_terminal_pkg <br>
 * @headcom
 **********************************************************/

procedure add_atm_terminal(
    i_terminal_id            in      com_api_type_pkg.t_short_id
  , i_atm_type               in      com_api_type_pkg.t_dict_value
  , i_atm_model              in      com_api_type_pkg.t_name
  , i_serial_number          in      com_api_type_pkg.t_name
  , i_placement_type         in      com_api_type_pkg.t_dict_value
  , i_availability_type      in      com_api_type_pkg.t_dict_value
  , i_operating_hours        in      com_api_type_pkg.t_name
  , i_local_date_gap         in      com_api_type_pkg.t_short_id
  , i_cassette_count         in      com_api_type_pkg.t_tiny_id
  , i_key_change_algo        in      com_api_type_pkg.t_dict_value
  , i_counter_sync_cond      in      com_api_type_pkg.t_dict_value
  , i_reject_disp_warn       in      com_api_type_pkg.t_tiny_id
  , i_disp_rest_warn         in      com_api_type_pkg.t_tiny_id
  , i_receipt_warn           in      com_api_type_pkg.t_tiny_id
  , i_card_capture_warn      in      com_api_type_pkg.t_tiny_id
  , i_note_max_count         in      com_api_type_pkg.t_tiny_id
  , i_scenario_id            in      com_api_type_pkg.t_tiny_id
  , i_hopper_count           in      com_api_type_pkg.t_tiny_id
  , i_manual_synch           in      com_api_type_pkg.t_dict_value
  , i_establ_conn_synch      in      com_api_type_pkg.t_dict_value
  , i_counter_mismatch_synch in      com_api_type_pkg.t_dict_value
  , i_online_in_synch        in      com_api_type_pkg.t_dict_value
  , i_online_out_synch       in      com_api_type_pkg.t_dict_value
  , i_safe_close_synch       in      com_api_type_pkg.t_dict_value
  , i_disp_error_synch       in      com_api_type_pkg.t_dict_value
  , i_periodic_synch         in      com_api_type_pkg.t_dict_value
  , i_periodic_all_oper      in      com_api_type_pkg.t_boolean
  , i_periodic_oper_count    in      com_api_type_pkg.t_tiny_id
  , i_reject_disp_min_warn   in      com_api_type_pkg.t_tiny_id
  , i_cash_in_present        in      com_api_type_pkg.t_boolean
  , i_cash_in_min_warn       in      com_api_type_pkg.t_tiny_id
  , i_cash_in_max_warn       in      com_api_type_pkg.t_tiny_id
  , i_powerup_service        in      com_api_type_pkg.t_dict_value := null
  , i_supervisor_service     in      com_api_type_pkg.t_dict_value := null
  , i_dispense_algo          in      com_api_type_pkg.t_dict_value default null
);

procedure modify_atm_terminal(
    i_terminal_id            in      com_api_type_pkg.t_short_id
  , i_atm_model              in      com_api_type_pkg.t_name
  , i_serial_number          in      com_api_type_pkg.t_name
  , i_placement_type         in      com_api_type_pkg.t_dict_value
  , i_availability_type      in      com_api_type_pkg.t_dict_value
  , i_operating_hours        in      com_api_type_pkg.t_name
  , i_cassette_count         in      com_api_type_pkg.t_tiny_id
  , i_key_change_algo        in      com_api_type_pkg.t_dict_value
  , i_counter_sync_cond      in      com_api_type_pkg.t_dict_value
  , i_reject_disp_warn       in      com_api_type_pkg.t_tiny_id
  , i_disp_rest_warn         in      com_api_type_pkg.t_tiny_id
  , i_receipt_warn           in      com_api_type_pkg.t_tiny_id
  , i_card_capture_warn      in      com_api_type_pkg.t_tiny_id
  , i_note_max_count         in      com_api_type_pkg.t_tiny_id
  , i_scenario_id            in      com_api_type_pkg.t_tiny_id
  , i_hopper_count           in      com_api_type_pkg.t_tiny_id
  , i_manual_synch           in      com_api_type_pkg.t_dict_value
  , i_establ_conn_synch      in      com_api_type_pkg.t_dict_value
  , i_counter_mismatch_synch in      com_api_type_pkg.t_dict_value
  , i_online_in_synch        in      com_api_type_pkg.t_dict_value
  , i_online_out_synch       in      com_api_type_pkg.t_dict_value
  , i_safe_close_synch       in      com_api_type_pkg.t_dict_value
  , i_disp_error_synch       in      com_api_type_pkg.t_dict_value
  , i_periodic_synch         in      com_api_type_pkg.t_dict_value
  , i_periodic_all_oper      in      com_api_type_pkg.t_boolean
  , i_periodic_oper_count    in      com_api_type_pkg.t_tiny_id
  , i_reject_disp_min_warn   in      com_api_type_pkg.t_tiny_id
  , i_cash_in_present        in      com_api_type_pkg.t_boolean
  , i_cash_in_min_warn       in      com_api_type_pkg.t_tiny_id
  , i_cash_in_max_warn       in      com_api_type_pkg.t_tiny_id
  , i_powerup_service        in      com_api_type_pkg.t_dict_value := null
  , i_supervisor_service     in      com_api_type_pkg.t_dict_value := null
  , i_dispense_algo          in      com_api_type_pkg.t_dict_value default null
);

procedure remove_atm_terminal(
    i_terminal_id       in      com_api_type_pkg.t_short_id
);
procedure add_terminal_dynamic(
    i_id                    in    com_api_type_pkg.t_short_id
  , i_coll_id               in     com_api_type_pkg.t_medium_id
  , i_coll_oper_count       in     com_api_type_pkg.t_tiny_id
  , i_last_oper_id          in     com_api_type_pkg.t_long_id
  , i_last_oper_date        in     date
  , i_receipt_loaded        in     com_api_type_pkg.t_tiny_id
  , i_receipt_printed       in     com_api_type_pkg.t_tiny_id
  , i_receipt_remained      in     com_api_type_pkg.t_tiny_id
  , i_card_captured         in     com_api_type_pkg.t_tiny_id
  , i_card_reader_status    in     com_api_type_pkg.t_dict_value
  , i_rcpt_status           in     com_api_type_pkg.t_dict_value
  , i_rcpt_paper_status     in     com_api_type_pkg.t_dict_value
  , i_rcpt_ribbon_status    in     com_api_type_pkg.t_dict_value
  , i_rcpt_head_status      in     com_api_type_pkg.t_dict_value
  , i_rcpt_knife_status     in     com_api_type_pkg.t_dict_value
  , i_jrnl_status           in     com_api_type_pkg.t_dict_value
  , i_jrnl_paper_status     in     com_api_type_pkg.t_dict_value
  , i_jrnl_ribbon_status    in     com_api_type_pkg.t_dict_value
  , i_jrnl_head_status      in     com_api_type_pkg.t_dict_value
  , i_ejrnl_status          in     com_api_type_pkg.t_dict_value
  , i_ejrnl_space_status    in     com_api_type_pkg.t_dict_value
  , i_stmt_status           in     com_api_type_pkg.t_dict_value
  , i_stmt_paper_status     in     com_api_type_pkg.t_dict_value
  , i_stmt_ribbon_stat      in     com_api_type_pkg.t_dict_value
  , i_stmt_head_status      in     com_api_type_pkg.t_dict_value
  , i_stmt_knife_status     in     com_api_type_pkg.t_dict_value
  , i_stmt_capt_bin_status  in     com_api_type_pkg.t_dict_value
  , i_tod_clock_status      in     com_api_type_pkg.t_dict_value
  , i_depository_status     in     com_api_type_pkg.t_dict_value
  , i_night_safe_status     in     com_api_type_pkg.t_dict_value
  , i_encryptor_status      in     com_api_type_pkg.t_dict_value
  , i_tscreen_keyb_status   in     com_api_type_pkg.t_dict_value
  , i_voice_guidance_status in     com_api_type_pkg.t_dict_value
  , i_camera_status         in     com_api_type_pkg.t_dict_value
  , i_bunch_acpt_status     in     com_api_type_pkg.t_dict_value
  , i_envelope_disp_status  in     com_api_type_pkg.t_dict_value
  , i_cheque_module_status  in     com_api_type_pkg.t_dict_value
  , i_barcode_reader_status in     com_api_type_pkg.t_dict_value
  , i_coin_disp_status      in     com_api_type_pkg.t_dict_value 
  , i_dispenser_status      in     com_api_type_pkg.t_dict_value
  , i_workflow_status       in     com_api_type_pkg.t_dict_value
  , i_service_status        in     com_api_type_pkg.t_dict_value
);

/*
 * Function returns TRUE if all terminal devices are in status Ok, otherwise FALSE is returned.
 */
function check_terminal_devices (
    i_terminal_id           in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

function check_terminal_device_statuses(
    i_terminal_id           in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_dict_value;

function get_technical_status (
    i_terminal_id           in com_api_type_pkg.t_short_id
    , i_lang                in com_api_type_pkg.t_dict_value := null
) return com_api_type_pkg.t_text;

function get_financial_status (
    i_terminal_id           in com_api_type_pkg.t_short_id
    , i_lang                in com_api_type_pkg.t_dict_value := null
) return com_api_type_pkg.t_text;

function get_expendable_status (
    i_terminal_id           in com_api_type_pkg.t_short_id
    , i_lang                in com_api_type_pkg.t_dict_value := null
) return com_api_type_pkg.t_text;

end;
/
