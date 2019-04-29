create table acc_entry (
    id                  number(16)
    , part_key          as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , split_hash        number(4)
    , macros_id         number(16)
    , bunch_id          number(16)
    , transaction_id    number(16)
    , transaction_type  varchar2(8)
    , account_id        number(12)
    , amount            number(22, 4)
    , currency          varchar2(3)
    , balance_type      varchar2(8)
    , balance_impact    number(1)
    , balance           number(22, 4)
    , rounding_balance  number(22, 4)
    , posting_date      date
    , posting_order     number(8)
    , sttl_day          number(8)
    , sttl_date         date
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                  -- [@skip patch]
subpartition by list (split_hash)
subpartition template
(
    <subpartition_list>
)
(
  partition acc_entry_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))        -- [@skip patch]
)
******************** partition end ********************/
/

comment on table acc_entry is 'posted entries are stored here'
/

comment on column acc_entry.id is 'entry identifier'
/
comment on column acc_entry.split_hash is 'Hash value to split further processing'
/
comment on column acc_entry.macros_id is 'macros identifier which entry belongs to'
/
comment on column acc_entry.bunch_id is 'Bunch identifier'
/
comment on column acc_entry.transaction_id is 'transaction identifier which entry belongs to'
/
comment on column acc_entry.transaction_type is 'transaction type which entry belongs to'
/
comment on column acc_entry.account_id is 'account identifier'
/
comment on column acc_entry.amount is 'entry amount'
/
comment on column acc_entry.currency is 'entry currency'
/
comment on column acc_entry.balance_type is 'balance type which entry affects'
/
comment on column acc_entry.balance_impact is 'impact of entry on balance'
/
comment on column acc_entry.balance is 'resulting balance after entry posting'
/
comment on column acc_entry.rounding_balance is 'Resulting of balance rounding after entry posting'
/
comment on column acc_entry.posting_date is 'date of entry posting'
/
comment on column acc_entry.posting_order is 'order of entry posting on balance'
/
comment on column acc_entry.sttl_day is 'Number of settlement day of entry posting'
/
comment on column acc_entry.sttl_date is 'Settlement date'
/
alter table acc_entry add (
    status              varchar2(8)
    , ref_entry_id      number(16)
)
/
comment on column acc_entry.status is 'Entry status'
/
comment on column acc_entry.ref_entry_id is 'Reference to another entry (e.g. original and cancelation)'
/
alter table acc_entry add (is_settled number(1))
/
comment on column acc_entry.is_settled is 'Entry settlement flag. Indicates entry is settled in CBS'
/
alter table acc_entry add sttl_flag_date date
/
comment on column acc_entry.sttl_flag_date is 'Settlement flag date.'
/
alter table acc_entry add (rounding_error number(22, 4))
/
comment on column acc_entry.rounding_error is 'The difference between the original posting entry amount and its rounded value saved in field <amount>. So it can be positive or negative'
/
comment on column acc_entry.amount is 'Entry amount (rounded)'
/
comment on column acc_entry.balance is 'Resulting balance after entry posting'
/
comment on column acc_entry.rounding_balance is 'Resulting (cumulative) rounding error as the sum of all differences between original posting entries amounts and their rounded values from field <amount>. Therefore, the sum of fields <balance> and <rounding_balance> values is the exact balance value as if all posting entries amounts are summed without rounding. (In other terms, sum(amount + rounding_error) = balance + rounding_balance)'
/
