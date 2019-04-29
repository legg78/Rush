create index mcw_fin_status_CLMS10_ndx on mcw_fin (
    decode(status, 'CLMS0010', de033, null)
)
/****************** partition start ********************
    local
******************** partition end ********************/
/
create index mcw_fin_mti_de024_de031_ndx on mcw_fin (mti, de024, de031)
/****************** partition start ********************
    local
******************** partition end ********************/
/
create index mcw_fin_sttl_date_ndx on mcw_fin (p0159_8)
/
create index mcw_fpd_id_ndx on mcw_fin (fpd_id)
/
create index mcw_fin_de071_file_network_ndx on mcw_fin (de071, file_id, network_id)
/
create index mcw_fin_dispute_id_ndx on mcw_fin(dispute_id)
/

drop index mcw_fin_de071_file_network_ndx
/
create index mcw_fin_file_network_de071_ndx on mcw_fin (file_id, network_id, de071)
/
create index mcw_fin_p0375_ndx on mcw_fin(p0375)
/
create index mcw_fin_fsum_id_ndx on mcw_fin(fsum_id)
/
create index mcw_fin_status_de094_ndx on mcw_fin (
    decode(status, 'CLMS0010', de094, null)
)
/****************** partition start ********************
    local
******************** partition end ********************/
/
create index mcw_fin_ext_claim_msg_id_ndx on mcw_fin (ext_claim_id, ext_message_id)
/
