create or replace force view fcl_fee_vw as
select a.id
     , a.seqnum
     , a.fee_type
     , a.currency
     , a.fee_rate_calc
     , a.fee_base_calc
     , a.limit_id
     , a.cycle_id
     , a.inst_id
  from fcl_fee a
/