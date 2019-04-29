create table mup_fpd (
    id              number(16)
    , network_id    number(4)
    , inst_id       number(4)
    , file_id       number(8)
    , status        varchar2(8)
    , mti           varchar2(4)
    , de024         varchar2(3)
    , de025         varchar2(4)
    , de026         varchar2(4)
    , de049         varchar2(3)
    , de050         varchar2(3)
    , de071         number(8)
    , de093         varchar2(11)
    , de100         varchar2(11)
    , p0148         varchar2(60)
    , p0165         varchar2(30)
    , p0300         varchar2(25)
    , p0302         varchar2(1)
    , p0369         varchar2(6)
    , p0370_1       varchar2(19)
    , p0370_2       varchar2(19)
    , p0372_1       number(4)
    , p0372_2       number(3)
    , p0374         varchar2(2)
    , p0375         varchar2(50)
    , p0378         varchar2(1)
    , p0380_1       varchar2(1)
    , p0380_2       number(16)
    , p0381_1       varchar2(1)
    , p0381_2       number(16)
    , p0384_1       varchar2(1)
    , p0384_2       number(16)
    , p0390_1       varchar2(1)
    , p0390_2       number(16)
    , p0391_1       varchar2(1)
    , p0391_2       number(16)
    , p0392         varchar2(216)
    , p0393         varchar2(216)
    , p0394_1       varchar2(1)
    , p0394_2       number(16)
    , p0395_1       varchar2(1)
    , p0395_2       number(15)
    , p0396_1       varchar2(1)
    , p0396_2       number(16)
    , p0400         number(10)
    , p0401         number(10)
    , p0402         number(10)
    , p2358_1       varchar2(4)
    , p2358_2       date
    , p2358_3       number(2)
    , p2358_4       varchar2(1)
    , p2358_5       varchar2(3)
    , p2358_6       varchar2(2)
    , p2359_1       varchar2(11)
    , p2359_2       varchar2(1)
    , p2359_3       varchar2(10)
    , p2359_4       date
    , p2359_5       number(2)
    , p2359_6       date
)
/    
comment on table mup_fpd is 'Financial Position Detail/1644 Messages'
/
comment on column mup_fpd.id is 'Message identifier'
/
comment on column mup_fpd.network_id is 'Network identifier'
/
comment on column mup_fpd.inst_id is 'Receiving institution identifier'
/
comment on column mup_fpd.file_id is 'File identifier'
/
comment on column mup_fpd.status is 'Message status'
/
comment on column mup_fpd.mti is 'Message Type Identifier'
/
comment on column mup_fpd.de024 is 'Function Code'
/
comment on column mup_fpd.de025 is 'Message Reason Code'
/
comment on column mup_fpd.de026 is 'Card Acceptor Business Code'
/
comment on column mup_fpd.de049 is 'Currency Code, Transaction'
/
comment on column mup_fpd.de050 is 'Currency Code, Reconciliation'
/
comment on column mup_fpd.de071 is 'Message Number'
/
comment on column mup_fpd.de093 is 'Transaction Destination Institution ID Code'
/
comment on column mup_fpd.de100 is 'Receiving Institution ID Code'
/
comment on column mup_fpd.p0148 is 'Currency Exponents'
/
comment on column mup_fpd.p0165 is 'Settlement Indicator'
/
comment on column mup_fpd.p0300 is 'Reconciled, File'
/
comment on column mup_fpd.p0302 is 'Reconciled, Member Activity'
/
comment on column mup_fpd.p0369 is 'Reconciled, Acquirer`s BIN'
/
comment on column mup_fpd.p2358_1 is 'Network ID'
/
comment on column mup_fpd.p2358_2 is 'Reconciliation Date'
/
comment on column mup_fpd.p2358_3 is 'Reconciliation Cycle'
/
comment on column mup_fpd.p2358_4 is 'Reconciliation Level'
/
comment on column mup_fpd.p2358_5 is 'Product ID'
/
comment on column mup_fpd.p2358_6 is 'Interchange Fee Descriptor – IFD'
/
comment on column mup_fpd.p2359_1 is 'Settlement Service Transfer Agent ID Code'
/
comment on column mup_fpd.p2359_2 is 'Settlement Service Level Code'
/
comment on column mup_fpd.p2359_3 is 'Settlement Service ID Code'
/
comment on column mup_fpd.p2359_4 is 'Reconciliation Date'
/
comment on column mup_fpd.p2359_5 is 'Reconciliation Cycle'
/
comment on column mup_fpd.p2359_6 is 'Settlement Date'
/
comment on column mup_fpd.p2359_6 is 'Settlement Date'
/
comment on column mup_fpd.p0370_1 is 'Reconciled, Account Range'
/
comment on column mup_fpd.p0370_2 is 'Reconciled, Account Range'
/
comment on column mup_fpd.p0372_1 is 'Reconciled, Transaction Function'
/
comment on column mup_fpd.p0372_2 is 'Reconciled, Transaction Function'
/
comment on column mup_fpd.p0374 is 'Reconciled, Processing Code'
/
comment on column mup_fpd.p0375 is 'Member Reconciliation Indicator'
/
comment on column mup_fpd.p0378 is 'Original/Reversal Totals Indicator'
/
comment on column mup_fpd.p0380_1 is 'Debits, Transaction Amount in Transaction Currency'
/
comment on column mup_fpd.p0380_2 is 'Debits, Transaction Amount in Transaction Currency'
/
comment on column mup_fpd.p0381_1 is 'Credits, Transaction Amount in Transaction Currency'
/
comment on column mup_fpd.p0381_2 is 'Credits, Transaction Amount in Transaction Currency'
/
comment on column mup_fpd.p0384_1 is 'Amount, Net Transaction in Transaction Currency'
/
comment on column mup_fpd.p0384_2 is 'Amount, Net Transaction in Transaction Currency'
/
comment on column mup_fpd.p0390_1 is 'Debits, Transaction Amount in Reconciliation Currency'
/
comment on column mup_fpd.p0390_2 is 'Debits, Transaction Amount in Reconciliation Currency'
/
comment on column mup_fpd.p0391_1 is 'Credits, Transaction Amount in Reconciliation Currency'
/
comment on column mup_fpd.p0391_2 is 'Credits, Transaction Amount in Reconciliation Currency'
/
comment on column mup_fpd.p0392 is 'Debits, Fee Amount in Reconciliation Currency'
/
comment on column mup_fpd.p0393 is 'Credits, Fee Amount in Reconciliation Currency'
/
comment on column mup_fpd.p0394_1 is 'Amount, Net Transaction in Reconciliation Currency'
/
comment on column mup_fpd.p0394_2 is 'Amount, Net Transaction in Reconciliation Currency'
/
comment on column mup_fpd.p0395_1 is 'Amount, Net Fee in Reconciliation Currency'
/
comment on column mup_fpd.p0395_2 is 'Amount, Net Fee in Reconciliation Currency'
/
comment on column mup_fpd.p0396_1 is 'Amount, Net Total in Reconciliation Currency'
/
comment on column mup_fpd.p0396_2 is 'Amount, Net Total in Reconciliation Currency'
/
comment on column mup_fpd.p0400 is 'Debits, Transaction Number'
/
comment on column mup_fpd.p0401 is 'Credits, Transaction Number'
/
comment on column mup_fpd.p0402 is 'Total, Transaction Number'
/
