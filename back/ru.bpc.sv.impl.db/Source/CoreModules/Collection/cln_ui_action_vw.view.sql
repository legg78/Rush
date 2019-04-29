create or replace force view cln_ui_action_vw as
select a.id
     , a.part_key
     , a.case_id
     , a.seqnum
     , a.split_hash
     , a.activity_category
     , a.activity_type
     , a.user_id
     , a.action_date
     , a.eff_date
     , a.status
     , a.resolution
     , a.commentary
     , get_article_text(i_article  => a.activity_category) as activity_category_name
     , get_article_text(i_article  => a.activity_type) as activity_type_name
     , acm_api_user_pkg.get_user_name(i_user_id  => a.user_id, i_mask_error  => 1) as user_name
     , get_article_text(i_article  => a.status) as status_name
     , get_article_text(i_article  => a.resolution) as resolution_name
     , l.lang 
  from cln_action a
     , com_language_vw l
/

