create table opr_check_selection (
    id                  number(4)
    , seqnum            number(4)
    , oper_type         varchar2(8)
    , msg_type          varchar2(8)
    , party_type        varchar2(8)
    , inst_id           varchar2(8)
    , network_id        varchar2(8)
    , check_group_id    number(4)
    , exec_order        number(4)
)
/
comment on table opr_check_selection is 'Selection of check groups according to message parameters'
/
comment on column opr_check_selection.id is 'Record identifier'
/
comment on column opr_check_selection.seqnum is 'Sequential number of record data version'
/
comment on column opr_check_selection.oper_type is 'Operation type'
/
comment on column opr_check_selection.msg_type is 'Message type'
/
comment on column opr_check_selection.party_type is 'Participating party type'
/
comment on column opr_check_selection.inst_id is 'Institution identifier'
/
comment on column opr_check_selection.network_id is 'Network identifier'
/
comment on column opr_check_selection.check_group_id is 'Check group identifier'
/
comment on column opr_check_selection.exec_order is 'Check order'
/
