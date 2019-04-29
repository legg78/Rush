create table rul_mod (
    id              number(4) not null
    , scale_id      number(4)
    , condition     varchar2(2000)
    , priority      number(4)
    , seqnum        number(4)
)
/
comment on table rul_mod is 'Scale modifiers '
/
comment on column rul_mod.id is 'Modifier identifier'
/
comment on column rul_mod.scale_id is 'Scale identifier'
/
comment on column rul_mod.condition is 'Modifier condition'
/
comment on column rul_mod.priority is 'Modifier priority'
/
comment on column rul_mod.seqnum is 'Sequential number of data version'
/
