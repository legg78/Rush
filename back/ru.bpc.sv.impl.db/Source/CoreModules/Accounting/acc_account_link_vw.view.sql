create or replace force view acc_account_link_vw as
select a.id
     , a.account_id
     , a.entity_type
     , a.object_id
     , a.description
     , a.is_active
  from acc_account_link a
/
