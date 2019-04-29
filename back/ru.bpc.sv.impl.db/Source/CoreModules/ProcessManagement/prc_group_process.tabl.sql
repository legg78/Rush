create table prc_group_process (
    id            number(8) not null
    , group_id    number(4)
    , process_id  number(8)
)
/
comment on table prc_group_process is 'Contents of group of processes'
/
comment on column prc_group_process.id is 'Record identifier'
/
comment on column prc_group_process.group_id is 'Group identifier'
/
comment on column prc_group_process.process_id is 'Process identifier'
/
