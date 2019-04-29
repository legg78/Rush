create global temporary table cst_m_fil_row_total_tmp(
    contract_type varchar2(4 char)
  , contract_number varchar2(24 char)
  , contract_name varchar2(32 char)
  , merchant_location varchar2(30 char)
  , merchant_country varchar2(3 char)
  , merchant_city varchar2(16 char)
  , merchant_number varchar2(15 char)
  , contra_entry varchar2(4 char)
  , transaction_type varchar2(8 char)
  , oper_currency number(3, 0)
  , count number(6, 0)
  , sum_amount number(18, 0)
  , sum_fee_amount number(18, 0)
  , batch_flag number(1, 0)
  , count_batch number(6, 0)
) on commit delete rows
/
comment on table cst_m_fil_row_total_tmp is 'Temporary table for save row total of M-file data'
/
comment on column cst_m_fil_row_total_tmp.contract_type is 'Contract type'
/
comment on column cst_m_fil_row_total_tmp.contract_number is 'Contract number'
/
comment on column cst_m_fil_row_total_tmp.contract_name is 'Contract name'
/
comment on column cst_m_fil_row_total_tmp.merchant_location is 'Merchant location'
/
comment on column cst_m_fil_row_total_tmp.merchant_country is 'Merchant country'
/
comment on column cst_m_fil_row_total_tmp.merchant_city is 'Merchant city'
/
comment on column cst_m_fil_row_total_tmp.merchant_number is 'Merchant number'
/
comment on column cst_m_fil_row_total_tmp.contra_entry is 'Contra entry'
/
comment on column cst_m_fil_row_total_tmp.transaction_type is 'Transaction type'
/
comment on column cst_m_fil_row_total_tmp.oper_currency is 'Operation currency'
/
comment on column cst_m_fil_row_total_tmp.count is 'Count'
/
comment on column cst_m_fil_row_total_tmp.sum_amount is 'Sum amount'
/
comment on column cst_m_fil_row_total_tmp.sum_fee_amount is 'Sum fee amount'
/
comment on column cst_m_fil_row_total_tmp.batch_flag is 'Batch flag'
/
comment on column cst_m_fil_row_total_tmp.count_batch is 'Count batch'
/
