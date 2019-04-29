alter table qrz_job_details add (
    constraint qrz_job_details_pk primary key (sched_name, job_name, job_group)
)
/