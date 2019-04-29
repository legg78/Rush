create or replace force view svy_tag_param_vw as
select tp.id
     , tp.tag_id
     , tp.param_id
  from svy_tag_parameter tp
/
