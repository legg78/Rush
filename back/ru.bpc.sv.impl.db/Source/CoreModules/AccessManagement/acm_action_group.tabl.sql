create table acm_action_group (
    id             number(4) not null
    , seqnum       number(4) not null
    , entity_type  varchar2(8) not null
    , parent_id    number(4)
    , inst_id      number(4) not null
)
/
comment on table acm_action_group is 'Grouping context actions to build multilevel context menus.'
/
comment on column acm_action_group.id is 'Primary key'
/
comment on column acm_action_group.seqnum is 'Sequential number of data version'
/
comment on column acm_action_group.entity_type is 'Entity type is related to the action could be included to current group.'
/
comment on column acm_action_group.parent_id is 'Reference to parent group'
/
comment on column acm_action_group.inst_id is 'Institution identifier'
/
