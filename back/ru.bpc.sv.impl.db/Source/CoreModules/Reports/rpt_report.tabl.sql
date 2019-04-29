create table rpt_report (
    id                  number(8)
  , seqnum              number(4)
  , inst_id             number(4)
  , data_source         clob
  , source_type         varchar2(8)
  , is_deterministic    number(1)
  , name_format_id      number(4)
  , document_type       varchar2(8)
)
/

comment on table rpt_report is 'Reports hierarchy.'
/

comment on column rpt_report.id is 'Primary key.'
/

comment on column rpt_report.seqnum is 'Data version sequential number.'
/

comment on column rpt_report.inst_id is 'Report owner institution identifier.'
/

comment on column rpt_report.data_source is 'Report source (SQL commant).'
/

comment on column rpt_report.source_type is 'Data source type (plain data, XML, refcursor).'
/

comment on column rpt_report.is_deterministic is 'If report should have constant view with same parameter values. (1 - yes, 0 - no)'
/

comment on column rpt_report.name_format_id is 'Report file naming format.'
/

comment on column rpt_report.document_type is 'Document type related with the report'
/
alter table rpt_report add (entity_type varchar2(8), object_type varchar2(8))
/
comment on column rpt_report.entity_type is 'Object entity type.'
/
comment on column rpt_report.object_type is 'Object type of entity.'
/
alter table rpt_report drop column entity_type
/
alter table rpt_report drop column object_type
/

alter table rpt_report add is_notification number(1)
/
comment on column rpt_report.is_notification is 'Automatic report flag (1 - only auto, 0 - auto and manual'
/
