create table opr_check (
    id                  number(4)
    , seqnum            number(4)
    , check_group_id    number(4)
    , check_type        varchar2(8)
    , exec_order        number(4)
)
/
comment on table opr_check is 'List of checks to be performed within group'
/
comment on column opr_check.id is 'Record identifier'
/
comment on column opr_check.seqnum is 'Sequential number of record data version'
/
comment on column opr_check.check_group_id is 'Identifier of group of checks'
/
comment on column opr_check.check_type is 'Check type'
/
comment on column opr_check.exec_order is 'Check order'
/