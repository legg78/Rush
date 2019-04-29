create or replace force view acm_priv_limitation_vw as
select id
     , seqnum
     , priv_id
     , condition
     , limitation_type
  from acm_priv_limitation
/
