alter table dpp_payment_plan add constraint dpp_payment_plan_pk primary key(id)
/
alter table dpp_payment_plan add constraint dpp_payment_plan_reg_oper_uk unique(reg_oper_id)
/
