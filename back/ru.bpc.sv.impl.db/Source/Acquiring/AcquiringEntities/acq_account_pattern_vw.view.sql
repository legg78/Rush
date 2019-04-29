create or replace force view acq_account_pattern_vw as
select id
  , seqnum
  , scheme_id
  , oper_type
  , oper_reason
  , sttl_type
  , terminal_type
  , currency
  , oper_sign
  , merchant_type
  , account_type
  , account_currency
  , priority
from acq_account_pattern
/
