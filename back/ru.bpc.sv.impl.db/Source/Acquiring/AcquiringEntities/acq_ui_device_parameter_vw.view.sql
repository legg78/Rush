create or replace force view acq_ui_device_parameter_vw as
with
    std as (
        select
            s.object_id     object_id
            , 'ENTTCMDV'    entity_type
            , null          version_id
            , s.standard_id
            , p.id          param_id
            , p.data_type
            , p.lov_id
            , p.default_value
            , p.caption
            , p.name        param_name
            , p.lang
            , p.scale_id
            , p.scale_name
            , p.pattern
        from 
            cmn_standard_object s
            , cmn_ui_parameter_vw p
        where
            s.standard_type = 'STDT0002'
            and s.entity_type = 'ENTTCMDV'
            and s.standard_id = p.standard_id
            and p.entity_type = 'ENTTCMDV'
    )
select
    'ENTTSTDR' param_level
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
    , std.pattern
from
    std
    , cmn_parameter_value val
where
    std.object_id = val.object_id(+)
    and std.entity_type = val.entity_type(+)
    and std.param_id = val.param_id(+)
    and std.standard_id = val.standard_id(+)
    and val.version_id(+) is null
/
