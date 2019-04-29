create table dsp_scale_selection(
    id                  number(4) not null
  , seqnum              number(4)
  , scale_type          varchar2(8)
  , mod_id              number(4)
)
/
comment on table dsp_scale_selection is 'Dispute scale type selection'
/
comment on column dsp_scale_selection.id is 'Primary key'
/
comment on column dsp_scale_selection.seqnum is 'Sequential number'
/
comment on column dsp_scale_selection.scale_type is 'Scale type (dictionary SCTP)'
/
comment on column dsp_scale_selection.mod_id is 'Modifier identifier (PK of table RUL_MOD)'
/
alter table dsp_scale_selection add (init_rule_id number(4))
/
comment on column dsp_scale_selection.init_rule_id is 'Rule for initializing parameters of selected scale type. These modifiers are used for checking dispute modifiers of selected scale type.'
/
