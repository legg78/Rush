create table rus_form_259_1_opers(
    account_id             number(16)
  , inst_id                number(4)
  , oper_id                number(16)
  , oper_date              date
  , original_id            number(16)
  , is_reversal            number(1)
  , customer_type          varchar2(8)
  , contract_type          varchar2(8)
  , amount                 number(22,4)
  , currency               varchar2(3)
  , oper_type              varchar2(20)
  , account_dst            varchar2(20)
)
/

comment on table rus_form_259_1_opers is 'Data of operation to create regular report - Forma 259 part 1'
/
comment on column rus_form_259_1_opers.account_id is 'Account ID'
/
comment on column rus_form_259_1_opers.inst_id is 'Institution ID'
/
comment on column rus_form_259_1_opers.oper_id is 'Operation ID'
/
comment on column rus_form_259_1_opers.oper_date is 'Operation date'
/
comment on column rus_form_259_1_opers.original_id is 'Reference to original operation in case of reversal'
/
comment on column rus_form_259_1_opers.is_reversal is 'Reversal indicator'
/
comment on column rus_form_259_1_opers.customer_type is 'Customer type'
/
comment on column rus_form_259_1_opers.customer_type is 'Contract type'
/
comment on column rus_form_259_1_opers.amount is 'Entry amount'
/
comment on column rus_form_259_1_opers.currency is 'Currency'
/
comment on column rus_form_259_1_opers.oper_type is 'Operation type (increase_amount, decrease_amount, cash_out, undefined)'
/
comment on column rus_form_259_1_opers.account_dst is 'Destination of operation'
/
alter table rus_form_259_1_opers add (card_network_id number(4))
/
comment on column rus_form_259_1_opers.card_network_id is 'Card network identifier'
/
