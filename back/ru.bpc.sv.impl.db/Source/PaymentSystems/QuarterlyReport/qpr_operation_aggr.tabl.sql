create table qpr_operation_aggr(
    aggr_id number(12)
  , oper_id number(16)
)
/
comment on table qpr_operation_aggr  is 'Aggregate operation data for quarter reports'
/
comment on column qpr_operation_aggr.aggr_id is 'Aggregate data identifier'
/
comment on column qpr_operation_aggr.oper_id is 'Operation ID'
/
