alter table vis_validation_rules add (constraint vis_validation_rules_pk primary key (id))
/
alter table vis_validation_rules add (constraint vis_validation_rules_uk unique (transaction_code, tcr, start_position))
/
