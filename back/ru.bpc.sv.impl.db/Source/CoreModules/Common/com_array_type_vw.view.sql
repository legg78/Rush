create or replace force view com_array_type_vw as
select id
     , seqnum
     , name
     , is_unique
     , lov_id
     , entity_type
     , data_type
     , inst_id
     , scale_type
     , class_name
  from com_array_type n
/