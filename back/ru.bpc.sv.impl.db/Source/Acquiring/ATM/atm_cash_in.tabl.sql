create table atm_cash_in(
    id                number(12)
  , terminal_id       number(8)
  , face_value        number(22 ,4)
  , currency          varchar2(3)
  , denomination_code varchar2(3)
  , is_active         number(1)
)
/

comment on table atm_cash_in is 'Currency denominations accepting by Cash-In device.'
/

comment on column atm_cash_in.id is 'Primary key'
/
comment on column atm_cash_in.terminal_id is 'Reference to terminal'
/
comment on column atm_cash_in.face_value is 'Banknote face-value'
/
comment on column atm_cash_in.currency is 'Banknote currency'
/
comment on column atm_cash_in.denomination_code is 'Code of denomination in Cash-In device'
/
comment on column atm_cash_in.is_active is 'Denomination status (1 - Active, 0 - Inactive)'
/
