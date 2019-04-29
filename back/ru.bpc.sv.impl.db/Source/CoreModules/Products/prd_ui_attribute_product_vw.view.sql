create or replace force view prd_ui_attribute_product_vw as
select q.id
     , q.attr_name
     , q.data_type
     , q.lov_id
     , q.display_order
     , q.attr_entity_type
     , q.attr_object_type
     , q. parent_id
     , q.entity_type
     , q.lang
     , q.label
     , q.description
     , q.scale_id
     , com_api_i18n_pkg.get_text(
           i_table_name  => 'rul_mod_scale'
         , i_column_name => 'name'
         , i_object_id   => q.scale_id
         , i_lang        => q.lang
       ) as scale_name
     , q.inst_id
     , q.service_id
     , q.product_id
     , q.definition_level
  from (
    select a.id
         , a.attr_name
         , a.data_type
         , a.lov_id
         , a.display_order
         , a.entity_type attr_entity_type
         , a.object_type attr_object_type
         , nvl(a.parent_id, e.id) parent_id
         , e.product_type entity_type
         , l.lang
         , com_api_i18n_pkg.get_text('prd_attribute', 'label', a.id, l.lang) label
         , com_api_i18n_pkg.get_text('prd_attribute', 'description', a.id, l.lang) description
         , (select distinct first_value(scale_id) over (order by inst_id)
              from prd_attribute_scale y
             where a.id = y.attr_id
              and (p.inst_id = y.inst_id or y.inst_id = 9999)) as scale_id
         , p.inst_id as inst_id
         , s.id service_id
         , p.id product_id
         , a.definition_level
      from prd_attribute a
      inner join prd_service_type e on a.service_type_id = e.id
      inner join prd_service s on s.service_type_id = e.id
      inner join prd_product_service ps on ps.service_id = s.id
      inner join prd_product p on ps.product_id = p.id
      cross join com_language_vw l
     where 1 in (
           select
               nvl(min(t.is_visible), a.is_visible)
           from
               prd_service_attribute t
           where
               t.service_id(+) = s.id
               and t.attribute_id(+) = a.id
       )
    ) q
union all
select s.service_type_id id
     , null attr_name
     , null data_type
     , null lov_id
     , null display_order
     , null attr_entity_type
     , null attr_object_type
     , null parent_id
     , p.product_type entity_type
     , l.lang
     , com_api_i18n_pkg.get_text('prd_service', 'label', s.id, l.lang) label
     , com_api_i18n_pkg.get_text('prd_service', 'description', s.id, l.lang) description
     , null scale_id
     , null scale_name
     , p.inst_id
     , s.id service_id
     , p.id product_id
     , null definition_level
  from com_language_vw l
     , prd_product p 
     , prd_service s
     , prd_product_service ps
 where ps.service_id = s.id
   and ps.product_id = p.id
/
