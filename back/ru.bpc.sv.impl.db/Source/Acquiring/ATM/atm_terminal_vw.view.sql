create or replace force view atm_terminal_vw as
select id
     , atm_type
     , atm_model
     , serial_number
     , placement_type
     , availability_type
     , operating_hours
     , local_date_gap
     , cassette_count
     , key_change_algo
     , dispense_algo
     , counter_sync_cond
     , reject_disp_warn     -- Reject dispenser's overflow limit
     , reject_disp_min_warn -- Reject dispenser's warning limit
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
     , cash_in_present
     , cash_in_min_warn
     , cash_in_max_warn
     , recycling_present
     , machine_number
     , powerup_service
     , supervisor_service
  from atm_terminal
/