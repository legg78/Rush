create or replace force view cmn_parameter_value_vw as
select 
    id
    , param_id
    , standard_id
    , version_id
    , entity_type
    , object_id
    , param_value
    , xml_value
    , mod_id
from
    cmn_parameter_value
/
