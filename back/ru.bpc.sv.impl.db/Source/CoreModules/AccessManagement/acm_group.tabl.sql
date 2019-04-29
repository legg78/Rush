create table acm_group (
    id             number(8)
  , inst_id        number(4)
  , seqnum         number(4)
  , creation_date  date
)
/
comment on table acm_group is 'Groups for users.'
/
comment on column acm_group.id is 'Primary key.'
/
comment on column acm_group.inst_id is 'Institution ID'
/
comment on column acm_group.seqnum is 'Sequence number (for data integrity)'
/
comment on column acm_group.creation_date is 'Date of group creating'
/
