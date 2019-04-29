create table rul_rule_set (
    id          number(4) not null
    , seqnum    number(4)
    , category  varchar2(8)
)
/
comment on table rul_rule_set is 'Sets of rules'
/
comment on column rul_rule_set.id is 'Identifier'
/
comment on column rul_rule_set.seqnum is 'Sequential number'
/
comment on column rul_rule_set.category is 'Category of rules set (RLCG key)'
/
