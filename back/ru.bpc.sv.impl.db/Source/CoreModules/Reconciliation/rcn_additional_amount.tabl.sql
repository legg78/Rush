create table rcn_additional_amount (
    rcn_id        number(16)
 ,  part_key       as (to_date(substr(lpad(to_char(rcn_id), 16, '0'), 1, 6), 'yymmdd')) virtual
 ,  rcn_type      varchar2(8)
 ,  amount_type   varchar2(8)
 ,  currency      varchar2(3)
 ,  amount       number(22,4)
)
/***************** partition start *******************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))
(
    partition rcn_additional_amount_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))
)
******************* partition end *******************/
/
comment on table rcn_additional_amount is 'Additional amount table'
/
comment on column rcn_additional_amount.rcn_id is 'A reconciliation message row identifier'
/
comment on column rcn_additional_amount.rcn_type is 'Reconciliation type. Dictionary RCNT'
/
comment on column rcn_additional_amount.amount_type is 'Type of amount. Dictionary AMPR'
/
comment on column rcn_additional_amount.currency is 'ISO amount currency'
/
comment on column rcn_additional_amount.amount is 'Value of amount in currency'
/
