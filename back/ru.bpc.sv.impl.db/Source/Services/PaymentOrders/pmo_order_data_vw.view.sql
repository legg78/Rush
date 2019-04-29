create or replace force view pmo_order_data_vw as
select
    a.id
  , a.order_id
  , a.param_id
  , a.param_value
  , a.purpose_id
  , a.direction
from
    pmo_order_data a
/

