alter table rcn_atm_msg add constraint rcn_atm_msg_pk primary key (id)
/
alter table rcn_atm_msg add constraint rcn_atm_msg_oper_id_uk unique (operation_id)
/
