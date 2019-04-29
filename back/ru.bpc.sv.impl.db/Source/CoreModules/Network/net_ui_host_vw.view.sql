create or replace force view net_ui_host_vw as
select
    n.id
  , n.seqnum
  , n.network_id
  , n.inst_id
  , n.online_standard_id
  , n.offline_standard_id
  , n.participant_type
  , n.description
  , n.online_standard_name
  , n.offline_standard_name
  , n.lang
  , n.status
  , n.inactive_till
from
    net_ui_member_vw n
where(
        n.online_standard_id is not null
    or
        n.offline_standard_id is not null
    or
        exists (select null from net_interface i where i.host_member_id = n.id)
      )
/
