create table rus_form_259_1_report(
    inst_id                 number(4)
  , report_date             date
  , pmode                   number(3)
  , customer_type           varchar2(8)
  , contract_type           varchar2(8)
  , card_count              number(16)
  , active_card_count       number(16)
  , balance_amount          number(22,4)
  , credit_count            number(16)
  , credit_amount           number(22,4)
  , credit_mobile_count     number(16)
  , credit_mobile_amount    number(22,4)
  , debit_count             number(16)
  , debit_amount            number(22,4)
  , debit_bank_count        number(16)
  , debit_bank_amount       number(22,4)
  , debit_bank_other_count  number(16)
  , debit_bank_other_amount number(22,4)
  , debit_cash_count        number(16)
  , debit_cash_amount       number(22,4)
)
/

comment on table rus_form_259_1_report is 'Data to create regular report - Form 259 part 1'
/
comment on column rus_form_259_1_report.inst_id is 'Institution identifier'
/
comment on column rus_form_259_1_report.report_date is 'Fisrt day of quarter'
/
comment on column rus_form_259_1_report.pmode is 'Mode'
/
comment on column rus_form_259_1_report.customer_type is 'Customer type (Person, Organization, Instant Issue)'
/
comment on column rus_form_259_1_report.contract_type is 'Contract type (Prepaid)'
/
comment on column rus_form_259_1_report.card_count is 'Total card count'
/
comment on column rus_form_259_1_report.active_card_count is 'Count of card which has activity from start of year'
/
comment on column rus_form_259_1_report.balance_amount is 'Balance amount by the reporting date'
/
comment on column rus_form_259_1_report.credit_count is 'Count of transactions to increase the balance of electronic funds'
/
comment on column rus_form_259_1_report.credit_amount is 'Amount of transactions to increase the balance of electronic funds'
/
comment on column rus_form_259_1_report.credit_mobile_count is 'Count of transactions to increase the balance of electronic funds (clients of telecom operators)'
/
comment on column rus_form_259_1_report.credit_mobile_amount is 'Amount of transactions to increase the balance of electronic funds (clients of telecom operators)'
/
comment on column rus_form_259_1_report.debit_count is 'Count of transactions to reduce the balance of electronic funds'
/
comment on column rus_form_259_1_report.debit_amount is 'Amount of transactions to reduce the balance of electronic funds'
/
comment on column rus_form_259_1_report.debit_bank_count is 'Count of transfer transactions to a bank account'
/
comment on column rus_form_259_1_report.debit_bank_amount is 'Amount of transfer transactions to a bank account'
/
comment on column rus_form_259_1_report.debit_bank_other_count is 'Count of transfer transactions to a bank account (legal entity that is not a credit institution)'
/
comment on column rus_form_259_1_report.debit_bank_other_amount is 'Amount of transfer transactions to a bank account (legal entity that is not a credit institution)'
/
comment on column rus_form_259_1_report.debit_cash_count is 'Count of transfer transactions to cash'
/
comment on column rus_form_259_1_report.debit_cash_amount is 'Amount of transfer transactions to cash'
/
alter table rus_form_259_1_report add (network_id number(4))
/
comment on column rus_form_259_1_report.network_id is 'Card network identifier'
/
