create or replace force view com_flex_field_standard_vw as
select s.id
     , s.field_id
     , s.seqnum
     , s.standard_id
  from com_flexible_field_standard s
/

