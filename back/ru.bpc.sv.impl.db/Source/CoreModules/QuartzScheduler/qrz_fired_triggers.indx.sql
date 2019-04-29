create index qrz_fired_trig_instance_ndx on qrz_fired_triggers(sched_name, instance_name, requests_recovery)
/

create index qrz_fired_triggers_job_ndx on qrz_fired_triggers(sched_name, job_group, job_name)
/

create index qrz_fired_triggers_trigg_ndx on qrz_fired_triggers(sched_name, trigger_group, trigger_name)
/
