create table atm_terminal_dynamic (
    id                    number(8)
  , coll_id               number(12)
  , coll_oper_count       number(4)
  , last_oper_id          number(16)
  , last_oper_date        date
  , receipt_loaded        number(4)
  , receipt_printed       number(4)
  , receipt_remained      number(4)
  , card_captured         number(4)
  , card_reader_status    varchar2(8)
  , rcpt_status           varchar2(8)
  , rcpt_paper_status     varchar2(8)
  , rcpt_ribbon_status    varchar2(8)
  , rcpt_head_status      varchar2(8)
  , rcpt_knife_status     varchar2(8)
  , jrnl_status           varchar2(8)
  , jrnl_paper_status     varchar2(8)
  , jrnl_ribbon_status    varchar2(8)
  , jrnl_head_status      varchar2(8)
  , ejrnl_status          varchar2(8)
  , ejrnl_space_status    varchar2(8)
  , stmt_status           varchar2(8)
  , stmt_paper_status     varchar2(8)
  , stmt_ribbon_stat      varchar2(8)
  , stmt_head_status      varchar2(8)
  , stmt_knife_status     varchar2(8)
  , stmt_capt_bin_status  varchar2(8)
  , tod_clock_status      varchar2(8)
  , depository_status     varchar2(8)
  , night_safe_status     varchar2(8)
  , encryptor_status      varchar2(8)
  , tscreen_keyb_status   varchar2(8)
  , voice_guidance_status varchar2(8)
  , camera_status         varchar2(8)
  , bunch_acpt_status     varchar2(8)
  , envelope_disp_status  varchar2(8)
  , cheque_module_status  varchar2(8)
  , barcode_reader_status varchar2(8)
  , coin_disp_status      varchar2(8)
  , dispenser_status      varchar2(8)
  , workflow_status       varchar2(8)
  , service_status        varchar2(8)
)
/
comment on table atm_terminal_dynamic is 'ATM terminal dynamic parameters.'
/

comment on column atm_terminal_dynamic.id is 'Primary key. Value is equal to ACQ_TERMINAL.ID'
/

comment on column atm_terminal_dynamic.coll_id is 'Current collection ID.'
/

comment on column atm_terminal_dynamic.coll_oper_count is 'Operations count in current collection.'
/

comment on column atm_terminal_dynamic.last_oper_id is 'Last operation ID.'
/

comment on column atm_terminal_dynamic.last_oper_date is 'Date of last operation.'
/

comment on column atm_terminal_dynamic.receipt_loaded is 'Count of receipts loaded into terminal.'
/

comment on column atm_terminal_dynamic.receipt_printed is 'Count of printed receipts after last load.'
/

comment on column atm_terminal_dynamic.receipt_remained is 'Count of remained receipts after last load.'
/

comment on column atm_terminal_dynamic.card_captured is 'Count of captured cards.'
/

comment on column atm_terminal_dynamic.card_reader_status is 'Card Reader Status - Ok, Overfill, Error'
/

comment on column atm_terminal_dynamic.rcpt_status is 'Receipt Printer Status - Ok, NotConfigured, SupplyWarning, SupplyError, Error'
/

comment on column atm_terminal_dynamic.rcpt_paper_status is 'Receipt Printer Paper Status - Ok, Low, Exhausted'
/

comment on column atm_terminal_dynamic.rcpt_ribbon_status is 'Receipt Printer Ribbon Status - Ok, OptionalReplacement, MandatoryReplacement'
/

comment on column atm_terminal_dynamic.rcpt_head_status is 'Receipt Printer Print Head Status - Ok, OptionalReplacement, MandatoryReplacement'
/

comment on column atm_terminal_dynamic.rcpt_knife_status is 'Receipt Printer Knife Status - Ok, OptionalReplacement, MandatoryReplacement'
/

comment on column atm_terminal_dynamic.jrnl_status is 'Journal Printer Status - Ok, NotConfigured, SupplyWarning, SupplyError, Error'
/

comment on column atm_terminal_dynamic.jrnl_paper_status is 'Journal Printer Paper Status - Ok, Low, Exhausted'
/

comment on column atm_terminal_dynamic.jrnl_ribbon_status is 'Journal Printer Ribbon Status - Ok, OptionalReplacement, MandatoryReplacement'
/

comment on column atm_terminal_dynamic.jrnl_head_status is 'Journal Printer Print Head Status - Ok, OptionalReplacement, MandatoryReplacement'
/

comment on column atm_terminal_dynamic.ejrnl_status is 'Electronic Journal Printer Status - Ok, NotConfigured, SupplyWarning, SupplyError, Error'
/

comment on column atm_terminal_dynamic.ejrnl_space_status is 'Electronic Journal Log Space Status - Ok, Low, Exhausted'
/

comment on column atm_terminal_dynamic.stmt_status is 'Statement Printer Status - Ok, NotConfigured, SupplyWarning, SupplyError, Error'
/

comment on column atm_terminal_dynamic.stmt_paper_status is 'Statement Printer Paper Status - Ok, Low, Exhausted'
/

comment on column atm_terminal_dynamic.stmt_ribbon_stat is 'Statement Printer Ribbon Status - Ok, OptionalReplacement, MandatoryReplacement'
/

comment on column atm_terminal_dynamic.stmt_head_status is 'Statement Printer Print Head Status - Ok, OptionalReplacement, MandatoryReplacement'
/

comment on column atm_terminal_dynamic.stmt_knife_status is 'Statement_Printer_Knife_Status - Ok, OptionalReplacement, MandatoryReplacement'
/

comment on column atm_terminal_dynamic.stmt_capt_bin_status is 'Statement Printer Capture Bin Status - Ok, Overfill'
/

comment on column atm_terminal_dynamic.tod_clock_status is 'ToD Clock Status - Ok, ClockResetButRunning, ClockHasStopped'
/

comment on column atm_terminal_dynamic.depository_status is 'Depository Status - Ok, Error, Overfill, NotPresent'
/

comment on column atm_terminal_dynamic.night_safe_status is 'Night Safe Depository Status - Ok, Overfill, NotPresent'
/

comment on column atm_terminal_dynamic.encryptor_status is 'Encryptor_Status - Ok, NotConfigured, Error'
/

comment on column atm_terminal_dynamic.tscreen_keyb_status is 'Touch Screen Keyboard Status - Ok, Error, NotPresent'
/

comment on column atm_terminal_dynamic.voice_guidance_status is 'Voice Guidance Status - Ok, Error, NotPresent'
/

comment on column atm_terminal_dynamic.camera_status is 'Camera Status - Ok, SupplyWarning, SupplyError, Error'
/

comment on column atm_terminal_dynamic.bunch_acpt_status is 'Bunch Note Acceptor Status - Ok, NotPresent'
/

comment on column atm_terminal_dynamic.envelope_disp_status is 'Envelope Dispenser Status - Ok, Error, Low, Exhausted, NotPresent'
/

comment on column atm_terminal_dynamic.cheque_module_status is 'Cheque Processing Module Status - Ok, NotPresent'
/

comment on column atm_terminal_dynamic.barcode_reader_status is 'Barcode Reader Status - Ok, Error, NotPresent'
/

comment on column atm_terminal_dynamic.coin_disp_status is 'Coin Dispenser Status - Ok, Error, NotPresent'
/

comment on column atm_terminal_dynamic.dispenser_status is 'Dispenser Status -  Ok, Error, RejectBinOverfill, NotPresent'
/

comment on column atm_terminal_dynamic.workflow_status is 'ATM Workflow Status - Undefined, Idle, Procedure, Operation'
/

comment on column atm_terminal_dynamic.service_status is 'ATM Service Status Undefined, InService, OutOfService'
/
alter table atm_terminal_dynamic add connection_status varchar2(8)
/
comment on column atm_terminal_dynamic.connection_status is 'ATM connection status'
/
alter table atm_terminal_dynamic add (last_synch_date  date)
/
comment on column atm_terminal_dynamic.last_synch_date is 'Last synchronize date'
/
alter table atm_terminal_dynamic add (transaction_serial_number number(8))
/
comment on column atm_terminal_dynamic.transaction_serial_number is 'Transaction serial number'
/
