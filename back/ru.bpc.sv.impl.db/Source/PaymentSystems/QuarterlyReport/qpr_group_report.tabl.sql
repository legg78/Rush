create table qpr_group_report
   (	id  number(16) not null,
	group_name number(4,0),
	report_name varchar2(30),
    report_type number(1)
   )
/
comment on table qpr_group_report  is 'Reference of parameters groups and VISA and MC quarter reports'
/                                
comment on column qpr_group_report.id is 'Identifier'
/
comment on column qpr_group_report.group_name is 'Group name'
/
comment on column qpr_group_report.report_name is 'Report name'
/
comment on column qpr_group_report.report_type is 'Report type'
/



