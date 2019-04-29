create global temporary table cst_m_fil_row_tmp(
    transaction_number varchar2(10)
  , reg_number_doc varchar2(30)
  , contract_number varchar2(24)
  , card_number varchar2(24)
  , trans_date varchar2(8)
  , trans_time varchar2(6)
  , transaction_direction varchar2(1)
  , oper_currency number(3, 0)
  , account_currency number(3, 0)
  , oper_amount number(15, 0)
  , account_amount number(15, 0)
  , fee_direction varchar2(1)
  , fee_amount number(15, 0)
  , account_type varchar2(3)
  , expir_date varchar2(4)
  , trans_detail varchar2(30)
  , auth_reg_number varchar2(10)
  , auth_code varchar2(6)
  , auth_amount number(15, 0)
  , sttl_date varchar2(8)
  , mcc varchar2(4)
  , contra_entry_channel varchar2(1)
  , arn varchar2(23)
  , recon_curr number(3, 0)
  , request_amount number(15, 0)
  , iss_reference_number varchar2(10)
  , value_date varchar2(8)
  , gl_date varchar2(8)
  , collection_number varchar2(10)
  , contract_type varchar2(4)
  , contract_name varchar2(32)
  , merchant_location varchar2(30)
  , merchant_country varchar2(3)
  , merchant_city varchar2(16)
  , merchant_number varchar2(15)
  , transaction_type varchar2(8)
  , event_id number(16, 0)
  , msg_type varchar2(8)
  , card_type_id varchar2(8)
  , contra_entry varchar2(4)
  , contra_entry_number varchar2(24)
  , sttl_type varchar2(8)
  , sttl_currency varchar2(3)
  , sttl_amount number(22, 4)
  , orig_number_dog varchar2(10)
  , p2p_channel varchar2(1 char)
  , p2p_card_type varchar2(2 char)
) on commit delete rows
/
comment on table cst_m_fil_row_tmp is 'Temporary table for save of M-file data'
/
comment on column cst_m_fil_row_tmp.transaction_number is 'Transaction number'
/
comment on column cst_m_fil_row_tmp.reg_number_doc is 'Operation ID'
/
comment on column cst_m_fil_row_tmp.contract_number is 'Terminal number'
/
comment on column cst_m_fil_row_tmp.card_number is 'Card number'
/
comment on column cst_m_fil_row_tmp.trans_date is 'Transaction date'
/
comment on column cst_m_fil_row_tmp.trans_time is 'Transaction time'
/
comment on column cst_m_fil_row_tmp.transaction_direction is 'Transaction direction'
/
comment on column cst_m_fil_row_tmp.oper_currency is 'Operation currency'
/
comment on column cst_m_fil_row_tmp.account_currency is 'Account currency'
/
comment on column cst_m_fil_row_tmp.oper_amount is 'Operation amount'
/
comment on column cst_m_fil_row_tmp.account_amount is 'Account amount'
/
comment on column cst_m_fil_row_tmp.fee_direction is 'Fee direction'
/
comment on column cst_m_fil_row_tmp.fee_amount is 'Fee amount'
/
comment on column cst_m_fil_row_tmp.account_type is 'Account type'
/
comment on column cst_m_fil_row_tmp.expir_date is 'Expiration date'
/
comment on column cst_m_fil_row_tmp.trans_detail is 'Transaction detail'
/
comment on column cst_m_fil_row_tmp.auth_reg_number is 'Authorization registration number'
/
comment on column cst_m_fil_row_tmp.auth_code is 'Authorization code'
/
comment on column cst_m_fil_row_tmp.auth_amount is 'Authorization amount'
/
comment on column cst_m_fil_row_tmp.sttl_date is 'Settlement date'
/
comment on column cst_m_fil_row_tmp.mcc is 'Merchant category code (MCC)'
/
comment on column cst_m_fil_row_tmp.contra_entry_channel is 'Contra entry channel'
/
comment on column cst_m_fil_row_tmp.arn is 'Acquirer Reference Number'
/
comment on column cst_m_fil_row_tmp.recon_curr is 'Operation currency'
/
comment on column cst_m_fil_row_tmp.request_amount is 'Operation request amount'
/
comment on column cst_m_fil_row_tmp.iss_reference_number is 'Issuer reference number'
/
comment on column cst_m_fil_row_tmp.value_date is 'Value date'
/
comment on column cst_m_fil_row_tmp.gl_date is 'GL date'
/
comment on column cst_m_fil_row_tmp.collection_number is 'Collection number'
/
comment on column cst_m_fil_row_tmp.contract_type is 'Contract type'
/
comment on column cst_m_fil_row_tmp.contract_name is 'Contract name'
/
comment on column cst_m_fil_row_tmp.merchant_location is 'Merchant location'
/
comment on column cst_m_fil_row_tmp.merchant_country is 'Merchant country'
/
comment on column cst_m_fil_row_tmp.merchant_city is 'Merchant city'
/
comment on column cst_m_fil_row_tmp.merchant_number is 'Merchant number'
/
comment on column cst_m_fil_row_tmp.transaction_type is 'Transaction type'
/
comment on column cst_m_fil_row_tmp.event_id is 'Event ID'
/
comment on column cst_m_fil_row_tmp.msg_type is 'Message type'
/
comment on column cst_m_fil_row_tmp.card_type_id is 'Card type ID'
/
comment on column cst_m_fil_row_tmp.contra_entry is 'Contra entry'
/
comment on column cst_m_fil_row_tmp.contra_entry_number is 'Contra entry number'
/
comment on column cst_m_fil_row_tmp.sttl_type is 'Settlement type'
/
comment on column cst_m_fil_row_tmp.sttl_currency is 'Settlement currency'
/
comment on column cst_m_fil_row_tmp.sttl_amount is 'Settlement amount'
/
comment on column cst_m_fil_row_tmp.orig_number_dog is 'Part of original ID if operation is reversal'
/
comment on column cst_m_fil_row_tmp.p2p_channel is ' P2P reference contra entry channel'
/
comment on column cst_m_fil_row_tmp.p2p_card_type is 'P2P reference card type'
/
