alter table qrz_scheduler_state add (
    constraint qrz_scheduler_state_pk primary key (sched_name, instance_name)
)
/