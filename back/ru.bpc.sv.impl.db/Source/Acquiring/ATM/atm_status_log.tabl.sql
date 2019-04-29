create table atm_status_log(
    terminal_id         number(8)
  , status              varchar2(8)
  , change_date         date
  , atm_part_type       varchar2(8)
)
/

comment on table atm_status_log is 'ATM''s parts status history'
/

comment on column atm_status_log.terminal_id is 'Reference to terminal'
/

comment on column atm_status_log.status is 'Status of ATM''s part'
/

comment on column atm_status_log.change_date is 'Date of status change'
/

comment on column atm_status_log.atm_part_type is 'ATM''s part type'
/

