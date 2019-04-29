create table mup_reject_code (
    id                  number(16)
    , reject_data_id    number(16)
    , de_number         varchar2(5)
    , severity_code     varchar2(2)
    , message_code      varchar2(255)
    , subfield_id       varchar2(3)
    , is_from_orig_msg  number(1)
)
/
comment on table mup_reject_code is 'Message Error Indicator (MUP Reject codes)'
/
comment on column mup_reject_code.id is 'Unique identifier'
/
comment on column mup_reject_code.reject_data_id is 'Reject data record identifier (FK mcw_reject_data.id)'
/
comment on column mup_reject_code.de_number is 'Data Element ID (DE)'
/
comment on column mup_reject_code.severity_code is 'Error Severity Code'
/
comment on column mup_reject_code.message_code is 'Error Message Code'
/
comment on column mup_reject_code.subfield_id is 'Subfield ID'
/
comment on column mup_reject_code.de_number is 'Data Element ID (DE)'
/
comment on column mup_reject_code.severity_code is 'Error Severity Code'
/
comment on column mup_reject_code.message_code is 'Error Message Code'
/
comment on column mup_reject_code.subfield_id is 'Subfield ID (PDS)'
/
comment on column mup_reject_code.is_from_orig_msg is '1 - code comed from field of source reject message, 0 - from validation rules'
/
comment on column mup_reject_code.reject_data_id is 'Reject data record identifier (FK mup_reject_data.id)'
/
