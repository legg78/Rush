create table com_split_map (
    thread_number number(4)
    , split_hash number(4)
)
/
comment on table com_split_map is 'Mapping of splitting hash value into processing thread number'
/
comment on column com_split_map.thread_number is 'Thread number'
/
comment on column com_split_map.split_hash is 'Split hash value'
/
