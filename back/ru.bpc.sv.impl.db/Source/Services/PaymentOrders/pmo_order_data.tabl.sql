create table pmo_order_data (
    id          number(16)
  , part_key    as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , order_id    number(16)
  , param_id    number(8)
  , param_value varchar2(2000)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                    -- [@skip patch]
(
    partition pmo_order_data_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/

comment on table pmo_order_data is 'Payment order details'
/
comment on column pmo_order_data.id is 'Primary key'
/
comment on column pmo_order_data.order_id is 'Reference to payment order'
/
comment on column pmo_order_data.param_id is 'Reference to payment parameter'
/
comment on column pmo_order_data.param_value is 'Parameter value'
/
alter table pmo_order_data add (purpose_id number(8), direction number(1))
/
comment on column pmo_order_data.purpose_id is 'Reference to purpose which contain parameter'
/
comment on column pmo_order_data.direction is 'Direction of parameter purpose (1 - in, -1 - out)'
/
