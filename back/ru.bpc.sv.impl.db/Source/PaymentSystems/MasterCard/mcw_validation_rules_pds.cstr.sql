alter table mcw_validation_rules_pds add (constraint mcw_validation_rules_pds_pk primary key (id))
/
alter table mcw_validation_rules_pds add (constraint mcw_validation_rules_pds_uk unique (mti, function_code, pds))
/
