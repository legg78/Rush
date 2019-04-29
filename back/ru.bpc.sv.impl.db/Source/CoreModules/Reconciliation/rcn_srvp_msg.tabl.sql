create table rcn_srvp_msg(
    id                      number(16) not null
  , part_key                as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , recon_type              varchar2(8)
  , msg_source              varchar2(8)
  , recon_status            varchar2(8)
  , msg_date                date
  , recon_date              date
  , inst_id                 number(4)
  , split_hash              number(4)
  , order_id                number(16)
  , recon_msg_id            number(16)
  , payment_order_number    varchar2(200)
  , order_date              date
  , order_amount            number(22)
  , order_currency          varchar2(3)
  , customer_id             number(12)
  , customer_number         varchar2(200)
  , purpose_id              number(8)
  , purpose_number          varchar2(200)
  , provider_id             number(8)
  , provider_number         varchar2(200)
  , order_status            varchar2(8)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))
subpartition by list (split_hash)
subpartition template
(
    <subpartition_list>
)
(
  partition rcn_srvp_msg_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))
)
******************** partition end ********************/
/
  
comment on table rcn_srvp_msg is 'Service provider reconciliation messages'
/
comment on column rcn_srvp_msg.id is 'Record identifier'
/
comment on column rcn_srvp_msg.part_key is ''
/
comment on column rcn_srvp_msg.recon_type is 'Reconciliation type. (Dictionary RCNT)'
/
comment on column rcn_srvp_msg.msg_source is 'Message source. (Dictionary RMSC)'
/
comment on column rcn_srvp_msg.recon_status is 'Reconciliation status. (Dictionary RNST)'
/
comment on column rcn_srvp_msg.msg_date is 'Message date and time inserted into the table'
/
comment on column rcn_srvp_msg.recon_date is 'Date and time of last reconciliation process on the message'
/
comment on column rcn_srvp_msg.inst_id is 'Institution identifier'
/
comment on column rcn_srvp_msg.split_hash is 'Split hash'
/
comment on column rcn_srvp_msg.order_id is 'Payment order id'
/
comment on column rcn_srvp_msg.recon_msg_id is 'Reference to reconciled message'
/
comment on column rcn_srvp_msg.payment_order_number is 'Payment order number'
/
comment on column rcn_srvp_msg.order_date is 'Date of payment order'
/
comment on column rcn_srvp_msg.order_amount is 'Payment order amount'
/
comment on column rcn_srvp_msg.order_currency is 'Payment order currency'
/
comment on column rcn_srvp_msg.customer_id is 'Service provider customer id'
/
comment on column rcn_srvp_msg.customer_number is 'Service provider customer number'
/
comment on column rcn_srvp_msg.purpose_id is 'ID of payment order purpose'
/
comment on column rcn_srvp_msg.purpose_number is 'Payment purpose external number'
/
comment on column rcn_srvp_msg.provider_id is 'Service provider identifier'
/
comment on column rcn_srvp_msg.provider_number is 'Service provider external number'
/
comment on column rcn_srvp_msg.order_status is 'Payment order status. Dictionary POSA (Processed, Canceled)'
/
