create or replace force view svy_ui_questionary_vw as
select q.id
     , q.part_key
     , q.seqnum
     , q.inst_id
     , q.split_hash
     , q.object_id
     , c.customer_number as object_number
     , q.survey_id
     , s.survey_number
     , s.status as survey_status
     , get_article_text(i_article  => s.status) as survey_status_name
     , s.entity_type
     , get_article_text(i_article  => s.entity_type) as entity_type_name
     , q.questionary_number
     , q.status as questionary_status
     , get_article_text(i_article  => q.status) as questionary_status_name
     , q.creation_date
     , q.closure_date
     , l.lang
  from svy_questionary q
     , svy_survey s
     , prd_customer c
     , com_language_vw l
 where q.survey_id = s.id
   and s.entity_type = 'ENTTCUST'
   and q.object_id = c.id
/
