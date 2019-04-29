create table rul_proc_param (
    id            number(8)
  , proc_id       number(4)
  , param_name    varchar2(30)
  , lov_id        number(4)
  , display_order number(4)
  , is_mandatory  number(1)
  , param_id      number(8))
/

comment on table rul_proc_param is 'List of parameters of rules processing procedures'
/

comment on column rul_proc_param.id is 'Identifier'
/

comment on column rul_proc_param.proc_id is 'Procedure identifier'
/

comment on column rul_proc_param.param_name is 'Parameter name'
/

comment on column rul_proc_param.lov_id is 'List of values for parameter'
/

comment on column rul_proc_param.display_order is 'Display order'
/

comment on column rul_proc_param.is_mandatory is 'Is mandatory parameter '
/

comment on column rul_proc_param.param_id is 'Parameter ID ( reference to RUL_MOD_PARAM.ID)'
/