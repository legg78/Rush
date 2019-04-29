create or replace force view rpt_parameter_vw as
select id
     , seqnum
     , report_id
     , param_name
     , data_type
     , default_value
     , is_mandatory
     , display_order
     , lov_id
     , direction
     , is_grouping
     , is_sorting
     , selection_form
from rpt_parameter
/
 