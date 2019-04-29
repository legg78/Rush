alter table qrz_locks add (
    constraint qrz_locks_pk primary key (sched_name, lock_name)
)
/