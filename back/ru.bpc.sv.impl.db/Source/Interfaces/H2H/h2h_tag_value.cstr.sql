alter table h2h_tag_value add constraint h2h_tag_value_pk primary key (id)
/
alter table h2h_tag_value add constraint h2h_tag_value_uk unique(fin_id, tag_id)
/
