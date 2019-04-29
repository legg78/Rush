create table opr_check_group (
    id              number(4)
    , seqnum        number(4)
)
/
comment on table opr_check_group is 'List of groups of checks'
/
comment on column opr_check_group.id is 'Record identifier'
/
comment on column opr_check_group.seqnum is 'Sequential number of record data version'
/
