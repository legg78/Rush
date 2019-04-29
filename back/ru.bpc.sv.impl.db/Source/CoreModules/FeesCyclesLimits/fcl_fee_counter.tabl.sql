create table fcl_fee_counter (
    id                  number(16)
    , fee_type          varchar2(8)
    , entity_type       varchar2(8)
    , object_id         number(16)
    , start_date        date
    , end_date          date
    , split_hash        number(4)
    , inst_id           number(4)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/
comment on table fcl_fee_counter is 'History of servicing fees activity. Using for periodic fees calculation.'
/
comment on column fcl_fee_counter.id is 'Primary key.'
/
comment on column fcl_fee_counter.fee_type is 'Cyclic fee type.'
/
comment on column fcl_fee_counter.entity_type is 'Type of business entity (Card, Account, Customer, Institution etc.).'
/
comment on column fcl_fee_counter.object_id is 'Reference to the object.'
/
comment on column fcl_fee_counter.start_date is 'Date when fee became active.'
/
comment on column fcl_fee_counter.end_date is 'Date when fee became inactive.'
/
comment on column fcl_fee_counter.split_hash is 'Hash value to split further processing.'
/
comment on column fcl_fee_counter.inst_id is 'Institution id fee counter is defined for'
/
