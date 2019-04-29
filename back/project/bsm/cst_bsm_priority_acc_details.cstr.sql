alter table cst_bsm_priority_acc_details add constraint cst_bsm_priority_acc_det_pk primary key (id)
/
alter table CST_BSM_PRIORITY_ACC_DETAILS modify (customer_number varchar2(32 char))
/
alter table CST_BSM_PRIORITY_ACC_DETAILS modify (account_number varchar2(32 char))
/
