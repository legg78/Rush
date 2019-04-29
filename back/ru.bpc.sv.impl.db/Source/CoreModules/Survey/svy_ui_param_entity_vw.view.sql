create or replace force view svy_ui_param_entity_vw as
select e.id
     , e.seqnum
     , e.entity_type
     , get_article_text(i_article  => e.entity_type) as entity_type_name
     , e.param_id
     , p.param_name
     , l.lang
  from svy_parameter_entity e
     , svy_parameter p
     , com_language_vw l
 where e.param_id = p.id
/
