create index cst_bof_ghp_fin_msg_arn_ndx on cst_bof_ghp_fin_msg(arn)
/
create index cst_bof_ghp_fin_msg_stat_ndx on cst_bof_ghp_fin_msg (decode(status, 'CLMS0010', 'CLMS0010', null))
/
create index cst_bof_ghp_fin_msg_dsp_id_ndx on cst_bof_ghp_fin_msg(dispute_id)
/
