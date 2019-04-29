alter table acc_account_object add constraint acc_object_account_pk primary key (
    id
)
/

create unique index acc_account_object_uk on acc_account_object (
    object_id
    , entity_type
    , account_id
)
/
