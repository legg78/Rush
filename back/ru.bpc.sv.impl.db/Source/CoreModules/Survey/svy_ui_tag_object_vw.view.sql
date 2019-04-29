create or replace force view svy_ui_tag_object_vw as
select tj.id
     , tj.tag_id
     , tj.param_id
     , p.param_name
     , tj.object_id
     , t.entity_type
     , l.lang
  from svy_tag_object tj
     , svy_tag t
     , svy_parameter p
     , com_language_vw l
 where tj.tag_id = t.id
   and tj.param_id = p.id
/
