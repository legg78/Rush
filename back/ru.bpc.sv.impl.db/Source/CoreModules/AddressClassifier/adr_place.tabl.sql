create table adr_place (
    id          number(8)
  , parent_id   number(8)
  , place_code  varchar2(200)
  , place_name  varchar2(200)
  , comp_id     number(4)
  , comp_level  number(4)
  , postal_code varchar2(10)
  , region_code varchar2(11)
  , lang        varchar2(8) )
/

comment on column adr_place.id is 'Primary key'
/

comment on column adr_place.parent_id is 'Parent ID'
/

comment on column adr_place.place_code is 'Place code'
/

comment on column adr_place.place_name is 'Place name'
/

comment on column adr_place.comp_id is 'Component id ( link to ADR_COMPONENT)'
/

comment on column adr_place.comp_level is 'Comp level'
/

comment on column adr_place.postal_code is 'Postal code'
/

comment on column adr_place.region_code is 'Region code'
/

comment on column adr_place.lang is 'Language  (link to ADR_COMPONENT)'
/