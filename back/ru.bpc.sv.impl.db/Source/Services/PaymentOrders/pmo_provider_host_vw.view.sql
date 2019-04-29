create or replace force view pmo_provider_host_vw as
select a.host_member_id
     , a.provider_id
     , a.execution_type
     , a.priority
     , a.mod_id
     , a.inactive_till
     , a.status
  from pmo_provider_host a
/
