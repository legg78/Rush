create or replace force view acm_cu_agent_vw as
select agent_id
     , is_default
  from acm_user_agent_mvw
 where user_id = get_user_id
/
