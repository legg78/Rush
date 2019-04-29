alter table aup_tag add constraint aup_tag_pk primary key (id)
/
create unique index aup_tag_uk on aup_tag(tag)
/