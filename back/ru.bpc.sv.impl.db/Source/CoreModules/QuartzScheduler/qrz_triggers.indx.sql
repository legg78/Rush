create index qrz_triggers_job_ndx on qrz_triggers(sched_name, job_group, job_name)
/

create index qrz_triggers_calendar_ndx on qrz_triggers(sched_name, calendar_name)
/

create index qrz_triggers_trigger_ndx on qrz_triggers(sched_name, trigger_group, trigger_state, trigger_name)
/

create index qrz_triggers_state_ndx on qrz_triggers(sched_name, trigger_state, next_fire_time)
/

create index qrz_triggers_misfire_ndx on qrz_triggers(sched_name, next_fire_time, misfire_instr, trigger_state, trigger_group)
/