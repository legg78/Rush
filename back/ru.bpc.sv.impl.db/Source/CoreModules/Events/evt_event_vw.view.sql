create or replace force view evt_event_vw as
select 
     id
   , seqnum
   , event_type
   , scale_id
   , inst_id
   , is_cached
from evt_event c
/