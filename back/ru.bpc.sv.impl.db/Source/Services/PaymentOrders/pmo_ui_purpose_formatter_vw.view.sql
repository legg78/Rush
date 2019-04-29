create or replace force view pmo_ui_purpose_formatter_vw as
select 
    n.id
    , n.seqnum
    , n.purpose_id
    , n.standard_id
    , n.version_id
    , n.paym_aggr_msg_type
    , n.formatter
from 
    pmo_purpose_formatter n
/
