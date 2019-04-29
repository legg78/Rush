create table din_recap(
    id                           number(12)
  , file_id                      number(16)
  , record_number                number(8)
  , inst_id                      number(4)
  , sending_institution          varchar2(2)
  , recap_number                 number(3)
  , receiving_institution        varchar2(2)
  , currency                     varchar2(3)
  , recap_date                   date
  , credit_count                 number(8)
  , credit_amount                number(22, 4)
  , debit_count                  number(8)
  , debit_amount                 number(22, 4)
  , program_transaction_amount   number(22, 4)
  , net_amount                   number(22, 4)
  , alt_currency                 varchar2(3)
  , alt_gross_amount             number(22, 4)
  , alt_net_amount               number(22, 4)
  , newrecap_number              number(3)
  , proc_date                    date
  , sttl_date                    date
  , is_rejected                  number(1)
)
/

comment on table din_recap is 'Diners Club recaps. There are character codes with field names from the specification in comments (in square brackets)'
/
comment on column din_recap.id is 'Primary key'
/
comment on column din_recap.file_id is 'Reference to a clearing file (primary key of the table DIN_FILE and PRC_SESSION_FILE)'
/
comment on column din_recap.record_number is 'Record number in a clearing file'
/
comment on column din_recap.inst_id is 'Institution ID that generates (ACQ) an outgoing message or receives (ISS) an incoming message'
/
comment on column din_recap.sending_institution is 'Sending institution identification code [SFTER]. For outgoing clearing it is associated with the field INST_ID (ACQ institution)'
/
comment on column din_recap.recap_number is 'Recap number (0..999) [RCPNO]'
/
comment on column din_recap.receiving_institution is 'Receiving institution identification code [DFTER]. For incoming clearing it is associated with the field INST_ID (ISS institution)'
/
comment on column din_recap.currency is 'Recap currency ISO code (Currency key) [CURKY]'
/
comment on column din_recap.recap_date is 'Recap date (May not be greater than or more than 60 days prior to the current day''s date) [RCPDT]'
/
comment on column din_recap.credit_count is 'Number of credit items in a recap [RCNCR]'
/
comment on column din_recap.credit_amount is 'Amount of credit items in a recap [RCACR]'
/
comment on column din_recap.debit_count is 'Number of debit items in a recap [RCNDR]'
/
comment on column din_recap.debit_amount is 'Amount of debit items in a recap [RCADR]'
/
comment on column din_recap.program_transaction_amount is 'Program transaction amount [DRATE]. It represents percent that is used for calculating Recap message net amount (RNAMT)'
/
comment on column din_recap.net_amount is 'Recap net amount [RNAMT], RNAMT = (RCADR – RCACR) * (1 – DRATE/100)'
/
comment on column din_recap.alt_currency is 'Alternate settlement currency ISO code (Alternate settlement currency key) [ACRKY]'
/
comment on column din_recap.alt_gross_amount is 'Alternate settlement gross amount [AGAMT], AGAMT = RCADR – RCACR; the absolute value of the amount of debits (RCADR) minus the amount of credits (RCACR) in the alternate currency (ACRKY)'
/
comment on column din_recap.alt_net_amount is 'The recap messages net amount (RNAMT) denominated in the alternate currency (ACRKY) (Alternate settlement net amount) [ACAMT]'
/
comment on column din_recap.newrecap_number is 'New recap number [NEWRN] (it is used on the receiver''s end for validation)'
/
comment on column din_recap.proc_date is 'DCISC processing date [BGAMT, first 6 digits]'
/
comment on column din_recap.sttl_date is 'DCISC settlement date [BGAMT, last 6 digits]'
/
comment on column din_recap.is_rejected is 'Reject flag (reserved)'
/
alter table din_recap drop column newrecap_number
/
alter table din_recap add (new_recap_number number(3))
/
comment on column din_recap.new_recap_number is 'New recap number [NEWRN] (it is used on the receiver''s end for validation)'
/
