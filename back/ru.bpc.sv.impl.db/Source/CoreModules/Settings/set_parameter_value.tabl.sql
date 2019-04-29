create table set_parameter_value
(
  param_id     number(8),
  param_level  varchar2(8),
  level_value  varchar2(200),
  param_value  varchar2(200), 
  constraint set_parameter_value_pk primary key (param_id, param_level, level_value)
) organization index
/

comment on table set_parameter_value is 'Parameter defined values.'
/

comment on column set_parameter_value.param_id is 'Reference to parameter primary key'
/

comment on column set_parameter_value.param_level is 'Level type where value is defined. Possible values: PLVLSYST, PLVLINST, PLVLAGNT, PLVLUSER.'
/

comment on column set_parameter_value.level_value is 'Entity identifier corresponding to value level: Institution ID, Agent ID or User ID.'
/

comment on column set_parameter_value.param_value is 'Value of parameter.'
/
alter table set_parameter_value add id number(8)
/
comment on column set_parameter_value.id is 'Primary key'
/
create table set_parameter_value_copy as select nvl(id, m.max_id + rownum) id
                                              , v.param_id
                                              , v.param_level
                                              , v.level_value
                                              , v.param_value
                                           from set_parameter_value v
                                              , (select nvl(max(id), 0) max_id
                                                   from set_parameter_value) m
/
drop table set_parameter_value
/
alter table set_parameter_value_copy rename to set_parameter_value
/
comment on table set_parameter_value is 'Parameter defined values.'
/
comment on column set_parameter_value.param_id is 'Reference to parameter primary key'
/
comment on column set_parameter_value.param_level is 'Level type where value is defined. Possible values: PLVLSYST, PLVLINST, PLVLAGNT, PLVLUSER.'
/
comment on column set_parameter_value.level_value is 'Entity identifier corresponding to value level: Institution ID, Agent ID or User ID.'
/
comment on column set_parameter_value.param_value is 'Value of parameter.'
/
comment on column set_parameter_value.id is 'Primary key'
/
