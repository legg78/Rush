create index acc_macros_object_ndx on acc_macros (
    object_id
    , entity_type
)
/

create index acc_macros_posting_date_ndx on acc_macros (
    posting_date
)
/

create index acc_macros_account_ndx on acc_macros (account_id)
/****************** partition start ********************
    local
******************** partition end ********************/
/
