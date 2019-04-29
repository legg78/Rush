alter table mup_validation_rules_pds add (constraint mup_validation_rules_pds_pk primary key (id))
/
alter table mup_validation_rules_pds add (constraint mup_validation_rules_pds_uk unique (mti, function_code, pds))
/
