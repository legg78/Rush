create or replace force view pmo_api_order_data_vw as
select d.id
     , d.order_id
     , d.param_id
     , d.param_value
     , p.param_name
     , p.tag_id
     , p.data_type
  from pmo_order_data d
     , pmo_parameter p
 where d.param_id = p.id
/
