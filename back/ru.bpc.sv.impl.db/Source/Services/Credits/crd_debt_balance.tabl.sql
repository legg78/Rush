create table crd_debt_balance
(
    id              number(16)
  , part_key        as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , debt_id         number(16)
  , debt_intr_id    number(16)
  , balance_type    varchar2(8)
  , amount          number(22,4)
  , repay_priority  number(4)
  , min_amount_due  number(22,4)
  , split_hash      number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                       -- [@skip patch]
subpartition by list (split_hash)                                                         -- [@skip patch]
subpartition template                                                                     -- [@skip patch]
(                                                                                         -- [@skip patch]
    <subpartition_list>                                                                   -- [@skip patch]
)                                                                                         -- [@skip patch]
(                                                                                         -- [@skip patch]
    partition crd_debt_balance_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))  -- [@skip patch]
)                                                                                         -- [@skip patch]
******************** partition end ********************/
/

comment on table crd_debt_balance is 'Current state of debt in the context of balances.'
/

comment on column crd_debt_balance.id is 'Primary key.'
/
comment on column crd_debt_balance.debt_id is 'Reference to debt.'
/
comment on column crd_debt_balance.debt_intr_id is 'Reference to history of debt state (last).'
/
comment on column crd_debt_balance.balance_type is 'Balance type.'
/
comment on column crd_debt_balance.amount is 'Balance amount.'
/
comment on column crd_debt_balance.repay_priority is 'Repay priority. Define order of debts repeyment.'
/
comment on column crd_debt_balance.min_amount_due is 'Minimum amount due.'
/
comment on column crd_debt_balance.split_hash is 'Hash value to split further processing.'
/
alter table crd_debt_balance add posting_order number(8)
/
comment on column crd_debt_balance.posting_order is 'Order of entry posting on balance'
/
begin
    for rec in (select count(1) cnt from user_tab_columns where table_name = 'CRD_DEBT_BALANCE' and column_name = 'PART_KEY')
    loop
        if rec.cnt = 0 then
            execute immediate 'alter table crd_debt_balance add (part_key as (to_date(substr(lpad(to_char(id), 16, ''0''), 1, 6), ''yymmdd'')) virtual)';
            execute immediate 'comment on column crd_debt_balance.part_key is ''Partition key''';
        end if;
    end loop;
end;
/
