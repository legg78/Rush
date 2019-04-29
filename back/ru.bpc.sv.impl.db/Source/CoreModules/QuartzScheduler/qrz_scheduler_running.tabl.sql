create table qrz_scheduler_running(
    is_running          number(1)
)
/
comment on table qrz_scheduler_running is 'Scheduler run statuses.'
/
comment on column qrz_scheduler_running.is_running is 'Schedulers running status.'
/
