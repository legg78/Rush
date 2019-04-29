create table mcw_file (
    id                  number(8) not null
    , inst_id           number(4)
    , network_id        number(4)
    , is_incoming       number(1)
    , proc_date         date
    , session_file_id   number(8)
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

comment on table mcw_file is 'MasterCard logical files'
/

comment on column mcw_file.id is 'Identifier'
/

comment on column mcw_file.inst_id is 'Institution identifier'
/

comment on column mcw_file.network_id is 'Network identifier'
/

comment on column mcw_file.is_incoming is 'Incoming indicator'
/

comment on column mcw_file.proc_date is 'Processing date'
/

comment on column mcw_file.session_file_id is 'Session file identifier'
/

comment on column mcw_file.is_rejected is 'Rejected idicator'
/

comment on column mcw_file.reject_id is 'Reject message identifier'
/

comment on column mcw_file.p0026 is 'PDS 0026 (File Reversal Indicator) identifies the entire file as a reversal of a previous file.'
/

comment on column mcw_file.p0105 is 'PDS 0105 (File ID) uniquely identifies a logical data file to be exchanged between a member or processor and the clearing system.'
/

comment on column mcw_file.p0110 is 'PDS 0110 (Transmission ID) uniquely identifies a physical transmission or grouping of logical files to be exchanged between a member or processor and the clearing system.'
/

comment on column mcw_file.p0122 is 'PDS 0122 (Processing Mode) indicates the type of processing to be performed on transaction messages.'
/

comment on column mcw_file.p0301 is 'PDS 0301 (File Amount, Checksum) provides a preliminary "quick check" for the file recipient to indicate or to determine that it received all messages in a file.'
/

comment on column mcw_file.p0306 is 'PDS 0306 (File Message Counts) provides a preliminary "quick check" for the file recipient to indicate that all records in a file have been received. It contains the total number of messages in the file.'
/

comment on column mcw_file.header_mti is 'The Message Type Identifier of file header'
/

comment on column mcw_file.header_de024 is 'DE 24 (Function Code) of file header'
/

comment on column mcw_file.header_de071 is 'DE 71 (Message Number) of file header'
/

comment on column mcw_file.trailer_mti is 'The Message Type Identifier of file trailer'
/

comment on column mcw_file.trailer_de024 is 'DE 24 (Function Code) of file trailer'
/

comment on column mcw_file.trailer_de071 is 'DE 71 (Message Number) of file trailer'
/
alter table mcw_file modify session_file_id number(16)
/

alter table mcw_file add local_file number(1)
/
comment on column mcw_file.local_file is 'Sign of file with domestic transactions'
/
