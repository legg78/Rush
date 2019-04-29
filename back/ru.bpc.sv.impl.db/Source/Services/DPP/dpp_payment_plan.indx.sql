create index dpp_payment_plan_accnt_id_ndx on dpp_payment_plan(account_id)
/

create index dpp_payment_plan_reg_oper_ndx on dpp_payment_plan(reg_oper_id)
/****************** partition start ********************
    local
******************** partition end ********************/
/

drop index dpp_payment_plan_accnt_id_ndx
/
create index dpp_payment_plan_accnt_id_ndx on dpp_payment_plan(account_id)
/****************** partition start ********************
    local
******************** partition end ********************/
/
create index dpp_payment_plan_status_ndx on dpp_payment_plan (decode(status, 'DOST0100', account_id, null))
/
drop index dpp_payment_plan_reg_oper_ndx
/
