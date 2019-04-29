create table acc_selection_step (
    id              number(4)
    , selection_id  number(4)
    , exec_order    number(4)
    , step          varchar2(8)
    , seqnum        number(4)
)
/
comment on table acc_selection_step is 'Steps which agorithm consists of'
/
comment on column acc_selection_step.id is 'Identifier'
/
comment on column acc_selection_step.selection_id is 'Selection algorithm identifier'
/
comment on column acc_selection_step.exec_order is 'Step order'
/
comment on column acc_selection_step.step is 'Step'
/
comment on column acc_selection_step.seqnum is 'Sequential number of data version'
/
