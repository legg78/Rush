create table qpr_param(
    id  number(16) not null
  , param_name varchar2(50 byte)
  , param_desc varchar2(240 byte)
  , single_value number(1,0))
/

comment on table qpr_param  is 'Parameters for VISA and MC quarter reports'
/
comment on column qpr_param.id is 'Identifier'
/
comment on column qpr_param.param_name is 'Parameter name'
/
comment on column qpr_param.param_desc is 'Parameter description'
/
comment on column qpr_param.single_value is 'Is single value: 1 - single value; 0 - multiple value'
/
alter table qpr_param modify param_name varchar2(100)
/
