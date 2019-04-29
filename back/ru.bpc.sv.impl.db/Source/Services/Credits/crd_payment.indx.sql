create index crd_payment_status_ndx on crd_payment (decode(status, 'PMTSACTV', account_id, null))
/

create index crd_payment_acct_is_new_ndx on crd_payment (decode(is_new, 1, account_id, null))
/
create index crd_payment_oper_id_ndx on crd_payment (oper_id)
/
create index crd_payment_account_id_ndx on crd_payment (account_id)
/
create index crd_payment_original_id_ndx on crd_payment (original_oper_id)
/
