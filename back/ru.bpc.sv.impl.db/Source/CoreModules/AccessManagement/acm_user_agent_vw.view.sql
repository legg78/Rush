create or replace force view acm_user_agent_vw
as
  select a.id
       , a.user_id
       , a.agent_id
       , a.is_default
  from   acm_user_agent a
/
