create index crd_debt_status_ndx on crd_debt (decode(status, 'DBTSACTV', account_id, null))
/

create index crd_debt_account_is_new_ndx on crd_debt (decode(is_new, 1, account_id, null))
/
create index crd_debt_oper_id_ndx on crd_debt (oper_id)
/
create index crd_debt_status_card_ndx on crd_debt (decode(status, 'DBTSACTV', card_id, null))
/
create index crd_debt_account_ndx on crd_debt (account_id)
/
create index crd_debt_original_id_ndx on crd_debt (original_id)
/

