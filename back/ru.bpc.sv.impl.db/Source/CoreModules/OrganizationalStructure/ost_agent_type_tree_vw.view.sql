create or replace force view ost_agent_type_tree_vw as
select id
     , seqnum
     , agent_type
     , parent_agent_type
     , inst_id
  from ost_agent_type_tree
/ 