create table acm_action(
    id              number(4)
  , seqnum          number(4)
  , call_mode       varchar2(8)
  , entity_type     varchar2(8)
  , object_type     varchar2(8)
  , group_id        number(4)
  , section_id      number(4)
  , priv_id         number(8)
  , priv_object_id  number(16)
  , inst_id         number(4)
  , is_default      number(1)
)
/

comment on table acm_action is 'Custom actions.'
/

comment on column acm_action.id is 'Primary key.'
/
comment on column acm_action.seqnum is 'Sequential number of data version'
/
comment on column acm_action.call_mode is 'Mode in which the action may be available.'
/
comment on column acm_action.entity_type is 'Entity type is related to the respective action.'
/
comment on column acm_action.group_id is 'Reference to grouping context actions'
/
comment on column acm_action.section_id is 'Modal form will shown '
/
comment on column acm_action.priv_id is 'Reference to privilege assigned with action.'
/
comment on column acm_action.priv_object_id is 'Reference to exact object assigned with privilege.'
/
comment on column acm_action.inst_id is 'Institution identifier.'
/
comment on column acm_action.is_default is 'Default action for entity type.'
/
comment on column acm_action.object_type is 'Object type to restrict some actions'
/
alter table acm_action add (object_type_lov_id number(4))
/
comment on column acm_action.object_type_lov_id is 'LOV to choosing value for object type'
/