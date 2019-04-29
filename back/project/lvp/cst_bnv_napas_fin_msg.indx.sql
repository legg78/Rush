create index cst_bnv_napas_fin_msg_load_ndx on cst_bnv_napas_fin_msg(decode(status, 'CLMS0040', 'CLMS0040', null))
/
create index cst_bnv_napas_fin_msg_date_ndx on cst_bnv_napas_fin_msg(trans_date)
/
create index cst_bnv_napas_fin_msg_mtch_ndx on cst_bnv_napas_fin_msg(match_oper_id)
/
