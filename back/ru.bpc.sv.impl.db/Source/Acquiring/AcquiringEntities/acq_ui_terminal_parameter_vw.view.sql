create or replace force view acq_ui_terminal_parameter_vw as
with ver as (
    select v.object_id         object_id
         , 'ENTTTRMN'          entity_type
         , v.version_id
         , p.standard_id
         , p.param_id
         , p.data_type
         , p.lov_id
         , nvl(p.param_value, p.default_value)   default_value
         , p.caption
         , p.param_name
         , p.lang
         , p.scale_id
         , p.scale_name
         , nvl(p.xml_value, p.xml_default_value) xml_default_value
         , p.pattern
      from cmn_standard_version_obj v
         , cmn_ui_version_parameter_vw p
     where v.entity_type       = 'ENTTTRMN'
       and v.version_id        = p.version_id
       and p.param_entity_type = 'ENTTTRMN'
    )
, std as (
    select s.object_id     object_id
         , 'ENTTTRMN'      entity_type
         , null            version_id
         , s.standard_id
         , p.id            param_id
         , p.data_type
         , p.lov_id
         , p.default_value
         , p.caption
         , p.name          param_name
         , p.lang
         , p.scale_id
         , p.scale_name
         , p.xml_default_value
         , p.pattern
      from cmn_standard_object s
         , cmn_ui_parameter_vw p
     where s.entity_type = 'ENTTTRMN'
       and s.standard_id = p.standard_id
       and p.entity_type = 'ENTTTRMN'
    )
select 'ENTTSTVR' param_level
      , val.id
      , val.param_value
      , ver.object_id
      , ver.entity_type
      , ver.version_id
      , ver.standard_id
      , ver.param_id
      , ver.data_type
      , ver.lov_id
      , nvl(def_val.param_value, ver.default_value) default_value
      , ver.caption
      , ver.param_name
      , ver.lang
      , get_number_value(ver.data_type, nvl(def_val.param_value, ver.default_value)) default_number_value
      , get_char_value  (ver.data_type, nvl(def_val.param_value, ver.default_value)) default_char_value
      , get_date_value  (ver.data_type, nvl(def_val.param_value, ver.default_value)) default_date_value
      , get_lov_value   (ver.data_type, nvl(def_val.param_value, ver.default_value), ver.lov_id) default_lov_value
      , get_number_value(ver.data_type, val.param_value) param_number_value
      , get_char_value  (ver.data_type, val.param_value) param_char_value
      , get_date_value  (ver.data_type, val.param_value) param_date_value
      , get_lov_value   (ver.data_type, val.param_value, ver.lov_id) param_lov_value
      , val.mod_id
      , get_text('rul_mod', 'name', val.mod_id, ver.lang ) as mod_name
      , ver.scale_id
      , ver.scale_name
      , nvl(def_val.xml_value, ver.xml_default_value) default_xml_value
      , val.xml_value xml_value
      , ver.pattern
   from ver
      , cmn_parameter_value val
      , cmn_parameter_value def_val
  where ver.object_id   = val.object_id(+)
    and ver.entity_type = val.entity_type(+)
    and ver.param_id    = val.param_id(+)
    and ver.standard_id = val.standard_id(+)
    and ver.version_id  = val.version_id(+)
    and ver.object_id   = def_val.object_id(+)
    and ver.entity_type = def_val.entity_type(+)
    and ver.param_id    = def_val.param_id(+)
    and ver.standard_id = def_val.standard_id(+)
    and def_val.version_id(+) is null
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
      , std.caption
      , std.param_name
      , std.lang
      , get_number_value(std.data_type, std.default_value) default_number_value
      , get_char_value  (std.data_type, std.default_value) default_char_value
      , get_date_value  (std.data_type, std.default_value) default_date_value
      , get_lov_value   (std.data_type, std.default_value, std.lov_id) default_lov_value
      , get_number_value(std.data_type, val.param_value) param_number_value
      , get_char_value  (std.data_type, val.param_value) param_char_value
      , get_date_value  (std.data_type, val.param_value) param_date_value
      , get_lov_value   (std.data_type, val.param_value, std.lov_id) param_lov_value
      , val.mod_id
      , get_text('rul_mod', 'name', val.mod_id, std.lang ) as mod_name
      , std.scale_id
      , std.scale_name
      , std.xml_default_value default_xml_value
      , val.xml_value xml_value
      , std.pattern
   from std
      , cmn_parameter_value val
  where std.object_id     = val.object_id(+)
    and std.entity_type   = val.entity_type(+)
    and std.param_id      = val.param_id(+)
    and std.standard_id   = val.standard_id(+)
    and val.version_id(+) is null
/
