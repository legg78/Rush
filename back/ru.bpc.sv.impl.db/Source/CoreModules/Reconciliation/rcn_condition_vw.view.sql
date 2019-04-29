create or replace force view rcn_condition_vw as
select id
     , inst_id
     , recon_type
     , condition
     , condition_type
     , seqnum
     , provider_id
     , purpose_id
  from rcn_condition cnd
/
