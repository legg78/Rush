create table mcw_reason_code (
    mti             varchar2(4)
    , de024         varchar2(3)
    , de025         varchar2(4)
    , description   varchar2(2000)
    , de072         varchar2(999)
    , de003         varchar2(6)
    , p0262         number(1)
    , fee_enabled   number(1)
)
/
comment on table mcw_reason_code is 'Message reason codes'
/
comment on column mcw_reason_code.mti is 'Message Type Identifier'
/
comment on column mcw_reason_code.de024 is 'Function Code'
/
comment on column mcw_reason_code.de025 is 'Message Reason Code'
/
comment on column mcw_reason_code.description is 'Description'
/
comment on column mcw_reason_code.de072 is 'Data Record'
/
comment on column mcw_reason_code.de003 is 'Processing Code'
/
comment on column mcw_reason_code.p0262 is 'Documentation Indicator'
/
comment on column mcw_reason_code.fee_enabled is 'Handling fee enabled'
/
