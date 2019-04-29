alter table acc_iso_account_type add constraint acc_iso_account_type_pk primary key (
    id
)
/
create unique index acc_iso_account_type_uk on acc_iso_account_type (
    inst_id
    , account_type
    , iso_type
)
/