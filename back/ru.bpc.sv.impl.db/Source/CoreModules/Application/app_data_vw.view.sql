create or replace force view app_data_vw as
select a.id
     , a.split_hash
     , a.appl_id
     , a.element_id
     , a.parent_id
     , a.serial_number
     , a.element_value
     , a.is_auto
     , e.name
  from app_data a
     , app_element e
 where e.id = a.element_id
/
