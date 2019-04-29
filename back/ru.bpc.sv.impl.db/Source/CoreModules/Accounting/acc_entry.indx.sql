create index acc_entry_macros_ndx on acc_entry (
    macros_id
)
/

create index acc_entry_transaction_ndx on acc_entry (
    transaction_id
)
/


create index acc_entry_account_ndx on acc_entry (
    account_id
)
/

create index acc_entry_scan_sttl_date_ndx on acc_entry (
    account_id
    , balance_type
    , sttl_date
    , posting_order
)
/

create index acc_entry_scan_post_date_ndx on acc_entry (
    account_id
    , balance_type
    , posting_date
    , posting_order
)
/

create index acc_entry_bunch_ndx on acc_entry(bunch_id)
/
