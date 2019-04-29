create or replace force view evt_ui_subscriber_vw as
select 
    a.id
  , a.seqnum
  , a.procedure_name
  , a.event_type
  , a.priority
from evt_subscriber a
/