create or replace force view com_ui_person_vw as
select
    a.id
  , a.seqnum
  , a.lang
  , a.title
  , a.first_name
  , a.second_name
  , a.surname
  , a.suffix
  , a.gender
  , a.birthday
  , a.place_of_birth
  , a.inst_id
from
    com_person a
where
    a.inst_id = get_user_sandbox
/
