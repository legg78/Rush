create index jcb_fin_status_CLMS10_ndx on jcb_fin_message (
    decode(status, 'CLMS0010', de033, null)
)
/****************** partition start ********************
    local
******************** partition end ********************/
/
create index jcb_fin_mti_de024_de031_ndx on jcb_fin_message (mti, de024, de031)
/****************** partition start ********************
    local
******************** partition end ********************/
/
