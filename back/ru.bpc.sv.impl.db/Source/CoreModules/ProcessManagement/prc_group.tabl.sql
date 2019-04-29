create table prc_group (
    id                number(4) not null
    , semaphore_name  varchar2(30)
)
/
comment on table prc_group is 'Groups of processes stored here'
/
comment on column prc_group.id is 'Group identifier'
/
comment on column prc_group.semaphore_name is 'Semaphore name (to avoid simultaneous run)'
/
