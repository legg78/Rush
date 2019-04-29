create or replace force view acc_rpt_account_r1_vw as
select id
     , split_hash
     , account_type
     , com_api_dictionary_pkg.get_article_text(
           i_article => account_type
       ) account_type_name
     , account_number
     , currency
     , inst_id
     , agent_id
     , customer_id
     , contract_id
     , status
     , com_api_dictionary_pkg.get_article_text(
           i_article => status
       ) status_name
     , scheme_id
  from acc_account
/

