create table opr_match_level (
    id              number(4) not null
    , inst_id       number(4)
    , priority      number(4)
    , seqnum        number(4)
)
/
comment on table opr_match_level is 'Matching levels'
/
comment on column opr_match_level.id is 'Level identifier'
/
comment on column opr_match_level.inst_id is 'Owner institution identifier'
/
comment on column opr_match_level.priority is 'Priority of level within institution'
/
comment on column opr_match_level.seqnum is 'Sequential version of data'
/
