alter table qrz_cron_triggers add (
    constraint qrz_cron_triggers_pk primary key (sched_name, trigger_name, trigger_group)
)
/