create or replace force view adt_ui_detail_vw as
select id
     , trail_id
     , column_name
     , data_type
     , data_format
     , old_value
     , new_value
     , get_number_value(data_type, old_value) old_number_value
     , get_char_value(data_type, old_value) old_char_value
     , get_date_value(data_type, old_value) old_date_value
     , get_number_value(data_type, new_value) new_number_value
     , get_char_value(data_type, new_value) new_char_value
     , get_date_value(data_type, new_value) new_date_value
  from adt_detail
/