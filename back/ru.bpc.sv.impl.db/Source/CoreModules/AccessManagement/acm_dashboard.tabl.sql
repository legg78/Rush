create table acm_dashboard (
    id        number(8)
  , seqnum    number(4)
  , user_id   number(8)
  , inst_id   number(4)
  , is_shared number(1)
)
/

comment on table acm_dashboard is 'Dashboards created by users'
/

comment on column acm_dashboard.id is 'Primary key'
/

comment on column acm_dashboard.seqnum is 'Data version sequentional number'
/

comment on column acm_dashboard.user_id is 'User which created and own dashboard. Only that user could change dashboard.'
/

comment on column acm_dashboard.inst_id is 'Institution identifier'
/

comment on column acm_dashboard.is_shared is 'Shared dashboard. Not only owner could use dashboard (1 - yes, 0 - no). '
/