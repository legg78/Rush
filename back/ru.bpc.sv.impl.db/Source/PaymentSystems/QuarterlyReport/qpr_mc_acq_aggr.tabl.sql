create table qpr_mc_acq_aggr
(
    id            number(16)
    , oper_date   date
    , group_name  varchar2(100)
    , param_name  varchar2(100)
)
/
comment on table qpr_mc_acq_aggr  is 'Detailed operation data for quarter reports (MasterCard acquiring)'
/
comment on column qpr_mc_acq_aggr.id is 'Operation ID'
/
comment on column qpr_mc_acq_aggr.oper_date is 'Operation date'
/
comment on column qpr_mc_acq_aggr.group_name is 'Quarterly report group name'
/
comment on column qpr_mc_acq_aggr.param_name is 'Quarterly report param name'
/
alter table qpr_mc_acq_aggr add (inst_id number(4))
/
comment on column qpr_mc_acq_aggr.inst_id is 'Institution identifier'
/
 