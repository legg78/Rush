create or replace force view net_member_interchange_vw as
select 
    n.id
    , n.seqnum
    , n.mod_id
    , n.value
    , get_text (
        i_table_name    => 'net_member_interchange'
        , i_column_name => 'name'
        , i_object_id   => n.id
        , i_lang        => l.lang
    ) name
    , l.lang
from 
    net_member_interchange n
    , com_language_vw l
/
