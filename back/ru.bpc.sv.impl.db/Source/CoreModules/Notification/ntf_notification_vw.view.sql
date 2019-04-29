create or replace force view ntf_notification_vw as
select 
    n.id
    , n.seqnum
    , n.event_type
    , n.report_id
    , n.inst_id
from 
    ntf_notification n
/
