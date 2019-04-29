create or replace force view svy_ui_tag_param_vw as
select tp.id
     , tp.tag_id
     , t.entity_type
     , tp.param_id
     , p.param_name
     , l.lang
  from svy_tag_parameter tp
     , svy_tag t
     , svy_parameter p
     , com_language_vw l
 where tp.tag_id = t.id
   and tp.param_id = p.id 
/
