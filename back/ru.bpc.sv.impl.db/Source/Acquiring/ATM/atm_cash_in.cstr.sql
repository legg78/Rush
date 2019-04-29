alter table atm_cash_in add constraint atm_cash_in_pk primary key (id)
/
alter table atm_cash_in add constraint atm_cash_in_un unique (terminal_id, denomination_code)
/
