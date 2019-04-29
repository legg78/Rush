create or replace force view fcl_fee_rate_vw as
select a.id
     , a.seqnum
     , a.fee_type
     , a.rate_type
     , a.inst_id
  from fcl_fee_rate a
/
