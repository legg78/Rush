create table opr_oper_detail(
    id           number      not null
  , oper_id      number(16)  not null
  , object_id    number
  , entity_type  varchar2(8)
)
/****************** partition start ********************
partition by range(oper_id) interval(1000000000000)
(
    partition opr_oper_detail_p01 values less than (1801010000000000)
)
******************** partition end ********************/
/
comment on table opr_oper_detail is 'Operation details'
/
comment on column opr_oper_detail.id is 'Primary key'
/
comment on column opr_oper_detail.oper_id is 'Operation identifier'
/
comment on column opr_oper_detail.object_id is 'Object identifier'
/
comment on column opr_oper_detail.entity_type is 'Entity type of related object'
/
