create or replace force view ntf_ui_template_vw as
select 
    n.id
    , n.seqnum
    , n.notif_id
    , n.channel_id
    , n.lang
    , n.report_template_id
from 
    ntf_template n
/
