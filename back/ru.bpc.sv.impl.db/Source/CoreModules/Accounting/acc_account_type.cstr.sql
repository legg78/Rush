alter table acc_account_type add constraint acc_account_type_pk primary key (
    id
)
/

create unique index acc_account_type_uk on acc_account_type (
    account_type 
    , inst_id
)
/
