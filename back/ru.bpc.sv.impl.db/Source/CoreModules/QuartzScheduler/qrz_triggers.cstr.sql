alter table qrz_triggers add (
    constraint qrz_triggers_pk primary key (sched_name, trigger_name, trigger_group)
)
/