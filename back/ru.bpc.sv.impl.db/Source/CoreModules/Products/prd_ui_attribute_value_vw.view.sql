create or replace force view prd_ui_attribute_value_vw as 
select value_id
     , service_id
     , object_id
     , entity_type
     , owner_product_id
     , level_priority
     , attr_id
     , attr_name
     , mod_id
     , mod_priority
     , mod_condition
     , mod_name
     , start_date
     , end_date
     , register_timestamp
     , data_type
     , lov_id
     , data_format
     , attr_entity_type
     , attr_object_type
     , attr_value
     , value_description
     , split_hash
     , attr_number_value
     , attr_char_value
     , attr_date_value
     , attr_lov_value
     , lang
  from prd_ui_attribute_value_cmn_vw
 where entity_type != 'ENTTPROD'
/
