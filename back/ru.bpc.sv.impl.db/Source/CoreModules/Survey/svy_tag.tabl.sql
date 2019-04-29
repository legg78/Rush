create table svy_tag(
    id               number(8)
  , seqnum           number(4)
  , inst_id          number(4)
  , entity_type      varchar2(8)
  , condition        varchar2(2000)
)
/
comment on table svy_tag is 'Tags to mark entities stored here.'
/
comment on column svy_tag.id is 'Tag identifier. Primary key.'
/
comment on column svy_tag.seqnum is 'Sequence number. Describe data version.'
/
comment on column svy_tag.inst_id is 'Institution identifier'
/
comment on column svy_tag.entity_type is 'Business-entity type.'
/
comment on column svy_tag.condition is 'Tag condition.'
/
