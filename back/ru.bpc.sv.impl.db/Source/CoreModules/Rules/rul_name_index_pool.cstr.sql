alter table rul_name_index_pool add constraint rul_name_index_pool_pk primary key (id)
/
alter table rul_name_index_pool add constraint rul_name_index_pool_un unique(index_range_id, value)
/
