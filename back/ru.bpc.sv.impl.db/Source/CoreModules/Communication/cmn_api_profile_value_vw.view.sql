create or replace force view cmn_api_profile_value_vw as
select 
    a.object_id profile_id
    , a.param_id
    , b.name param_name
    , nvl(a.param_value, b.default_value) param_value
    , nvl(a.xml_value, b.xml_default_value) xml_value
    , b.standard_id
    , b.data_type
    , b.lov_id
  from cmn_parameter b
     , cmn_parameter_value a
 where b.id = a.param_id
   and a.entity_type = 'ENTTCMPF'
/