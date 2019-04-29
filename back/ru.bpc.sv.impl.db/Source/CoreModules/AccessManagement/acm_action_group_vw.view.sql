create or replace force view acm_action_group_vw as
select
    id
    , seqnum
    , entity_type
    , parent_id
    , inst_id
from
    acm_action_group
/
