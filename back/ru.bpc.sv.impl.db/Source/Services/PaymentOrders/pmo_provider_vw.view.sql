create or replace force view pmo_provider_vw as
select
    a.id
  , a.seqnum
  , a.parent_id
  , a.region_code
  , a.provider_number
  , a.logo_path
  , a.inst_id
from
    pmo_provider a
/
