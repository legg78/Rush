create table opr_reason (
    id                  number(4)
    , seqnum            number(4)
    , oper_type         varchar2(8)
    , reason_dict       varchar2(8)
)
/
comment on table opr_reason is 'Mapping of operation reason'
/
comment on column opr_reason.id is 'Record identifier'
/
comment on column opr_reason.seqnum is 'Sequential number of record data version'
/
comment on column opr_reason.oper_type is 'Operation type (OPTP dictionary)'
/
comment on column opr_reason.reason_dict is 'Reason dictionary'
/
