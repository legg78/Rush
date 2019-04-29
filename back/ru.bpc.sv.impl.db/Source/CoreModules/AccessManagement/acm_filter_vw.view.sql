create or replace force view acm_filter_vw as
select a.id
     , a.seqnum
     , a.section_id
     , a.inst_id
     , a.user_id
     , a.display_order
from acm_filter a
/
