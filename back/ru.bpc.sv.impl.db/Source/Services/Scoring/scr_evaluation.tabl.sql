create table scr_evaluation(
    id          number(12)
  , seqnum      number(4)  
)
/ 

comment on table scr_evaluation is 'Scoring table'
/
comment on column scr_evaluation.id is 'Primary key'
/
comment on column scr_evaluation.seqnum is 'Sequence number for web'
/
alter table scr_evaluation add inst_id number(4)
/
