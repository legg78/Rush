create table iss_cardholder (
    id                  number(12) not null
    , person_id         number(12)
    , cardholder_number varchar2(200)
    , cardholder_name   varchar2(200)
    , inst_id           number(4)
    , seqnum            number(4)
)
/
comment on table iss_cardholder is 'Cardholders'
/
comment on column iss_cardholder.id is 'Cardholder Identifier'
/
comment on column iss_cardholder.person_id is 'Person identifier'
/
comment on column iss_cardholder.cardholder_number is 'External cardholder number'
/
comment on column iss_cardholder.cardholder_name is 'Cardholder embossing name'
/
comment on column iss_cardholder.inst_id is 'Owner institution identifier'
/
comment on column iss_cardholder.seqnum is 'Sequential number of data'
/
alter table iss_cardholder add relation varchar2(8)
/
alter table iss_cardholder add resident number(1)
/
alter table iss_cardholder add nationality varchar2(3)
/
alter table iss_cardholder add marital_status varchar2(8)
/
comment on column iss_cardholder.relation is 'Relationship client to bank (RSCB dictionary)'
/
comment on column iss_cardholder.resident is 'Cardholder is a resident of bank allocation country (1-yes, 0-no)'
/
comment on column iss_cardholder.nationality is 'Customer nationality (ISO code)'
/
comment on column iss_cardholder.marital_status is 'Marital status (MRST dictionary)'
/
