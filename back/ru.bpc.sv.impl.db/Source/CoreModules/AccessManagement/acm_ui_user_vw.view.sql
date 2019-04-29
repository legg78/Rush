create or replace force view acm_ui_user_vw
as
select d.id as user_id
     , d.name as user_name
     , d.status as user_status
     , d.inst_id
     , d.person_id
     , l.lang
     , (select title 
          from com_person 
         where id = d.person_id 
           and rownum = 1
       ) title
     , com_ui_person_pkg.get_first_name(d.person_id, l.lang) first_name
     , com_ui_person_pkg.get_second_name(d.person_id, l.lang) second_name
     , com_ui_person_pkg.get_surname(d.person_id, l.lang) surname
     , (select suffix 
          from com_person 
         where id = d.person_id 
           and rownum = 1
       ) suffix
     , (select gender 
          from com_person 
         where id = d.person_id 
           and rownum = 1
       ) gender
     , (select birthday 
          from com_person 
         where id = d.person_id 
           and rownum = 1
       ) birthday
     , (select place_of_birth 
          from com_person 
         where id = d.person_id 
           and rownum = 1
        ) place_of_birth
     , d.creation_date
     , d.auth_scheme
  from acm_user_vw d
     , com_language_vw l 
 where d.inst_id   = get_user_sandbox
/
