create table vch_voucher (
    id                  number(16)
  , part_key            as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
  , seqnum              number(4 , 0)
  , batch_id            number(16)
  , card_id             number(12)
  , expir_date          date
  , oper_amount         number(22, 4)
  , oper_id             number(16)
  , oper_type           varchar2(8)
  , auth_code           varchar2(6)
  , oper_request_amount number(22, 4)
  , oper_date           date
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition vch_voucher_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))        -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table vch_voucher is 'Vouchers, that contained in a batch.'
/

comment on column vch_voucher.id is 'Primary key.'
/
comment on column vch_voucher.seqnum is 'Sequence number.'
/
comment on column vch_voucher.batch_id is 'Reference to batch.'
/
comment on column vch_voucher.card_id is 'Card ID ( if exists).'
/
comment on column vch_voucher.expir_date is 'Card expiration date.'
/
comment on column vch_voucher.oper_amount is 'Operation amount.'
/
comment on column vch_voucher.oper_id is 'Operation ID.'
/
comment on column vch_voucher.oper_type is 'Operation type.'
/
comment on column vch_voucher.auth_code is 'Auth code.'
/
comment on column vch_voucher.oper_request_amount is 'Operation request amount.'
/
comment on column vch_voucher.oper_date is 'Operation date.'
/
