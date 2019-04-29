create table gui_wizard_step (
    id             number(1)
    , seqnum       number(4)
    , wizard_id    number(4)
    , step_order   number(4)
    , step_source  varchar2(200)
)
/
comment on table gui_wizard_step is 'Step of wizards'
/
comment on column gui_wizard_step.id is 'Record identifier'
/
comment on column gui_wizard_step.seqnum is 'Sequential number of record data version'
/
comment on column gui_wizard_step.wizard_id is 'Identifier of wizard'
/
comment on column gui_wizard_step.step_order is 'Step order'
/
comment on column gui_wizard_step.step_source is 'Java class that implements wizard step'
/
alter table gui_wizard_step modify id number(4)
/