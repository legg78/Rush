create or replace force view fcl_ui_limit_type_vw as
select a.id
     , a.seqnum
     , a.limit_type
     , a.entity_type
     , a.cycle_type
     , a.is_internal
     , a.posting_method
     , a.counter_algorithm
     , a.limit_usage
  from fcl_limit_type a
/
