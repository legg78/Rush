create or replace force view rpt_tag_vw as
select
    a.id
  , a.seqnum
  , a.inst_id
from
    rpt_tag a
/
