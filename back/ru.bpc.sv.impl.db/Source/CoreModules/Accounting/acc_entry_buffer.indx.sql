create index acc_entry_buf_account_ndx on acc_entry_buffer (
    account_id
)
/

create index acc_entry_buf_dest_entity_ndx on acc_entry_buffer (
    dest_entity_type
)
/

create index acc_entry_buf_dest_acct_ndx on acc_entry_buffer (
    dest_account_type
)
/

create index acc_entry_buf_macros_ndx on acc_entry_buffer(macros_id)
/
create index acc_entry_buf_bunch_ndx on acc_entry_buffer(bunch_id)
/
create index acc_entry_buf_transaction_ndx on acc_entry_buffer(transaction_id)
/
