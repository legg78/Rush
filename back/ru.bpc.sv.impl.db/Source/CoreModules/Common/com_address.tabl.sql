create table com_address (
    id                  number(12)
  , seqnum              number(4)
  , lang                varchar2(8)
  , country             varchar2(3)
  , region              varchar2(200)
  , city                varchar2(200)
  , street              varchar2(200)
  , house               varchar2(200)
  , apartment           varchar2(200)
  , postal_code         varchar2(10)
  , region_code         varchar2(8)
  , latitude            number(10,7)
  , longitude           number(10,7)
  , inst_id             number(4)
)
/

comment on table com_address is 'Addresses.'
/
comment on column com_address.id is 'Primary key'
/
comment on column com_address.seqnum is 'Sequence number. Describe data version.'
/
comment on column com_address.lang is 'Address description language.'
/
comment on column com_address.country is 'Country ISO code.'
/
comment on column com_address.region is 'Region name.'
/
comment on column com_address.city is 'City.'
/
comment on column com_address.street is 'Street.'
/
comment on column com_address.house is 'House.'
/
comment on column com_address.apartment is 'Office/apartment.'
/
comment on column com_address.postal_code is 'Postal code.'
/
comment on column com_address.region_code is 'Region code.'
/
comment on column com_address.latitude is 'Geographic coordinate - Latitude (N)'
/
comment on column com_address.longitude is 'Geographic coordinate - Longitude (W)'
/
comment on column com_address.inst_id is 'Owner institution identifier.'
/
alter table com_address modify (region_code varchar2(20 char))
/
alter table com_address add (place_code varchar2(200 char))
/
comment on column com_address.place_code is 'Place code.'
/
alter table com_address add (comments varchar2(200 char))
/
comment on column com_address.comments is 'Custom comment for address name'
/
