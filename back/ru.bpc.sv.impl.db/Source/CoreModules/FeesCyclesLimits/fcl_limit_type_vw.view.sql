create or replace force view fcl_limit_type_vw as
select id
     , seqnum
     , limit_type
     , entity_type
     , cycle_type
     , is_internal
     , posting_method
     , counter_algorithm
     , limit_usage
  from fcl_limit_type
/
