alter table mcw_validation_rules_de add (constraint mcw_validation_rules_de_pk primary key (id))
/
alter table mcw_validation_rules_de add (constraint mcw_validation_rules_de_uk unique (mti, function_code, de))
/
