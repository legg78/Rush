create table jcb_add (
    id              number(16) not null
    , fin_id        number(16)
    , file_id       number(8)
    , is_incoming   number(1)
    , mti           varchar2(4)
    , de024         varchar2(3)
    , de032         varchar2(11)
    , de033         varchar2(11)
    , de071         number(8)
    , de093         varchar2(11)
    , de094         varchar2(11)
    , de100         varchar2(11)
    , p3600         varchar2(13)
    , p3600_1       number(8)
    , p3600_2       varchar2(2)
    , p3600_3       varchar2(3)
    , p3601         varchar2(1)
    , p3602         varchar2(15)
    , p3604         varchar2(25)
)
/

comment on table jcb_add is 'Financial Detail Addendum/1644 Messages'
/

comment on column jcb_add.id is 'Addendum message identifier'
/

comment on column jcb_add.fin_id is 'Reference to financial message which addendum belongs to'
/

comment on column jcb_add.file_id is 'Logical file identifier'
/

comment on column jcb_add.is_incoming is 'Incoming indicator'
/

comment on column jcb_add.mti is 'Message Type Identifier'
/

comment on column jcb_add.de024 is 'Function Code'
/

comment on column jcb_add.de071 is 'Message Number'
/

comment on column jcb_add.de032 is 'Acquiring Institution ID Code'
/

comment on column jcb_add.de033 is 'Forwarding Institution ID Code'
/

comment on column jcb_add.de093 is 'Transaction Destination Institution ID Code'
/

comment on column jcb_add.de094 is 'Transaction Originator Institution ID Code'
/

comment on column jcb_add.de100 is 'Receiving Institution ID Code'
/

comment on column jcb_add.p3600 is 'Addendum Control Data'
/

comment on column jcb_add.p3600_1 is 'Presentment Message Number'
/

comment on column jcb_add.p3600_2 is 'Addendum Info Type'
/

comment on column jcb_add.p3600_3 is 'Sequence Numbers of Addendum'
/

comment on column jcb_add.p3601 is 'No-Show Indicator'
/

comment on column jcb_add.p3602 is 'Travel Agency ID/Code'
/

comment on column jcb_add.p3604 is 'Travel Agency Name'
/
