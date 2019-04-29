create or replace force view cmn_api_resp_code_out_vw as
select
    a.id
  , a.seqnum
  , a.standard_id
  , a.resp_code
  , a.device_code_out
  , a.resp_reason
from
    cmn_resp_code a
where
    device_code_out is not null
/
