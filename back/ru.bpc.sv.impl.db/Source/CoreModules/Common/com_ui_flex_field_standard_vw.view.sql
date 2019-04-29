create or replace force view com_ui_flex_field_standard_vw as
select s.id
     , s.field_id
     , s.seqnum
     , s.standard_id
     , f.entity_type
     , f.name
     , f.data_type
     , f.data_format
     , f.lov_id
     , f.inst_id
     , f.default_value
  from com_flexible_field_standard s
     , com_flexible_field          f
 where s.field_id = f.id
/

