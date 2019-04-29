create or replace force view hsm_ui_lmk_vw as
select 
    n.id
    , n.seqnum
    , n.check_value
    , get_text (
        i_table_name    => 'hsm_lmk'
        , i_column_name => 'name'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) description
    , l.lang
from 
    hsm_lmk n
    , com_language_vw l
/
