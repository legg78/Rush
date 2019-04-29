create or replace force view net_ui_card_type_vw as
select
    n.id
    , n.seqnum
    , n.parent_type_id
    , n.network_id
    , get_text (
        i_table_name => 'net_card_type'
        , i_column_name => 'name'
        , i_object_id => n.id
        , i_lang => l.lang
      ) as name
    , n.is_virtual
    , l.lang
from
    net_card_type n
    , com_language_vw l
/
