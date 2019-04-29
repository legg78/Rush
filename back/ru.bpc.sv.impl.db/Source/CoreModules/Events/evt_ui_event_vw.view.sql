create or replace force view evt_ui_event_vw as
select 
     id
   , seqnum
   , event_type
   , scale_id
   , inst_id
from evt_event c
/