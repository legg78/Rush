create or replace force view com_rpt_person_r1_vw as
select id
     , seqnum
     , lang
     , com_api_dictionary_pkg.get_article_text(
           i_article => lang
       ) lang_name
     , title
     , com_api_dictionary_pkg.get_article_text(
           i_article => title
       ) title_name
     , first_name
     , second_name
     , surname
     , suffix
     , com_api_dictionary_pkg.get_article_text(
           i_article => suffix
       ) suffix_name
     , gender
     , com_api_dictionary_pkg.get_article_text(
           i_article => gender
       ) gender_name
     , birthday
     , place_of_birth
     , inst_id
  from com_person
/

