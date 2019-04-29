create index acc_unlink_account_account_ndx on acc_unlink_account (account_id)
/****************** partition start ********************
    local
******************** partition end ********************/
/
create index acc_unlink_account_ndx on acc_unlink_account (object_id, entity_type)
/****************** partition start ********************
    local
******************** partition end ********************/
/
