create table rus_form_259_2_report(
    inst_id                 number(4)
  , report_date             date
  , pmode                   number(3)
  , customer_type           varchar2(8)
  , contract_type           varchar2(8)
  , legal_foreign_count     number(16)
  , legal_foreign_amount    number(22,4)
  , person_foreign_count    number(16)
  , person_foreign_amount   number(22,4)
  , legal_domestic_count    number(16)
  , legal_domestic_amount   number(22,4)
  , person_domestic_count   number(16)
  , person_domestic_amount  number(22,4)
)
/

comment on table rus_form_259_2_report is 'Data to create regular report - Form 259 part 2'
/
comment on column rus_form_259_2_report.inst_id is 'Institution identifier'
/
comment on column rus_form_259_2_report.report_date is 'Fisrt day of quarter'
/
comment on column rus_form_259_2_report.pmode is 'Mode'
/
comment on column rus_form_259_2_report.customer_type is 'Customer type (Person, Organization, Instant Issue)'
/
comment on column rus_form_259_2_report.contract_type is 'Contract type (Prepaid)'
/
comment on column rus_form_259_2_report.legal_foreign_count is 'Number of transfers of electronic funds to legal in foreign currency'
/
comment on column rus_form_259_2_report.legal_foreign_amount is 'Amount of transfers of electronic funds to legal in foreign currency'
/
comment on column rus_form_259_2_report.person_foreign_count is 'Number of transfers of electronic funds to person in foreign currency'
/
comment on column rus_form_259_2_report.person_foreign_amount is 'Amount of transfers of electronic funds to person in foreign currency'
/
comment on column rus_form_259_2_report.legal_domestic_count is 'Number of transfers of electronic funds to legal in domestic currency'
/
comment on column rus_form_259_2_report.legal_domestic_amount is 'Amount of transfers of electronic funds to legal in domestic currency'
/
comment on column rus_form_259_2_report.person_domestic_count is 'Number of transfers of electronic funds to person in domestic currency'
/
comment on column rus_form_259_2_report.person_domestic_amount is 'Amount of transfers of electronic funds to person in domestic currency'
/
alter table rus_form_259_2_report add (network_id number(4))
/
comment on column rus_form_259_2_report.network_id is 'Card network identifier'
/
