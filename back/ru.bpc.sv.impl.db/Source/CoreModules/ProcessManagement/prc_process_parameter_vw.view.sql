create or replace force view prc_process_parameter_vw as
select
    a.id
    , a.process_id
    , a.param_id
    , a.default_value
    , a.display_order
    , a.is_format
    , a.is_mandatory
    , a.lov_id
from
    prc_process_parameter a
/
