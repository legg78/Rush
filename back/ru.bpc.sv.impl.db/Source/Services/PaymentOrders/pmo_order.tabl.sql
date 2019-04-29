create table pmo_order (
    id                  number(16)
  , part_key            as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , customer_id         number(12)
  , entity_type         varchar2(8)
  , object_id           number(16)
  , purpose_id          number(8)
  , template_id         number(16)
  , amount              number(22,4)
  , currency            varchar2(3)
  , event_date          date
  , status              varchar2(8)
  , inst_id             number(4)
  , attempt_count       number(4)
  , split_hash          number(4)
  , is_template         number(1)
  , templ_status        varchar2(8)
  , is_prepared_order   number(1)
  , dst_customer_id     number(12)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                       -- [@skip patch]
subpartition by list (split_hash)                                                         -- [@skip patch]
subpartition template                                                                     -- [@skip patch]
(                                                                                         -- [@skip patch]
    <subpartition_list>                                                                   -- [@skip patch]
)                                                                                         -- [@skip patch]
(                                                                                         -- [@skip patch]
    partition pmo_order_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))           -- [@skip patch]
)                                                                                         -- [@skip patch]
******************** partition end ********************/
/

comment on table pmo_order is 'Payment orders'
/
comment on column pmo_order.id is 'Primary key'
/
comment on column pmo_order.customer_id is 'Customer identifier'
/
comment on column pmo_order.entity_type is 'An entity type used for payment (Card, Account, Terminal etc)'
/
comment on column pmo_order.object_id is 'Payment object identifier'
/
comment on column pmo_order.purpose_id is 'Reference to payment purpose'
/
comment on column pmo_order.template_id is 'Reference to template if order was created by template'
/
comment on column pmo_order.amount is 'Payment amount'
/
comment on column pmo_order.currency is 'Payment currency'
/
comment on column pmo_order.event_date is 'Date of event created an order.'
/
comment on column pmo_order.status is 'Order status (Awaiting processing, Processed, Canceled)'
/
comment on column pmo_order.inst_id is 'Institution identifier'
/
comment on column pmo_order.attempt_count is 'Count of attempts to process order (Insufficient funds)'
/
comment on column pmo_order.split_hash is 'Hash value to split further processing.'
/
comment on column pmo_order.is_template is 'Template flag'
/
comment on column pmo_order.templ_status is 'Template status (Valid, Invalid).'
/
comment on column pmo_order.is_prepared_order is 'Template based on prepared order.'
/
comment on column pmo_order.dst_customer_id is 'Payment order destination customer'
/
alter table pmo_order add (in_purpose_id number(8))
/
comment on column pmo_order.in_purpose_id is 'Source of incoming funds'
/
alter table pmo_order add (payment_order_number varchar2(200))
/
comment on column pmo_order.payment_order_number is 'Payment order number'
/

alter table pmo_order add (expiration_date date)
/
comment on column pmo_order.expiration_date is 'Payment order expiration date'
/
alter table pmo_order add (resp_code varchar2(8))
/
comment on column pmo_order.resp_code is 'Payment order response code'
/
alter table pmo_order add (resp_amount number(22,4))
/
comment on column pmo_order.resp_amount is 'Payment order response amount'
/
begin
    for rec in (select count(1) cnt from user_tab_columns where table_name = 'PMO_ORDER' and column_name = 'PART_KEY')
    loop
        if rec.cnt = 0 then
            execute immediate 'alter table pmo_order add (part_key as (to_date(substr(lpad(to_char(id), 16, ''0''), 1, 6), ''yymmdd'')) virtual)';
            execute immediate 'comment on column pmo_order.part_key is ''Partition key''';
        end if;
    end loop;
end;
/
alter table pmo_order add (originator_refnum varchar2(36))
/
comment on column pmo_order.originator_refnum is 'This is originator_refnum from opr_operation. It used for match orders with operation via opr_oper_detail'
/
