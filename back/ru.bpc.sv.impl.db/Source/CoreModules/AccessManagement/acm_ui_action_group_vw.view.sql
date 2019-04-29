create or replace force view acm_ui_action_group_vw as
select
    n.id
    , n.seqnum
    , n.entity_type
    , n.parent_id
    , n.inst_id
    , get_text (
        i_table_name    => 'acm_action_group'
        , i_column_name => 'label'
        , i_object_id   => n.id
        , i_lang        => l.lang
      ) label
    , l.lang
from
    acm_action_group n
    , com_language_vw l
where
    n.inst_id in (select inst_id from acm_cu_inst_vw)
/
