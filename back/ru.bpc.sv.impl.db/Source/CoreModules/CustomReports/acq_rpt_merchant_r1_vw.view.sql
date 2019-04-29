create or replace force view acq_rpt_merchant_r1_vw as
select id
     , seqnum
     , merchant_number
     , merchant_name
     , merchant_type
     , com_api_dictionary_pkg.get_article_text(
           i_article => merchant_type
       ) merchant_type_name
     , parent_id
     , mcc
     , status
     , com_api_dictionary_pkg.get_article_text(
           i_article => status
       ) status_name
     , contract_id
     , inst_id
     , split_hash
     , risk_indicator
  from acq_merchant
/

