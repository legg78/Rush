create table com_lov (
    id              number(4)
  , dict            varchar2(8)
  , lov_query       varchar2(2000)
  , module_code     varchar2(3)
  , sort_mode       varchar2(8)
  , appearance      varchar2(8)
  , data_type       varchar2(8)
  , is_parametrized number(1) )
/

comment on table com_lov is 'Dictionary of queries returning avalable values for exact parameter.'
/
comment on column com_lov.id is 'Primary key.'
/
comment on column com_lov.dict is 'Dictionary code if avalable values is a list of dictionary articles.'
/
comment on column com_lov.lov_query is 'Custom query returning avalable values in two columns. CODE - value, NAME - description.'
/
comment on column com_lov.module_code is 'Module code.'
/
comment on column com_lov.sort_mode is 'Sort mode'
/
comment on column com_lov.appearance is 'Lov value appearance'
/
comment on column com_lov.data_type is 'Values data type.'
/
comment on column com_lov.is_parametrized is 'LOV has parameters: 1 - yes, 0 - no.'
/
alter table com_lov add is_depended number(1)
/
comment on column com_lov.is_depended is 'LOV query is depended on parameters: 1 - yes, 0 - no.'
/
alter table com_lov add is_editable number(1)
/
comment on column com_lov.is_editable is 'This flag is for using on GUI. If it is set to 1, a user is allowed to input its own string. Otherwise, a user has to choose among values of the LOV'
/
