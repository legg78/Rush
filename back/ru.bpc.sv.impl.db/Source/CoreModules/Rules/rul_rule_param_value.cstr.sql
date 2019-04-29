alter table rul_rule_param_value add constraint rul_rule_param_value_pk primary key (
    id
)
/

create unique index rul_rule_param_value_uk on rul_rule_param_value (
    rule_id
  , proc_param_id
)
/

