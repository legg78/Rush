create or replace force view evt_status_map_vw as
select id
     , seqnum
     , event_type
     , initiator
     , initial_status
     , result_status
     , priority
     , inst_id
  from evt_status_map
/
