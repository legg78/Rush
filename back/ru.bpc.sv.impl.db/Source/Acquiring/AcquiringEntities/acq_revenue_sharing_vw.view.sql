create or replace force view acq_revenue_sharing_vw as
select id
     , seqnum
     , terminal_id
     , customer_id
     , account_id
     , provider_id
     , mod_id
     , fee_type
     , fee_id
     , inst_id
     , service_id
     , purpose_id
  from acq_revenue_sharing
/
