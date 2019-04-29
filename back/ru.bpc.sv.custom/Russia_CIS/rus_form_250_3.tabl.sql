create global temporary table rus_form_250_3(
    region_code               varchar2(8)
  , subsection                number(1)
  , network_id                number(4)
  , payment_count_all         number(16)
  , payment_amount_all        number(22,4)
  , payment_count_impr        number(16)
  , payment_amount_impr       number(22,4)
  , payment_count_atm         number(16)
  , payment_amount_atm        number(22,4)
  , payment_count_pos         number(16)
  , payment_amount_pos        number(22,4)
  , payment_count_other       number(16)
  , payment_amount_other      number(22,4)
  , cash_count_all            number(16)
  , cash_amount_all           number(22,4)
  , cash_count_atm            number(16)
  , cash_amount_atm           number(22,4)
  , cash_count_foreign_curr   number(16)
  , cash_amount_foreign_curr  number(22,4)
)
on commit preserve rows
/

comment on table rus_form_250_3 is 'Data to create regular report - Forma 250 section 3'
/

comment on column rus_form_250_3.region_code is 'Region code'
/

comment on column rus_form_250_3.subsection is 'Subsection'
/

comment on column rus_form_250_3.network_id is 'Card network identifier'
/

comment on column rus_form_250_3.payment_count_all is 'Count of all payments'
/

comment on column rus_form_250_3.payment_amount_all is 'Amount of all payments'
/

comment on column rus_form_250_3.payment_count_impr is 'Count of payments performed by imprinter'
/

comment on column rus_form_250_3.payment_amount_impr is 'Amount of payments performed by imprinter'
/

comment on column rus_form_250_3.payment_count_atm is 'Count of payments performed by ATM'
/

comment on column rus_form_250_3.payment_amount_atm is 'Amount of payments performed by ATM'
/

comment on column rus_form_250_3.payment_count_pos is 'Count of payments performed by POS, EPOS'
/

comment on column rus_form_250_3.payment_amount_pos is 'Amount of payments performed by POS, EPOS'
/

comment on column rus_form_250_3.payment_count_other is 'Count of payments performed not by ATM, POS, EPOS, imprinter'
/

comment on column rus_form_250_3.payment_amount_other is 'Amount of payments performed not by ATM, POS, EPOS, imprinter'
/

comment on column rus_form_250_3.cash_count_all is 'Count of all cash withdrawal transactions'
/

comment on column rus_form_250_3.cash_amount_all is 'Amount of all cash withdrawal transactions'
/

comment on column rus_form_250_3.cash_count_atm is 'Count of cash withdrawal transactions performed by ATM'
/

comment on column rus_form_250_3.cash_amount_atm is 'Amount of cash withdrawal transactions performed by ATM'
/

comment on column rus_form_250_3.cash_count_foreign_curr is 'Count of cash withdrawal transactions performed in foreign currency'
/

comment on column rus_form_250_3.cash_amount_foreign_curr is 'Amount of cash withdrawal transactions performed in foreign currency'
/

