create table emv_script (
    id             number(16) not null
    , object_id    number(16)
    , entity_type  varchar2(8)
    , type_id      number(4)
    , body         varchar2(512)
    , status       varchar2(8)
)
/
comment on table emv_script is 'EMV scripts'
/
comment on column emv_script.id is 'Script identifier'
/
comment on column emv_script.object_id is 'Object identifier using script'
/
comment on column emv_script.entity_type is 'Entity type using script'
/
comment on column emv_script.type_id is 'Script type identifier'
/
comment on column emv_script.body is 'Script body'
/
comment on column emv_script.status is 'EMV script status (SRST key)'
/
alter table emv_script drop column body
/
alter table emv_script add class_byte varchar2(2)
/
alter table emv_script add instruction_byte  varchar2(2)
/
alter table emv_script add parameter1 varchar2(2)
/
alter table emv_script add parameter2 varchar2(2)
/
alter table emv_script add length number(4)
/
alter table emv_script add data varchar2(200)
/
comment on column emv_script.class_byte is 'Class byte of the command message'
/
comment on column emv_script.instruction_byte is 'Instruction byte of command message'
/
comment on column emv_script.parameter1 is 'Parameter 1 of command message'
/
comment on column emv_script.parameter2 is 'Parameter 2 of command message'
/
comment on column emv_script.length is 'Maximum number of bytes expected in the data field of the response to the command'
/
comment on column emv_script.data is 'String of bytes sent in the data field of the command'
/
alter table emv_script add change_date date
/
comment on column emv_script.change_date is 'Data of changing script status'
/