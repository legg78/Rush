create table amx_msg_impact (
    mtid            number(4)
    , func_code     varchar2(3)
    , proc_code     varchar2(6)
    , incoming      number(1)
    , impact        number(1)
)
/
comment on table amx_msg_impact is ''
/
comment on column amx_msg_impact.mtid is 'Message type'
/
comment on column amx_msg_impact.func_code is 'Function Code'
/
comment on column amx_msg_impact.proc_code is 'Processing Code'
/
comment on column amx_msg_impact.incoming is '0 - incoming file, 1 – outgoing file'
/
comment on column amx_msg_impact.impact is 'Impact'
/
