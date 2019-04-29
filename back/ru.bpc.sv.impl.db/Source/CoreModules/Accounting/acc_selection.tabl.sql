create table acc_selection (
    id              number(4)
    , seqnum          number(4)
)
/
comment on table acc_selection is 'Account selection algorithms'
/
comment on column acc_selection.id is 'Identifier'
/
comment on column acc_selection.seqnum is 'Sequential number of data version'
/
alter table acc_selection add (check_aval_balance  number(1))
/
comment on column acc_selection.check_aval_balance is 'This is flag which indicate that need to compare operation amount with available balance amount. 1 - need to check, 0 - do not check'
/
