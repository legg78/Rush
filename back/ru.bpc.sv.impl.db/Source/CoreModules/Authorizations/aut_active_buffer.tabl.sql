create table aut_active_buffer (
    active_buffer_num                  number(4) not null
)
/

comment on table aut_active_buffer is 'Active buffer for authorizations exchange'
/
comment on column aut_active_buffer.active_buffer_num is 'Number of active buffer for authorizations exchange'
/

