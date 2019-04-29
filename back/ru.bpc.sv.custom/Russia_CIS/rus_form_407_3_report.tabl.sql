create table rus_form_407_3_report(
    inst_id                 number(4)
  , report_date             date
  , transaction_direction   varchar2(200)
  , counterparty            varchar2(200)
  , country                 varchar2(3)
  , currency                varchar2(3)
  , oper_count              number(16)
  , oper_amount             number(22,4)
)
/

comment on table rus_form_407_3_report is 'Data to create regular report - Form 407 part 3'
/
comment on column rus_form_407_3_report.inst_id is 'Institution identifier'
/
comment on column rus_form_407_3_report.report_date is 'Fisrt day of quarter'
/
comment on column rus_form_407_3_report.transaction_direction is 'Transaction direction'
/
comment on column rus_form_407_3_report.counterparty is 'Counterparty'
/
comment on column rus_form_407_3_report.country is 'Country'
/
comment on column rus_form_407_3_report.currency is 'Currency'
/
comment on column rus_form_407_3_report.oper_count is 'Number of transfers of electronic funds'
/
comment on column rus_form_407_3_report.oper_amount is 'Amount of transfers of electronic funds'
/
alter table rus_form_407_3_report add (network_id number(4))
/
comment on column rus_form_407_3_report.network_id is 'Card network identifier'
/
