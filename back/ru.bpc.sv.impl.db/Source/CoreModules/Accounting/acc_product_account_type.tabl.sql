create table acc_product_account_type(
    id                    number(8)
  , product_id            number(8)
  , account_type          varchar2(8)
  , scheme_id             number(4)
)
/

comment on table acc_product_account_type is 'Schemes for account types'
/

comment on column acc_product_account_type.id is 'Primary key'
/
comment on column acc_product_account_type.product_id is 'Product identifier'
/
comment on column acc_product_account_type.account_type is 'Account type'
/
comment on column acc_product_account_type.scheme_id is 'Scheme identifier'
/
alter table acc_product_account_type add (currency varchar2(3), service_id number(8))
/
comment on column acc_product_account_type.currency is 'Currency of account balances.'
/
comment on column acc_product_account_type.service_id is 'Service identifier.'
/
alter table acc_product_account_type add aval_algorithm varchar2(8)
/
comment on column acc_product_account_type.aval_algorithm is 'Available balance calculation algorithm.'
/
