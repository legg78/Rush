create or replace force view prd_ui_product_attr_value_vw as 
select value_id
     , product_id
     , service_id
     , product_type
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
     , get_number_value(data_type, attr_value) attr_number_value
     , get_char_value  (data_type, attr_value) attr_char_value
     , get_date_value  (data_type, attr_value) attr_date_value
     , get_lov_value   (data_type, attr_value, lov_id) attr_lov_value
     , campaign_id
     , l.lang
  from (
        select v.id value_id
             , p.product_id
             , ps.service_id
             , p.product_type
             , p.parent_id owner_product_id
             , p.level_priority
             , v.attr_id
             , a.attr_name
             , v.mod_id
             , a.data_type
             , a.lov_id
             , v.start_date
             , v.end_date
             , v.register_timestamp
             , v.attr_value
             , m.priority mod_priority
             , m.condition mod_condition
             , a.entity_type attr_entity_type
             , a.object_type attr_object_type
             , case a.entity_type
                    when 'ENTTFEES' then fcl_ui_fee_pkg.get_fee_desc(to_number(v.attr_value, 'FM000000000000000000.0000'))
                    when 'ENTTCYCL' then fcl_ui_cycle_pkg.get_cycle_desc(to_number(v.attr_value, 'FM000000000000000000.0000'))
                    when 'ENTTLIMT' then fcl_ui_limit_pkg.get_limit_desc(to_number(v.attr_value, 'FM000000000000000000.0000'))
                    else v.attr_value
               end value_description
             , av.campaign_id
          from (
                select connect_by_root id product_id
                     , level level_priority
                     , id parent_id
                     , product_type
                     , case when parent_id is null then 1 else 0 end top_flag
                  from prd_product
                 connect by prior parent_id = id
               ) p
             , prd_attribute_value v
             , prd_attribute a
             , prd_service s
             , rul_mod m
             , prd_product_service ps
               --Add left join with cpn_attribute_value via attribute_value_id for show service terms value which determined in campaign. 
             , cpn_attribute_value av
         where ps.product_id     = p.product_id
           and ps.service_id     = s.id
           and v.service_id      = s.id
           and a.service_type_id = s.service_type_id
           and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id) 
           and v.entity_type     = decode (a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
           and v.attr_id         = a.id
           and v.mod_id          = m.id(+)
           and v.id              = av.attribute_value_id(+)
          ) v 
     , com_language_vw l
/
