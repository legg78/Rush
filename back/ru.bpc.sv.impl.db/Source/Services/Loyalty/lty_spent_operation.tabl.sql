create table lty_spent_operation (
    id                   number(16)
  , part_key             as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , spent_oper_id        number(16)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition lty_spent_operation_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/

comment on table lty_spent_operation is 'Reward loyalty spent operations'
/
comment on column lty_spent_operation.id is 'Primary key.(=opr_operation.id)'
/
comment on column lty_spent_operation.spent_oper_id is 'Reward spending operation id.'
/
 
