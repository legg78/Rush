create table prc_container(
    id                      number(8) not null
    , container_process_id  number(8)
    , process_id            number(8)
    , exec_order            number(4)
    , is_parallel           number(1)
    , error_limit           number(4)
    , track_threshold       number(4)
)
/

comment on table prc_container is 'Container processes are built here.'
/
comment on column prc_container.id is 'Record identifier.'
/
comment on column prc_container.container_process_id is 'Container process identifier.'
/
comment on column prc_container.process_id is 'Identifier of component process (child process).'
/
comment on column prc_container.exec_order is 'Order of execution of process within container.'
/
comment on column prc_container.is_parallel is 'Instruction to run process in parallel threads.'
/
comment on column prc_container.error_limit is 'Number of errors as a percentage, after which the process is aborted and marked as failed.'
/
comment on column prc_container.track_threshold is 'Amount of processed data, after which begins tracking the number of errors.'
/
alter table prc_container add parallel_degree number(4)
/
comment on column prc_container.parallel_degree is 'Parallel degree'
/
alter table prc_container add stop_on_fatal number(1)
/
comment on column prc_container.parallel_degree is 'When true a whole container will be stopped on fatal exception in the process'
/
comment on column prc_container.parallel_degree is 'Parallel degree'
/
comment on column prc_container.stop_on_fatal is 'When true a whole container will be stopped on fatal exception in the process'
/
alter table prc_container add trace_level number(8)
/
alter table prc_container add debug_writing_mode varchar2(8 char)
/
alter table prc_container add start_trace_size number(8)
/
alter table prc_container add error_trace_size number(8)
/
comment on column prc_container.trace_level is 'Trace level'
/
comment on column prc_container.debug_writing_mode is 'Debug info writing mode (LGMD dictionary)'
/
comment on column prc_container.start_trace_size is 'Trace size after process start'
/
comment on column prc_container.error_trace_size is 'Trace size before error'
/
alter table prc_container modify track_threshold number(16)
/
alter table prc_container add max_duration number(8)
/
comment on column prc_container.max_duration is 'Maximal duration for process according technical reglament (in seconds)'
/
alter table prc_container add min_speed number(16)
/
comment on column prc_container.min_speed is 'Minimal speed for process (objects per minute)'
/
