create table opr_rule_selection (
    id                              number(8)
    , seqnum                        number(4)
    , msg_type                      varchar2(8)
    , proc_stage                    varchar2(8)
    , sttl_type                     varchar2(8)
    , oper_type                     varchar2(8)
    , oper_reason                   varchar2(8)
    , is_reversal                   varchar2(8)
    , iss_inst_id                   varchar2(8)
    , acq_inst_id                   varchar2(8)
    , terminal_type                 varchar2(8)
    , oper_currency                 varchar2(3)
    , account_currency              varchar2(3)
    , sttl_currency                 varchar2(3)
    , mod_id                        number(4)
    , rule_set_id                   number(4)
    , exec_order                    number(4)
)
/
comment on table opr_rule_selection is 'Parameters for rules selection'
/
comment on column opr_rule_selection.id is 'Identifier'
/
comment on column opr_rule_selection.seqnum is 'Sequential number of record data version'
/
comment on column opr_rule_selection.msg_type is 'Message type (MGTP key)'
/
comment on column opr_rule_selection.proc_stage is 'Processing stage (PSTG dictionary)'
/
comment on column opr_rule_selection.sttl_type is 'Settlement type (STTT key)'
/
comment on column opr_rule_selection.oper_type is 'Operation type (OPTP key)'
/
comment on column opr_rule_selection.oper_reason is 'Operation purpose'
/
comment on column opr_rule_selection.is_reversal is 'Reversal indicator'
/
comment on column opr_rule_selection.iss_inst_id is 'Issuer institution identifier'
/
comment on column opr_rule_selection.acq_inst_id is 'Acquirer institution identifier'
/
comment on column opr_rule_selection.terminal_type is 'Terminal type (TRMT key)'
/
comment on column opr_rule_selection.oper_currency is 'Operation currency (ISO numeric)'
/
comment on column opr_rule_selection.account_currency is 'Account currency (ISO numeric)'
/
comment on column opr_rule_selection.sttl_currency is 'Settlement currency (ISO numeric)'
/
comment on column opr_rule_selection.mod_id is 'Modifier identifier'
/
comment on column opr_rule_selection.rule_set_id is 'Rule set identifier'
/
comment on column opr_rule_selection.exec_order is 'Execution order'
/
