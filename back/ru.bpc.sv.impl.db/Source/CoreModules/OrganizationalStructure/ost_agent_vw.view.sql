create or replace force view ost_agent_vw as
select id
     , seqnum
     , inst_id
     , parent_id
     , agent_type
     , is_default
     , agent_number
  from ost_agent
/