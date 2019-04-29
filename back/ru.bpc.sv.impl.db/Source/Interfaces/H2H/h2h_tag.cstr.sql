alter table h2h_tag add constraint h2h_tag_pk primary key (id)
/
create unique index h2h_tag_uk on h2h_tag(tag)
/
drop index h2h_tag_uk
/
alter table h2h_tag add constraint h2h_tag_uk unique(tag)
/
