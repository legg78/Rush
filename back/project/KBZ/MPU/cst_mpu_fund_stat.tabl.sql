create table cst_mpu_fund_stat (
    id                number(16) not null
  , inst_id           number(4)
  , network_id        number(4)
  , status            varchar2(8)
  , file_id           number(16)
  , record_type       varchar2(3)
  , member_inst_code  varchar2(11)
  , out_amount_sign   varchar2(1)
  , out_amount        number(16)
  , out_fee_sign      varchar2(1)
  , out_fee_amount    number(16)
  , in_amount_sign    varchar2(1)
  , in_amount         number(16)
  , in_fee_sign       varchar2(1)
  , in_fee_amount     number(16)
  , stf_amount_sign   varchar2(1)
  , stf_amount        number(16)
  , stf_fee_sign      varchar2(1)
  , stf_fee_amount    number(16)
  , out_summary       number(10)
  , in_summary        number(10)
  , sttl_currency     varchar2(3)
)
/

comment on table cst_mpu_fund_stat is 'Fund Settlement Statistics messages'
/
comment on column cst_mpu_fund_stat.id is 'Primary key. Message identifier'
/
comment on column cst_mpu_fund_stat.inst_id is 'Institution identifier'
/
comment on column cst_mpu_fund_stat.network_id is 'Network identifier'
/
comment on column cst_mpu_fund_stat.status is 'Message status'
/
comment on column cst_mpu_fund_stat.file_id is 'File identifier'
/
comment on column cst_mpu_fund_stat.record_type is 'Record Type'
/
comment on column cst_mpu_fund_stat.member_inst_code is 'Member Institution Code'
/
comment on column cst_mpu_fund_stat.out_amount_sign is 'Outgoing Amount Sign'
/
comment on column cst_mpu_fund_stat.out_amount is 'Outgoing Amount'
/
comment on column cst_mpu_fund_stat.out_fee_sign is 'Outgoing Fee Sign'
/
comment on column cst_mpu_fund_stat.out_fee_amount is 'Outgoing Fee'
/
comment on column cst_mpu_fund_stat.in_amount_sign is 'Incoming Amount Sign'
/
comment on column cst_mpu_fund_stat.in_amount is 'Incoming Amount'
/
comment on column cst_mpu_fund_stat.in_fee_sign is 'Incoming Fee Sign'
/
comment on column cst_mpu_fund_stat.in_fee_amount is 'Incoming Fee'
/
comment on column cst_mpu_fund_stat.stf_amount_sign is 'STF Amount Sign'
/
comment on column cst_mpu_fund_stat.stf_amount is 'STF Amount'
/
comment on column cst_mpu_fund_stat.stf_fee_sign is 'STF Fee Sign'
/
comment on column cst_mpu_fund_stat.stf_fee_amount is 'STF Fee'
/
comment on column cst_mpu_fund_stat.out_summary is 'Outgoing Summary'
/
comment on column cst_mpu_fund_stat.in_summary is 'Incoming Summary'
/
comment on column cst_mpu_fund_stat.sttl_currency is 'Settlement Currency'
/
