create table scr_criteria(
    id            number(12)
  , seqnum        number(4)
  , evaluation_id number(12)
  , order_num     number(4)
)
/

comment on table scr_criteria is 'Criteria for evaluation'
/
comment on column scr_criteria.id is 'Primary key'
/
comment on column scr_criteria.seqnum is 'Sequence number for web'
/
comment on column scr_criteria.evaluation_id is 'Evaluation identifier'
/
comment on column scr_criteria.order_num is 'Order of criteria'
/
