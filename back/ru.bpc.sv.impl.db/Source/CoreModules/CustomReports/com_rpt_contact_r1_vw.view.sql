create or replace force view com_rpt_contact_r1_vw as
select id
     , seqnum
     , preferred_lang
     , com_api_dictionary_pkg.get_article_text(
           i_article => preferred_lang
       ) preferred_lang_name
     , job_title
     , com_api_dictionary_pkg.get_article_text(
           i_article => job_title
       ) job_title_name
     , person_id
     , inst_id 
  from com_contact
/

