create table acm_privilege (
    id          number(8)
  , name        varchar2(200)
  , section_id  number(4)
  , module_code varchar2(3)
  , is_active   number(1))
/


comment on table acm_privilege is 'Possible user actions in the system.'
/

comment on column acm_privilege.id is 'Primary key.'
/
comment on column acm_privilege.name is 'Unique system name.'
/
comment on column acm_privilege.section_id is 'Reference on section where action can be done.'
/
comment on column acm_privilege.module_code is 'Reference to system module. Module code.'
/
comment on column acm_privilege.is_active is 'Is Active (0 - No, 1 - Yes).'
/
