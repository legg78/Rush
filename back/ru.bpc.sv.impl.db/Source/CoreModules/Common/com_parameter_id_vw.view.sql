create or replace force view com_parameter_id_vw as
select 'app_element' table_name, id, name       from app_element        union all 
select 'cmn_parameter',          id, null       from cmn_parameter      union all
select 'com_flexible_field',     id, name       from com_flexible_field union all
select 'prc_parameter',          id, null       from prc_parameter      union all
select 'prd_attribute',          id, null       from prd_attribute      union all
select 'prd_service',            id, null       from prd_service        union all
select 'prd_service_type',       id, null       from prd_service_type   union all  
select 'rpt_parameter',          id, null       from rpt_parameter      union all
select 'rul_mod_param',          id, null       from rul_mod_param      union all
select 'set_parameter',          id, null       from set_parameter
/