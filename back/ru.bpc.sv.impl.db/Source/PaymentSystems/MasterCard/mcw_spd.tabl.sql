create table mcw_spd (
    id number(16)
    , network_id number(4)
    , inst_id number(4)
    , file_id number(8)
    , status varchar2(8)
    , mti varchar2(4)
    , de024 varchar2(3)
    , de025 varchar2(4)
    , de049 varchar2(3)
    , de050 varchar2(3)
    , de071 number(8)
    , de093 varchar2(11)
    , de100 varchar2(11)
    , p0148 varchar2(60)
    , p0300 varchar2(25)
    , p0302 varchar2(1)
    , p0359 varchar2(67)
    , p0367 varchar2(3)
    , p0368 varchar2(2)
    , p0369 varchar2(6)
    , p0370_1 varchar2(19)
    , p0370_2 varchar2(19)
    , p0390_1 varchar2(1)
    , p0390_2 number(16)
    , p0391_1 varchar2(1)
    , p0391_2 number(16)
    , p0392 varchar2(216)
    , p0393 varchar2(216)
    , p0394_1 varchar2(1)
    , p0394_2 number(16)
    , p0395_1 varchar2(1)
    , p0395_2 number(16)
    , p0396_1 varchar2(1)
    , p0396_2 number(16)
)
/
comment on table mcw_spd is 'Settlement Position Detail/1644 Messages'
/
comment on column mcw_spd.id is 'Message identifier'
/
comment on column mcw_spd.network_id is 'Network identifier'
/
comment on column mcw_spd.inst_id is 'Receiving institution identifier'
/
comment on column mcw_spd.file_id is 'File identifier'
/
comment on column mcw_spd.status is 'Message status'
/
comment on column mcw_spd.mti is 'Message Type Identifier'
/
comment on column mcw_spd.de024 is 'Function Code'
/
comment on column mcw_spd.de025 is 'Message Reason Code'
/
comment on column mcw_spd.de049 is 'Currency Code, Transaction'
/
comment on column mcw_spd.de050 is 'Currency Code, Reconciliation'
/
comment on column mcw_spd.de071 is 'Message Number'
/
comment on column mcw_spd.de093 is 'Transaction Destination Institution ID Code'
/
comment on column mcw_spd.de100 is 'Receiving Institution ID Code'
/
comment on column mcw_spd.p0148 is 'Currency Exponents'
/
comment on column mcw_spd.p0300 is 'Reconciled, File'
/
comment on column mcw_spd.p0302 is 'Reconciled, Member Activity'
/
comment on column mcw_spd.p0359 is 'Reconciled, Settlement Activity'
/
comment on column mcw_spd.p0367 is 'Reconciled, Card Program Identifier'
/
comment on column mcw_spd.p0368 is 'Reconciled, Transaction Function Group Code'
/
comment on column mcw_spd.p0369 is 'Reconciled, Acquirers BIN'
/
comment on column mcw_spd.p0370_1 is 'Reconciled, Account Range'
/
comment on column mcw_spd.p0370_2 is 'Reconciled, Account Range'
/
comment on column mcw_spd.p0390_1 is 'Debits, Transaction Amount in Reconciliation Currency'
/
comment on column mcw_spd.p0390_2 is 'Debits, Transaction Amount in Reconciliation Currency'
/
comment on column mcw_spd.p0391_1 is 'Credits, Transaction Amount in Reconciliation Currency'
/
comment on column mcw_spd.p0391_2 is 'Credits, Transaction Amount in Reconciliation Currency'
/
comment on column mcw_spd.p0392 is 'Debits, Fee Amount in Reconciliation Currency'
/
comment on column mcw_spd.p0393 is 'Credits, Fee Amount in Reconciliation Currency'
/
comment on column mcw_spd.p0394_1 is 'Amount, Net Transaction in Reconciliation Currency'
/
comment on column mcw_spd.p0394_2 is 'Amount, Net Transaction in Reconciliation Currency'
/
comment on column mcw_spd.p0395_1 is 'Amount, Net Fee in Reconciliation Currency'
/
comment on column mcw_spd.p0395_2 is 'Amount, Net Fee in Reconciliation Currency'
/
comment on column mcw_spd.p0396_1 is 'Amount, Net Total in Reconciliation Currency'
/
comment on column mcw_spd.p0396_2 is 'Amount, Net Total in Reconciliation Currency'
/

alter table mcw_spd add p0397 varchar2(252)
/
comment on column mcw_spd.p0397 is 'Debits, Extended Precision Amount in Reconciliation Currency'
/
alter table mcw_spd add p0398 varchar2(252)
/
comment on column mcw_spd.p0398 is 'Credits, Extended Precision Amount in Reconciliation Currency'
/
alter table mcw_spd add p0399_1 varchar2(1)
/
comment on column mcw_spd.p0399_1 is 'Debit/Credit Indicator, Net Extended Precision in Reconciliation Currency'
/
alter table mcw_spd add p0399_2 number(18)
/
comment on column mcw_spd.p0399_2 is 'Amount, Net Extended Precision in Reconciliation Currency'
/
