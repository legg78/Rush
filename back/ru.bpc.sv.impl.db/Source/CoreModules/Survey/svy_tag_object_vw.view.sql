create or replace force view svy_tag_object_vw as
select tj.id
     , tj.tag_id
     , tj.param_id
     , tj.object_id
  from svy_tag_object tj
/
