create or replace force view net_device_vw as
select device_id
     , host_member_id
  from net_device
/
