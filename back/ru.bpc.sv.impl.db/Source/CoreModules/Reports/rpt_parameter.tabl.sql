create table rpt_parameter (
    id             number(8)
  , seqnum         number(4)
  , report_id      number(8)
  , param_name     varchar2(200)
  , data_type      varchar2(8)
  , default_value  varchar2(2000)
  , is_mandatory   number(1)
  , display_order  number(4)
  , lov_id         number(4))
/

comment on table rpt_parameter is 'Report parameters.'
/

comment on column rpt_parameter.id is 'Primary key.'
/

comment on column rpt_parameter.seqnum is 'Data version sequential number.'
/

comment on column rpt_parameter.report_id is 'Reference to report.'
/

comment on column rpt_parameter.param_name is 'Parameter name like it used in report query.'
/

comment on column rpt_parameter.data_type is 'Parameter data type.'
/

comment on column rpt_parameter.default_value is 'Default value. Using if value was not defined by user.'
/

comment on column rpt_parameter.is_mandatory is 'Option if value is mandatory.'
/

comment on column rpt_parameter.display_order is 'Order for displaying list of parameter on interface.'
/

comment on column rpt_parameter.lov_id is 'Reference to list of possible values.'
/

alter table rpt_parameter add direction number(1)
/
alter table rpt_parameter add is_grouping number(1)
/
alter table rpt_parameter add is_sorting number(1)
/
comment on column rpt_parameter.direction is 'Direction (input - 1 / output - 0).'
/
comment on column rpt_parameter.is_grouping is 'Parameter is grouping.'
/
comment on column rpt_parameter.is_sorting is 'Parameter is sorting.'
/
alter table rpt_parameter add selection_form varchar2(200 char)
/
comment on column rpt_parameter.selection_form is 'Custom visual form for selecting parameter.'
/
