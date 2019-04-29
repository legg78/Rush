create or replace force view cmn_api_resp_code_in_vw as
select
    a.id
  , a.seqnum
  , a.standard_id
  , a.resp_code
  , a.device_code_in
  , a.resp_reason
from
    cmn_resp_code a
where
    a.device_code_in is not null
/
