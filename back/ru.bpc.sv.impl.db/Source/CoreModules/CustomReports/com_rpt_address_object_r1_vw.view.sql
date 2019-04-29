create or replace force view com_rpt_address_object_r1_vw as
select id
     , entity_type
     , object_id
     , address_type
     , address_id
  from com_address_object
/

