create table evt_rule_set
(
    id                  number(4)
  , seqnum              number(4)
  , event_id            number(4)
  , rule_set_id         number(4)
  , mod_id              number(4)
)
/

comment on table evt_rule_set is 'Rule sets executing when events raised'
/

comment on column evt_rule_set.id is 'Primary key.'
/

comment on column evt_rule_set.seqnum is 'Data version number.'
/

comment on column evt_rule_set.event_id is 'Reference to event.'
/

comment on column evt_rule_set.rule_set_id is 'Refrenece to rule set.'
/

comment on column evt_rule_set.mod_id is 'Modifier containing filter on objects will be processed by current rule set.'
/