create table pmo_order_detail (
    id          number(16)
  , part_key    as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , order_id    number(16)
  , entity_type varchar2(8)
  , object_id   number(16)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition pmo_order_detail_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/

comment on table pmo_order_detail is 'Financial messages or other entities concerned with payment order.'
/
comment on column pmo_order_detail.id is 'Primary key'
/
comment on column pmo_order_detail.order_id is 'Reference to payment order'
/
comment on column pmo_order_detail.entity_type is 'Entity type of related object'
/
comment on column pmo_order_detail.object_id is 'Object identifier'
/
