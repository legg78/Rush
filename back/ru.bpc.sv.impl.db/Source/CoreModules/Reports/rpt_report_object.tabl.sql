create table rpt_report_object (
    id                  number(8)
  , seqnum              number(4)
  , report_id           number(8)
  , entity_type         varchar2(8)
  , object_type         varchar2(8)
)
/

comment on table rpt_report_object is 'Reports linked with business entities.'
/

comment on column rpt_report_object.id is 'Primary key.'
/

comment on column rpt_report_object.seqnum is 'Data version sequential number.'
/

comment on column rpt_report_object.report_id is 'Reference to report.'
/

comment on column rpt_report_object.entity_type is 'Entity type.'
/

comment on column rpt_report_object.object_type is 'Object type.'
/
