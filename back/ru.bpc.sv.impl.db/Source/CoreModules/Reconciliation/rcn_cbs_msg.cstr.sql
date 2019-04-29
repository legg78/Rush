alter table rcn_cbs_msg add constraint rcn_cbs_msg_pk primary key (id) -- [@skip patch]
/
alter table rcn_cbs_msg add constraint rcn_cbs_msg_sv_uk unique (oper_id)
/
alter table rcn_cbs_msg add constraint rcn_cbs_msg_cbs_uk unique (auth_code, recon_inst_id, originator_refnum, msg_type, oper_type, oper_date, merchant_number, terminal_number)
/
alter table rcn_cbs_msg drop constraint rcn_cbs_msg_cbs_uk
/
alter table rcn_cbs_msg add constraint rcn_cbs_msg_cbs_uk unique (auth_code, recon_inst_id, originator_refnum, msg_type, oper_type, oper_date, merchant_number, terminal_number, msg_source)
/
alter table rcn_cbs_msg drop constraint rcn_cbs_msg_cbs_uk
/
alter table rcn_cbs_msg add constraint rcn_cbs_msg_cbs_uk unique (auth_code, recon_inst_id, originator_refnum, msg_type, oper_type, oper_date, merchant_number, terminal_number, msg_source, is_reversal)
/
