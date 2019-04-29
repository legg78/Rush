create or replace force view aut_ui_resp_code_vw as
select
    id
  , seqnum
  , resp_code
  , is_reversal
  , proc_type
  , auth_status
  , proc_mode
  , status_reason
  , oper_type
  , msg_type
  , priority
  , is_completed
  , sttl_type
  , oper_reason
from
    aut_resp_code
/

