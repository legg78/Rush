create table cup_file (
    id                      number(16) not null
    , is_incoming           number(1)    
    , is_rejected           number(1)        
    , network_id            number(4)         
    , trans_date            date    
    , inst_id               number(4)   
    , inst_name             varchar2(200) --??? com_i18 
    , action_code           number(1)        
    , file_number           number(2)    
    , pack_no               varchar2(9)       
    , version               varchar2(10)    
    , crc                   number(20)    
    , encoding              varchar2(6) 
    , file_type             varchar2(10)    
)
/
comment on table cup_file is 'All clearing files'
/
comment on column cup_file.id is 'Primary key. Equal to ID in PRC_SESSION_FILE'
/
comment on column cup_file.is_incoming is '0 - incoming file, 1 – outgoing file'
/
comment on column cup_file.is_rejected is '1 – rejected file'
/
comment on column cup_file.network_id is 'Network identifier'
/
comment on column cup_file.trans_date is 'Transmittal date'
/
comment on column cup_file.inst_id is 'Institution identifier'
/
comment on column cup_file.inst_name is 'Institution name'
/
comment on column cup_file.action_code is 'Action code'
/
comment on column cup_file.file_number is 'File Sequence Number'
/
comment on column cup_file.pack_no is 'Serial number of the packet'
/
comment on column cup_file.version is 'Protocol Version'
/
comment on column cup_file.crc is 'Check sum'
/
comment on column cup_file.encoding is 'File encoding'
/
comment on column cup_file.file_type is 'File type'
/
alter table cup_file add(session_file_id number(16))
/
comment on column cup_file.session_file_id is 'Session file identifier'
/
