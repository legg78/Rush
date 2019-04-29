create table atm_dispenser_history (
    dispenser_id    number(12)
  , terminal_id     number(8)
  , disp_number     number(4)
  , face_value      number(22, 4)
  , currency        varchar2(3)
  , denomination_id varchar2(1)
  , dispenser_type  varchar2(8)
  , change_date     date
)
/

comment on table atm_dispenser_history is 'ATM dispensers.'
/

comment on column atm_dispenser_history.dispenser_id is 'Dispenser identifier. '
/

comment on column atm_dispenser_history.terminal_id is 'Reference to terminal.'
/

comment on column atm_dispenser_history.disp_number is 'Number of dispenser.'
/

comment on column atm_dispenser_history.face_value is 'Face-value of notes loaded into dispenser.'
/

comment on column atm_dispenser_history.currency is 'Currency of notes loaded into dispenser.'
/

comment on column atm_dispenser_history.denomination_id is 'Denomination type specified by ATM standard.'
/

comment on column atm_dispenser_history.dispenser_type is 'DISPENSER TYPE - cassete, hopper'
/

comment on column atm_dispenser_history.change_date is 'Date when atm_dispenser was changed.'
/
