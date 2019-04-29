create table opr_additional_amount
(
    oper_id      number(16)   not null
  , part_key     as (to_date(substr(lpad(to_char(oper_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , amount_type  varchar2(8)  not null
  , currency     varchar2(3)
  , amount       number(22,4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition opr_additional_amount_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/
comment on table opr_additional_amount is 'Additional amounts for an operation'
/
comment on column opr_additional_amount.oper_id is 'Operation ID'
/
comment on column opr_additional_amount.amount_type is 'Type of amount'
/
comment on column opr_additional_amount.currency is 'Amount currency'
/
comment on column opr_additional_amount.amount is 'Value of amount in currency'
/

