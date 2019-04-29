create table acm_widget (
    id          number(4)
  , seqnum      number(4)
  , path        varchar2(2000)
  , css_name    varchar2(200)
  , is_external number(1)
  , width       number(4)
  , height      number(4)
  , priv_id     number(4)
  , params_path varchar2(2000)
)
/

comment on table acm_widget is 'Widgets supported by the system.'
/
comment on column acm_widget.id is 'Primary key'
/
comment on column acm_widget.seqnum is 'Data version sequentional number'
/
comment on column acm_widget.path is 'Path/URL to widget source.'
/
comment on column acm_widget.css_name is 'Name of CSS using for decoration of current widget'
/
comment on column acm_widget.is_external is 'Is widget provided by external source (1 - Yes, 0 - No)'
/
comment on column acm_widget.width is 'Width of widget layout in percents of total screen width'
/
comment on column acm_widget.height is 'Height of widget layout in percents of total screen height'
/
comment on column acm_widget.priv_id is 'Privilege associated with widget. User has to have privilege to see data on that widget.'
/
comment on column acm_widget.params_path is 'Parameters form path'
/
