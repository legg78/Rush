create table mup_add (
    id              number(16) not null
    , fin_id        number(16)
    , file_id       number(8)
    , is_incoming   number(1)
    , mti           varchar2(4)
    , de024         varchar2(3)
    , de071         number(7)
    , de032         varchar2(11)
    , de033         varchar2(11)
    , de063         varchar2(16)
    , de093         varchar2(11)
    , de094         varchar2(11)
    , de100         varchar2(11)
)
/

comment on table mup_add is 'Financial Detail Addendum/1644 Messages'
/

comment on column mup_add.id is 'Addendum message identifier'
/

comment on column mup_add.fin_id is 'Reference to financial message which addendum belongs to'
/

comment on column mup_add.file_id is 'Logical file identifier'
/

comment on column mup_add.is_incoming is 'Incoming indicator'
/

comment on column mup_add.mti is 'Message Type Identifier'
/

comment on column mup_add.de024 is 'Function Code'
/

comment on column mup_add.de071 is 'Message Number'
/

comment on column mup_add.de032 is 'Acquiring Institution ID Code'
/

comment on column mup_add.de033 is 'Forwarding Institution ID Code'
/

comment on column mup_add.de063 is 'Transaction Life Cycle ID'
/

comment on column mup_add.de093 is 'Transaction Destination Institution ID Code'
/

comment on column mup_add.de094 is 'Transaction Originator Institution ID Code'
/

comment on column mup_add.de100 is 'Receiving Institution ID Code'
/

