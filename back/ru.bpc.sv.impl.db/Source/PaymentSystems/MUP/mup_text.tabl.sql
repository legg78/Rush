create table mup_text (
    id              number(16)
    , network_id    number(4)
    , inst_id       number(4)
    , file_id       number(8)
    , mti           varchar2(4)
    , de024         varchar2(3)
    , de025         varchar2(4)
    , de071         number(7)
    , de072         varchar2(999)
    , de093         varchar2(11)
    , de094         varchar2(11)
    , de100         varchar2(11)
)
/
comment on table mup_text is 'Currency Update/1644 Messages'
/
comment on column mup_text.id is 'Identifier'
/
comment on column mup_text.inst_id is 'Receiver institution'
/
comment on column mup_text.file_id is 'File identifier'
/
comment on column mup_text.mti is 'Message Type Identifier'
/
comment on column mup_text.de024 is 'Function Code'
/
comment on column mup_text.de025 is 'Message Reason Code'
/
comment on column mup_text.de071 is 'Message Number'
/
comment on column mup_text.de072 is 'Data Record'
/
comment on column mup_text.de093 is 'Transaction Destination Institution ID Code'
/
comment on column mup_text.de094 is 'Transaction Originator Institution ID Code'
/
comment on column mup_text.de100 is 'Receiving Institution ID Code'
/

