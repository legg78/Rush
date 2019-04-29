create or replace force view opr_ui_match_lvl_condition_vw as
select
    c.id
    , c.level_id
    , c.condition_id
    , c.seqnum
from
    opr_match_level_condition c
/