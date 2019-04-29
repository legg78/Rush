create table adr_component (
    id           number(4)
  , lang         varchar2(8)
  , abbreviation varchar2(200)
  , comp_name    varchar2(200)
  , comp_level   number(4)
  , country_id   number(4))
/

comment on column adr_component.id is 'Primary Key'
/

comment on column adr_component.abbreviation is 'Abbreviation'
/

comment on column adr_component.comp_name is 'Name of component'
/

comment on column adr_component.comp_level is 'Level of component.'
/

comment on column adr_component.lang is 'Language'
/

comment on column adr_component.country_id is 'Country ID ( link to COM_COUNTRY)'
/

