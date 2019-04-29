create table acm_component_state (
    id           number(8)
  , user_id      number(8)
  , component_id varchar2(200)
  , state        varchar2(2000))
/

comment on table acm_component_state is 'State of interface component.'
/

comment on column acm_component_state.id is 'Primary key.'
/

comment on column acm_component_state.user_id is 'User ID'
/

comment on column acm_component_state.component_id is 'Component ID'
/

comment on column acm_component_state.state is 'State'
/

