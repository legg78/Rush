create table app_flow_filter(
    id                  number(8)
  , seqnum              number(4)
  , stage_id            number(8)
  , struct_id           number(8)
  , min_count           number(4)
  , max_count           number(4)
  , is_visible          number(1)
  , is_updatable        number(1)
  , is_insertable       number(1)
  , default_value       varchar2(200)
)
/

comment on table app_flow_filter is 'Application structure filter. Describe state of application field on each stage.'
/

comment on column app_flow_filter.id is 'Primary key.'
/
comment on column app_flow_filter.seqnum is 'Sequence number. Describe data version.'
/
comment on column app_flow_filter.stage_id is 'Stage identifier.'
/
comment on column app_flow_filter.struct_id is 'Reference  to aplication structure element.'
/
comment on column app_flow_filter.min_count is 'Minimum count of elements of that type in parent block (if 0 then element is optional if 1 element is mandatory).'
/
comment on column app_flow_filter.max_count is 'Maximum count of element of that type in parent block.'
/
comment on column app_flow_filter.is_visible is 'Visible flag. Should display in visual form or not.'
/
comment on column app_flow_filter.is_updatable is 'Updatable flag. Is user can redefine default value.'
/
comment on column app_flow_filter.is_insertable is 'Insertable flag. Is user can add new.'
/
comment on column app_flow_filter.default_value is 'Default value.'
/
