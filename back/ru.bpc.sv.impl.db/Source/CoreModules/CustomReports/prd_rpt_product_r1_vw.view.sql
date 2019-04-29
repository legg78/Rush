create or replace force view prd_rpt_product_r1_vw as
select id
     , product_type
     , com_api_dictionary_pkg.get_article_text(
           i_article => product_type
       ) product_type_name
     , contract_type
     , com_api_dictionary_pkg.get_article_text(
           i_article => contract_type
       ) contract_type_name
     , parent_id
     , seqnum
     , inst_id
     , status
     , com_api_dictionary_pkg.get_article_text(
           i_article => status
       ) status_name
     , product_number
  from prd_product
/

