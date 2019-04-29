create index cst_itmx_fin_mess_CLMS0010_ndx on cst_itmx_fin_message (
    decode(status, 'CLMS0010', 'CLMS0010', null)
)
/
