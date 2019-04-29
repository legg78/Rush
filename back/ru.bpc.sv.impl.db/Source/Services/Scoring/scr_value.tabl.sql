create table scr_value(
    id            number(12)
  , seqnum        number(4)
  , criteria_id   number(12)
  , score         number(4)
)
/

comment on table scr_value is 'Values for evaluation'
/
comment on column scr_value.id is 'Primary key'
/
comment on column scr_value.seqnum is 'Sequence number for web'
/
comment on column scr_value.criteria_id is 'Criteria identifier'
/
comment on column scr_value.score is 'Score value'
/
