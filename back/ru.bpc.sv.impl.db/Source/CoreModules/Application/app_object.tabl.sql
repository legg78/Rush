create table app_object(
    appl_id         number(16)
  , part_key        as (to_date(substr(lpad(to_char(appl_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , entity_type     varchar2(8)
  , object_id       number(16)
  , seqnum          number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition app_object_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))         -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table app_object is 'Objects modified by application'
/

comment on column app_object.appl_id is 'Reference to application'
/
comment on column app_object.entity_type is 'Type of entity modified in application'
/
comment on column app_object.object_id is 'Identifier of object modified in application'
/
comment on column app_object.seqnum is 'Sequential number of data version'
/
