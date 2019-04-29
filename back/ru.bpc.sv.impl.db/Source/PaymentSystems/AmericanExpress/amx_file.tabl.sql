create table amx_file (
    id                      number(16) not null
    , is_incoming           number(1)    
    , is_rejected           number(1)        
    , network_id            number(4)         
    , transmittal_date      date    
    , inst_id               number(4)        
    , forw_inst_code        varchar2(11)        
    , receiv_inst_code      varchar2(11)        
    , action_code           varchar2(3)        
    , file_number           varchar2(6)    
    , reject_code           varchar2(40)    
    , msg_total             number(8)    
    , credit_count          number(6)    
    , debit_count           number(6)    
    , credit_amount         number (16)     
    , debit_amount          number (16)     
    , total_amount          number(17)         
    , receipt_file_id       number(16)    
    , reject_message_id     number(16)    
)
/
comment on table amx_file is 'All clearing files'
/
comment on column amx_file.id is 'Primary key. Equal to ID in PRC_SESSION_FILE'
/
comment on column amx_file.is_incoming is '0 - incoming file, 1 – outgoing file'
/
comment on column amx_file.is_rejected is '1 – rejected file'
/
comment on column amx_file.network_id is 'Network identifier'
/
comment on column amx_file.transmittal_date is 'Transmittal date'
/
comment on column amx_file.inst_id is 'Institution identifier'
/
comment on column amx_file.forw_inst_code is 'Forwarding CMID'
/
comment on column amx_file.receiv_inst_code is 'Receiving CMID'
/
comment on column amx_file.action_code is 'Action code'
/
comment on column amx_file.file_number is 'File Sequence Number'
/
comment on column amx_file.reject_code is 'Reject codes(Up to ten (10) Reject Reason Codes may be used in a rejected message)'
/
comment on column amx_file.msg_total is 'Number of messages'
/
comment on column amx_file.credit_count is 'Number of credit'
/
comment on column amx_file.debit_count is 'Number of debit'
/
comment on column amx_file.credit_amount is 'Hash total of all credit transaction amounts of the financial records in the file'
/
comment on column amx_file.debit_amount is 'Hash total of all debit transaction amounts of the financial records in the file'
/
comment on column amx_file.total_amount is 'Hash total of all transaction amounts of the financial records in the file'
/
comment on column amx_file.receipt_file_id is 'Receipt file ID'
/
comment on column amx_file.reject_message_id is 'File Reject Message reference number'
/
alter table amx_file add (session_file_id  number(16))
/
comment on column amx_file.session_file_id is 'File object identifier (prc_session_file.id).'
/

--update--
alter table amx_file add (hash_total_amount  number(17))
/
comment on column amx_file.session_file_id is 'Hash Total Amount'
/

comment on table amx_file is 'Amex clearing files'
/
comment on column amx_file.id is 'Primary key. Equal to ID in prc_session_file'
/
--DAF update--
alter table amx_file modify credit_count number(8)
/
alter table amx_file modify debit_count number(8)  
/
alter table amx_file modify credit_amount number(17)
/
alter table amx_file modify debit_amount number(17)
/
alter table amx_file add func_code varchar2(3 char)
/
comment on column amx_file.func_code is 'Function Code'
/
alter table amx_file add org_identifier varchar2(11 char)
/
comment on column amx_file.org_identifier is 'Organization Identifier'
/
