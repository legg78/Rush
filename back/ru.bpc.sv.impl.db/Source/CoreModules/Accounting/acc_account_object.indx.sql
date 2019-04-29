create index acc_account_object_account_ndx on acc_account_object (account_id)
/****************** partition start ********************
    local
******************** partition end ********************/
/

create index acc_account_object_entity_ndx on acc_account_object (object_id, entity_type)
/****************** partition start ********************
    local
******************** partition end ********************/
/
