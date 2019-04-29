create table cst_mpu_file (
    id               number(16) not null
  , inst_id          number(4)
  , network_id       number(4)
  , is_incoming      number(1)
  , iin              varchar2(11)
  , trans_date       date
  , trans_total      number(9)
  , generator        varchar2(20)
  , file_date        date
  , session_file_id  number(16)
  , file_type        varchar2(1)
  , file_number      number(2)
  , inst_role        varchar2(1)
  , data_type        varchar2(1)
  , proc_date        date
)
/

comment on table cst_mpu_file is 'MPU files'
/
comment on column cst_mpu_file.id is 'Primary key. File identifier'
/
comment on column cst_mpu_file.inst_id is 'Institution identifier'
/
comment on column cst_mpu_file.network_id is 'Network identifier'
/
comment on column cst_mpu_file.is_incoming is 'Incoming indicator'
/
comment on column cst_mpu_file.iin is 'Member IIN'
/
comment on column cst_mpu_file.trans_date is 'Transaction date of the last transaction recorded in the file'
/
comment on column cst_mpu_file.trans_total is 'Number of records in the file'
/
comment on column cst_mpu_file.generator is 'User code of the extraction system'
/
comment on column cst_mpu_file.file_date is 'File generation date and time'
/
comment on column cst_mpu_file.session_file_id is 'Session file identifier'
/
comment on column cst_mpu_file.file_type is 'File type. D - audit trailer, C - dual-message settlement'
/
comment on column cst_mpu_file.file_number is 'Batch number/sequence number'
/
comment on column cst_mpu_file.inst_role is 'Institution role for SMS files. A - Acquirer, I - Issuer, B - bemeficiary, S - statistics'
/
comment on column cst_mpu_file.data_type is 'Data type for DMS files. C - Settlement, R - rejecttion, S - statistics, D - dispute, X - settlement remind'
/
comment on column cst_mpu_file.proc_date is 'Processing date'
/

