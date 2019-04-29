create table emv_script_type (
    id                number(4) not null
    , seqnum          number(4)
    , type            varchar2(8)
    , priority        number(4)
    , mac             number(1)
    , tag_71          number(1)
    , tag_72          number(1)
    , condition       varchar2(8)
    , retransmission  number(1)
    , repeat_count    number(4)
)
/
comment on table emv_script_type is 'EMV script type'
/
comment on column emv_script_type.id is 'EMV type identifier'
/
comment on column emv_script_type.seqnum is 'Sequential number of record version'
/
comment on column emv_script_type.type is 'EMV type script (SRTP key)'
/
comment on column emv_script_type.priority is 'Priority'
/
comment on column emv_script_type.mac is 'MAC calculating need flag'
/
comment on column emv_script_type.tag_71 is 'EMV script is sent to the tag tag 71'
/
comment on column emv_script_type.tag_72 is 'EMV script is sent to the tag tag 71'
/
comment on column emv_script_type.condition is 'Script transfer conditions'
/
comment on column emv_script_type.retransmission is 'Required retransmission script'
/
comment on column emv_script_type.repeat_count is 'Number of attempts to retransmit emv script'
/

alter table emv_script_type add (
    class_byte          varchar2(2)
    , instruction_byte  varchar2(2)
    , parameter1        varchar2(2)
    , parameter2        varchar2(2)
    , req_length_data   number(1) 
)
/
comment on column emv_script_type.class_byte is 'Class byte of the command message'
/
comment on column emv_script_type.instruction_byte is 'Instruction byte of command message'
/
comment on column emv_script_type.parameter1 is 'Parameter 1 of command message'
/
comment on column emv_script_type.parameter2 is 'Parameter 2 of command message'
/
comment on column emv_script_type.req_length_data is 'Length of expected data is required'
/
alter table emv_script_type add (
    is_used_by_user    number(1)
    , form_url         varchar2(200)
)
/
comment on column emv_script_type.is_used_by_user is 'Script type is used by the user'
/
comment on column emv_script_type.form_url is 'URL for form parameter'
/