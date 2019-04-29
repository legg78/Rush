create or replace force view fcl_limit_rate_vw as
select a.id
     , a.seqnum
     , a.limit_type
     , a.rate_type
     , a.inst_id
  from fcl_limit_rate a
/
