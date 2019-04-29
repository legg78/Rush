alter table qrz_simprop_triggers add (
    constraint qrz_simprop_triggers_pk primary key (sched_name, trigger_name, trigger_group)
)
/