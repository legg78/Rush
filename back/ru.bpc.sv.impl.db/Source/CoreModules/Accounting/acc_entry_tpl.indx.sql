create unique index acc_entry_tpl_bunch_trans_ndx on acc_entry_tpl (
    bunch_type_id, 
    transaction_num, 
    balance_impact
)
/

drop index acc_entry_tpl_bunch_trans_ndx
/

create unique index acc_entry_tpl_bunch_trans_ndx on acc_entry_tpl (bunch_type_id, transaction_num, balance_impact, mod_id)
/