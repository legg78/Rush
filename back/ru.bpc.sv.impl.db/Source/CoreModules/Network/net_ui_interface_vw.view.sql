create or replace force view net_ui_interface_vw as
select n.id
     , n.seqnum
     , n.host_member_id
     , n.consumer_member_id
     , n.msp_member_id
  from net_interface n
/
