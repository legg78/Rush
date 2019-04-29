alter table set_parameter_value add constraint set_parameter_value_pk primary key (id)
/
alter table set_parameter_value add constraint set_parameter_value_uk unique (param_id, param_level, level_value)
/
