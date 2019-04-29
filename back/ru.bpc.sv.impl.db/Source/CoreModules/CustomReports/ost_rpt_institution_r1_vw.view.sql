create or replace force view ost_rpt_institution_r1_vw as
select id
     , seqnum
     , parent_id
     , network_id
     , inst_type
     , com_api_dictionary_pkg.get_article_text(
           i_article => inst_type
       ) inst_type_name
  from ost_institution
/

