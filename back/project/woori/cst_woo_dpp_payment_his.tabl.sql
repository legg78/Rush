create table cst_woo_dpp_payment_his(
    dpp_id              number(16)
  , new_count           number(2)
  , payment_date        date  
  , payment_amount      number(22 ,4)
  , acceleration_type   varchar2(8)
)
/

comment on table cst_woo_dpp_payment_his is 'DPP early payment history'
/
comment on column cst_woo_dpp_payment_his.dpp_id is 'DPP ID'
/
comment on column cst_woo_dpp_payment_his.new_count is 'DPP new count'
/
comment on column cst_woo_dpp_payment_his.payment_date is 'DPP payment date'
/
comment on column cst_woo_dpp_payment_his.payment_amount is 'DPP payment date'
/
comment on column cst_woo_dpp_payment_his.acceleration_type is 'DPP acceleration type'
/
