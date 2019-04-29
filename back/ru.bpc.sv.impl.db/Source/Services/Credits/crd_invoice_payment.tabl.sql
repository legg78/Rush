create table crd_invoice_payment
(
    id          number(16)
  , part_key    as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , invoice_id  number(12)
  , pay_id      number(16)
  , pay_amount  number(22,4)
  , is_new      number(1)
  , split_hash  number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                          -- [@skip patch]
subpartition by list (split_hash)                                                            -- [@skip patch]
subpartition template                                                                        -- [@skip patch]
(                                                                                            -- [@skip patch]
    <subpartition_list>                                                                      -- [@skip patch]
)                                                                                            -- [@skip patch]
(                                                                                            -- [@skip patch]
    partition crd_invoice_payment_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))  -- [@skip patch]
)                                                                                            -- [@skip patch]
******************** partition end ********************/
/

comment on table crd_invoice_payment is 'Payments included into invoices.'
/

comment on column crd_invoice_payment.id is 'Primary key.'
/
comment on column crd_invoice_payment.invoice_id is 'Invoice identifier.'
/
comment on column crd_invoice_payment.pay_id is 'Payment identifier.'
/
comment on column crd_invoice_payment.pay_amount is 'Paid amount.'
/
comment on column crd_invoice_payment.is_new is 'New payment meaning that it was made in current billing period.'
/
comment on column crd_invoice_payment.split_hash is 'Hash value to split further processing.'
/
