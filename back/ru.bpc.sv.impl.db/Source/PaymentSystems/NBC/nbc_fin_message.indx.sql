create index nbc_fin_message_CLMS0010_ndx on nbc_fin_message (
    decode(status, 'CLMS0010', 'CLMS0010', null)
)
/
create index nbc_fin_message_CLMS0040_ndx on nbc_fin_message (
    decode(status, 'CLMS0040', 'CLMS0040', null)
)
/
create index nbc_fin_original_id_ndx on nbc_fin_message(original_id)
/
