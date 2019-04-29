create or replace force view fcl_limit_vw as
select id
     , seqnum
     , limit_type
     , cycle_id
     , count_limit
     , sum_limit
     , currency
     , posting_method
     , is_custom
     , inst_id
     , limit_base
     , limit_rate
     , check_type
     , counter_algorithm
     , count_max_bound
     , sum_max_bound
  from fcl_limit
/
