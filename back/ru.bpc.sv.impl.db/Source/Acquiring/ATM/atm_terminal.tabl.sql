create table atm_terminal (
    id                     number(8)
  , atm_type               varchar2(8)
  , atm_model              varchar2(200)
  , serial_number          varchar2(200)
  , placement_type         varchar2(8)
  , availability_type      varchar2(8)
  , operating_hours        varchar2(200)
  , local_date_gap         number(8)
  , cassette_count         number(4)
  , key_change_algo        varchar2(8)
  , counter_sync_cond      number(4)
  , reject_disp_warn       number(4)
  , disp_rest_warn         number(4)
  , receipt_warn           number(4)
  , card_capture_warn      number(4)
  , note_max_count         number(4)
  , scenario_id            number(4)
  , hopper_count           number(4)
  , manual_synch           varchar2(8)
  , establ_conn_synch      varchar2(8)
  , counter_mismatch_synch varchar2(8)
  , online_in_synch        varchar2(8)
  , online_out_synch       varchar2(8)
  , safe_close_synch       varchar2(8)
  , disp_error_synch       varchar2(8)
  , periodic_synch         varchar2(8)
  , periodic_all_oper      number(1)
  , periodic_oper_count    number(4)
  , cash_in_present        number(1)
  , recycling_present      number(1)
)
/

comment on table atm_terminal is 'ATM terminal static parameters.'
/

comment on column atm_terminal.id is 'Primary key. Value is equal to ACQ_TERMINAL.ID'
/

comment on column atm_terminal.atm_type is 'ATM terminal type - device producer (NCR, Diebold, etc).'
/

comment on column atm_terminal.atm_model is 'Device model in producer specification.'
/

comment on column atm_terminal.serial_number is 'Serial number of device'
/

comment on column atm_terminal.placement_type is 'Terminal placement type (indoors, outdoors).'
/

comment on column atm_terminal.availability_type is 'Terminal availability (public, VIP)'
/

comment on column atm_terminal.operating_hours is 'Operating hours'
/

comment on column atm_terminal.local_date_gap is 'Time gap between local date of terminal and server date (in seconds negative or positive)'
/

comment on column atm_terminal.cassette_count is 'Count of cassettes.'
/

comment on column atm_terminal.key_change_algo is 'Algorithm of key change.'
/

comment on column atm_terminal.counter_sync_cond is 'Counters synchronization condition.'
/

comment on column atm_terminal.reject_disp_warn is 'Reject dispenser warnings limit.'
/

comment on column atm_terminal.disp_rest_warn is 'Dispenser rest warnings limit.'
/

comment on column atm_terminal.receipt_warn is 'Reciept rest warnings limit.'
/

comment on column atm_terminal.card_capture_warn is 'Captured cards warnings limit.'
/

comment on column atm_terminal.note_max_count is 'Maximum count of notes dispenser could give out per time.'
/

comment on column atm_terminal.scenario_id is 'ATM scenario identifier.'
/

comment on column atm_terminal.hopper_count is 'Coins dispenser count.'
/

comment on column atm_terminal.manual_synch is 'Manual synchronization mode'
/

comment on column atm_terminal.establ_conn_synch is 'Establish of communication synchronization mode'
/

comment on column atm_terminal.counter_mismatch_synch is 'Counter mismatch (between terminal and host) synchronization mode'
/

comment on column atm_terminal.online_in_synch is 'Online in synchronization mode'
/

comment on column atm_terminal.online_out_synch is 'Online out synchronization mode'
/

comment on column atm_terminal.safe_close_synch is 'Closing safe door synchronization mode'
/

comment on column atm_terminal.disp_error_synch is 'Dispenser error synchronization mode'
/

comment on column atm_terminal.periodic_synch is 'Periodic synchronization mode'
/

comment on column atm_terminal.periodic_all_oper is 'Count all operations for periodic synchronization mode (1 - all operations, 0 - only withdrawals)'
/

comment on column atm_terminal.periodic_oper_count is 'Operations count for periodic synchronization mode'
/

comment on column atm_terminal.cash_in_present is 'CashIn device present flag (1 - present, 0 - not present)'
/

comment on column atm_terminal.recycling_present is 'Recycling function present flag (1 - present, 0 - not present)'
/

alter table atm_terminal add (
    reject_disp_min_warn    number(4),
    cash_in_min_warn        number(4),
    cash_in_max_warn        number(4)
)
/

comment on column atm_terminal.reject_disp_min_warn is 'Reject dispenser min limit for warnings'
/

comment on column atm_terminal.cash_in_min_warn is 'CashIn min limit for warnings'
/

comment on column atm_terminal.cash_in_max_warn is 'CashIn max limit'
/

alter table atm_terminal add (machine_number varchar2(6))
/

comment on column atm_terminal.machine_number is 'Machine number. This is not the number used within messages send to the host. This number can be entered within the function ENTER MAC'
/
alter table atm_terminal add (powerup_service varchar2(8), supervisor_service varchar2(8))
/
comment on column atm_terminal.powerup_service is 'Returned to service after restart (ATMM dictionary)'
/
comment on column atm_terminal.supervisor_service is 'Returned to service after leaving the supervisor (ATMM dictionary)'
/

alter table atm_terminal add (dispense_algo varchar2(8))
/
comment on column atm_terminal.dispense_algo is 'Dispense algorithm (ATMD dictionary)'
/

comment on column atm_terminal.reject_disp_warn is 'Reject dispenser''s overflow limit'
/
comment on column atm_terminal.reject_disp_min_warn is 'Reject dispenser''s warning limit'
/

alter table atm_terminal modify (counter_sync_cond varchar2(8))
/
