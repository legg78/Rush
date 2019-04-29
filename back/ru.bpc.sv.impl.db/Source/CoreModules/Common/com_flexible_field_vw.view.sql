create or replace force view com_flexible_field_vw as
select a.id
     , a.entity_type
     , a.object_type
     , a.name
     , a.data_type
     , a.data_format
     , a.lov_id
     , a.is_user_defined
     , a.inst_id
     , a.default_value
  from com_flexible_field a
/ 