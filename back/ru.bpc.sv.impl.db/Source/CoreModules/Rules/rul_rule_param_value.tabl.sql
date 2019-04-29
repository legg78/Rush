create table rul_rule_param_value (
    id            number(8)
  , seqnum        number(4)
  , rule_id       number(4)
  , proc_param_id number(8)
  , param_value   varchar2(200)
)
/

comment on table rul_rule_param_value is 'Values of processing procedures parameters'
/

comment on column rul_rule_param_value.id is 'Identifier'
/

comment on column rul_rule_param_value.rule_id is 'Action identifier (instance of procedure in rules set)'
/

comment on column rul_rule_param_value.proc_param_id is 'Parameter identifier'
/

comment on column rul_rule_param_value.param_value is 'Parameter value'
/

comment on column rul_rule_param_value.seqnum is 'Sequence number. Describe data version.'
/
alter table rul_rule_param_value modify rule_id number(8)
/
