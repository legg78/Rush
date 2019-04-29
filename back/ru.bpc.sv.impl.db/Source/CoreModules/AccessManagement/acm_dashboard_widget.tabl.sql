create table acm_dashboard_widget (
    id                number(8)
  , seqnum            number(4)
  , dashboard_id      number(8)
  , widget_id         number(4)
  , row_number        number(4)
  , column_number     number(4)
  , is_refresh        number(1)
  , refresh_interval  number(4)
)
/

comment on table acm_dashboard_widget is 'Widgets included into dashboard'
/
comment on column acm_dashboard_widget.id is 'Primary key'
/
comment on column acm_dashboard_widget.seqnum is 'Data version sequentional number'
/
comment on column acm_dashboard_widget.dashboard_id is 'Reference to dashboard'
/
comment on column acm_dashboard_widget.widget_id is 'Reference to widget'
/
comment on column acm_dashboard_widget.row_number is 'Vertical position of widget on dashboard (top-left coner)'
/
comment on column acm_dashboard_widget.column_number is 'Horizontal position of widget on dashboard (top-left coner)'
/
comment on column acm_dashboard_widget.is_refresh is 'Is refresh'
/
comment on column acm_dashboard_widget.refresh_interval is 'Refresh period'
/
