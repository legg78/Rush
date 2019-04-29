alter table mup_validation_rules_de add (constraint mup_validation_rules_de_pk primary key (id))
/
alter table mup_validation_rules_de add (constraint mup_validation_rules_de_uk unique (mti, function_code, de))
/
