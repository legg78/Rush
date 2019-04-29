create table fcl_limit_counter (
    id                    number(16)
    , entity_type         varchar2(8)
    , object_id           number(16)
    , limit_type          varchar2(8)
    , count_value         number(16)
    , sum_value           number(22,4)
    , prev_count_value    number(16)
    , prev_sum_value      number(22,4)
    , last_reset_date     date
    , split_hash          number(4)
    , inst_id             number(4)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/
comment on table fcl_limit_counter is 'Limit counters.'
/
comment on column fcl_limit_counter.id is 'Primary key.'
/
comment on column fcl_limit_counter.entity_type is 'Type of business entity (Card, Account, Customer, Institution etc.).'
/
comment on column fcl_limit_counter.object_id is 'Reference to the object.'
/
comment on column fcl_limit_counter.limit_type is 'Limit type. Describe destination of limit and using area.'
/
comment on column fcl_limit_counter.count_value is 'Limit counter. Zero when new cycle started.'
/
comment on column fcl_limit_counter.sum_value is 'Sum value. Zero when new cycle started.'
/
comment on column fcl_limit_counter.prev_count_value is 'Count value before last reset.'
/
comment on column fcl_limit_counter.prev_sum_value is 'Sum value before last reset.'
/
comment on column fcl_limit_counter.last_reset_date is 'Date of last counter reset.'
/
comment on column fcl_limit_counter.split_hash is 'Hash value to split further processing.'
/
comment on column fcl_limit_counter.inst_id is 'Institution id limit counter is defined for'
/
