alter table scr_criteria 
add constraint scr_criteria_pk primary key (id)
/
alter table scr_criteria 
add constraint scr_criteria_uk unique (evaluation_id, order_num)
/
