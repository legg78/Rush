create table rpt_report_tag (
    report_id number(8) not null
  , tag_id    number(4) not null
)
/

comment on table rpt_report_tag is 'Links reports with tags'
/

comment on column rpt_report_tag.report_id is 'Reference to report'
/
comment on column rpt_report_tag.tag_id is  'Reference to tag'
/
