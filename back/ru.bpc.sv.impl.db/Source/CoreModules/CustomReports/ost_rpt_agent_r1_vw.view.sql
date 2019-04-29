create or replace force view ost_rpt_agent_r1_vw as
select id
     , inst_id
     , seqnum
     , parent_id
     , agent_type
     , com_api_dictionary_pkg.get_article_text(
           i_article => agent_type
       ) agent_type_name
     , is_default
     , agent_number
  from ost_agent
/

