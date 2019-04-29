create table qrz_job_details (
    sched_name          varchar2(120)
  , job_name            varchar2(200)
  , job_group           varchar2(200)
  , description         varchar2(250)
  , job_class_name      varchar2(250) 
  , is_durable          varchar2(1)
  , is_nonconcurrent    varchar2(1)
  , is_update_data      varchar2(1)
  , requests_recovery   varchar2(1)
  , job_data            blob
)
/