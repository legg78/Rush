create table scr_grade(
    id            number(12)
  , seqnum        number(4)
  , evaluation_id number(12)
  , total_score   number(4)
  , grade         varchar2(100)
)
/

comment on table scr_grade is 'Scoring for evaluation'
/
comment on column scr_grade.id is 'Primary key'
/
comment on column scr_grade.seqnum is 'Sequence number for web'
/
comment on column scr_grade.evaluation_id is 'Evaluation identifier'
/
comment on column scr_grade.total_score is 'Required score level to obtain current grade'
/
comment on column scr_grade.total_score is 'Grade (credit limit, for example)'
/
