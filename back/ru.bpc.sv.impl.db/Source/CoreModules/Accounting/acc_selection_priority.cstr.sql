alter table acc_selection_priority add constraint acc_selection_priority_pk primary key (
    id
)
/
alter table acc_selection_priority add constraint acc_selection_priority_uk
unique( inst_id, oper_type, account_type, account_status, party_type)
/
alter table acc_selection_priority drop constraint acc_selection_priority_uk
/
alter table acc_selection_priority add constraint acc_selection_priority_uk unique (inst_id, oper_type, account_type, account_status, party_type, msg_type)
/
alter table acc_selection_priority drop constraint acc_selection_priority_uk
/
alter table acc_selection_priority add constraint acc_selection_priority_uk unique (inst_id, oper_type, account_type, account_status, party_type, msg_type, account_currency)
/
