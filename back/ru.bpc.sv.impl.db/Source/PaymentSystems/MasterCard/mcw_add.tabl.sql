create table mcw_add (
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
    , p0501_1       varchar2(2)
    , p0501_2       varchar2(3)
    , p0501_3       number(7)
    , p0501_4       number(7)
)
/

comment on table mcw_add is 'Financial Detail Addendum/1644 Messages'
/

comment on column mcw_add.id is 'Addendum message identifier'
/

comment on column mcw_add.fin_id is 'Reference to financial message which addendum belongs to'
/

comment on column mcw_add.file_id is 'Logical file identifier'
/

comment on column mcw_add.is_incoming is 'Incoming indicator'
/

comment on column mcw_add.mti is 'Message Type Identifier'
/

comment on column mcw_add.de024 is 'Function Code'
/

comment on column mcw_add.de071 is 'Message Number'
/

comment on column mcw_add.de032 is 'Acquiring Institution ID Code'
/

comment on column mcw_add.de033 is 'Forwarding Institution ID Code'
/

comment on column mcw_add.de063 is 'Transaction Life Cycle ID'
/

comment on column mcw_add.de093 is 'Transaction Destination Institution ID Code'
/

comment on column mcw_add.de094 is 'Transaction Originator Institution ID Code'
/

comment on column mcw_add.de100 is 'Receiving Institution ID Code'
/

comment on column mcw_add.p0501_1 is 'Usage Code'
/

comment on column mcw_add.p0501_2 is 'Industry Record Number'
/

comment on column mcw_add.p0501_3 is 'Occurrence Indicator'
/

comment on column mcw_add.p0501_4 is 'Associated First Presentment Number'
/

alter table mcw_add add p0715_1 varchar2(2)
/
comment on column mcw_add.p0715_1 is 'Ancillary Fee Code'
/

alter table mcw_add add p0715_2 number(12)
/
comment on column mcw_add.p0715_2 is 'Amount, Ancillary Fee'
/

alter table mcw_add add p0715 varchar2(4000)
/
comment on column mcw_add.p0715 is 'Ancillary Fee code and amount (all occurences)'
/
alter table mcw_add drop column p0715_1
/
alter table mcw_add drop column p0715_2
/
