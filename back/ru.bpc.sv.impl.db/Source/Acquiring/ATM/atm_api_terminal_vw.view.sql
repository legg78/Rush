create or replace force view atm_api_terminal_vw as
select a.id
     , b.seqnum
     , a.atm_type
     , a.atm_model
     , a.placement_type
     , a.availability_type
     , a.operating_hours
     , a.local_date_gap
     , a.cassette_count
     , a.key_change_algo
     , a.dispense_algo
     , a.counter_sync_cond
     , a.reject_disp_warn
     , a.reject_disp_min_warn
     , a.disp_rest_warn
     , a.receipt_warn
     , a.card_capture_warn
     , a.note_max_count
     , a.scenario_id
     , a.hopper_count
     , a.manual_synch
     , a.establ_conn_synch
     , a.counter_mismatch_synch
     , a.online_in_synch
     , a.online_out_synch
     , a.safe_close_synch
     , a.disp_error_synch
     , a.periodic_synch
     , a.periodic_all_oper
     , a.periodic_oper_count
     , a.cash_in_present
     , a.cash_in_min_warn
     , a.cash_in_max_warn
     , a.machine_number
     , b.device_id
     , a.powerup_service
     , a.supervisor_service
     , d.coll_id
     , d.coll_oper_count
     , d.last_oper_id
     , d.last_oper_date
     , d.receipt_loaded
     , d.receipt_printed
     , d.receipt_remained
     , d.card_captured
     , d.card_reader_status
     , d.rcpt_status
     , d.rcpt_paper_status
     , d.rcpt_ribbon_status
     , d.rcpt_head_status
     , d.rcpt_knife_status
     , d.jrnl_status
     , d.jrnl_paper_status
     , d.jrnl_ribbon_status
     , d.jrnl_head_status
     , d.ejrnl_status
     , d.ejrnl_space_status
     , d.stmt_status
     , d.stmt_paper_status
     , d.stmt_ribbon_stat
     , d.stmt_head_status
     , d.stmt_knife_status
     , d.stmt_capt_bin_status
     , d.tod_clock_status
     , d.depository_status
     , d.night_safe_status
     , d.encryptor_status
     , d.tscreen_keyb_status
     , d.voice_guidance_status
     , d.camera_status
     , d.bunch_acpt_status
     , d.envelope_disp_status
     , d.cheque_module_status
     , d.barcode_reader_status
     , d.coin_disp_status
     , d.dispenser_status
     , d.workflow_status
     , d.service_status
     , d.connection_status
     , d.last_synch_date
     , c.collection_number
     , d.transaction_serial_number
  from atm_terminal a
     , acq_terminal b
     , atm_terminal_dynamic d
     , atm_collection c
 where a.id             = b.id
   and d.id          (+)= a.id
   and (b.is_template+0) != 1
   and b.status         = 'TRMS0001'
   and exists(select 1 from cmn_device c where c.is_enabled = 1 and c.id = b.device_id)
   and c.id(+)          = d.coll_id
/
