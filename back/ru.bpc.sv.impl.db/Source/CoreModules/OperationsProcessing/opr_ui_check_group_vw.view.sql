create or replace force view opr_ui_check_group_vw as
select 
    n.id
    , n.seqnum
    , get_text (
        i_table_name    => 'opr_check_group'
        , i_column_name => 'name'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) name
    , get_text (
        i_table_name    => 'opr_check_group'
        , i_column_name => 'description'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) description
    , l.lang
from 
    opr_check_group_vw n
    , com_language_vw l
/
