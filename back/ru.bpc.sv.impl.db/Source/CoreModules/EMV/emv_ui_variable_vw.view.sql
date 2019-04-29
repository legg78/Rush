create or replace force view emv_ui_variable_vw as
select 
    n.id
    , n.seqnum
    , n.application_id
    , n.variable_type
    , n.profile
    , get_text (
        i_table_name    => 'emv_variable'
        , i_column_name => 'name'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) name
    , l.lang
from 
    emv_variable n
    , com_language_vw l
/
