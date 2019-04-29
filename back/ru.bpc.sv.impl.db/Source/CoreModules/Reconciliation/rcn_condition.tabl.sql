create table rcn_condition (
    id                        number(4)
  , name                      varchar2(200)
  , inst_id                   number(4)
  , recon_type                varchar2(8)
  , condition                 varchar2(2000)
  , condition_type            varchar2(8)
  , seqnum                    number(4)
)
/
comment on table rcn_condition is 'Reconciliation conditions'
/
comment on column rcn_condition.id is 'Record identifier'
/
comment on column rcn_condition.name is 'Condition name.'
/
comment on column rcn_condition.inst_id is 'Owner institution identifier.'
/
comment on column rcn_condition.recon_type is 'Reconciliation type. (Dictionary "RCNT").'
/
comment on column rcn_condition.condition is 'Condition (as SQL where clause part).'
/
comment on column rcn_condition.condition_type is 'Type of condition. (Dictionary "RCTP").'
/
comment on column rcn_condition.seqnum is 'Sequence number. Describe data version.'
/
alter table rcn_condition drop column name
/
alter table rcn_condition add (provider_id number(8))
/
alter table rcn_condition add (purpose_id number(8))
/
