create index tie_fin_status_CLMS10_ndx on tie_fin (
    decode(status, 'CLMS0010', inst_id, null)
)
/****************** partition start ********************
    local
******************** partition end ********************/
/
