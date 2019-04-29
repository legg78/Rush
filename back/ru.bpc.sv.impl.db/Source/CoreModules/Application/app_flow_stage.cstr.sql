alter table app_flow_stage add(constraint app_flow_stage_pk primary key(id))
/
alter table app_flow_stage add (
	constraint app_flow_stage_uk unique (flow_id, appl_status)
)
/
alter table app_flow_stage drop constraint app_flow_stage_uk
/
alter table app_flow_stage add (constraint app_flow_stage_uk unique (flow_id, appl_status, reject_code))
/
