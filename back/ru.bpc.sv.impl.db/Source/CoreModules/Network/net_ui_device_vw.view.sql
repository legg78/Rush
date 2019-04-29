create or replace force view net_ui_device_vw as
select
    a.device_id
    , a.host_member_id
    , b.is_signed_on
    , c.communication_plugin
    , c.standard_id
    , c.inst_id
    , c.caption
    , c.description
    , c.lang
    , c.seqnum      
	, b.is_connected
from
    net_device a
    , net_device_dynamic b
    , cmn_ui_device_vw c
where
    a.device_id = b.device_id(+)
    and a.device_id = c.id
/