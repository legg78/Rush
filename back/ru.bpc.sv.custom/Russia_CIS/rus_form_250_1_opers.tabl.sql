create global temporary table rus_form_250_1_opers(
    oper_id                number(16)
  , oper_type              varchar2(20 char)
  , mcc                    varchar2(4 char)
  , card_id                number(12)
  , card_network_id        number(4)
  , merchant_country       varchar2(3 char)
  , is_reversal            number(1)
  , original_id            number(16)
  , balance_type           varchar2(20 char)
  , currency               varchar2(3 char)
  , entry_id               number(16)
  , entry_amount           number(22,4)
  , count_multiplier       number(1)
  , is_internet            number(1)
  , is_mobile              number(1)
)
on commit delete rows
/

comment on table rus_form_250_1_opers is 'Data of operation to create regular report - Forma 250 part 1'
/
comment on column rus_form_250_1_opers.oper_id is 'Operation ID'
/
comment on column rus_form_250_1_opers.oper_type is 'Operation type (Cashout, Purchases, Customs, Others)'
/
comment on column rus_form_250_1_opers.mcc is 'Card Acceptor Business Code (MCC)'
/
comment on column rus_form_250_1_opers.card_id is 'Card identifier'
/
comment on column rus_form_250_1_opers.card_network_id is 'Card network identifier'
/
comment on column rus_form_250_1_opers.merchant_country is 'Merchant country'
/
comment on column rus_form_250_1_opers.is_reversal is 'Reversal indicator'
/
comment on column rus_form_250_1_opers.original_id is 'Reference to original operation in case of reversal'
/
comment on column rus_form_250_1_opers.balance_type is 'Balance type (Ledger, Overdraft)'
/
comment on column rus_form_250_1_opers.currency is 'Currency'
/
comment on column rus_form_250_1_opers.entry_id is 'Entry identifier'
/
comment on column rus_form_250_1_opers.entry_amount is 'Entry amount'
/
comment on column rus_form_250_1_opers.count_multiplier is 'Multiplier for count of operations'
/
comment on column rus_form_250_1_opers.is_internet is 'Operation in internet indicator'
/
comment on column rus_form_250_1_opers.is_mobile is 'Operation on mobile indicator'
/
