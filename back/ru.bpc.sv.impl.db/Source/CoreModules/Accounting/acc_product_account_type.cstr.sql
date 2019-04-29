alter table acc_product_account_type add constraint acc_product_account_type_pk primary key (id) using index
/
alter table acc_product_account_type add (constraint acc_product_account_type_uk unique (account_type, service_id, currency, product_id))
/