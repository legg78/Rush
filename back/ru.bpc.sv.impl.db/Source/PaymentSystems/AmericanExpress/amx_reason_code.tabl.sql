create table amx_reason_code (
    mtid            varchar2(4)
    , reason_code   varchar2(4)
    , description   varchar2(2000)
)
/
comment on table amx_reason_code is 'Message reason codes'
/
comment on column amx_reason_code.mtid is 'Message Type Identifier'
/
comment on column amx_reason_code.reason_code is 'Message Reason Code'
/
comment on column amx_reason_code.description is 'Description'
/
