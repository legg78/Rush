create index cmp_fin_message_CLMS0010_ndx on cmp_fin_message (
    decode(status, 'CLMS0010', 'CLMS0010', null)
)
/
create index cmp_fin_message_CLMS0160_ndx on cmp_fin_message (decode(status, 'CLMS0160', 'CLMS0160', null))
/
