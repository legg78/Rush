create table atm_dispenser (
    id              number(12)
  , terminal_id     number(8)
  , disp_number     number(4)
  , face_value      number(22, 4)
  , currency        varchar2(3)
  , denomination_id varchar2(1)
  , dispenser_type  varchar2(8)
)
/

comment on table atm_dispenser is 'ATM dispensers.'
/

comment on column atm_dispenser.id is 'Dispenser identifier. Primary key.'
/

comment on column atm_dispenser.terminal_id is 'Reference to terminal.'
/

comment on column atm_dispenser.disp_number is 'Number of dispenser.'
/

comment on column atm_dispenser.face_value is 'Face-value of notes loaded into dispenser.'
/

comment on column atm_dispenser.currency is 'Currency of notes loaded into dispenser.'
/

comment on column atm_dispenser.denomination_id is 'Denomination type specified by ATM standard.'
/

comment on column atm_dispenser.dispenser_type is 'DISPENSER TYPE - cassete, hopper'
/