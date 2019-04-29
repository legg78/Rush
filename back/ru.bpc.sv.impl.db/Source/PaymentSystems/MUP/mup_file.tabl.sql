create table mup_file (
    id                  number(8) not null
    , inst_id           number(4)
    , network_id        number(4)
    , is_incoming       number(1)
    , proc_date         date
    , session_file_id   number(16)
    , is_rejected       number(1)
    , reject_id         number(16)
    , p0026             varchar2(7)
    , p0105             varchar2(25)
    , p0110             varchar2(25)
    , p0122             varchar2(1)    
    , p0301             number(16)
    , p0306             number(8)
    , header_mti        varchar2(4)
    , header_de024      varchar2(3)
    , header_de071      number(7)
    , trailer_mti       varchar2(4)
    , trailer_de024     varchar2(3)
    , trailer_de071     number(7)
)
/

comment on table mup_file is 'MUP logical files'
/

comment on column mup_file.id is 'Identifier'
/

comment on column mup_file.inst_id is 'Institution identifier'
/

comment on column mup_file.network_id is 'Network identifier'
/

comment on column mup_file.is_incoming is 'Incoming indicator'
/

comment on column mup_file.proc_date is 'Processing date'
/

comment on column mup_file.session_file_id is 'Session file identifier'
/

comment on column mup_file.is_rejected is 'Rejected idicator'
/

comment on column mup_file.reject_id is 'Reject message identifier'
/

comment on column mup_file.p0026 is 'PDS 0026 (File Reversal Indicator) identifies the entire file as a reversal of a previous file.'
/

comment on column mup_file.p0105 is 'PDS 0105 (File ID) uniquely identifies a logical data file to be exchanged between a member or processor and the clearing system.'
/

comment on column mup_file.p0110 is 'PDS 0110 (Transmission ID) uniquely identifies a physical transmission or grouping of logical files to be exchanged between a member or processor and the clearing system.'
/

comment on column mup_file.p0122 is 'PDS 0122 (Processing Mode) indicates the type of processing to be performed on transaction messages.'
/

comment on column mup_file.p0301 is 'PDS 0301 (File Amount, Checksum) provides a preliminary "quick check" for the file recipient to indicate or to determine that it received all messages in a file.'
/

comment on column mup_file.p0306 is 'PDS 0306 (File Message Counts) provides a preliminary "quick check" for the file recipient to indicate that all records in a file have been received. It contains the total number of messages in the file.'
/

comment on column mup_file.header_mti is 'The Message Type Identifier of file header'
/

comment on column mup_file.header_de024 is 'DE 24 (Function Code) of file header'
/

comment on column mup_file.header_de071 is 'DE 71 (Message Number) of file header'
/

comment on column mup_file.trailer_mti is 'The Message Type Identifier of file trailer'
/

comment on column mup_file.trailer_de024 is 'DE 24 (Function Code) of file trailer'
/

comment on column mup_file.trailer_de071 is 'DE 71 (Message Number) of file trailer'
/

alter table mup_file add is_returned         number(1)
/
alter table mup_file add proc_bin            varchar2(6)
/
alter table mup_file add sttl_date           date
/
alter table mup_file add release_number      varchar2(3)
/
alter table mup_file add security_code       varchar2(8)
/
alter table mup_file add visa_file_id        varchar2(3)
/
alter table mup_file add batch_total         number(8)
/
alter table mup_file add monetary_total      number(8)
/
alter table mup_file add tcr_total           number(8)
/
alter table mup_file add trans_total         number(8)
/
alter table mup_file add src_amount          number(22,4)
/
alter table mup_file add dst_amount          number(22,4)
/

comment on column mup_file.is_incoming is 'Incoming flag.'
/
comment on column mup_file.network_id is 'Network identifier.'
/
comment on column mup_file.proc_bin is 'Processing BIN.'
/
comment on column mup_file.proc_date is 'Processing date.'
/
comment on column mup_file.sttl_date is 'Settlement date.'
/
comment on column mup_file.release_number is 'Release number.'
/
comment on column mup_file.security_code is 'Security code.'
/
comment on column mup_file.visa_file_id is 'VISA file identifier.'
/
comment on column mup_file.batch_total is 'Total batches in file.'
/
comment on column mup_file.monetary_total is 'Number of Monetary Transactions'
/
comment on column mup_file.tcr_total is 'Number of TCRs'
/
comment on column mup_file.trans_total is 'Number of Transactions'
/
comment on column mup_file.src_amount is 'Source amount.'
/
comment on column mup_file.dst_amount is 'Destination Amount'
/
comment on column mup_file.is_returned is 'Returned message flag.'
/

alter table mup_file add report_type varchar2(7)
/
comment on column mup_file.report_type is 'ID of report header (HSIR / HAIR/ HOIR)'
/

alter table mup_file add endpoint varchar2(19)
/
comment on column mup_file.endpoint is 'Endpoint'
/

alter table mup_file add de094 varchar(11)
/
comment on column mup_file.de094 is 'Member ID'
/
