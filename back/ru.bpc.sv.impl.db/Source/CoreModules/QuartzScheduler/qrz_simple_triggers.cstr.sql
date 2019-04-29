alter table qrz_simple_triggers add (
    constraint qrz_simple_triggers_pk primary key (sched_name, trigger_name, trigger_group)
)
/