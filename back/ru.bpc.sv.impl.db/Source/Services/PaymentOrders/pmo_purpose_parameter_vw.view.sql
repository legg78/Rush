create or replace force view pmo_purpose_parameter_vw as
select
    a.id
  , a.seqnum
  , a.param_id
  , a.purpose_id
  , a.order_stage
  , a.display_order
  , a.is_mandatory
  , a.is_template_fixed
  , a.is_editable
  , a.default_value
  , a.param_function
from
    pmo_purpose_parameter a
/
