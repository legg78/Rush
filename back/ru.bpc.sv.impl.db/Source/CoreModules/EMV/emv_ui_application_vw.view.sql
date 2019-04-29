create or replace force view emv_ui_application_vw as
select 
    n.id
    , n.seqnum
    , n.aid
    , n.mod_id
    , n.id_owner
    , n.appl_scheme_id
    , get_text (
        i_table_name    => 'emv_application'
        , i_column_name => 'name'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) name
    , l.lang
    , n.pix
from 
    emv_application n
    , com_language_vw l
/
