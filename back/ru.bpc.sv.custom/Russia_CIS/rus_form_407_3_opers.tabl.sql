create table rus_form_407_3_opers(
    account_id             number(16)
  , inst_id                number(4)
  , oper_id                number(16)
  , oper_date              date
  , original_id            number(16)
  , is_reversal            number(1)
  , amount                 number(22,4)
  , currency               varchar2(3)
  , sttl_type              varchar2(8)
  , country                varchar2(3)
)
/

comment on table rus_form_407_3_opers is 'Data of operation to create regular report - Forma 407 part 3'
/
comment on column rus_form_407_3_opers.account_id is 'Account ID'
/
comment on column rus_form_407_3_opers.inst_id is 'Institution ID'
/
comment on column rus_form_407_3_opers.oper_id is 'Operation ID'
/
comment on column rus_form_407_3_opers.oper_date is 'Operation date'
/
comment on column rus_form_407_3_opers.original_id is 'Reference to original operation in case of reversal'
/
comment on column rus_form_407_3_opers.is_reversal is 'Reversal indicator'
/
comment on column rus_form_407_3_opers.amount is 'Amount'
/
comment on column rus_form_407_3_opers.currency is 'Currency'
/
comment on column rus_form_407_3_opers.sttl_type is 'Settlement type'
/
comment on column rus_form_407_3_opers.country is 'Country code'
/
alter table rus_form_407_3_opers add (card_network_id number(4))
/
comment on column rus_form_407_3_opers.card_network_id is 'Card network identifier'
/
