create or replace force view acm_rpt_user_r1_vw as
select id
     , name
     , person_id
     , status
     , com_api_dictionary_pkg.get_article_text(
           i_article => status
       ) status_name     
     , inst_id
     , password_change_needed
     , creation_date
     , auth_scheme
  from acm_user
/

