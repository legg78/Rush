create table crd_invoice_debt
(
    id            number(16)
  , part_key      as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , invoice_id    number(12)
  , debt_id       number(16)
  , debt_intr_id  number(16)
  , is_new        number(1)
  , split_hash    number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                       -- [@skip patch]
subpartition by list (split_hash)                                                         -- [@skip patch]
subpartition template                                                                     -- [@skip patch]
(                                                                                         -- [@skip patch]
    <subpartition_list>                                                                   -- [@skip patch]
)                                                                                         -- [@skip patch]
(                                                                                         -- [@skip patch]
    partition crd_invoice_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))       -- [@skip patch]
)                                                                                         -- [@skip patch]
******************** partition end ********************/
/

comment on table crd_invoice_debt is 'Debts included into invoices.'
/

comment on column crd_invoice_debt.id is 'Primary key.'
/
comment on column crd_invoice_debt.invoice_id is 'Invoice identifier.'
/
comment on column crd_invoice_debt.debt_id is 'Debt identifier.'
/
comment on column crd_invoice_debt.debt_intr_id is 'Reference to debt state history.'
/
comment on column crd_invoice_debt.is_new is 'New debt meaning that it was made in current billing period.'
/
comment on column crd_invoice_debt.split_hash is 'Hash value to split further processing.'
/
begin
    for rec in (select count(1) cnt from user_tab_columns where table_name = 'CRD_INVOICE_DEBT' and column_name = 'PART_KEY')
    loop
        if rec.cnt = 0 then
            execute immediate 'alter table crd_invoice_debt add (part_key as (to_date(substr(lpad(to_char(id), 16, ''0''), 1, 6), ''yymmdd'')) virtual)';
            execute immediate 'comment on column crd_invoice_debt.part_key is ''Partition key''';
        end if;
    end loop;
end;
/
