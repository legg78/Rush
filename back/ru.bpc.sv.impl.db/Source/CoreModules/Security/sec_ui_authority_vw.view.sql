create or replace force view sec_ui_authority_vw as
select
    a.id
    , a.seqnum
    , a.type
    , a.rid
    , get_text (
          i_table_name     => 'sec_authority'
          , i_column_name  => 'name'
          , i_object_id    => a.id
          , i_lang         => l.lang
      ) name
    , l.lang
from
    sec_authority a
    , com_language_vw l
/
