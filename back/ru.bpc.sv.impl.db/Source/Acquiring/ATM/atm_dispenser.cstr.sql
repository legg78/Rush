alter table atm_dispenser add constraint atm_dispenser_pk primary key(id)
/

alter table atm_dispenser add constraint atm_dispenser_uk unique(terminal_id, disp_number)
/