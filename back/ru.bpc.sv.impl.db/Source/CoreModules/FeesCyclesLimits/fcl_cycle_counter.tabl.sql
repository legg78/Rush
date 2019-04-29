create table fcl_cycle_counter (
    id               number(16)
    , entity_type    varchar2(8)
    , object_id      number(16)
    , cycle_type     varchar2(8)
    , prev_date      date
    , next_date      date
    , period_number  number(4)
    , split_hash     number(4)
    , inst_id        number(4)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/
comment on table fcl_cycle_counter is 'Cycle counters.'
/
comment on column fcl_cycle_counter.id is 'Primary key.'
/
comment on column fcl_cycle_counter.entity_type is 'Type of business entity (Card, Account, Customer, Institution etc.).'
/
comment on column fcl_cycle_counter.object_id is 'Reference to the object.'
/
comment on column fcl_cycle_counter.cycle_type is 'Type of cycle.  Describe destination and using area.'
/
comment on column fcl_cycle_counter.prev_date is 'Previous cycle date.'
/
comment on column fcl_cycle_counter.next_date is 'Next cycle date.'
/
comment on column fcl_cycle_counter.period_number is 'Cycle period number.'
/
comment on column fcl_cycle_counter.split_hash is 'Hash value to split further processing.'
/
comment on column fcl_cycle_counter.inst_id is 'Institution id cycle counter is defined for'
/
