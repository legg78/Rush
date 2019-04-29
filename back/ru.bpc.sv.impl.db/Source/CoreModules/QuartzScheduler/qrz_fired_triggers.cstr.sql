alter table qrz_fired_triggers add (
    constraint qrz_fired_triggers_pk primary key (sched_name, entry_id)
)
/