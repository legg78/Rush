alter table qrz_blob_triggers add (
    constraint qrz_blob_triggers_pk primary key (sched_name, trigger_name, trigger_group)
)
/