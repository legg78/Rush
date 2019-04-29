create or replace force view com_rpt_address_r1_vw as
select id
     , seqnum
     , lang
     , com_api_dictionary_pkg.get_article_text(
           i_article => lang
       ) lang_name
     , country
     , case when country is null then null
            else com_api_country_pkg.get_country_name(
                     i_code => country
                 ) end country_name
     , region
     , city
     , street
     , house
     , apartment
     , postal_code
     , region_code
     , latitude
     , longitude
     , inst_id
     , place_code
     , comments
  from com_address
/

