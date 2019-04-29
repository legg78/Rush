create table gui_wizard (
    id        number(4)
    , seqnum  number(4)
)
/

comment on table gui_wizard is 'Wizard of graphical user interface'
/
comment on column gui_wizard.id is 'Record identifier'
/
comment on column gui_wizard.seqnum is 'Sequential number of record data version'
/

alter table gui_wizard add maker_privilege_id number(8)
/
alter table gui_wizard add checker_privilege_id number(8)
/

comment on column gui_wizard.maker_privilege_id   is 'ID of maker privilege (link to acm_privilege.id)'
/
comment on column gui_wizard.checker_privilege_id is 'ID of checker privilege (link to acm_privilege.id)'
/
