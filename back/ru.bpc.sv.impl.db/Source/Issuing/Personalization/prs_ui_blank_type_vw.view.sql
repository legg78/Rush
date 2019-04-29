create or replace force view prs_ui_blank_type_vw as
select 
    n.id
    , n.card_type_id
    , n.inst_id     
    , n.seqnum      
    , get_text (
        i_table_name    => 'prs_blank_type'
        , i_column_name => 'name'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) description
    , l.lang
from 
    prs_blank_type n
    , com_language_vw l
where
    n.inst_id in (select inst_id from acm_cu_inst_vw)
/
