create table com_module
(
    id              number(4)
  , name            varchar2(30)
  , module_code     varchar2(3)
)
/

comment on table com_module is 'List of modules installed in system.'
/

comment on column com_module.id is 'Primary key.'
/

comment on column com_module.name is 'Module name.'
/

comment on column com_module.module_code is 'Module code. Using as prefix in naming DB objects.'
/

alter table com_module add (dict_code      varchar2(2))
/

comment on column com_module.dict_code is 'Code dictionary.'
/

