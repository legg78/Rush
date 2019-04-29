create table com_mcc (
    id                    number(8)
  , seqnum                number(4)
  , mcc                   varchar2(4)
  , tcc                   varchar2(4)
  , diners_code           varchar2(4)
  , mastercard_cab_type   varchar2(4)
)
/

comment on table com_mcc is 'Card Acceptor Business Codes (MCCs)'
/

comment on column com_mcc.id is 'Record identifier'
/

comment on column com_mcc.seqnum is 'Sequence number. Describe data version.'
/

comment on column com_mcc.mcc is 'Card Acceptor Business Code (MCC)'
/

comment on column com_mcc.tcc is 'Transaction Category Code (TCC)'
/

comment on column com_mcc.diners_code is 'Diners correspondence code'
/

comment on column com_mcc.mastercard_cab_type is 'Card Acceptor Business (CAB) Type'
/
alter table com_mcc add (visa_mcg varchar2(100))
/
comment on column com_mcc.visa_mcg is 'VISA Merchant Category Group (MCG)'
/
alter table com_mcc add (ru_visa_mcg varchar2(100))
/
comment on column com_mcc.ru_visa_mcg is 'VISA Merchant Category Group (MCG) for RU region'
/
