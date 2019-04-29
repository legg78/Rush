create table cst_amk_epw_fin_msg(
    id                      number(8)
  , status                  varchar2(8)
  , file_id                 number(8)
  , is_invalid              number(1)
  , is_incoming             number(1)
  , row_number              number(22)
  , supplier_code           varchar2(200)
  , supplier_name           varchar2(200)
  , customer_code           varchar2(200)
  , customer_name           varchar2(200)
  , customer_id             number(8)
  , trxn_datetime           date
  , amount                  number(22,4)
  , currency_name           varchar2(3)
  , currency_code           varchar2(3)
  , oper_id                 number(16)
)
/

comment on table cst_amk_epw_fin_msg is 'E-Power financial messages.'
/
comment on column cst_amk_epw_fin_msg.id is 'Primary key.'
/
comment on column cst_amk_epw_fin_msg.status is 'Fin message status.'
/
comment on column cst_amk_epw_fin_msg.file_id is 'File id.'
/
comment on column cst_amk_epw_fin_msg.is_invalid is 'Invalid flag.'
/
comment on column cst_amk_epw_fin_msg.is_incoming is 'Incoming flag.'
/
comment on column cst_amk_epw_fin_msg.row_number is 'Sequence number of record.'
/
comment on column cst_amk_epw_fin_msg.supplier_code is 'Supplier code.'
/
comment on column cst_amk_epw_fin_msg.supplier_name is 'Supplier name.'
/
comment on column cst_amk_epw_fin_msg.customer_code is 'Customer code.'
/
comment on column cst_amk_epw_fin_msg.customer_name is 'Customer name.'
/
comment on column cst_amk_epw_fin_msg.customer_id is 'Customer id.'
/
comment on column cst_amk_epw_fin_msg.trxn_datetime is 'Operation date.'
/
comment on column cst_amk_epw_fin_msg.amount is 'Operation amount.'
/
comment on column cst_amk_epw_fin_msg.currency_name is 'Currency name.'
/
comment on column cst_amk_epw_fin_msg.currency_code is 'Currency code.'
/
comment on column cst_amk_epw_fin_msg.oper_id is 'Matched operation id.'
/
