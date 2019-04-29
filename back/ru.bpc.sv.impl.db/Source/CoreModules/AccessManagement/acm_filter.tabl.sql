create table acm_filter (
    id            number(8) not null
  , seqnum        number(4)
  , section_id    number(4)
  , inst_id       number(4)
  , user_id       number(8)
  , display_order number(4)
)
/
comment on table acm_filter is 'Filters regarding to sections'
/

comment on column acm_filter.id is 'Record identifier'
/
comment on column acm_filter.seqnum is 'Sequential version of record data'
/
comment on column acm_filter.section_id is'Section identifier to which filter belongs'
/
comment on column acm_filter.inst_id is 'Institution identifier (or ALL)'
/
comment on column acm_filter.user_id is 'User identifier (null means ALL)'
/
comment on column acm_filter.display_order is 'Display order'
/

