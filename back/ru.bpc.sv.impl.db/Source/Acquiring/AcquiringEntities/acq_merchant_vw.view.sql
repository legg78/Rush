create or replace force view acq_merchant_vw as
select id
     , seqnum
     , merchant_number
     , merchant_name
     , merchant_type
     , parent_id
     , mcc
     , status
     , contract_id
     , inst_id
     , split_hash
     , partner_id_code
     , risk_indicator
     , mc_assigned_id
  from acq_merchant
/
