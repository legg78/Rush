create table rpt_template (
    id                  number(8)
  , seqnum              number(4)
  , report_id           number(8)
  , lang                varchar2(8)
  , text                clob
  , base64              clob
  , report_processor    varchar2(8)
  , report_format       varchar2(8)
  , start_date          date
  , end_date            date
)
/

comment on table rpt_template is 'Report template. Jasper report layout in JRXML format.'
/

comment on column rpt_template.base64 is 'Compiled template encoded in BASE64.'
/

comment on column rpt_template.id is 'Primary key.'
/

comment on column rpt_template.seqnum is 'Data version sequential number.'
/

comment on column rpt_template.report_id is 'Reference to report.'
/

comment on column rpt_template.lang is 'Template language.'
/

comment on column rpt_template.text is 'Template source.'
/

comment on column rpt_template.report_processor is 'Report processor.'
/

comment on column rpt_template.report_format is 'Report file format.'
/

comment on column rpt_template.start_date is 'Template validity period start date'
/

comment on column rpt_template.end_date is 'Template validity period end date'
/
