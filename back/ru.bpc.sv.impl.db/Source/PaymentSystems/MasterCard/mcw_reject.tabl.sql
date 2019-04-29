create table mcw_reject (
    id                  number(16)
    , network_id        number(4)
    , inst_id           number(4)
    , file_id           number(8)
    , rejected_fin_id   number(16)
    , rejected_file_id  number(8)
    , mti               varchar2(4)
    , de024             varchar2(3)
    , de071             number(7)
    , de072             varchar2(999)
    , de093             varchar2(11)
    , de094             varchar2(11)
    , de100             varchar2(11)
    , p0005             varchar2(140)
    , p0006             varchar2(10)
    , p0025             varchar2(7)
    , p0026             varchar2(7)
    , p0138             number(8)
    , p0165             varchar2(30)
    , p0280             varchar2(25)
)
/
comment on table mcw_reject is 'Message Exception and File Reject/1644 Message'
/
comment on column mcw_reject.id is 'Identifier'
/
comment on column mcw_reject.network_id is 'Network identifier'
/
comment on column mcw_reject.inst_id is 'Receiver institution'
/
comment on column mcw_reject.file_id is 'File identifier'
/
comment on column mcw_reject.rejected_fin_id is 'Identifier of rejected message'
/
comment on column mcw_reject.rejected_file_id is 'Identifier of rejected file'
/
comment on column mcw_reject.mti is 'Message Type Identifier'
/
comment on column mcw_reject.de024 is 'Function Code'
/
comment on column mcw_reject.de071 is 'Message Number'
/
comment on column mcw_reject.de072 is 'Data Record'
/
comment on column mcw_reject.de093 is 'Transaction Destination Institution ID Code'
/
comment on column mcw_reject.de094 is 'Transaction Originator Institution ID Code'
/
comment on column mcw_reject.de100 is 'Receiving Institution ID Code'
/
comment on column mcw_reject.p0005 is 'Message Error Indicator'
/
comment on column mcw_reject.p0006 is 'Applied Business Service Arrangement'
/
comment on column mcw_reject.p0025 is 'Message Reversal Indicator'
/
comment on column mcw_reject.p0026 is 'File Reversal Indicator'
/
comment on column mcw_reject.p0138 is 'Source Message Number ID'
/
comment on column mcw_reject.p0165 is 'Settlement Indicator'
/
comment on column mcw_reject.p0280 is 'Source File ID'
/
