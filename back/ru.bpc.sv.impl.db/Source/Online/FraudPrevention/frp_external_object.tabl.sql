create table frp_external_object
(
    id              number(16)
  , part_key            as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual        -- [@skip patch]
  , entity_type     varchar2(8)
  , external_id     varchar2(200)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition frp_external_obj_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table frp_external_object is 'External objects (Terminals, Cards) participants of authorizations'
/

comment on column frp_external_object.id is 'Primary key'
/
comment on column frp_external_object.entity_type is 'Entity type (Terminal, Merchant or Card)'
/
comment on column frp_external_object.external_id is 'Unique external identifier of object'
/
