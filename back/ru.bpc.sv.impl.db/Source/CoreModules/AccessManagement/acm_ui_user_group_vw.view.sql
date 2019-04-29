create or replace force view acm_ui_user_group_vw as
select u.user_id
     , u.user_name
     , u.user_status
     , u.person_id
     , u.lang
     , u.title
     , u.first_name
     , u.second_name
     , u.surname
     , u.suffix
     , u.gender
     , u.birthday
     , u.place_of_birth
     , acm_ui_user_pkg.get_lockout_date(u.user_id) as unlock_date
     , u.inst_id
     , g.id group_id
     , g.inst_id group_inst_id
     , g.creation_date
     , get_text(
           i_table_name  => 'ACM_GROUP'
         , i_column_name => 'NAME'
         , i_object_id   => ug.group_id
         , i_lang        => l.lang
       ) as group_name
  from acm_user_group ug
     , acm_ui_user_vw u
     , acm_group_vw g
     , com_language_vw l
 where u.user_id = ug.user_id
   and g.id = ug.group_id
   and u.lang = l.lang
/
