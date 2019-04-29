create or replace force view iss_ui_bin_vw as
select 
    n.id
    , n.bin
    , n.inst_id
    , n.network_id
    , n.bin_currency
    , n.sttl_currency
    , n.pan_length
    , n.card_type_id
    , n.country
    , n.seqnum
    , get_text (
        i_table_name    => 'iss_bin'
        , i_column_name => 'description'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) description
    , l.lang
from 
    iss_bin n
    , com_language_vw l    
where
    n.inst_id in (select inst_id from acm_cu_inst_vw)
/