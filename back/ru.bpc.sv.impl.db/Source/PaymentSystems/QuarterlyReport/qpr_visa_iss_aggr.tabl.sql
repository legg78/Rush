create table qpr_visa_iss_aggr
(
    id              number(16)
    , oper_date     date
    , card_type_id  number(4)
    , param_name    varchar2(100)
    , group_name    varchar2(100)
)
/
comment on table qpr_visa_iss_aggr  is 'Detailed operation data for quarter reports (VISA issuing)'
/
comment on column qpr_visa_iss_aggr.id is 'Operation ID'
/
comment on column qpr_visa_iss_aggr.oper_date is 'Operation date'
/
comment on column qpr_visa_iss_aggr.card_type_id is 'Card type identifier'
/
comment on column qpr_visa_iss_aggr.group_name is 'Quarterly report group name'
/
comment on column qpr_visa_iss_aggr.param_name is 'Quarterly report param name'
/
alter table qpr_visa_iss_aggr add (inst_id number(4))
/
comment on column qpr_visa_iss_aggr.inst_id is 'Institution identifier'
/
