create or replace force view prd_rpt_contract_r1_vw as
select id
     , seqnum
     , product_id
     , customer_id
     , contract_type
     , com_api_dictionary_pkg.get_article_text(
           i_article => contract_type
       ) contract_type_name
     , contract_number
     , start_date
     , end_date
     , inst_id
     , agent_id
     , split_hash
  from prd_contract
/

