create or replace force view app_ui_attribute_service_vw as
select a.id
     , a.attr_name
     , a.data_type
     , a.lov_id
     , a.display_order
     , a.entity_type attr_entity_type
     , a.object_type attr_object_type
     , a.parent_id
     , 'ENTTSRVC' entity_type
     , l.lang
     , get_text('prd_attribute', 'label', a.id, l.lang) label
     , get_text('prd_attribute', 'description', a.id, l.lang) description
     , y.scale_id
     , get_text('rul_mod_scale', 'name', y.scale_id, l.lang) scale_name
     , y.inst_id
     , s.id service_id
     , get_text('prd_service', 'label', s.id, l.lang) service_label
     , a.definition_level
     , a.is_visible
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
 where y.attr_id = a.id 
   and a.service_type_id = e.id
   and s.service_type_id = e.id
/