create table mup_fsum (
    id number(16)
    , network_id number(4)
    , inst_id number(4)
    , file_id number(8)
    , status varchar2(8)
    , mti varchar2(4)
    , de024 varchar2(3)
    , de025 varchar2(4)
    , de049 varchar2(3)
    , de071 number(8)
    , de093 varchar2(11)
    , de100 varchar2(11)
    , p0148 varchar2(60)
    , p0300 varchar2(25)
    , p0380_1 varchar2(1)
    , p0380_2 number(16)
    , p0381_1 varchar2(1)
    , p0381_2 number(16)
    , p0384_1 varchar2(1)
    , p0384_2 number(16)
    , p0400 number(10)
    , p0401 number(10)
    , p0402 number(10)
)
/
comment on table mup_fsum is 'Financial Position Detail/1644 Messages'
/
comment on column mup_fsum.id is 'Message identifier'
/
comment on column mup_fsum.network_id is 'Network identifier'
/
comment on column mup_fsum.inst_id is 'Receiving institution identifier'
/
comment on column mup_fsum.file_id is 'File identifier'
/
comment on column mup_fsum.status is 'Message status'
/
comment on column mup_fsum.mti is 'Message Type Identifier'
/
comment on column mup_fsum.de024 is 'Function Code'
/
comment on column mup_fsum.de025 is 'Message Reason Code'
/
comment on column mup_fsum.de049 is 'Currency Code, Transaction'
/
comment on column mup_fsum.de071 is 'Message Number'
/
comment on column mup_fsum.de093 is 'Transaction Destination Institution ID Code'
/
comment on column mup_fsum.de100 is 'Receiving Institution ID Code'
/
comment on column mup_fsum.p0148 is 'Currency Exponents'
/
comment on column mup_fsum.p0300 is 'Reconciled, File'
/
comment on column mup_fsum.p0380_1 is 'Debits, Transaction Amount in Transaction Currency'
/
comment on column mup_fsum.p0380_2 is 'Debits, Transaction Amount in Transaction Currency'
/
comment on column mup_fsum.p0381_1 is 'Credits, Transaction Amount in Transaction Currency'
/
comment on column mup_fsum.p0381_2 is 'Credits, Transaction Amount in Transaction Currency'
/
comment on column mup_fsum.p0384_1 is 'Amount, Net Transaction in Transaction Currency'
/
comment on column mup_fsum.p0384_2 is 'Amount, Net Transaction in Transaction Currency'
/
comment on column mup_fsum.p0400 is 'Debits, Transaction Number'
/
comment on column mup_fsum.p0401 is 'Credits, Transaction Number'
/
comment on column mup_fsum.p0402 is 'Total, Transaction Number'
/
