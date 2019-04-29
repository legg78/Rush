create or replace force view cmn_ui_resp_code_vw as
select
    a.id
  , a.seqnum
  , a.standard_id
  , a.resp_code
  , a.device_code_in
  , a.device_code_out
  , a.resp_reason
from
    cmn_resp_code a
/
