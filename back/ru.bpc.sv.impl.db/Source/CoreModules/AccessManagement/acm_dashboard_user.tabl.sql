create table acm_dashboard_user (
    id           number(8)
  , seqnum       number(4)
  , dashboard_id number(8)
  , user_id      number(8)
  , is_default   number(1)
)
/

comment on table acm_dashboard_user is 'Dashboards is used by user.'
/

comment on column acm_dashboard_user.id is 'Primary key'
/

comment on column acm_dashboard_user.seqnum is 'Data version sequentional number'
/

comment on column acm_dashboard_user.dashboard_id is 'Reference to dashboard'
/

comment on column acm_dashboard_user.user_id is 'User who use current dashboard.'
/

comment on column acm_dashboard_user.is_default is 'Default dashboard indicator.'
/