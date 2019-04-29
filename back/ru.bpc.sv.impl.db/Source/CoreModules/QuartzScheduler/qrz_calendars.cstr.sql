alter table qrz_calendars add (
    constraint qrz_calendars_pk primary key (sched_name, calendar_name)
)
/