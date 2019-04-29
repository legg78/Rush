create or replace force view iss_rpt_card_r1_vw as
select id
     , split_hash
     , card_hash
     , card_mask
     , inst_id
     , card_type_id
     , country
     , case when country is null then null
            else com_api_country_pkg.get_country_name(
                     i_code => country
                 ) end country_name
     , customer_id
     , cardholder_id
     , contract_id
     , reg_date
     , category
     , com_api_dictionary_pkg.get_article_text(
           i_article => category
       ) category_name 
  from iss_card
/

