create or replace force view fcl_fee_tier_vw as
select a.id
     , a.seqnum
     , a.fee_id
     , a.fixed_rate
     , a.percent_rate
     , a.min_value
     , a.max_value
     , a.length_type
     , a.sum_threshold
     , a.count_threshold
     , a.length_type_algorithm
from fcl_fee_tier a
/
