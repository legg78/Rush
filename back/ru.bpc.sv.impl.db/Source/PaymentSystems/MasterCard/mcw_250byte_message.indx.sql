create index mcw_250byte_msg_CLMS0010_ndx on mcw_250byte_message (
    decode(status, 'CLMS0010', 'CLMS0010', null)
)
/

