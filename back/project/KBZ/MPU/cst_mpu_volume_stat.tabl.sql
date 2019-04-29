create table cst_mpu_volume_stat (
    id                number(16) not null
  , inst_id           number(4)
  , network_id        number(4)
  , status            varchar2(8)
  , file_id           number(16)
  , record_type       varchar2(3)
  , member_inst_code  varchar2(11)
  , sttl_currency     varchar2(3)
  , stat_trans_code   varchar2(3)
  , summary           number(10)
  , credit_amount     number(16)
  , debit_amount      number(16)
)
/
comment on table cst_mpu_volume_stat is 'Volume Statistics'
/
comment on column cst_mpu_volume_stat.id is 'Primary key. Message identifier'
/
comment on column cst_mpu_volume_stat.inst_id is 'Institution identifier'
/
comment on column cst_mpu_volume_stat.network_id is 'Network identifier'
/
comment on column cst_mpu_volume_stat.status is 'Message status'
/
comment on column cst_mpu_volume_stat.file_id is 'File identifier'
/
comment on column cst_mpu_volume_stat.record_type is 'Record Type' 
/
comment on column cst_mpu_volume_stat.member_inst_code is 'Member Institution Code'
/
comment on column cst_mpu_volume_stat.sttl_currency is 'Settlement Currency'
/
comment on column cst_mpu_volume_stat.stat_trans_code is 'Statistics Transaction Code' 
/
comment on column cst_mpu_volume_stat.summary is 'Incoming Summary/Outgoing Summary' 
/
comment on column cst_mpu_volume_stat.credit_amount is 'Amount, credit'  
/
comment on column cst_mpu_volume_stat.debit_amount is 'Amount, debit'
/

