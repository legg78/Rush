create or replace force view iss_rpt_cardholder_r1_vw as
select id
     , person_id
     , cardholder_number
     , cardholder_name
     , inst_id
     , seqnum
     , relation
     , com_api_dictionary_pkg.get_article_text(
           i_article => relation
       ) relation_name
     , resident
     , nationality
     , case when nationality is null then null
            else com_api_country_pkg.get_country_name(
                     i_code => nationality
                 ) end nationality_name
     , marital_status
     , com_api_dictionary_pkg.get_article_text(
           i_article => marital_status
       ) marital_status_name
  from iss_cardholder
/

