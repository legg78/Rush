create or replace force view rpt_banner_vw as
select 
    id
  , seqnum
  , status
  , filename
  , inst_id
from rpt_banner
/