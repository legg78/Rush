create or replace force view acm_filter_component_vw as
select a.id
     , a.seqnum
     , a.filter_id
     , a.name
     , a.value
from acm_filter_component a
/

