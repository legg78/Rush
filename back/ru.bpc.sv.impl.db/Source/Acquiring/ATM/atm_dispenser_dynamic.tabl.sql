create table atm_dispenser_dynamic (
    id              number(12)
  , note_loaded     number(4)
  , note_dispensed  number(4)
  , note_remained   number(4)
  , note_rejected   number(4)
  , cassette_status varchar2(8)
)
/


comment on table atm_dispenser_dynamic is 'ATM dispensers dynamic parameters.'
/

comment on column atm_dispenser_dynamic.id is 'Dispenser identifier. Primary key.'
/

comment on column atm_dispenser_dynamic.note_loaded is 'Count of loaded notes into dispenser.'
/

comment on column atm_dispenser_dynamic.note_dispensed is 'Count of dispensed notes.'
/

comment on column atm_dispenser_dynamic.note_remained is 'Count of remained notes.'
/

comment on column atm_dispenser_dynamic.note_rejected is 'Count of rejected notes into reject dispenser.'
/

comment on column atm_dispenser_dynamic.cassette_status is 'Cassette Status - Disabled, Active, NotesLow, OutOfNotes, Error'
/
