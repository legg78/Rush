create index mup_fin_status_CLMS10_ndx on mup_fin (decode(status, 'CLMS0010', de033, null))
/****************** partition start ********************
    local
******************** partition end ********************/
/
create index mup_fin_mti_de024_de031_ndx on mup_fin (mti, de024, de031)
/****************** partition start ********************
    local
******************** partition end ********************/
/
create index mup_fin_sttl_date_ndx on mup_fin (p2159_6)
/
create index mup_fpd_id_ndx on mup_fin (fpd_id)
/
create index mup_fin_de071_file_network_ndx on mup_fin (de071, file_id, network_id)
/
create index mup_fin_p0375_ndx on mup_fin (p0375)
/
create index mup_fin_rrn_ndx on mup_fin (de037)
/
create index mup_fin_is_collection_ndx on mup_fin (nvl(is_collection, 0))
/****************** partition start ********************
    local
******************** partition end ********************/
/
drop index mup_fin_de071_file_network_ndx
/
create index mup_fin_file_network_de071_ndx on mup_fin (file_id, network_id, de071)
/
