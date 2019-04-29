alter table sec_question add constraint sec_question_pk primary key (
    id
)
/
create unique index sec_question_uk on sec_question (
    object_id
    , entity_type
    , question  
)
/

