create table crd_aging (
    id                 number(12) not null
    , invoice_id       number(12)
    , aging_period     number(4)
    , aging_date       date
    , aging_amount     number(22, 4)
    , split_hash       number(4)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/
comment on table crd_aging is 'Invoice aging.'
/
comment on column crd_aging.id is 'Primary key.'
/
comment on column crd_aging.invoice_id is 'Reference to invoice.'
/
comment on column crd_aging.aging_period is 'Sequencial number of invoice aging.'
/
comment on column crd_aging.aging_date is 'Date when exact aging was generated.'
/
comment on column crd_aging.aging_amount is 'Past-due amount in account currency.'
/
comment on column crd_aging.split_hash is 'Hash value to split further processing.'
/
alter table crd_aging modify (id  number(16))
/

