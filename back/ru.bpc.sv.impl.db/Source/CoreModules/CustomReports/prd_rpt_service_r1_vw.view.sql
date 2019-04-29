create or replace force view prd_rpt_service_r1_vw as
select id
     , seqnum
     , service_type_id
     , template_appl_id
     , inst_id
     , status
     , com_api_dictionary_pkg.get_article_text(
           i_article => status
       ) status_name
     , service_number
  from prd_service
/

