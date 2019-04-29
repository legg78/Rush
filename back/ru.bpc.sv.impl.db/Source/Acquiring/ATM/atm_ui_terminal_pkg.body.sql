create or replace package body atm_ui_terminal_pkg as
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
  , i_powerup_service        in      com_api_type_pkg.t_dict_value
  , i_supervisor_service     in      com_api_type_pkg.t_dict_value
  , i_dispense_algo          in      com_api_type_pkg.t_dict_value default null
) is
begin
    atm_api_terminal_pkg.add_terminal(
        i_terminal_id            => i_terminal_id
      , i_atm_type               => i_atm_type
      , i_atm_model              => i_atm_model
      , i_serial_number          => i_serial_number
      , i_placement_type         => i_placement_type
      , i_availability_type      => i_availability_type
      , i_operating_hours        => i_operating_hours
      , i_local_date_gap         => i_local_date_gap
      , i_cassette_count         => i_cassette_count
      , i_key_change_algo        => i_key_change_algo
      , i_counter_sync_cond      => i_counter_sync_cond   
      , i_reject_disp_warn       => i_reject_disp_warn
      , i_disp_rest_warn         => i_disp_rest_warn
      , i_receipt_warn           => i_receipt_warn
      , i_card_capture_warn      => i_card_capture_warn
      , i_note_max_count         => i_note_max_count
      , i_scenario_id            => i_scenario_id
      , i_hopper_count           => i_hopper_count
      , i_manual_synch           => i_manual_synch
      , i_establ_conn_synch      => i_establ_conn_synch
      , i_counter_mismatch_synch => i_counter_mismatch_synch
      , i_online_in_synch        => i_online_in_synch
      , i_online_out_synch       => i_online_out_synch
      , i_safe_close_synch       => i_safe_close_synch
      , i_disp_error_synch       => i_disp_error_synch
      , i_periodic_synch         => i_periodic_synch
      , i_periodic_all_oper      => i_periodic_all_oper
      , i_periodic_oper_count    => i_periodic_oper_count
      , i_reject_disp_min_warn   => i_reject_disp_min_warn
      , i_cash_in_present        => i_cash_in_present
      , i_cash_in_min_warn       => i_cash_in_min_warn
      , i_cash_in_max_warn       => i_cash_in_max_warn
      , i_dispense_algo          => i_dispense_algo
    );
end;

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
  , i_powerup_service        in      com_api_type_pkg.t_dict_value
  , i_supervisor_service     in      com_api_type_pkg.t_dict_value
  , i_dispense_algo          in      com_api_type_pkg.t_dict_value default null
) is
begin
    atm_api_terminal_pkg.modify_terminal(
        i_terminal_id            => i_terminal_id
      , i_atm_model              => i_atm_model
      , i_serial_number          => i_serial_number
      , i_placement_type         => i_placement_type
      , i_availability_type      => i_availability_type
      , i_operating_hours        => i_operating_hours
      , i_cassette_count         => i_cassette_count
      , i_key_change_algo        => i_key_change_algo
      , i_counter_sync_cond      => i_counter_sync_cond
      , i_reject_disp_warn       => i_reject_disp_warn
      , i_disp_rest_warn         => i_disp_rest_warn
      , i_receipt_warn           => i_receipt_warn
      , i_card_capture_warn      => i_card_capture_warn
      , i_note_max_count         => i_note_max_count
      , i_scenario_id            => i_scenario_id
      , i_hopper_count           => i_hopper_count
      , i_manual_synch           => i_manual_synch
      , i_establ_conn_synch      => i_establ_conn_synch
      , i_counter_mismatch_synch => i_counter_mismatch_synch
      , i_online_in_synch        => i_online_in_synch
      , i_online_out_synch       => i_online_out_synch
      , i_safe_close_synch       => i_safe_close_synch
      , i_disp_error_synch       => i_disp_error_synch
      , i_periodic_synch         => i_periodic_synch
      , i_periodic_all_oper      => i_periodic_all_oper
      , i_periodic_oper_count    => i_periodic_oper_count
      , i_reject_disp_min_warn   => i_reject_disp_min_warn
      , i_cash_in_present        => i_cash_in_present
      , i_cash_in_min_warn       => i_cash_in_min_warn
      , i_cash_in_max_warn       => i_cash_in_max_warn
      , i_dispense_algo          => i_dispense_algo
    );
end;

procedure remove_atm_terminal(
    i_terminal_id       in      com_api_type_pkg.t_short_id
) is
begin
    atm_api_terminal_pkg.remove_terminal(
        i_terminal_id   => i_terminal_id
    );
end;
 
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
) is 
begin
    insert into atm_terminal_dynamic_vw(
        id
      , coll_id
      , coll_oper_count
      , last_oper_id
      , last_oper_date
      , receipt_loaded
      , receipt_printed
      , receipt_remained
      , card_captured
      , card_reader_status
      , rcpt_status
      , rcpt_paper_status
      , rcpt_ribbon_status
      , rcpt_head_status
      , rcpt_knife_status
      , jrnl_status
      , jrnl_paper_status
      , jrnl_ribbon_status
      , jrnl_head_status
      , ejrnl_status
      , ejrnl_space_status
      , stmt_status
      , stmt_paper_status
      , stmt_ribbon_stat
      , stmt_head_status
      , stmt_knife_status
      , stmt_capt_bin_status
      , tod_clock_status
      , depository_status
      , night_safe_status
      , encryptor_status
      , tscreen_keyb_status
      , voice_guidance_status
      , camera_status
      , bunch_acpt_status
      , envelope_disp_status
      , cheque_module_status
      , barcode_reader_status
      , coin_disp_status
      , dispenser_status
      , workflow_status
      , service_status
    ) values(
        i_id
      , i_coll_id
      , i_coll_oper_count
      , i_last_oper_id
      , i_last_oper_date
      , i_receipt_loaded
      , i_receipt_printed
      , i_receipt_remained
      , i_card_captured
      , i_card_reader_status
      , i_rcpt_status
      , i_rcpt_paper_status
      , i_rcpt_ribbon_status
      , i_rcpt_head_status
      , i_rcpt_knife_status
      , i_jrnl_status
      , i_jrnl_paper_status
      , i_jrnl_ribbon_status
      , i_jrnl_head_status
      , i_ejrnl_status
      , i_ejrnl_space_status
      , i_stmt_status
      , i_stmt_paper_status
      , i_stmt_ribbon_stat
      , i_stmt_head_status
      , i_stmt_knife_status
      , i_stmt_capt_bin_status
      , i_tod_clock_status
      , i_depository_status
      , i_night_safe_status
      , i_encryptor_status
      , i_tscreen_keyb_status
      , i_voice_guidance_status
      , i_camera_status
      , i_bunch_acpt_status
      , i_envelope_disp_status
      , i_cheque_module_status
      , i_barcode_reader_status
      , i_coin_disp_status 
      , i_dispenser_status
      , i_workflow_status
      , i_service_status
    );
end;

/*
 * Function returns TRUE if all terminal devices are in status Ok, otherwise FALSE is returned.
 */
function check_terminal_devices (
    i_terminal_id           in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean is
    l_result                       com_api_type_pkg.t_boolean;
begin
    select case count(1)
               when 0 then
                   com_api_type_pkg.TRUE
               else
                   com_api_type_pkg.FALSE
           end case
    into   l_result        
    from   atm_terminal_dynamic_vw
    where  id = i_terminal_id
       and (
            card_reader_status      != atm_api_const_pkg.CARD_READER_STATUS_OK
         or rcpt_status             != atm_api_const_pkg.PRINTER_STATUS_OK
         or jrnl_status             != atm_api_const_pkg.JRNL_STATUS_OK
         or ejrnl_status            != atm_api_const_pkg.EJRN_STATUS_OK
         or stmt_status             != atm_api_const_pkg.STPR_STATUS_OK
         or tod_clock_status        != atm_api_const_pkg.TOD_CLOCK_STATUS_OK
         or camera_status           != atm_api_const_pkg.CAMERA_STATUS_OK
         or encryptor_status        != atm_api_const_pkg.ENCRYPTOR_STATUS_OK
         or depository_status       not in (atm_api_const_pkg.DEPOSITORY_STATUS_OK, atm_api_const_pkg.DEPOSITORY_STATUS_NOT_PRESENT)
         or tscreen_keyb_status     not in (atm_api_const_pkg.TSCREEN_KEYB_STATUS_OK, atm_api_const_pkg.TSCREEN_KEYB_STATUS_NOT_PR)
         or voice_guidance_status   not in (atm_api_const_pkg.VOICE_GUIDANCE_STATUS_OK, atm_api_const_pkg.VOICE_GUIDANCE_STATUS_NOTPR)
         or bunch_acpt_status       not in (atm_api_const_pkg.BUNCH_ACPT_STATUS_OK, atm_api_const_pkg.BUNCH_ACPT_STATUS_NOPR)
         or envelope_disp_status    not in (atm_api_const_pkg.ENVELOPE_DISP_STATUS_OK, atm_api_const_pkg.ENVELOPE_DISP_STATUS_NOPR)
         or cheque_module_status    not in (atm_api_const_pkg.CHEQUE_MODULE_STATUS_OK, atm_api_const_pkg.CHEQUE_MODULE_STATUS_NOPR)
         or barcode_reader_status   not in (atm_api_const_pkg.BARCODE_READER_STATUS_OK, atm_api_const_pkg.BARCODE_READER_STATUS_NOPR)
         or coin_disp_status        not in (atm_api_const_pkg.COIN_DISP_STATUS_OK, atm_api_const_pkg.COIN_DISP_STATUS_NOPR)
         or dispenser_status        not in (atm_api_const_pkg.DISPENSER_STATUS_OK, atm_api_const_pkg.DISPENSER_STATUS_NOPR) 
       );
    return l_result;
end;  

function check_terminal_device_statuses(
    i_terminal_id           in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_dict_value is
    l_result com_api_type_pkg.t_dict_value;
begin
    select case count(1)
               when 0 then
                   atm_api_const_pkg.COMMON_TECH_STATUS_OK
               else
                   atm_api_const_pkg.COMMON_TECH_STATUS_PROBLEM
           end case
      into l_result
      from atm_terminal_dynamic_vw
     where id = i_terminal_id
       and (   card_reader_status          !=  atm_api_const_pkg.CARD_READER_STATUS_OK
            or rcpt_status                 !=  atm_api_const_pkg.PRINTER_STATUS_OK
            or jrnl_status                 !=  atm_api_const_pkg.JRNL_STATUS_OK
            or ejrnl_status                !=  atm_api_const_pkg.EJRN_STATUS_OK
            or stmt_status                 !=  atm_api_const_pkg.STPR_STATUS_OK
            or camera_status               !=  atm_api_const_pkg.CAMERA_STATUS_OK
            or encryptor_status        not in (atm_api_const_pkg.ENCRYPTOR_STATUS_OK,      atm_api_const_pkg.ENCRYPTOR_STATUS_NOT_CONF)
            or depository_status       not in (atm_api_const_pkg.DEPOSITORY_STATUS_OK,     atm_api_const_pkg.DEPOSITORY_STATUS_NOT_PRESENT)
            or tscreen_keyb_status     not in (atm_api_const_pkg.TSCREEN_KEYB_STATUS_OK,   atm_api_const_pkg.TSCREEN_KEYB_STATUS_NOT_PR)
            or voice_guidance_status   not in (atm_api_const_pkg.VOICE_GUIDANCE_STATUS_OK, atm_api_const_pkg.VOICE_GUIDANCE_STATUS_NOTPR)
            or bunch_acpt_status       not in (atm_api_const_pkg.BUNCH_ACPT_STATUS_OK,     atm_api_const_pkg.BUNCH_ACPT_STATUS_NOPR)
            or cheque_module_status    not in (atm_api_const_pkg.CHEQUE_MODULE_STATUS_OK,  atm_api_const_pkg.CHEQUE_MODULE_STATUS_NOPR)
            or barcode_reader_status   not in (atm_api_const_pkg.BARCODE_READER_STATUS_OK, atm_api_const_pkg.BARCODE_READER_STATUS_NOPR)
            or coin_disp_status        not in (atm_api_const_pkg.COIN_DISP_STATUS_OK,      atm_api_const_pkg.COIN_DISP_STATUS_NOPR)
            or dispenser_status        not in (atm_api_const_pkg.DISPENSER_STATUS_OK,      atm_api_const_pkg.DISPENSER_STATUS_NOPR)
            or tod_clock_status        not in (atm_api_const_pkg.TOD_CLOCK_STATUS_OK,      atm_api_const_pkg.TOD_CLOCK_STATUS_STOP,         atm_api_const_pkg.TOD_CLOCK_STATUS_RESET)
            or envelope_disp_status    not in (atm_api_const_pkg.ENVELOPE_DISP_STATUS_OK,  atm_api_const_pkg.ENVELOPE_DISP_STATUS_NOPR,     atm_api_const_pkg.ENVELOPE_DISP_STATUS_LOW)
           );

    if l_result = atm_api_const_pkg.COMMON_TECH_STATUS_PROBLEM then
        select case count(1)
                   when 0 then
                       atm_api_const_pkg.COMMON_TECH_STATUS_WARNING
                   else
                       atm_api_const_pkg.COMMON_TECH_STATUS_PROBLEM
               end case
          into l_result
          from atm_terminal_dynamic_vw
         where id = i_terminal_id
           and (   encryptor_status             =  atm_api_const_pkg.ENCRYPTOR_STATUS_ERROR
                or tscreen_keyb_status          =  atm_api_const_pkg.TSCREEN_KEYB_STATUS_ERROR
                or voice_guidance_status        =  atm_api_const_pkg.VOICE_GUIDANCE_STATUS_ERROR
                or barcode_reader_status        =  atm_api_const_pkg.BARCODE_READER_STATUS_ERROR
                or coin_disp_status             =  atm_api_const_pkg.COIN_DISP_STATUS_ERROR
                or envelope_disp_status         =  atm_api_const_pkg.ENVELOPE_DISP_STATUS_ERROR           
                or card_reader_status          in (atm_api_const_pkg.CARD_READER_STATUS_ERROR,  atm_api_const_pkg.CARD_READER_STATUS_OVERFILL)
                or depository_status           in (atm_api_const_pkg.DEPOSITORY_STATUS_ERROR,   atm_api_const_pkg.DEPOSITORY_STATUS_OVERFILL)
                or dispenser_status            in (atm_api_const_pkg.DISPENSER_STATUS_ERROR,    atm_api_const_pkg.DISPENSER_STATUS_RBOF)
                or camera_status               in (atm_api_const_pkg.CAMERA_STATUS_ERROR,       atm_api_const_pkg.CAMERA_STATUS_SUPPLY_ERROR)
                or rcpt_status                 in (atm_api_const_pkg.PRINTER_STATUS_ERROR,      atm_api_const_pkg.PRINTER_STATUS_SUPPLY_ERROR,  atm_api_const_pkg.PRINTER_STATUS_NOT_CONFIGURED)
                or jrnl_status                 in (atm_api_const_pkg.JRNL_STATUS_ERROR,         atm_api_const_pkg.JRNL_STATUS_SUPPLY_ERROR,     atm_api_const_pkg.JRNL_STATUS_NOT_CONFIGURED)
                or ejrnl_status                in (atm_api_const_pkg.EJRN_STATUS_ERROR,         atm_api_const_pkg.EJRN_STATUS_SUPPLY_ERROR,     atm_api_const_pkg.EJRN_STATUS_NOT_CONFIGURED)
                or stmt_status                 in (atm_api_const_pkg.STPR_STATUS_ERROR,         atm_api_const_pkg.STPR_STATUS_SUPPLY_ERROR,     atm_api_const_pkg.STPR_STATUS_NOT_CONFIGURED)
               );
    end if;

    return l_result;
end;

function get_technical_status (
    i_terminal_id           in com_api_type_pkg.t_short_id
    , i_lang                in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_text is
    l_result                com_api_type_pkg.t_text;
begin
    l_result := cst_api_terminal_pkg.get_technical_status (
        i_terminal_id  => i_terminal_id
        , i_lang       => i_lang
    );
    if l_result is null then
        select
               case
                   when dy.service_status  = atm_api_const_pkg.SERVICE_STATUS_UNDEFINED then
                       atm_api_const_pkg.COMMON_TECH_STATUS_NA
                   when dy.service_status != atm_api_const_pkg.SERVICE_STATUS_UNDEFINED
                    and ds.dev_status = atm_api_const_pkg.COMMON_TECH_STATUS_PROBLEM then
                       atm_api_const_pkg.COMMON_TECH_STATUS_PROBLEM
                   when dy.service_status != atm_api_const_pkg.SERVICE_STATUS_UNDEFINED
                    and ds.dev_status = atm_api_const_pkg.COMMON_TECH_STATUS_WARNING then
                       atm_api_const_pkg.COMMON_TECH_STATUS_WARNING
                   when dy.service_status != atm_api_const_pkg.SERVICE_STATUS_UNDEFINED
                    and ds.dev_status = atm_api_const_pkg.COMMON_TECH_STATUS_OK then
                       atm_api_const_pkg.COMMON_TECH_STATUS_OK
                   else atm_api_const_pkg.COMMON_TECH_STATUS_NA
               end
          into l_result
          from atm_terminal_dynamic dy
             , (select check_terminal_device_statuses(i_terminal_id) dev_status
                  from dual
               ) ds
         where dy.id = i_terminal_id;
    end if;
        
    return l_result;
exception
    when no_data_found then
        return atm_api_const_pkg.COMMON_TECH_STATUS_NA;
end;

function get_financial_status (
    i_terminal_id           in com_api_type_pkg.t_short_id
    , i_lang                in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_text is
    l_result                com_api_type_pkg.t_text;
begin
    l_result := cst_api_terminal_pkg.get_financial_status (
        i_terminal_id  => i_terminal_id
        , i_lang       => i_lang
    );
    if l_result is not null then
        return l_result;
    end if;
    
    select
        case
        when ts.tech_status in ('ATCS0001', 'ATCS0002')
          -- Minimum count of remained notes less dispenser rest warnings limit
            and (dnote.min_note_remained <= at.disp_rest_warn and dnote.min_note_remained > 0)
        then
            'AFCS0002'
        when ts.tech_status in ('ATCS0001', 'ATCS0002')
          -- Count of rejected notes into reject dispenser is less than 
          -- its OVERFLOW limit and greater than its WARNING limit
            and (dnote.sum_note_rejected < at.reject_disp_warn and dnote.sum_note_rejected > at.reject_disp_min_warn)
        then
            'AFCS0002'
        when ts.tech_status in ('ATCS0001', 'ATCS0002')
          -- Cash in note count greater cash in minimum limit for warnings and less cash in maximum limit for warning
            and (cashin.note_count >= at.cash_in_min_warn and cashin.note_count < at.cash_in_max_warn)
        then
            'AFCS0002'
        when ts.tech_status in ('ATCS0001', 'ATCS0002')
          -- Minimum count of remained notes eq zero
            and (dnote.min_note_remained = 0)
        then
            'AFCS0003'
        when ts.tech_status in ('ATCS0001', 'ATCS0002')
          -- Count of rejected notes into reject dispenser is greater than its OVERFLOW limit
            and dnote.sum_note_rejected >= at.reject_disp_warn
        then
            'AFCS0003'
        when ts.tech_status in ('ATCS0001', 'ATCS0002')
          -- Cash in note count greater cash in maximum limit for warnings
            and cashin.note_count > at.cash_in_max_warn
        then
            'AFCS0003'
        when ts.tech_status in ('ATCS0001', 'ATCS0002')
          -- (1) minimum count of remained notes is greater than dispenser rest warnings limit,
          -- (2) and count of rejected notes into reject dispenser is less than its WARNING limit,
          -- (3) and cash in note count is greater than cash in minimum limit for warnings
          -- and less cash in minimum limit for warnings or cash in not present
            and dnote.min_note_remained > at.disp_rest_warn
            and dnote.sum_note_rejected < at.reject_disp_min_warn
            and (cashin.note_count < at.cash_in_min_warn or com_api_type_pkg.FALSE = nvl(at.cash_in_present, 0))
        then
            'AFCS0001'
        else
            'AFCS0000'
        end
    into
        l_result
    from
        atm_terminal at
        , ( select
                dy.id terminal_id
                , case when dy.service_status = 'ASSTUNDF' then 'ATCS0000'
                       when dy.service_status = 'ASSTOSRV' and ds.dev_status = com_api_type_pkg.FALSE then 'ATCS0003'
                       when dy.service_status not in ('ASSTUNDF', 'ASSTOSRV') and ds.dev_status = com_api_type_pkg.FALSE then 'ATCS0002'
                       when dy.service_status = 'ASSTISRV' and ds.dev_status = com_api_type_pkg.TRUE then 'ATCS0001'
                       else 'ATCS0000'
                  end tech_status
            from
                atm_terminal_dynamic dy
                , ( select
                        atm_ui_terminal_pkg.check_terminal_devices(i_terminal_id) dev_status
                    from
                        dual
                ) ds
            where
                dy.id = i_terminal_id
        ) ts
        , ( select
                ad.terminal_id terminal_id
                , min(dd.note_remained) min_note_remained
                , sum(dd.note_rejected) sum_note_rejected
            from
                atm_dispenser_dynamic dd
            join 
                atm_dispenser ad
            on
                dd.id = ad.id
                and ad.terminal_id = i_terminal_id
            group by
                ad.terminal_id
        ) dnote
        , ( select
                terminal_id
                , count(1) note_count
            from
                atm_cash_in t
            where
                terminal_id = i_terminal_id
            group by
                terminal_id
        ) cashin
    where
        at.id = i_terminal_id
        and at.id = ts.terminal_id
        and at.id = dnote.terminal_id(+)
        and at.id = cashin.terminal_id(+);
    
    return l_result;
exception
    when no_data_found then
        return atm_api_const_pkg.COMMON_FIN_STATUS_NA;
end;

function get_expendable_status (
    i_terminal_id           in com_api_type_pkg.t_short_id
    , i_lang                in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_text is
    l_result                com_api_type_pkg.t_text;
begin
    l_result := cst_api_terminal_pkg.get_expendable_status (
        i_terminal_id  => i_terminal_id
        , i_lang       => i_lang
    );
    if l_result is not null then
        return l_result;
    end if;
    
    select
        case
        -- Receipts not setup
        when td.receipt_loaded<=0 then
            'AECS'||substr(ts.tech_status,5)   
        -- Technical status is ok or warning and count of remained receipts after last load less reciept rest warnings limit
        when ts.tech_status in ('ATCS0001', 'ATCS0002') and td.receipt_remained > 0 and td.receipt_remained <= at.receipt_warn then
            'AECS0002'
        -- Technical status is ok or warning and count of remained receipts after last load eq zero
        when ts.tech_status in ('ATCS0001', 'ATCS0002') and td.receipt_remained = 0 then
            'AECS0003'
        -- Technical status is ok or warning and count of remained receipts after last load greater reciept rest warnings limit
        when ts.tech_status in ('ATCS0001', 'ATCS0002') and td.receipt_remained > at.receipt_warn then
            'AECS0001'
        else
            'AECS0000'
        end
    into
        l_result
    from
        atm_terminal at
        , atm_terminal_dynamic td
        , ( select
                dy.id terminal_id
                , case when dy.service_status = 'ASSTUNDF' then 'ATCS0000'
                       when dy.service_status = 'ASSTOSRV' and ds.dev_status = com_api_type_pkg.FALSE then 'ATCS0003'
                       when dy.service_status not in ('ASSTUNDF', 'ASSTOSRV') and ds.dev_status = com_api_type_pkg.FALSE then 'ATCS0002'
                       when dy.service_status = 'ASSTISRV' and ds.dev_status = com_api_type_pkg.TRUE then 'ATCS0001'
                       else 'ATCS0000'
                  end tech_status
            from
                atm_terminal_dynamic dy
                , ( select
                        atm_ui_terminal_pkg.check_terminal_devices(i_terminal_id) dev_status
                    from
                        dual
                ) ds
            where
                dy.id = i_terminal_id
        ) ts
    where
        at.id = i_terminal_id
        and td.id = at.id;
    
    return l_result;
exception
    when no_data_found then
        return atm_api_const_pkg.COMMON_EXPEND_STATUS_NA;
end;

end;
/
