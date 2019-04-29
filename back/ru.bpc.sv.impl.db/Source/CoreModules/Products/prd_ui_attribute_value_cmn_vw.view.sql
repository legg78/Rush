create or replace force view prd_ui_attribute_value_cmn_vw as 
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
     , get_text('rul_mod', 'name', mod_id, l.lang) mod_name
     , start_date
     , end_date
     , register_timestamp
     , data_type
     , lov_id
     , com_api_const_pkg.get_format(data_type) data_format
     , attr_entity_type
     , attr_object_type
     , attr_value
     , value_description
     , split_hash
     , get_number_value(data_type, attr_value) attr_number_value
     , get_char_value  (data_type, attr_value) attr_char_value
     , get_date_value  (data_type, attr_value) attr_date_value
     , get_lov_value   (data_type, attr_value, lov_id) attr_lov_value
     , l.lang
  from (  
        select v.id value_id
             , v.service_id
             , v.object_id
             , v.entity_type
             , to_number(null) owner_product_id
             , -1 level_priority
             , v.attr_id
             , a.attr_name
             , v.mod_id
             , m.priority mod_priority
             , m.condition mod_condition
             , v.start_date
             , v.end_date
             , v.register_timestamp
             , a.data_type
             , a.lov_id
             , a.entity_type attr_entity_type
             , a.object_type attr_object_type
             , v.attr_value
             , case a.entity_type
                   when 'ENTTFEES' then fcl_ui_fee_pkg.get_fee_desc(to_number(v.attr_value, 'FM000000000000000000.0000'))
                   when 'ENTTCYCL' then fcl_ui_cycle_pkg.get_cycle_desc(to_number(v.attr_value, 'FM000000000000000000.0000'))
                   when 'ENTTLIMT' then fcl_ui_limit_pkg.get_limit_desc(to_number(v.attr_value, 'FM000000000000000000.0000'))
                   else v.attr_value
               end value_description
             , v.split_hash
          from prd_attribute_value v
             , prd_attribute a
             , rul_mod m
         where v.attr_id = a.id
           and v.mod_id  = m.id(+)
       )
     , com_language_vw l
/