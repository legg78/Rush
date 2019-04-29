create index cup_fin_message_CLMS0010_ndx on cup_fin_message (decode(status, 'CLMS0010', 'CLMS0010', null))
/
create index cup_fin_message_CLMS0160_ndx on cup_fin_message (decode(status, 'CLMS0160', 'CLMS0160', null))
/
drop index cup_fin_message_CLMS0160_ndx
/
create index cup_fin_message_sys_trace_ndx on cup_fin_message (sys_trace_num)
/
