alter table mup_file add constraint mup_file_pk primary key (id)
/
create unique index mup_file_uk on mup_file (p0105, network_id)
/
drop index mup_file_uk 
/
create unique index mup_file_uk on mup_file (p0105, case when p0105 is not null then network_id else null end)
/
