create table cst_act_transactions (
    oper_id          number(16)
  , host_date        date
  , oper_amount      number(22,4)
  , oper_currency    varchar2(3)
  , acc_amount       number(22,4)
  , acc_currency     varchar2(3)
  , oper_type        varchar2(200)
  , is_reversal      varchar2(1)
  , original_id      number(16)
  , status           varchar2(200)
  , status_reason    varchar2(200)
  , merchant_number  varchar2(15)
  , merchant_name    varchar2(200)
  , merchant_account varchar2(100)
  , terminal_type    varchar2(200)
  , file_name        varchar2(200)
  , network          varchar2(20)
  , fill_mode        varchar2(20 char)
)
/
comment on table cst_act_transactions is 'Transactions for report "Rendered processing services"'
/
comment on column cst_act_transactions.oper_id is 'Operation identifier'
/
comment on column cst_act_transactions.host_date is 'Host date'
/
comment on column cst_act_transactions.oper_amount is 'Operation amount'
/
comment on column cst_act_transactions.oper_currency is 'Operation currency'
/
comment on column cst_act_transactions.acc_amount is 'Account amount'
/
comment on column cst_act_transactions.acc_currency is 'Account currency'
/
comment on column cst_act_transactions.oper_type is 'Operation type'
/
comment on column cst_act_transactions.is_reversal is 'Is reversal'
/
comment on column cst_act_transactions.original_id is 'Original id'
/
comment on column cst_act_transactions.status is 'Status'
/
comment on column cst_act_transactions.status_reason is 'Status reason'
/
comment on column cst_act_transactions.merchant_number is 'Merchant number'
/
comment on column cst_act_transactions.merchant_name is 'Merchant name'
/
comment on column cst_act_transactions.merchant_account is 'Merchant account'
/
comment on column cst_act_transactions.terminal_type is 'Terminal type'
/
comment on column cst_act_transactions.file_name is 'File name'
/
comment on column cst_act_transactions.network is 'Network'
/
comment on column cst_act_transactions.fill_mode is 'Fill mode'
/
