create or replace force view acm_ui_action_groups_vw as
select
    id
    , seqnum
    , entity_type
    , group_id parent_id
    , inst_id
from
    acm_action_vw
where
    group_id is not null
    and inst_id in (select inst_id from acm_cu_inst_vw)
union all
select
    g.id
    , g.seqnum
    , g.entity_type
    , g.parent_id
    , g.inst_id
from
    acm_action_group_vw g
where
    exists ( select 1 from acm_action_vw a where group_id = g.id)
    and g.inst_id in (select inst_id from acm_cu_inst_vw)
/
