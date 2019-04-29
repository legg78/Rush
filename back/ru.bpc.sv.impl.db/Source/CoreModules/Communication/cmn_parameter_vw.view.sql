create or replace force view cmn_parameter_vw as
select a.id
     , a.standard_id
     , a.name
     , a.entity_type
     , a.data_type
     , a.lov_id
     , a.default_value
     , a.xml_default_value
     , a.scale_id
     , a.pattern
  from cmn_parameter a
/