create or replace force view prd_ui_attribute_vw as
select a.id
     , a.service_type_id
     , a.attr_name
     , a.data_type
     , a.lov_id
     , a.display_order
     , a.entity_type
     , a.object_type
     , a.definition_level
     , nvl(a.parent_id, a.service_type_id) as parent_id
     , l.lang
     , com_api_i18n_pkg.get_text('prd_attribute', 'label', a.id, l.lang) as label
     , com_api_i18n_pkg.get_text('prd_attribute', 'description', a.id, l.lang) as description
     , com_api_i18n_pkg.get_text('prd_attribute', 'short_name', a.id, l.lang) as short_name
     , nvl(v.is_cyclic, 0) as is_cyclic
     , nvl(v.is_use_limit, 0) as is_use_limit
     , nvl(v.is_cyclic_limit, 0) as is_cyclic_limit
     , a.is_visible
     , nvl2(t.service_fee, 1, 0) as is_service_fee
     , v.cycle_type
     , v.counter_algorithm
     , nvl(v.need_length_type, 0) as is_need_length_type
  from prd_attribute a
     , com_language_vw l
     , ( select 'ENTTFEES' as entity_type
              , b.fee_type as object_type
              , nvl2(b.cycle_type, 1, 0) as is_cyclic
              , nvl2(b.limit_type, 1, 0) as is_use_limit
              , nvl2(c.cycle_type, 1, 0) as is_cyclic_limit
              , c.cycle_type
              , c.counter_algorithm
              ,b.need_length_type
           from fcl_ui_fee_type_vw b
              , fcl_ui_limit_type_vw c
          where b.limit_type = c.limit_type(+)
         union all
         select 'ENTTLIMT' as entity_type
              , limit_type as object_type
              , nvl2(cycle_type, 1, 0) as is_cyclic
              , 0 as is_use_limit
              , 0 as is_cyclic_limit
              , cycle_type
              , counter_algorithm
              , 0 as is_need_length_type
           from fcl_ui_limit_type_vw
         union all
         select 'ENTTCYCL' as entity_type
              , cycle_type as object_type
              , IS_REPEATING as is_cyclic
              , 0 as is_use_limit
              , 0 as is_cyclic_limit
              , cycle_type as cycle_type
              , '' as counter_algorithm
              , 0 as is_need_length_type
           from fcl_ui_cycle_type_vw
       ) v
       , prd_service_type t
 where a.entity_type = v.entity_type(+)
   and a.object_type = v.object_type(+)
   and t.id = a.service_type_id
union all
select a.id
     , a.id as service_type_id
     , com_api_i18n_pkg.get_text('prd_attribute', 'label', a.id, l.lang) as attr_name
     , null as data_type
     , null as lov_id
     , 0 as display_order
     , 'ENTTSRVT' as entity_type
     , null as object_type
     , null as definition_level
     , null as parent_id
     , l.lang
     , com_api_i18n_pkg.get_text('prd_service_type', 'label', a.id, l.lang) as label
     , com_api_i18n_pkg.get_text('prd_service_type', 'description', a.id, l.lang) as description
     , com_api_i18n_pkg.get_text('prd_attribute', 'short_name', a.id, l.lang) as short_name
     , 0 as is_cyclic
     , 0 as is_use_limit
     , 0 as is_cyclic_limit
     , 1 as is_visible
     , nvl2(a.service_fee, 1, 0) as is_service_fee
     , null cycle_type
     , null counter_algorithm
     , 0 as is_need_length_type
  from prd_service_type a
     , com_language_vw l
/
