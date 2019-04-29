create or replace force view atm_ui_terminal_vw as
select t.id
     , t.atm_type
     , t.atm_model
     , t.serial_number
     , t.placement_type
     , t.availability_type
     , t.operating_hours
     , t.local_date_gap
     , t.cassette_count
     , t.key_change_algo
     , t.dispense_algo
     , t.counter_sync_cond
     , t.reject_disp_warn -- Reject dispenser's overflow limit
     , t.disp_rest_warn
     , t.receipt_warn
     , t.card_capture_warn
     , t.note_max_count
     , t.scenario_id
     , t.hopper_count
     , t.manual_synch
     , t.establ_conn_synch
     , t.counter_mismatch_synch
     , t.online_in_synch
     , t.online_out_synch
     , t.safe_close_synch
     , t.disp_error_synch
     , t.periodic_synch
     , t.periodic_all_oper
     , t.periodic_oper_count
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
     , nvl(d.service_status, 'ASSTUNDF') service_status
     , decode(nvl(d.service_status, 'ASSTUNDF'), 'ASSTUNDF', 0, 1) conn_status
     , o.standard_id
     , get_text (
         'cmn_standard'
         , 'label'
         , o.standard_id
         , l.lang
     ) standard_name
     , atm_ui_terminal_pkg.get_technical_status (
         i_terminal_id  => t.id
         , i_lang       => l.lang
     ) tech_status
     , atm_ui_terminal_pkg.get_financial_status (
         i_terminal_id  => t.id
         , i_lang       => l.lang
     ) finance_status
     , atm_ui_terminal_pkg.get_expendable_status (
         i_terminal_id  => t.id
         , i_lang       => l.lang
     ) consumables_status
     , a.inst_id
     , com_api_address_pkg.get_address_string (acq_api_terminal_pkg.get_terminal_address_id(t.id, l.lang)) atm_address
     , (sysdate + t.local_date_gap / 86400) atm_date
     , 0 work_time
     , t.cash_in_present
     , b.communication_plugin
     , e.remote_address
     , e.local_port
     , e.remote_port
     , e.initiator
     , e.format
     , e.keep_alive
     , b.is_enabled
     , e.monitor_connection
     , e.multiple_connection
     , c.agent_id
     , l.lang
     , a.terminal_number
     , t.reject_disp_min_warn -- Reject dispenser's warning limit
     , t.cash_in_min_warn
     , t.cash_in_max_warn
     , t.machine_number
     , a.merchant_id
     , m.merchant_number
     , t.powerup_service
     , t.supervisor_service
     , d.connection_status
     , ost_ui_agent_pkg.get_agent_name(c.agent_id, l.lang) agent_name
     , ost_ui_agent_pkg.get_agent_number(c.agent_id) agent_number
     , d.last_synch_date
     , m.risk_indicator
from
      atm_terminal t
      , atm_terminal_dynamic d
      , cmn_standard_object o
      , acq_terminal a
      , prd_contract c
      , com_language_vw l
      , acq_merchant m 
      , cmn_device b
      , cmn_tcp_ip e
where t.id = d.id(+)
  and a.id = t.id
  and c.id = a.contract_id
  and b.id(+) = a.device_id
  and o.object_id = t.id
  and o.entity_type = 'ENTTTRMN'
  and e.id(+) = b.id
  and m.id = a.merchant_id
/
