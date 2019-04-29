create table com_partition_table(
    id                   number(4)
  , seqnum               number(4)
  , table_name           varchar2(30)
  , id_column_name       varchar2(30)
  , date_column_name     varchar2(30)
  , partition_cycle_id   number(8)
  , storage_cycle_id     number(8)
  , next_partition_date  date
)
/

comment on table com_partition_table is 'List of transactional tables.'
/

comment on column com_partition_table.id is 'Primary key.'
/

comment on column com_partition_table.seqnum is 'Sequential number or record version.'
/

comment on column com_partition_table.table_name is 'Table name.'
/

comment on column com_partition_table.id_column_name is 'Primary key column name.'
/

comment on column com_partition_table.date_column_name is 'Date column name.'
/

comment on column com_partition_table.partition_cycle_id is 'Cycle identifier using for calculating partitioning interval.'
/

comment on column com_partition_table.storage_cycle_id is 'Cycle identifier using for calculating data storage interval.'
/

comment on column com_partition_table.next_partition_date is 'Date when next partition will be created.'
/

alter table com_partition_table drop column id_column_name
/
alter table com_partition_table drop column date_column_name
/
