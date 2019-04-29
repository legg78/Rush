create table prc_semaphore(
    session_id              number(16) not null 
    , semaphore_name        varchar2(30) 
)
/

comment on table prc_semaphore is 'Semaphore of groups of processes stored here.'
/
comment on table prc_semaphore is 'Groups of processes stored here'
/
comment on column prc_semaphore.session_id is 'Session identifier'
/
comment on column prc_semaphore.semaphore_name is 'Semaphore name (to avoid simultaneous run)'
/
comment on table prc_semaphore is 'Semaphore of groups of processes stored here.'
/
