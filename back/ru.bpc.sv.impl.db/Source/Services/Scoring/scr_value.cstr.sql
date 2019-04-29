alter table scr_value
add constraint scr_value_pk primary key (id)
/
alter table scr_value
add constraint scr_value_uk unique (criteria_id, score)
/
