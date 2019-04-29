create table opr_match_level_condition (
    id              number(4) not null
    , level_id      number(4)
    , condition_id  number(4)
    , seqnum        number(4)
)
/
comment on table opr_match_level_condition is 'Conditions defined for matching level'
/
comment on column opr_match_level_condition.id is 'Association identifier'
/
comment on column opr_match_level_condition.level_id is 'Matching level identifier'
/
comment on column opr_match_level_condition.condition_id is 'Condition identifier'
/
comment on column opr_match_level_condition.seqnum is 'Sequential version of data'
/
