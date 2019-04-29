create table cst_mpu_mrch_settlement (
    id                      number(16) not null
  , inst_id                 number(4)
  , network_id              number(4)
  , status                  varchar2(8)
  , file_id                 number(16)
  , record_type             varchar2(3)
  , member_inst_code        varchar2(11)
  , merchant_number         varchar2(15)
  , in_amount_sign          varchar2(1)
  , in_amount               number(16)
  , in_fee_sign             varchar2(1)
  , in_fee_amount           number(16)
  , total_sttl_amount_sign  varchar2(1)
  , total_sttl_amount       number(16)
  , in_summary              number(10)
  , sttl_currency           varchar2(3)
  , mrch_sttl_account       varchar2(30)
)
/
comment on table cst_mpu_mrch_settlement is 'Merchant Settlement'
/
comment on column cst_mpu_mrch_settlement.id    is 'Primary key. Message identifier'
/
comment on column cst_mpu_mrch_settlement.inst_id is 'Institution identifier'
/
comment on column cst_mpu_mrch_settlement.network_id is 'Network identifier'
/
comment on column cst_mpu_mrch_settlement.status is 'Message status'
/
comment on column cst_mpu_mrch_settlement.file_id is 'File identifier'
/
comment on column cst_mpu_mrch_settlement.record_type is 'Record Type'
/
comment on column cst_mpu_mrch_settlement.member_inst_code is 'Member Institution Code'
/
comment on column cst_mpu_mrch_settlement.merchant_number is 'Merchant Code'
/
comment on column cst_mpu_mrch_settlement.in_amount_sign is 'Incoming Amount Sign'
/
comment on column cst_mpu_mrch_settlement.in_amount is 'Incoming Amount'
/
comment on column cst_mpu_mrch_settlement.in_fee_sign is 'Incoming Fee Sign'
/
comment on column cst_mpu_mrch_settlement.in_fee_amount is 'Incoming Fee'
/
comment on column cst_mpu_mrch_settlement.total_sttl_amount_sign is 'Total Settlement Amount Sign'
/
comment on column cst_mpu_mrch_settlement.total_sttl_amount is 'Total Settlement Amount'
/
comment on column cst_mpu_mrch_settlement.in_summary is 'Incoming Summary'
/
comment on column cst_mpu_mrch_settlement.sttl_currency is 'Settlement Currency'
/
comment on column cst_mpu_mrch_settlement.mrch_sttl_account is 'Merchant Settlement Account'
/
