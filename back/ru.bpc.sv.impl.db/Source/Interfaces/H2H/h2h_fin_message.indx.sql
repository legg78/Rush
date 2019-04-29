create index h2h_fin_message_load_ndx on h2h_fin_message(decode(status, 'CLMS0040', 'CLMS0040', null))
/
drop index h2h_fin_message_load_ndx
/
create index h2h_fin_message_CLMS0010_ndx on h2h_fin_message(decode(status, 'CLMS0010', 'CLMS0010', null))
/
create index h2h_fin_message_oper_id_ndx on h2h_fin_message(oper_id)
/
