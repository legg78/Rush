alter table rcn_host_msg add constraint rcn_host_msg_pk primary key (id)
/
alter table rcn_host_msg add constraint rcn_host_msg_sv_uk unique (oper_id)
/
alter table rcn_host_msg add constraint rcn_host_msg_host_uk unique (auth_code, recon_inst_id, originator_refnum, msg_type, oper_type, oper_date, merchant_number, terminal_number)
/
alter table rcn_host_msg drop constraint rcn_host_msg_host_uk
/
alter table rcn_host_msg add constraint rcn_host_msg_host_uk unique (auth_code, recon_inst_id, originator_refnum, msg_type, oper_type, oper_date, merchant_number, terminal_number, msg_source, is_reversal)
/
alter table rcn_host_msg drop constraint rcn_host_msg_host_uk
/
alter table rcn_host_msg add constraint rcn_host_msg_host_uk unique (approval_code, recon_inst_id, rrn, msg_type, oper_type, oper_date, merchant_number, terminal_number, msg_source, is_reversal)
/
