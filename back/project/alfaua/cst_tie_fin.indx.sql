create index cst_tie_fin_status_CLMS10_ndx on cst_tie_fin (
    decode(status, 'CLMS0010', inst_id, null)
)
/
