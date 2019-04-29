create or replace package body atm_api_terminal_pkg as
/*********************************************************
 *  Api for terminals <br>
 *  Created by Filimonov A.(filimonov@bpc.ru)  at 13.04.2010  <br>
 *  Last changed by $Author$ <br>
 *  $LastChangedDate::                           $  <br>
 *  Revision: $LastChangedRevision$ <br>
 *  Module: atm_api_terminal_pkg <br>
 *  @headcom
 **********************************************************/

procedure add_terminal(
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
  , i_dispense_algo          in      com_api_type_pkg.t_dict_value  default null
) is
begin
    if i_scenario_id is null then
        trc_log_pkg.warn(
            i_text       => 'ATM_SCENARIO_NOT_DEFINED'
          , i_env_param1 => i_terminal_id
        );
    end if;

    insert into atm_terminal(
        id
      , atm_type
      , atm_model
      , serial_number
      , placement_type
      , availability_type
      , operating_hours
      , local_date_gap
      , cassette_count
      , key_change_algo
      , counter_sync_cond
      , reject_disp_warn
      , disp_rest_warn
      , receipt_warn
      , card_capture_warn
      , note_max_count
      , scenario_id
      , hopper_count
      , manual_synch
      , establ_conn_synch
      , counter_mismatch_synch
      , online_in_synch
      , online_out_synch
      , safe_close_synch
      , disp_error_synch
      , periodic_synch
      , periodic_all_oper
      , periodic_oper_count
      , reject_disp_min_warn
      , cash_in_present
      , cash_in_min_warn
      , cash_in_max_warn
      , powerup_service
      , supervisor_service
      , dispense_algo
    ) values (
        i_terminal_id
      , i_atm_type
      , i_atm_model
      , i_serial_number
      , i_placement_type
      , i_availability_type
      , i_operating_hours
      , i_local_date_gap
      , i_cassette_count
      , i_key_change_algo
      , i_counter_sync_cond
      , i_reject_disp_warn
      , i_disp_rest_warn
      , i_receipt_warn
      , i_card_capture_warn
      , i_note_max_count
      , i_scenario_id
      , i_hopper_count
      , i_manual_synch
      , i_establ_conn_synch
      , i_counter_mismatch_synch
      , i_online_in_synch
      , i_online_out_synch
      , i_safe_close_synch
      , i_disp_error_synch
      , i_periodic_synch
      , i_periodic_all_oper
      , i_periodic_oper_count
      , i_reject_disp_min_warn
      , i_cash_in_present
      , i_cash_in_min_warn
      , i_cash_in_max_warn
      , nvl(i_powerup_service, atm_api_const_pkg.ATM_SERVICE_STATUS_CHANGE)
      , nvl(i_supervisor_service, atm_api_const_pkg.ATM_SERVICE_STATUS_CHANGE)
      , i_dispense_algo
    );
end;

procedure modify_terminal(
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
  , i_appl_flag              in      com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
  , i_powerup_service        in      com_api_type_pkg.t_dict_value
  , i_supervisor_service     in      com_api_type_pkg.t_dict_value
  , i_dispense_algo          in      com_api_type_pkg.t_dict_value  default null
) is
begin
    if i_scenario_id is null then
        trc_log_pkg.warn(
            i_text       => 'ATM_SCENARIO_NOT_DEFINED'
          , i_env_param1 => i_terminal_id
        );
    end if;

    trc_log_pkg.debug (
            i_text => 'i_appl_flag=' || to_char(i_appl_flag)
        );

    if i_appl_flag = com_api_type_pkg.TRUE then
        update atm_terminal
           set atm_model              = nvl(i_atm_model,              atm_model)
             , placement_type         = nvl(i_placement_type,         placement_type)
             , availability_type      = nvl(i_availability_type,      availability_type)
             , operating_hours        = nvl(i_operating_hours,        operating_hours)
             , cassette_count         = nvl(i_cassette_count,         cassette_count)
             , key_change_algo        = nvl(i_key_change_algo,        key_change_algo)
             , counter_sync_cond      = nvl(i_counter_sync_cond,      counter_sync_cond)
             , reject_disp_warn       = nvl(i_reject_disp_warn,       reject_disp_warn)
             , disp_rest_warn         = nvl(i_disp_rest_warn,         disp_rest_warn)
             , receipt_warn           = nvl(i_receipt_warn,           receipt_warn)
             , card_capture_warn      = nvl(i_card_capture_warn,      card_capture_warn)
             , note_max_count         = nvl(i_note_max_count,         note_max_count)
             , scenario_id            = nvl(i_scenario_id,            scenario_id)
             , hopper_count           = nvl(i_hopper_count,           hopper_count)
             , manual_synch           = nvl(i_manual_synch,           manual_synch)
             , establ_conn_synch      = nvl(i_establ_conn_synch,      establ_conn_synch)
             , counter_mismatch_synch = nvl(i_counter_mismatch_synch, counter_mismatch_synch)
             , online_in_synch        = nvl(i_online_in_synch,        online_in_synch)
             , online_out_synch       = nvl(i_online_out_synch,       online_out_synch)
             , safe_close_synch       = nvl(i_safe_close_synch,       safe_close_synch)
             , disp_error_synch       = nvl(i_disp_error_synch,       disp_error_synch)
             , periodic_synch         = nvl(i_periodic_synch,         periodic_synch)
             , periodic_all_oper      = nvl(i_periodic_all_oper,      periodic_all_oper)
             , periodic_oper_count    = nvl(i_periodic_oper_count,    periodic_oper_count)
             , reject_disp_min_warn   = nvl(i_reject_disp_min_warn,   reject_disp_min_warn)
             , cash_in_present        = nvl(i_cash_in_present,        cash_in_present)
             , cash_in_min_warn       = nvl(i_cash_in_min_warn,       cash_in_min_warn)
             , cash_in_max_warn       = nvl(i_cash_in_max_warn,       cash_in_max_warn)
             , powerup_service        = nvl(i_powerup_service,        powerup_service)
             , supervisor_service     = nvl(i_supervisor_service,     supervisor_service)
             , dispense_algo          = nvl(i_dispense_algo,          dispense_algo)
         where id                     = i_terminal_id;
    else
        update atm_terminal
           set atm_model              = i_atm_model
             , placement_type         = i_placement_type
             , availability_type      = i_availability_type
             , operating_hours        = i_operating_hours
             , cassette_count         = i_cassette_count
             , key_change_algo        = i_key_change_algo
             , counter_sync_cond      = i_counter_sync_cond
             , reject_disp_warn       = i_reject_disp_warn
             , disp_rest_warn         = i_disp_rest_warn
             , receipt_warn           = i_receipt_warn
             , card_capture_warn      = i_card_capture_warn
             , note_max_count         = i_note_max_count
             , scenario_id            = i_scenario_id
             , hopper_count           = i_hopper_count
             , manual_synch           = i_manual_synch
             , establ_conn_synch      = i_establ_conn_synch
             , counter_mismatch_synch = i_counter_mismatch_synch
             , online_in_synch        = i_online_in_synch
             , online_out_synch       = i_online_out_synch
             , safe_close_synch       = i_safe_close_synch
             , disp_error_synch       = i_disp_error_synch
             , periodic_synch         = i_periodic_synch
             , periodic_all_oper      = i_periodic_all_oper
             , periodic_oper_count    = i_periodic_oper_count
             , reject_disp_min_warn   = i_reject_disp_min_warn
             , cash_in_present        = i_cash_in_present
             , cash_in_min_warn       = i_cash_in_min_warn
             , cash_in_max_warn       = i_cash_in_max_warn
             , powerup_service        = nvl(i_powerup_service, atm_api_const_pkg.ATM_SERVICE_STATUS_CHANGE)
             , supervisor_service     = nvl(i_supervisor_service, atm_api_const_pkg.ATM_SERVICE_STATUS_CHANGE)
             , dispense_algo          = i_dispense_algo
         where id                     = i_terminal_id;
    end if;
end;

procedure remove_terminal(
    i_terminal_id       in      com_api_type_pkg.t_short_id
) is
begin
    delete atm_terminal
     where id                = i_terminal_id;
end;

procedure set_terminal_dynamic(
    i_id                     in      com_api_type_pkg.t_short_id
  , i_coll_id                in      com_api_type_pkg.t_medium_id
  , i_coll_oper_count        in      com_api_type_pkg.t_tiny_id
  , i_last_oper_id           in      com_api_type_pkg.t_long_id
  , i_last_oper_date         in      date
  , i_receipt_loaded         in      com_api_type_pkg.t_tiny_id
  , i_receipt_printed        in      com_api_type_pkg.t_tiny_id
  , i_receipt_remained       in      com_api_type_pkg.t_tiny_id
  , i_card_captured          in      com_api_type_pkg.t_tiny_id
  , i_card_reader_status     in      com_api_type_pkg.t_dict_value
  , i_rcpt_status            in      com_api_type_pkg.t_dict_value
  , i_rcpt_paper_status      in      com_api_type_pkg.t_dict_value
  , i_rcpt_ribbon_status     in      com_api_type_pkg.t_dict_value
  , i_rcpt_head_status       in      com_api_type_pkg.t_dict_value
  , i_rcpt_knife_status      in      com_api_type_pkg.t_dict_value
  , i_jrnl_status            in      com_api_type_pkg.t_dict_value
  , i_jrnl_paper_status      in      com_api_type_pkg.t_dict_value
  , i_jrnl_ribbon_status     in      com_api_type_pkg.t_dict_value
  , i_jrnl_head_status       in      com_api_type_pkg.t_dict_value
  , i_ejrnl_status           in      com_api_type_pkg.t_dict_value
  , i_ejrnl_space_status     in      com_api_type_pkg.t_dict_value
  , i_stmt_status            in      com_api_type_pkg.t_dict_value
  , i_stmt_paper_status      in      com_api_type_pkg.t_dict_value
  , i_stmt_ribbon_stat       in      com_api_type_pkg.t_dict_value
  , i_stmt_head_status       in      com_api_type_pkg.t_dict_value
  , i_stmt_knife_status      in      com_api_type_pkg.t_dict_value
  , i_stmt_capt_bin_status   in      com_api_type_pkg.t_dict_value
  , i_tod_clock_status       in      com_api_type_pkg.t_dict_value
  , i_depository_status      in      com_api_type_pkg.t_dict_value
  , i_night_safe_status      in      com_api_type_pkg.t_dict_value
  , i_encryptor_status       in      com_api_type_pkg.t_dict_value
  , i_tscreen_keyb_status    in      com_api_type_pkg.t_dict_value
  , i_voice_guidance_status  in      com_api_type_pkg.t_dict_value
  , i_camera_status          in      com_api_type_pkg.t_dict_value
  , i_bunch_acpt_status      in      com_api_type_pkg.t_dict_value
  , i_envelope_disp_status   in      com_api_type_pkg.t_dict_value
  , i_cheque_module_status   in      com_api_type_pkg.t_dict_value
  , i_barcode_reader_status  in      com_api_type_pkg.t_dict_value
  , i_coin_disp_status       in      com_api_type_pkg.t_dict_value
  , i_dispenser_status       in      com_api_type_pkg.t_dict_value
  , i_workflow_status        in      com_api_type_pkg.t_dict_value
  , i_service_status         in      com_api_type_pkg.t_dict_value
  , i_connection_status      in      com_api_type_pkg.t_dict_value
  , i_counters_synch_flag    in      com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
  , i_transaction_serial_number in   com_api_type_pkg.t_short_id default null
) is
    l_last_oper_date                 date;
    l_operation                      opr_api_type_pkg.t_oper_rec;
begin
    if i_last_oper_date is null then
        opr_api_operation_pkg.get_operation(
            i_oper_id             => i_last_oper_id
          , o_operation           => l_operation
        );
        l_last_oper_date := l_operation.oper_date;
    else
        l_last_oper_date := i_last_oper_date;
    end if;
    merge into
        atm_terminal_dynamic dst
    using (
        select
            i_id id
        from
            dual
    ) src
    on (
        src.id = dst.id
    )
    when matched then
        update
        set dst.coll_id                   = i_coll_id
          , dst.coll_oper_count           = i_coll_oper_count
          , dst.last_oper_id              = i_last_oper_id
          , dst.last_oper_date            = l_last_oper_date
          , dst.receipt_loaded            = i_receipt_loaded
          , dst.receipt_printed           = i_receipt_printed
          , dst.receipt_remained          = i_receipt_remained
          , dst.card_captured             = i_card_captured
          , dst.card_reader_status        = i_card_reader_status
          , dst.rcpt_status               = i_rcpt_status
          , dst.rcpt_paper_status         = i_rcpt_paper_status
          , dst.rcpt_ribbon_status        = i_rcpt_ribbon_status
          , dst.rcpt_head_status          = i_rcpt_head_status
          , dst.rcpt_knife_status         = i_rcpt_knife_status
          , dst.jrnl_status               = i_jrnl_status
          , dst.jrnl_paper_status         = i_jrnl_paper_status
          , dst.jrnl_ribbon_status        = i_jrnl_ribbon_status
          , dst.jrnl_head_status          = i_jrnl_head_status
          , dst.ejrnl_status              = i_ejrnl_status
          , dst.ejrnl_space_status        = i_ejrnl_space_status
          , dst.stmt_status               = i_stmt_status
          , dst.stmt_paper_status         = i_stmt_paper_status
          , dst.stmt_ribbon_stat          = i_stmt_ribbon_stat
          , dst.stmt_head_status          = i_stmt_head_status
          , dst.stmt_knife_status         = i_stmt_knife_status
          , dst.stmt_capt_bin_status      = i_stmt_capt_bin_status
          , dst.tod_clock_status          = i_tod_clock_status
          , dst.depository_status         = i_depository_status
          , dst.night_safe_status         = i_night_safe_status
          , dst.encryptor_status          = i_encryptor_status
          , dst.tscreen_keyb_status       = i_tscreen_keyb_status
          , dst.voice_guidance_status     = i_voice_guidance_status
          , dst.camera_status             = i_camera_status
          , dst.bunch_acpt_status         = i_bunch_acpt_status
          , dst.envelope_disp_status      = i_envelope_disp_status
          , dst.cheque_module_status      = i_cheque_module_status
          , dst.barcode_reader_status     = i_barcode_reader_status
          , dst.coin_disp_status          = i_coin_disp_status
          , dst.dispenser_status          = i_dispenser_status
          , dst.workflow_status           = i_workflow_status
          , dst.service_status            = i_service_status
          , dst.connection_status         = nvl(i_connection_status, dst.connection_status)
          , dst.last_synch_date           = case i_counters_synch_flag
                                                when com_api_type_pkg.TRUE then sysdate
                                                else dst.last_synch_date
                                            end
          , dst.transaction_serial_number = i_transaction_serial_number
    when not matched then
        insert (
            dst.id
          , dst.coll_id
          , dst.coll_oper_count
          , dst.last_oper_id
          , dst.last_oper_date
          , dst.receipt_loaded
          , dst.receipt_printed
          , dst.receipt_remained
          , dst.card_captured
          , dst.card_reader_status
          , dst.rcpt_status
          , dst.rcpt_paper_status
          , dst.rcpt_ribbon_status
          , dst.rcpt_head_status
          , dst.rcpt_knife_status
          , dst.jrnl_status
          , dst.jrnl_paper_status
          , dst.jrnl_ribbon_status
          , dst.jrnl_head_status
          , dst.ejrnl_status
          , dst.ejrnl_space_status
          , dst.stmt_status
          , dst.stmt_paper_status
          , dst.stmt_ribbon_stat
          , dst.stmt_head_status
          , dst.stmt_knife_status
          , dst.stmt_capt_bin_status
          , dst.tod_clock_status
          , dst.depository_status
          , dst.night_safe_status
          , dst.encryptor_status
          , dst.tscreen_keyb_status
          , dst.voice_guidance_status
          , dst.camera_status
          , dst.bunch_acpt_status
          , dst.envelope_disp_status
          , dst.cheque_module_status
          , dst.barcode_reader_status
          , dst.coin_disp_status
          , dst.dispenser_status
          , dst.workflow_status
          , dst.service_status
          , dst.connection_status
          , dst.last_synch_date
          , dst.transaction_serial_number
        ) values(
            src.id
          , i_coll_id
          , i_coll_oper_count
          , i_last_oper_id
          , l_last_oper_date
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
          , nvl(i_connection_status, atm_api_const_pkg.CONECTION_STATUS_CLOSE)
          , case i_counters_synch_flag when com_api_type_pkg.TRUE then sysdate else null end
          , i_transaction_serial_number
        );
end;

procedure modify_terminal_dynamic(
    i_id                     in      com_api_type_pkg.t_short_id
  , i_coll_id                in      com_api_type_pkg.t_medium_id
  , i_coll_oper_count        in      com_api_type_pkg.t_tiny_id
  , i_last_oper_id           in      com_api_type_pkg.t_long_id
  , i_last_oper_date         in      date
  , i_receipt_loaded         in      com_api_type_pkg.t_tiny_id
  , i_receipt_printed        in      com_api_type_pkg.t_tiny_id
  , i_receipt_remained       in      com_api_type_pkg.t_tiny_id
  , i_card_captured          in      com_api_type_pkg.t_tiny_id
  , i_card_reader_status     in      com_api_type_pkg.t_dict_value
  , i_rcpt_status            in      com_api_type_pkg.t_dict_value
  , i_rcpt_paper_status      in      com_api_type_pkg.t_dict_value
  , i_rcpt_ribbon_status     in      com_api_type_pkg.t_dict_value
  , i_rcpt_head_status       in      com_api_type_pkg.t_dict_value
  , i_rcpt_knife_status      in      com_api_type_pkg.t_dict_value
  , i_jrnl_status            in      com_api_type_pkg.t_dict_value
  , i_jrnl_paper_status      in      com_api_type_pkg.t_dict_value
  , i_jrnl_ribbon_status     in      com_api_type_pkg.t_dict_value
  , i_jrnl_head_status       in      com_api_type_pkg.t_dict_value
  , i_ejrnl_status           in      com_api_type_pkg.t_dict_value
  , i_ejrnl_space_status     in      com_api_type_pkg.t_dict_value
  , i_stmt_status            in      com_api_type_pkg.t_dict_value
  , i_stmt_paper_status      in      com_api_type_pkg.t_dict_value
  , i_stmt_ribbon_stat       in      com_api_type_pkg.t_dict_value
  , i_stmt_head_status       in      com_api_type_pkg.t_dict_value
  , i_stmt_knife_status      in      com_api_type_pkg.t_dict_value
  , i_stmt_capt_bin_status   in      com_api_type_pkg.t_dict_value
  , i_tod_clock_status       in      com_api_type_pkg.t_dict_value
  , i_depository_status      in      com_api_type_pkg.t_dict_value
  , i_night_safe_status      in      com_api_type_pkg.t_dict_value
  , i_encryptor_status       in      com_api_type_pkg.t_dict_value
  , i_tscreen_keyb_status    in      com_api_type_pkg.t_dict_value
  , i_voice_guidance_status  in      com_api_type_pkg.t_dict_value
  , i_camera_status          in      com_api_type_pkg.t_dict_value
  , i_bunch_acpt_status      in      com_api_type_pkg.t_dict_value
  , i_envelope_disp_status   in      com_api_type_pkg.t_dict_value
  , i_cheque_module_status   in      com_api_type_pkg.t_dict_value
  , i_barcode_reader_status  in      com_api_type_pkg.t_dict_value
  , i_coin_disp_status       in      com_api_type_pkg.t_dict_value
  , i_dispenser_status       in      com_api_type_pkg.t_dict_value
  , i_workflow_status        in      com_api_type_pkg.t_dict_value
  , i_service_status         in      com_api_type_pkg.t_dict_value
  , i_connection_status      in      com_api_type_pkg.t_dict_value
  , i_counters_synch_flag    in      com_api_type_pkg.t_boolean
  , i_transaction_serial_number in   com_api_type_pkg.t_short_id default null
) is
    l_card_reader_status             com_api_type_pkg.t_dict_value;
    l_rcpt_status                    com_api_type_pkg.t_dict_value;
    l_rcpt_paper_status              com_api_type_pkg.t_dict_value;
    l_rcpt_ribbon_status             com_api_type_pkg.t_dict_value;
    l_rcpt_head_status               com_api_type_pkg.t_dict_value;
    l_rcpt_knife_status              com_api_type_pkg.t_dict_value;
    l_jrnl_status                    com_api_type_pkg.t_dict_value;
    l_jrnl_paper_status              com_api_type_pkg.t_dict_value;
    l_jrnl_ribbon_status             com_api_type_pkg.t_dict_value;
    l_jrnl_head_status               com_api_type_pkg.t_dict_value;
    l_ejrnl_status                   com_api_type_pkg.t_dict_value;
    l_ejrnl_space_status             com_api_type_pkg.t_dict_value;
    l_stmt_status                    com_api_type_pkg.t_dict_value;
    l_stmt_paper_status              com_api_type_pkg.t_dict_value;
    l_stmt_ribbon_stat               com_api_type_pkg.t_dict_value;
    l_stmt_head_status               com_api_type_pkg.t_dict_value;
    l_stmt_knife_status              com_api_type_pkg.t_dict_value;
    l_stmt_capt_bin_status           com_api_type_pkg.t_dict_value;
    l_tod_clock_status               com_api_type_pkg.t_dict_value;
    l_depository_status              com_api_type_pkg.t_dict_value;
    l_night_safe_status              com_api_type_pkg.t_dict_value;
    l_encryptor_status               com_api_type_pkg.t_dict_value;
    l_tscreen_keyb_status            com_api_type_pkg.t_dict_value;
    l_voice_guidance_status          com_api_type_pkg.t_dict_value;
    l_camera_status                  com_api_type_pkg.t_dict_value;
    l_bunch_acpt_status              com_api_type_pkg.t_dict_value;
    l_envelope_disp_status           com_api_type_pkg.t_dict_value;
    l_cheque_module_status           com_api_type_pkg.t_dict_value;
    l_barcode_reader_status          com_api_type_pkg.t_dict_value;
    l_coin_disp_status               com_api_type_pkg.t_dict_value;
    l_dispenser_status               com_api_type_pkg.t_dict_value;
    l_workflow_status                com_api_type_pkg.t_dict_value;
    l_service_status                 com_api_type_pkg.t_dict_value;
    l_connection_status              com_api_type_pkg.t_dict_value;

    l_split_hash                     com_api_type_pkg.t_tiny_id;
    l_common_status                  com_api_type_pkg.t_boolean    :=  com_api_const_pkg.FALSE;
    l_receipt_remained               com_api_type_pkg.t_tiny_id;
    l_receipt_warn                   com_api_type_pkg.t_tiny_id;
    l_card_captured                  com_api_type_pkg.t_tiny_id;

    procedure add_status_log(
        i_old_status             in     com_api_type_pkg.t_dict_value
      , i_new_status             in     com_api_type_pkg.t_dict_value
      , i_atm_part_type          in     com_api_type_pkg.t_dict_value default null
    ) is
    begin
        if nvl(i_old_status, '0') != nvl(i_new_status, '0') then
            atm_api_status_log_pkg.add_status_log(
                i_terminal_id   => i_id
              , i_status        => i_new_status
              , i_atm_part_type => i_atm_part_type
            );
        end if;
    end;

    procedure register_event (
        i_event_type             in     com_api_type_pkg.t_dict_value
    ) is
        l_inst_id                       com_api_type_pkg.t_inst_id;
    begin
        select inst_id
          into l_inst_id
          from acq_terminal
         where id = i_id;
         
        evt_api_event_pkg.register_event (
            i_event_type    =>  i_event_type
          , i_eff_date      =>  i_last_oper_date
          , i_entity_type   =>  acq_api_const_pkg.ENTITY_TYPE_TERMINAL
          , i_object_id     =>  i_id
          , i_inst_id       =>  l_inst_id
          , i_split_hash    =>  l_split_hash
        );

        l_common_status := com_api_const_pkg.TRUE;
    end;

    procedure register_event_conditional (
        i_prev_status            in     com_api_type_pkg.t_dict_value
      , i_new_status             in     com_api_type_pkg.t_dict_value
      , i_event_type             in     com_api_type_pkg.t_dict_value
    ) is
    begin
        if nvl(i_prev_status,'0') != nvl(i_new_status,'0') then
            register_event(
                i_event_type => i_event_type
            );
        end if;
    end;

begin
    begin
        select card_reader_status
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
             , receipt_remained
             , card_captured
             , connection_status
          into l_card_reader_status
             , l_rcpt_status
             , l_rcpt_paper_status
             , l_rcpt_ribbon_status
             , l_rcpt_head_status
             , l_rcpt_knife_status
             , l_jrnl_status
             , l_jrnl_paper_status
             , l_jrnl_ribbon_status
             , l_jrnl_head_status
             , l_ejrnl_status
             , l_ejrnl_space_status
             , l_stmt_status
             , l_stmt_paper_status
             , l_stmt_ribbon_stat
             , l_stmt_head_status
             , l_stmt_knife_status
             , l_stmt_capt_bin_status
             , l_tod_clock_status
             , l_depository_status
             , l_night_safe_status
             , l_encryptor_status
             , l_tscreen_keyb_status
             , l_voice_guidance_status
             , l_camera_status
             , l_bunch_acpt_status
             , l_envelope_disp_status
             , l_cheque_module_status
             , l_barcode_reader_status
             , l_coin_disp_status
             , l_dispenser_status
             , l_workflow_status
             , l_service_status
             , l_receipt_remained
             , l_card_captured
             , l_connection_status
          from atm_terminal_dynamic b
         where id = i_id;
    exception
        when no_data_found then
            null;
    end;

    add_status_log(
        i_old_status    => l_card_reader_status
      , i_new_status    => i_card_reader_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_CARD_READER
    );
    add_status_log(
        i_old_status    => l_rcpt_status
      , i_new_status    => i_rcpt_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_RECEIPT_PRINTER
    );
    add_status_log(
        i_old_status    => l_rcpt_paper_status
      , i_new_status    => i_rcpt_paper_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_RECEIPT_PRINTER
    );
    add_status_log(
        i_old_status    => l_rcpt_ribbon_status
      , i_new_status    => i_rcpt_ribbon_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_RECEIPT_PRINTER
    );
    add_status_log(
        i_old_status    => l_rcpt_head_status
      , i_new_status    => i_rcpt_head_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_RECEIPT_PRINTER
    );
    add_status_log(
        i_old_status    => l_rcpt_knife_status
      , i_new_status    => i_rcpt_knife_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_RECEIPT_PRINTER
    );
    add_status_log(
        i_old_status    => l_jrnl_status
      , i_new_status    => i_jrnl_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_JOURNAL_PRINTER
    );
    add_status_log(
        i_old_status    => l_jrnl_paper_status
      , i_new_status    => i_jrnl_paper_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_JOURNAL_PRINTER
    );
    add_status_log(
        i_old_status    => l_jrnl_ribbon_status
      , i_new_status    => i_jrnl_ribbon_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_JOURNAL_PRINTER
    );
    add_status_log(
        i_old_status    => l_jrnl_head_status
      , i_new_status    => i_jrnl_head_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_JOURNAL_PRINTER
    );
    add_status_log(
        i_old_status    => l_ejrnl_status
      , i_new_status    => i_ejrnl_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_ELECTRON_JOURNAL
    );
    add_status_log(
        i_old_status    => l_ejrnl_space_status
      , i_new_status    => i_ejrnl_space_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_ELECTRON_JOURNAL
    );
    add_status_log(
        i_old_status    => l_stmt_status
      , i_new_status    => i_stmt_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_STMT_PRINTER
    );
    add_status_log(
        i_old_status    => l_stmt_paper_status
      , i_new_status    => i_stmt_paper_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_STMT_PRINTER
    );
    add_status_log(
        i_old_status    => l_stmt_ribbon_stat
      , i_new_status    => i_stmt_ribbon_stat
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_STMT_PRINTER
    );
    add_status_log(
        i_old_status    => l_stmt_head_status
      , i_new_status    => i_stmt_head_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_STMT_PRINTER
    );
    add_status_log(
        i_old_status    => l_stmt_knife_status
      , i_new_status    => i_stmt_knife_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_STMT_PRINTER
    );
    add_status_log(
        i_old_status    => l_stmt_capt_bin_status
      , i_new_status    => i_stmt_capt_bin_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_STMT_PRINTER
    );
    add_status_log(
        i_old_status    => l_tod_clock_status
      , i_new_status    => i_tod_clock_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_TOD_CLOCK
    );
    add_status_log(
        i_old_status    => l_depository_status
      , i_new_status    => i_depository_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_ENV_DEPOSITORY
    );
    add_status_log(
        i_old_status    => l_night_safe_status
      , i_new_status    => i_night_safe_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_NIGHT_SAFE_DPST
    );
    add_status_log(
        i_old_status    => l_encryptor_status
      , i_new_status    => i_encryptor_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_ENCRYPTOR
    );
    add_status_log(
        i_old_status    => l_tscreen_keyb_status
      , i_new_status    => i_tscreen_keyb_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_CARDHLDR_DISPLAY
    );
    add_status_log(
        i_old_status    => l_voice_guidance_status
      , i_new_status    => i_voice_guidance_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_VOICE_GUIDANCE
    );
    add_status_log(
        i_old_status    => l_camera_status
      , i_new_status    => i_camera_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_SECURITY_CAMERA
    );
    add_status_log(
        i_old_status    => l_bunch_acpt_status
      , i_new_status    => i_bunch_acpt_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_NOTE_ACCEPTOR
    );
    add_status_log(
        i_old_status    => l_envelope_disp_status
      , i_new_status    => i_envelope_disp_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_ENV_DISPENSER
    );
    add_status_log(
        i_old_status    => l_cheque_module_status
      , i_new_status    => i_cheque_module_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_CHK_PROCESS_MOD
    );
    add_status_log(
        i_old_status    => l_barcode_reader_status
      , i_new_status    => i_barcode_reader_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_BARCODE_READER
    );
    add_status_log(
        i_old_status    => l_coin_disp_status
      , i_new_status    => i_coin_disp_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_COIN_DISPENSER
    );
    add_status_log(
        i_old_status    => l_dispenser_status
      , i_new_status    => i_dispenser_status
      , i_atm_part_type => atm_api_const_pkg.ATM_PART_TYPE_DISPENSER
    );
    add_status_log(
        i_old_status    => l_workflow_status
      , i_new_status    => i_workflow_status
    );
    add_status_log(
        i_old_status    => l_service_status
      , i_new_status    => i_service_status
    );
    add_status_log(
        i_old_status    => l_connection_status
      , i_new_status    => i_connection_status
    );

    set_terminal_dynamic(
        i_id                        => i_id
      , i_coll_id                   => i_coll_id
      , i_coll_oper_count           => i_coll_oper_count
      , i_last_oper_id              => i_last_oper_id
      , i_last_oper_date            => i_last_oper_date
      , i_receipt_loaded            => i_receipt_loaded
      , i_receipt_printed           => i_receipt_printed
      , i_receipt_remained          => i_receipt_remained
      , i_card_captured             => i_card_captured
      , i_card_reader_status        => i_card_reader_status
      , i_rcpt_status               => i_rcpt_status
      , i_rcpt_paper_status         => i_rcpt_paper_status
      , i_rcpt_ribbon_status        => i_rcpt_ribbon_status
      , i_rcpt_head_status          => i_rcpt_head_status
      , i_rcpt_knife_status         => i_rcpt_knife_status
      , i_jrnl_status               => i_jrnl_status
      , i_jrnl_paper_status         => i_jrnl_paper_status
      , i_jrnl_ribbon_status        => i_jrnl_ribbon_status
      , i_jrnl_head_status          => i_jrnl_head_status
      , i_ejrnl_status              => i_ejrnl_status
      , i_ejrnl_space_status        => i_ejrnl_space_status
      , i_stmt_status               => i_stmt_status
      , i_stmt_paper_status         => i_stmt_paper_status
      , i_stmt_ribbon_stat          => i_stmt_ribbon_stat
      , i_stmt_head_status          => i_stmt_head_status
      , i_stmt_knife_status         => i_stmt_knife_status
      , i_stmt_capt_bin_status      => i_stmt_capt_bin_status
      , i_tod_clock_status          => i_tod_clock_status
      , i_depository_status         => i_depository_status
      , i_night_safe_status         => i_night_safe_status
      , i_encryptor_status          => i_encryptor_status
      , i_tscreen_keyb_status       => i_tscreen_keyb_status
      , i_voice_guidance_status     => i_voice_guidance_status
      , i_camera_status             => i_camera_status
      , i_bunch_acpt_status         => i_bunch_acpt_status
      , i_envelope_disp_status      => i_envelope_disp_status
      , i_cheque_module_status      => i_cheque_module_status
      , i_barcode_reader_status     => i_barcode_reader_status
      , i_coin_disp_status          => i_coin_disp_status
      , i_dispenser_status          => i_dispenser_status
      , i_workflow_status           => i_workflow_status
      , i_service_status            => i_service_status
      , i_connection_status         => i_connection_status
      , i_counters_synch_flag       => i_counters_synch_flag
      , i_transaction_serial_number => i_transaction_serial_number
    );

    evt_api_status_pkg.add_status_log(
        i_event_type    => null
      , i_initiator     => evt_api_const_pkg.INITIATOR_SYSTEM
      , i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_object_id     => i_id
      , i_reason        => null
      , i_status        => i_service_status
      , i_eff_date      => null
    );

    select split_hash
    into   l_split_hash
    from   acq_terminal
    where  id = i_id;

    register_event_conditional (
        i_prev_status   =>  l_rcpt_status
      , i_new_status    =>  i_rcpt_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_RCPT
    );

    register_event_conditional (
        i_prev_status   =>  l_card_reader_status
      , i_new_status    =>  i_card_reader_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_CARD_READER
    );

    register_event_conditional (
        i_prev_status   =>  l_jrnl_status
      , i_new_status    =>  i_jrnl_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_JRNL
    );

    register_event_conditional (
        i_prev_status   =>  l_ejrnl_status
      , i_new_status    =>  i_ejrnl_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_EJRNL
    );

    register_event_conditional (
        i_prev_status   =>  l_stmt_status
      , i_new_status    =>  i_stmt_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_STMT
    );

    register_event_conditional (
        i_prev_status   =>  l_tod_clock_status
      , i_new_status    =>  i_tod_clock_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_TOD_CLOCK
    );

    register_event_conditional (
        i_prev_status   =>  l_depository_status
      , i_new_status    =>  i_depository_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_DEPOSITORY
    );

    register_event_conditional (
        i_prev_status   =>  l_night_safe_status
      , i_new_status    =>  i_night_safe_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_NIGHT_SAFE
    );

    register_event_conditional (
        i_prev_status   =>  l_encryptor_status
      , i_new_status    =>  i_encryptor_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_ENCRYPTOR
    );

    register_event_conditional (
        i_prev_status   =>  l_tscreen_keyb_status
      , i_new_status    =>  i_tscreen_keyb_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_TSCREEN_KEYB
    );

    register_event_conditional (
        i_prev_status   =>  l_voice_guidance_status
      , i_new_status    =>  i_voice_guidance_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_VOICE_GUIDANCE
    );

    register_event_conditional (
        i_prev_status   =>  l_camera_status
      , i_new_status    =>  i_camera_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_CAMERA
    );

    register_event_conditional (
        i_prev_status   =>  l_bunch_acpt_status
      , i_new_status    =>  i_bunch_acpt_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_BUNCH_ACPT
    );

    register_event_conditional (
        i_prev_status   =>  l_envelope_disp_status
      , i_new_status    =>  i_envelope_disp_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_ENVELOPE_DISP
    );

    register_event_conditional (
        i_prev_status   =>  l_cheque_module_status
      , i_new_status    =>  i_cheque_module_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_CHEQUE_MODULE
    );

    register_event_conditional (
        i_prev_status   =>  l_barcode_reader_status
      , i_new_status    =>  i_barcode_reader_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_BARCODE_READER
    );

    register_event_conditional (
        i_prev_status   =>  l_coin_disp_status
      , i_new_status    =>  i_coin_disp_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_COIN_DISP
    );

    register_event_conditional (
        i_prev_status   =>  l_dispenser_status
      , i_new_status    =>  i_dispenser_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_DISPENSER
    );

    register_event_conditional (
        i_prev_status   =>  l_connection_status
      , i_new_status    =>  i_connection_status
      , i_event_type    =>  acq_api_const_pkg.EVENT_TERMINAL_CONNNECTION
    );

    select receipt_warn
    into   l_receipt_warn
    from   atm_terminal
    where  id = i_id;

    if l_receipt_remained < l_receipt_warn and i_receipt_remained >= l_receipt_warn then
        register_event(
            i_event_type => acq_api_const_pkg.EVENT_TERMINAL_RCPT_LIMIT
        );
    end if;

    --add to condition service_status workflow_status
    if l_common_status = com_api_const_pkg.TRUE then
        register_event(
            i_event_type => acq_api_const_pkg.EVENT_TERMINAL_COMMON
        );
    end if;

    if nvl(i_card_captured, 0) > nvl(l_card_captured, 0) then
        --add captured card
        atm_api_captured_card_pkg.add_captured_card(
            i_auth_id       => i_last_oper_id
          , i_terminal_id   => i_id
          , i_coll_id       => i_coll_id 
        );
    end if;
end;

procedure modify_terminal_dynamic(
    i_id                     in      com_api_type_pkg.t_short_id
  , i_coll_id                in      com_api_type_pkg.t_medium_id
  , i_coll_oper_count        in      com_api_type_pkg.t_tiny_id
  , i_last_oper_id           in      com_api_type_pkg.t_long_id
  , i_last_oper_date         in      date
  , i_receipt_loaded         in      com_api_type_pkg.t_tiny_id
  , i_receipt_printed        in      com_api_type_pkg.t_tiny_id
  , i_receipt_remained       in      com_api_type_pkg.t_tiny_id
  , i_card_captured          in      com_api_type_pkg.t_tiny_id
  , i_card_reader_status     in      com_api_type_pkg.t_dict_value
  , i_rcpt_status            in      com_api_type_pkg.t_dict_value
  , i_rcpt_paper_status      in      com_api_type_pkg.t_dict_value
  , i_rcpt_ribbon_status     in      com_api_type_pkg.t_dict_value
  , i_rcpt_head_status       in      com_api_type_pkg.t_dict_value
  , i_rcpt_knife_status      in      com_api_type_pkg.t_dict_value
  , i_jrnl_status            in      com_api_type_pkg.t_dict_value
  , i_jrnl_paper_status      in      com_api_type_pkg.t_dict_value
  , i_jrnl_ribbon_status     in      com_api_type_pkg.t_dict_value
  , i_jrnl_head_status       in      com_api_type_pkg.t_dict_value
  , i_ejrnl_status           in      com_api_type_pkg.t_dict_value
  , i_ejrnl_space_status     in      com_api_type_pkg.t_dict_value
  , i_stmt_status            in      com_api_type_pkg.t_dict_value
  , i_stmt_paper_status      in      com_api_type_pkg.t_dict_value
  , i_stmt_ribbon_stat       in      com_api_type_pkg.t_dict_value
  , i_stmt_head_status       in      com_api_type_pkg.t_dict_value
  , i_stmt_knife_status      in      com_api_type_pkg.t_dict_value
  , i_stmt_capt_bin_status   in      com_api_type_pkg.t_dict_value
  , i_tod_clock_status       in      com_api_type_pkg.t_dict_value
  , i_depository_status      in      com_api_type_pkg.t_dict_value
  , i_night_safe_status      in      com_api_type_pkg.t_dict_value
  , i_encryptor_status       in      com_api_type_pkg.t_dict_value
  , i_tscreen_keyb_status    in      com_api_type_pkg.t_dict_value
  , i_voice_guidance_status  in      com_api_type_pkg.t_dict_value
  , i_camera_status          in      com_api_type_pkg.t_dict_value
  , i_bunch_acpt_status      in      com_api_type_pkg.t_dict_value
  , i_envelope_disp_status   in      com_api_type_pkg.t_dict_value
  , i_cheque_module_status   in      com_api_type_pkg.t_dict_value
  , i_barcode_reader_status  in      com_api_type_pkg.t_dict_value
  , i_coin_disp_status       in      com_api_type_pkg.t_dict_value
  , i_dispenser_status       in      com_api_type_pkg.t_dict_value
  , i_workflow_status        in      com_api_type_pkg.t_dict_value
  , i_service_status         in      com_api_type_pkg.t_dict_value
  , i_connection_status      in      com_api_type_pkg.t_dict_value
  , i_dispenser_id_tab       in      com_api_type_pkg.t_number_tab
  , i_note_dispensed_tab     in      com_api_type_pkg.t_number_tab
  , i_note_remained_tab      in      com_api_type_pkg.t_number_tab
  , i_note_rejected_tab      in      com_api_type_pkg.t_number_tab
  , i_note_loaded_tab        in      com_api_type_pkg.t_number_tab
  , i_cassette_status_tab    in      com_api_type_pkg.t_dict_tab
  , i_counters_synch_flag    in      com_api_type_pkg.t_boolean
  , i_transaction_serial_number  in  com_api_type_pkg.t_short_id default null
) is
    l_connection_status              com_api_type_pkg.t_dict_value;

    function is_fatal_status return com_api_type_pkg.t_boolean is
    begin
        if i_card_reader_status in (atm_api_const_pkg.CARD_READER_STATUS_ERROR)
           or i_rcpt_status in (atm_api_const_pkg.PRINTER_STATUS_ERROR)
           or i_jrnl_status in (atm_api_const_pkg.JRNL_STATUS_ERROR)
           or i_ejrnl_status in (atm_api_const_pkg.PAPER_STATUS_EXHAUSTED)
           or i_stmt_status in (atm_api_const_pkg.STPR_STATUS_ERROR)
           or i_tod_clock_status in (atm_api_const_pkg.TOD_CLOCK_STATUS_STOP)
           or i_depository_status in (atm_api_const_pkg.DEPOSITORY_STATUS_ERROR)
           or i_night_safe_status in (atm_api_const_pkg.NIGHT_SAFE_STATUS_OVERFILL)
           or i_encryptor_status in (atm_api_const_pkg.ENCRYPTOR_STATUS_ERROR)
           or i_tscreen_keyb_status in (atm_api_const_pkg.TSCREEN_KEYB_STATUS_ERROR)
           or i_voice_guidance_status in (atm_api_const_pkg.VOICE_GUIDANCE_STATUS_ERROR)
           or i_camera_status in (atm_api_const_pkg.CAMERA_STATUS_ERROR)
           or i_envelope_disp_status in (atm_api_const_pkg.ENVELOPE_DISP_STATUS_ERROR)
           or i_barcode_reader_status in (atm_api_const_pkg.BARCODE_READER_STATUS_ERROR)
           or i_coin_disp_status in (atm_api_const_pkg.COIN_DISP_STATUS_ERROR)
           or i_dispenser_status in (atm_api_const_pkg.DISPENSER_STATUS_ERROR) then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    end;
begin
    modify_terminal_dynamic(
        i_id                        => i_id
      , i_coll_id                   => i_coll_id
      , i_coll_oper_count           => i_coll_oper_count
      , i_last_oper_id              => i_last_oper_id
      , i_last_oper_date            => i_last_oper_date
      , i_receipt_loaded            => i_receipt_loaded
      , i_receipt_printed           => i_receipt_printed
      , i_receipt_remained          => i_receipt_remained
      , i_card_captured             => i_card_captured
      , i_card_reader_status        => i_card_reader_status
      , i_rcpt_status               => i_rcpt_status
      , i_rcpt_paper_status         => i_rcpt_paper_status
      , i_rcpt_ribbon_status        => i_rcpt_ribbon_status
      , i_rcpt_head_status          => i_rcpt_head_status
      , i_rcpt_knife_status         => i_rcpt_knife_status
      , i_jrnl_status               => i_jrnl_status
      , i_jrnl_paper_status         => i_jrnl_paper_status
      , i_jrnl_ribbon_status        => i_jrnl_ribbon_status
      , i_jrnl_head_status          => i_jrnl_head_status
      , i_ejrnl_status              => i_ejrnl_status
      , i_ejrnl_space_status        => i_ejrnl_space_status
      , i_stmt_status               => i_stmt_status
      , i_stmt_paper_status         => i_stmt_paper_status
      , i_stmt_ribbon_stat          => i_stmt_ribbon_stat
      , i_stmt_head_status          => i_stmt_head_status
      , i_stmt_knife_status         => i_stmt_knife_status
      , i_stmt_capt_bin_status      => i_stmt_capt_bin_status
      , i_tod_clock_status          => i_tod_clock_status
      , i_depository_status         => i_depository_status
      , i_night_safe_status         => i_night_safe_status
      , i_encryptor_status          => i_encryptor_status
      , i_tscreen_keyb_status       => i_tscreen_keyb_status
      , i_voice_guidance_status     => i_voice_guidance_status
      , i_camera_status             => i_camera_status
      , i_bunch_acpt_status         => i_bunch_acpt_status
      , i_envelope_disp_status      => i_envelope_disp_status
      , i_cheque_module_status      => i_cheque_module_status
      , i_barcode_reader_status     => i_barcode_reader_status
      , i_coin_disp_status          => i_coin_disp_status
      , i_dispenser_status          => i_dispenser_status
      , i_workflow_status           => i_workflow_status
      , i_service_status            => i_service_status
      , i_connection_status         => i_connection_status
      , i_counters_synch_flag       => i_counters_synch_flag
      , i_transaction_serial_number => i_transaction_serial_number
    );

    atm_api_dispenser_pkg.modify_disp_stat(
        i_dispenser_id_tab     => i_dispenser_id_tab
      , i_note_dispensed_tab   => i_note_dispensed_tab
      , i_note_remained_tab    => i_note_remained_tab
      , i_note_rejected_tab    => i_note_rejected_tab
      , i_note_loaded_tab      => i_note_loaded_tab
      , i_cassette_status_tab  => i_cassette_status_tab
    );

    select
        case
        when i_connection_status = atm_api_const_pkg.CONECTION_STATUS_CLOSE then
            atm_api_const_pkg.AGGR_STATUS_ABSENCE_COMM
        when x.service_status = atm_api_const_pkg.SERVICE_STATUS_OUT_OF_S
            and x.fatal_error = com_api_type_pkg.TRUE then
            atm_api_const_pkg.AGGR_STATUS_CLOSED_FATAL_ERROR
        when x.service_status = atm_api_const_pkg.SERVICE_STATUS_OUT_OF_S
            and x.workflow_status in (atm_api_const_pkg.WORKFLOW_STATUS_UNDEFINED, atm_api_const_pkg.WORKFLOW_STATUS_IDLE)
            and x.fatal_error = com_api_type_pkg.FALSE then
            atm_api_const_pkg.AGGR_STATUS_CLOSED
        when x.service_status = atm_api_const_pkg.SERVICE_STATUS_OUT_OF_S
            and x.workflow_status not in (atm_api_const_pkg.WORKFLOW_STATUS_UNDEFINED, atm_api_const_pkg.WORKFLOW_STATUS_IDLE)
            and x.fatal_error = com_api_type_pkg.FALSE then
            atm_api_const_pkg.AGGR_STATUS_CLOSED_AUTO_PROC
        when x.service_status = atm_api_const_pkg.SERVICE_STATUS_IN_SERVICE
            and (x.dispenser_status = atm_api_const_pkg.DISPENSER_STATUS_ERROR or x.cassette_error = com_api_type_pkg.TRUE) then
            atm_api_const_pkg.AGGR_STATUS_OPEN_DISP_NOT_WORK
        when x.service_status = atm_api_const_pkg.SERVICE_STATUS_IN_SERVICE
            and x.all_out_notes = com_api_type_pkg.TRUE then
            atm_api_const_pkg.AGGR_STATUS_OPEN_OUT_OF_NOTES
        when x.service_status = atm_api_const_pkg.SERVICE_STATUS_IN_SERVICE
            and x.some_out_notes > 0 then
            atm_api_const_pkg.AGGR_STATUS_OPEN_CASSETTEEMPTY
        when x.service_status = atm_api_const_pkg.SERVICE_STATUS_IN_SERVICE
            and x.some_low_notes > 0 then
            atm_api_const_pkg.AGGR_STATUS_OPEN_NOTES_LOW
        else -- i_connection_status = atm_api_const_pkg.CONECTION_STATUS_OPEN
            atm_api_const_pkg.AGGR_STATUS_OPEN
        end
    into
        l_connection_status
    from (
        select
            t.service_status
            , t.workflow_status
            , t.dispenser_status
            , case when
                t.card_reader_status in (atm_api_const_pkg.CARD_READER_STATUS_ERROR)
                or t.rcpt_status in (atm_api_const_pkg.PRINTER_STATUS_ERROR)
                or t.jrnl_status in (atm_api_const_pkg.JRNL_STATUS_ERROR)
                or t.ejrnl_status in (atm_api_const_pkg.PAPER_STATUS_EXHAUSTED)
                or t.stmt_status in (atm_api_const_pkg.STPR_STATUS_ERROR)
                or t.tod_clock_status in (atm_api_const_pkg.TOD_CLOCK_STATUS_STOP)
                or t.depository_status in (atm_api_const_pkg.DEPOSITORY_STATUS_ERROR)
                or t.night_safe_status in (atm_api_const_pkg.NIGHT_SAFE_STATUS_OVERFILL)
                or t.encryptor_status in (atm_api_const_pkg.ENCRYPTOR_STATUS_ERROR)
                or t.tscreen_keyb_status in (atm_api_const_pkg.TSCREEN_KEYB_STATUS_ERROR)
                or t.voice_guidance_status in (atm_api_const_pkg.VOICE_GUIDANCE_STATUS_ERROR)
                or t.camera_status in (atm_api_const_pkg.CAMERA_STATUS_ERROR)
                or t.envelope_disp_status in (atm_api_const_pkg.ENVELOPE_DISP_STATUS_ERROR)
                or t.barcode_reader_status in (atm_api_const_pkg.BARCODE_READER_STATUS_ERROR)
                or t.coin_disp_status in (atm_api_const_pkg.COIN_DISP_STATUS_ERROR)
                or t.dispenser_status in (atm_api_const_pkg.DISPENSER_STATUS_ERROR)
              then 1 else 0 end fatal_error
            , p.*
        from
            atm_terminal_dynamic t
            , ( select
                    case when count(s.id) > 0 and count(decode(s.cassette_status, atm_api_const_pkg.CASSETTE_STATUS_ERROR, 1)) = count(s.id) then 1 else 0 end cassette_error
                    , case when count(s.id) > 0 and count(decode(s.cassette_status, atm_api_const_pkg.CASSETTE_STATUS_OUT_OF_NOTES, 1)) = count(s.id) then 1 else 0 end all_out_notes
                    , count(decode(s.cassette_status, atm_api_const_pkg.CASSETTE_STATUS_OUT_OF_NOTES, 1)) some_out_notes
                    , count(decode(s.cassette_status, atm_api_const_pkg.CASSETTE_STATUS_NOTES_LOW, 1)) some_low_notes
                from
                    atm_dispenser d
                    , atm_dispenser_dynamic s
                where
                    d.id = s.id
                    and d.terminal_id = i_id
            ) p
        where
            t.id = i_id
    ) x;

    atm_api_status_log_pkg.add_status_log (
        i_terminal_id  => i_id
        , i_status     => l_connection_status
    );
end;

end;
/
