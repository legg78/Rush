create or replace force view net_ui_interface_parameter_vw as
select t.param_level
     , t.id
     , t.param_value
     , t.object_id 
     , t.entity_type
     , t.version_id
     , t.standard_id
     , t.param_id
     , t.data_type
     , t.lov_id
     , t.default_value
     , get_text ('cmn_parameter', 'caption', t.param_id, l.lang) caption            
     , t.param_name
     , l.lang
     , get_number_value(t.data_type, t.default_value) default_number_value
     , get_char_value  (t.data_type, t.default_value) default_char_value
     , get_date_value  (t.data_type, t.default_value) default_date_value
     , get_lov_value   (t.data_type, t.default_value, t.lov_id) default_lov_value
     , get_number_value(t.data_type, t.param_value) param_number_value
     , get_char_value  (t.data_type, t.param_value) param_char_value
     , get_date_value  (t.data_type, t.param_value) param_date_value
     , get_lov_value   (t.data_type, t.param_value, t.lov_id) param_lov_value
     , t.mod_id
     , get_text('rul_mod', 'name', t.mod_id, l.lang ) as mod_name
     , t.scale_id
     , get_text ('rul_mod_scale', 'name', t.scale_id, l.lang) scale_name
     , t.xml_value
     , t.default_xml_value 
     , t.pattern
  from (
        with interface_version as (
            select i.id 
                 , v.standard_id
                 , ov.version_id
              from net_interface i
                 , cmn_standard_version_obj ov
                 , cmn_standard_version v     
             where i.host_member_id    = ov.object_id
               and ov.entity_type      = 'ENTTHOST'         
               and ov.version_id = v.id
        ),
        version_parameter as (
            select v.id version_id
                 , v.standard_id standard_id
                 , a.id param_id
                 , a.name param_name
                 , a.entity_type entity_type
                 , a.data_type data_type
                 , a.lov_id lov_id
                 , a.default_value default_value
                 , a.xml_default_value
                 , a.scale_id
                 , a.pattern
              from cmn_standard_version v
                 , cmn_parameter a
             where v.standard_id = a.standard_id
        ),
        interface_param_val as (
            select iv.id object_id
                 , iv.standard_id
                 , iv.version_id
                 , pr.param_id
                 , pr.param_name
                 , pr.data_type
                 , pr.default_value
                 , pr.xml_default_value
                 , pr.scale_id
                 , pr.entity_type
                 , pr.lov_id
                 , pr.pattern
              from interface_version iv
                 , version_parameter pr
             where iv.version_id  = pr.version_id
               and pr.entity_type = 'ENTTNIFC'
        )
        , interface_standard as (
            select i.id          object_id
                 , 'ENTTNIFC'    entity_type
                 , null          version_id
                 , s.standard_id
                 , p.id          param_id
                 , p.data_type
                 , p.lov_id
                 , p.default_value
                 , p.name        param_name
                 , p.scale_id
                 , p.pattern
              from net_interface i
                 , cmn_standard_object s
                 , cmn_parameter p
             where i.host_member_id = s.object_id
               and s.entity_type    = 'ENTTHOST'
               and s.standard_id    = p.standard_id
               and p.entity_type    = 'ENTTNIFC'
        )        
       select 'ENTTSTVR' param_level
            , v1.id
            , coalesce (v1.param_value, v2.param_value, i.default_value) param_value
            , i.object_id 
            , i.entity_type
            , i.version_id
            , i.standard_id
            , i.param_id
            , i.data_type
            , i.lov_id
            , nvl(v2.param_value, i.default_value) default_value
            , i.param_name
            , v1.mod_id
            , i.scale_id
            , coalesce (v1.xml_value, v2.xml_value, i.xml_default_value) xml_value
            , nvl(v2.xml_value, i.xml_default_value) default_xml_value
            , i.pattern
         from interface_param_val i
            , cmn_parameter_value v1
            , cmn_parameter_value v2
        where v1.param_id(+)    = i.param_id
          and v1.entity_type(+) = 'ENTTNIFC'
          and v1.object_id(+)   = i.object_id
          and v1.standard_id(+) = i.standard_id
          and v1.version_id(+)  = i.version_id
          and v2.param_id(+)    = i.param_id
          and v2.entity_type(+) = 'ENTTNIFC'
          and v2.object_id(+)   = i.object_id
          and v2.standard_id(+) = i.standard_id
          and v2.version_id(+) is null    
    union all
       select 'ENTTSTDR' param_level
            , val.id
            , val.param_value
            , std.object_id
            , std.entity_type
            , std.version_id
            , std.standard_id
            , std.param_id
            , std.data_type
            , std.lov_id
            , std.default_value
            , std.param_name
            , val.mod_id
            , std.scale_id
            , null as default_xml_value
            , val.xml_value
            , std.pattern
         from interface_standard std
            , cmn_parameter_value val
        where std.object_id    = val.object_id(+)
          and std.entity_type  = val.entity_type(+)
          and std.param_id     = val.param_id(+)
          and std.standard_id  = val.standard_id(+)
          and val.version_id(+) is null                     
  ) t
  , com_language_vw l 
/
