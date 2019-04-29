create or replace force view cmn_api_version_parameter_vw as
with
    version_parameter as (
        select
            v.id                version_id 
            , v.standard_id     standard_id
            , a.id              param_id
            , a.name            param_name
            , a.entity_type     entity_type
            , a.data_type       data_type
            , a.lov_id          lov_id
            , a.default_value   default_value
            , a.xml_default_value
            , a.scale_id
            , a.pattern 
        from 
            cmn_standard_version v
            , cmn_parameter a
        where
            v.standard_id = a.standard_id
    )
select
    prm.version_id 
    , prm.standard_id
    , prm.param_id
    , prm.param_name
    , prm.entity_type param_entity_type
    , prm.data_type
    , prm.lov_id
    , prm.default_value
    , val.param_value
    , prm.xml_default_value
    , val.xml_value
    , prm.scale_id
    , val.id
    , val.object_id
    , val.entity_type
    , val.mod_id
    , prm.pattern
from 
    version_parameter prm
    , cmn_parameter_value val
where
    prm.standard_id = val.standard_id(+)
    and prm.version_id = val.version_id(+)
    and prm.param_id = val.param_id(+)
/
