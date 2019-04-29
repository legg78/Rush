create table rpt_report_constructor (
    id number(8)
  , report_name varchar2(1024)
  , description varchar2(2000)
  , xml_template clob
)
/
comment on table rpt_report_constructor is 'Custom report constructor'
/
comment on column rpt_report_constructor.id is 'Primary key'
/
comment on column rpt_report_constructor.report_name is 'Report name'
/
comment on column rpt_report_constructor.description is 'Report description'
/
comment on column rpt_report_constructor.xml_template is 'Report template'
/
