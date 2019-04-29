create table rpt_report_banner (
	id        number (8), 
	report_id number (8),
	banner_id number (8)
)
/

comment on column rpt_report_banner.id is 'Primary key.'
/
comment on table rpt_report_banner is 'links reports with banners'
/
comment on column rpt_report_banner.report_id is 'reference to report'
/
comment on column rpt_report_banner.banner_id is  'reference to banner'
/
