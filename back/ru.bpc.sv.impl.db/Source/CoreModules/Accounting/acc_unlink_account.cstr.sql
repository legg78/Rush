alter table acc_unlink_account add constraint acc_unlink_account_pk primary key (
    id
)
/

create unique index acc_unlink_account_uk on acc_unlink_account (
    object_id
    , entity_type
    , account_id
)
/
drop index acc_unlink_account_uk
/
create index acc_unlink_account_object_ndx on acc_unlink_account (object_id, entity_type, account_id)
/
