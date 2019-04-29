create or replace force view adt_detail_vw as
select id
     , trail_id
     , column_name
     , data_type
     , data_format
     , old_value
     , new_value
  from adt_detail
/