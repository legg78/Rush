create table mcw_fpd (
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
    , p0358_1       varchar2(3)
    , p0358_2       varchar2(1)
    , p0358_3       varchar2(6)
    , p0358_4       varchar2(2)
    , p0358_5       date
    , p0358_6       number(2)
    , p0358_7       varchar2(1)
    , p0358_8       varchar2(3)
    , p0358_9       varchar2(1)
    , p0358_10      varchar2(1)
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
    , p0395_2       number(16)
    , p0396_1       varchar2(1)
    , p0396_2       number(16)
    , p0400         number(10)
    , p0401         number(10)
    , p0402         number(10)
)
/    
comment on table mcw_fpd is 'Financial Position Detail/1644 Messages'
/
comment on column mcw_fpd.id is 'Message identifier'
/
comment on column mcw_fpd.network_id is 'Network identifier'
/
comment on column mcw_fpd.inst_id is 'Receiving institution identifier'
/
comment on column mcw_fpd.file_id is 'File identifier'
/
comment on column mcw_fpd.status is 'Message status'
/
comment on column mcw_fpd.mti is 'Message Type Identifier'
/
comment on column mcw_fpd.de024 is 'Function Code'
/
comment on column mcw_fpd.de025 is 'Message Reason Code'
/
comment on column mcw_fpd.de026 is 'Card Acceptor Business Code'
/
comment on column mcw_fpd.de049 is 'Currency Code, Transaction'
/
comment on column mcw_fpd.de050 is 'Currency Code, Reconciliation'
/
comment on column mcw_fpd.de071 is 'Message Number'
/
comment on column mcw_fpd.de093 is 'Transaction Destination Institution ID Code'
/
comment on column mcw_fpd.de100 is 'Receiving Institution ID Code'
/
comment on column mcw_fpd.p0148 is 'Currency Exponents'
/
comment on column mcw_fpd.p0165 is 'Settlement Indicator'
/
comment on column mcw_fpd.p0300 is 'Reconciled, File'
/
comment on column mcw_fpd.p0302 is 'Reconciled, Member Activity'
/
comment on column mcw_fpd.p0358_1 is 'Card Program Identifier'
/
comment on column mcw_fpd.p0358_2 is 'Business Service Arrangement Type Code'
/
comment on column mcw_fpd.p0358_3 is 'Business Service ID Code'
/
comment on column mcw_fpd.p0358_4 is 'Interchange Rate Designator'
/
comment on column mcw_fpd.p0358_5 is 'Business Date'
/
comment on column mcw_fpd.p0358_6 is 'Business Cycle'
/
comment on column mcw_fpd.p0358_7 is 'Card Acceptor Classification Override Indicator'
/
comment on column mcw_fpd.p0358_8 is 'Product Class Override Indicator'
/
comment on column mcw_fpd.p0358_9 is 'Corporate Incentive Rates Apply Indicator'
/
comment on column mcw_fpd.p0358_10 is 'Special Conditions Indicator'
/
comment on column mcw_fpd.p0370_1 is 'Reconciled, Account Range'
/
comment on column mcw_fpd.p0370_2 is 'Reconciled, Account Range'
/
comment on column mcw_fpd.p0372_1 is 'Reconciled, Transaction Function'
/
comment on column mcw_fpd.p0372_2 is 'Reconciled, Transaction Function'
/
comment on column mcw_fpd.p0374 is 'Reconciled, Processing Code'
/
comment on column mcw_fpd.p0375 is 'Member Reconciliation Indicator'
/
comment on column mcw_fpd.p0378 is 'Original/Reversal Totals Indicator'
/
comment on column mcw_fpd.p0380_1 is 'Debits, Transaction Amount in Transaction Currency'
/
comment on column mcw_fpd.p0380_2 is 'Debits, Transaction Amount in Transaction Currency'
/
comment on column mcw_fpd.p0381_1 is 'Credits, Transaction Amount in Transaction Currency'
/
comment on column mcw_fpd.p0381_2 is 'Credits, Transaction Amount in Transaction Currency'
/
comment on column mcw_fpd.p0384_1 is 'Amount, Net Transaction in Transaction Currency'
/
comment on column mcw_fpd.p0384_2 is 'Amount, Net Transaction in Transaction Currency'
/
comment on column mcw_fpd.p0390_1 is 'Debits, Transaction Amount in Reconciliation Currency'
/
comment on column mcw_fpd.p0390_2 is 'Debits, Transaction Amount in Reconciliation Currency'
/
comment on column mcw_fpd.p0391_1 is 'Credits, Transaction Amount in Reconciliation Currency'
/
comment on column mcw_fpd.p0391_2 is 'Credits, Transaction Amount in Reconciliation Currency'
/
comment on column mcw_fpd.p0392 is 'Debits, Fee Amount in Reconciliation Currency'
/
comment on column mcw_fpd.p0393 is 'Credits, Fee Amount in Reconciliation Currency'
/
comment on column mcw_fpd.p0394_1 is 'Amount, Net Transaction in Reconciliation Currency'
/
comment on column mcw_fpd.p0394_2 is 'Amount, Net Transaction in Reconciliation Currency'
/
comment on column mcw_fpd.p0395_1 is 'Amount, Net Fee in Reconciliation Currency'
/
comment on column mcw_fpd.p0395_2 is 'Amount, Net Fee in Reconciliation Currency'
/
comment on column mcw_fpd.p0396_1 is 'Amount, Net Total in Reconciliation Currency'
/
comment on column mcw_fpd.p0396_2 is 'Amount, Net Total in Reconciliation Currency'
/
comment on column mcw_fpd.p0400 is 'Debits, Transaction Number'
/
comment on column mcw_fpd.p0401 is 'Credits, Transaction Number'
/
comment on column mcw_fpd.p0402 is 'Total, Transaction Number'
/

alter table mcw_fpd add p0358_11 varchar2(1)
/
alter table mcw_fpd add p0358_12 varchar2(1)
/
alter table mcw_fpd add p0358_13 varchar2(1)
/
alter table mcw_fpd add p0358_14 varchar2(1)
/

comment on column mcw_fpd.p0358_11 is 'MasterCard Assigned ID Override Indicator'
/
comment on column mcw_fpd.p0358_12 is 'Account Level Management Account Category Code'
/
comment on column mcw_fpd.p0358_13 is 'Rate Indicator'
/
comment on column mcw_fpd.p0358_14 is 'MasterPass Incentive Indicator'
/

alter table mcw_fpd add p0397 varchar2(252)
/
comment on column mcw_fpd.p0397 is 'Debits, Extended Precision Amount in Reconciliation Currency'
/
alter table mcw_fpd add p0398 varchar2(252)
/
comment on column mcw_fpd.p0398 is 'Credits, Extended Precision Amount in Reconciliation Currency'
/
alter table mcw_fpd add p0399_1 varchar2(1)
/
comment on column mcw_fpd.p0399_1 is 'Debit/Credit Indicator, Net Extended Precision in Reconciliation Currency'
/
alter table mcw_fpd add p0399_2 number(18)
/
comment on column mcw_fpd.p0399_2 is 'Amount, Net Extended Precision in Reconciliation Currency'
/
