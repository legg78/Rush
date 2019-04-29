create table fcl_limit_buffer
(
    id           number(16)
  , entity_type  varchar2(8)
  , object_id     number(16)
  , limit_type   varchar2(8)
  , count_value  number(16)
  , sum_value    number(22,4)
  , split_hash   number(4)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/

comment on table fcl_limit_buffer is 'Limit counts buffer.'
/

comment on column fcl_limit_buffer.id is 'Primary key.'
/

comment on column fcl_limit_buffer.entity_type is 'Type of business entity (Card, Account, Customer, Institution etc.).'
/

comment on column fcl_limit_buffer.object_id is 'Reference to the object.'
/

comment on column fcl_limit_buffer.limit_type is 'Limit type. Describe destination of limit and using area.'
/

comment on column fcl_limit_buffer.count_value is 'Count value to increase limit counter.'
/

comment on column fcl_limit_buffer.sum_value is 'Sum value to increase limit counter.'
/

comment on column fcl_limit_buffer.split_hash is 'Hash value to split further processing.'
/