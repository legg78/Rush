create table fcl_cycle
(
    id            number(8)
  , seqnum        number(4)
  , cycle_type    varchar2(8)
  , length_type   varchar2(8)
  , cycle_length  number(4)
  , trunc_type    varchar2(8)
  , inst_id       number(4)
)
/

comment on table fcl_cycle is 'Cycles defined in the system.'
/

comment on column fcl_cycle.id is 'Primary key.'
/

comment on column fcl_cycle.seqnum is 'Sequence number. Describe data version.'
/

comment on column fcl_cycle.cycle_type is 'Type of cycle.  Describe destination and using area.'
/

comment on column fcl_cycle.length_type is 'Date calculation unit (Year, Month, Week, Day).'
/

comment on column fcl_cycle.cycle_length is 'Cycle length in defined units.'
/

comment on column fcl_cycle.trunc_type is 'Describe type of truncate start date. Calculate cycle from first day of start date (year, month, week, day) or from start date (none).'
/

comment on column fcl_cycle.inst_id is 'Institution ID cycle is defined for.'
/

alter table fcl_cycle add (workdays_only number(1))
/

comment on column fcl_cycle.workdays_only is 'Flag calculation cycle in working days'
/
