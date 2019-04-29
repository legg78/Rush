create table ntb_note (
    id              number(16)
    , entity_type   varchar2(8)
    , object_id     number(16)
    , note_type     varchar2(8)
    , reg_date      timestamp
    , user_id       varchar2(30)
)
/
comment on table ntb_note is 'Objects notes'
/
comment on column ntb_note.id is 'Identifier'
/
comment on column ntb_note.entity_type is 'Type of entity which note relates to'
/
comment on column ntb_note.object_id is 'Object identifier which note relates to'
/
comment on column ntb_note.note_type is 'Note type'
/
comment on column ntb_note.reg_date is 'Note registration date'
/
comment on column ntb_note.user_id is 'Author'
/
alter table ntb_note add start_date date
/
comment on column ntb_note.start_date is 'Start date of the note validity'
/
alter table ntb_note add end_date date
/
comment on column ntb_note.end_date is 'End date of the note validity'
/
