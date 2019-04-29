create table com_partition(
    id              number(8)
  , table_name      varchar2(30)
  , partition_name  varchar2(30)
  , id_value        number(16)
  , date_value      date
)
/

comment on table com_partition is 'Atomatic created partitions in transactional tables.'
/

comment on column com_partition.id is 'Primary key.'
/

comment on column com_partition.table_name is 'Table name.'
/

comment on column com_partition.partition_name is 'Automatic generated partition name. Consist of table name and upper date value in format ''YYYYMMDD''.'
/

comment on column com_partition.id_value is 'Upper identifier value.'
/

comment on column com_partition.date_value is 'Upper data value.'
/

alter table com_partition drop column id_value
/
alter table com_partition drop column date_value
/
alter table com_partition add (start_date date, end_date date, drop_date date)
/
comment on column com_partition.start_date is 'Partition start date.'
/
comment on column com_partition.end_date is 'Partition end date.'
/
comment on column com_partition.drop_date is 'Partition drop date.'
/
