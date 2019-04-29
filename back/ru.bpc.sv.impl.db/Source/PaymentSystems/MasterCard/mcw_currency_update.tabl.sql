create table mcw_currency_update (
    id              number(16)
    , network_id    number(4)
    , inst_id       number(4)
    , file_id       number(8)
    , mti           varchar2(4)
    , de024         varchar2(3)
    , de050         varchar2(3)
    , de071         number(7)
    , de093         varchar2(11)
    , de094         varchar2(11)
    , de100         varchar2(11)
)
/
comment on table mcw_currency_update is 'Currency Update/1644 Messages'
/
comment on column mcw_currency_update.id is 'Identifier'
/
comment on column mcw_currency_update.network_id is 'Network identifier'
/
comment on column mcw_currency_update.inst_id is 'Receiver institution'
/
comment on column mcw_currency_update.file_id is 'File identifier'
/
comment on column mcw_currency_update.mti is 'Message Type Identifier'
/
comment on column mcw_currency_update.de024 is 'Function Code'
/
comment on column mcw_currency_update.de050 is 'Currency Code, Reconciliation (Base Currency)'
/
comment on column mcw_currency_update.de071 is 'Message Number'
/
comment on column mcw_currency_update.de093 is 'Transaction Destination Institution ID Code'
/
comment on column mcw_currency_update.de094 is 'Transaction Originator Institution ID Code'
/
comment on column mcw_currency_update.de100 is 'Receiving Institution ID Code'
/
