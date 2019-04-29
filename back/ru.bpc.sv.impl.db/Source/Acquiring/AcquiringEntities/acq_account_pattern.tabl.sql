create table acq_account_pattern (
    id               number(12)
  , seqnum           number(4)
  , scheme_id        number(4)
  , oper_type        varchar2(8)
  , oper_reason      varchar2(8)
  , sttl_type        varchar2(8)
  , terminal_type    varchar2(8)
  , currency         varchar2(3)
  , oper_sign        number(1)
  , merchant_type    varchar2(8)
  , account_type     varchar2(8)
  , account_currency varchar2(3)
  , priority         number(4)
    )
/

comment on table acq_account_pattern is 'Acquiring billing scheme. Describing billing level for operations.'
/

comment on column acq_account_pattern.id is 'Primary key.'
/
comment on column acq_account_pattern.seqnum is 'Sequence number. Describe data version.'
/
comment on column acq_account_pattern.scheme_id is 'Accounting scheme identifier.'
/
comment on column acq_account_pattern.oper_type is 'Operation type (cash, sale, payment etc.)'
/
comment on column acq_account_pattern.oper_reason is 'Operation reason (fee types, rate types, payment types etc).'
/
comment on column acq_account_pattern.sttl_type is 'Settlement type.'
/
comment on column acq_account_pattern.terminal_type is 'Terminal type.'
/
comment on column acq_account_pattern.currency is 'Operation currency. Also define currency of account for posting.'
/
comment on column acq_account_pattern.oper_sign is 'Sign of operation (debit/credit).'
/
comment on column acq_account_pattern.merchant_type is 'Merchant type (Billing level).'
/
comment on column acq_account_pattern.account_type is 'Account type for posting.'
/
comment on column acq_account_pattern.account_currency is 'Account currency.'
/
comment on column acq_account_pattern.priority is 'Account type priority.'
/
