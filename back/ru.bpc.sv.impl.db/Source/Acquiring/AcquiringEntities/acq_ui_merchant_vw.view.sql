create or replace force view acq_ui_merchant_vw as
select
    a.id
  , a.seqnum
  , a.merchant_number
  , a.merchant_name
  , a.merchant_type
  , a.parent_id
  , a.mcc
  , a.status
  , a.contract_id
  , a.inst_id
  , a.split_hash
  , get_text('acq_merchant', 'label', a.id, b.lang) label
  , get_text('acq_merchant', 'description', a.id, b.lang) description
  , b.lang
  , c.product_id
  , c.contract_number
  , a.partner_id_code
  , a.risk_indicator
  , a.mc_assigned_id
from acq_merchant a
   , com_language_vw b
   , prd_contract c
where a.inst_id in (select inst_id from acm_cu_inst_vw)
  and a.contract_id = c.id
/
