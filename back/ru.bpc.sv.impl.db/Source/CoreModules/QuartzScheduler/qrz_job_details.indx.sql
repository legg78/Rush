create index qrz_job_details_req_recov_ndx on qrz_job_details(sched_name, requests_recovery)
/

create index qrz_job_details_group_ndx on qrz_job_details(sched_name, job_group)
/
