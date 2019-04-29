create or replace force view cmn_api_device_standard_vw as
select
    a.id device_id
  , a.seqnum
  , a.communication_plugin
  , b.application_plugin
  , b.id standard_id
from
    cmn_device a
  , cmn_standard b
  , cmn_standard_object os
where
    a.id = os.object_id
and
    os.entity_type = 'ENTTCMDV'
and
    os.standard_type in ('STDT0001', 'STDT0002')
and
    os.standard_id = b.id
/
