create or replace force view crd_event_bunch_type_vw as
select id
     , seqnum
     , event_type
     , balance_type
     , bunch_type_id
     , inst_id
     , add_bunch_type_id
  from crd_event_bunch_type
/
