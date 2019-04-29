alter table qrz_paused_trigger_grps add (
    constraint qrz_paused_trigger_grps_pk primary key (sched_name, trigger_group)
)
/