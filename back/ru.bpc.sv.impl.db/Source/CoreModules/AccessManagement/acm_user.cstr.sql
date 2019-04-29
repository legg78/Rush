alter table acm_user add (
    constraint acm_user_pk primary key (id)
  , constraint acm_user_un unique (person_id)
)
/
