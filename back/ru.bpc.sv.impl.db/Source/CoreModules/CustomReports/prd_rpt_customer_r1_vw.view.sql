create or replace force view prd_rpt_customer_r1_vw as
select id
     , seqnum
     , entity_type
     , com_api_dictionary_pkg.get_article_text(
           i_article => entity_type
       ) entity_type_name
     , object_id
     , customer_number
     , contract_id
     , inst_id
     , split_hash
     , category
     , com_api_dictionary_pkg.get_article_text(
           i_article => category
       ) category_nmae
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
     , credit_rating
     , com_api_dictionary_pkg.get_article_text(
           i_article => credit_rating
       ) credit_rating_name
     , money_laundry_risk
     , com_api_dictionary_pkg.get_article_text(
           i_article => money_laundry_risk
       ) money_laundry_risk_name
     , money_laundry_reason
     , com_api_dictionary_pkg.get_article_text(
           i_article => money_laundry_reason
       ) money_laundry_reason_name
     , last_modify_date
     , last_modify_user
     , status
     , com_api_dictionary_pkg.get_article_text(
           i_article => status
       ) status_name
     , ext_entity_type
     , com_api_dictionary_pkg.get_article_text(
           i_article => ext_entity_type
       ) ext_entity_type_name
     , ext_object_id
     , reg_date
     , employment_status
     , com_api_dictionary_pkg.get_article_text(
           i_article => employment_status
       ) employment_status_name
     , employment_period
     , com_api_dictionary_pkg.get_article_text(
           i_article => employment_period
       ) employment_period_name
     , residence_type
     , com_api_dictionary_pkg.get_article_text(
           i_article => residence_type
       ) residence_type_name
     , marital_status_date
     , income_range
     , com_api_dictionary_pkg.get_article_text(
           i_article => income_range
       ) income_range_name
     , number_of_children
     , com_api_dictionary_pkg.get_article_text(
           i_article => number_of_children
       ) number_of_children_name
     , marital_status
     , com_api_dictionary_pkg.get_article_text(
           i_article => marital_status
       ) marital_status_name
  from prd_customer
/

