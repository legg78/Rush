create table opr_match_condition (
    id              number(4) not null
    , inst_id       number(4)
    , condition     varchar2(200)
    , seqnum        number(4)
)
/
comment on table opr_match_condition is 'List of usable conditions for matching'
/
comment on column opr_match_condition.id is 'Condition identifier'
/
comment on column opr_match_condition.inst_id is 'Owner institution identifier'
/
comment on column opr_match_condition.condition is 'Condition (as SQL where clause part)'
/
comment on column opr_match_condition.seqnum is 'Sequential version of data'
/


alter table opr_match_condition modify(condition varchar2(1000))
/