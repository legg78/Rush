create or replace force view fcl_ui_fee_tier_vw as
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
     , c.need_length_type
  from fcl_fee_tier a
     , fcl_fee b
     , fcl_fee_type c
 where b.id       = a.fee_id
   and c.fee_type = b.fee_type
/
