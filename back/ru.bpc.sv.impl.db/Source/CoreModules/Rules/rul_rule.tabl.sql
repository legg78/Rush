create table rul_rule (
    id              number(4) not null
    , seqnum        number(4) not null
    , rule_set_id   number(4) not null
    , proc_id       number(4) not null
    , exec_order    number(4) not null
)
/
comment on table rul_rule is 'Assignment of procedures as processing rules'
/
comment on column rul_rule.id is 'Identifier'
/
comment on column rul_rule.rule_set_id is 'Rules set identifier'
/
comment on column rul_rule.proc_id is 'Procedure identifier'
/
comment on column rul_rule.exec_order is 'Rule execution order within rules set'
/
comment on column rul_rule.seqnum is 'Sequence number. Describe data version.'
/
alter table rul_rule modify id number(8)
/
