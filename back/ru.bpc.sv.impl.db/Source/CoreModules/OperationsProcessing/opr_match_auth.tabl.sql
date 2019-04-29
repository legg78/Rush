create table opr_match_auth (
    id                         number(16)
  , row_id                     varchar2(200)
  , is_reversal                number(1)
  , oper_type                  varchar2(8)
  , msg_type                   varchar2(8)
  , status                     varchar2(8)
  , acq_inst_bin               varchar2(12)
  , forw_inst_bin              varchar2(12)
  , merchant_number            varchar2(15)
  , terminal_number            varchar2(16)
  , mcc                        varchar2(4)
  , originator_refnum          varchar2(36)
  , oper_amount                number(22, 4)
  , oper_currency              varchar2(3)
  , oper_date                  date
  , clearing_sequence_num      number(2)
  , clearing_sequence_count    number(2)
  , sttl_date                  date
  , total_amount               number(22, 4)
  , split_hash                 number(4)
  , client_id_type             varchar2(8)
  , auth_code                  varchar2(6)
  , card_id                    number(12)
  , account_id                 number(12)
  , object_id                  number(16)
  , is_credit_operation        number(1)
)
/
comment on table opr_match_auth is 'Table with temporary storage data for authorization matching (without any indexes for best performance)'
/
comment on column opr_match_auth.id                      is 'Operation identifier'
/
comment on column opr_match_auth.row_id                  is 'Row id for matching'
/
comment on column opr_match_auth.is_reversal             is 'Reversal indicator'
/
comment on column opr_match_auth.oper_type               is 'Operation type (OPTP dictionary)'
/
comment on column opr_match_auth.msg_type                is 'Message type (MSGT dictionary)'
/
comment on column opr_match_auth.status                  is 'Operation status (OPST dictionary)'
/
comment on column opr_match_auth.acq_inst_bin            is 'Acquirer institution BIN'
/
comment on column opr_match_auth.forw_inst_bin           is 'Forwarding institution BIN'
/
comment on column opr_match_auth.merchant_number         is 'ISO Merchant number'
/
comment on column opr_match_auth.terminal_number         is 'ISO Terminal number'
/
comment on column opr_match_auth.mcc                     is 'Merchant category code (MCC)'
/
comment on column opr_match_auth.originator_refnum       is 'Reference number generated by originator of operation'
/
comment on column opr_match_auth.oper_amount             is 'Operation amount in operation currency'
/
comment on column opr_match_auth.oper_currency           is 'Operation currency'
/
comment on column opr_match_auth.oper_date               is 'Operation date (local device date)'
/
comment on column opr_match_auth.clearing_sequence_num   is 'Multiple Clearing Sequence Number'
/
comment on column opr_match_auth.clearing_sequence_count is 'Multiple Clearing Sequence Count'
/
comment on column opr_match_auth.sttl_date               is 'Settlement date'
/
comment on column opr_match_auth.total_amount            is 'Total amount of Incremental Preauthorization Transactions'
/
comment on column opr_match_auth.split_hash              is 'Hash value to split further processing'
/
comment on column opr_match_auth.client_id_type          is 'Type of client identification'
/
comment on column opr_match_auth.auth_code               is 'Authorization code'
/
comment on column opr_match_auth.card_id                 is 'Card identifier'
/
comment on column opr_match_auth.account_id              is 'Account identifier involved in operation'
/
comment on column opr_match_auth.object_id               is 'Object identifier involved in operation (card or account)'
/
comment on column opr_match_auth.is_credit_operation     is '1 - for credit operation, 0 - for other operation'
/
alter table opr_match_auth drop column client_id_type
/
alter table opr_match_auth drop column object_id
/
alter table opr_match_auth drop column account_id
/