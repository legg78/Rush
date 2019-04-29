create or replace force view ost_ui_agent_type_tree_vw as
select id
     , seqnum
     , agent_type
     , parent_agent_type
     , inst_id
  from ost_agent_type_tree
 where inst_id in (select inst_id from acm_cu_inst_vw)
/ 