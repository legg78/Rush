create table ecm_order
(
    id                      number(16)
  , part_key                as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , merchant_id             number(8)
  , order_uuid              varchar2(200)
  , order_number            varchar2(200)
  , order_details           varchar2(2000)
  , customer_identifier     varchar2(200)
  , customer_name           varchar2(200)
  , success_url             varchar2(200)
  , fail_url                varchar2(200)
  , split_hash              number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
subpartition by list (split_hash)
subpartition template
(
    <subpartition_list>
)
(
    partition ecm_order_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)
******************** partition end ********************/
/

comment on table ecm_order is 'Customer order data'
/

comment on column ecm_order.id is 'Primary key. Equal with identifier in PMO_ORDER'
/

comment on column ecm_order.merchant_id is 'Reference to merchant'
/

comment on column ecm_order.order_uuid is 'Order unique identifier'
/

comment on column ecm_order.order_number is 'External order number provided by merchant'
/
comment on column ecm_order.order_details is 'Order details'
/
comment on column ecm_order.customer_identifier is 'Customer identifier in internet store'
/
comment on column ecm_order.customer_name is 'Customer name provided in request'
/
comment on column ecm_order.split_hash is 'Hash value to split further processing'
/
comment on column ecm_order.success_url is 'URL should called if operation was succeded'
/
comment on column ecm_order.fail_url is 'URL should called if operation was failed'
/
