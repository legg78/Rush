create table prc_process (
    id                number(8) not null
    , procedure_name  varchar2(200)
    , is_parallel     number(1)
    , inst_id         number(4)
    , is_external     number(1)
    , is_container    number(1)
)
/
comment on table prc_process is 'List of processes'
/
comment on column prc_process.id is 'Process identifier'
/
comment on column prc_process.procedure_name is 'Name of procedure which implements process logic (not applicable for container process)'
/
comment on column prc_process.is_parallel is 'Possibility to run process in parallel threads'
/
comment on column prc_process.inst_id is 'Identifier of owner institution.'
/
comment on column prc_process.is_external is 'Flag external/internal process.'
/
comment on column prc_process.is_container is 'Container indicator.'
/
alter table prc_process add interrupt_threads number(1)
/
comment on column prc_process.interrupt_threads is 'Flag interrupt all the threads in case of a fall of at least one flow. 1 - interrupt, 0 - continue work'
/