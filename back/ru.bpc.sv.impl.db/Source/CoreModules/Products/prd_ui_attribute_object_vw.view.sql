create or replace force view prd_ui_attribute_object_vw as
select a.id
     , a.attr_name
     , a.data_type
     , a.lov_id
     , a.display_order
     , a.entity_type attr_entity_type
     , a.object_type attr_object_type
     , nvl(a.parent_id, s.id) parent_id
     , e.entity_type
     , o.object_id
     , l.lang
     , com_api_i18n_pkg.get_text('prd_attribute', 'label', a.id, l.lang) label
     , com_api_i18n_pkg.get_text('prd_attribute', 'description', a.id, l.lang) description
     , y.scale_id
     , com_api_i18n_pkg.get_text('rul_mod_scale', 'name', y.scale_id, l.lang) scale_name
     , y.inst_id
     , s.id service_id
     , c.product_id
     , a.definition_level
     , o.status service_status
  from prd_attribute a
     , prd_service_type e
     , (
        select b.scale_id
             , x.inst_id
             , x.attr_id
          from prd_attribute_scale b
             , (
                select i.inst_id
                     , a.id attr_id
                  from prd_attribute a
                     , acm_cu_inst_vw i
               ) x
           where b.inst_id(+) = x.inst_id
             and b.attr_id(+) = x.attr_id
       ) y
     , com_language_vw l
     , prd_service s
     , prd_service_object o
     , prd_contract c
 where y.attr_id = a.id
   and a.service_type_id = e.id
   and s.service_type_id = e.id
   and s.id = o.service_id
   and c.id = o.contract_id
   and s.inst_id = y.inst_id
   and 1 in (
       select
           nvl(min(t.is_visible), a.is_visible)
       from
           prd_service_attribute t
       where
           t.service_id(+) = s.id
           and t.attribute_id(+) = a.id
   )
union all
select o.service_id id
     , null attr_name
     , null data_type
     , null lov_id
     , null display_order
     , null attr_entity_type
     , null attr_object_type
     , null parent_id
     , o.entity_type
     , o.object_id
     , l.lang
     , com_api_i18n_pkg.get_text('prd_service', 'label', o.service_id, l.lang) label
     , com_api_i18n_pkg.get_text('prd_service', 'description', o.service_id, l.lang) description
     , null scale_id
     , null scale_name
     , c.inst_id
     , null service_id
     , c.product_id
     , null definition_level
     , o.status service_status
  from com_language_vw l
     , prd_service_object o
     , prd_contract c
 where c.id = o.contract_id
/
