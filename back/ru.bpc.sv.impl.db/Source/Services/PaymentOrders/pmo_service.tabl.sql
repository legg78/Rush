create table pmo_service(
    id        number (8) not null
  , seqnum    number (4)
  , direction number (1)
)
/

comment on table pmo_service is 'Covered services '
/

comment on column pmo_service.id is 'Primary key'
/
comment on column pmo_service.seqnum is 'Data version sequence number'
/
comment on column pmo_service.direction is 'Direction of funds transfering (To customer, From customer)'
/
comment on column pmo_service.direction is 'Direction of funds transfering (-1 = From customer, 1 =  To customer)'
/
alter table pmo_service add inst_id number(4)
/
comment on column pmo_service.inst_id is 'Institution identifier'
/
