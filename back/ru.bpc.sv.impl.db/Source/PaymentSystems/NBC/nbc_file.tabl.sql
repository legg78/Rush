create table nbc_file (
    id                  number(16)
  , file_type           varchar2(2)
  , is_incoming         number(1)
  , inst_id             number(4)
  , network_id          number(4)
  , bin_number          varchar2(7)
  , sttl_date           date
  , proc_date           date
  , file_number         number(3)
  , participant_type    varchar2(3)
  , session_file_id     number(16)
  , records_total       number(8)
  , crc                 number(20)
)
/

comment on table nbc_file is 'NBC clearing files'
/
comment on column nbc_file.id is 'Primary key. Equal to ID in PRC_SESSION_FILE'
/
comment on column nbc_file.file_type is 'Type of file: RF/DF'
/
comment on column nbc_file.is_incoming is 'Incoming flag'
/
comment on column nbc_file.inst_id is 'Institution identifier'
/
comment on column nbc_file.network_id is 'Network identifier'
/
comment on column nbc_file.bin_number is 'BIN number of the Bank which has role relate to the transactions'
/
comment on column nbc_file.sttl_date is 'Settlement date'
/
comment on column nbc_file.proc_date is 'Processing date'
/
comment on column nbc_file.file_number is 'File Sequence Number'
/
comment on column nbc_file.participant_type is 'Participant type: ISS/ACQ/BNB'
/
comment on column nbc_file.session_file_id is 'File object identifier(prc_session_file.id)'
/
comment on column nbc_file.records_total is 'Number of Records in file'
/
comment on column nbc_file.crc is 'Check sum'
/
alter table nbc_file add md5 varchar2(32)
/
comment on column nbc_file.md5 is 'Md5 sum'
/
alter table nbc_file drop column crc
/
