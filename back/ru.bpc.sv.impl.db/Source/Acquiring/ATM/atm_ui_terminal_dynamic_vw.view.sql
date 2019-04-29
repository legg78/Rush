create or replace force view atm_ui_terminal_dynamic_vw
as
select 
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
  , connection_status
  , last_synch_date
from atm_terminal_dynamic
/