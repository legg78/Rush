create or replace force view com_flexible_data_vw as
select b.id
     , b.field_id
     , b.seq_number
     , b.object_id
     , b.field_value
     , a.entity_type
     , a.object_type
     , a.name
     , a.data_type
     , a.data_format
     , a.lov_id
     , a.is_user_defined
     , a.inst_id
  from com_flexible_field a
     , com_flexible_data b
 where b.field_id = a.id 
/ 