create table qpr_visa_acq_aggr
(
    id               number(16)
    , oper_date      date
    , param_name     varchar2(100)
    , subparam_name  varchar2(100)
    , group_name     varchar2(100)
)
/
comment on table qpr_visa_acq_aggr  is 'Detailed operation data for quarter reports (VISA acquiring)'
/
comment on column qpr_visa_acq_aggr.id is 'Operation ID'
/
comment on column qpr_visa_acq_aggr.oper_date is 'Operation date'
/
comment on column qpr_visa_acq_aggr.group_name is 'Quarterly report group name'
/
comment on column qpr_visa_acq_aggr.param_name is 'Quarterly report param name'
/
comment on column qpr_visa_acq_aggr.subparam_name is 'Quarterly report subparam name'
/
alter table qpr_visa_acq_aggr add (inst_id number(4))
/
comment on column qpr_visa_acq_aggr.inst_id is 'Institution identifier'
/
