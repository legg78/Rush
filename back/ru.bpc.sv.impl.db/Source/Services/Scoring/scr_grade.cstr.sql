alter table scr_grade
add constraint scr_grade_pk primary key (id)
/
alter table scr_grade
add constraint scr_grade_uk unique (evaluation_id, total_score)
/
