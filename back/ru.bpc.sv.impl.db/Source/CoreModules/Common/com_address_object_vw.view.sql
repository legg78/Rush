create or replace force view com_address_object_vw as
select
    id
  , entity_type
  , object_id
  , address_type
  , address_id
  from com_address_object
/ 
