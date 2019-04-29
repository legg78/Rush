create table rul_name_index_pool (
      id                number(16)
    , index_range_id    number(8)
    , value             number(16)
    , is_used           number(1)
)
/
comment on table rul_name_index_pool is 'Pool of index values for name generation'
/
comment on column rul_name_index_pool.id is 'Value identifier'
/
comment on column rul_name_index_pool.index_range_id is 'Index range identifier'
/
comment on column rul_name_index_pool.value is 'Index value'
/
comment on column rul_name_index_pool.is_used is 'Is used'
/
alter table rul_name_index_pool add partition_key number(6)
/
comment on column rul_name_index_pool.partition_key is 'Partition key'
/
alter table rul_name_index_pool modify value number(24) --[@skip patch]
/
