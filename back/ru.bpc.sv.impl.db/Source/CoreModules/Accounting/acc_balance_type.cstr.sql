alter table acc_balance_type add constraint acc_balance_type_pk primary key (
    id
)
/

create unique index acc_balance_type_uk on acc_balance_type (
    account_type
  , inst_id
  , balance_type
)
/
